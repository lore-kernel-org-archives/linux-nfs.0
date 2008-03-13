From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH] nfs: fix encode_fsinfo_maxsz
Date: Thu, 13 Mar 2008 18:27:16 +0200
Message-ID: <47D955E4.5010900@panasas.com>
References: <1205414790-1710-1-git-send-email-bhalevy@panasas.com> <1205425264.11399.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:31494 "EHLO
	cassoulet.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751672AbYCMQ2B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Mar 2008 12:28:01 -0400
In-Reply-To: <1205425264.11399.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Thu, 2008-03-13 at 15:26 +0200, Benny Halevy wrote:
>> From: Fred Isaman <iisaman@citi.umich.edu>
>>
>> The previous value was not taking into account space for bitmap array size.
>>
>> Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4xdr.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 51dd380..0277821 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -110,7 +110,7 @@ static int nfs4_stat_to_errno(int);
>>  #define decode_savefh_maxsz     (op_decode_hdr_maxsz)
>>  #define encode_restorefh_maxsz  (op_encode_hdr_maxsz)
>>  #define decode_restorefh_maxsz  (op_decode_hdr_maxsz)
>> -#define encode_fsinfo_maxsz	(op_encode_hdr_maxsz + 2)
>> +#define encode_fsinfo_maxsz	(encode_getattr_maxsz)
>>  #define decode_fsinfo_maxsz	(op_decode_hdr_maxsz + 11)
>>  #define encode_renew_maxsz	(op_encode_hdr_maxsz + 3)
>>  #define decode_renew_maxsz	(op_decode_hdr_maxsz)
> 
> Thanks!
> 
> Has this ever been observed to cause problems in the mainline NFSv4?
> Having never seen any such problems myself, I'm a bit inclined to delay
> this until the 2.6.26 merge window. That said, if you can point to an
> instance where it caused a bug, then I'll push it to Linus sooner.

I can't point to such an instance.
I *think* it was found by code inspection only.
Maybe Fred can...

Benny

> 
> Cheers
>   Trond
> 

