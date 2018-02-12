Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49422 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754353AbeBLQyq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Feb 2018 11:54:46 -0500
Date: Mon, 12 Feb 2018 11:54:45 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "thiago.becker@gmail.com" <thiago.becker@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH] sunrpc: Add task's xid to 'not responding' messages on
 call_timeout
Message-ID: <20180212165445.GD3294@fieldses.org>
References: <20180210010628.19792-1-thiago.becker@gmail.com>
 <1518226912.22856.3.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1518226912.22856.3.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Feb 10, 2018 at 01:41:55AM +0000, Trond Myklebust wrote:
> On Fri, 2018-02-09 at 23:06 -0200, Thiago Rafael Becker wrote:
> > When investigating reasons for nfs failures, packet dumps arei
> > eventually used.
> > Finding the rpc that generated the failure is done by comparing all
> > sent
> > rpc calls and all received rpc replies for those which are
> > unanswered,
> > which is prone to errors like
> > - Slow server responses
> > - Incomplete and uncaptured packets in the packet dump
> > - The heuristics used to inspect packets failing to interpret one
> > 
> > This patch adds the xid of rpc_tasks to the 'not responding' messages
> > in call_timeout to make these analysis more precise.
> > 
> > Signed-off-by: Thiago Rafael Becker <thiago.becker@gmail.com>
> > ---
> >  net/sunrpc/clnt.c | 10 ++++++----
> >  1 file changed, 6 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index e2a4184f3c5d..83c8aca951f4 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -2214,9 +2214,10 @@ call_timeout(struct rpc_task *task)
> >  	}
> >  	if (RPC_IS_SOFT(task)) {
> >  		if (clnt->cl_chatty) {
> > -			printk(KERN_NOTICE "%s: server %s not
> > responding, timed out\n",
> > +			printk(KERN_NOTICE "%s: server %s not
> > responding, timed out (xid: %x)\n",
> >  				clnt->cl_program->name,
> > -				task->tk_xprt->servername);
> > +				task->tk_xprt->servername,
> > +				be32_to_cpu(task->tk_rqstp-
> > >rq_xid));
> >  		}
> >  		if (task->tk_flags & RPC_TASK_TIMEOUT)
> >  			rpc_exit(task, -ETIMEDOUT);
> > @@ -2228,9 +2229,10 @@ call_timeout(struct rpc_task *task)
> >  	if (!(task->tk_flags & RPC_CALL_MAJORSEEN)) {
> >  		task->tk_flags |= RPC_CALL_MAJORSEEN;
> >  		if (clnt->cl_chatty) {
> > -			printk(KERN_NOTICE "%s: server %s not
> > responding, still trying\n",
> > +			printk(KERN_NOTICE "%s: server %s not
> > responding, still trying (xid: %x)\n",
> >  			clnt->cl_program->name,
> > -			task->tk_xprt->servername);
> > +			task->tk_xprt->servername,
> > +			be32_to_cpu(task->tk_rqstp->rq_xid));
> >  		}
> >  	}
> >  	rpc_force_rebind(clnt);
> 
> NACK. We should not be logging internal information such as XIDs as
> KERN_NOTICE messages.

I didn't now that was a general rule.  Is it that KERN_NOTICE (and
higher?) messages are expected to be leaked to users we don't trust?

I also wouldn't have expected XIDs to be terribly useful to an attacker.
But maybe it could help inject a malicious reply.

--b.

> If you want this information, you can extract it
> yourself; there are already plenty of ways to do so as a privileged
> user.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
