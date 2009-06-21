From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/2] nfs41: Move initialization of nfs4_opendata seq_res
 to nfs4_init_opendata_res
Date: Sun, 21 Jun 2009 18:06:45 +0300
Message-ID: <4A3E4C85.7090302@panasas.com>
References: <1245376884-3711-1-git-send-email-bhalevy@panasas.com> <1245523961.5182.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andy Adamson <andros@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:23815
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750895AbZFUPGq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Jun 2009 11:06:46 -0400
In-Reply-To: <1245523961.5182.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 20, 2009, 21:52 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Thu, 2009-06-18 at 22:01 -0400, Benny Halevy wrote:
>> nfs4_open_recover_helper clears opendata->o_res
>> before calling nfs4_init_opendata_res, thus causing
>> NFSv4.0 OPEN operations to be sent rather than nfsv4.1.
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>> Trond, please add these two patches to the nfs41-for-2.6.31 series.
>> Also availble on git://linux-nfs.org/~bhalevy/linux-pnfs.git nfs41-for-2.6.31
>>
>>  fs/nfs/nfs4proc.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 57dabb8..04da834 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -680,6 +680,7 @@ static void nfs4_init_opendata_res(struct nfs4_opendata *p)
>>  	p->o_res.server = p->o_arg.server;
>>  	nfs_fattr_init(&p->f_attr);
>>  	nfs_fattr_init(&p->dir_attr);
>> +	p->o_res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
> 
> This really needs cleaning up. The "magic sr_slotid value"
> initialisation is littering the code, and you have to look _very_
> carefully in order to figure out what NFS4_MAX_SLOT_TABLE actually
> means.
> 
> I'm applying this patch for now, but come 2.6.32, I do expect a
> changeset that gets rid of the sr_slotid magic value in favour of
> something that documents what it is for.

I agree that it is confusing.
I suggest that:
a. we add an helper to initialize struct nfs4_sequence_res
   so that the logic will be implemented in one place rather
   than scattered all over the place.
b. #define NFS4_INVALID_SLOT_ID NFS4_MAX_SLOT_TABLE
   and use as initial value.

Benny

> 
>>  }
>>  
>>  static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
>> @@ -711,7 +712,6 @@ static struct nfs4_opendata *nfs4_opendata_alloc(struct path *path,
>>  	p->o_arg.server = server;
>>  	p->o_arg.bitmask = server->attr_bitmask;
>>  	p->o_arg.claim = NFS4_OPEN_CLAIM_NULL;
>> -	p->o_res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
>>  	if (flags & O_EXCL) {
>>  		u32 *s = (u32 *) p->o_arg.u.verifier.data;
>>  		s[0] = jiffies;
> 
