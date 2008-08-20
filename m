From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/8] SUNRPC: Set V6ONLY socket option for RPC listener
	sockets
Date: Wed, 20 Aug 2008 15:31:26 -0400
Message-ID: <20080820193126.GB21226@fieldses.org>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net> <20080813223953.13068.97829.stgit@manray.1015granger.net> <20080814200554.GI23859@fieldses.org> <74E488BD-DB15-41CD-AD30-A8A5213BC140@oracle.com> <20080814203833.GK23859@fieldses.org> <A8AF0C9D-B606-4EA4-9EE0-5367C515BE84@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56300 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754930AbYHTTbe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Aug 2008 15:31:34 -0400
In-Reply-To: <A8AF0C9D-B606-4EA4-9EE0-5367C515BE84@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 14, 2008 at 04:45:31PM -0400, Chuck Lever wrote:
> On Aug 14, 2008, at 4:38 PM, J. Bruce Fields wrote:
>> On Thu, Aug 14, 2008 at 04:34:14PM -0400, Chuck Lever wrote:
>>> On Aug 14, 2008, at 4:05 PM, J. Bruce Fields wrote:
>>>> On Wed, Aug 13, 2008 at 06:39:54PM -0400, Chuck Lever wrote:
>>>>> My plan is to use an AF_INET listener on systems that support only
>>>>> IPv4,
>>>>> and an AF_INET6 listener on systems that can support IPv6. Incoming
>>>>> IPv4 packets will be posted to an AF_INET6 listener with a mapped
>>>>> IPv4
>>>>> address.
>>>>
>>>> How will the nfs server choose whether to use AF_INET or AF_INET6?
>>>> Will
>>>> we need some new user interface?
>>>
>>> [PATCH 2/8] changes svc_create() to take an additional argument which
>>> specifies the listener's address family.  This value is stored in
>>> svc_serv.
>>
>> Right, but I'm asking about the nfsd server, not the rpc server, and  
>> the
>> user interface, not the in-kernel interface:
>
> Ah.  That wasn't clear before.
>
>> so suppose I'm a server
>> administrator, and want my nfs server to listen for ipv6 connections.
>> Will there be some switch I'll need to flip?
>
> I don't know how that UI will be designed.  So far, I've focused only on 
> the pieces needed for client side IPv6 support.  I figured the Bull team 
> had something figured out for the server, and didn't think any more about 
> it.

I've forgotten who was working on that; Aurelien Charbon?

--b.

>
>>>>> Max Matveev <makc@sgi.com> says:
>>>>> Creating a single listener can be dangerous - if  
>>>>> net.ipv6.bindv6only
>>>>> is enabled then it's possible to create another listener in v4
>>>>> namespace on the same port and steal the traffic from the "unifed"
>>>>> listener. You need to disable V6ONLY explicitly via a sockopt to
>>>>> stop
>>>>> that.
>>>>>
>>>>> Set appropriate socket option on RPC server listener sockets to
>>>>> prevent
>>>>> this.
>>>>>
>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> ---
>>>>>
>>>>> net/sunrpc/svcsock.c |   13 +++++++++++++
>>>>> 1 files changed, 13 insertions(+), 0 deletions(-)
>>>>>
>>>>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>>>>> index 3e65719..f91377c 100644
>>>>> --- a/net/sunrpc/svcsock.c
>>>>> +++ b/net/sunrpc/svcsock.c
>>>>> @@ -1114,6 +1114,7 @@ static struct svc_sock
>>>>> *svc_setup_socket(struct svc_serv *serv,
>>>>> 	struct svc_sock	*svsk;
>>>>> 	struct sock	*inet;
>>>>> 	int		pmap_register = !(flags & SVC_SOCK_ANONYMOUS);
>>>>> +	int		val;
>>>>>
>>>>> 	dprintk("svc: svc_setup_socket %p\n", sock);
>>>>> 	if (!(svsk = kzalloc(sizeof(*svsk), GFP_KERNEL))) {
>>>>> @@ -1146,6 +1147,18 @@ static struct svc_sock
>>>>> *svc_setup_socket(struct svc_serv *serv,
>>>>> 	else
>>>>> 		svc_tcp_init(svsk, serv);
>>>>>
>>>>> +	/*
>>>>> +	 * We start one listener per sv_serv.  We want AF_INET
>>>>> +	 * requests to be automatically shunted to our AF_INET6
>>>>> +	 * listener using a mapped IPv4 address.  Make sure
>>>>> +	 * no-one starts an equivalent IPv4 listener, which
>>>>> +	 * would steal our incoming connections.
>>>>> +	 */
>>>>> +	val = 0;
>>>>> +	if (serv->sv_family == AF_INET6)
>>>>> +		kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
>>>>> +					(char *)&val, sizeof(val));
>>>>> +
>>>>> 	dprintk("svc: svc_setup_socket created %p (inet %p)\n",
>>>>> 				svsk, svsk->sk_sk);
>>>>>
>>>>>
>>>
>>> --
>>> Chuck Lever
>>> chuck[dot]lever[at]oracle[dot]com
>>>
>>>
>>>
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
