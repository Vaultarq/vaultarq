import { Vaultarq } from './index';
import { exec } from 'child_process';

jest.mock('child_process', () => ({
  exec: jest.fn(),
}));

describe('Vaultarq', () => {
  let vaultarq: Vaultarq;
  
  beforeEach(() => {
    vaultarq = new Vaultarq();
    (exec as jest.Mock).mockReset();
  });

  describe('isAvailable', () => {
    it('should return true when vaultarq is available', async () => {
      mockExecSuccess('vaultarq version 0.1.0');
      
      const result = await vaultarq.isAvailable();
      
      expect(result).toBe(true);
      expect(exec).toHaveBeenCalledWith('vaultarq --version || vaultarq');
    });

    it('should return false when vaultarq is not available', async () => {
      mockExecFailure('command not found: vaultarq');
      
      const result = await vaultarq.isAvailable();
      
      expect(result).toBe(false);
      expect(exec).toHaveBeenCalledWith('vaultarq --version || vaultarq');
    });
  });

  describe('load', () => {
    it('should load secrets successfully', async () => {
      mockExecSuccess('export API_KEY="secret"\nexport DB_PASSWORD="password"');
      
      const result = await vaultarq.load();
      
      expect(result).toBe(true);
      expect(process.env.API_KEY).toBe('secret');
      expect(process.env.DB_PASSWORD).toBe('password');
      expect(exec).toHaveBeenCalledWith('vaultarq export --bash');
    });

    it('should load secrets with custom options', async () => {
      mockExecSuccess('export API_KEY="prod-secret"');
      
      const result = await vaultarq.load({
        environment: 'prod',
        format: 'dotenv',
        binPath: '/custom/vaultarq'
      });
      
      expect(result).toBe(true);
      expect(process.env.API_KEY).toBe('prod-secret');
      expect(exec).toHaveBeenCalledWith('/custom/vaultarq link prod');
      expect(exec).toHaveBeenCalledWith('/custom/vaultarq export --dotenv');
    });

    it('should return false when vaultarq is not available and throwIfNotFound is false', async () => {
      mockExecFailure('command not found: vaultarq');
      
      const result = await vaultarq.load();
      
      expect(result).toBe(false);
    });

    it('should throw an error when vaultarq is not available and throwIfNotFound is true', async () => {
      mockExecFailure('command not found: vaultarq');
      
      await expect(vaultarq.load({ throwIfNotFound: true }))
        .rejects.toThrow();
    });
  });

  // Helper functions
  function mockExecSuccess(stdout: string) {
    (exec as jest.Mock).mockImplementation((command, callback) => {
      if (callback) {
        callback(null, { stdout, stderr: '' });
      }
      return {
        stdout,
        stderr: ''
      };
    });
  }

  function mockExecFailure(stderr: string) {
    const error = new Error('Command failed');
    (error as any).stderr = stderr;
    
    (exec as jest.Mock).mockImplementation((command, callback) => {
      if (callback) {
        callback(error, { stdout: '', stderr });
      }
      throw error;
    });
  }
}); 