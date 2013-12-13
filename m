Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f51.google.com ([209.85.160.51]:35475 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab3LMBTI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Dec 2013 20:19:08 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so1536252pbc.24
        for <linux-nfs@vger.kernel.org>; Thu, 12 Dec 2013 17:19:08 -0800 (PST)
Message-ID: <52AA604F.3090201@gmail.com>
Date: Fri, 13 Dec 2013 09:18:07 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: make calculate  reserved space correctly
References: <52A5AA09.4030409@gmail.com> <20131212162452.GG11521@fieldses.org>
In-Reply-To: <20131212162452.GG11521@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/13/2013 12:24 AM, J. Bruce Fields wrote:
> On Mon, Dec 09, 2013 at 07:31:21PM +0800, Kinglong Mee wrote:
>> rpcsec_gss_oid is defined as below, So, must using XDR_LEN to calculate reserved space.
>> When len is not the multiples of 4, client will get bad data.
> 
> Looking at the definition of RESERVE_SPACE: first, it doesn't actually
> advance any pointers, all it does is an overflow check, so there
> shouldn't be data corruption unless we're at the end of a page (which
> shouldn't happen here).  Second, RESERVE_SPACE actually rounds up for
> is, so we wouldn't hit that problem anyway.

Yes.

> 
> Nevertheless, agreed that it's probably good practice to round up here
> as well.

Thank you.

thanks,
Kinglong Mee

> 
> --b.
> 
>>
>> struct rpcsec_gss_oid {
>>         unsigned int    len;
>>         u8              data[GSS_OID_MAX_LEN];
>> };
>>
>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
>> ---
>>  fs/nfsd/nfs4xdr.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index b0b886e..a57e67d 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -3233,7 +3233,7 @@ nfsd4_do_encode_secinfo(struct nfsd4_compoundres *resp,
>>  
>>  		if (rpcauth_get_gssinfo(pf, &info) == 0) {
>>  			supported++;
>> -			RESERVE_SPACE(4 + 4 + info.oid.len + 4 + 4);
>> +			RESERVE_SPACE(4 + 4 + XDR_LEN(info.oid.len) + 4 + 4);
>>  			WRITE32(RPC_AUTH_GSS);
>>  			WRITE32(info.oid.len);
>>  			WRITEMEM(info.oid.data, info.oid.len);
>> -- 
>> 1.8.4.2
> 

