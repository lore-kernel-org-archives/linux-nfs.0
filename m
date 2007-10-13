From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: Stale/incorrect cached information
Date: Sat, 13 Oct 2007 09:23:34 -0700
Message-ID: <20071013162334.GA6716@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Igjm5-0003lD-6s
	for nfs@lists.sourceforge.net; Sat, 13 Oct 2007 09:23:37 -0700
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Igjm9-0002oL-AS
	for nfs@lists.sourceforge.net; Sat, 13 Oct 2007 09:23:42 -0700
Received: from alphard.ligo.caltech.edu (alphard [131.215.114.160])
	by acrux.ligo.caltech.edu (8.12.11/8.12.11) with ESMTP id
	l9DGNeSv005967
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <nfs@lists.sourceforge.net>; Sat, 13 Oct 2007 09:23:40 -0700 (PDT)
Received: from alphard.ligo.caltech.edu (localhost.localdomain [127.0.0.1])
	by alphard.ligo.caltech.edu (8.13.7/8.13.4) with ESMTP id
	l9DGNZ1j006828
	for <nfs@lists.sourceforge.net>; Sat, 13 Oct 2007 09:23:35 -0700
Received: (from anderson@localhost)
	by alphard.ligo.caltech.edu (8.13.7/8.13.4/Submit) id l9DGNYds006827
	for nfs@lists.sourceforge.net; Sat, 13 Oct 2007 09:23:34 -0700
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

On an x86_64 SMP box running 2.6.20.20 we have gotten one NFS version 3 mounted
filesystem into the following state where it appears to have stale/incorrect
cached information:

 $ mkdir foo
 $ rmdir foo

So far so good.

 $ mkdir foo
 $ rm -rf foo
 rm: `foo' changed dev/ino: Is a directory

Strange.

 $ mv foo old.2
 mv: cannot remove directory `foo': Device or resource busy
 $ rmdir foo
 rmdir: `foo': Device or resource busy


This is only happening on one NFS client of one filesystem, i.e.,
on another NFS client machine this same filesystem works, and on
another NFS filesystem on the same machine it also works. There
is also no problem with the filesystem on the NFS server.

Possible related is a recent softlockup error:

kernel: BUG: soft lockup detected on CPU#0!
kernel: 
kernel: Call Trace:
kernel:  <IRQ>  [<ffffffff8025a3dc>] softlockup_tick+0xfc/0x140
kernel:  [<ffffffff80233ff3>] __do_softirq+0x63/0xd0
kernel:  [<ffffffff80237f27>] update_process_times+0x57/0x90
kernel:  [<ffffffff802160d4>] smp_local_timer_interrupt+0x34/0x60
kernel:  [<ffffffff80216779>] smp_apic_timer_interrupt+0x59/0x80
kernel:  [<ffffffff8020a7b6>] apic_timer_interrupt+0x66/0x70
kernel:  <EOI>  [<ffffffff88128700>] :sunrpc:unx_validate+0x0/0x70
kernel:  [<ffffffff803275d1>] _raw_spin_lock+0xb1/0x150
kernel:  [<ffffffff8817c330>] :nfs:nfs3_xdr_readres+0x0/0x170
kernel:  [<ffffffff8043db4d>] lock_kernel+0x1d/0x30
kernel:  [<ffffffff88120f7a>] :sunrpc:call_decode+0x5ba/0x660
kernel:  [<ffffffff881274a0>] :sunrpc:rpc_async_schedule+0x0/0x10
kernel:  [<ffffffff8812721e>] :sunrpc:__rpc_execute+0x8e/0x280
kernel:  [<ffffffff8023fdce>] run_workqueue+0xae/0x160
kernel:  [<ffffffff8023ff40>] worker_thread+0x0/0x190
kernel:  [<ffffffff80243990>] keventd_create_kthread+0x0/0x90
kernel:  [<ffffffff80240091>] worker_thread+0x151/0x190
kernel:  [<ffffffff802294d0>] default_wake_function+0x0/0x10
kernel:  [<ffffffff8023ff40>] worker_thread+0x0/0x190
kernel:  [<ffffffff80243bd9>] kthread+0xd9/0x120
kernel:  [<ffffffff8020a998>] child_rip+0xa/0x12
kernel:  [<ffffffff80243990>] keventd_create_kthread+0x0/0x90
kernel:  [<ffffffff80243b00>] kthread+0x0/0x120
kernel:  [<ffffffff8020a98e>] child_rip+0x0/0x12
kernel: 

Thanks.

-- 
Stuart Anderson  anderson@ligo.caltech.edu
http://www.ligo.caltech.edu/~anderson

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
