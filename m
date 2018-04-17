Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:48516 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751878AbeDQSJC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Apr 2018 14:09:02 -0400
Content-Type: text/plain;
        charset=utf-8
MIME-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: [PATCH v8 7/9] NFSD handle OFFLOAD_CANCEL op
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <f854e802-bb9f-568c-53c8-85831d4b7ce3@gmail.com>
Date: Tue, 17 Apr 2018 14:08:53 -0400
CC: <bfields@redhat.com>, <linux-nfs@vger.kernel.org>
Message-ID: <0423AF4E-E5F9-4AB7-B82E-B6CCF707A72F@netapp.com>
References: <20180413170158.17589-1-kolga@netapp.com>
 <20180413170158.17589-8-kolga@netapp.com>
 <f854e802-bb9f-568c-53c8-85831d4b7ce3@gmail.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Apr 17, 2018, at 2:06 PM, Anna Schumaker <schumaker.anna@gmail.com> =
wrote:
>=20
> Hi Olga,
>=20
> On 04/13/2018 01:01 PM, Olga Kornievskaia wrote:
>> Upon receiving OFFLOAD_CANCEL search the list of copy stateids,
>> if found then set the SIGPENDING signal so that do_splice stops
>> copying and also send kthread_stop to the copy thread to stop
>> and wait for it. Take a reference on the copy from the
>> offload_cancel thread so that it won't go away while we are
>> trying to process it.
>>=20
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>> fs/nfsd/nfs4proc.c | 40 +++++++++++++++++++++++++++++++++++++---
>> fs/nfsd/state.h    |  1 +
>> fs/nfsd/xdr4.h     |  1 +
>> 3 files changed, 39 insertions(+), 3 deletions(-)
>>=20
>> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
>> index 9d5f0d0..cebc087 100644
>> --- a/fs/nfsd/nfs4proc.c
>> +++ b/fs/nfsd/nfs4proc.c
>> @@ -1100,11 +1100,19 @@ static int fill_in_write_vector(struct kvec =
*vec, struct nfsd4_write *write)
>> out:
>> 	return status;
>> }
>> +
>> +void nfs4_put_copy(struct nfsd4_copy *copy)
>> +{
>> +	if (!refcount_dec_and_test(&copy->refcount))
>> +		return;
>> +	kfree(copy);
>> +}
>> +
>> static void nfsd4_cb_offload_release(struct nfsd4_callback *cb)
>> {
>> 	struct nfsd4_copy *copy =3D container_of(cb, struct nfsd4_copy, =
cp_cb);
>>=20
>> -	kfree(copy);
>> +	nfs4_put_copy(copy);
>> }
>>=20
>> static int nfsd4_cb_offload_done(struct nfsd4_callback *cb,
>> @@ -1135,6 +1143,8 @@ static ssize_t _nfsd_copy_file_range(struct =
nfsd4_copy *copy)
>> 	u64 dst_pos =3D copy->cp_dst_pos;
>>=20
>> 	do {
>> +		if (signalled() || kthread_should_stop())
>> +			break;
>> 		bytes_copied =3D nfsd_copy_file_range(copy->file_src, =
src_pos,
>> 				copy->file_dst, dst_pos, bytes_total);
>> 		if (bytes_copied <=3D 0)
>> @@ -1188,7 +1198,7 @@ static void cleanup_async_copy(struct =
nfsd4_copy *copy)
>> 	spin_lock(&copy->cp_clp->async_lock);
>> 	list_del(&copy->copies);
>> 	spin_unlock(&copy->cp_clp->async_lock);
>> -	kfree(copy);
>> +	nfs4_put_copy(copy);
>> }
>>=20
>> static int nfsd4_do_async_copy(void *data)
>> @@ -1238,6 +1248,7 @@ static int nfsd4_do_async_copy(void *data)
>> 			goto out;
>> 		if (!nfs4_init_cp_state(nn, copy))
>> 			goto out;
>> +		refcount_set(&async_copy->refcount, 1);
>> 		memcpy(&copy->cp_res.cb_stateid, &copy->cp_stateid,
>> 			sizeof(copy->cp_stateid));
>> 		dup_copy_fields(copy, async_copy);
>> @@ -1266,7 +1277,30 @@ static int nfsd4_do_async_copy(void *data)
>> 		     struct nfsd4_compound_state *cstate,
>> 		     union nfsd4_op_u *u)
>> {
>> -	return 0;
>> +	struct nfsd4_offload_status *os =3D &u->offload_status;
>> +	__be32 status =3D 0;
>> +	struct nfsd4_copy *copy;
>> +	bool found =3D false;
>> +	struct nfs4_client *clp =3D cstate->clp;
>> +
>> +	spin_lock(&clp->async_lock);
>> +	list_for_each_entry(copy, &clp->async_copies, copies) {
>> +		if (memcmp(&copy->cps->cp_stateid, &os->stateid,
>> +				NFS4_STATEID_SIZE))
>=20
> I'm having trouble compiling this patch: =20
>=20
> fs/nfsd/nfs4proc.c: In function 'nfsd4_offload_cancel':
> fs/nfsd/nfs4proc.c:1288:21: error: 'struct nfsd4_copy' has no member =
named 'cps'; did you mean 'cp_res'?
>   if (memcmp(&copy->cps->cp_stateid, &os->stateid,
>                     ^~~
>                     cp_res
>=20
> Is something out of order here?
>=20

Yep that=E2=80=99s the one I told you about that kbuilt have sent me and =
I have a fix for. I was waiting for more comments before sending =
corrections. Patches 7 and consequently 8 are effected.


> Anna
>=20
>> +			continue;
>> +		found =3D true;
>> +		refcount_inc(&copy->refcount);
>> +		break;
>> +	}
>> +	spin_unlock(&clp->async_lock);
>> +	if (found) {
>> +		set_tsk_thread_flag(copy->copy_task, TIF_SIGPENDING);
>> +		kthread_stop(copy->copy_task);
>> +		nfs4_put_copy(copy);
>> +	} else
>> +		status =3D nfserr_bad_stateid;
>> +
>> +	return status;
>> }
>>=20
>> static __be32
>> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
>> index d8893427..0ee2ed3 100644
>> --- a/fs/nfsd/state.h
>> +++ b/fs/nfsd/state.h
>> @@ -641,6 +641,7 @@ extern struct nfs4_client_reclaim =
*nfs4_client_to_reclaim(const char *name,
>>=20
>> struct nfs4_file *find_file(struct knfsd_fh *fh);
>> void put_nfs4_file(struct nfs4_file *fi);
>> +extern void nfs4_put_copy(struct nfsd4_copy *copy);
>> static inline void get_nfs4_file(struct nfs4_file *fi)
>> {
>> 	refcount_inc(&fi->fi_ref);
>> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
>> index 5af9eae..249d883 100644
>> --- a/fs/nfsd/xdr4.h
>> +++ b/fs/nfsd/xdr4.h
>> @@ -542,6 +542,7 @@ struct nfsd4_copy {
>>=20
>> 	struct list_head	copies;
>> 	struct task_struct	*copy_task;
>> +	refcount_t		refcount;
>> };
>>=20
>> struct nfsd4_seek {
>>=20

