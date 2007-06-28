From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: soft lockup
Date: Thu, 28 Jun 2007 16:52:49 -0700
Message-ID: <20070628235249.GM32531@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I43nD-00069j-QG
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 16:52:55 -0700
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I43nG-0005Ho-4F
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 16:52:59 -0700
Received: from alphard.ligo.caltech.edu (alphard [131.215.114.160])
	by acrux.ligo.caltech.edu (8.12.11/8.12.11) with ESMTP id
	l5SNqsmi013684
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Thu, 28 Jun 2007 16:52:54 -0700 (PDT)
Received: from alphard.ligo.caltech.edu (localhost.localdomain [127.0.0.1])
	by alphard.ligo.caltech.edu (8.13.7/8.13.4) with ESMTP id
	l5SNqnul031150
	for <nfs@lists.sourceforge.net>; Thu, 28 Jun 2007 16:52:49 -0700
Received: (from anderson@localhost)
	by alphard.ligo.caltech.edu (8.13.7/8.13.4/Submit) id l5SNqnVG031149
	for nfs@lists.sourceforge.net; Thu, 28 Jun 2007 16:52:49 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I am currently getting a soft lockup every few minutes on a Sun X4600M2
(8 x Opteron 8218) running 2.6.20.14 plus Tronds revalidate-the-fsid patch
and Jeff's O_EXCL-OPEN patch. The machine is still usable but a bit slow and
currently the rpciod/0 thread is being reported as using 100%CPU by top.

Any ideas?

Thanks.

kernel: BUG: soft lockup detected on CPU#0!
kernel: 
kernel: Call Trace:
kernel:  <IRQ>  [<ffffffff8025a17c>] softlockup_tick+0xfc/0x140
kernel:  [<ffffffff80237ed7>] update_process_times+0x57/0x90
kernel:  [<ffffffff802160e4>] smp_local_timer_interrupt+0x34/0x60
kernel:  [<ffffffff80216789>] smp_apic_timer_interrupt+0x59/0x80
kernel:  [<ffffffff8020a7b6>] apic_timer_interrupt+0x66/0x70
kernel:  <EOI>  [<ffffffff8817a310>] :nfs:nfs3_xdr_readres+0x0/0x170
kernel:  [<ffffffff803272e1>] _raw_spin_lock+0xb1/0x150
kernel:  [<ffffffff8817a310>] :nfs:nfs3_xdr_readres+0x0/0x170
kernel:  [<ffffffff8043d74d>] lock_kernel+0x1d/0x30
kernel:  [<ffffffff88123f3f>] :sunrpc:rpc_exit_task+0x1f/0x90
kernel:  [<ffffffff8812521e>] :sunrpc:__rpc_execute+0x8e/0x280
kernel:  [<ffffffff8023fd6e>] run_workqueue+0xae/0x160
kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
kernel:  [<ffffffff80243930>] keventd_create_kthread+0x0/0x90
kernel:  [<ffffffff80240031>] worker_thread+0x151/0x190
kernel:  [<ffffffff80229490>] default_wake_function+0x0/0x10
kernel:  [<ffffffff8023fee0>] worker_thread+0x0/0x190
kernel:  [<ffffffff80243b79>] kthread+0xd9/0x120
kernel:  [<ffffffff8020a998>] child_rip+0xa/0x12
kernel:  [<ffffffff80243930>] keventd_create_kthread+0x0/0x90
kernel:  [<ffffffff80243aa0>] kthread+0x0/0x120
kernel:  [<ffffffff8020a98e>] child_rip+0x0/0x12
kernel: 


-- 
Stuart Anderson  anderson@ligo.caltech.edu
http://www.ligo.caltech.edu/~anderson

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
