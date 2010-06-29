From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH] SQUASHME: pnfs: check for read_buf error in decode_pnfs_layoutrecall_args
Date: Tue, 29 Jun 2010 09:19:40 -0400
Message-ID: <EC3B4874-0F69-4915-B97F-24C30C8F8F5E@netapp.com>
References: <1277808956-7694-1-git-send-email-bhalevy@panasas.com> <AANLkTiku06tjr1NCt4kJMJOlDne11zhRHKkJMc67-DvR@mail.gmail.com> <4C29EE53.5020703@panasas.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
	linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20798 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754896Ab0F2NTm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jun 2010 09:19:42 -0400
In-Reply-To: <4C29EE53.5020703@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 29, 2010, at 9:00 AM, Benny Halevy wrote:

> On Jun. 29, 2010, 15:22 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com 
> > wrote:
>> I see that NFS4ERR_RESOURCE is returned throughout  
>> callback_xdr.c ,but
>> it is not a legal error return for NFSv4.1. -ENOMEM would be better.
>
> Sigh... it is indeed.
>
> You mean NFS4ERR_DELAY?

We code the client to have enough buffer space e.g. use the maximum  
possible value for all the xdr fields. So if a request overflows this  
buffer, I say it's NFS4ERR_BADXDR. (or NFS4ERR_BAD_CLIENT_CODE!!)

In any event, NFS4ERR_DELAY will not solve the problem as the client  
will not increase the buffer space, and  (most likely) the server will  
not decrease what it sends.

-->Andy

>
> Benny
>
>>
>> -->Andy
>>
>> On Tue, Jun 29, 2010 at 6:55 AM, Benny Halevy <bhalevy@panasas.com>  
>> wrote:
>>> read_buf may return NULL. return NFS4ERR_RESOURCE in this case.
>>>
>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>> ---
>>> fs/nfs/callback_xdr.c |    8 ++++++++
>>> 1 files changed, 8 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
>>> index 7e34bb3..2f69f0d 100644
>>> --- a/fs/nfs/callback_xdr.c
>>> +++ b/fs/nfs/callback_xdr.c
>>> @@ -247,6 +247,10 @@ static __be32  
>>> decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
>>>                       goto out;
>>>
>>>               p = read_buf(xdr, 2 * sizeof(uint64_t));
>>> +               if (unlikely(p == NULL)) {
>>> +                       status = htonl(NFS4ERR_RESOURCE);
>>> +                       goto out;
>>> +               }
>>>               p = xdr_decode_hyper(p, &args->cbl_seg.offset);
>>>               p = xdr_decode_hyper(p, &args->cbl_seg.length);
>>>               status = decode_stateid(xdr, &args->cbl_stateid);
>>> @@ -254,6 +258,10 @@ static __be32  
>>> decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
>>>                       goto out;
>>>       } else if (args->cbl_recall_type == RETURN_FSID) {
>>>               p = read_buf(xdr, 2 * sizeof(uint64_t));
>>> +               if (unlikely(p == NULL)) {
>>> +                       status = htonl(NFS4ERR_RESOURCE);
>>> +                       goto out;
>>> +               }
>>>               p = xdr_decode_hyper(p, &args->cbl_fsid.major);
>>>               p = xdr_decode_hyper(p, &args->cbl_fsid.minor);
>>>       }
>>> --
>>> 1.6.6.1
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>> nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux- 
>> nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

