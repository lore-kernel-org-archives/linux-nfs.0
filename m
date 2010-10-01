Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:51118 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932357Ab0JAPSG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 11:18:06 -0400
Message-ID: <4CA5FBAB.2040309@panasas.com>
Date: Fri, 01 Oct 2010 17:18:03 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd4: adjust buflen for encoded attrs bitmap based
 on actual bitmap length
References: <1285872466-21013-1-git-send-email-bhalevy@panasas.com> <20101001145018.GD17310@fieldses.org>
In-Reply-To: <20101001145018.GD17310@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-01 16:50,  J. Bruce Fields wrote:
> On Thu, Sep 30, 2010 at 08:47:46PM +0200, Benny Halevy wrote:
>> The existing code adjusted it based on the worst case scenario for the returned
>> bitmap and the best case scenario for the supported attrs attribute.
> 
> Looks fine, thanks.  Mind if I just ditch the unlikely()s?  I know,
> they've been there for a while, but I'm just skeptical of their value on
> anything but the most unbelievably hot optimized-to-death code paths.

Well, they don't bother me so I don't the value of ditching them either :)

They're supposed to help branch prediction thus optimizing the common
code paths on the expense of the unlikely path but I too didn't measure
their affect.

Bottom line is that I don't have and strong reservations either for or
against them in this case :)

Benny

> 
> --b.
> 
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4xdr.c |   14 ++++++++++----
>>  1 files changed, 10 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 1a468bb..f48d891 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -1805,19 +1805,23 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>>  				goto out_nfserr;
>>  		}
>>  	}
>> -	if ((buflen -= 16) < 0)
>> -		goto out_resource;
>>  
>>  	if (unlikely(bmval2)) {
>> +		if ((buflen -= 16) < 0)
>> +			goto out_resource;
>>  		WRITE32(3);
>>  		WRITE32(bmval0);
>>  		WRITE32(bmval1);
>>  		WRITE32(bmval2);
>>  	} else if (likely(bmval1)) {
>> +		if ((buflen -= 12) < 0)
>> +			goto out_resource;
>>  		WRITE32(2);
>>  		WRITE32(bmval0);
>>  		WRITE32(bmval1);
>>  	} else {
>> +		if ((buflen -= 8) < 0)
>> +			goto out_resource;
>>  		WRITE32(1);
>>  		WRITE32(bmval0);
>>  	}
>> @@ -1828,15 +1832,17 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
>>  		u32 word1 = nfsd_suppattrs1(minorversion);
>>  		u32 word2 = nfsd_suppattrs2(minorversion);
>>  
>> -		if ((buflen -= 12) < 0)
>> -			goto out_resource;
>>  		if (!aclsupport)
>>  			word0 &= ~FATTR4_WORD0_ACL;
>>  		if (!word2) {
>> +			if ((buflen -= 12) < 0)
>> +				goto out_resource;
>>  			WRITE32(2);
>>  			WRITE32(word0);
>>  			WRITE32(word1);
>>  		} else {
>> +			if ((buflen -= 16) < 0)
>> +				goto out_resource;
>>  			WRITE32(3);
>>  			WRITE32(word0);
>>  			WRITE32(word1);
>> -- 
>> 1.7.2.3
>>
