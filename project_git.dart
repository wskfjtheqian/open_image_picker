import 'dart:io';

List<Map<String, String>> configs = [
  {
    'name': 'open_file',
    'git': 'git@192.168.2.252:yttx/open_file.git',
    'branch': 'master',
  },
];

Future<void> log(String name, String text, Future Function() call) async {
  print('$text\n:$name');
  ProcessResult result = await call();
  if (result.stdout?.toString()?.isNotEmpty ?? false) {
    print('${result.stdout?.toString()}\n:$name');
  } else if (result.stderr?.toString()?.isNotEmpty ?? false) {
    print('${result.stderr?.toString()}\n:$name');
  }
}

void main(List<String> arguments) {
  configs.forEach((config) async {
    try {
      if (Directory('../${config['name']}').existsSync()) {
        await log(config['name']!, '开始更新', () => Process.run('git', ['pull'], workingDirectory: '../${config['name']}'));
      } else {
        await log(config['name']!, '开始克隆', () => Process.run('git', ['clone', config['git']!, config['name']!], workingDirectory: '../'));
        await log(
          config['name']!,
          '切换分支${config['branch']}',
          () => Process.run('git', ['checkout', config['branch']!], workingDirectory: '../${config['name']}'),
        );
      }
      if (File('../${config['name']}/project_git.dart').existsSync()) {
        await log(config['name']!, '检测并更新', () => Process.run('dart', ['run', 'project_git.dart'], workingDirectory: '../${config['name']}'));
      }
    } catch (e) {
      print(e);
    }
  });
}
