From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering
  rpcbind registrations.
Date: Thu, 28 May 2009 09:07:20 -0400
Message-ID: <4a1e8c9e.48c3f10a.6d51.4c33@mx.google.com>
References: <20090528062730.15937.70579.stgit@notabene.brown>
 <20090528063303.15937.62423.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f190.google.com ([209.85.221.190]:60080 "EHLO
	mail-qy0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759493AbZE1NHm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2009 09:07:42 -0400
Received: by qyk28 with SMTP id 28so5431889qyk.33
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2009 06:07:43 -0700 (PDT)
In-Reply-To: <20090528063303.15937.62423.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 02:33 AM 5/28/2009, NeilBrown wrote:
>Unregistering an RPC service is not essential - but it is tidy.
>So it is unpleasant to wait a long time for it to complete.
>
>As unregistering is always directed to localhost, the most likely
>reason for any delay is the portmap (or rpcbind) is not running.
>In that case, waiting it totally pointless.  In any case, we should
>expect a quick response, and zero packet loss.
>
>So reduce the timeouts to a total of half a second.

Why wait for the response at all in this case? With zero retries
and nothing to do with the result, it seems pointless to even wait
for half a second.

Tom.


>
>This means that if we try to stop nfsd while portmap is not running,
>it takes 3 seconds instead of 3.5 minutes.
>
>Note that stopping portmap before the last nfsd thread has died is
>not simply a configuration error.  When we kill nfsd threads they
>could take a while to die, and it is possible that portmap could
>then be killed before the last nfsd thread has had a change to finish
>up.
>
>[An alternate might be to make the sunrpc code always "connect"
>udp sockets so that "port not reachable" errors would get reported
>back.  This requires a more intrusive change though and might have
>other consequences]
>
>Signed-off-by: NeilBrown <neilb@suse.de>
>---
>
> net/sunrpc/rpcb_clnt.c |   17 +++++++++++++++--
> 1 files changed, 15 insertions(+), 2 deletions(-)
>
>diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
>index beee6da..31f7e2e 100644
>--- a/net/sunrpc/rpcb_clnt.c
>+++ b/net/sunrpc/rpcb_clnt.c
>@@ -132,7 +132,8 @@ static const struct sockaddr_in rpcb_inaddr_loopback = {
> };
> 
> static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
>-					  size_t addrlen, u32 version)
>+					  size_t addrlen, u32 version,
>+					  int unregister)
> {
> 	struct rpc_create_args args = {
> 		.protocol	= XPRT_TRANSPORT_UDP,
>@@ -144,6 +145,16 @@ static struct rpc_clnt *rpcb_create_local(struct 
>sockaddr *addr,
> 		.authflavor	= RPC_AUTH_UNIX,
> 		.flags		= RPC_CLNT_CREATE_NOPING,
> 	};
>+	const struct rpc_timeout unreg_timeout = {
>+		.to_initval = HZ/2,
>+		.to_maxval = HZ/2,
>+		.to_increment = 0,
>+		.to_retries = 0,
>+		.to_exponential = 0,
>+	};
>+
>+	if (unregister)
>+		args.timeout = &unreg_timeout;
> 
> 	return rpc_create(&args);
> }
>@@ -183,10 +194,12 @@ static int rpcb_register_call(const u32 version, 
>struct rpc_message *msg)
> 	size_t addrlen = sizeof(rpcb_inaddr_loopback);
> 	struct rpc_clnt *rpcb_clnt;
> 	int result, error = 0;
>+	int unregister;
> 
> 	msg->rpc_resp = &result;
> 
>-	rpcb_clnt = rpcb_create_local(addr, addrlen, version);
>+	unregister = (msg->rpc_proc->p_proc == RPCBPROC_UNSET);
>+	rpcb_clnt = rpcb_create_local(addr, addrlen, version, unregister);
> 	if (!IS_ERR(rpcb_clnt)) {
> 		error = rpc_call_sync(rpcb_clnt, msg, 0);
> 		rpc_shutdown_client(rpcb_clnt);
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

