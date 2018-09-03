Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:42687 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728973AbeICWB7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Sep 2018 18:01:59 -0400
Received: by mail-io0-f194.google.com with SMTP id n18-v6so926109ioa.9
        for <linux-nfs@vger.kernel.org>; Mon, 03 Sep 2018 10:40:48 -0700 (PDT)
Message-ID: <c33416fa2c7d3f444bf72266302ac6ec03b5159b.camel@gmail.com>
Subject: Re: [PATCH 05/27] SUNRPC: Avoid holding locks across the XDR
 encoding of the RPC message
From: Trond Myklebust <trondmy@gmail.com>
To: Chuck Lever <chucklever@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 03 Sep 2018 13:40:45 -0400
In-Reply-To: <3CB8AF72-4F0E-4273-B91E-FB4A28124E29@gmail.com>
References: <20180903152936.24325-1-trond.myklebust@hammerspace.com>
         <20180903152936.24325-2-trond.myklebust@hammerspace.com>
         <20180903152936.24325-3-trond.myklebust@hammerspace.com>
         <20180903152936.24325-4-trond.myklebust@hammerspace.com>
         <20180903152936.24325-5-trond.myklebust@hammerspace.com>
         <20180903152936.24325-6-trond.myklebust@hammerspace.com>
         <3CB8AF72-4F0E-4273-B91E-FB4A28124E29@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2018-09-03 at 13:11 -0400, Chuck Lever wrote:
> > On Sep 3, 2018, at 11:29 AM, Trond Myklebust <trondmy@gmail.com>
> > wrote:
> > 
> > Currently, we grab the socket bit lock before we allow the message
> > to be XDR encoded. That significantly slows down the transmission
> > rate, since we serialise on a potentially blocking operation.
> 
> Which operation blocks, and how often?

RPCSEC_GSS allocates memory when doing privacy encoding, for instance. 

> > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> > ---
> > net/sunrpc/clnt.c | 8 ++++----
> > 1 file changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> > index e5ac35e803ad..66ec61347716 100644
> > --- a/net/sunrpc/clnt.c
> > +++ b/net/sunrpc/clnt.c
> > @@ -1949,9 +1949,6 @@ call_transmit(struct rpc_task *task)
> > 	task->tk_action = call_status;
> > 	if (task->tk_status < 0)
> > 		return;
> > -	if (!xprt_prepare_transmit(task))
> > -		return;
> > -	task->tk_action = call_transmit_status;
> > 	/* Encode here so that rpcsec_gss can use correct sequence
> > number. */
> > 	if (rpc_task_need_encode(task)) {
> > 		rpc_xdr_encode(task);
> > @@ -1965,8 +1962,11 @@ call_transmit(struct rpc_task *task)
> > 			return;
> > 		}
> > 	}
> > +	if (!xprt_prepare_transmit(task))
> > +		return;
> > +	task->tk_action = call_transmit_status;
> > 	xprt_transmit(task);
> > -	if (task->tk_status < 0)
> > +	if (task->tk_status < 0) {
> 
> The added curly bracket seems incorrect.

Oops. Yes, that's a rebase brain-fart... Thanks for spotting it!
> 
> 
> > 		return;
> > 	if (is_retrans)
> > 		task->tk_client->cl_stats->rpcretrans++;
> > -- 
> > 2.17.1
> > 
> 
> --
> Chuck Lever
> chucklever@gmail.com
> 
> 
> 
