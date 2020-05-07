# Plan name: simp_update
#
# Wraps the simp_update task to pass the appropriate parameters.
plan simp_update (
  TargetSpec                  $targets       = get_targets('all'),
  Enum['git', 'ssh', 'https'] $git_transport = 'git',
) {
  run_task_with('simp_update', $targets) |$target| {
    $vars = $target.vars
    case $git_transport {
      'https': { $url = 'clone_url' }
      default: { $url = "${git_transport}_url" }
    }

    $args = {
      'path' => $vars['path'],
      'url'  => $vars[$url],
    }

    if $vars['fork'] {
      $_args = $args + {
        'parent' => $vars['parent'][$url],
      }
    } else {
      $_args = $args
    }

    $_args
  }
}
