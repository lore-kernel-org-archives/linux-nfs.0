From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 03/33] SUNRPC: Don't attempt to destroy expired RPCSEC_GSS credentials..
Date: Wed, 23 Apr 2008 13:40:52 -0400
Message-ID: <BA4DAED3-46BB-4AC9-9FDF-95FB11548487@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204047.14124.64969.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <FB8780E7-FE92-40D6-8DFE-0663DF1B0162@oracle.com> <1208822443.7767.23.camel@heimdal.trondhjem.org> <86898638-C54D-44F7-917E-1EDF6795B56C@oracle.com> <1208876800.11982.6.camel@heimdal.trondhjem.org> <1208960443.7459.9.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:35385 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696AbYDWRlY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Apr 2008 13:41:24 -0400
In-Reply-To: <1208960443.7459.9.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 23, 2008, at 10:20 AM, Trond Myklebust wrote:
> On Tue, 2008-04-22 at 11:11 -0400, Trond Myklebust wrote:
>> On Tue, 2008-04-22 at 09:38 -0400, Chuck Lever wrote:
>>>> RFC-2203 states that servers are supposed to silently discard  
>>>> requests
>>>> that they don't recognise (see section 5.3.3.1 - Context
>>>> Management), so
>>>> it is correct server behaviour.
>>>
>>>
>>> Dropping the request to destroy a context is fine.  Temporarily
>>> fencing the client is what I was concerned about.
>>
>> I'd agree that is somewhat drastic, and have passed the information  
>> on
>> to the server vendor, however that doesn't change the fact that we  
>> have
>> a client bug too: we should not be using expired creds.
>>
>> The client side performance problem was compounded by the fact that  
>> the
>> RPCSEC_GSS destruction call was sent as a hard RPC call, and the fact
>> that we impose the NFSv4 rule that we need to drop the connection  
>> before
>> resending a request.
>
> Having thought a bit more about the consequences of this RFC, I  
> think we
> also need to drop the credential on (major) timeouts, since we need to
> assume that the timeout may be due to the credential being out of
> sequence.

I'm not an expert on this, but so we're on the same page, are you  
looking at RFC 2203 Section 5.3.3, or Section 7.2?

5.3.3.1 seems to suggest that clients will typically bump the sequence  
number and retry after the server drops a request.  In other words, it  
doesn't expect there to be much more to timeout recovery than that.

I wonder about the impact of frequent credential invalidation for  
datagram transports, where major timeouts are not so rare.

> ---------------------------------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Tue, 22 Apr 2008 16:47:55 -0400
> SUNRPC: Invalidate the RPCSEC_GSS session if the server dropped the  
> request
>
> RFC 2203 requires the server to drop the request if it believes the
> RPCSEC_GSS context is out of sequence. The problem is that we have  
> no way
> on the client to know why the server dropped the request. In order  
> to avoid
> spinning forever trying to resend the request, the safe approach is
> therefore to always invalidate the RPCSEC_GSS context on every major
> timeout.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
> net/sunrpc/clnt.c |    5 +++++
> 1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
> index 2969e84..eb813e9 100644
> --- a/net/sunrpc/clnt.c
> +++ b/net/sunrpc/clnt.c
> @@ -1169,6 +1169,11 @@ call_timeout(struct rpc_task *task)
> 			clnt->cl_protname, clnt->cl_server);
> 	}
> 	rpc_force_rebind(clnt);
> +	/*
> +	 * Did our request time out due to an RPCSEC_GSS out-of-sequence
> +	 * event? RFC2203 requires the server to drop all such requests.
> +	 */
> +	rpcauth_invalcred(task);
>
> retry:
> 	clnt->cl_stats->rpcretrans++;
>
>
> -- 
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



