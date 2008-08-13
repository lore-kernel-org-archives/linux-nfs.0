From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 4/7] nfsd: nfs4xdr encode_stateid helper function
Date: Wed, 13 Aug 2008 10:27:37 +0300
Message-ID: <48A28CE9.3080400@panasas.com>
References: <48A1CB0C.4090906@panasas.com> <1218563107-25393-1-git-send-email-bhalevy@panasas.com> <20080812183941.GB30729@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-colo-pa.panasas.com ([66.238.117.130]:13976 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751486AbYHMH2H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Aug 2008 03:28:07 -0400
In-Reply-To: <20080812183941.GB30729@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug. 12, 2008, 21:39 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Tue, Aug 12, 2008 at 08:45:07PM +0300, Benny Halevy wrote:
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4xdr.c |   76 ++++++++++++++++++++++------------------------------
>>  1 files changed, 32 insertions(+), 44 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 4ec52f9..96da1aa 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
> ...
>> @@ -2083,12 +2091,9 @@ nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lo
>>  {
>>  	ENCODE_SEQID_OP_HEAD;
>>  
>> -	if (!nfserr) {
>> -		RESERVE_SPACE(4 + sizeof(stateid_t));
> 
> Hm, so that was a little over before (a harmless error, but better to
> have it fixed).

True.  I can add a preliminary patch fixing that.

Benny

> 
> --b.
> 
>> -		WRITE32(lock->lk_resp_stateid.si_generation);
>> -		WRITEMEM(&lock->lk_resp_stateid.si_opaque, sizeof(stateid_opaque_t));
>> -		ADJUST_ARGS();
