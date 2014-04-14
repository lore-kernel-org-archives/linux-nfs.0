Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753896AbaDNRcj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Apr 2014 13:32:39 -0400
Date: Mon, 14 Apr 2014 13:32:28 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Dickson Steve <steved@redhat.com>, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Subject: Re: [PATCH 1/2] SUNRPC: Ensure that call_connect times out
 correctly
Message-ID: <20140414133228.4683d495@ipyr.poochiereds.net>
In-Reply-To: <02E852FE-5A75-4646-AAD3-A818A69C9C40@primarydata.com>
References: <1395081645-11906-1-git-send-email-trond.myklebust@primarydata.com>
	<20140414122518.6a3ca149@ipyr.poochiereds.net>
	<02E852FE-5A75-4646-AAD3-A818A69C9C40@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 14 Apr 2014 12:57:58 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Apr 14, 2014, at 12:25, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > On Mon, 17 Mar 2014 14:40:44 -0400
> > Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> > 
> >> When the server is unavailable due to a networking error, etc, we want
> >> the RPC client to respect the timeout delays when attempting to reconnect.
> >> 
> >> Fixes: 561ec1603171 (SUNRPC: call_connect_status should recheck bind..)
> >> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> >> ---
> >> net/sunrpc/clnt.c | 8 +++-----
> >> 1 file changed, 3 insertions(+), 5 deletions(-)
> >> 
> >> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> >> index 0edada973434..f22d3a115fda 100644
> >> --- a/net/sunrpc/clnt.c
> >> +++ b/net/sunrpc/clnt.c
> >> @@ -1798,10 +1798,6 @@ call_connect_status(struct rpc_task *task)
> >> 	trace_rpc_connect_status(task, status);
> >> 	task->tk_status = 0;
> >> 	switch (status) {
> >> -		/* if soft mounted, test if we've timed out */
> >> -	case -ETIMEDOUT:
> >> -		task->tk_action = call_timeout;
> >> -		return;
> >> 	case -ECONNREFUSED:
> >> 	case -ECONNRESET:
> >> 	case -ECONNABORTED:
> >> @@ -1812,7 +1808,9 @@ call_connect_status(struct rpc_task *task)
> >> 		if (RPC_IS_SOFTCONN(task))
> >> 			break;
> >> 	case -EAGAIN:
> >> -		task->tk_action = call_bind;
> >> +	case -ETIMEDOUT:
> >> +		/* Check if we've timed out before looping back to call_bind */
> >> +		task->tk_action = call_timeout;
> >> 		return;
> >> 	case 0:
> >> 		clnt->cl_stats->netreconn++;
> > 
> > I believe this patch may have broken the v4.0 callback channel
> > establishment code in nfsd. I think what's happening is this:
> > 
> > nfsd tries to create a RPC_TASK_SOFTCONN call to probe the cb channel
> > with a CB_NULL. It queues the connect_worker to the workqueue. That
> > establishes the socket and then gets a callback from the socket layer
> > into xs_tcp_state_change for TCP_ESTABLISHED.
> > 
> > That code does:
> > 
> >    xprt_wake_pending_tasks(xprt, -EAGAIN);
> > 
> > ...that wakes the task up, and sets the tk_status to -EAGAIN, and it
> > then moves on to call_timeout due to this patch. That code then does
> > this:
> > 
> >        if (RPC_IS_SOFTCONN(task)) {
> >                rpc_exit(task, -ETIMEDOUT);
> >                return;
> >        }
> > 
> > ...and the callback ping then fails with an error. Reverting this patch
> > seems to fix it. I see several ways that we could fix this, but I'm not
> > clear on the right way. Maybe we shouldn't be waking up the tasks with
> > -EAGAIN in the TCP_ESTABLISHED case?
> 
> ...or, possibly setup_callback_client should be setting the timeparms.to_maxval to a non-zero value so that xprt_adjust_timeout() and xprt_reset_majortimeo() behave as expected.
> 
> _________________________________
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> 

Well spotted. That does indeed fix it. I'll spin up a patch and send it
to Bruce.

Thanks!
-- 
Jeff Layton <jlayton@redhat.com>
