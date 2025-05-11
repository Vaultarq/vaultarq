import os
import unittest
from unittest import mock

from vaultarq.vaultarq import load_env, is_available


class TestVaultarq(unittest.TestCase):
    def setUp(self):
        # Clear environment variables before each test
        for key in list(os.environ.keys()):
            if key not in ('PATH', 'PYTHONPATH'):
                os.environ.pop(key)

    @mock.patch('vaultarq.vaultarq._run_command')
    @mock.patch('vaultarq.vaultarq.shutil.which')
    def test_is_available_when_available(self, mock_which, mock_run):
        mock_which.return_value = '/usr/local/bin/vaultarq'
        mock_run.return_value = (True, 'vaultarq version 0.1.0', '')
        
        self.assertTrue(is_available())
        mock_run.assert_called_once()

    @mock.patch('vaultarq.vaultarq._run_command')
    @mock.patch('vaultarq.vaultarq.shutil.which')
    def test_is_available_when_not_available(self, mock_which, mock_run):
        mock_which.return_value = None
        
        self.assertFalse(is_available())
        mock_run.assert_not_called()

    @mock.patch('vaultarq.vaultarq._run_command')
    def test_load_env_success(self, mock_run):
        mock_run.return_value = (True, 'export API_KEY="secret"\nexport DB_PASSWORD="password"', '')
        
        result = load_env()
        
        self.assertTrue(result)
        self.assertEqual(os.environ.get('API_KEY'), 'secret')
        self.assertEqual(os.environ.get('DB_PASSWORD'), 'password')
        mock_run.assert_called_with(['vaultarq', 'export', '--bash'])

    @mock.patch('vaultarq.vaultarq._run_command')
    def test_load_env_with_options(self, mock_run):
        # First call for linking environment, second for export
        mock_run.side_effect = [
            (True, '', ''),  # link command
            (True, 'DB_URL=postgres://user:pass@localhost/db', '')  # export command
        ]
        
        result = load_env(
            bin_path='/custom/vaultarq',
            environment='prod',
            format='dotenv'
        )
        
        self.assertTrue(result)
        self.assertEqual(os.environ.get('DB_URL'), 'postgres://user:pass@localhost/db')
        mock_run.assert_any_call(['/custom/vaultarq', 'link', 'prod'])
        mock_run.assert_any_call(['/custom/vaultarq', 'export', '--dotenv'])

    @mock.patch('vaultarq.vaultarq._run_command')
    @mock.patch('vaultarq.vaultarq.is_available')
    def test_load_env_vaultarq_not_available(self, mock_is_available, mock_run):
        mock_is_available.return_value = False
        
        result = load_env()
        
        self.assertFalse(result)
        mock_run.assert_not_called()

    @mock.patch('vaultarq.vaultarq._run_command')
    @mock.patch('vaultarq.vaultarq.is_available')
    def test_load_env_vaultarq_not_available_throws(self, mock_is_available, mock_run):
        mock_is_available.return_value = False
        
        with self.assertRaises(FileNotFoundError):
            load_env(throw_if_not_found=True)

    @mock.patch('vaultarq.vaultarq._run_command')
    def test_load_env_invalid_format(self, mock_run):
        with self.assertRaises(ValueError):
            load_env(format='invalid')


if __name__ == '__main__':
    unittest.main() 