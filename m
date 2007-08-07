From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.23-rc1-mm2
Date: Tue, 07 Aug 2007 19:08:27 -0400
Message-ID: <1186528107.6625.71.camel@heimdal.trondhjem.org>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<200708031301.01569.marc.dietrich@ap.physik.uni-giessen.de>
	<20070803093830.39852a01.akpm@linux-foundation.org>
	<1186160608.7255.10.camel@localhost> <20070803172137.GA3783@tv-sign.ru>
	<1186520929.6625.12.camel@heimdal.trondhjem.org>
	<20070807213749.GA461@tv-sign.ru>
	<1186524314.6625.29.camel@heimdal.trondhjem.org>
	<20070807222042.GA553@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIYAZ-000207-9g
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:08:55 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/E+ZKLaAFh4VBr0yHW1xMq0KNumIJkoBo=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIYAc-0006zH-Sp
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 16:08:59 -0700
In-Reply-To: <20070807222042.GA553@tv-sign.ru>
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

On Wed, 2007-08-08 at 02:20 +0400, Oleg Nesterov wrote:

> But. nfs4_renew_state() checks list_empty(&clp->cl_superblocks) under
> clp->cl_sem? So, if it is possible that clp->cl_renewd was scheduled
> at the time when nfs4_kill_renewd(), we can deadlock, no? Because
> nfs4_renew_state() needs clp->cl_sem to complete, but nfs4_kill_renewd()
> holds this sem, and waits for nfs4_renew_state() completion.

They both take read locks, which means that they can take them
simultaneously. AFAICS, the deadlock can only occur if something manages
to insert a request for a write lock after nfs4_kill_renewd() takes its
read lock, but before nfs4_renew_state() takes its read lock:

1) nfs4_kill_renewd()		2) nfs4_renew_state()		3) somebody else
-------------------             ------------------		-------------
read lock
wait on (2) to complete
								write lock <waits on (1)>
				read lock <waits on (3),
					because rw_semaphores
					don't allow a read lock
					request to jump a write
					lock request>

however as I explained earlier, the only process that can take a write
lock is the reclaimer daemon, but we _know_ that cannot be running (for
one thing, the reference count on nfs_client is zero, for the other,
there are no superblocks).

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
