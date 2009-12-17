From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: Re: [PATCH] nfsd41: nfsd4_decode_compound() does not recognize allops
Date: Thu, 17 Dec 2009 08:39:32 -0800
Message-ID: <486253D1-0DDA-4670-9A60-B57917BD7E4D@netapp.com>
References: <1260587449-29538-1-git-send-email-Ricardo.Labiaga@netapp.com> <1260587449-29538-2-git-send-email-Ricardo.Labiaga@netapp.com> <20091217155403.GA15866@fieldses.org>
Mime-Version: 1.0 (iPhone Mail 7D11)
Content-Type: text/plain;
	format=flowed;
	delsp=yes;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:38355 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764726AbZLQQjy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Dec 2009 11:39:54 -0500
In-Reply-To: <20091217155403.GA15866@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

That's right.

- ricardo

On Dec 17, 2009, at 7:53 AM, "J. Bruce Fields" <bfields@fieldses.org>  
wrote:

> On Fri, Dec 11, 2009 at 07:10:49PM -0800, Ricardo Labiaga wrote:
>> The server incorrectly assumes that the operations in the
>> array start with value 0.  The first operation (OP_ACCESS)
>> has a value of 3, causing the check in nfsd4_decode_compound
>> to be off.
>>
>> Instead of comparing that the operation number is less than
>> the number of elements in the array, the server should verify
>> that it is less than the maximum valid operation number
>> defined by LAST_NFS4_OP.
>
> Thanks.  So the effect of this was to return an OP_ILLEGAL in some  
> cases
> where we should have been returning a NOTSUPP error?
>
> --b.
>
>>
>> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>> ---
>> fs/nfsd/nfs4xdr.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 0fbd50c..b83a24c 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1442,7 +1442,7 @@ nfsd4_decode_compound(struct  
>> nfsd4_compoundargs *argp)
>>        }
>>        op->opnum = ntohl(*argp->p++);
>>
>> -        if (op->opnum >= OP_ACCESS && op->opnum < ops->nops)
>> +        if (op->opnum >= OP_ACCESS && op->opnum <= LAST_NFS4_OP)
>>            op->status = ops->decoders[op->opnum](argp, &op->u);
>>        else {
>>            op->opnum = OP_ILLEGAL;
>> -- 
>> 1.5.4.3
>>
