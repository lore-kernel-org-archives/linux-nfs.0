From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 04/35] pnfsd: return pnfs flags on exchange_id
Date: Tue, 08 Dec 2009 16:46:27 +0200
Message-ID: <4B1E66C3.70907@panasas.com>
References: <4B1CCA52.8020900@panasas.com> <1260178237-14780-1-git-send-email-bhalevy@panasas.com> <20091207195141.GB32454@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Dean Hildebrand <dhildeb@us.ibm.com>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20091207195141.GB32454@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec. 07, 2009, 21:51 +0200, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> On Mon, Dec 07, 2009 at 11:30:37AM +0200, Benny Halevy wrote:
>> Set the cl_exchange_flags to be non_pnfs if we do not set
>> either pnfs or ds (in the plain old nfs41 case).
>>
>> pnfsd: set EXCHGID4_FLAG_USE_NON_PNFS when !CONFIG_PNFSD:
>> EXCHGID4_FLAG_USE_NON_PNFS should be set when the server does not support
>> operations (e.g. LAYOUTGET) or attributes that pertain to pNFS.
>>
>> [extraced from pnfsd: Initial pNFS server implementation.]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> [pnfsd: Fixup nfsd4_set_ex_flags.]
>> Signed-off-by: Dean Hildebrand <dhildeb@us.ibm.com>
>> [pnfsd: set EXCHGID4_FLAG_USE_NON_PNFS when !CONFIG_PNFSD]
>> [pnfsd: fix compiler warning in nfsd4_set_ex_flags when CONFIG_PNFSD is not defined]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfsd/nfs4state.c |   15 +++++++++++++++
>>  1 files changed, 15 insertions(+), 0 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 2923e6c..9ecbc25 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1098,8 +1098,23 @@ nfsd4_replay_cache_entry(struct nfsd4_compoundres *resp,
>>  static void
>>  nfsd4_set_ex_flags(struct nfs4_client *new, struct nfsd4_exchange_id *clid)
>>  {
>> +#if defined(CONFIG_PNFSD)
>> +	int mds_and_ds = EXCHGID4_FLAG_USE_PNFS_MDS | EXCHGID4_FLAG_USE_PNFS_DS;
>> +	int mds_or_ds = 0;
> 
> initialization isn't used.
> 
>> +
>> +	/* Save the client's MDS or DS flags, or set them both.
>> +	 * XXX We currently do not have a method of determining
>> +	 * what a server supports prior to receiving a filehandle
>> +	 * e.g. at exchange id time. */
>> +	mds_or_ds = clid->flags & mds_and_ds;
>> +	if (mds_or_ds)
>> +		new->cl_exchange_flags |= mds_or_ds;
>> +	else
>> +		new->cl_exchange_flags |= mds_and_ds;
> 
> Why do we need to do this?  If the fact is that we're going to accept
> either DS or MDS traffic over this session, let's just always set both
> flags.  That doesn't stop the client from dedicating sessions to one or
> the other use if that's what it wants.

The original motivation come from the client side who treats DSs differently
than MDSs with regards to renewing the lease.
If we return both flags set unconditionally, then the client will need
to remember internally what it uses the server for - an MDS or a DS.

Something along these lines (needs testing):

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 128715a..cb8ae88 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -272,6 +272,9 @@ nfs4_pnfs_ds_create(struct nfs_server *mds_srv, struct nfs4_pnfs_ds *ds)
 	if (err)
 		goto out_put;
 
+	/* mask out the server's MDS capability flag */
+	clp->cl_exchange_flags |= EXCHGID4_FLAG_USE_PNFS_DS;
+
 	if (!(clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_DS)) {
 		printk(KERN_INFO "ip:port %s is not a pNFS Data Server\n",
 			ds->r_addr);


Benny

> 
>> +#else  /* CONFIG_PNFSD */
>>  	/* pNFS is not supported */
>>  	new->cl_exchange_flags |= EXCHGID4_FLAG_USE_NON_PNFS;
>> +#endif /* CONFIG_PNFSD */
> 
> The ifdef should be easy enough to hide in the usual way, with a
> conditionally defined
> 
> 	new->cl_exchange_flags |= get_pnfs_flags(clid->flags)
> 
> (or something to that effect).
> 
> --b.
> 
>>  
>>  	/* Referrals are supported, Migration is not. */
>>  	new->cl_exchange_flags |= EXCHGID4_FLAG_SUPP_MOVED_REFER;
>> -- 
>> 1.6.5.1
>>
