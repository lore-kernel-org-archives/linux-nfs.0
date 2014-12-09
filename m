Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47369 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754314AbaLIQgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 11:36:47 -0500
Date: Tue, 9 Dec 2014 11:36:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Chris Worley <chris.worley@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] sunrpc: add some tracepoints around enqueue and
 dequeue of svc_xprt
Message-ID: <20141209163644.GE20526@fieldses.org>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
 <1416597571-4265-5-git-send-email-jlayton@primarydata.com>
 <20141202083112.5f706ddb@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141202083112.5f706ddb@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 02, 2014 at 08:31:12AM -0500, Jeff Layton wrote:
> On Fri, 21 Nov 2014 14:19:31 -0500
> Jeff Layton <jlayton@primarydata.com> wrote:
> 
> > These were useful when I was tracking down a race condition between
> > svc_xprt_do_enqueue and svc_get_next_xprt.
> > 
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  include/trace/events/sunrpc.h | 94 +++++++++++++++++++++++++++++++++++++++++++
> >  net/sunrpc/svc_xprt.c         | 23 +++++++----
> >  2 files changed, 110 insertions(+), 7 deletions(-)
> > 
> > diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> > index ee4438a63a48..b9c1dc6c825a 100644
> > --- a/include/trace/events/sunrpc.h
> > +++ b/include/trace/events/sunrpc.h
> > @@ -8,6 +8,7 @@
> >  #include <linux/sunrpc/clnt.h>
> >  #include <linux/sunrpc/svc.h>
> >  #include <linux/sunrpc/xprtsock.h>
> > +#include <linux/sunrpc/svc_xprt.h>
> >  #include <net/tcp_states.h>
> >  #include <linux/net.h>
> >  #include <linux/tracepoint.h>
> > @@ -480,6 +481,99 @@ DEFINE_EVENT(svc_rqst_status, svc_send,
> >  	TP_PROTO(struct svc_rqst *rqst, int status),
> >  	TP_ARGS(rqst, status));
> >  
> > +#define show_svc_xprt_flags(flags)					\
> > +	__print_flags(flags, "|",					\
> > +		{ (1UL << XPT_BUSY),		"XPT_BUSY"},		\
> > +		{ (1UL << XPT_CONN),		"XPT_CONN"},		\
> > +		{ (1UL << XPT_CLOSE),		"XPT_CLOSE"},		\
> > +		{ (1UL << XPT_DATA),		"XPT_DATA"},		\
> > +		{ (1UL << XPT_TEMP),		"XPT_TEMP"},		\
> > +		{ (1UL << XPT_DEAD),		"XPT_DEAD"},		\
> > +		{ (1UL << XPT_CHNGBUF),		"XPT_CHNGBUF"},		\
> > +		{ (1UL << XPT_DEFERRED),	"XPT_DEFERRED"},	\
> > +		{ (1UL << XPT_OLD),		"XPT_OLD"},		\
> > +		{ (1UL << XPT_LISTENER),	"XPT_LISTENER"},	\
> > +		{ (1UL << XPT_CACHE_AUTH),	"XPT_CACHE_AUTH"},	\
> > +		{ (1UL << XPT_LOCAL),		"XPT_LOCAL"})
> > +
> > +TRACE_EVENT(svc_xprt_do_enqueue,
> > +	TP_PROTO(struct svc_xprt *xprt, struct svc_rqst *rqst),
> > +
> > +	TP_ARGS(xprt, rqst),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(struct svc_xprt *, xprt)
> > +		__field(struct svc_rqst *, rqst)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->xprt = xprt;
> > +		__entry->rqst = rqst;
> > +	),
> > +
> > +	TP_printk("xprt=0x%p addr=%pIScp pid=%d flags=%s", __entry->xprt,
> > +		(struct sockaddr *)&__entry->xprt->xpt_remote,
> > +		__entry->rqst ? __entry->rqst->rq_task->pid : 0,
> > +		show_svc_xprt_flags(__entry->xprt->xpt_flags))
> > +);
> > +
> > +TRACE_EVENT(svc_xprt_dequeue,
> > +	TP_PROTO(struct svc_xprt *xprt),
> > +
> > +	TP_ARGS(xprt),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(struct svc_xprt *, xprt)
> > +		__field_struct(struct sockaddr_storage, ss)
> > +		__field(unsigned long, flags)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->xprt = xprt,
> > +		xprt ? memcpy(&__entry->ss, &xprt->xpt_remote, sizeof(__entry->ss)) : memset(&__entry->ss, 0, sizeof(__entry->ss));
> > +		__entry->flags = xprt ? xprt->xpt_flags : 0;
> > +	),
> > +
> > +	TP_printk("xprt=0x%p addr=%pIScp flags=%s", __entry->xprt,
> > +		(struct sockaddr *)&__entry->ss,
> > +		show_svc_xprt_flags(__entry->flags))
> > +);
> > +
> > +TRACE_EVENT(svc_wake_up,
> > +	TP_PROTO(int pid),
> > +
> > +	TP_ARGS(pid),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(int, pid)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->pid = pid;
> > +	),
> > +
> > +	TP_printk("pid=%d", __entry->pid)
> > +);
> > +
> > +TRACE_EVENT(svc_handle_xprt,
> > +	TP_PROTO(struct svc_xprt *xprt, int len),
> > +
> > +	TP_ARGS(xprt, len),
> > +
> > +	TP_STRUCT__entry(
> > +		__field(struct svc_xprt *, xprt)
> > +		__field(int, len)
> > +	),
> > +
> > +	TP_fast_assign(
> > +		__entry->xprt = xprt;
> > +		__entry->len = len;
> > +	),
> > +
> > +	TP_printk("xprt=0x%p addr=%pIScp len=%d flags=%s", __entry->xprt,
> > +		(struct sockaddr *)&__entry->xprt->xpt_remote, __entry->len,
> > +		show_svc_xprt_flags(__entry->xprt->xpt_flags))
> > +);
> >  #endif /* _TRACE_SUNRPC_H */
> >  
> >  #include <trace/define_trace.h>
> > diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> > index ed90d955f733..0ae1d78d934d 100644
> > --- a/net/sunrpc/svc_xprt.c
> > +++ b/net/sunrpc/svc_xprt.c
> > @@ -322,12 +322,12 @@ static bool svc_xprt_has_something_to_do(struct svc_xprt *xprt)
> >  static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
> >  {
> >  	struct svc_pool *pool;
> > -	struct svc_rqst	*rqstp;
> > +	struct svc_rqst	*rqstp = NULL;
> >  	int cpu;
> >  	bool queued = false;
> >  
> >  	if (!svc_xprt_has_something_to_do(xprt))
> > -		return;
> > +		goto out;
> >  
> >  	/* Mark transport as busy. It will remain in this state until
> >  	 * the provider calls svc_xprt_received. We update XPT_BUSY
> > @@ -337,7 +337,7 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
> >  	if (test_and_set_bit(XPT_BUSY, &xprt->xpt_flags)) {
> >  		/* Don't enqueue transport while already enqueued */
> >  		dprintk("svc: transport %p busy, not enqueued\n", xprt);
> > -		return;
> > +		goto out;
> >  	}
> >  
> >  	cpu = get_cpu();
> > @@ -377,7 +377,7 @@ redo_search:
> >  		atomic_long_inc(&pool->sp_stats.threads_woken);
> >  		wake_up_process(rqstp->rq_task);
> >  		put_cpu();
> > -		return;
> > +		goto out;
> >  	}
> >  	rcu_read_unlock();
> >  
> > @@ -387,6 +387,7 @@ redo_search:
> >  	 * up to it directly but we can wake the thread up in the hopes that it
> >  	 * will pick it up once it searches for a xprt to service.
> >  	 */
> > +	dprintk("svc: transport %p put into queue\n", xprt);
> 
> Not sure how I ended up adding this dprintk here. That can certainly be
> removed since it's a duplicate of the one inside the following
> conditional block and we don't really want that to fire but once.
> 
> Bruce, do you want me to resend this patch with that removed?

I've fixed it, thanks for warning me.

--b.
