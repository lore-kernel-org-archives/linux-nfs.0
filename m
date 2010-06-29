From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] SQUASHME: pnfs: check for read_buf error in decode_pnfs_layoutrecall_args
Date: Tue, 29 Jun 2010 16:00:03 +0300
Message-ID: <4C29EE53.5020703@panasas.com>
References: <1277808956-7694-1-git-send-email-bhalevy@panasas.com> <AANLkTiku06tjr1NCt4kJMJOlDne11zhRHKkJMc67-DvR@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:39504 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882Ab0F2NAJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jun 2010 09:00:09 -0400
Received: by wwb18 with SMTP id 18so465927wwb.19
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jun 2010 06:00:06 -0700 (PDT)
In-Reply-To: <AANLkTiku06tjr1NCt4kJMJOlDne11zhRHKkJMc67-DvR-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 29, 2010, 15:22 +0300, "William A. (Andy) Adamson" <androsadamson@gmail.com> wrote:
> I see that NFS4ERR_RESOURCE is returned throughout callback_xdr.c ,but
> it is not a legal error return for NFSv4.1. -ENOMEM would be better.

Sigh... it is indeed.

You mean NFS4ERR_DELAY?

Benny

> 
> -->Andy
> 
> On Tue, Jun 29, 2010 at 6:55 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> read_buf may return NULL. return NFS4ERR_RESOURCE in this case.
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/callback_xdr.c |    8 ++++++++
>>  1 files changed, 8 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
>> index 7e34bb3..2f69f0d 100644
>> --- a/fs/nfs/callback_xdr.c
>> +++ b/fs/nfs/callback_xdr.c
>> @@ -247,6 +247,10 @@ static __be32 decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
>>                        goto out;
>>
>>                p = read_buf(xdr, 2 * sizeof(uint64_t));
>> +               if (unlikely(p == NULL)) {
>> +                       status = htonl(NFS4ERR_RESOURCE);
>> +                       goto out;
>> +               }
>>                p = xdr_decode_hyper(p, &args->cbl_seg.offset);
>>                p = xdr_decode_hyper(p, &args->cbl_seg.length);
>>                status = decode_stateid(xdr, &args->cbl_stateid);
>> @@ -254,6 +258,10 @@ static __be32 decode_pnfs_layoutrecall_args(struct svc_rqst *rqstp,
>>                        goto out;
>>        } else if (args->cbl_recall_type == RETURN_FSID) {
>>                p = read_buf(xdr, 2 * sizeof(uint64_t));
>> +               if (unlikely(p == NULL)) {
>> +                       status = htonl(NFS4ERR_RESOURCE);
>> +                       goto out;
>> +               }
>>                p = xdr_decode_hyper(p, &args->cbl_fsid.major);
>>                p = xdr_decode_hyper(p, &args->cbl_fsid.minor);
>>        }
>> --
>> 1.6.6.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

