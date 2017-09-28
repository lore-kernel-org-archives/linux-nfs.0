Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50416 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750891AbdI1SzL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 14:55:11 -0400
Date: Thu, 28 Sep 2017 14:55:10 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 05/10] NFSD first draft of async copy
Message-ID: <20170928185509.GI10182@parsley.fieldses.org>
References: <20170928172945.50780-1-kolga@netapp.com>
 <20170928172945.50780-6-kolga@netapp.com>
 <20170928180703.GE10182@parsley.fieldses.org>
 <2E614129-E276-4E80-8A6D-161C1C3019DC@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <2E614129-E276-4E80-8A6D-161C1C3019DC@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 28, 2017 at 02:44:42PM -0400, Olga Kornievskaia wrote:
> 
> > On Sep 28, 2017, at 2:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > On Thu, Sep 28, 2017 at 01:29:40PM -0400, Olga Kornievskaia wrote:
> >> Asynchronous copies are handled by a single threaded workqueue.
> >> If we get asynchronous request, make sure to copy the needed
> >> arguments/state from the stack before starting the copy. Then
> >> queue work and reply back to the client indicating copy is
> >> asynchronous.
> >> 
> >> nfsd_copy_file_range() will copy in 4MBchunk so do a loop over
> >> the total number of bytes need to copy.
> > 
> > I don't think you need to do this--just call vfs_copy_file_range()
> > directly, as nfsd_copy_file_range does.
> > 
> > The 4MB chunking was only there to prevent a synchronous copy from
> > taking too long, which isn't an issue in the async case.
> > 
> 
> One reason is to allow for the copy to be cancelled in the “middle”.
> Otherwise, we have no control over once we call into the vfs_copy_file_range
> to stop the on-going copy. At least this way we check every 4MB chunks.

Yes, see my other email, I think we should signal the thread to stop it.

Even with copying in chunks--we'd like to be able to cancel the copy
mid-chunk.

Talking this over here with Jeff and Trond.... I don't *think* there's
an easy way to cancel a long-running work item.

So probably you want to create your own thread for the copy instead.  It
looks like kthread_create/kthread_stop/kthread_should_stop are what you
want?  You can see some examples if you "git grep kthread net/sunrpc".

--b.

