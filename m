From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 05/35] pnfsd: don't set up back channel on	create_session
 for ds
Date: Tue, 08 Dec 2009 16:50:46 +0200
Message-ID: <4B1E67C6.5060401@panasas.com>
References: <4B1CCA52.8020900@panasas.com> <1260178251-14816-1-git-send-email-bhalevy@panasas.com> <20091207201038.GC32454@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org,
	Dean Hildebrand <seattleplus@gmail.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20091207201038.GC32454@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec. 07, 2009, 22:10 +0200, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> On Mon, Dec 07, 2009 at 11:30:51AM +0200, Benny Halevy wrote:
>> From: Dean Hildebrand <seattleplus@gmail.com>
>>
>> [was pnfsd: Add use of pnfs exchange flags]
>> Should this code be surrounded by CONFIG_PNFSD?
> 
> Might be nice, but I suppose it's not important.
> 
>> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4state.c |    4 ++++
>>  1 files changed, 4 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 9ecbc25..dc9d553 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1349,6 +1349,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>>  		cr_ses->flags &= ~SESSION4_PERSIST;
>>  		cr_ses->flags &= ~SESSION4_RDMA;
>>  
>> +		if (!(unconf->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS) &&
>> +		    (unconf->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS))
>> +			cr_ses->flags &= ~SESSION4_BACK_CHAN;
>> +
> 
> Might be easier to read as:
> 
> 	if (is_ds_only_session(unconf))
> 		cr_ses->flags &= ~SESSION4_BACK_CHAN;
> 
> with is_ds_only_session() defined in the obvious way.

Yeah.  Actually we have exchgid_is_ds_only() defined for the client
as follows:

static inline bool exchgid_is_ds_only(struct nfs_client *clp)
{
	u32 mask = EXCHGID4_FLAG_USE_PNFS_DS | EXCHGID4_FLAG_USE_PNFS_MDS;

	return (clp->cl_exchange_flags & mask) == EXCHGID4_FLAG_USE_PNFS_DS;
}

we can define it as common code working on the exchange flags
rather than on the high level client structure...

Benny

> 
> --b.
> 
>>  		if (cr_ses->flags & SESSION4_BACK_CHAN) {
>>  			unconf->cl_cb_xprt = rqstp->rq_xprt;
>>  			svc_xprt_get(unconf->cl_cb_xprt);
>> -- 
>> 1.6.5.1
>>
