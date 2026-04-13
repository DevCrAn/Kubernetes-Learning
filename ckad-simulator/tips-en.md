# CKAD Tips - Kubernetes 1.35

In this section we'll provide some tips on how to handle the CKAD exam and browser terminal.

---

## Knowledge

- Study all topics as proposed in the curriculum until you feel comfortable with all
- Learn and Study the in-browser scenarios on https://killercoda.com/killer-shell-ckad
- Read this and do all examples: https://kubernetes.io/docs/concepts/cluster-administration/logging
- Understand Rolling Update Deployment including `maxSurge` and `maxUnavailable`
- Do 1 or 2 test sessions with this CKAD Simulator. Understand the solutions and maybe try out other ways to achieve the same
- Be fast and breathe kubectl

---

## CKAD Preparation

**Read the Curriculum**  
https://github.com/cncf/curriculum

**Read the Handbook**  
https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2

**Read the important tips**  
https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad

**Read the FAQ**  
https://docs.linuxfoundation.org/tc-docs/certification/faq-cka-ckad

---

## Kubernetes Documentation

Get familiar with the Kubernetes documentation and be able to use the search. Allowed resources are:

- https://kubernetes.io/docs
- https://kubernetes.io/blog
- https://helm.sh/docs

> ℹ️ Verify the list [here](https://docs.linuxfoundation.org/tc-docs/certification/certification-resources-allowed)

---

## The Exam UI / Remote Desktop

The real exam, as well as the simulator, provides a Remote Desktop (XFCE) on Ubuntu/Debian. Coming from OSX/Windows there will be changes in copy&paste for example.

**Official Information**  
ExamUI: [Performance Based Exams](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-user-interface)

### Lagging

There could be some lagging, definitely make sure you are using a good internet connection because your webcam and screen are transferring all the time.

### Kubectl autocompletion and commands

The following are installed or pre-configured, [verify the list here](https://docs.linuxfoundation.org/tc-docs/certification/tips-cka-and-ckad):

- `kubectl` with `k` alias and Bash autocompletion
- `yq` or YAML processing
- `curl` and `wget` for testing web services
- `man` and man pages for further documentation

> ℹ️ You're allowed to install tools, like `tmux` for terminal multiplexing or `jq` for JSON processing

### Copy & Paste

Copy and pasting will work like normal in a Linux Environment:

- **What always works:** copy+paste using right mouse context menu
- **What works in Terminal:** `Ctrl+Shift+c` and `Ctrl+Shift+v`
- **What works in other apps like Firefox:** `Ctrl+c` and `Ctrl+v`

### Score

There are 15-20 questions in the exam. Your results will be automatically checked according to the handbook. If you don't agree with the results you can request a review by contacting the Linux Foundation Support.

### Notepad & Flagging Questions

You can flag questions to return to later. This is just a marker for yourself and won't affect scoring. You also have access to a simple notepad in the browser which can be used to store any kind of plain text. It might make sense to use this and write down additional information about flagged questions. Instead of using the notepad you could also open Mousepad (XFCE application inside the Remote Desktop) or create a file with Vim.

### VSCodium

You can use VSCodium to edit files and you can also use its terminal to run commands. You're not allowed to install any VSCodium extensions.

### Servers

Each question needs to be solved on a specific instance other than your main terminal. You'll need to connect to the correct instance via ssh, the command is provided before each question.

---

## PSI Bridge

Starting with PSI Bridge:

- The exam will now be taken using the PSI Secure Browser, which can be downloaded using the newest versions of Microsoft Edge, Safari, Chrome, or Firefox
- Multiple monitors will no longer be permitted
- Use of personal bookmarks will no longer be permitted

The new ExamUI includes improved features such as:

- A remote desktop configured with the tools and software needed to complete the tasks
- A timer that displays the actual time remaining (in minutes) and provides an alert with 30, 15, or 5 minute remaining
- The content panel remains the same (presented on the Left Hand Side of the ExamUI)

[Read more here](https://docs.linuxfoundation.org/tc-docs/certification/lf-handbook2/exam-user-interface/psi-bridge-proctoring-platform).

---

## Terminal Handling

### Bash Aliases

In the real exam, each question has to be solved on a different instance to which you connect via ssh. This means it's not advised to configure bash aliases because they wouldn't be available on the instances accessed by ssh.

### Be fast

Use the `history` command to reuse already entered commands or use even faster history search through `Ctrl+r`.

If a command takes some time to execute, like sometimes `kubectl delete pod x`. You can put a task in the background using `Ctrl+z` and pull it back into foreground running command `fg`.

You can delete pods fast with:

```bash
k delete pod x --grace-period 0 --force
```

---

## Vim

Be great with vim.

### Settings

In case you face a situation where vim is not configured properly and you face for example issues with pasting copied content you should be able to configure via `~/.vimrc` or by entering manually in vim settings mode:

```vim
set tabstop=2
set expandtab
set shiftwidth=2
```

The `expandtab` option makes sure to use spaces for tabs.

Note that changes in `~/.vimrc` will not be transferred when connecting to other instances via ssh.

### Toggle vim line numbers

When in vim you can press `Esc` and type `:set number` or `:set nonumber` followed by `Enter` to toggle line numbers. This can be useful when finding syntax errors based on line - but can be bad when wanting to mark&copy by mouse. You can also just jump to a line number with `Esc :22 + Enter`.

### Copy&Paste

Get used to copy/paste/cut with vim:

- **Mark lines:** `Esc+V` (then arrow keys)
- **Copy marked lines:** `y`
- **Cut marked lines:** `d`
- **Paste lines:** `p` or `P`

### Indent multiple lines

To indent multiple lines press `Esc` and type `:set shiftwidth=2`. First mark multiple lines using `Shift+v` and the up/down keys. Then to indent the marked lines press `>` or `<`. You can then press `.` to repeat the action.
