From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: 2.6.23-rc1-mm2
Date: Mon, 6 Aug 2007 14:53:16 +0400
Message-ID: <20070806105316.GA140@tv-sign.ru>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
	<200708031301.01569.marc.dietrich@ap.physik.uni-giessen.de>
	<20070803093830.39852a01.akpm@linux-foundation.org>
	<1186160608.7255.10.camel@localhost>
	<20070803172137.GA3783@tv-sign.ru>
	<1186381496.21957.30.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Neil Brown <neilb@suse.de>, linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>,
	Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II0DV-0007eh-TD
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 03:53:42 -0700
Received: from mail.screens.ru ([213.234.233.54])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1II0DZ-0004ss-7u
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 03:53:46 -0700
In-Reply-To: <1186381496.21957.30.camel@johannes.berg>
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

On 08/06, Johannes Berg wrote:
>
> On Fri, 2007-08-03 at 21:21 +0400, Oleg Nesterov wrote:
> 
> > To avoid a possible confusion: it is still OK if work->func() flushes
> > its own workqueue, so strictly speaking this trace is false positive,
> > but it would be very nice if we can get rid of this practice.
> 
> However, the question whether we should allow flush_workqueue from
> within a struct work is mainly an API policy issue; it doesn't hurt to
> flush a workqueue from within a work,

I am not sure, but currently I hope we can forbid this eventually, so I
personally think it is good that your patch complains.

> --- wireless-dev.orig/kernel/workqueue.c	2007-08-06 08:11:23.297846657 +0200
> +++ wireless-dev/kernel/workqueue.c	2007-08-06 08:19:54.727846657 +0200
> @@ -272,7 +272,7 @@ static void run_workqueue(struct cpu_wor
>  
>  		BUG_ON(get_wq_data(work) != cwq);
>  		work_clear_pending(work);
> -		lock_acquire(&cwq->wq->lockdep_map, 0, 0, 0, 2, _THIS_IP_);
> +		lock_acquire(&cwq->wq->lockdep_map, 0, 0, 1, 2, _THIS_IP_);
>  		lock_acquire(&lockdep_map, 0, 0, 0, 2, _THIS_IP_);
>  		f(work);
>  		lock_release(&lockdep_map, 1, _THIS_IP_);
> @@ -395,7 +395,7 @@ void fastcall flush_workqueue(struct wor
>  	int cpu;
>  
>  	might_sleep();
> -	lock_acquire(&wq->lockdep_map, 0, 0, 0, 2, _THIS_IP_);
> +	lock_acquire(&wq->lockdep_map, 0, 0, 1, 2, _THIS_IP_);
>  	lock_release(&wq->lockdep_map, 1, _THIS_IP_);
>  	for_each_cpu_mask(cpu, *cpu_map)
>  		flush_cpu_workqueue(per_cpu_ptr(wq->cpu_wq, cpu));
> @@ -779,7 +779,7 @@ static void cleanup_workqueue_thread(str
>  	if (cwq->thread == NULL)
>  		return;
>  
> -	lock_acquire(&cwq->wq->lockdep_map, 0, 0, 0, 2, _THIS_IP_);
> +	lock_acquire(&cwq->wq->lockdep_map, 0, 0, 1, 2, _THIS_IP_);
>  	lock_release(&cwq->wq->lockdep_map, 1, _THIS_IP_);
>  
>  	flush_cpu_workqueue(cwq);

But this makes ->lockdep_map meaningless? We always take wq->lockdep_map
for reading, now we can't detect deadlocks.

	read_lock(A);
	lock(B);

vs
	lock(B);
	read_lock(A);

is valid, kernel/lockdep.c should not complain.

No?

Oleg.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
