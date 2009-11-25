From: Andrew Morton <akpm@linux-foundation.org>
Subject: Fw: Deadlock regression in v2.6.31.6
Date: Tue, 24 Nov 2009 23:35:55 -0800
Message-ID: <20091124233555.da6439c4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59240 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752111AbZKYHgJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Nov 2009 02:36:09 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Begin forwarded message:

Date: Tue, 24 Nov 2009 01:24:53 +0100
From: "Stephen R. van den Berg" <srb-PCMv+cxZuL0@public.gmane.org>
To: linux-kernel@vger.kernel.org
Subject: Deadlock regression in v2.6.31.6


During a Debian package update for the man-db package (regenerating the
man index), the kernel reproducibly entered into a deadlock which
resulted in the kernel getting stuck in rpciod (the kernel version).
This is happening on a system which has an NFS-mounted root-filesystem
(no other filesystems, except for tmpfs on /tmp).

The problem vanishes as soon as I run v2.6.31.5 (neither kernel contains
any significant modules).

Kernel trace at the point of deadlock:
---------------------------------------------------------------------------
Pid: 258, comm: rpciod/0 Not tainted (2.6.31.6-00004-gd334df2 #140)
EIP: 0060:[<c0216eae>] EFLAGS: 00000246 CPU: 0
Using defaults from ksymoops -t elf32-i386 -a i386
EAX: cf890000 EBX: cfa66400 ECX: c03834c4 EDX: cfa66534
ESI: cfa90420 EDI: cf407280 EBP: cf891ef0 ESP: cf891ee8
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
CR0: 8005003b CR2: b75a00a4 CR3: 0e8f3000 CR4: 00000090
Call Trace:
 [<c03f3129>] ? 0xc03f3129
 [<c03f4435>] 0xc03f4435
 [<c039a23f>] 0xc039a23f
 [<c0335bf2>] 0xc0335bf2
 [<c03f3c04>] 0xc03f3c04
 [<c03f2cd4>] 0xc03f2cd4
 [<c03f0d49>] 0xc03f0d49
 [<c03f5eeb>] 0xc03f5eeb
 [<c03f60a7>] 0xc03f60a7
 [<c021df90>] 0xc021df90
 [<c03f609c>] ? 0xc03f609c
 [<c0220669>] ? 0xc0220669
 [<c021dee5>] ? 0xc021dee5
 [<c02203d0>] 0xc02203d0
 [<c0220368>] ? 0xc0220368
 [<c0202d63>] 0xc0202d63
Pid: 258, comm: rpciod/0 Not tainted (2.6.31.6-00004-gd334df2 #140)
EIP: 0060:[<c0390d6c>] EFLAGS: 00000246 CPU: 0
EAX: ffffff9d EBX: cfa90420 ECX: 00000000 EDX: cfa15000
ESI: 97817dd4 EDI: 97817dd4 EBP: cf891f10 ESP: cf891e78
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
CR0: 8005003b CR2: b75a00a4 CR3: 0e8f3000 CR4: 00000090
Call Trace:
 [<c0336d75>] ? 0xc0336d75
 [<c03f38f8>] ? 0xc03f38f8
 [<c0216ead>] ? 0xc0216ead
 [<c039a79e>] 0xc039a79e
 [<c021de23>] ? 0xc021de23
 [<c021e177>] ? 0xc021e177
 [<c0335b96>] 0xc0335b96
 [<c03f413c>] 0xc03f413c
 [<c0216ead>] ? 0xc0216ead
 [<c03f5f0b>] ? 0xc03f5f0b
 [<c03f420b>] 0xc03f420b
 [<c021df90>] 0xc021df90
 [<c03f41f7>] ? 0xc03f41f7
 [<c0220669>] ? 0xc0220669
 [<c021dee5>] ? 0xc021dee5
 [<c02203d0>] 0xc02203d0
 [<c0220368>] ? 0xc0220368
 [<c0202d63>] 0xc0202d63
Warning (Oops_read): Code line not seen, dumping what data is available


>>EIP; c0216eae <local_bh_enable+c/e>   <=====

>>ECX; c03834c4 <tcp_shutdown+0/43>

Trace; c03f3129 <xprt_disconnect_done+39/3e>
Trace; c03f4435 <xs_tcp_state_change+1cd/1d4>
Trace; c039a23f <inet_shutdown+b3/c2>
Trace; c0335bf2 <kernel_sock_shutdown+9/b>
Trace; c03f3c04 <xs_tcp_send_request+103/117>
Trace; c03f2cd4 <xprt_transmit+142/214>
Trace; c03f0d49 <call_transmit+1b2/1ed>
Trace; c03f5eeb <__rpc_execute+6e/1d2>
Trace; c03f60a7 <rpc_async_schedule+b/d>
Trace; c021df90 <worker_thread+ab/109>
Trace; c03f609c <rpc_async_schedule+0/d>
Trace; c0220669 <autoremove_wake_function+0/2f>
Trace; c021dee5 <worker_thread+0/109>
Trace; c02203d0 <kthread+68/6d>
Trace; c0220368 <kthread+0/6d>
Trace; c0202d63 <kernel_thread_helper+7/10>

>>EIP; c0390d6c <tcp_v4_connect+2a0/3c1>   <=====

>>ESI; 97817dd4 <phys_startup_32+97617dd4/c0000000>
>>EDI; 97817dd4 <phys_startup_32+97617dd4/c0000000>

Trace; c0336d75 <kernel_sendmsg+28/37>
Trace; c03f38f8 <xs_send_kvec+6d/77>
Trace; c0216ead <local_bh_enable+b/e>
Trace; c039a79e <inet_stream_connect+85/1e6>
Trace; c021de23 <queue_work+e/10>
Trace; c021e177 <queue_delayed_work+c/1e>
Trace; c0335b96 <kernel_connect+d/12>
Trace; c03f413c <xs_tcp_setup_socket+1f9/29e>
Trace; c0216ead <local_bh_enable+b/e>
Trace; c03f5f0b <__rpc_execute+8e/1d2>
Trace; c03f420b <xs_tcp_connect_worker4+14/16>
Trace; c021df90 <worker_thread+ab/109>
Trace; c03f41f7 <xs_tcp_connect_worker4+0/16>
Trace; c0220669 <autoremove_wake_function+0/2f>
Trace; c021dee5 <worker_thread+0/109>
Trace; c02203d0 <kthread+68/6d>
Trace; c0220368 <kthread+0/6d>
Trace; c0202d63 <kernel_thread_helper+7/10>
---------------------------------------------------------------------------

strace log of the userspace processes at the time of deadlock:
---------------------------------------------------------------------------
[pid  3911] brk(0x8d0d000)              = 0x8d0d000
[pid  3911] close(7)                    = 0
[pid  3911] munmap(0xb75bc000, 524288)  = 0
[pid  3911] brk(0x8d0b000)              = 0x8d0b000
[pid  3911] brk(0x8d07000)              = 0x8d07000
[pid  3911] write(1, "\\F[]\ncommand for more information\\&. This command corresponds to the GetPrinterData() MS Platform SDK function\\&.\n.RE\n.PP\ngetdataex\n.RS 4\nGet printer driver data with keyname\n.RE\n.PP\ngetdriver <printername>\n.RS 4\nRetrieve the printer driver information (such as driver file, config file, dependent fi"..., 4041) = 4041
[pid  3911] exit_group(0)               = ?
Process 3911 detached
Process 3912 attached
[pid  3314] <... clone resumed> child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7672728) = 3912
[pid  3912] rt_sigaction(SIGHUP, NULL, {0x8058790, [], 0}, 8) = 0
[pid  3912] rt_sigaction(SIGHUP, {0x8058790, [], 0}, NULL, 8) = 0
[pid  3912] rt_sigaction(SIGINT, NULL, {0x8058790, [], 0}, 8) = 0
[pid  3912] rt_sigaction(SIGINT, {0x8058790, [], 0}, NULL, 8) = 0
[pid  3912] rt_sigaction(SIGTERM, NULL, {0x8058790, [], 0}, 8) = 0
[pid  3912] rt_sigaction(SIGTERM, {0x8058790, [], 0}, NULL, 8) = 0
[pid  3912] dup2(8, 0)                  = 0
[pid  3912] close(8)                    = 0
[pid  3912] dup2(9, 1 <unfinished ...>
[pid  3314] close(8 <unfinished ...>
[pid  3912] <... dup2 resumed> )        = 1
[pid  3912] close(9)                    = 0
[pid  3912] close(7)                    = 0
[pid  3912] dup(0)                      = 7
[pid  3912] rt_sigprocmask(SIG_BLOCK, [CHLD], [CHLD], 8) = 0
[pid  3912] rt_sigprocmask(SIG_SETMASK, [CHLD], NULL, 8) = 0
[pid  3912] pipe([8, 9])                = 0
[pid  3912] rt_sigprocmask(SIG_BLOCK, [CHLD], [CHLD], 8) = 0
[pid  3912] clone(Process 3913 attached
child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7672728) = 3913
[pid  3913] rt_sigaction(SIGHUP, NULL, {0x8058790, [], 0}, 8) = 0
[pid  3913] rt_sigaction(SIGHUP, {0x8058790, [], 0}, NULL, 8) = 0
[pid  3913] rt_sigaction(SIGINT, NULL, {0x8058790, [], 0}, 8) = 0
[pid  3913] rt_sigaction(SIGINT, {0x8058790, [], 0}, NULL, 8) = 0
[pid  3913] rt_sigaction(SIGTERM, NULL, {0x8058790, [], 0}, 8) = 0
[pid  3913] rt_sigaction(SIGTERM, {0x8058790, [], 0}, NULL, 8) = 0
[pid  3913] dup2(7, 0)                  = 0
[pid  3913] close(7)                    = 0
[pid  3913] dup2(9, 1)                  = 1
[pid  3913] close(9)                    = 0
[pid  3913] close(8)                    = 0
[pid  3913] close(7)                    = -1 EBADF (Bad file descriptor)
[pid  3913] dup(0)                      = 7
[pid  3913] fcntl64(7, F_GETFL)         = 0 (flags O_RDONLY)
[pid  3913] fstat64(7, {st_mode=S_IFIFO|0600, st_size=0, ...}) = 0
[pid  3913] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb77da000
[pid  3913] _llseek(7, 0, 0xbff30a18, SEEK_CUR) = -1 ESPIPE (Illegal seek)
[pid  3913] read(7, ".\\\"     Title: rpcclient\n.\\\"    Author: [see the \"AUTHOR\" section]\n.\\\" Generator: DocBook XSL Stylesheets v1.74.0 <http://docbook.sf.net/>\n.\\\"      Date: 09/30/2009\n.\\\"    Manual: User Commands\n.\\\"    Source: Samba 3.4\n.\\\"  Language: English\n.\\\"\n.TH \"RPCCLIENT\" \"1\" \"09/30/2009\" \"Samba 3\\&.4\" \"User C"..., 16384) = 16384
[pid  3913] _llseek(7, 0, 0xbff30a0c, SEEK_CUR) = -1 ESPIPE (Illegal seek)
[pid  3913] fstat64(1, {st_mode=S_IFIFO|0600, st_size=0, ...}) = 0
[pid  3913] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb77d9000
[pid  3913] write(1, ".\\\"     Title: rpcclient\n.\\\"    Author: [see the \"AUTHOR\" section]\n.\\\" Generator: DocBook XSL Stylesheets v1.74.0 <http://docbook.sf.net/>\n.\\\"      Date: 09/30/2009\n.\\\"    Manual: User Commands\n.\\\"    Source: Samba 3.4\n.\\\"  Language: English\n.\\\"\n.TH \"RPCCLIENT\" \"1\" \"09/30/2009\" \"Samba 3\\&.4\" \"User C"..., 4096) = 4096
[pid  3913] write(1, "\n.PP\nThis tool is part of the\n\\fBsamba\\fR(7)\nsuite\\&.\n.PP\n\\FCrpcclient\\F[]\nis a utility initially developed to test MS\\-RPC functionality in Samba itself\\&. It has undergone several stages of development and stability\\&. Many system administrators have now written scripts around it to manage Windows"..., 4096) = 4096
[pid  3913] write(1, ".RS 4\nSets the SMB username or username and password\\&.\n.sp\nIf %password is not specified, the user will be prompted\\&. The client will first check the\n\\fBUSER\\fR\nenvironment variable, then the\n\\fBLOGNAME\\fR\nvariable and if either exists, the string is uppercased\\&. If these environmental variables "..., 4096) = 4096
[pid  3913] read(7, "\\F[]\ncommand for more information\\&. This command corresponds to the GetPrinterData() MS Platform SDK function\\&.\n.RE\n.PP\ngetdataex\n.RS 4\nGet printer driver data with keyname\n.RE\n.PP\ngetdriver <printername>\n.RS 4\nRetrieve the printer driver information (such as driver file, config file, dependent fi"..., 4096) = 4041
[pid  3913] read(7, "", 4096)           = 0
[pid  3913] write(1, "RE\n.PP\nenumdomgroups\n.RS 4\nEnumerate domain groups\n.RE\n.PP\nenumalsgroups\n.RS 4\nEnumerate alias groups\n.RE\n.PP\ncreatedomuser\n.RS 4\nCreate domain user\n.RE\n.PP\nsamlookupnames\n.RS 4\nLook up names\n.RE\n.PP\nsamlookuprids\n.RS 4\nLook up names\n.RE\n.PP\ndeletedomuser\n.RS 4\nDelete domain user\n.RE\n.PP\nsamquerysec"..., 4096) = 4096
[pid  3913] close(7)                    = 0
[pid  3913] munmap(0xb77da000, 4096)    = 0
[pid  3913] write(1, "\\F[]\ncommand for more information\\&. This command corresponds to the GetPrinterData() MS Platform SDK function\\&.\n.RE\n.PP\ngetdataex\n.RS 4\nGet printer driver data with keyname\n.RE\n.PP\ngetdriver <printername>\n.RS 4\nRetrieve the printer driver information (such as driver file, config file, dependent fi"..., 4041) = 4041
[pid  3913] exit_group(0)               = ?
Process 3913 detached
[pid  3314] <... close resumed> )       = 0
[pid  3912] close(7 <unfinished ...>
[pid  3314] close(9)                    = 0
[pid  3314] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid  3314] --- SIGCHLD (Child exited) @ 0 (0) ---
[pid  3314] waitpid(-1, [{WIFEXITED(s) && WEXITSTATUS(s) == 0}], WNOHANG) = 3911
[pid  3314] waitpid(-1, 0xbff31b08, WNOHANG) = 0
[pid  3314] sigreturn()                 = ? (mask now [])
[pid  3314] read(7,  <unfinished ...>
[pid  3912] <... close resumed> )       = 0
[pid  3912] close(9)                    = 0
[pid  3912] rt_sigprocmask(SIG_SETMASK, [CHLD], NULL, 8) = 0
[pid  3912] read(8, ".\\\"     Title: rpcclient\n.\\\"    Author: [see the \"AUTHOR\" section]\n.\\\" Generator: DocBook XSL Stylesheets v1.74.0 <http://docbook.sf.net/>\n.\\\"      Date: 09/30/2009\n.\\\"    Manual: User Commands\n.\\\"    Source: Samba 3.4\n.\\\"  Language: English\n.\\\"\n.TH \"RPCCLIENT\" \"1\" \"09/30/2009\" \"Samba 3\\&.4\" \"User C"..., 4096) = 4096
[pid  3912] open("/usr/lib/gconv/gconv-modules.cache", O_RDONLY) = 7
[pid  3912] fstat64(7, {st_mode=S_IFREG|0644, st_size=26048, ...}) = 0
[pid  3912] mmap2(NULL, 26048, PROT_READ, MAP_SHARED, 7, 0) = 0xb7635000
[pid  3912] close(7)                    = 0
[pid  3912] brk(0x8d10000)              = 0x8d10000
[pid  3912] read(8, "\n.PP\nThis tool is part of the\n\\fBsamba\\fR(7)\nsuite\\&.\n.PP\n\\FCrpcclient\\F[]\nis a utility initially developed to test MS\\-RPC functionality in Samba itself\\&. It has undergone several stages of development and stability\\&. Many system administrators have now written scripts around it to manage Windows"..., 61440) = 16329
[pid  3912] read(8, "", 45111)          = 0
[pid  3912] brk(0x8d40000)              = 0x8d40000
[pid  3912] fstat64(1, {st_mode=S_IFIFO|0600, st_size=0, ...}) = 0
[pid  3912] mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xb77da000
[pid  3912] write(1, ".\\\"     Title: rpcclient\n.\\\"    Author: [see the \"AUTHOR\" section]\n.\\\" Generator: DocBook XSL Stylesheets v1.74.0 <http://docbook.sf.net/>\n.\\\"      Date: 09/30/2009\n.\\\"    Manual: User Commands\n.\\\"    Source: Samba 3.4\n.\\\"  Language: English\n.\\\"\n.TH \"RPCCLIENT\" \"1\" \"09/30/2009\" \"Samba 3\\&.4\" \"User C"..., 16384) = 16384
[pid  3314] <... read resumed> ".\\\"     Title: rpcclient\n.\\\"    Author: [see the \"AUTHOR\" section]\n.\\\" Generator: DocBook XSL Stylesheets v1.74.0 <http://docbook.sf.net/>\n.\\\"      Date: 09/30/2009\n.\\\"    Manual: User Commands\n.\\\"    Source: Samba 3.4\n.\\\"  Language: English\n.\\\"\n.TH \"RPCCLIENT\" \"1\" \"09/30/2009\" \"Samba 3\\&.4\" \"User C"..., 1024) = 1024
[pid  3314] read(7, "oupper \\\\$*\n.el \\{\\\n\\\\$*\n.\\}\n..\n.\\\" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n.\\\" SH - level-one heading that works better for non-TTY output\n.\\\" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n.de1 SH\n.if t \\{\\\n.sp 1\n.\\}\n.sp \\\\n[PD]u\n.nr an-level 1\n.set-an-"..., 1024) = 1024
[pid  3314] read(7, "dent \\\\n[IN]\n.fi\n.in \\\\n[IN]u\n.ti \\\\n[SN]u\n.it 1 an-trap\n.nr an-no-space-flag 1\n.nr an-break-flag 1\n.ps \\\\n[PS-SS]u\n.ps +2\n.ft B\n.ne (2v + 1u)\n.if \\\\n[.$] \\&\\\\$*\n..\n.\\\" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n.\\\" BB/BE - put background/screen (filled box) around block of te"..., 1024) = 1024
[pid  3314] read(7, "~~~~~~~~~~~~~~~~~~~~~~~~\n.de BM\n.if t \\{\\\n.br\n.ll -2n\n.gcolor red\n.di BX\n.\\}\n..\n.de EM\n.if t \\{\\\n.br\n.di\n.ll\n.gcolor\n.nr BH \\\\n(dn\n.ne \\\\n(BHu\n\\M[\\\\$1]\\D'P -.75n 0 0 \\\\n(BHu -(\\\\n[.i]u - \\\\n(INu - .75n) 0 0 -\\\\n(BHu'\\M[]\n.in 0\n.nf\n.BX\n.in\n.fi\n.\\}\n..\n.\\\" ----------------------------------------------"..., 1024) = 1024
[pid  3314] read(7, "\n.PP\nThis tool is part of the\n\\fBsamba\\fR(7)\nsuite\\&.\n.PP\n\\FCrpcclient\\F[]\nis a utility initially developed to test MS\\-RPC functionality in Samba itself\\&. It has undergone several stages of development and stability\\&. Many system administrators have now written scripts around it to manage Windows"..., 1024) = 1024
[pid  3314] read(7, "is parameter will force the client to assume that the server is on the machine with the specified IP address and the NetBIOS name component of the resource being connected to will be ignored\\&.\n.sp\nThere is no default for this parameter\\&. If not supplied, it will be determined automatically by the "..., 1024) = 1024
[pid  3314] read(7, "xtremely cryptic\\&.\n.sp\nNote that specifying this parameter here will override the\n\\m[blue]\\fBlog level\\fR\\m[]\nparameter in the\n\\FCsmb\\&.conf\\F[]\nfile\\&.\n.RE\n.PP\n\\-V\n.RS 4\nPrints the program version number\\&.\n.RE\n.PP\n\\-s <configuration file>\n.RS 4\nThe file specified contains the configuration detail"..., 1024) = 1024
[pid  3314] read(7, "that does not require a password\\&.\n.sp\nUnless a password is specified on the command line or this parameter is specified, the client will request a password\\&.\n.sp\nIf a password is specified on the command line and this option is also defined the password on the command line will be silently ingnor"..., 1024) = 1024
[pid  3314] read(7, ".RS 4\nSets the SMB username or username and password\\&.\n.sp\nIf %password is not specified, the user will be prompted\\&. The client will first check the\n\\fBUSER\\fR\nenvironment variable, then the\n\\fBLOGNAME\\fR\nvariable and if either exists, the string is uppercased\\&. If these environmental variables "..., 1024) = 1024
[pid  3314] read(7, "ry NetBIOS name>\n.RS 4\nThis option allows you to override the NetBIOS name that Samba uses for itself\\&. This is identical to setting the\n\\m[blue]\\fBnetbios name\\fR\\m[]\nparameter in the\n\\FCsmb\\&.conf\\F[]\nfile\\&. However, a command line setting will take precedence over settings in\n\\FCsmb\\&.conf\\F[]\\"..., 1024) = 1024
[pid  3314] read(7, "tions\n.RS 4\nTCP socket options to set on the client socket\\&. See the socket options parameter in the\n\\FCsmb\\&.conf\\F[]\nmanual page for the list of valid options\\&.\n.RE\n.PP\n\\-h|\\-\\-help\n.RS 4\nPrint a summary of command line options\\&.\n.RE\n.SH \"COMMANDS\"\n.SS \"LSARPC\"\n.PP\nlsaquery\n.RS 4\nQuery info pol"..., 1024) = 1024
[pid  3314] read(7, "saquerysecobj\n.RS 4\nQuery LSA security object\n.RE\n.SS \"LSARPC\\-DS\"\n.PP\ndsroledominfo\n.RS 4\nGet Primary Domain Information\n.RE\n.PP\n.PP\n\\fIDFS\\fR\n.PP\ndfsexist\n.RS 4\nQuery DFS support\n.RE\n.PP\ndfsadd\n.RS 4\nAdd a DFS share\n.RE\n.PP\ndfsremove\n.RS 4\nRemove a DFS share\n.RE\n.PP\ndfsgetinfo\n.RS 4\nQuery DFS shar"..., 1024) = 1024
[pid  3314] read(7, "RE\n.PP\nenumdomgroups\n.RS 4\nEnumerate domain groups\n.RE\n.PP\nenumalsgroups\n.RS 4\nEnumerate alias groups\n.RE\n.PP\ncreatedomuser\n.RS 4\nCreate domain user\n.RE\n.PP\nsamlookupnames\n.RS 4\nLook up names\n.RE\n.PP\nsamlookuprids\n.RS 4\nLook up names\n.RE\n.PP\ndeletedomuser\n.RS 4\nDelete domain user\n.RE\n.PP\nsamquerysec"..., 1024) = 1024
[pid  3314] read(7, ":\\e\nHelp File Name:\\e\nLanguage Monitor Name:\\e\nDefault Data Type:\\e\nComma Separated list of Files\n.EB lightgray adjust-for-leading-newline\n.if t \\{\\\n.sp 1\n.\\}\n.fi\n.fam\n.ps +1\n.if n \\{\\\n.RE\n.\\}\n.sp\nAny empty fields should be enter as the string \"NULL\"\\&.\n.sp\nSamba does not need to support the concept"..., 1024) = 1024
[pid  3314] read(7, "the printer driver must already be installed on the server (see\n\\FCadddriver\\F[]) and the\n\\fIport\\fRmust be a valid port name (see\n\\FCenumports\\F[]\\&.\n.RE\n.PP\ndeldriver\n.RS 4\nDelete the specified printer driver for all architectures\\&. This does not delete the actual driver files from the server, on"..., 1024) = 1024
[pid  3314] read(7, "bs <printer>\n.RS 4\nList the jobs and status of a given printer\\&. This command corresponds to the MS Platform SDK EnumJobs() function\n.RE\n.PP\nenumkey\n.RS 4\nEnumerate printer keys\n.RE\n.PP\nenumports [level]\n.RS 4\nExecutes an EnumPorts() call using the specified info level\\&. Currently only info levels"..., 1024) = 1024
[pid  3314] read(7,  <unfinished ...>
[pid  3912] read(8, "", 65536)          = 0
[pid  3912] read(8, "", 65536)          = 0
[pid  3912] close(8)                    = 0
[pid  3912] waitpid(-1, [{WIFEXITED(s) && WEXITSTATUS(s) == 0}], 0) = 3913
[pid  3912] write(1, "\\F[]\ncommand for more information\\&. This command corresponds to the GetPrinterData() MS Platform SDK function\\&.\n.RE\n.PP\ngetdataex\n.RS 4\nGet printer driver data with keyname\n.RE\n.PP\ngetdriver <printername>\n.RS 4\nRetrieve the printer driver information (such as driver file, config file, dependent fi"..., 4041) = 4041
[pid  3314] <... read resumed> "\\F[]\ncommand for more information\\&. This command corresponds to the GetPrinterData() MS Platform SDK function\\&.\n.RE\n.PP\ngetdataex\n.RS 4\nGet printer driver data with keyname\n.RE\n.PP\ngetdriver <printername>\n.RS 4\nRetrieve the printer driver information (such as driver file, config file, dependent fi"..., 1024) = 1024
[pid  3314] read(7, "irectory\n.RE\n.PP\nopenprinter <printername>\n.RS 4\nExecute an OpenPrinterEx() and ClosePrinter() RPC against a given printer\\&.\n.RE\n.PP\nsetdriver <printername> <drivername>\n.RS 4\nExecute a SetPrinter() command to update the printer driver associated with an installed printer\\&. The printer driver must"..., 1024) = 1024
[pid  3314] read(7, "4\nQuery Sam Deltas\n.RE\n.PP\nsamlogon\n.RS 4\nSam Logon\n.RE\n.SS \"GENERAL COMMANDS\"\n.PP\ndebuglevel\n.RS 4\nSet the current debug level used to log information\\&.\n.RE\n.PP\nhelp (?)\n.RS 4\nPrint a listing of all known commands or extended help on a particular command\\&.\n.RE\n.PP\nquit (exit)\n.RS 4\nExit\n\\FCrpccli"..., 1024) = 1024
[pid  3314] read(7, "implementation is also a bit rough, and as more of the services are understood, it can even result in versions of\n\\fBsmbd\\fR(8)\nand\n\\fBrpcclient\\fR(1)\nthat are incompatible for some commands or services\\&. Additionally, the developers are sending reports to Microsoft, and problems found or reported "..., 1024) = 969
[pid  3314] read(7,  <unfinished ...>
[pid  3912] exit_group(0)               = ?
Process 3912 detached
[pid  3314] <... read resumed> "", 1024) = 0
[pid  3314] close(7)                    = 0
[pid  3314] waitpid(-1, [{WIFEXITED(s) && WEXITSTATUS(s) == 0}], 0) = 3912
[pid  3314] --- SIGCHLD (Child exited) @ 0 (0) ---
[pid  3314] sigreturn()                 = ? (mask now [])
[pid  3314] waitpid(-1, 0xbff31fe8, WNOHANG) = -1 ECHILD (No child processes)
[pid  3314] lseek(5, 129260, SEEK_SET)  = 129260
[pid  3314] write(5, "rpcclient\0", 10) = 10
[pid  3314] write(5, "-\t1\t1\t1254554345\tA\t-\t-\tgz\ttool for executing client side MS-RPC functions\0", 74) = 74
[pid  3314] lseek(5, 65536, SEEK_SET)   = 65536
[pid  3314] write(5, "\4\0\0\0\20\0\0\0\325\313\1\0.\0\0\0\5\t\2\0009\0\0\0&\244\1\0\337s\0\0!\f\2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\275\1\0\0\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0]\34L-squi\0\200\1\0\21\0\0\0+\0\0\0\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0&@\332/git-<\200\1\0\20\0\0\0J\0\0\0kA\16yedit\226\200\1\0\t\0\0\0001\0\0\0c\34\2221sane\320\200\1\0\v\0\0\0P\0\0\0\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\377\377\377\377\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"..., 32768) = 32768
[pid  3314] lstat64("/usr/share/man/man1/netkit-rsh.1.gz", {st_mode=S_IFREG|0644, st_size=2227, ...}) = 0
[pid  3314] lseek(5, 118788, SEEK_SET)  = 118788
[pid  3314] read(5, "netkit-rsh\0-\t1\t1\t1187257038\tA\t-\t-\tgz\tremote shell\0", 50) = 50
[pid  3314] lstat64("/usr/share/man/man1/wbinfo.1.gz", {st_mode=S_IFREG|0644, st_size=3872, ...}) = 0
[pid  3314] stat64("/usr/share/man/man1/wbinfo.1.gz", {st_mode=S_IFREG|0644, st_size=3872, ...}) = 0
[pid  3314] stat64("/usr/share/man/man1/wbinfo.1.gz", {st_mode=S_IFREG|0644, st_size=3872, ...}) = 0
[pid  3314] rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
[pid  3314] rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
[pid  3314] open("/usr/share/man/man1/wbinfo.1.gz", O_RDONLY|O_LARGEFILE) = 7
[pid  3314] pipe([8, 9])                = 0
[pid  3314] rt_sigprocmask(SIG_BLOCK, [CHLD], [], 8) = 0
[pid  3314] clone(Process 3914 attached
child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0xb7672728) = 3914
[pid  3914] rt_sigaction(SIGHUP, NULL, {0x8058790, [], 0}, 8) = 0
[pid  3914] rt_sigaction(SIGHUP, {0x8058790, [], 0}, NULL, 8) = 0
[pid  3914] rt_sigaction(SIGINT, NULL, {0x8058790, [], 0}, 8) = 0
[pid  3914] rt_sigaction(SIGINT, {0x8058790, [], 0}, NULL, 8) = 0
[pid  3914] rt_sigaction(SIGTERM, NULL, {0x8058790, [], 0}, 8) = 0
[pid  3914] rt_sigaction(SIGTERM, {0x8058790, [], 0}, NULL, 8) = 0
[pid  3914] dup2(7, 0)                  = 0
[pid  3914] close(7)                    = 0
[pid  3914] dup2(9, 1
---------------------------------------------------------------------------

It reproducibly ends at the dup2(9,1), exact same spot (even after a reboot).

The problem is gone now though, after backing down to 2.6.31.5.
-- 
Sincerely,
           Stephen R. van den Berg.
--
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
