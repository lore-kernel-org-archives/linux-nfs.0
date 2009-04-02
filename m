From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 40/47] nfsd41: cb_sequence callback
Date: Thu, 02 Apr 2009 22:20:08 +0300
Message-ID: <49D50FE8.8020303@panasas.com>
References: <49CDDFC2.4070402@panasas.com> <1238229281-11516-1-git-send-email-bhalevy@panasas.com> <20090401043932.GC29339@fieldses.org> <49D47B9C.9030502@panasas.com> <20090402185107.GG5560@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:21321 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765126AbZDBTUX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 15:20:23 -0400
In-Reply-To: <20090402185107.GG5560@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 02, 2009, 21:51 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Thu, Apr 02, 2009 at 11:47:24AM +0300, Benny Halevy wrote:
>> On Apr. 01, 2009, 7:39 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> On Sat, Mar 28, 2009 at 11:34:41AM +0300, Benny Halevy wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>>
>>>> Implement the cb_sequence callback conforming to draft-ietf-nfsv4-minorversion1
>>>>
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> [Rework the back channel xdr using the shared v4.0 and v4.1 framework.]
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> [fixed indentation]
>>>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>>>> ---
>>>>  fs/nfsd/nfs4callback.c     |  118 ++++++++++++++++++++++++++++++++++++++++++++
>>>>  include/linux/nfsd/state.h |    7 ++-
>>>>  2 files changed, 124 insertions(+), 1 deletions(-)
>>>>
>>>> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
>>>> index 6b7ef87..7ada6b1 100644
>>>> --- a/fs/nfsd/nfs4callback.c
>>>> +++ b/fs/nfsd/nfs4callback.c
>>>> @@ -255,6 +255,29 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_cb_recall *cb_rec,
>>>>  	hdr->nops++;
>>>>  }
>>>>  
>>>> +static void
>>>> +encode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *args,
>>>> +		   struct nfs4_cb_compound_hdr *hdr)
>>>> +{
>>>> +	__be32 *p;
>>>> +
>>>> +	if (hdr->minorversion == 0)
>>>> +		return;
>>>> +
>>>> +	RESERVE_SPACE(1 + NFS4_MAX_SESSIONID_LEN + 20);
>>>> +
>>>> +	WRITE32(OP_CB_SEQUENCE);
>>>> +#ifdef CONFIG_NFSD_V4_1
>>>> +	WRITEMEM(args->cbs_clp->cl_sessionid.data, NFS4_MAX_SESSIONID_LEN);
>>>> +	WRITE32(args->cbs_clp->cl_cb_seq_nr);
>>>> +#endif /* CONFIG_NFSD_V4_1 */
>>> This whole function should be under CONFIG_NFSD_V4_1.
>>>
>>>> +	WRITE32(0);		/* slotid, always 0 */
>>>> +	WRITE32(0);		/* highest slotid always 0 */
>>>> +	WRITE32(0);		/* cachethis always 0 */
>>>> +	WRITE32(0); /* FIXME: support referring_call_lists */
>>>> +	hdr->nops++;
>>>> +}
>>>> +
>>>>  static int
>>>>  nfs4_xdr_enc_cb_null(struct rpc_rqst *req, __be32 *p)
>>>>  {
>>>> @@ -319,6 +342,69 @@ decode_cb_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
>>>>  	return 0;
>>>>  }
>>>>  
>>>> +/*
>>>> + * Our current back channel implmentation supports a single backchannel
>>>> + * with a single slot.
>>>> + */
>>>> +static int
>>>> +decode_cb_sequence(struct xdr_stream *xdr, struct nfsd4_cb_sequence *res,
>>>> +		   struct rpc_rqst *rqstp)
>>>> +{
>>>> +	struct nfs4_callback *cb =
>>>> +		(struct nfs4_callback *)rqstp->rq_task->tk_client->cl_private;
>>>> +	struct nfs4_sessionid id;
>>>> +	int status;
>>>> +	u32 dummy;
>>>> +	__be32 *p;
>>>> +
>>>> +	if (cb->cb_minorversion == 0)
>>>> +		return 0;
>>>> +
>>>> +	status = decode_cb_op_hdr(xdr, OP_CB_SEQUENCE);
>>>> +	if (status)
>>>> +		return status;
>>>> +
>>>> +	/*
>>>> +	 * If the server returns different values for sessionID, slotID or
>>>> +	 * sequence number, the server is looney tunes.
>>>> +	 */
>>>> +	status = -ESERVERFAULT;
>>>> +
>>>> +	READ_BUF(NFS4_MAX_SESSIONID_LEN + 16);
>>>> +	COPYMEM(id.data, NFS4_MAX_SESSIONID_LEN);
>>>> +#ifdef CONFIG_NFSD_V4_1
>>>> +	if (memcmp(id.data, res->cbs_clp->cl_sessionid.data,
>>>> +		   NFS4_MAX_SESSIONID_LEN)) {
>>>> +		dprintk("%s Invalid session id\n", __func__);
>>>> +		goto out;
>>>> +	}
>>>> +	READ32(dummy);
>>>> +	if (dummy != res->cbs_clp->cl_cb_seq_nr) {
>>>> +		dprintk("%s Invalid sequence number\n", __func__);
>>>> +		goto out;
>>>> +	}
>>>> +#endif /* CONFIG_NFSD_V4_1 */
>>> Ditto.
>>>
>>>> +	READ32(dummy); 	/* slotid must be 0 */
>>>> +	if (dummy != 0) {
>>>> +		dprintk("%s Invalid slotid\n", __func__);
>>>> +		goto out;
>>>> +	}
>>>> +	READ32(dummy); 	/* highest slotid must be 0 */
>>>> +	if (dummy != 0) {
>>>> +		dprintk("%s Invalid highest slotid\n", __func__);
>>>> +		goto out;
>>>> +	}
>>>> +	READ32(dummy); 	/* target highest slotid must be 0 */
>>>> +	if (dummy != 0) {
>>>> +		dprintk("%s Invalid target highest slotid\n", __func__);
>>>> +		goto out;
>>>> +	}
>>>> +	status = 0;
>>>> +out:
>>>> +	return status;
>>>> +}
>>>> +
>>>> +
>>>>  static int
>>>>  nfs4_xdr_dec_cb_null(struct rpc_rqst *req, __be32 *p)
>>>>  {
>>>> @@ -503,6 +589,38 @@ nfsd4_probe_callback(struct nfs4_client *clp)
>>>>  	return;
>>>>  }
>>>>  
>>>> +#if defined(CONFIG_NFSD_V4_1)
>>>> +/*
>>>> + * FIXME: cb_sequence should support referring call lists, cachethis, and
>>>> + * multiple slots
>>>> + */
>>>> +static int
>>>> +nfs41_cb_sequence_setup(struct nfs4_client *clp, struct nfsd4_cb_sequence *args)
>>>> +{
>>>> +	u32 *ptr = (u32 *)clp->cl_sessionid.data;
>>>> +
>>>> +	dprintk("%s: %u:%u:%u:%u\n", __func__,
>>>> +		ptr[0], ptr[1], ptr[2], ptr[3]);
>>>> +
>>>> +	mutex_lock(&clp->cl_cb_mutex);
>>> We shouldn't be holding a mutex across a callback.  Why is this needed?
>> Just a simple way to limit concurrency to 1 and not deal with
>> multiple slots on the callback path.
> 
> OK.  We should work out some sort of asynchronous equivalent.

OK.

> How is the client side currently waiting on slots?

Currently it has a single slot and a single
(NFS41_BC_MIN_CALLBACKS) preallocated rpc_rqst.
If it gets more calls than that, concurrently, it will
drop its end of the line using 
set_bit(XPRT_CLOSE_WAIT, &xprt->state)

(Ricardo, please keep me honest :)

Benny

> 
> --b.
