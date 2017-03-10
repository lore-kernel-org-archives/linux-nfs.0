Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56840 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933813AbdCJV3L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Mar 2017 16:29:11 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Kinglong Mee" <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC/backchanel: set XPT_CONG_CTRL flag for bc xprt
Date: Fri, 10 Mar 2017 16:29:09 -0500
Message-ID: <727CB200-3DDD-4BC1-8AC0-62D38C5BFD6D@redhat.com>
In-Reply-To: <20170309202610.GF3929@fieldses.org>
References: <b321152e-cbe8-94b3-498c-1d32e7c7be2d@gmail.com>
 <1488885081.2788.0.camel@redhat.com> <20170309202610.GF3929@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9 Mar 2017, at 15:26, J. Bruce Fields wrote:

> Thanks!  Applying.--b.
>
> On Tue, Mar 07, 2017 at 06:11:21AM -0500, Jeff Layton wrote:
>> On Tue, 2017-03-07 at 17:22 +0800, Kinglong Mee wrote:
>>> The xprt for backchannel is created separately, not in TCP/UDP code.
>>> Because without the flags, the requests from NFSv41 backchannel are
>>> rejected in svc_process_common(),
>>>
>>> 1191         if (versp->vs_need_cong_ctrl &&
>>> 1192             !test_bit(XPT_CONG_CTRL, 
>>> &rqstp->rq_xprt->xpt_flags))
>>> 1193                 goto err_bad_vers;
>>>
>>> Fixes: 5283b03ee5 ("nfs/nfsd/sunrpc: enforce transport...")
>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>>> ---
>>>  net/sunrpc/svcsock.c | 1 +
>>>  1 file changed, 1 insertion(+)
>>>
>>> diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
>>> index 8931e33..2b720fa 100644
>>> --- a/net/sunrpc/svcsock.c
>>> +++ b/net/sunrpc/svcsock.c
>>> @@ -1635,6 +1635,7 @@ static struct svc_xprt 
>>> *svc_bc_create_socket(struct svc_serv *serv,
>>>
>>>  	xprt = &svsk->sk_xprt;
>>>  	svc_xprt_init(net, &svc_tcp_bc_class, xprt, serv);
>>> +	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
>>>
>>>  	serv->sv_bc_xprt = xprt;
>>>
>>
>> Good catch.
>>
>> Reviewed-by: Jeff Layton <jlayton@redhat.com>

This one fixes my failing xfstests generic/089.  Thanks, Kinglong Mee.

Ben
