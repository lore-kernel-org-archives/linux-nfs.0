From: Mark Goodman <mgoodman@CSUA.Berkeley.EDU>
Subject: Oops on killing process with soft-unmounted NFS3 krb5 mount
Date: Mon, 31 Jan 2005 12:50:11 -0800
Message-ID: <41FE9A03.1030008@csua.berkeley.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CviV0-0003wi-VD
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 12:50:18 -0800
Received: from soda.csua.berkeley.edu ([128.32.112.233] ident=[hPhnfMxe7xjGNulNRzUAKHPjcfwtTGYH])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CviUy-0002B8-Sv
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 12:50:18 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I am running 2.6.11-rc2 with your patches. I recall this behavior on 
2.6.8 as well.

I can consistently reproduce this oops on my Fedora Core 3 machine with 
the following steps:

Login as a normal user with a home directory on an NFS3 krb5 mount
Login as root and run init 1. init 1 unmounts the mount.
Kill the normal user's shell.

In practice, this often happens when switching to runlevel 6 for a reboot.

Jan 31 12:32:39 soda kernel: net/sunrpc/rpc_pipe.c: rpc_lookup_parent 
failed to find path /nfs/clnt0/krb5
Jan 31 12:32:39 soda kernel: Unable to handle kernel NULL pointer 
dereference at virtual address 0000005c
Jan 31 12:32:39 soda kernel:  printing eip:
Jan 31 12:32:39 soda kernel: f940ff40
Jan 31 12:32:39 soda kernel: *pde = 00000000
Jan 31 12:32:39 soda kernel: Oops: 0000 [#1]
Jan 31 12:32:39 soda kernel: Modules linked in: des nfs lockd md5 ipv6 
parport_pc lp parport autofs4 rpcsec_gss_krb5 auth_rpcgss sunrpc video 
button battery ac uhci_hcd ehci_hcd snd_intel8x0 snd_ac97_codec 
snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc 
tg3 floppy dm_snapshot dm_zero dm_mirror ext3 jbd dm_mod ata_piix libata 
sd_mod scsi_mod
Jan 31 12:32:39 soda kernel: CPU:    0
Jan 31 12:32:39 soda kernel: EIP:    0060:[<f940ff40>]    Not tainted VLI
Jan 31 12:32:39 soda kernel: EFLAGS: 00010286   (2.6.11-rc2)
Jan 31 12:32:39 soda kernel: EIP is at gss_pipe_release+0x10/0x290 
[auth_rpcgss]
Jan 31 12:32:39 soda kernel: eax: f58d1600   ebx: 00000000   ecx: 
00000073   edx: f940ff30
Jan 31 12:32:39 soda kernel: esi: f5b46630   edi: f5b4604c   ebp: 
00000000   esp: f5726d00
Jan 31 12:32:39 soda kernel: ds: 007b   es: 007b   ss: 0068
Jan 31 12:32:39 soda kernel: Process bash (pid: 4354, 
threadinfo=f5726000 task=f5674b30)
Jan 31 12:32:39 soda kernel: Stack: f5726d00 00000296 f504e800 f504e9c8 
ffffffe0 00000000 f93d9126 f504e800
Jan 31 12:32:39 soda kernel:        f5b46630 f5b4604c 00000000 f93d92f9 
f5b460ec f93d9d00 00000005 f5726d90
Jan 31 12:32:39 soda kernel:        f5498b2c 10ee271a f58d890c f5726000 
00000001 f5b46630 f5b46268 f504ed00
Jan 31 12:32:39 soda kernel: Call Trace:
Jan 31 12:32:39 soda kernel:  [<f93d9126>] __rpc_purge_upcall+0xa6/0xb0 
[sunrpc]
Jan 31 12:32:39 soda kernel:  [<f93d92f9>] rpc_close_pipes+0x89/0x90 
[sunrpc]
Jan 31 12:32:39 soda kernel:  [<f93d9d00>] rpc_depopulate+0x280/0x410 
[sunrpc]
Jan 31 12:32:39 soda kernel:  [<c018edcd>] cached_lookup+0x1d/0x80
Jan 31 12:32:39 soda kernel:  [<c0190aaf>] __lookup_hash+0x5f/0xb0
Jan 31 12:32:39 soda kernel:  [<f93da495>] rpc_rmdir+0x75/0xb0 [sunrpc]
Jan 31 12:32:39 soda kernel:  [<f941040d>] gss_destroy+0x2d/0x70 
[auth_rpcgss]
Jan 31 12:32:39 soda kernel:  [<f93c44f4>] rpc_destroy_client+0x94/0xe0 
[sunrpc]
Jan 31 12:32:39 soda kernel:  [<c0185ed7>] kill_anon_super+0x87/0x180
Jan 31 12:32:39 soda kernel:  [<f93c44dc>] rpc_destroy_client+0x7c/0xe0 
[sunrpc]
Jan 31 12:32:39 soda kernel:  [<c019a139>] dput+0x109/0x680
Jan 31 12:32:39 soda kernel:  [<f95621d5>] nfs_kill_super+0x35/0x70 [nfs]
Jan 31 12:32:39 soda kernel:  [<c0183ed2>] deactivate_super+0xa2/0x120
Jan 31 12:32:39 soda kernel:  [<c0126393>] do_exit+0x623/0x670
Jan 31 12:32:39 soda kernel:  [<c0390396>] schedule_timeout+0xd6/0xe0
Jan 31 12:32:39 soda kernel:  [<c012645b>] do_group_exit+0x3b/0x1f0
Jan 31 12:32:39 soda kernel:  [<c0130123>] dequeue_signal+0x23/0xb0
Jan 31 12:32:39 soda kernel:  [<c01334ee>] get_signal_to_deliver+0x49e/0x7a0
Jan 31 12:32:39 soda kernel:  [<c025f827>] opost_block+0x97/0x140
Jan 31 12:32:39 soda kernel:  [<c01037df>] do_signal+0x8f/0x150
Jan 31 12:32:39 soda kernel:  [<c011d310>] default_wake_function+0x0/0x10
Jan 31 12:32:39 soda kernel:  [<c025aba5>] tty_write+0xb5/0x280
Jan 31 12:32:39 soda kernel:  [<c025aa6f>] tty_read+0xaf/0x130
Jan 31 12:32:39 soda kernel:  [<c017b9b5>] vfs_read+0xd5/0x170
Jan 31 12:32:39 soda kernel:  [<c0133b19>] sys_rt_sigprocmask+0x79/0x270
Jan 31 12:32:39 soda kernel:  [<c017bd01>] sys_read+0x41/0x70
Jan 31 12:32:39 soda kernel:  [<c01038d7>] do_notify_resume+0x37/0x3c
Jan 31 12:32:39 soda kernel:  [<c0103a1e>] work_notifysig+0x13/0x15
Jan 31 12:32:39 soda kernel: Code: 44 24 04 e8 d3 2a d1 c6 e9 57 fe ff 
ff 0f 0b e0 01 6c 47 41 f9 e9 82 fd ff ff 90 55 57 56 53 83 ec 1c 8b 80 
bc 01 00 00 8b 58 1c <81> 7b 5c 3c 4b 24 1d 74 25 c7 04 24 14 48 41 f9 
8d 43 5c be 04




-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
