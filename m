From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: 2.6.23-rc1-mm2
Date: Wed, 8 Aug 2007 01:37:49 +0400
Message-ID: <20070807213749.GA461@tv-sign.ru>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<200708031301.01569.marc.dietrich@ap.physik.uni-giessen.de>
	<20070803093830.39852a01.akpm@linux-foundation.org>
	<1186160608.7255.10.camel@localhost>
	<20070803172137.GA3783@tv-sign.ru>
	<1186520929.6625.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IIWkY-0000eb-O6
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 14:38:01 -0700
Received: from x346.tv-sign.ru ([89.108.83.215] helo=mail.screens.ru)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IIWka-00031h-4O
	for nfs@lists.sourceforge.net; Tue, 07 Aug 2007 14:38:02 -0700
In-Reply-To: <1186520929.6625.12.camel@heimdal.trondhjem.org>
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

On 08/07, Trond Myklebust wrote:
>
> On Fri, 2007-08-03 at 21:21 +0400, Oleg Nesterov wrote:
> > On 08/03, Trond Myklebust wrote:
> > > I'll have a look at this. I suspect that most if not all of our calls to
> > > run_workqueue()/flush_scheduled_work() can now be replaced by more
> > > targeted calls to cancel_work_sync() and cancel_delayed_work_sync().
> > 
> > Yes, please, if possible.
> 
> All the NFS and SUNRPC cases appear to be trivial. IOW: the only reason
> for the flush_workqueue()/flush_scheduled_work() calls was to ensure
> that the cancel_work()/cancel_delayed_work() calls preceding them have
> completed. Nevertheless I've split the conversion into two patches,
> since one touches only the NFS code, whereas the other touches the
> SUNRPC client and server code.
> 
> The two patches have been tested, and appear to work...

Great!

>  void
>  nfs4_kill_renewd(struct nfs_client *clp)
>  {
>  	down_read(&clp->cl_sem);
> -	cancel_delayed_work(&clp->cl_renewd);
> +	cancel_delayed_work_sync(&clp->cl_renewd);
>  	up_read(&clp->cl_sem);
> -	flush_scheduled_work();
>  }

this looks unsafe to me, the window is very small, but afaics this can
deadlock if called when nfs4_renew_state() has already started, but didn't
take ->cl_sem yet.

Can't we avoid taking clp->cl_sem here?

Btw, unless I missed something, the code without this patch looks incorrect
too: cancel_delayed_work() can fail if the timer expired, but the ->cl_renewd
didn't run yet. In that case nfs4_renew_state() can run and re-schedule itself
after flush_scheduled_work() returns.

Oleg.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
