Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1050.oracle.com ([141.146.126.70]:30537 "EHLO
        aserp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754065AbcHSCXn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Aug 2016 22:23:43 -0400
Received: from aserp1040.oracle.com (aserp1040.oracle.com [141.146.126.69])
        by aserp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u7IMC6S2022345
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <linux-nfs@vger.kernel.org>; Thu, 18 Aug 2016 22:12:06 GMT
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: WARN_ON added to rpc_create()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160818215611.GA25052@fieldses.org>
Date: Thu, 18 Aug 2016 18:11:43 -0400
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <FA0D14B1-EC11-4345-887C-413EDC403E3A@oracle.com>
References: <42D0C152-58F9-4467-B86D-2A7A25544CE4@oracle.com> <20160803174724.GA5993@fieldses.org> <5E7D6A55-B7F3-411D-A74B-E8BCE04BCF02@oracle.com> <20160818215611.GA25052@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Aug 18, 2016, at 5:56 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Wed, Aug 03, 2016 at 03:40:11PM -0400, Chuck Lever wrote:
>> 
>>> On Aug 3, 2016, at 1:47 PM, bfields@fieldses.org wrote:
>>> 
>>> On Wed, Aug 03, 2016 at 11:27:47AM -0400, Chuck Lever wrote:
>>>> Hi Bruce-
>>>> 
>>>> I see that commit 39a9beab5acb83176e8b9a4f0778749a09341f1f
>>>> Author:     J. Bruce Fields <bfields@redhat.com>
>>>> AuthorDate: Tue May 17 12:38:21 2016 -0400
>>>> 
>>>>   rpc: share one xps between all backchannels
>>>> 
>>>> has added this piece of code:
>>>> 
>>>> @@ -452,10 +452,20 @@ static struct rpc_clnt *rpc_create_xprt(struct rpc_create_args *args,
>>>>       struct rpc_clnt *clnt = NULL;
>>>>       struct rpc_xprt_switch *xps;
>>>> 
>>>> -       xps = xprt_switch_alloc(xprt, GFP_KERNEL);
>>>> -       if (xps == NULL) {
>>>> -               xprt_put(xprt);
>>>> -               return ERR_PTR(-ENOMEM);
>>>> +       if (args->bc_xprt && args->bc_xprt->xpt_bc_xps) {
>>>> +               WARN_ON(args->protocol != XPRT_TRANSPORT_BC_TCP);
>>>> +               xps = args->bc_xprt->xpt_bc_xps;
>>>> +               xprt_switch_get(xps);
>>>> +       } else {
>>>> 
>>>> 
>>>> the WARN_ON here fires on the server whenever I use NFSv4.1 on RDMA.
>>>> 
>>>> Can you say why it was added? Is there something RPC/RDMA needs to
>>>> do to make the code safe?
>>> 
>>> What is args->protocol in this case?
>>> 
>>> Digging around...  OK, I missed that BC_TCP and BC_RDMA were defined as
>>> OR's of an XPRT_TRANSPORT_BC bit with the identifier of the underlying
>>> transport.  That makes sense.
>>> 
>>> So, I should have just used XPRT_TRANSPORT_BC there--I think all I meant
>>> was "is this a backchannel".
>>> 
>>> Does that fix the problem?
>> 
>> This simple fix eliminates the log noise:
>> 
>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>> index 2808d55..f94caf7 100644
>> --- a/net/sunrpc/clnt.c
>> +++ b/net/sunrpc/clnt.c
>> @@ -520,7 +520,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
>>        char servername[48];
>> 
>>        if (args->bc_xprt) {
>> -               WARN_ON(args->protocol != XPRT_TRANSPORT_BC_TCP);
>> +               WARN_ON(!(args->protocol & XPRT_TRANSPORT_BC));
>>                xprt = args->bc_xprt->xpt_bc_xprt;
>>                if (xprt) {
>>                        xprt_get(xprt);
>> 
>> 
>> This code seems to come from:
>> 
>> commit d50039ea5ee63c589b0434baa5ecf6e5075bb6f9
>> Author:     J. Bruce Fields <bfields@redhat.com>
>> AuthorDate: Mon May 16 17:03:42 2016 -0400
>> 
>>    nfsd4/rpc: move backchannel create logic into rpc code
>> 
>> 
>> Where it may have been copied from:
>> 
>> -static struct rpc_clnt *create_backchannel_client(struct rpc_create_args *args)
>> -{
>> -       struct rpc_xprt *xprt;
>> -
>> -       if (args->protocol != XPRT_TRANSPORT_BC_TCP)
>> -               return rpc_create(args);
>> -
>> -       xprt = args->bc_xprt->xpt_bc_xprt;
>> -       if (xprt) {
>> -               xprt_get(xprt);
>> -               return rpc_create_xprt(args, xprt);
>> -       }
>> -
>> -       return rpc_create(args);
>> -}
>> 
>> There's no warning here. In fact, protocol != BC_TCP seems to
>> be expected.
> 
> The protocol should be BC_TCP (OK, actually just BC) if and only if
> bc_xprt is set.
> 
> (The BC_TCP case is the 4.1+ case, the other is the 4.0 case.  In the
> 4.1+ case, the new client uses an existing (client-initiated)
> connection, in the 4.0 case, the new client must also have a new
> connection.
> 
> In the 4.0 case we'll always create a new xprt, in the 4.1 case we might
> or might not--depends on whether that particular connection has been
> used for a backchannel previously.)

OK, but why is a WARN_ON needed here? Why not return -EINVAL,
for example (once you've corrected BC_TCP -> BC) ?


--
Chuck Lever