> 
> > --b.
> > 
> >> In case a failure
> >> happens in the middle, we can return an error as well as how
> >> much we copied so far. Once done creating a workitem for the
> >> callback workqueue and send CB_OFFLOAD with the results.
> >> 
> >> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> >> ---
> >> fs/nfsd/nfs4proc.c  | 164 ++++++++++++++++++++++++++++++++++++++++++++++------
> >> fs/nfsd/nfs4state.c |   9 ++-
> >> fs/nfsd/state.h     |   2 +
> >> fs/nfsd/xdr4.h      |   7 +++
> >> 4 files changed, 162 insertions(+), 20 deletions(-)
> >> 
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index 11ade90..de21b1a 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -76,6 +76,21 @@
> >> { }
> >> #endif
> >> 
> >> +static struct workqueue_struct *copy_wq;
> >> +
> >> +int nfsd4_create_copy_queue(void)
> >> +{
> >> +	copy_wq = create_singlethread_workqueue("nfsd4_copy");
> >> +	if (!copy_wq)
> >> +		return -ENOMEM;
> >> +	return 0;
> >> +}
> >> +
> >> +void nfsd4_destroy_copy_queue(void)
> >> +{
> >> +	destroy_workqueue(copy_wq);
> >> +}
> >> +
> >> #define NFSDDBG_FACILITY		NFSDDBG_PROC
> >> 
> >> static u32 nfsd_attrmask[] = {
> >> @@ -1085,37 +1100,148 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
> >> out:
> >> 	return status;
> >> }
> >> +static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
> >> +{
> >> +	struct nfsd4_copy *copy = container_of(cb, struct nfsd4_copy, cp_cb);
> >> +
> >> +	kfree(copy);
> >> +}
> >> +
> >> +static int nfsd4_cb_offload_done(struct nfsd4_callback *cb,
> >> +				 struct rpc_task *task)
> >> +{
> >> +	return 1;
> >> +}
> >> +
> >> +static const struct nfsd4_callback_ops nfsd4_cb_offload_ops = {
> >> +	.release = nfsd4_cb_offload_release,
> >> +	.done = nfsd4_cb_offload_done
> >> +};
> >> +
> >> +static int nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
> >> +{
> >> +	memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
> >> +		sizeof(copy->cp_dst_stateid));
> >> +	copy->cp_res.wr_stable_how = NFS_UNSTABLE;
> >> +	copy->cp_consecutive = 1;
> >> +	copy->cp_synchronous = sync;
> >> +	gen_boot_verifier(&copy->cp_res.wr_verifier, copy->net);
> >> +
> >> +	return nfs_ok;
> >> +}
> >> +
> >> +static int _nfsd_copy_file_range(struct nfsd4_copy *copy)
> >> +{
> >> +	ssize_t bytes_copied = 0;
> >> +	size_t bytes_total = copy->cp_count;
> >> +	size_t bytes_to_copy;
> >> +	u64 src_pos = copy->cp_src_pos;
> >> +	u64 dst_pos = copy->cp_dst_pos;
> >> +
> >> +	do {
> >> +		bytes_to_copy = min_t(u64, bytes_total, MAX_RW_COUNT);
> >> +		bytes_copied = nfsd_copy_file_range(copy->fh_src, src_pos,
> >> +					copy->fh_dst, dst_pos, bytes_to_copy);
> >> +		if (bytes_copied <= 0)
> >> +			break;
> >> +		bytes_total -= bytes_copied;
> >> +		copy->cp_res.wr_bytes_written += bytes_copied;
> >> +		src_pos += bytes_copied;
> >> +		dst_pos += bytes_copied;
> >> +	} while (bytes_total > 0 && !copy->cp_synchronous);
> >> +	return bytes_copied;
> >> +}
> >> +
> >> +static int nfsd4_do_copy(struct nfsd4_copy *copy, bool sync)
> >> +{
> >> +	__be32 status;
> >> +	ssize_t bytes;
> >> +
> >> +	bytes = _nfsd_copy_file_range(copy);
> >> +	if (bytes < 0)
> >> +		status = nfserrno(bytes);
> >> +	else
> >> +		status = nfsd4_init_copy_res(copy, sync);
> >> +
> >> +	fput(copy->fh_src);
> >> +	fput(copy->fh_dst);
> >> +	return status;
> >> +}
> >> +
> >> +static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
> >> +{
> >> +	memcpy(&dst->cp_src_stateid, &src->cp_src_stateid, sizeof(stateid_t));
> >> +	memcpy(&dst->cp_dst_stateid, &src->cp_dst_stateid, sizeof(stateid_t));
> >> +	dst->cp_src_pos = src->cp_src_pos;
> >> +	dst->cp_dst_pos = src->cp_dst_pos;
> >> +	dst->cp_count = src->cp_count;
> >> +	dst->cp_consecutive = src->cp_consecutive;
> >> +	dst->cp_synchronous = src->cp_synchronous;
> >> +	memcpy(&dst->cp_res, &src->cp_res, sizeof(src->cp_res));
> >> +	/* skipping nfsd4_callback */
> >> +	memcpy(&dst->fh, &src->fh, sizeof(src->fh));
> >> +	dst->fh = src->fh;
> >> +	dst->cp_clp = src->cp_clp;
> >> +	dst->fh_src = src->fh_src;
> >> +	dst->fh_dst = src->fh_dst;
> >> +	dst->net = src->net;
> >> +}
> >> +
> >> +static void nfsd4_do_async_copy(struct work_struct *work)
> >> +{
> >> +	struct nfsd4_copy *copy =
> >> +		container_of(work, struct nfsd4_copy, cp_work);
> >> +	struct nfsd4_copy *cb_copy;
> >> +
> >> +	copy->nfserr = nfsd4_do_copy(copy, 0);
> >> +	cb_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
> >> +	if (!cb_copy)
> >> +		goto out;
> >> +	memcpy(&cb_copy->cp_res, &copy->cp_res, sizeof(copy->cp_res));
> >> +	cb_copy->cp_clp = copy->cp_clp;
> >> +	cb_copy->nfserr = copy->nfserr;
> >> +	memcpy(&cb_copy->fh, &copy->fh, sizeof(copy->fh));
> >> +	nfsd4_init_cb(&cb_copy->cp_cb, cb_copy->cp_clp,
> >> +			&nfsd4_cb_offload_ops, NFSPROC4_CLNT_CB_OFFLOAD);
> >> +	nfsd4_run_cb(&cb_copy->cp_cb);
> >> +out:
> >> +	kfree(copy);
> >> +}
> >> 
> >> static __be32
> >> nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >> 		union nfsd4_op_u *u)
> >> {
> >> 	struct nfsd4_copy *copy = &u->copy;
> >> -	struct file *src, *dst;
> >> 	__be32 status;
> >> -	ssize_t bytes;
> >> 
> >> -	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid, &src,
> >> -				   &copy->cp_dst_stateid, &dst);
> >> +	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
> >> +				   &copy->fh_src, &copy->cp_dst_stateid,
> >> +				   &copy->fh_dst);
> >> 	if (status)
> >> 		goto out;
> >> 
> >> -	bytes = nfsd_copy_file_range(src, copy->cp_src_pos,
> >> -			dst, copy->cp_dst_pos, copy->cp_count);
> >> -
> >> -	if (bytes < 0)
> >> -		status = nfserrno(bytes);
> >> -	else {
> >> -		copy->cp_res.wr_bytes_written = bytes;
> >> -		copy->cp_res.wr_stable_how = NFS_UNSTABLE;
> >> -		copy->cp_consecutive = 1;
> >> -		copy->cp_synchronous = 1;
> >> -		gen_boot_verifier(&copy->cp_res.wr_verifier, SVC_NET(rqstp));
> >> -		status = nfs_ok;
> >> +	copy->cp_clp = cstate->clp;
> >> +	memcpy(&copy->fh, &cstate->current_fh.fh_handle,
> >> +		sizeof(struct knfsd_fh));
> >> +	copy->net = SVC_NET(rqstp);
> >> +	if (!copy->cp_synchronous) {
> >> +		struct nfsd4_copy *async_copy;
> >> +
> >> +		status = nfsd4_init_copy_res(copy, 0);
> >> +		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
> >> +		if (!async_copy) {
> >> +			status = nfserrno(-ENOMEM);
> >> +			goto out;
> >> +		}
> >> +		dup_copy_fields(copy, async_copy);
> >> +		memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
> >> +			sizeof(copy->cp_dst_stateid));
> >> +		INIT_WORK(&async_copy->cp_work, nfsd4_do_async_copy);
> >> +		queue_work(copy_wq, &async_copy->cp_work);
> >> +	} else {
> >> +		status = nfsd4_do_copy(copy, 1);
> >> 	}
> >> -
> >> -	fput(src);
> >> -	fput(dst);
> >> out:
> >> 	return status;
> >> }
> >> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> >> index 0c04f81..fe6f275 100644
> >> --- a/fs/nfsd/nfs4state.c
> >> +++ b/fs/nfsd/nfs4state.c
> >> @@ -7033,8 +7033,14 @@ static int nfs4_state_create_net(struct net *net)
> >> 		goto out_free_laundry;
> >> 
> >> 	set_max_delegations();
> >> -	return 0;
> >> 
> >> +	ret = nfsd4_create_copy_queue();
> >> +	if (ret)
> >> +		goto out_free_callback;
> >> +
> >> +	return 0;
> >> +out_free_callback:
> >> +	nfsd4_destroy_callback_queue();
> >> out_free_laundry:
> >> 	destroy_workqueue(laundry_wq);
> >> out_cleanup_cred:
> >> @@ -7097,6 +7103,7 @@ static int nfs4_state_create_net(struct net *net)
> >> 	destroy_workqueue(laundry_wq);
> >> 	nfsd4_destroy_callback_queue();
> >> 	cleanup_callback_cred();
> >> +	nfsd4_destroy_copy_queue();
> >> }
> >> 
> >> static void
> >> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> >> index f8b0210..b5358cf 100644
> >> --- a/fs/nfsd/state.h
> >> +++ b/fs/nfsd/state.h
> >> @@ -630,6 +630,8 @@ extern void nfsd4_init_cb(struct nfsd4_callback *cb, struct nfs4_client *clp,
> >> extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
> >> 							struct nfsd_net *nn);
> >> extern bool nfs4_has_reclaimed_state(const char *name, struct nfsd_net *nn);
> >> +extern int nfsd4_create_copy_queue(void);
> >> +extern void nfsd4_destroy_copy_queue(void);
> >> 
> >> struct nfs4_file *find_file(struct knfsd_fh *fh);
> >> void put_nfs4_file(struct nfs4_file *fi);
> >> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> >> index 9b0c099..f7a94d3 100644
> >> --- a/fs/nfsd/xdr4.h
> >> +++ b/fs/nfsd/xdr4.h
> >> @@ -529,6 +529,13 @@ struct nfsd4_copy {
> >> 	struct nfsd4_callback	cp_cb;
> >> 	__be32			nfserr;
> >> 	struct knfsd_fh		fh;
> >> +
> >> +	struct work_struct      cp_work;
> >> +	struct nfs4_client      *cp_clp;
> >> +
> >> +	struct file             *fh_src;
> >> +	struct file             *fh_dst;
> >> +	struct net              *net;
> >> };
> >> 
> >> struct nfsd4_seek {
> >> -- 
> >> 1.8.3.1
> >> 
> 
