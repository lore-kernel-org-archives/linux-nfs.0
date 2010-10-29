Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay1.lrz-muenchen.de ([129.187.254.106]:50066 "EHLO
	mailrelay1.lrz-muenchen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755963Ab0J2I5P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Oct 2010 04:57:15 -0400
Received: from st-brauchle.localnet ([129.187.109.181] [129.187.109.181]) by mailout.lrz-muenchen.de with ESMTP for linux-nfs@vger.kernel.org; Fri, 29 Oct 2010 10:56:53 +0200
From: Joschi Brauchle <joschi.brauchle@tum.de>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: RPCIOD constantly taking 10-20% CPU, X hangs (in NFSv4 Environment)
Date: Fri, 29 Oct 2010 10:56:52 +0200
References: <201010191500.07799.joschi.brauchle@tum.de>
In-Reply-To: <201010191500.07799.joschi.brauchle@tum.de>
Content-Type: Text/Plain;
  charset="us-ascii"
Message-Id: <201010291056.53056.joschi.brauchle@tum.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tuesday 19 October 2010 15:00:07 Joschi Brauchle wrote:
> Hello everyone,
> 
> I have a problem with a OpenSuSE 11.3 box that I reported here:
> https://bugzilla.novell.com/show_bug.cgi?id=644880
> 
> I thought I'd post this to the NFS mailing list, as I did not get a
> response from Novell yet and the problem keeps us from upgrading about 100
> machines from OpenSuSE11.1 to 11.3.
> -----------------------
> 
> I have the following problem with Opensuse 11.3, x86_64 in an NFSv4
> environment:
> 
> Mostly in the morning when I return to the box (it's running idle all
> night), the X server hangs and 'top' shows 'rpciod/0' taking between
> 10-20% cpu constantly. A 'reboot' fails as stopping the 'automount'
> service fails due to my home (NFSv4 mount) being busy.
> 
> Sometimes the X server freezes with the same symptoms even randomly during
> work, but mostly it seems to happen when the session is idle at night.
> 
> I'm not very experienced in debugging a problem like this, so I definitely
> need instructions on how to get more information. Here is the information I
> have at hand:
> -----------------------
> 'uname -a' on the Opensuse 11.3 box:
> Linux <hostname> 2.6.34.7-0.3-desktop #1 SMP PREEMPT 2010-09-20 15:27:38
> +0200 x86_64 x86_64 x86_64 GNU/Linux
> -----------------------
> 'mount' returns the following line on my home:
> 192.168.109.3:/home/staff/<username> on /home/<username> type nfs4
> (rw,rsize=32768,wsize=32768,sec=krb5,sloppy,addr=192.168.109.3,clientaddr=1
> 92.168.109.72)
> 
> There are no other NFSv4 mounts.
> -----------------------
> I get a LOT of these messages in '/var/log/messages':
> Sep 28 18:30:58 <hostname> kernel: [117887.140931] NFS: v4 server returned
> a bad sequence-id error on an unconfirmed sequence ffff88007babd828!
> -----------------------
> 
> The NFS server is running SLES 10SP3 in a two-node Heartbeat cluster
> configuration with a shared IP (192.168.109.3), serving NFSv3 and NFSv4
> (with Kerberos/GSS Security).
> /etc/exports on the server contains:
> -----------------------
> # NFSv4 entries (with Kerberos and GSS Security):
> /export          gss/krb5(rw,fsid=0,no_all_squash,async,no_subtree_check)
> 
> We have about 40 OpenSuse 11.1 clients getting their homes from this
> server, they are all running fine without problems for several months. It
> seems to be a problem in the kernel of 11.3.
> 
> I also tried the latest kernel 2.6.36.rc7 available from the OpenSuse
> Buildservice. The problem persists, but the process that is hanging here is
> called "kworker".
> 
> By now I switched to the debug kernel 2.6.34.7. As I said, just let me know
> what more debug info is needed and how to obtain it. Also I have not found
> a way to reproduce or trigger the problem manually. I will try to create
> more NFSv4 traffic to see if I can reproduce the problem.
> 
> Thanks!


Today I finally experienced this bug again:

Once 'rpciod/1'was running at a constant 20% CPU, I increased the NFS and RPC debug levels by:
- echo 32767 > /proc/sys/sunrpc/rpc_debug
- echo 32767 > /proc/sys/sunrpc/nfs_debug
The complete logfile can be found here:
https://bugzilla.novell.com/attachment.cgi?id=397550
 
I also added the output of 'echo t > /proc/sysrq-trigger' here: 
https://bugzilla.novell.com/attachment.cgi?id=397551


-------------------------
- The /var/log/messages says:
-------------------------
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389091] INFO: task flush-0:24:2907 blocked for more than 120 seconds.
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389095] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389098] flush-0:24    D 0000000000000000     0  2907      2 0x00000000
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389104]  ffff88007e215ca0 0000000000000046 ffff88006e0c0af8 ffff88007e215fd8
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389110]  0000000000013fc0 ffff88007e215fd8 ffff88007dcb0400 0000000000013fc0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389115]  0000000000013fc0 0000000000013fc0 0000000000013fc0 0000000000013fc0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389120] Call Trace:
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389134]  [<ffffffff8114f8d9>] inode_wait+0x9/0x10
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389142]  [<ffffffff81468eaf>] __wait_on_bit+0x4f/0x80
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389149]  [<ffffffff8115adbb>] inode_wait_for_writeback+0x8b/0xb0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389156]  [<ffffffff8115bce4>] wb_writeback+0x174/0x1e0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389161]  [<ffffffff8115c34a>] wb_do_writeback+0x14a/0x160
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389168]  [<ffffffff8115c3a3>] bdi_writeback_task+0x43/0xe0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389174]  [<ffffffff8110055e>] bdi_start_fn+0x7e/0xf0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389180]  [<ffffffff81073dee>] kthread+0x8e/0xa0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389187]  [<ffffffff81003df4>] kernel_thread_helper+0x4/0x10
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389444] INFO: task kio_pop3:8833 blocked for more than 120 seconds.
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389446] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389449] kio_pop3      D 0000000000000000     0  8833   2903 0x00000004
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389453]  ffff88004b38da68 0000000000000046 01000038000002fc ffff88004b38dfd8
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389458]  0000000000013fc0 ffff88004b38dfd8 ffff880047580780 0000000000013fc0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389463]  0000000000013fc0 0000000000013fc0 0000000000013fc0 0000000000013fc0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389468] Call Trace:
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389474]  [<ffffffff8146878e>] io_schedule+0x6e/0xb0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389479]  [<ffffffff810e64b0>] sync_page+0x40/0x60
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389484]  [<ffffffff81468eaf>] __wait_on_bit+0x4f/0x80
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389489]  [<ffffffff810e665b>] wait_on_page_bit+0x6b/0x80
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389494]  [<ffffffff810e6a8c>] filemap_fdatawait_range+0xec/0x190
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389500]  [<ffffffff8115b010>] writeback_single_inode+0x230/0x340
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389506]  [<ffffffff8115b14b>] sync_inode+0x2b/0x50
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389520]  [<ffffffffa05f140b>] nfs_wb_all+0x3b/0x40 [nfs]
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389553]  [<ffffffffa05dfb91>] nfs_do_fsync+0x21/0x50 [nfs]
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389564]  [<ffffffff811370d8>] filp_close+0x38/0x80
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389571]  [<ffffffff81058646>] put_files_struct+0x76/0x100
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389576]  [<ffffffff81058bf8>] do_exit+0x138/0x390
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389582]  [<ffffffff81058fe9>] do_group_exit+0x49/0xb0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389587]  [<ffffffff81069ed7>] get_signal_to_deliver+0x297/0x430
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389594]  [<ffffffff81002891>] do_signal+0x71/0x1b0
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389600]  [<ffffffff81002b85>] do_notify_resume+0x65/0x90
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389607]  [<ffffffff81003296>] int_signal+0x12/0x17
Oct 28 10:48:35 st-brauchle kernel: [ 1440.389615]  [<00007fa0d2962df3>] 0x7fa0d2962df3
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389033] INFO: task flush-0:24:2907 blocked for more than 120 seconds.
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389037] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389040] flush-0:24    D 0000000000000000     0  2907      2 0x00000000
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389046]  ffff88007e215ca0 0000000000000046 ffff88006e0c0af8 ffff88007e215fd8
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389052]  0000000000013fc0 ffff88007e215fd8 ffff88007dcb0400 0000000000013fc0
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389057]  0000000000013fc0 0000000000013fc0 0000000000013fc0 0000000000013fc0
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389063] Call Trace:
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389077]  [<ffffffff8114f8d9>] inode_wait+0x9/0x10
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389085]  [<ffffffff81468eaf>] __wait_on_bit+0x4f/0x80
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389092]  [<ffffffff8115adbb>] inode_wait_for_writeback+0x8b/0xb0
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389098]  [<ffffffff8115bce4>] wb_writeback+0x174/0x1e0
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389103]  [<ffffffff8115c34a>] wb_do_writeback+0x14a/0x160
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389110]  [<ffffffff8115c3a3>] bdi_writeback_task+0x43/0xe0
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389116]  [<ffffffff8110055e>] bdi_start_fn+0x7e/0xf0
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389123]  [<ffffffff81073dee>] kthread+0x8e/0xa0
Oct 28 10:50:35 st-brauchle kernel: [ 1560.389129]  [<ffffffff81003df4>] kernel_thread_helper+0x4/0x10


