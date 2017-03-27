Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40032 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751811AbdC0CmQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 26 Mar 2017 22:42:16 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] svcrdma: set XPT_CONG_CTRL flag for bc xprt
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <62622BEB-E234-4035-94FE-0C34E00693AE@gmail.com>
Date: Sun, 26 Mar 2017 22:41:14 -0400
Cc: Jeff Layton <jlayton@poochiereds.net>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Message-Id: <FBC1AD99-AF91-42B7-9C38-C68DA5454C94@oracle.com>
References: <20170326231254.1319.26075.stgit@manet.1015granger.net> <1490577699.6879.1.camel@poochiereds.net> <62622BEB-E234-4035-94FE-0C34E00693AE@gmail.com>
To: Chuck Lever <chucklever@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Mar 26, 2017, at 10:38 PM, Chuck Lever <chucklever@gmail.com> wrote:
> 
> Hey Jeff-
> 
> 
>>> On Mar 26, 2017, at 9:21 PM, Jeff Layton <jlayton@poochiereds.net> wrote:
>>> 
>>> On Sun, 2017-03-26 at 19:27 -0400, Chuck Lever wrote:
>>> Same change as Kinglong Mee's fix for the TCP backchannel service.
>>> 
>> 
>> Good catch. I guess I didn't do a good job of hunting down all of the
>> transports where this needed to be set. I'll give them another pass
>> again tomorrow to make sure I didn't miss any others.
>> 
>>> Fixes: 5283b03ee5cd ("nfs/nfsd/sunrpc: enforce transport...")
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> Some (perhaps late) review comments on 5283b03ee5cd:
>>> 
>>> I have reservations about returning RPC_PROG_MISMATCH in this case.
>>> RPC_PROG_UNAVAIL is more sensible. But the use of UDP with NFSv4 is
>>> not an RPC-level error, thus reporting the problem here seems like a
>>> layering violation.
>>> 
>>> I'm not sure why an explicit check is needed: if the server isn't
>>> listening on UDP, wouldn't clients see a transport-level rejection
>>> (like ECONNREFUSED)?
>>> 
>> 
>> Sure, if the server isn't listening on UDP...
>> 
>> The point of that patch is to enforce not allowing v4 over UDP when the
>> server is listening on UDP to serve earlier versions.
>> 
>> As far as the error...From RFC 5531:
>> 
>>            PROG_UNAVAIL  = 1, /* remote hasn't exported program  */
>>            PROG_MISMATCH = 2, /* remote can't support version #  */
>> 
>> Consider the case where the server is listening on both TCP and UDP,
>> and is serving both v3 and v4. Someone tries to send a v4 RPC over UDP.
>> 
>> The RPC program in that case (nfs) is supported over UDP, but the
>> version (v4) is not. So I disagree here. PROG_MISMATCH seems like the
>> better fit to me.
> 
> Then the server should report the correct version range in the
> rejection. The RPC response I saw on the wire claimed that 4
> was the maximum supported version.

Of course, versions 2 and 3 do not make sense for
the backchannel. So I'm not sure what you would report
in that case.


>>> Are we certain that all client implementations (including
>>> backchannel clients) will do something useful when presented with
>>> such a rejection? At least in the backchannel case, the Linux server
>>> had no idea what to do with RPC_PROG_MISMATCH on the backchannel.
>>> The workload stopped dead, no error report anywhere.
>>> 
>> 
>> Ouch. I think this would get translated into EPROTONOSUPPORT in the
>> client code. That should have ended up with nfsd4_mark_cb_down being
>> called with that error?...but I think that function may be effectively
>> neutered:
>> 
>> static void warn_no_callback_path(struct nfs4_client *clp, int reason)
>> {
>>       dprintk("NFSD: warning: no callback path to client %.*s: error %d\n",
>>               (int)clp->cl_name.len, clp->cl_name.data, reason);
>> }
>> 
>> Note that it emits a dprintk instead of a printk. Should we promote
>> that to something more visible?
> 
> You don't want a warning if the client never provided a
> callback path. But if one was provided, and it disappears,
> that might be useful to know.
> 
> OTOH some might blanch at the log flood, should something
> else go wrong.
> 
> An error counter might be the least we can do, if not a
> one-shot pr_warn.
> 
> 
>>> net/sunrpc/xprtrdma/svc_rdma_transport.c |    1 +
>>> 1 file changed, 1 insertion(+)
>>> 
>>> diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> index c13a5c3..fc8f14c 100644
>>> --- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> +++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
>>> @@ -127,6 +127,7 @@ static struct svc_xprt *svc_rdma_bc_create(struct svc_serv *serv,
>>>   xprt = &cma_xprt->sc_xprt;
>>> 
>>>   svc_xprt_init(net, &svc_rdma_bc_class, xprt, serv);
>>> +    set_bit(XPT_CONG_CTRL, &xprt->xpt_flags);
>>>   serv->sv_bc_xprt = xprt;
>>> 
>>>   dprintk("svcrdma: %s(%p)\n", __func__, xprt);
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

