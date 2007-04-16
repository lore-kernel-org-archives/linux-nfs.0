From: Gabriel Barazer <gabriel@oxeva.fr>
Subject: Re: mountd randomly crash and panic the server
Date: Mon, 16 Apr 2007 11:26:08 +0200
Message-ID: <46234130.5020502@oxeva.fr>
References: <461CFABE.9050301@barazer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdNUA-0005vW-Ey
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 02:26:58 -0700
Received: from mail.reagi.com ([195.60.188.80])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdNUA-000313-Ge
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 02:27:01 -0700
In-Reply-To: <461CFABE.9050301@barazer.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello,

I once again got this crash this night. The call trace always end with 
the same function (cache_clean), which makes me think that there is 
maybe a race condition in it (happens randomly, particularly on quite 
heavy load).

Apr 16 00:29:45 filer1 kernel:  [<ffffffff8053ae60>]
cache_flush+0xd/0x23
Apr 16 00:29:45 filer1 kernel:  [<ffffffff805386e0>] 
ip_map_parse+0x17c/0x18e
Apr 16 00:29:45 filer1 kernel:  [<ffffffff8053b4d1>] cache_write+0x90/0xac
Apr 16 00:29:45 filer1 kernel:  [<ffffffff80213f77>] vfs_write+0xaf/0x151
Apr 16 00:29:45 filer1 kernel:  [<ffffffff80214907>] sys_write+0x45/0x6e
Apr 16 00:29:45 filer1 kernel:  [<ffffffff8025311e>] system_call+0x7e/0x83
Apr 16 00:29:45 filer1 kernel:
Apr 16 00:29:45 filer1 kernel:
Apr 16 00:29:45 filer1 kernel: Code: 48 8b 43 08 48 39 82 80 00 00 00 7e 
0a 48 ff c0 48 89 82 80
Apr 16 00:29:45 filer1 kernel: RIP  [<ffffffff8053ad42>] 
cache_clean+0x11e/0x22f

Is this related to the kernel cache_clean function in net/sunrpc/cache.c ?

Gabriel

On 04/11/2007 17:11:58 +0200, Gabriel Barazer <gabriel@barazer.net> wrote:

