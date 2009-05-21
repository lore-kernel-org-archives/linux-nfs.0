From: "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
Subject: Re: [RFC 10/11] nfsd41: Backchannel: Implement cb_recall over NFSv4.1
Date: Wed, 20 May 2009 23:54:53 -0700
Message-ID: <C63A48CD.6387%ricardo.labiaga@netapp.com>
References: <4A14EDCD.3090602@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <bfields@fieldses.org>, <pnfs@linux-nfs.org>,
	<linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12064 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750757AbZEUGzC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 May 2009 02:55:02 -0400
In-Reply-To: <4A14EDCD.3090602@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 5/20/09 10:59 PM, "Benny Halevy" <bhalevy@panasas.com> wrote:

> On May. 20, 2009, 21:17 +0300, "Labiaga, Ricardo" <ricardo.labiaga@netapp.com>
> wrote:
>> On 5/20/09 12:46 AM, "Benny Halevy" <bhalevy@panasas.com> wrote:
>> 
>>> On May. 20, 2009, 6:00 +0300, Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>>> wrote:
>>>> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>>>> [nfsd41: cb_recall callback]
>>>> [Share v4.0 and v4.1 back channel xdr]
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> [Share v4.0 and v4.1 back channel xdr]
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> [nfsd41: use nfsd4_cb_sequence for callback minorversion]
>>>> [nfsd41: conditionally decode_sequence in nfs4_xdr_dec_cb_recall]
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> [nfsd41: Backchannel: Add sequence arguments to callback RPC arguments]
>>>> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> ---
>>>>  fs/nfsd/nfs4callback.c |   40 ++++++++++++++++++++++++++++++++++++----
>>>>  1 files changed, 36 insertions(+), 4 deletions(-)
>>>> 
>>>> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
>>>> index 521d5f5..b25dcc2 100644
>>>> --- a/fs/nfsd/nfs4callback.c
>>>> +++ b/fs/nfsd/nfs4callback.c
>>>> @@ -292,15 +292,19 @@ nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
>>>>  }
>>>>  
>>>>  static int
>>>> -nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p, struct
>>>> nfs4_delegation *args)
>>>> +nfs4_xdr_enc_cb_recall(struct rpc_rqst *req, __be32 *p,
>>>> +  struct nfs4_rpc_args *rpc_args)
>>>>  {
>>>> struct xdr_stream xdr;
>>>> + struct nfs4_delegation *args = rpc_args->args_op;
>>>> struct nfs4_cb_compound_hdr hdr = {
>>>> .ident = args->dl_ident,
>>>> +  .minorversion = rpc_args->args_seq.cbs_minorversion,
>>>> };
>>>>  
>>>> xdr_init_encode(&xdr, &req->rq_snd_buf, p);
>>>> encode_cb_compound_hdr(&xdr, &hdr);
>>>> + encode_cb_sequence(&xdr, &rpc_args->args_seq, &hdr);
>>>> encode_cb_recall(&xdr, args, &hdr);
>>>> encode_cb_nops(&hdr);
>>>> return 0;
>>>> @@ -400,7 +404,8 @@ nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
>>>>  }
>>>>  
>>>>  static int
>>>> -nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p)
>>>> +nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32 *p,
>>>> +  struct nfs4_rpc_res *rpc_res)
>>>>  {
>>>> struct xdr_stream xdr;
>>>> struct nfs4_cb_compound_hdr hdr;
>>>> @@ -410,6 +415,11 @@ nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp, __be32
>>>> *p)
>>>> status = decode_cb_compound_hdr(&xdr, &hdr);
>>>> if (status)
>>>> goto out;
>>>> + if (rpc_res && rpc_res->res_seq) {
>>> With this version rpc_res != NULL is guaranteed, isn't it?
>>> Also, embedding res_seq in nfs4_rpc_res will obviate this condition further.
>> 
>> True, rpc_res will always be non-NULL but rpc_res->res_seq is still NULL if
>> this is a v4.0 callback.
>> 
>>>> +  status = decode_cb_sequence(&xdr, rpc_res->res_seq, rqstp);
>>>> +  if (status)
>>>> +   goto out;
>>>> + }
>>>> status = decode_cb_op_hdr(&xdr, OP_CB_RECALL);
>>>>  out:
>>>> return status;
>>>> @@ -687,6 +697,8 @@ static void nfsd4_cb_recall_done(struct rpc_task *task,
>>>> void *calldata)
>>>> struct nfs4_delegation *dp = calldata;
>>>> struct nfs4_client *clp = dp->dl_client;
>>>>  
>>>> + nfsd4_cb_done(task, calldata);
>>>> +
>>>> switch (task->tk_status) {
>>>> case -EIO:
>>>> /* Network partition? */
>>>> @@ -699,16 +711,20 @@ static void nfsd4_cb_recall_done(struct rpc_task
>>>> *task,
>>>> void *calldata)
>>>> break;
>>>> default:
>>>> /* success, or error we can't handle */
>>>> -  return;
>>>> +  goto done;
>>>> }
>>>> if (dp->dl_retries--) {
>>>> rpc_delay(task, 2*HZ);
>>>> task->tk_status = 0;
>>>> rpc_restart_call(task);
>>>> +  return;
>>>> } else {
>>>> atomic_set(&clp->cl_cb_conn.cb_set, 0);
>>>> warn_no_callback_path(clp, task->tk_status);
>>>> }
>>>> +done:
>>>> + kfree(task->tk_msg.rpc_argp);
>>>> + kfree(task->tk_msg.rpc_resp);
>>>>  }
>>>>  
>>>>  static void nfsd4_cb_recall_release(void *calldata)
>>>> @@ -734,16 +750,32 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
>>>>  {
>>>> struct nfs4_client *clp = dp->dl_client;
>>>> struct rpc_clnt *clnt = clp->cl_cb_conn.cb_client;
>>>> + struct nfs4_rpc_args *args;
>>>> + struct nfs4_rpc_res *res;
>>>> struct rpc_message msg = {
>>>> .rpc_proc = &nfs4_cb_procedures[NFSPROC4_CLNT_CB_RECALL],
>>>> -  .rpc_argp = dp,
>>>> .rpc_cred = clp->cl_cb_conn.cb_cred
>>>> };
>>>> int status;
>>>>  
>>>> + args = kzalloc(sizeof(*args), GFP_KERNEL);
>>>> + if (!args) {
>>>> +  status = -ENOMEM;
>>>> +  goto out;
>>>> + }
>>>> + res = kzalloc(sizeof(*res), GFP_KERNEL);
>>>> + if (!res) {
>>>> +  kfree(args);
>>>> +  status = -ENOMEM;
>>>> +  goto out;
>>>> + }
>>> Hmm, why not allocate the two in one piece and possibly having a kmem_cache
>>> for them?
>> 
>> They're two different types of structures.  You mean encapsulate them in a
>> super structure and then have the pointers to respective members?  I'm not
>> following.
> 
> Exactly.
> 
> I meant something like this:
> 
> struct nfs4_rpc_alloc {
> struct nfs4_rpc_args args;
> struct nfs4_rpc_res res;
> };
> 
> However, as you pointed elsewhere, struct nfs4_rpc_res currently
> contains only a pointer to struct nfsd4_cb_sequence which is embedded
> in the nfs4_rpc_args so we can just get rid of struct nfs4_rpc_res
> altogether for now, until we have a better use for it, and set
> task->tk_msg.rpc_resp = &args->args_seq;
> directly in nfsd41_cb_setup_sequence.
> (or even up in nfsd4_cb_recall and friends so it's always set,
> for all minorversions, as decode_cb_sequence is a noop for
> res->cbs_minorversion==0)
> 

I initially decided against doing that since CB_GETATTR has results that
need to be returned to the caller.  A pointer to the results would be
included in 'struct nfs4_rpc_res' for access during the decode.

Although in the spirit of not adding code for future use, I guess is best to
use &args->args_seq at this time and then change it to use 'nfs4_rpc_res'
when we actually implement CB_GETATTR.

You just talked me into it, I'll make the change.

- ricardo

> Benny
> 
>> 
>> - ricardo
>> 
>>> Benny
>>> 
>>>> + args->args_op = dp;
>>>> + msg.rpc_argp = args;
>>>> + msg.rpc_resp = res;
>>>> dp->dl_retries = 1;
>>>> status = rpc_call_async(clnt, &msg, RPC_TASK_SOFT,
>>>> &nfsd4_cb_recall_ops, dp);
>>>> +out:
>>>> if (status) {
>>>> put_nfs4_client(clp);
>>>> nfs4_put_delegation(dp);
>> 

