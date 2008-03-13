From: Fredric Isaman <iisaman@citi.umich.edu>
Subject: Re: [PATCH] nfs: fix encode_fsinfo_maxsz
Date: Thu, 13 Mar 2008 12:29:06 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0803131227380.29614@citi.umich.edu>
References: <1205414790-1710-1-git-send-email-bhalevy@panasas.com>
 <1205425264.11399.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:12587 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751618AbYCMQ3I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Mar 2008 12:29:08 -0400
In-Reply-To: <1205425264.11399.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Thu, 13 Mar 2008, Trond Myklebust wrote:

>
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
>
> Cheers
>  Trond
>
>

I just noticed it in the process of adding some attributes to fsinfo, as 
opposed to searching down a bug.

 	Fred

