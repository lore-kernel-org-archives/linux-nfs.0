From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.23-rc1-mm2
Date: Fri, 03 Aug 2007 13:03:28 -0400
Message-ID: <1186160608.7255.10.camel@localhost>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<200708031301.01569.marc.dietrich@ap.physik.uni-giessen.de>
	<20070803093830.39852a01.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, Johannes Berg <johannes@sipsolutions.net>,
	Oleg Nesterov <oleg@tv-sign.ru>,
	Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0ZI-0008G6-UF
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:04:05 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19GwxVl5Ms6uXwUPLTKxgobgt6T2JlZ39Q=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IH0ZL-0006ZA-6P
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:04:09 -0700
In-Reply-To: <20070803093830.39852a01.akpm@linux-foundation.org>
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

On Fri, 2007-08-03 at 09:38 -0700, Andrew Morton wrote:
> On Fri, 3 Aug 2007 13:00:46 +0200 Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de> wrote:
> 
> > 
> > Hi,
> > 
> > Am Wednesday 01 August 2007 08:09 schrieb Andrew Morton:
> > > ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc1/2.
> > >6.23-rc1-mm2/
> > >
> > >
> > > - the git-block tree remains dropped due to disageement with the Vaio
> > >
> > > - git-e1000new was withdrawn by the authors
> > >
> > > - git-wireless is back.  It is still a >3MB diff, and appears to compile.
> > >
> > > - Is anyone testing the kgdb code in here?
> > 
> > I still get some nfs related locking bug.
> > 
> > I applied 
> > 
> > linux-2.6.23-001-fix_rpciod_down_race.dif
> > linux-2.6.23-003-fix_locking_regression.dif
> > linux-2.6.23-004-fix_stateid_regression.dif
> > 
> > =============================================
> > [ INFO: possible recursive locking detected ]
> > 2.6.23-rc1-mm2 #3
> > ---------------------------------------------
> > events/0/5 is trying to acquire lock:
> >  (events){--..}, at: [<c012ed90>] flush_workqueue+0x0/0x70
> > 
> > but task is already holding lock:
> >  (events){--..}, at: [<c012e5c4>] run_workqueue+0xd4/0x1e0
> > 
> > other info that might help us debug this:
> > 2 locks held by events/0/5:
> >  #0:  (events){--..}, at: [<c012e5c4>] run_workqueue+0xd4/0x1e0
> >  #1:  ((nfs_automount_task).work){--..}, at: [<c012e5c4>] 
> > run_workqueue+0xd4/0x1e0
> > 
> > stack backtrace:
> >  [<c0104fda>] show_trace_log_lvl+0x1a/0x30
> >  [<c0105c02>] show_trace+0x12/0x20
> >  [<c0105d15>] dump_stack+0x15/0x20
> >  [<c013ee42>] __lock_acquire+0xc22/0x1030
> >  [<c013f2b1>] lock_acquire+0x61/0x80
> >  [<c012edd9>] flush_workqueue+0x49/0x70
> >  [<c012ee0d>] flush_scheduled_work+0xd/0x10
> >  [<dcf55c0c>] nfs_release_automount_timer+0x2c/0x30 [nfs]
> >  [<dcf45d8e>] nfs_free_server+0x9e/0xd0 [nfs]
> >  [<dcf4e626>] nfs_kill_super+0x16/0x20 [nfs]
> >  [<c017b38d>] deactivate_super+0x7d/0xa0
> >  [<c018f94b>] mntput_no_expire+0x4b/0x80
> >  [<c018fd94>] expire_mount_list+0xe4/0x140
> >  [<c0191219>] mark_mounts_for_expiry+0x99/0xb0
> >  [<dcf55d1d>] nfs_expire_automounts+0xd/0x40 [nfs]
> >  [<c012e61b>] run_workqueue+0x12b/0x1e0
> >  [<c012f05b>] worker_thread+0x9b/0x100
> >  [<c0131c72>] kthread+0x42/0x70
> >  [<c0104c0f>] kernel_thread_helper+0x7/0x18
> >  =======================
> > 
> 
> There is new debugging stuff in -mm: deadlockable usage of workqueue
> primitives will now trigger lockdep warnings.  See
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc1/2.6.23-rc1-mm2/broken-out/workqueue-debug-flushing-deadlocks-with-lockdep.patch
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc1/2.6.23-rc1-mm2/broken-out/workqueue-debug-work-related-deadlocks-with-lockdep.patch
> 
> I am suspecting that running flush_scheduled_work() from within run_workqueue()
> isn't good.

I'll have a look at this. I suspect that most if not all of our calls to
run_workqueue()/flush_scheduled_work() can now be replaced by more
targeted calls to cancel_work_sync() and cancel_delayed_work_sync().

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
