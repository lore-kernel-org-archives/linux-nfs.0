Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:55525 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757432Ab1EKQUO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 May 2011 12:20:14 -0400
Message-ID: <4DCAB73B.4040700@netapp.com>
Date: Wed, 11 May 2011 12:20:11 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFSD: Added TEST_STATEID opreation
References: <1304708255-20464-1-git-send-email-bjschuma@netapp.com> <1304708255-20464-3-git-send-email-bjschuma@netapp.com> <20110510004951.GC3600@fieldses.org>
In-Reply-To: <20110510004951.GC3600@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/09/2011 08:49 PM, J. Bruce Fields wrote:
> On Fri, May 06, 2011 at 02:57:35PM -0400, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> This operation is used by the client to check the validity of a list of
>> stateids.
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>>  fs/nfsd/nfs4proc.c  |    5 ++
>>  fs/nfsd/nfs4state.c |   66 ++++++++++++++++++++++++++
>>  fs/nfsd/nfs4xdr.c   |  128 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>>  fs/nfsd/xdr4.h      |   21 ++++++++
>>  4 files changed, 218 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 7e00116..a856f30 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1412,6 +1412,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
>>  		.op_flags = OP_HANDLES_WRONGSEC,
>>  		.op_name = "OP_SECINFO_NO_NAME",
>>  	},
>> +	[OP_TEST_STATEID] = {
>> +		.op_func = (nfsd4op_func)nfsd4_test_stateid,
>> +		.op_flags = ALLOWED_WITHOUT_FH,
>> +		.op_name = "OP_TEST_STATEID",
>> +	},
>>  	[OP_FREE_STATEID] = {
>>  		.op_func = (nfsd4op_func)nfsd4_free_stateid,
>>  		.op_flags = ALLOWED_WITHOUT_FH,
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 6beec13..c7bb3ce 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -37,6 +37,7 @@
>>  #include <linux/slab.h>
>>  #include <linux/namei.h>
>>  #include <linux/swap.h>
>> +#include <linux/pagemap.h>
>>  #include <linux/sunrpc/svcauth_gss.h>
>>  #include <linux/sunrpc/clnt.h>
>>  #include "xdr4.h"
>> @@ -3140,6 +3141,35 @@ static int is_delegation_stateid(stateid_t *stateid)
>>  	return stateid->si_fileid == 0;
>>  }
>>  
>> +static __be32 nfs4_validate_stateid(stateid_t *stateid, int flags, struct file **filpp, struct svc_fh *current_fh)
>> +{
>> +	struct nfs4_stateid *stp = NULL;
>> +	__be32 status = nfserr_stale_stateid;
>> +
>> +	if (STALE_STATEID(stateid))
>> +		goto out;
>> +
>> +	status = nfserr_expired;
>> +	stp = search_for_stateid(stateid);
>> +	if (!stp)
>> +		goto out;
>> +	status = nfserr_bad_stateid;
>> +
>> +	if (!stp->st_stateowner->so_confirmed)
>> +		goto out;
>> +
>> +	status = check_stateid_generation(stateid, &stp->st_stateid, flags);
>> +	if (status)
>> +		goto out;
>> +
>> +	status = nfs4_check_openmode(stp, flags);
> 
> It doesn't make sense to be doing openmode checks here, since
> test_stateid doesn't check whether a stateid could be used for read or
> write.  (And OPENMODE isn't a legal return value for test_stateid.)

Ok, I'll remove this check.

> 
>> +	if (status)
>> +		goto out;
>> +	status = nfs_ok;
>> +out:
>> +	return status;
>> +}
>> +
>>  /*
>>  * Checks for stateid operations
>>  */
>> @@ -3220,6 +3250,42 @@ out:
>>  }
>>  
>>  /*
>> + * Test if the stateid is valid
>> + */
>> +__be32
>> +nfsd4_test_stateid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> +		   struct nfsd4_test_stateid *test_stateid)
>> +{
>> +	stateid_t *stateid = NULL;
>> +	int *resp = NULL;
>> +	struct svc_fh *current_fh;
>> +	unsigned int cur_id_page = 0;
>> +	unsigned int cur_resp_page = 0;
>> +	int i;
>> +	unsigned int lock_flags = LOCK_STATE | RD_STATE | WR_STATE;
>> +	unsigned int open_flags = OPEN_STATE | RD_STATE | WR_STATE;
>> +
>> +	current_fh = &cstate->current_fh;
>> +
>> +	for (i = 0; i < test_stateid->ts_num_ids; i++) {
>> +		if ((i % test_stateid->ts_stateids->items_per_page) == 0) {
>> +			stateid = (stateid_t *)test_stateid->ts_stateids->items[cur_id_page].first_item;
>> +			cur_id_page++;
>> +		}
>> +		if ((i % test_stateid->ts_valid->items_per_page) == 0) {
>> +			resp = (int *)test_stateid->ts_valid->items[cur_resp_page].first_item;
>> +			cur_resp_page++;
>> +		}
>> +		*resp = nfs4_validate_stateid(stateid, lock_flags, NULL, current_fh);
>> +		if (!*resp)
>> +			*resp = nfs4_validate_stateid(stateid, open_flags, NULL, current_fh);
>> +		stateid++;
>> +		resp++;
>> +	}
>> +	return nfs_ok;
>> +}
>> +
>> +/*
>>   * Free a state id
>>   */
>>  __be32
>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>> index 5da6874..c92c4d2 100644
>> --- a/fs/nfsd/nfs4xdr.c
>> +++ b/fs/nfsd/nfs4xdr.c
>> @@ -44,6 +44,7 @@
>>  #include <linux/namei.h>
>>  #include <linux/statfs.h>
>>  #include <linux/utsname.h>
>> +#include <linux/pagemap.h>
>>  #include <linux/sunrpc/svcauth_gss.h>
>>  
>>  #include "idmap.h"
>> @@ -1274,6 +1275,98 @@ nfsd4_decode_sequence(struct nfsd4_compoundargs *argp,
>>  	DECODE_TAIL;
>>  }
>>  
>> +static void
>> +nfsd4_free_ts_pagearray(struct nfsd4_ts_pagearray *array)
>> +{
>> +	unsigned int i;
>> +	struct page *page;
>> +	for (i = 0; i < array->num_pages; i++) {
>> +		kunmap(array->items[i].page);
>> +		put_page(array->items[i].page);
>> +	}
>> +	page = array->page_ptr;
>> +	put_page(page);
>> +}
>> +
>> +static struct nfsd4_ts_pagearray *
>> +nfsd4_alloc_ts_pagearray(struct nfsd4_test_stateid *test_stateid, unsigned int item_size)
>> +{
>> +	unsigned int num_pages;
>> +	struct nfsd4_ts_pagearray *array;
>> +	struct page *page;
>> +	int i = 0;
>> +
>> +	page = alloc_page(GFP_KERNEL);
>> +	if (page == NULL)
>> +		goto out_nomem;
>> +
>> +	array = kmap(page);
>> +	array->num_pages = 0;
>> +	array->items_per_page = PAGE_SIZE / item_size;
>> +	array->page_ptr  = page;
>> +
>> +	num_pages = ((test_stateid->ts_num_ids * item_size) / PAGE_SIZE) + 1;
>> +
>> +	for (i = 0; i < num_pages; i++) {
>> +		page = alloc_page(GFP_KERNEL);
>> +		if (page == NULL)
>> +			goto out_freepages;
>> +		array->items[i].page = page;
>> +		array->items[i].first_item = kmap(page);
>> +		array->num_pages += 1;
>> +	}
>> +	return array;
>> +
>> +out_freepages:
>> +	nfsd4_free_ts_pagearray(array);
>> +out_nomem:
>> +	return ERR_PTR(-ENOMEM);
>> +}
>> +
>> +static __be32
>> +nfsd4_decode_test_stateid(struct nfsd4_compoundargs *argp, struct nfsd4_test_stateid *test_stateid)
>> +{
>> +	stateid_t * si = NULL;
>> +	unsigned int cur_page = 0;
>> +	struct page *page;
>> +	int i;
>> +
>> +	DECODE_HEAD;
>> +	READ_BUF(4);
>> +	READ32(test_stateid->ts_num_ids);
> 
> Surely we need some sort of sanity-check on the size of that thing?
> Otherwise the num_pages calculation above can overflow and weird stuff
> happens.

Good point.  I'll add this in.

> 
>> +
>> +	test_stateid->ts_stateids = nfsd4_alloc_ts_pagearray(test_stateid, sizeof(stateid_t));
>> +	if (IS_ERR(test_stateid->ts_stateids))
>> +		return PTR_ERR(test_stateid->ts_stateids);
>> +
>> +	test_stateid->ts_valid = nfsd4_alloc_ts_pagearray(test_stateid, sizeof(int));
> 
> Will this be freed in every case?  I guess you're assuming the encode
> function will be called whenever the decode succeeds.  Off the top of my
> head, I don't think that's true if xdr decoding of a later op fails.

That was what I was assuming.  What is the best way to free this if a later decode fails?  something in nfsd4_proc_compound()?

> 
> --b.
> 
>> +	if (IS_ERR(test_stateid->ts_valid)) {
>> +		status = PTR_ERR(test_stateid->ts_valid);
>> +		goto out_free_pages;
>> +	}
>> +
>> +	/* Read in a list of stateids provided by the client */
>> +	for (i = 0; i < test_stateid->ts_num_ids; i++) {
>> +		if ((i % test_stateid->ts_stateids->items_per_page) == 0) {
>> +			si = test_stateid->ts_stateids->items[cur_page].first_item;
>> +			cur_page++;
>> +		}
>> +		nfsd4_decode_stateid(argp, si);
>> +		si++;
>> +	}
>> +	kunmap(page);
>> +	status = 0;
>> +out:
>> +	return status;
>> +xdr_error:
>> +	dprintk("NFSD: xdr error (%s:%d)\n", __FILE__, __LINE__);
>> +	status = nfserr_bad_xdr;
>> +	nfsd4_free_ts_pagearray(test_stateid->ts_valid);
>> +out_free_pages:
>> +	nfsd4_free_ts_pagearray(test_stateid->ts_stateids);
>> +	goto out;
>> +}
>> +
>>  static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, struct nfsd4_reclaim_complete *rc)
>>  {
>>  	DECODE_HEAD;
>> @@ -1393,7 +1486,7 @@ static nfsd4_dec nfsd41_dec_ops[] = {
>>  	[OP_SECINFO_NO_NAME]	= (nfsd4_dec)nfsd4_decode_secinfo_no_name,
>>  	[OP_SEQUENCE]		= (nfsd4_dec)nfsd4_decode_sequence,
>>  	[OP_SET_SSV]		= (nfsd4_dec)nfsd4_decode_notsupp,
>> -	[OP_TEST_STATEID]	= (nfsd4_dec)nfsd4_decode_notsupp,
>> +	[OP_TEST_STATEID]	= (nfsd4_dec)nfsd4_decode_test_stateid,
>>  	[OP_WANT_DELEGATION]	= (nfsd4_dec)nfsd4_decode_notsupp,
>>  	[OP_DESTROY_CLIENTID]	= (nfsd4_dec)nfsd4_decode_notsupp,
>>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_dec)nfsd4_decode_reclaim_complete,
>> @@ -3166,6 +3259,37 @@ nfsd4_encode_sequence(struct nfsd4_compoundres *resp, int nfserr,
>>  	return 0;
>>  }
>>  
>> +__be32
>> +nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, int nfserr,
>> +			  struct nfsd4_test_stateid *test_stateid)
>> +{
>> +	__be32 *p;
>> +	unsigned int i;
>> +	unsigned int cur_page = 0;
>> +	int *valid = NULL;
>> +
>> +	if (!nfserr) {
>> +		RESERVE_SPACE(4);
>> +		WRITE32(test_stateid->ts_num_ids);
>> +		ADJUST_ARGS();
>> +
>> +		for (i = 0; i < test_stateid->ts_num_ids; i++) {
>> +			if ((i % test_stateid->ts_valid->items_per_page) == 0) {
>> +				valid = (int *)test_stateid->ts_valid->items[cur_page].first_item;
>> +				cur_page++;
>> +			}
>> +			RESERVE_SPACE(4);
>> +			WRITE32(*valid);
>> +			ADJUST_ARGS();
>> +			valid++;
>> +		}
>> +	}
>> +
>> +	nfsd4_free_ts_pagearray(test_stateid->ts_valid);
>> +	nfsd4_free_ts_pagearray(test_stateid->ts_stateids);
>> +	return nfserr;
>> +}
>> +
>>  static __be32
>>  nfsd4_encode_noop(struct nfsd4_compoundres *resp, __be32 nfserr, void *p)
>>  {
>> @@ -3234,7 +3358,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
>>  	[OP_SECINFO_NO_NAME]	= (nfsd4_enc)nfsd4_encode_secinfo_no_name,
>>  	[OP_SEQUENCE]		= (nfsd4_enc)nfsd4_encode_sequence,
>>  	[OP_SET_SSV]		= (nfsd4_enc)nfsd4_encode_noop,
>> -	[OP_TEST_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
>> +	[OP_TEST_STATEID]	= (nfsd4_enc)nfsd4_encode_test_stateid,
>>  	[OP_WANT_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
>>  	[OP_DESTROY_CLIENTID]	= (nfsd4_enc)nfsd4_encode_noop,
>>  	[OP_RECLAIM_COMPLETE]	= (nfsd4_enc)nfsd4_encode_noop,
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index ed1784d..0455f55 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -342,6 +342,24 @@ struct nfsd4_setclientid_confirm {
>>  	nfs4_verifier	sc_confirm;
>>  };
>>  
>> +struct nfsd4_ts_pagearray_item {
>> +	struct page *page;
>> +	void *first_item;
>> +};
>> +
>> +struct nfsd4_ts_pagearray {
>> +	unsigned int num_pages;
>> +	unsigned int items_per_page;
>> +	struct page *page_ptr;
>> +	struct nfsd4_ts_pagearray_item items[0];
>> +};
>> +
>> +struct nfsd4_test_stateid {
>> +	__be32		ts_num_ids;             /* request */
>> +	struct nfsd4_ts_pagearray *ts_stateids; /* request */
>> +	struct nfsd4_ts_pagearray *ts_valid;    /* response */
>> +};
>> +
>>  struct nfsd4_free_stateid {
>>  	stateid_t	fr_stateid;         /* request */
>>  	__be32		fr_status;          /* response */
>> @@ -437,6 +455,7 @@ struct nfsd4_op {
>>  		struct nfsd4_destroy_session	destroy_session;
>>  		struct nfsd4_sequence		sequence;
>>  		struct nfsd4_reclaim_complete	reclaim_complete;
>> +		struct nfsd4_test_stateid	test_stateid;
>>  		struct nfsd4_free_stateid	free_stateid;
>>  	} u;
>>  	struct nfs4_replay *			replay;
>> @@ -570,6 +589,8 @@ extern __be32 nfsd4_delegreturn(struct svc_rqst *rqstp,
>>  		struct nfsd4_compound_state *, struct nfsd4_delegreturn *dr);
>>  extern __be32 nfsd4_renew(struct svc_rqst *rqstp,
>>  			  struct nfsd4_compound_state *, clientid_t *clid);
>> +extern __be32 nfsd4_test_stateid(struct svc_rqst *rqstp,
>> +		struct nfsd4_compound_state *, struct nfsd4_test_stateid *test_stateid);
>>  extern __be32 nfsd4_free_stateid(struct svc_rqst *rqstp,
>>  		struct nfsd4_compound_state *, struct nfsd4_free_stateid *free_stateid);
>>  #endif
>> -- 
>> 1.7.5.1
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

