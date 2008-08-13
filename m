From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 7/7] nfsd: nfs4xdr decode_stateid helper function
Date: Wed, 13 Aug 2008 10:31:54 +0300
Message-ID: <48A28DEA.5060406@panasas.com>
References: <48A1CB0C.4090906@panasas.com> <1218563178-25480-1-git-send-email-bhalevy@panasas.com> <20080812190410.GC30729@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:9294 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751871AbYHMHcV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 03:32:21 -0400
In-Reply-To: <20080812190410.GC30729@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 12, 2008, 22:04 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Tue, Aug 12, 2008 at 08:46:18PM +0300, Benny Halevy wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4xdr.c |   99 +++++++++++++++++++++++++++++-----------------------
>>  1 files changed, 55 insertions(+), 44 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 47ac498..9570b1b 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>>  static __be32
>> @@ -929,9 +939,10 @@ nfsd4_decode_write(struct nfsd4_compoundargs *argp, struct nfsd4_write *write)
>>  	int len;
>>  	DECODE_HEAD;
>>  
>> -	READ_BUF(sizeof(stateid_opaque_t) + 20);
>> -	READ32(write->wr_stateid.si_generation);
>> -	COPYMEM(&write->wr_stateid.si_opaque, sizeof(stateid_opaque_t));
>> +	status = nfsd4_decode_stateid(argp, &write->wr_stateid);
>> +	if (status)
>> +		return status;
>> +	READ_BUF(16);
> 
> How did that 20 become a 16?

It was sizeof(stateid_opaque_t) + 20 == sizeof(stateid_t) - 4 + 20 ==
sizeof(stateid_t) + 16.

> 
> OK, I guess this is another case of a preexisting arithmetic error.
> Anywhere that error would have had immediate consequences, but here
> thanks to the hand-coded write-data decoding, the incorrect argp->p
> isn't used except to check that there's space for the incoming data.
> And previously that check was more pessimistic than necessary.

Oddly enough, the hand coded calculation was fine, as shown above...
Note that the remaining 16 bytes correspond to one READ64
and two READ32s.

Benny

> 
> --b.
> 
>>  	READ64(write->wr_offset);
>>  	READ32(write->wr_stable_how);
>>  	if (write->wr_stable_how > 2)
>> -- 
>> 1.5.6.5
>>
