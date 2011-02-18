Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:49191 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751665Ab1BRRXD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Feb 2011 12:23:03 -0500
Message-ID: <4D5EAB02.6030600@suse.de>
Date: Fri, 18 Feb 2011 22:53:14 +0530
From: Suresh Jayaraman <sjayaraman@suse.de>
To: linux-nfs@vger.kernel.org
Cc: Di Pe <dipeit@gmail.com>
Subject: Re: Oops.... cannot mount secure nfs exports (kerberized nfs / rpc.gssd
 crashes)
References: <AANLkTimyXBKeFJ2_mmHvCsC9EBEO0mb_ontXKaOxwtav@mail.gmail.com>
In-Reply-To: <AANLkTimyXBKeFJ2_mmHvCsC9EBEO0mb_ontXKaOxwtav@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 02/15/2011 05:51 AM, Di Pe wrote:
> Could someone have a look at this
> 
> https://bugzilla.novell.com/show_bug.cgi?id=668880
> ox6:~ # rpm -q nfs-client
> nfs-client-1.2.3-7.1.x86_64
> ox6:~ # uname -a
> Linux ox6 2.6.37-20-desktop #1 SMP PREEMPT 2011-01-22 00:41:44 +0100
> x86_64 x86_64 x86_64 GNU/Linux
> 
> ox6:~ # mount -t nfs4 -o sec=krb5 home:/vol/home_ph1 /mnt/home/home_ph1

Adding relevant rpc debugging message and full oops message to aid further debugging:

Setup:
Linux kernel - 2.6.37
NFS Server: NetApp OnTap 7.3.1
KDC: Windows 2003 R2 
(Seem to have worked with 2.6.34.7 kernel)

It looked like a bug with the ArcFour with HMAC/md5 encryption type that
was added recently. But, the same problem was reproducible even after restricting
enctypes to dec-cbc-md5 and dec-cbs-crc in krb5.conf and recreating principals

       default_tkt_enctypes = des-cbc-md5; or des-cbc-crc
       default_tgs_enctypes = des-cbc-md5; or des-cbc-crc

