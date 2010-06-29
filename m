From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] SQUASHME: pnfs: check for read_buf error in decode_pnfs_layoutrecall_args
Date: Tue, 29 Jun 2010 16:57:26 +0300
Message-ID: <4C29FBC6.60506@panasas.com>
References: <1277808956-7694-1-git-send-email-bhalevy@panasas.com> <AANLkTiku06tjr1NCt4kJMJOlDne11zhRHKkJMc67-DvR@mail.gmail.com> <4C29EE53.5020703@panasas.com> <EC3B4874-0F69-4915-B97F-24C30C8F8F5E@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
	linux-nfs@vger.kernel.org
To: Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39358 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755206Ab0F2N5d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 09:57:33 -0400
Received: by wyb38 with SMTP id 38so2722867wyb.19
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jun 2010 06:57:32 -0700 (PDT)
In-Reply-To: <EC3B4874-0F69-4915-B97F-24C30C8F8F5E@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 29, 2010, 16:19 +0300, Andy Adamson <andros@netapp.com> wrote:
> 
> On Jun 29, 2010, at 9:00 AM, Benny Halevy wrote:
> 
>> On Jun. 29, 2010, 15:22 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com 
>>> wrote:
>>> I see that NFS4ERR_RESOURCE is returned throughout  
>>> callback_xdr.c ,but
>>> it is not a legal error return for NFSv4.1. -ENOMEM would be better.
>>
>> Sigh... it is indeed.
>>
>> You mean NFS4ERR_DELAY?
> 
> We code the client to have enough buffer space e.g. use the maximum  
> possible value for all the xdr fields. So if a request overflows this  
> buffer, I say it's NFS4ERR_BADXDR. (or NFS4ERR_BAD_CLIENT_CODE!!)

In this case BADXDR seems wrong as the "allocation" is static, independent
of the actual xdr code, so failure to allocate indicates more a bug on the
(callback RPC) server size, hence: NFS4ERR_SERVERFAULT would be more appropriate.

> 
> In any event, NFS4ERR_DELAY will not solve the problem as the client  
> will not increase the buffer space, and  (most likely) the server will  
> not decrease what it sends.

That's true.

> 
> -->Andy
> 
>>
>> Benny
>>
>>>
>>> -->Andy
>>>
>>> On Tue, Jun 29, 2010 at 6:55 AM, Benny Halevy <bhalevy@panasas.com>  
>>> wrote:
>>>> read_buf may return NULL. return NFS4ERR_RESOURCE in this case.
>>>>
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> ---
>>>> fs/nfs/callback_xdr.c |    8 ++++++++
>>>> 1 files changed, 8 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
>>>> index 7e34bb3..2f69f0d 100644
>>>> --- a/fs/nfs/callback_xdr.c
>>>> +++ b/fs/nfs/callback_xdr.c
>>>> @@ -247,6 +247,10 @@ static __be32  
>>>> decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
>>>>                       goto out;
>>>>
>>>>               p = read_buf(xdr, 2 * sizeof(uint64_t));
>>>> +               if (unlikely(p == NULL)) {
>>>> +                       status = htonl(NFS4ERR_RESOURCE);
>>>> +                       goto out;
>>>> +               }
>>>>               p = xdr_decode_hyper(p, &args->cbl_seg.offset);
>>>>               p = xdr_decode_hyper(p, &args->cbl_seg.length);
>>>>               status = decode_stateid(xdr, &args->cbl_stateid);
>>>> @@ -254,6 +258,10 @@ static __be32  
>>>> decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
>>>>                       goto out;
>>>>       } else if (args->cbl_recall_type == RETURN_FSID) {
>>>>               p = read_buf(xdr, 2 * sizeof(uint64_t));
>>>> +               if (unlikely(p == NULL)) {
>>>> +                       status = htonl(NFS4ERR_RESOURCE);
>>>> +                       goto out;
>>>> +               }
>>>>               p = xdr_decode_hyper(p, &args->cbl_fsid.major);
>>>>               p = xdr_decode_hyper(p, &args->cbl_fsid.minor);
>>>>       }
>>>> --
>>>> 1.6.6.1
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>>> nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>> nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

