From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] sunrpc: reduce timeout when unregistering rpcbind registrations.
Date: Thu, 28 May 2009 09:43:25 -0400
Message-ID: <A85051CB-18EB-4003-8DD6-26D3E9968543@oracle.com>
References: <20090528062730.15937.70579.stgit@notabene.brown> <20090528063303.15937.62423.stgit@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:40348 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757645AbZE1Nnh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2009 09:43:37 -0400
In-Reply-To: <20090528063303.15937.62423.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 28, 2009, at 2:33 AM, NeilBrown wrote:
> Unregistering an RPC service is not essential - but it is tidy.
> So it is unpleasant to wait a long time for it to complete.
>
> As unregistering is always directed to localhost, the most likely
> reason for any delay is the portmap (or rpcbind) is not running.
> In that case, waiting it totally pointless.  In any case, we should
> expect a quick response, and zero packet loss.
>
> So reduce the timeouts to a total of half a second.

A much better solution here would be to use a connected UDP socket.   
This would make start-up in the absense of rpcbind/portmap fail much  
quicker, we could keep the longer, safer timeout value, and the kernel  
could warn about exactly what the problem is.  It would also have  
similar benefits for the kernel's mount and NSM clients, and when  
starting up services.  It would additionally make UDP RPC ping  
checking fail very quickly.

> This means that if we try to stop nfsd while portmap is not running,
> it takes 3 seconds instead of 3.5 minutes.
>
> Note that stopping portmap before the last nfsd thread has died is
> not simply a configuration error.  When we kill nfsd threads they
> could take a while to die, and it is possible that portmap could
> then be killed before the last nfsd thread has had a change to finish
> up.
>
> [An alternate might be to make the sunrpc code always "connect"
> udp sockets so that "port not reachable" errors would get reported
> back.  This requires a more intrusive change though and might have
> other consequences]

We had discussed this about a year ago when I started adding IPv6  
support.  I had suggested switching the local rpc client to use TCP  
instead of UDP to solve exactly this time-out problem during start- 
up.  There was some resistance to the idea because TCP would leave  
privileged ports in TIMEWAIT (at shutdown, this is probably not a  
significant concern).

Trond had intended to introduce connected UDP socket support to the  
RPC client, although we were also interested in someday having a  
single UDP socket for all RPC traffic... the design never moved on  
from there.

My feeling at this point is that having a connected UDP socket  
transport would be simpler and have broader benefits than waiting for  
an eventual design that can accommodate multiple transport instances  
sharing a single socket.

> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>
> net/sunrpc/rpcb_clnt.c |   17 +++++++++++++++--
> 1 files changed, 15 insertions(+), 2 deletions(-)
>
> diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
> index beee6da..31f7e2e 100644
> --- a/net/sunrpc/rpcb_clnt.c
> +++ b/net/sunrpc/rpcb_clnt.c
> @@ -132,7 +132,8 @@ static const struct sockaddr_in  
> rpcb_inaddr_loopback = {
> };
>
> static struct rpc_clnt *rpcb_create_local(struct sockaddr *addr,
> -					  size_t addrlen, u32 version)
> +					  size_t addrlen, u32 version,
> +					  int unregister)
> {

It might be cleaner to define the timeout structures as global  
statics, and pass in a pointer to the preferred structure instead of  
checking a passed-in an integer.  One conditional branch instead of two.

> 	struct rpc_create_args args = {
> 		.protocol	= XPRT_TRANSPORT_UDP,
> @@ -144,6 +145,16 @@ static struct rpc_clnt  
> *rpcb_create_local(struct sockaddr *addr,
> 		.authflavor	= RPC_AUTH_UNIX,
> 		.flags		= RPC_CLNT_CREATE_NOPING,
> 	};
> +	const struct rpc_timeout unreg_timeout = {
> +		.to_initval = HZ/2,
> +		.to_maxval = HZ/2,
> +		.to_increment = 0,
> +		.to_retries = 0,
> +		.to_exponential = 0,
> +	};
> +
> +	if (unregister)
> +		args.timeout = &unreg_timeout;
>
> 	return rpc_create(&args);
> }
> @@ -183,10 +194,12 @@ static int rpcb_register_call(const u32  
> version, struct rpc_message *msg)
> 	size_t addrlen = sizeof(rpcb_inaddr_loopback);
> 	struct rpc_clnt *rpcb_clnt;
> 	int result, error = 0;
> +	int unregister;
>
> 	msg->rpc_resp = &result;
>
> -	rpcb_clnt = rpcb_create_local(addr, addrlen, version);
> +	unregister = (msg->rpc_proc->p_proc == RPCBPROC_UNSET);
> +	rpcb_clnt = rpcb_create_local(addr, addrlen, version, unregister);
> 	if (!IS_ERR(rpcb_clnt)) {
> 		error = rpc_call_sync(rpcb_clnt, msg, 0);
> 		rpc_shutdown_client(rpcb_clnt);

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