> Hello there,
> 
> I recently got a problem probably due to rpc.mountd (from nfs-utils 
> 1.0.7). I have a file server running linux 2.6.20.3 and it crashed 4 
> times since march, 1st under a quite heavy load with the following 
> kernel errors in the syslog (which I have read after the crash, because 
> kernel probably panic()ed ano network access was possible)
> 
> Mar 19 19:52:57 filer1 kernel: general protection fault: 0000 [1] SMP
> Mar 19 19:52:57 filer1 kernel: CPU 3
> Mar 19 19:52:57 filer1 kernel: Modules linked in:
> Mar 19 19:52:57 filer1 kernel: Pid: 2238, comm: rpc.mountd Not tainted 2.6.20.3 #1
> Mar 19 19:52:57 filer1 kernel: RIP: 0010:[<ffffffff8053606f>]  [<ffffffff8053606f>] cache_clean+0x11e/0x22f
> Mar 19 19:52:57 filer1 kernel: RSP: 0018:ffff810068da7b68  EFLAGS: 00010206
> Mar 19 19:52:57 filer1 kernel: RAX: ffffffff806a0e80 RBX: 0001e71926010009 RCX: ffffffff806a0e80
> Mar 19 19:52:57 filer1 kernel: RDX: ffffffff806a0e80 RSI: 0000000000000071 RDI: ffffffff806a0e98
> Mar 19 19:52:57 filer1 kernel: RBP: ffff8100090ad7c0 R08: 0000000000000000 R09: 000000000000006b
> Mar 19 19:52:57 filer1 kernel: R10: 0000000000000000 R11: 0000000000000005 R12: 0000000000000000
> Mar 19 19:52:57 filer1 kernel: R13: ffff810068da7e08 R14: 0000000000000006 R15: ffff81001669c000
> Mar 19 19:52:57 filer1 kernel: FS:  00002ab0119c36e0(0000) GS:ffff81007ff397c0(0000) knlGS:0000000000000000
> Mar 19 19:52:57 filer1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Mar 19 19:52:57 filer1 kernel: CR2: 00002ab011474000 CR3: 000000007e228000 CR4: 00000000000006e0
> Mar 19 19:52:57 filer1 kernel: Process rpc.mountd (pid: 2238, threadinfo ffff810068da6000, task ffff81006b5a6400)
> Mar 19 19:52:57 filer1 kernel: Stack:  ffff810050a9ae40 0000000000000000 ffff810068da7da8 ffffffff8053618d
> Mar 19 19:52:57 filer1 kernel:  ffff810050a9ae40 ffffffff803489f8 00000000fffffffa ffff810027312840
> Mar 19 19:52:57 filer1 kernel:  ffff810025bb2400 ffff810025bb2400 ffff810068da7c69 ffff810068da7caa
> Mar 19 19:52:57 filer1 kernel: Call Trace:
> Mar 19 19:52:57 filer1 kernel:  [<ffffffff8053618d>] cache_flush+0xd/0x23
> Mar 19 19:52:57 filer1 kernel:  [<ffffffff803489f8>] svc_export_parse+0x5c2/0x650
> Mar 19 19:52:57 filer1 kernel:  [<ffffffff8020d338>] current_fs_time+0x4d/0x52
> Mar 19 19:52:57 filer1 kernel:  [<ffffffff803dc1a5>] elv_next_request+0x40/0x14f
> Mar 19 19:52:57 filer1 kernel:  [<ffffffff80224ccd>] sync_page+0x0/0x41
> Mar 19 19:52:57 filer1 kernel:  [<ffffffff805367fe>] cache_write+0x90/0xac
> Mar 19 19:52:57 filer1 kernel:  [<ffffffff80213f40>] vfs_write+0xaf/0x151
> Mar 19 19:52:57 filer1 kernel:  [<ffffffff802148d0>] sys_write+0x45/0x6e
> Mar 19 19:52:57 filer1 kernel:  [<ffffffff8025411e>] system_call+0x7e/0x83
> Mar 19 19:52:57 filer1 kernel:
> Mar 19 19:52:57 filer1 kernel:
> Mar 19 19:52:57 filer1 kernel: Code: 48 8b 43 08 48 39 82 80 00 00 00 7e 0a 48 ff c0 48 89 82 80
> Mar 19 19:52:57 filer1 kernel: RIP  [<ffffffff8053606f>] cache_clean+0x11e/0x22f
> Mar 19 19:52:57 filer1 kernel:  RSP <ffff810068da7b68>
> 
> The three other times , there was this error :
> 
> Apr  2 18:30:00 filer1 kernel: general protection fault: 0000 [1] SMP
> Apr  2 18:30:00 filer1 kernel: CPU 2
> Apr  2 18:30:00 filer1 kernel: Modules linked in:
> Apr  2 18:30:00 filer1 kernel: Pid: 891, comm: rpc.mountd Not tainted 2.6.20.3 #1
> Apr  2 18:30:00 filer1 kernel: RIP: 0010:[<ffffffff8053606f>]  [<ffffffff8053606f>] cache_clean+0x11e/0x22f
> Apr  2 18:30:00 filer1 kernel: RSP: 0018:ffff8100778ffe18  EFLAGS: 00010202
> Apr  2 18:30:00 filer1 kernel: RAX: ffffffff806a0e80 RBX: 2d305f742d315f61 RCX: ffffffff806a0e80
> Apr  2 18:30:00 filer1 kernel: RDX: ffffffff806a0e80 RSI: 0000000000000070 RDI: ffffffff806a0e98
> Apr  2 18:30:00 filer1 kernel: RBP: ffff810008664c40 R08: ffffffff807783a0 R09: 00000000000000fc
> Apr  2 18:30:00 filer1 kernel: R10: 000000000000000b R11: 0000000000000027 R12: 0000000000000000
> Apr  2 18:30:00 filer1 kernel: R13: ffff8100778ffe78 R14: 0000000000000001 R15: 000000000040c62b
> Apr  2 18:30:00 filer1 kernel: FS:  00002abf4f2526e0(0000) GS:ffff81007ff39e40(0000) knlGS:0000000000000000
> Apr  2 18:30:00 filer1 kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> Apr  2 18:30:00 filer1 kernel: CR2: 00002b3251f83000 CR3: 000000003266e000 CR4: 00000000000006e0
> Apr  2 18:30:00 filer1 kernel: Process rpc.mountd (pid: 891, threadinfo ffff8100778fe000, task ffff810077fd03c0)
> Apr  2 18:30:00 filer1 kernel: Stack:  ffff810079cca840 0000000000000000 000000004611368f ffffffff8053618d
> Apr  2 18:30:00 filer1 kernel:  0000000000000000 ffffffff80533a01 ffff8100778ffe77 0000000002cd00e3
> Apr  2 18:30:00 filer1 kernel:  ffff8100778ffe92 0000000a000081a4 0000000000000000 000000000000002f
> Apr  2 18:30:00 filer1 kernel: Call Trace:
> Apr  2 18:30:00 filer1 kernel:  [<ffffffff8053618d>] cache_flush+0xd/0x23
> Apr  2 18:30:00 filer1 kernel:  [<ffffffff80533a01>] ip_map_parse+0x17c/0x18e
> Apr  2 18:30:00 filer1 kernel:  [<ffffffff805367fe>] cache_write+0x90/0xac
> Apr  2 18:30:00 filer1 kernel:  [<ffffffff80213f40>] vfs_write+0xaf/0x151
> Apr  2 18:30:00 filer1 kernel:  [<ffffffff802148d0>] sys_write+0x45/0x6e
> Apr  2 18:30:00 filer1 kernel:  [<ffffffff8025411e>] system_call+0x7e/0x83
> Apr  2 18:30:00 filer1 kernel:
> Apr  2 18:30:00 filer1 kernel:
> Apr  2 18:30:00 filer1 kernel: Code: 48 8b 43 08 48 39 82 80 00 00 00 7e 0a 48 ff c0 48 89 82 80
> Apr  2 18:30:00 filer1 kernel: RIP  [<ffffffff8053606f>] cache_clean+0x11e/0x22f
> Apr  2 18:30:00 filer1 kernel:  RSP <ffff8100778ffe18>
> 
> And this one (only call trace included):
> 
> Mar 17 17:08:34 filer1 kernel: general protection fault: 0000 [1] SMP
> Mar 17 17:08:34 filer1 kernel: CPU 3
> Mar 17 17:08:34 filer1 kernel: Pid: 13, comm: events/3 Not tainted 2.6.20 #5
> Mar 17 17:08:34 filer1 kernel: RIP: 0010:[<ffffffff8051f81b>]  [<ffffffff8051f81b>] cache_clean+0x11e/0x22f
> Mar 17 17:08:34 filer1 kernel: RSP: 0018:ffff81007fe11e40  EFLAGS: 00010202
> Mar 17 17:08:34 filer1 kernel: RAX: ffffffff80660080 RBX: 2d305f742d315f61 RCX: ffffffff80660080
> Mar 17 17:08:34 filer1 kernel: RDX: ffffffff80660080 RSI: 0000000000000077 RDI: ffffffff80660098
> Mar 17 17:08:34 filer1 kernel: RBP: ffff81001e9b5e40 R08: ffff81007fe10000 R09: 0000000000000286
> Mar 17 17:08:34 filer1 kernel: R10: 0000000000000286 R11: ffffffff80240992 R12: 0000000000000000
> Mar 17 17:08:34 filer1 kernel: R13: 0000000000000206 R14: ffffffff8051fab1 R15: 0000000000000000
> Mar 17 17:08:34 filer1 kernel: FS:  0000000000000000(0000) GS:ffff810002f817c0(0000) knlGS:0000000000000000
> Mar 17 17:08:34 filer1 kernel: CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
> Mar 17 17:08:34 filer1 kernel: CR2: 00002b6b14d8bbc0 CR3: 000000007b57c000 CR4: 00000000000006e0
> Mar 17 17:08:34 filer1 kernel: Process events/3 (pid: 13, threadinfo ffff81007fe10000, task ffff81007fe3ef00)
> Mar 17 17:08:34 filer1 kernel: Stack:  0000000000000005 ffff810002f815c0 ffffffff806602c0 ffffffff8051fabc
> Mar 17 17:08:34 filer1 kernel:  ffffffff806602c8 ffffffff80244799 ffff810002f815c0 ffffffff802415b3
> Mar 17 17:08:34 filer1 kernel:  ffff81007ff23d60 00000000fffffffc 0000000000000000 ffffffff802416d7
> Mar 17 17:08:34 filer1 kernel: Call Trace:
> Mar 17 17:08:34 filer1 kernel:  [<ffffffff8051fabc>] do_cache_clean+0xb/0x38
> Mar 17 17:08:34 filer1 kernel:  [<ffffffff80244799>] run_workqueue+0x9f/0x13b
> Mar 17 17:08:34 filer1 kernel:  [<ffffffff802415b3>] worker_thread+0x0/0x15a
> Mar 17 17:08:34 filer1 kernel:  [<ffffffff802416d7>] worker_thread+0x124/0x15a
> Mar 17 17:08:34 filer1 kernel:  [<ffffffff802731fd>] default_wake_function+0x0/0xe
> Mar 17 17:08:34 filer1 kernel:  [<ffffffff802731fd>] default_wake_function+0x0/0xe
> Mar 17 17:08:35 filer1 kernel:  [<ffffffff8022d1c6>] kthread+0xc8/0xf1
> Mar 17 17:08:35 filer1 kernel:  [<ffffffff80252ec8>] child_rip+0xa/0x12
> Mar 17 17:08:35 filer1 kernel:  [<ffffffff802838e8>] kthread_create+0x6a/0x147
> Mar 17 17:08:35 filer1 kernel:  [<ffffffff8022d0fe>] kthread+0x0/0xf1
> Mar 17 17:08:35 filer1 kernel:  [<ffffffff80252ebe>] child_rip+0x0/0x12
> Mar 17 17:08:35 filer1 kernel:
> Mar 17 17:08:35 filer1 kernel:
> Mar 17 17:08:35 filer1 kernel: Code: 48 8b 43 08 48 39 82 80 00 00 00 7e 0a 48 ff c0 48 89 82 80
> Mar 17 17:08:35 filer1 kernel: RIP  [<ffffffff8051f81b>] cache_clean+0x11e/0x22f
> Mar 17 17:08:35 filer1 kernel:  RSP <ffff81007fe11e40>
> 
> Notice the same end related to the "cache_clean" function, maybe this means something for anyone ?
> 
> Additionally, I noticed that today the rpc.mountd process (from nfs-utils 1.1.0-rc1) is 350M big as the "ps" command shows :
> root      2091  0.0 17.2 364164 354664 ?     Ss   Apr03   0:27 rpc.mountd --no-nfs-version 2
> 
> And it seems to very slowly grow up in memory. /proc/<pid of rpc.mountd>/smaps shows that 350M are taken by the "heap" :
> 00514000-15eea000 rw-p 00514000 00:00 0                                  [heap]
> Size:            354136 kB
> Rss:             353756 kB
> Shared_Clean:         0 kB
> Shared_Dirty:         0 kB
> Private_Clean:        0 kB
> Private_Dirty:   353756 kB
> 
> I don't know if these 2 cases are related, but as I got a crash with rpc.mountd (see crash from apr. 2nd), I include it too.
> 
> Any thoughts ?
> 
> Regards,
> 
> Gabriel
> 
> 
> -------------------------------------------------------------------------
> Take Surveys. Earn Cash. Influence the Future of IT
> Join SourceForge.net's Techsay panel and you'll get the chance to share your
> opinions on IT & business topics through brief surveys-and earn cash
> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