It shows that the process is stuck in some kind of loop:
-------------------------
- The NFS debug log shows:
-------------------------
Oct 28 11:05:59 st-brauchle kernel: [ 2485.031996] --> nfs_put_client({2})
Oct 28 11:05:59 st-brauchle kernel: [ 2485.034878] NFS: 21736 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.034946] NFS: 48904 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.034957] NFS: 33450 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.034962] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.034968] NFS: 21737 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035203] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035231] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035298] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035320] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035342] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035364] --> nfs_put_client({2})
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035747] NFS: 21736 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035875] NFS: 48904 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035887] NFS: 33450 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035889] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.035900] NFS: 21737 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036140] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036168] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036236] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036257] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036302] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036344] --> nfs_put_client({2})
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036686] NFS: 21736 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036801] NFS: 48904 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036813] NFS: 33450 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036823] NFS: 21737 nfs_writeback_done (status -10023)
Oct 28 11:05:59 st-brauchle kernel: [ 2485.036850] encode_compound: tag=
Oct 28 11:05:59 st-brauchle kernel: [ 2485.037018] --> nfs_put_client({2})
...

-------------------------
The RPC+NFS debug log shows:
-------------------------
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611075] RPC:       xs_tcp_data_ready...
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611077] RPC:       xs_tcp_data_recv started
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611079] RPC:       reading TCP record fragment of length 92
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611080] RPC:       reading XID (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611082] RPC:       reading reply for XID 09576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611084] RPC:       reading CALL/REPLY flag (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611085] RPC:       read reply XID 09576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611087] RPC:       XID 09576cce read 84 bytes
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611089] RPC:       xprt = ffff88007cd0b6f8, tcp_copied = 92, tcp_offset = 92, tcp_reclen = 92
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611092] RPC: 21736 xid 09576cce complete (92 bytes received)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611093] RPC: 21736 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611095] RPC: 21736 disabling timer
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611097] RPC: 21736 removed from queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611100] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611101] RPC:       xs_tcp_data_recv done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611107] RPC:       xs_tcp_data_ready...
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611108] RPC:       xs_tcp_data_recv started
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611110] RPC:       reading TCP record fragment of length 92
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611111] RPC:       reading XID (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611113] RPC:       reading reply for XID 0a576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611114] RPC:       reading CALL/REPLY flag (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611116] RPC:       read reply XID 0a576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611118] RPC:       XID 0a576cce read 84 bytes
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611120] RPC:       xprt = ffff88007cd0b6f8, tcp_copied = 92, tcp_offset = 92, tcp_reclen = 92
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611122] RPC: 48904 xid 0a576cce complete (92 bytes received)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611124] RPC: 48904 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611125] RPC: 48904 disabling timer
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611127] RPC: 48904 removed from queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611128] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611130] RPC:       xs_tcp_data_recv done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611139] RPC:       xs_tcp_data_ready...
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611140] RPC:       xs_tcp_data_recv started
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611142] RPC:       reading TCP record fragment of length 92
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611143] RPC:       reading XID (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611145] RPC:       reading reply for XID 0b576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611146] RPC:       reading CALL/REPLY flag (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611148] RPC:       read reply XID 0b576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611149] RPC:       XID 0b576cce read 84 bytes
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611151] RPC:       xprt = ffff88007cd0b6f8, tcp_copied = 92, tcp_offset = 92, tcp_reclen = 92
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611153] RPC: 33450 xid 0b576cce complete (92 bytes received)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611155] RPC: 33450 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611157] RPC: 33450 disabling timer
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611158] RPC: 33450 removed from queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611160] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611161] RPC:       xs_tcp_data_recv done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611178] RPC: 21736 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611180] RPC: 21736 call_status (status 92)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611182] RPC: 21736 call_decode (status 92)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611184] RPC: 21736 validating RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611186] RPC: 21736 gss_validate
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611187] RPC:       krb5_read_token
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611198] RPC:       xs_tcp_data_ready...
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611200] RPC:       xs_tcp_data_recv started
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611201] RPC:       reading TCP record fragment of length 92
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611202] RPC:       reading XID (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611204] RPC:       reading reply for XID 0c576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611206] RPC:       reading CALL/REPLY flag (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611207] RPC:       read reply XID 0c576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611209] RPC:       XID 0c576cce read 84 bytes
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611211] RPC:       xprt = ffff88007cd0b6f8, tcp_copied = 92, tcp_offset = 92, tcp_reclen = 92
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611213] RPC: 21737 xid 0c576cce complete (92 bytes received)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611215] RPC: 21737 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611216] RPC: 21737 disabling timer
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611218] RPC: 21737 removed from queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611220] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611221] RPC:       xs_tcp_data_recv done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611227] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611228] RPC:       krb5_get_seq_num:
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611230] RPC:       gss_k5decrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611232] RPC: 21736 gss_validate: gss_verify_mic succeeded.
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611234] RPC: 21736 using AUTH_GSS cred ffff88007e05dee0 to unwrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611236] RPC: 21736 gss_unwrap_resp returning -10023
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611238] RPC: 21736 call_decode result -10023
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611239] NFS: 21736 nfs_writeback_done (status -10023)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611241] RPC: 21736 sleep_on(queue "NFS client" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611243] RPC: 21736 added to queue ffff88007cf76868 "NFS client"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611277] RPC:       freeing buffer of size 3756 at ffff88005ac01000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611280] RPC:       new task initialized, procpid 5232
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611281] RPC: 21736 release request ffff88007e02c150
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611283] RPC:       wake_up_next(ffff88007cd0bb20 "xprt_backlog")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611285] RPC:       allocated task ffff88004b367d10
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611287] RPC: 48904 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611289] RPC: 18624 __rpc_execute flags=0x280
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611291] RPC: 48904 call_status (status 92)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611293] RPC: 18624 call_start nfs4 proc RENEW (sync)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611294] RPC: 48904 call_decode (status 92)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611296] RPC: 48904 validating RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611299] RPC: 18624 call_reserve (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611301] RPC: 18624 reserved req ffff88007e02c150 xid 0d576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611302] RPC: 48904 gss_validate
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611303] RPC:       krb5_read_token
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611306] RPC: 18624 call_reserveresult (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611307] RPC: 18624 call_allocate (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611310] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611312] RPC:       krb5_get_seq_num:
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611313] RPC:       gss_k5decrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611315] RPC: 18624 allocated buffer of size 3168 at ffff88005a1a1000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611317] RPC: 18624 call_bind (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611319] RPC: 18624 call_connect xprt ffff88007cd0b6f8 is connected
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611320] RPC: 18624 call_transmit (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611322] RPC: 18624 xprt_prepare_transmit
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611323] RPC: 18624 rpc_xdr_encode (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611325] RPC: 18624 marshaling RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611326] RPC: 18624 gss_marshal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611327] RPC:       gss_krb5_seal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611328] RPC: 48904 gss_validate: gss_verify_mic succeeded.
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611331] RPC: 48904 using AUTH_GSS cred ffff88007e05dee0 to unwrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611333] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611334] RPC: 48904 gss_unwrap_resp returning -10023
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611336] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611337] RPC: 48904 call_decode result -10023
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611340] RPC: 18624 using AUTH_GSS cred ffff88007e05dee0 to wrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611342] RPC: 18624 gss_wrap_req
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611343] NFS: 48904 nfs_writeback_done (status -10023)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611345] encode_compound: tag=
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611346] RPC: 18624 gss_wrap_req returning 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611348] RPC: 18624 xprt_transmit(132)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611349] RPC: 48904 sleep_on(queue "NFS client" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611351] RPC: 48904 added to queue ffff88007cf76868 "NFS client"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611353] RPC:       freeing buffer of size 3756 at ffff88005e3ed000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611356] RPC:       xs_tcp_send_request(132) = 132
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611357] RPC: 48904 release request ffff88007e02d110
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611359] RPC: 18624 xmit complete
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611361] RPC: 18624 sleep_on(queue "xprt_pending" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611363] RPC: 18624 added to queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611365] RPC: 18624 setting alarm for 60000 ms
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611366] RPC:       wake_up_next(ffff88007cd0bb20 "xprt_backlog")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611369] RPC:       wake_up_next(ffff88007cd0b970 "xprt_resend")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611370] RPC: 33450 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611371] RPC: 33450 call_status (status 92)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611373] RPC: 33450 call_decode (status 92)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611374] RPC: 33450 validating RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611376] RPC: 33450 gss_validate
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611377] RPC:       krb5_read_token
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611379] RPC:       wake_up_next(ffff88007cd0b898 "xprt_sending")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611381] RPC: 18624 sync task going to sleep
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611382] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611384] RPC:       krb5_get_seq_num:
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611385] RPC:       gss_k5decrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611386] RPC: 33450 gss_validate: gss_verify_mic succeeded.
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611389] RPC: 33450 using AUTH_GSS cred ffff88007e05dee0 to unwrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611390] RPC: 33450 gss_unwrap_resp returning -10023
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611392] RPC: 33450 call_decode result -10023
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611394] NFS: 33450 nfs_writeback_done (status -10023)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611395] RPC: 33450 sleep_on(queue "NFS client" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611397] RPC: 33450 added to queue ffff88007cf76868 "NFS client"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611399] RPC:       freeing buffer of size 3756 at ffff880066a4b000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611401] RPC: 33450 release request ffff88007e02c000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611403] RPC:       wake_up_next(ffff88007cd0bb20 "xprt_backlog")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611405] RPC: 21737 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611407] RPC: 21737 call_status (status 92)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611408] RPC: 21737 call_decode (status 92)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611410] RPC: 21737 validating RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611411] RPC: 21737 gss_validate
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611413] RPC:       krb5_read_token
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611417] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611418] RPC:       krb5_get_seq_num:
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611420] RPC:       gss_k5decrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611421] RPC: 21737 gss_validate: gss_verify_mic succeeded.
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611423] RPC: 21737 using AUTH_GSS cred ffff88007e05dee0 to unwrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611425] RPC: 21737 gss_unwrap_resp returning -10023
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611427] RPC: 21737 call_decode result -10023
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611428] NFS: 21737 nfs_writeback_done (status -10023)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611430] RPC: 21737 sleep_on(queue "NFS client" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611432] RPC: 21737 added to queue ffff88007cf76868 "NFS client"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611434] RPC:       freeing buffer of size 3756 at ffff880047431000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611436] RPC: 21737 release request ffff88007e02d3b0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611437] RPC:       wake_up_next(ffff88007cd0bb20 "xprt_backlog")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611475] RPC:       xs_tcp_data_ready...
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611477] RPC:       xs_tcp_data_recv started
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611478] RPC:       reading TCP record fragment of length 84
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611480] RPC:       reading XID (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611481] RPC:       reading reply for XID 0d576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611483] RPC:       reading CALL/REPLY flag (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611485] RPC:       read reply XID 0d576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611487] RPC:       XID 0d576cce read 76 bytes
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611489] RPC:       xprt = ffff88007cd0b6f8, tcp_copied = 84, tcp_offset = 84, tcp_reclen = 84
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611491] RPC: 18624 xid 0d576cce complete (84 bytes received)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611493] RPC: 18624 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611494] RPC: 18624 disabling timer
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611496] RPC: 18624 removed from queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611500] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611502] RPC: 18624 sync task resuming
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611503] RPC:       xs_tcp_data_recv done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611505] RPC: 18624 call_status (status 84)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611507] RPC: 18624 call_decode (status 84)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611509] RPC: 18624 validating RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611511] RPC: 18624 gss_validate
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611512] RPC:       krb5_read_token
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611517] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611518] RPC:       krb5_get_seq_num:
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611520] RPC:       gss_k5decrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611521] RPC: 18624 gss_validate: gss_verify_mic succeeded.
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611523] RPC: 18624 using AUTH_GSS cred ffff88007e05dee0 to unwrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611524] RPC: 18624 gss_unwrap_resp returning 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611526] RPC: 18624 call_decode result 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611527] RPC: 18624 return 0, status 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611528] RPC: 18624 release task
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611530] RPC:       freeing buffer of size 3168 at ffff88005a1a1000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611532] RPC: 18624 release request ffff88007e02c150
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611534] RPC:       wake_up_next(ffff88007cd0bb20 "xprt_backlog")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611536] RPC: 18624 releasing RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611537] RPC:       rpc_release_client(ffff88007e53f720)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611539] RPC: 18624 freeing task
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611545] RPC:       new task initialized, procpid 5232
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611546] RPC:       allocated task ffff88004b367d10
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611548] RPC: 18625 __rpc_execute flags=0x81
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611550] RPC: 18625 return 0, status 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611551] RPC: 18625 release task
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611553] RPC: 18625 releasing RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611554] RPC:       rpc_release_client(ffff88007e53fd68)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611560] RPC: 21736 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611562] RPC: 21736 removed from queue ffff88007cf76868 "NFS client"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611564] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611566] RPC: 48904 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611568] RPC: 48904 removed from queue ffff88007cf76868 "NFS client"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611569] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611571] RPC: 33450 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611573] RPC: 33450 removed from queue ffff88007cf76868 "NFS client"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611574] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611576] RPC: 21737 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611577] RPC: 21737 removed from queue ffff88007cf76868 "NFS client"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611579] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611582] RPC:       new task initialized, procpid 5232
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611583] RPC:       allocated task ffff88004b367650
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611585] RPC: 18626 __rpc_execute flags=0x280
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611586] RPC: 18626 call_start nfs4 proc RENEW (sync)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611588] RPC: 18626 call_reserve (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611590] RPC: 18626 reserved req ffff88007e02c150 xid 0e576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611591] RPC: 18626 call_reserveresult (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611593] RPC: 18626 call_allocate (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611601] RPC: 18626 allocated buffer of size 3168 at ffff88005a1a1000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611603] RPC: 18626 call_bind (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611604] RPC: 18626 call_connect xprt ffff88007cd0b6f8 is connected
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611606] RPC: 18626 call_transmit (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611607] RPC: 18626 xprt_prepare_transmit
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611609] RPC: 18626 rpc_xdr_encode (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611611] RPC: 18626 marshaling RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611612] RPC: 18626 gss_marshal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611614] RPC:       gss_krb5_seal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611618] RPC: 18625 freeing task
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611621] RPC: 21736 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611623] RPC: 21736 call_start nfs4 proc WRITE (async)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611625] RPC: 21736 call_reserve (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611627] RPC: 21736 reserved req ffff88007e02d3b0 xid 0f576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611628] RPC: 21736 call_reserveresult (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611630] RPC: 21736 call_allocate (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611638] RPC: 21736 allocated buffer of size 3756 at ffff8800479ff000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611640] RPC: 21736 call_bind (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611641] RPC: 21736 call_connect xprt ffff88007cd0b6f8 is connected
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611643] RPC: 21736 call_transmit (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611644] RPC: 21736 xprt_prepare_transmit
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611645] RPC: 21736 failed to lock transport ffff88007cd0b6f8
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611647] RPC: 21736 sleep_on(queue "xprt_sending" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611649] RPC: 21736 added to queue ffff88007cd0b898 "xprt_sending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611651] RPC: 48904 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611652] RPC: 48904 call_start nfs4 proc WRITE (async)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611653] RPC: 48904 call_reserve (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611655] RPC: 48904 reserved req ffff88007e02c000 xid 10576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611657] RPC: 48904 call_reserveresult (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611658] RPC: 48904 call_allocate (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611666] RPC: 48904 allocated buffer of size 3756 at ffff880047575000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611668] RPC: 48904 call_bind (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611669] RPC: 48904 call_connect xprt ffff88007cd0b6f8 is connected
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611671] RPC: 48904 call_transmit (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611672] RPC: 48904 xprt_prepare_transmit
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611674] RPC: 48904 failed to lock transport ffff88007cd0b6f8
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611676] RPC: 48904 sleep_on(queue "xprt_sending" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611678] RPC: 48904 added to queue ffff88007cd0b898 "xprt_sending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611680] RPC: 33450 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611682] RPC: 33450 call_start nfs4 proc WRITE (async)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611683] RPC: 33450 call_reserve (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611685] RPC: 33450 reserved req ffff88007e02d110 xid 11576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611687] RPC: 33450 call_reserveresult (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611688] RPC: 33450 call_allocate (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611696] RPC: 33450 allocated buffer of size 3756 at ffff88005e3a0000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611698] RPC: 33450 call_bind (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611700] RPC: 33450 call_connect xprt ffff88007cd0b6f8 is connected
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611701] RPC: 33450 call_transmit (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611703] RPC: 33450 xprt_prepare_transmit
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611704] RPC: 33450 failed to lock transport ffff88007cd0b6f8
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611706] RPC: 33450 sleep_on(queue "xprt_sending" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611707] RPC: 33450 added to queue ffff88007cd0b898 "xprt_sending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611709] RPC: 21737 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611711] RPC: 21737 call_start nfs4 proc WRITE (async)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611712] RPC: 21737 call_reserve (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611714] RPC: 21737 reserved req ffff88007e02c7e0 xid 12576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611715] RPC: 21737 call_reserveresult (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611717] RPC: 21737 call_allocate (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611725] RPC: 21737 allocated buffer of size 3756 at ffff880047745000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611726] RPC: 21737 call_bind (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611728] RPC: 21737 call_connect xprt ffff88007cd0b6f8 is connected
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611730] RPC: 21737 call_transmit (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611731] RPC: 21737 xprt_prepare_transmit
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611733] RPC: 21737 failed to lock transport ffff88007cd0b6f8
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611735] RPC: 21737 sleep_on(queue "xprt_sending" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611737] RPC: 21737 added to queue ffff88007cd0b898 "xprt_sending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611741] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611744] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611746] RPC: 18626 using AUTH_GSS cred ffff88007e05dee0 to wrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611748] RPC: 18626 gss_wrap_req
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611749] encode_compound: tag=
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611750] RPC: 18626 gss_wrap_req returning 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611752] RPC: 18626 xprt_transmit(132)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611759] RPC:       xs_tcp_send_request(132) = 132
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611761] RPC: 18626 xmit complete
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611763] RPC: 18626 sleep_on(queue "xprt_pending" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611765] RPC: 18626 added to queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611766] RPC: 18626 setting alarm for 60000 ms
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611768] RPC:       wake_up_next(ffff88007cd0b970 "xprt_resend")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611769] RPC:       wake_up_next(ffff88007cd0b898 "xprt_sending")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611771] RPC: 21736 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611772] RPC: 21736 removed from queue ffff88007cd0b898 "xprt_sending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611775] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611776] RPC: 18626 sync task going to sleep
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611779] RPC: 21736 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611781] RPC: 21736 call_status (status -11)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611782] RPC: 21736 call_transmit (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611784] RPC: 21736 xprt_prepare_transmit
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611786] RPC: 21736 rpc_xdr_encode (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611787] RPC: 21736 marshaling RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611789] RPC: 21736 gss_marshal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611790] RPC:       gss_krb5_seal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611795] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611798] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611800] RPC: 21736 using AUTH_GSS cred ffff88007e05dee0 to wrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611801] RPC: 21736 gss_wrap_req
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611803] encode_compound: tag=
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611804] RPC: 21736 gss_wrap_req returning 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611806] RPC: 21736 xprt_transmit(32964)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611844] RPC:       xs_tcp_send_request(32964) = 32964
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611845] RPC: 21736 xmit complete
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611847] RPC: 21736 sleep_on(queue "xprt_pending" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611849] RPC: 21736 added to queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611851] RPC: 21736 setting alarm for 60000 ms
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611853] RPC:       wake_up_next(ffff88007cd0b970 "xprt_resend")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611854] RPC:       wake_up_next(ffff88007cd0b898 "xprt_sending")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611856] RPC: 48904 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611858] RPC: 48904 removed from queue ffff88007cd0b898 "xprt_sending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611860] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611861] RPC: 48904 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611863] RPC: 48904 call_status (status -11)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611865] RPC: 48904 call_transmit (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611866] RPC: 48904 xprt_prepare_transmit
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611868] RPC: 48904 rpc_xdr_encode (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611870] RPC: 48904 marshaling RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611871] RPC: 48904 gss_marshal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611872] RPC:       gss_krb5_seal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611878] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611880] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611880] RPC:       xs_tcp_data_ready...
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611882] RPC:       xs_tcp_data_recv started
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611883] RPC:       reading TCP record fragment of length 84
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611885] RPC:       reading XID (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611886] RPC:       reading reply for XID 0e576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611888] RPC:       reading CALL/REPLY flag (4 bytes)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611889] RPC:       read reply XID 0e576cce
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611891] RPC:       XID 0e576cce read 76 bytes
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611894] RPC: 48904 using AUTH_GSS cred ffff88007e05dee0 to wrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611896] RPC:       xprt = ffff88007cd0b6f8, tcp_copied = 84, tcp_offset = 84, tcp_reclen = 84
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611898] RPC: 18626 xid 0e576cce complete (84 bytes received)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611900] RPC: 18626 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611901] RPC: 18626 disabling timer
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611903] RPC: 18626 removed from queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611906] RPC: 48904 gss_wrap_req
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611906] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611908] encode_compound: tag=
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611909] RPC:       xs_tcp_data_recv done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611911] RPC: 48904 gss_wrap_req returning 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611913] RPC: 48904 xprt_transmit(764)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611922] RPC:       xs_tcp_send_request(764) = 764
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611923] RPC: 48904 xmit complete
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611925] RPC: 48904 sleep_on(queue "xprt_pending" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611927] RPC: 48904 added to queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611928] RPC: 48904 setting alarm for 60000 ms
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611930] RPC:       wake_up_next(ffff88007cd0b970 "xprt_resend")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611931] RPC:       wake_up_next(ffff88007cd0b898 "xprt_sending")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611933] RPC: 33450 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611935] RPC: 33450 removed from queue ffff88007cd0b898 "xprt_sending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611936] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611938] RPC: 33450 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611939] RPC: 33450 call_status (status -11)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611941] RPC: 33450 call_transmit (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611942] RPC: 33450 xprt_prepare_transmit
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611944] RPC: 33450 rpc_xdr_encode (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611945] RPC: 33450 marshaling RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611947] RPC: 33450 gss_marshal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611948] RPC:       gss_krb5_seal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611953] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611955] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611957] RPC: 33450 using AUTH_GSS cred ffff88007e05dee0 to wrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611959] RPC: 33450 gss_wrap_req
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611960] encode_compound: tag=
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611962] RPC: 33450 gss_wrap_req returning 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611963] RPC: 33450 xprt_transmit(708)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611971] RPC:       xs_tcp_send_request(708) = 708
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611972] RPC: 33450 xmit complete
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611974] RPC: 33450 sleep_on(queue "xprt_pending" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611976] RPC: 33450 added to queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611978] RPC: 33450 setting alarm for 60000 ms
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611980] RPC:       wake_up_next(ffff88007cd0b970 "xprt_resend")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611981] RPC:       wake_up_next(ffff88007cd0b898 "xprt_sending")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611983] RPC: 21737 __rpc_wake_up_task (now 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611985] RPC: 21737 removed from queue ffff88007cd0b898 "xprt_sending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611987] RPC:       __rpc_wake_up_task done
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611988] RPC: 21737 __rpc_execute flags=0x1
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611990] RPC: 21737 call_status (status -11)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611992] RPC: 21737 call_transmit (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611993] RPC: 21737 xprt_prepare_transmit
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611995] RPC: 21737 rpc_xdr_encode (status 0)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611996] RPC: 21737 marshaling RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611998] RPC: 21737 gss_marshal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.611999] RPC:       gss_krb5_seal
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612004] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612006] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612008] RPC: 21737 using AUTH_GSS cred ffff88007e05dee0 to wrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612010] RPC: 21737 gss_wrap_req
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612011] encode_compound: tag=
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612013] RPC: 21737 gss_wrap_req returning 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612014] RPC: 21737 xprt_transmit(12484)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612032] RPC:       xs_tcp_send_request(12484) = 12484
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612034] RPC: 21737 xmit complete
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612036] RPC: 21737 sleep_on(queue "xprt_pending" time 4295534948)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612038] RPC: 21737 added to queue ffff88007cd0ba48 "xprt_pending"
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612039] RPC: 21737 setting alarm for 60000 ms
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612041] RPC:       wake_up_next(ffff88007cd0b970 "xprt_resend")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612043] RPC:       wake_up_next(ffff88007cd0b898 "xprt_sending")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612046] RPC: 18626 sync task resuming
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612048] RPC: 18626 call_status (status 84)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612049] RPC: 18626 call_decode (status 84)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612051] RPC: 18626 validating RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612053] RPC: 18626 gss_validate
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612054] RPC:       krb5_read_token
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612059] RPC:       krb5_encrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612060] RPC:       krb5_get_seq_num:
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612062] RPC:       gss_k5decrypt returns 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612063] RPC: 18626 gss_validate: gss_verify_mic succeeded.
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612065] RPC: 18626 using AUTH_GSS cred ffff88007e05dee0 to unwrap rpc data
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612067] RPC: 18626 gss_unwrap_resp returning 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612068] RPC: 18626 call_decode result 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612070] RPC: 18626 return 0, status 0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612071] RPC: 18626 release task
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612073] RPC:       freeing buffer of size 3168 at ffff88005a1a1000
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612075] RPC: 18626 release request ffff88007e02c150
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612076] RPC:       wake_up_next(ffff88007cd0bb20 "xprt_backlog")
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612078] RPC: 18626 releasing RPCSEC_GSS cred ffff88007e05dee0
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612079] RPC:       rpc_release_client(ffff88007e53f720)
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612080] RPC: 18626 freeing task
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612082] --> nfs_put_client({2})
Oct 28 11:07:25 st-brauchle kernel: [ 2570.612285] RPC:       xs_tcp_data_ready...
-------------------------

This BUG is a real show stopper for our institute. We planned to roll out OpenSuSE 11.3 (or greater) within the next month, but this prevents the test machine from running reliably within out NFSv4+Kerberos environment.

So any help/comments would be greatly appreciated!

Thanks and best regards,
Joschi Brauchle
