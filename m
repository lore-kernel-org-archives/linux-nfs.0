Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:46229 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935970Ab3DRRZ6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Apr 2013 13:25:58 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 2/5] SUNRPC: allow disabling idle timeout
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130418171424.GA30837@pad.fieldses.org>
Date: Thu, 18 Apr 2013 10:25:49 -0700
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <F9B356AC-18C0-4BF1-8FBF-1F719801F72F@oracle.com>
References: <1366054508-27604-1-git-send-email-bfields@redhat.com> <1366054508-27604-3-git-send-email-bfields@redhat.com> <20130418170020.GA31075@fieldses.org> <1366304823.58246.22.camel@leira.trondhjem.org> <20130418171424.GA30837@pad.fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 18, 2013, at 10:14 AM, "J. Bruce Fields" <bfields@redhat.com> wrote:

> On Thu, Apr 18, 2013 at 05:07:03PM +0000, Myklebust, Trond wrote:
>> On Thu, 2013-04-18 at 13:00 -0400, J. Bruce Fields wrote:
>>> On Mon, Apr 15, 2013 at 03:35:04PM -0400, J. Bruce Fields wrote:
>>>> From: "J. Bruce Fields" <bfields@redhat.com>
>>>> 
>>>> In the gss-proxy case we don't want to have to reconnect at random--we
>>>> want to connect only on gss-proxy startup when we can steal gss-proxy's
>>>> context to do the connect in the right namespace.
>>>> 
>>>> So, provide a flag that allows the rpc_create caller to turn off the
>>>> idle timeout.
>>> 
>>> Chuck, the basic ideas was your suggestion, does the executation look OK
>>> here?  I had to copy the rpc_create flags down to the xprt_create, I
>>> don't know if that's reasonable.
>> 
>> This patch will conflict with commit
>> b7993cebb841b0da7a33e9d5ce301a9fd3209165 (SUNRPC: Allow rpc_create() to
>> request that TCP slots be unlimited) that was posted on this list
>> earlier this week.
> 
> Oh, sorry, I missed that.
> 
> Presumably then I should just work on top of that and do the same
> thing--define a pair of flags
> {RP_CLNT_CREATE|XPRT_CREATE}_NO_IDLE_TIMEOUT and translate between the
> two in rpc_create.

Agree.

> 
> --b.
> 
>> 
>>> --b.
>>> 
>>>> 
>>>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>>> ---
>>>> include/linux/sunrpc/clnt.h |    1 +
>>>> include/linux/sunrpc/xprt.h |    1 +
>>>> net/sunrpc/clnt.c           |    1 +
>>>> net/sunrpc/xprt.c           |    2 ++
>>>> 4 files changed, 5 insertions(+)
>>>> 
>>>> diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
>>>> index 2cf4ffa..8164986 100644
>>>> --- a/include/linux/sunrpc/clnt.h
>>>> +++ b/include/linux/sunrpc/clnt.h
>>>> @@ -124,6 +124,7 @@ struct rpc_create_args {
>>>> #define RPC_CLNT_CREATE_NOPING		(1UL << 4)
>>>> #define RPC_CLNT_CREATE_DISCRTRY	(1UL << 5)
>>>> #define RPC_CLNT_CREATE_QUIET		(1UL << 6)
>>>> +#define RPC_CLNT_CREATE_NO_IDLE_TIMEOUT	(1UL << 7)
>>>> 
>>>> struct rpc_clnt *rpc_create(struct rpc_create_args *args);
>>>> struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
>>>> diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
>>>> index 30834be..df28503 100644
>>>> --- a/include/linux/sunrpc/xprt.h
>>>> +++ b/include/linux/sunrpc/xprt.h
>>>> @@ -263,6 +263,7 @@ struct xprt_create {
>>>> 	size_t			addrlen;
>>>> 	const char		*servername;
>>>> 	struct svc_xprt		*bc_xprt;	/* NFSv4.1 backchannel */
>>>> +	unsigned long		flags;
>>>> };
>>>> 
>>>> struct xprt_class {
>>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>>> index dcc446e..a41d64a 100644
>>>> --- a/net/sunrpc/clnt.c
>>>> +++ b/net/sunrpc/clnt.c
>>>> @@ -411,6 +411,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
>>>> 		.addrlen = args->addrsize,
>>>> 		.servername = args->servername,
>>>> 		.bc_xprt = args->bc_xprt,
>>>> +		.flags = args->flags,
>>>> 	};
>>>> 	char servername[48];
>>>> 
>>>> diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
>>>> index b7478d5..37cbc37 100644
>>>> --- a/net/sunrpc/xprt.c
>>>> +++ b/net/sunrpc/xprt.c
>>>> @@ -1245,6 +1245,8 @@ found:
>>>> 				-PTR_ERR(xprt));
>>>> 		goto out;
>>>> 	}
>>>> +	if (args->flags & RPC_CLNT_CREATE_NO_IDLE_TIMEOUT)
>>>> +		xprt->idle_timeout = 0;
>>>> 	INIT_WORK(&xprt->task_cleanup, xprt_autoclose);
>>>> 	if (xprt_has_timer(xprt))
>>>> 		setup_timer(&xprt->timer, xprt_init_autodisconnect,
>>>> -- 
>>>> 1.7.9.5
>>>> 
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> 
>> -- 
>> Trond Myklebust
>> Linux NFS client maintainer
>> 
>> NetApp
>> Trond.Myklebust@netapp.com
>> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