---snip---
[198803.940947] RPC:     3 __rpc_execute flags=0x680
[198803.940949] RPC:     3 call_start rpcbind4 proc UNSET (sync)
[198803.940950] RPC:     3 call_reserve (status 0)
[198803.940952] RPC:     3 reserved req ffff880013b76000 xid 289176a5
[198803.940953] RPC:     3 call_reserveresult (status 0)
[198803.940955] RPC:     3 call_refresh (status 0)
[198803.940956] RPC:     3 looking up UNIX cred
[198803.940957] RPC:       looking up UNIX cred
[198803.940960] RPC:       allocating UNIX cred for uid 0 gid 0
[198803.940963] RPC:     3 refreshing UNIX cred ffff8800154295c0
[198803.940965] RPC:     3 call_refreshresult (status 0)
[198803.940966] RPC:     3 call_allocate (status 0)
[198803.940967] RPC:     3 allocated buffer of size 488 at ffff880014f6c800
[198803.940969] RPC:     3 call_bind (status 0)
[198803.940970] RPC:     3 call_connect xprt ffff880017ba2800 is connected
[198803.940971] RPC:     3 call_transmit (status 0)
[198803.940972] RPC:     3 xprt_prepare_transmit
[198803.940974] RPC:     3 rpc_xdr_encode (status 0)
[198803.940975] RPC:     3 marshaling UNIX cred ffff8800154295c0
[198803.940981] RPC:     3 using AUTH_UNIX cred ffff8800154295c0 to wrap rpc data
[198803.940984] RPC:     3 encoding RPCB_UNSET call (1073741824, 4, '', '')
[198803.940986] RPC:     3 xprt_transmit(96)
[198803.941153] RPC:       xs_tcp_data_ready...
[198803.941155] RPC:       xs_tcp_data_recv started
[198803.941156] RPC:       reading TCP record fragment of length 28
[198803.941157] RPC:       reading XID (4 bytes)
[198803.941159] RPC:       reading reply for XID 289176a5
[198803.941160] RPC:       reading CALL/REPLY flag (4 bytes)
[198803.941161] RPC:       read reply XID 289176a5
[198803.941163] RPC:       XID 289176a5 read 20 bytes
[198803.941164] RPC:       xprt = ffff880017ba2800, tcp_copied = 28, tcp_offset = 28, tcp_reclen = 28
[198803.941166] RPC:     3 xid 289176a5 complete (28 bytes received)
[198803.941168] RPC:       xs_tcp_data_recv done
[198803.941170] RPC:       xs_tcp_send_request(96) = 96
[198803.941171] RPC:     3 xmit complete
[198803.941172] RPC:       wake_up_next(ffff880017ba2a68 "xprt_resend")
[198803.941174] RPC:       wake_up_next(ffff880017ba2998 "xprt_sending")
[198803.941175] RPC:     3 call_status (status 28)
[198803.941176] RPC:     3 call_decode (status 28)
[198803.941178] RPC:     3 validating UNIX cred ffff8800154295c0
[198803.941180] RPC:     3 using AUTH_UNIX cred ffff8800154295c0 to unwrap rpc data
[198803.941182] RPC:     3 RPCB_UNSET call succeeded
[198803.941183] RPC:     3 call_decode result 0
[198803.941184] RPC:     3 return 0, status 0
[198803.941185] RPC:     3 release task
[198803.941187] RPC:       freeing buffer of size 488 at ffff880014f6c800
[198803.941189] RPC:     3 release request ffff880013b76000
[198803.941190] RPC:       wake_up_next(ffff880017ba2c08 "xprt_backlog")
[198803.941191] RPC:       rpc_release_client(ffff880013f19200)
[198803.941193] RPC:     3 freeing task
[198803.941194] svc: __svc_unregister(NFSv4 callbackv4), error 0
[198803.941202] svc: creating transport tcp[0]
[198803.941209] svc: svc_create_socket(NFSv4 callback, 6, 0.0.0.0, port=0)
[198803.941250] svc: svc_setup_socket ffff88000487cac0
[198803.941256] setting up TCP socket for listening
[198803.941257] svc: svc_setup_socket created ffff880013e89800 (inet ffff8800138f4400)
[198803.941259] svc: creating transport tcp[0]
[198803.941261] svc: svc_create_socket(NFSv4 callback, 6, 0000:0000:0000:0000:0000:0000:0000:0000, port=0)
[198803.941325] svc: svc_setup_socket ffff88000487c5c0
[198803.941327] setting up TCP socket for listening
[198803.941328] svc: svc_setup_socket created ffff880013916000 (inet ffff880014f807c0)
[198803.946045] svc: svc_destroy(NFSv4 callback, 2)
[198803.946469] RPC:       new task initialized, procpid 10970
[198803.946471] RPC:       allocated task ffff880013f00080
[198803.946473] RPC:     4 __rpc_execute flags=0x80
[198803.946479] RPC:     4 call_start nfs4 proc LOOKUP_ROOT (sync)
[198803.946480] RPC:     4 call_reserve (status 0)
[198803.946483] RPC:     4 reserved req ffff880014f42000 xid adf5f985
[198803.946484] RPC:     4 call_reserveresult (status 0)
[198803.946486] RPC:     4 call_refresh (status 0)
[198803.946488] RPC:     4 looking up RPCSEC_GSS cred
[198803.946489] RPC:       looking up RPCSEC_GSS cred
[198803.946492] RPC:       gss_create_cred for uid 0, flavor 390003
[198803.946495] RPC:       gss_upcall for uid 0
[198803.946499] RPC:       gss_find_upcall found nothing
[198803.949794] svc: server ffff880014f8c000 waiting for data (to = 9223372036854775807)
[198804.193954] RPC:       gss_find_upcall found msg ffff880013e47c00
[198804.193964] RPC:       context_derive_keys_rc4: entered
[198804.326023] BUG: unable to handle kernel paging request at ffff8800201e4f28
[198804.326023] IP: [<ffffffff8126b24b>] memcpy+0xb/0x120
[198804.326023] PGD 1a04063 PUD 1a08063 PMD 0 
[198804.326023] Oops: 0000 [#1] PREEMPT SMP 
[198804.326023] last sysfs file: /sys/module/auth_rpcgss/initstate
[198804.326023] CPU 0 
[198804.326023] Modules linked in: md5 rpcsec_gss_krb5 nfs lockd fscache nfs_acl auth_rpcgss sunrpc vmsync vmblock microcode edd mperf btrfs zlib_deflate dm_mod ppdev sr_mod cdrom parport_pc sg parport vmci e1000 shpchp floppy mptctl vmw_balloon pcspkr pci_hotplug i2c_piix4 button ac container ext4 jbd2 crc16 fan processor ata_generic thermal thermal_sys mptspi mptscsih mptbase scsi_transport_spi [last unloaded: preloadtrace]
[198804.326023] 
[198804.326023] Pid: 10963, comm: rpc.gssd Not tainted 2.6.37-20-desktop #1 440BX Desktop Reference Platform/VMware Virtual Platform
[198804.326023] RIP: 0010:[<ffffffff8126b24b>]  [<ffffffff8126b24b>] memcpy+0xb/0x120
[198804.326023] RSP: 0018:ffff880013cefcb0  EFLAGS: 00010206
[198804.326023] RAX: ffff880013dcdf70 RBX: ffff880013cefda8 RCX: 0000000000000001
[198804.326023] RDX: 0000000000000005 RSI: ffff8800201e4f28 RDI: ffff880013dcdf70
[198804.326023] RBP: ffff880013dcdf60 R08: 0000000000000000 R09: ffff880013e47a00
[198804.326023] R10: 000000000eacc729 R11: 000000005c5c5c5c R12: 0000000000000040
[198804.326023] R13: 000000000000000d R14: ffff8800201e4f28 R15: ffff8800141c7c60
[198804.326023] FS:  00007f2fac334720(0000) GS:ffff880017200000(0000) knlGS:0000000000000000
[198804.326023] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[198804.326023] CR2: ffff8800201e4f28 CR3: 00000000156ea000 CR4: 00000000000006f0
[198804.326023] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[198804.326023] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[198804.326023] Process rpc.gssd (pid: 10963, threadinfo ffff880013cee000, task ffff880013eaa440)
[198804.326023] Stack:
[198804.326023]  ffffffffa007999f ffff880013e47a08 ffff880013cefda8 ffff880013dcdf40
[198804.326023]  ffff880013cefd88 ffff880013e47868 0000000000000000 ffff8800141c7c60
[198804.326023]  ffffffff8123cfbe ffff8800201e4f28 0000000000000f28 ffffea00007069e0
[198804.326023] Call Trace:
[198804.326023]  [<ffffffffa007999f>] md5_update+0x12f/0x140 [md5]
[198804.326023]  [<ffffffff8123cfbe>] shash_compat_update+0x2e/0x50
[198804.326023]  [<ffffffff8123d1bb>] shash_compat_digest+0x9b/0x180
[198804.326023]  [<ffffffffa01e0270>] context_derive_keys_rc4+0x140/0x250 [rpcsec_gss_krb5]
[198804.326023]  [<ffffffffa01e1021>] gss_import_sec_context_kerberos+0x91/0x1b0 [rpcsec_gss_krb5]
[198804.326023]  [<ffffffffa03198d0>] gss_fill_context+0x1b0/0x200 [auth_rpcgss]
[198804.326023]  [<ffffffffa031b1a7>] gss_pipe_downcall+0x187/0x310 [auth_rpcgss]
[198804.326023]  [<ffffffffa0347b3b>] rpc_pipe_write+0x5b/0x90 [sunrpc]
[198804.326023]  [<ffffffff811521a6>] vfs_write+0xc6/0x180
[198804.326023]  [<ffffffff811524be>] sys_write+0x4e/0x90
[198804.326023]  [<ffffffff81002f8b>] system_call_fastpath+0x16/0x1b
[198804.326023]  [<00007f2faab2ce50>] 0x7f2faab2ce50
[198804.326023] Code: e8 2b fd ff ff 48 8b 43 58 2a 43 50 88 43 4e eb e9 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 48 89 f8 89 d1 c1 e9 03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 20 48 83 ea 20 4c 8b 06 4c 8b 4e 08 4c 
[198804.326023] RIP  [<ffffffff8126b24b>] memcpy+0xb/0x120
[198804.326023]  RSP <ffff880013cefcb0>
[198804.326023] CR2: ffff8800201e4f28
[198804.326023] ---[ end trace 0dfd870ce768a94c ]---

> Message from syslogd@ox6 at Feb 14 16:16:54 ...
>  kernel:[ 6376.964544] Oops: 0000 [#1] PREEMPT SMP
> 
> Message from syslogd@ox6 at Feb 14 16:16:54 ...
>  kernel:[ 6376.964547] last sysfs file: /sys/module/auth_rpcgss/initstate
> 
> Message from syslogd@ox6 at Feb 14 16:16:54 ...
>  kernel:[ 6376.964672] Stack:
> 
> Message from syslogd@ox6 at Feb 14 16:16:54 ...
>  kernel:[ 6376.964694] Call Trace:
> 
> Message from syslogd@ox6 at Feb 14 16:16:54 ...
>  kernel:[ 6376.965010] Code: e8 2b fd ff ff 48 8b 43 58 2a 43 50 88 43
> 4e eb e9 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 48 89 f8 89 d1
> c1 e9 03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 20 48 83 ea 20 4c 8b 06 4c
> 8b 4e 08 4c
> 
> Message from syslogd@ox6 at Feb 14 16:16:54 ...
>  kernel:[ 6376.965010] CR2: ffff88002022ff28

Thanks,

-- 
Suresh Jayaraman
