From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol
 for mount.
Date: Thu, 28 Aug 2008 11:35:31 -0400
Message-ID: <48B6C5C3.5090903@RedHat.com>
References: <18556.40594.897682.204554@notabene.brown>	<76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>	<18559.53893.95829.499988@notabene.brown> <18559.57353.428342.328105@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: chucklever@gmail.com, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45784 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753707AbYH1Pi0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Aug 2008 11:38:26 -0400
In-Reply-To: <18559.57353.428342.328105-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Neil Brown wrote:
> On Friday July 18, neilb@suse.de wrote:
>> This is done over an unconnected socket so ICMP errors don't come back
>> (I think) so the timeout is all that clnt_call gets to know there is
>> an error... I wonder what would happen if we just changed that to be a
>> connected socket...
> 
> Yep, that was a good idea.
> The patch below causes a connected socket to be used when talking to
> portmap over UDP.  That means that we get ICMP errors back.
> And if we handle the errors correctly, we avoid the timeout.
> 
> With this added to all my other current patches, attempting to mount
> when udp/portmap is blocked succeeds in 90 seconds rather than 112
> seconds, and the 90 seconds is all in the mount system call.
> 
> If the kernel used connected UDP ports to talk to portmap, it might
> benefit too (didn't I see some emails about connected UDP ports in
> net/sunrpc recently - I'm afraid I didn't pay much attention).
> 
> NeilBrown
> 
> 
> From: NeilBrown <neilb@suse.de>
> 
> Use a connected port when talking to portmap via UDP.
> 
> This allows us to get ICMP errors reported back so we can avoid
> timeouts.  Also catch the error (RPC_CANTRECV) properly in getport.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 75354a7..ff50512 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -447,7 +447,7 @@ static unsigned short getport(struct sockaddr_in *saddr,
>  	bind_saddr = *saddr;
>  	bind_saddr.sin_port = htons(PMAPPORT);
>  
> -	socket = get_socket(&bind_saddr, proto, PMAP_TIMEOUT, FALSE, FALSE);
> +	socket = get_socket(&bind_saddr, proto, PMAP_TIMEOUT, FALSE, TRUE);
>  	if (socket == RPC_ANYSOCK) {
>  		if (proto == IPPROTO_TCP &&
>  		    rpc_createerr.cf_error.re_errno == ETIMEDOUT)
> @@ -536,6 +536,7 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
>  		}
>  		if (rpc_createerr.cf_stat != RPC_PROGNOTREGISTERED &&
>  		    rpc_createerr.cf_stat != RPC_TIMEDOUT &&
> +		    rpc_createerr.cf_stat != RPC_CANTRECV &&
>  		    rpc_createerr.cf_stat != RPC_PROGVERSMISMATCH)
>  			goto out_bad;
>  
> @@ -544,7 +545,8 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
>  				continue;
>  			p_prot = protos;
>  		}
> -		if (rpc_createerr.cf_stat == RPC_TIMEDOUT)
> +		if (rpc_createerr.cf_stat == RPC_TIMEDOUT ||
> +		    rpc_createerr.cf_stat == RPC_CANTRECV)
>  			goto out_bad;
>  
>  		if (vers || !*++p_vers)

Committed....

steved.

