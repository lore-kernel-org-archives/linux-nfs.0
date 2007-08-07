From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.23-rc1-mm2
Date: Tue, 07 Aug 2007 18:05:14 -0400
Message-ID: <1186524314.6625.29.camel@heimdal.trondhjem.org>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<200708031301.01569.marc.dietrich@ap.physik.uni-giessen.de>
	<20070803093830.39852a01.akpm@linux-foundation.org>
	<1186160608.7255.10.camel@localhost> <20070803172137.GA3783@tv-sign.ru>
	<1186520929.6625.12.camel@heimdal.trondhjem.org>
	<20070807213749.GA461@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIXBK-0003mb-MS
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 15:05:39 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18FgZCjV2MsKJsijLfCn1HFCEwXOYiwlVM=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIXBJ-0004Mz-5a
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 15:05:38 -0700
In-Reply-To: <20070807213749.GA461@tv-sign.ru>
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

On Wed, 2007-08-08 at 01:37 +0400, Oleg Nesterov wrote:
> On 08/07, Trond Myklebust wrote:
> >
> > On Fri, 2007-08-03 at 21:21 +0400, Oleg Nesterov wrote:
> > > On 08/03, Trond Myklebust wrote:
> > > > I'll have a look at this. I suspect that most if not all of our calls to
> > > > run_workqueue()/flush_scheduled_work() can now be replaced by more
> > > > targeted calls to cancel_work_sync() and cancel_delayed_work_sync().
> > > 
> > > Yes, please, if possible.
> > 
> > All the NFS and SUNRPC cases appear to be trivial. IOW: the only reason
> > for the flush_workqueue()/flush_scheduled_work() calls was to ensure
> > that the cancel_work()/cancel_delayed_work() calls preceding them have
> > completed. Nevertheless I've split the conversion into two patches,
> > since one touches only the NFS code, whereas the other touches the
> > SUNRPC client and server code.
> > 
> > The two patches have been tested, and appear to work...
> 
> Great!
> 
> >  void
> >  nfs4_kill_renewd(struct nfs_client *clp)
> >  {
> >  	down_read(&clp->cl_sem);
> > -	cancel_delayed_work(&clp->cl_renewd);
> > +	cancel_delayed_work_sync(&clp->cl_renewd);
> >  	up_read(&clp->cl_sem);
> > -	flush_scheduled_work();
> >  }
> 
> this looks unsafe to me, the window is very small, but afaics this can
> deadlock if called when nfs4_renew_state() has already started, but didn't
> take ->cl_sem yet.

Not really. We have removed the nfs_client from the public lists, and we
are guaranteed that there are no more active superblocks attached to it
so nothing can call the reclaimer routine (which is the only routine
that takes a write lock on clp->cl_sem).

> Can't we avoid taking clp->cl_sem here?

Yes, I believe that we can, for the same reasons as above: the race with
the reclaimer is impossible, hence the read lock on cl_sem is redundant.

> Btw, unless I missed something, the code without this patch looks incorrect
> too: cancel_delayed_work() can fail if the timer expired, but the ->cl_renewd
> didn't run yet. In that case nfs4_renew_state() can run and re-schedule itself
> after flush_scheduled_work() returns.

No, that should not be possible. Again, see above: there are no active
superblocks, so clp->cl_superblocks is empty.

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
