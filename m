Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:30920 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755100Ab0KNLJv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Nov 2010 06:09:51 -0500
Message-ID: <4CDFBFEC.7080802@panasas.com>
Date: Sun, 14 Nov 2010 12:54:36 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH 18/22] pnfs-submit: roc add layoutreturn op to close compound
References: <1289551724-18575-1-git-send-email-iisaman@netapp.com>	<1289551724-18575-19-git-send-email-iisaman@netapp.com>	<4CDD6BE5.1000502@panasas.com> <AANLkTinCcrzaa0wf0QZ8mB0NuTsO2FuaMKvt8+O_rwG-@mail.gmail.com>
In-Reply-To: <AANLkTinCcrzaa0wf0QZ8mB0NuTsO2FuaMKvt8+O_rwG-@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-12 18:56, Fred Isaman wrote:
> On Fri, Nov 12, 2010 at 11:31 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>> On 2010-11-12 10:48, Fred Isaman wrote:
>>> From: Andy Adamson <andros@netapp.com>
>>> @@ -2143,6 +2145,8 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
>>>       encode_putfh(&xdr, args->fh, &hdr);
>>>       encode_close(&xdr, args, &hdr);
>>>       encode_getfattr(&xdr, args->bitmask, &hdr);
>>> +     if (args->op_bitmask & NFS4_HAS_LAYOUTRETURN) /* layoutreturn set */
>>> +             encode_layoutreturn(&xdr, &args->lr_args, &hdr);
>>
>> Sorry, I just noticed, but if there's no object I'll move the layoutreturn op
>> before close in the compound.
>>
>> Benny
>>
> 
> The reason the LAYOUTRETURN was last was so that we could ignore any
> error on the return.  Otherwise an error on the LAYOUTRETURN stops the
> CLOSE from being processed.  I'll defer to Andy, but while I see why
> you would want the reutrn first, moving it will require paying careful
> attention to how an error is dealt with.  (Actually, we have the same
> issue with the LAYOUTCOMMIT when it is later added.)

That's true, but the whole point behind doing the layoutreturn on close
is doing it before CLOSE :)

As we say in section 18.43:
   The logr_return_on_close result field is a directive to return the
   layout before closing the file.
          ^^^^^^^^^^^^^^^^^^^^^^^^

Benny

> 
> Fred
> 
