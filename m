Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:62890 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891Ab0IJVrb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 17:47:31 -0400
Received: by bwz11 with SMTP id 11so2652723bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Sep 2010 14:47:29 -0700 (PDT)
In-Reply-To: <1284149490.10062.107.camel@heimdal.trondhjem.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	<1283450419-5648-13-git-send-email-iisaman@netapp.com>
	<1284149490.10062.107.camel@heimdal.trondhjem.org>
Date: Fri, 10 Sep 2010 14:47:29 -0700
Message-ID: <AANLkTimWALJj=SNEW9NoTWFByGwOytXNUjvf9qdyGTXH@mail.gmail.com>
Subject: Re: [PATCH 12/13] RFC: pnfs: add LAYOUTGET and GETDEVICEINFO infrastructure
From: Fred Isaman <iisaman@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 10, 2010 at 1:11 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2010-09-02 at 14:00 -0400, Fred Isaman wrote:
>> From: The pNFS Team <linux-nfs@vger.kernel.org>
>>
>> Add the ability to actually send LAYOUTGET and GETDEVICEINFO.  This also adds
>> in the machinery to handle layout state and the deviceid cache.  Note that
>> GETDEVICEINFO is not called directly by the generic layer.  Instead it
>> is called by the drivers while parsing the LAYOUTGET opaque data in response
>> to an unknown device id embedded therein.  Annoyingly, RFC 5661 only encodes
>> device ids within the driver-specific opaque data.
>>
>> Signed-off-by: TBD - melding/reorganization of several patches
>> ---
>>  fs/nfs/nfs4proc.c         |  134 ++++++++++++++++
>>  fs/nfs/nfs4xdr.c          |  302 +++++++++++++++++++++++++++++++++++
>>  fs/nfs/pnfs.c             |  382 ++++++++++++++++++++++++++++++++++++++++++---
>>  fs/nfs/pnfs.h             |   91 +++++++++++-
>>  include/linux/nfs4.h      |    2 +
>>  include/linux/nfs_fs_sb.h |    1 +
>>  include/linux/nfs_xdr.h   |   49 ++++++
>>  7 files changed, 935 insertions(+), 26 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index c7c7277..7eeea0e 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -55,6 +55,7 @@
>>  #include "internal.h"
>>  #include "iostat.h"
>>  #include "callback.h"
>> +#include "pnfs.h"
>>
>>  #define NFSDBG_FACILITY              NFSDBG_PROC
>>
>> @@ -5335,6 +5336,139 @@ out:
>>       dprintk("<-- %s status=%d\n", __func__, status);
>>       return status;
>>  }
>> +
>> +static void
>> +nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
>> +{
>> +     struct nfs4_layoutget *lgp = calldata;
>> +     struct inode *ino = lgp->args.inode;
>> +     struct nfs_server *server = NFS_SERVER(ino);
>> +
>> +     dprintk("--> %s\n", __func__);
>> +     if (nfs4_setup_sequence(server, &lgp->args.seq_args,
>> +                             &lgp->res.seq_res, 0, task))
>> +             return;
>> +     rpc_call_start(task);
>> +}
>> +
>> +static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
>> +{
>> +     struct nfs4_layoutget *lgp = calldata;
>> +     struct inode *ino = lgp->args.inode;
>> +     struct nfs_server *server = NFS_SERVER(ino);
>> +
>> +     dprintk("--> %s\n", __func__);
>> +
>> +     if (!nfs4_sequence_done(task, &lgp->res.seq_res))
>> +             return;
>> +
>> +     if (RPC_ASSASSINATED(task))
>> +             return;
>> +
>> +     if (nfs4_async_handle_error(task, server, NULL) == -EAGAIN)
>> +             nfs_restart_rpc(task, server->nfs_client);
>> +
>> +     lgp->status = task->tk_status;
>> +     dprintk("<-- %s\n", __func__);
>> +}
>> +
>> +static void nfs4_layoutget_release(void *calldata)
>> +{
>> +     struct nfs4_layoutget *lgp = calldata;
>> +
>> +     dprintk("--> %s\n", __func__);
>> +     put_layout_hdr(lgp->args.inode);
>> +     if (lgp->res.layout.buf != NULL)
>> +             free_page((unsigned long) lgp->res.layout.buf);
>> +     put_nfs_open_context(lgp->args.ctx);
>> +     kfree(calldata);
>> +     dprintk("<-- %s\n", __func__);
>> +}
>> +
>> +static const struct rpc_call_ops nfs4_layoutget_call_ops = {
>> +     .rpc_call_prepare = nfs4_layoutget_prepare,
>> +     .rpc_call_done = nfs4_layoutget_done,
>> +     .rpc_release = nfs4_layoutget_release,
>> +};
>> +
>> +static int _nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
>> +{
>> +     struct nfs_server *server = NFS_SERVER(lgp->args.inode);
>> +     struct rpc_task *task;
>> +     struct rpc_message msg = {
>> +             .rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_LAYOUTGET],
>> +             .rpc_argp = &lgp->args,
>> +             .rpc_resp = &lgp->res,
>> +     };
>> +     struct rpc_task_setup task_setup_data = {
>> +             .rpc_client = server->client,
>> +             .rpc_message = &msg,
>> +             .callback_ops = &nfs4_layoutget_call_ops,
>> +             .callback_data = lgp,
>> +             .flags = RPC_TASK_ASYNC,
>> +     };
>> +     int status = 0;
>> +
>> +     dprintk("--> %s\n", __func__);
>> +
>> +     lgp->res.layout.buf = (void *)__get_free_page(GFP_NOFS);
>> +     if (lgp->res.layout.buf == NULL) {
>> +             nfs4_layoutget_release(lgp);
>> +             return -ENOMEM;
>> +     }
>> +
>> +     lgp->res.seq_res.sr_slotid = NFS4_MAX_SLOT_TABLE;
>> +     task = rpc_run_task(&task_setup_data);
>> +     if (IS_ERR(task))
>> +             return PTR_ERR(task);
>> +     status = nfs4_wait_for_completion_rpc_task(task);
>> +     if (status != 0)
>> +             goto out;
>> +     status = lgp->status;
>> +     if (status != 0)
>> +             goto out;
>> +     status = pnfs_layout_process(lgp);
>> +out:
>> +     rpc_put_task(task);
>> +     dprintk("<-- %s status=%d\n", __func__, status);
>> +     return status;
>> +}
>> +
>> +int nfs4_proc_layoutget(struct nfs4_layoutget *lgp)
>> +{
>> +     struct nfs_server *server = NFS_SERVER(lgp->args.inode);
>> +     struct nfs4_exception exception = { };
>> +     int err;
>> +     do {
>> +             err = nfs4_handle_exception(server, _nfs4_proc_layoutget(lgp),
>> +                                         &exception);
>> +     } while (exception.retry);
>> +     return err;
>> +}
>
> Since nfs4_layoutget_done() already calls nfs4_async_handle_error(), do
> you really need to call nfs4_handle_exception()?
>


Hmmm, since it is being called synchronously at the moment, we should
probably remove the nfs4_async_handle_error call.


>> +
>> +int nfs4_proc_getdeviceinfo(struct nfs_server *server, struct pnfs_device *pdev)
>> +{
>> +     struct nfs4_getdeviceinfo_args args = {
>> +             .pdev = pdev,
>> +     };
>> +     struct nfs4_getdeviceinfo_res res = {
>> +             .pdev = pdev,
>> +     };
>> +     struct rpc_message msg = {
>> +             .rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_GETDEVICEINFO],
>> +             .rpc_argp = &args,
>> +             .rpc_resp = &res,
>> +     };
>> +     int status;
>> +
>> +     dprintk("--> %s\n", __func__);
>> +     status = nfs4_call_sync(server, &msg, &args, &res, 0);
>> +     dprintk("<-- %s status=%d\n", __func__, status);
>> +
>> +     return status;
>> +}
>> +EXPORT_SYMBOL_GPL(nfs4_proc_getdeviceinfo);
>> +
>
> This, on the other hand, might need a 'handle exception' wrapper.

I agree.


>
>>  #endif /* CONFIG_NFS_V4_1 */
>>
>>  struct nfs4_state_recovery_ops nfs40_reboot_recovery_ops = {
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index 60233ae..aaf6fe5 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -52,6 +52,7 @@
>>  #include <linux/nfs_idmap.h>
>>  #include "nfs4_fs.h"
>>  #include "internal.h"
>> +#include "pnfs.h"
>>
>>  #define NFSDBG_FACILITY              NFSDBG_XDR
>>
>> @@ -310,6 +311,19 @@ static int nfs4_stat_to_errno(int);
>>                               XDR_QUADLEN(NFS4_MAX_SESSIONID_LEN) + 5)
>>  #define encode_reclaim_complete_maxsz        (op_encode_hdr_maxsz + 4)
>>  #define decode_reclaim_complete_maxsz        (op_decode_hdr_maxsz + 4)
>> +#define encode_getdeviceinfo_maxsz (op_encode_hdr_maxsz + 4 + \
>> +                             XDR_QUADLEN(NFS4_PNFS_DEVICEID4_SIZE))
>> +#define decode_getdeviceinfo_maxsz (op_decode_hdr_maxsz + \
>> +                             1 /* layout type */ + \
>> +                             1 /* opaque devaddr4 length */ + \
>> +                               /* devaddr4 payload is read into page */ \
>> +                             1 /* notification bitmap length */ + \
>> +                             1 /* notification bitmap */)
>> +#define encode_layoutget_maxsz       (op_encode_hdr_maxsz + 10 + \
>> +                             encode_stateid_maxsz)
>> +#define decode_layoutget_maxsz       (op_decode_hdr_maxsz + 8 + \
>> +                             decode_stateid_maxsz + \
>> +                             XDR_QUADLEN(PNFS_LAYOUT_MAXSIZE))
>>  #else /* CONFIG_NFS_V4_1 */
>>  #define encode_sequence_maxsz        0
>>  #define decode_sequence_maxsz        0
>> @@ -699,6 +713,20 @@ static int nfs4_stat_to_errno(int);
>>  #define NFS4_dec_reclaim_complete_sz (compound_decode_hdr_maxsz + \
>>                                        decode_sequence_maxsz + \
>>                                        decode_reclaim_complete_maxsz)
>> +#define NFS4_enc_getdeviceinfo_sz (compound_encode_hdr_maxsz +    \
>> +                             encode_sequence_maxsz +\
>> +                             encode_getdeviceinfo_maxsz)
>> +#define NFS4_dec_getdeviceinfo_sz (compound_decode_hdr_maxsz +    \
>> +                             decode_sequence_maxsz + \
>> +                             decode_getdeviceinfo_maxsz)
>> +#define NFS4_enc_layoutget_sz        (compound_encode_hdr_maxsz + \
>> +                             encode_sequence_maxsz + \
>> +                             encode_putfh_maxsz +        \
>> +                             encode_layoutget_maxsz)
>> +#define NFS4_dec_layoutget_sz        (compound_decode_hdr_maxsz + \
>> +                             decode_sequence_maxsz + \
>> +                             decode_putfh_maxsz +        \
>> +                             decode_layoutget_maxsz)
>>
>>  const u32 nfs41_maxwrite_overhead = ((RPC_MAX_HEADER_WITH_AUTH +
>>                                     compound_encode_hdr_maxsz +
>> @@ -1726,6 +1754,61 @@ static void encode_sequence(struct xdr_stream *xdr,
>>  #endif /* CONFIG_NFS_V4_1 */
>>  }
>>
>> +#ifdef CONFIG_NFS_V4_1
>> +static void
>> +encode_getdeviceinfo(struct xdr_stream *xdr,
>> +                  const struct nfs4_getdeviceinfo_args *args,
>> +                  struct compound_hdr *hdr)
>> +{
>> +     int has_bitmap = (args->pdev->dev_notify_types != 0);
>> +     int len = 16 + NFS4_PNFS_DEVICEID4_SIZE + (has_bitmap * 4);
>> +     __be32 *p;
>> +
>> +     p = reserve_space(xdr, len);
>> +     *p++ = cpu_to_be32(OP_GETDEVICEINFO);
>> +     p = xdr_encode_opaque_fixed(p, args->pdev->dev_id.data,
>> +                                 NFS4_PNFS_DEVICEID4_SIZE);
>> +     *p++ = cpu_to_be32(args->pdev->layout_type);
>> +     *p++ = cpu_to_be32(args->pdev->pglen);          /* gdia_maxcount */
>> +     *p++ = cpu_to_be32(has_bitmap);                 /* bitmap length [01] */
>> +     if (has_bitmap)
>> +             *p = cpu_to_be32(args->pdev->dev_notify_types);
>
> We don't support notification callbacks yet.
>

OK, I'll rip this out and just set the bitmap to zero.

>> +     hdr->nops++;
>> +     hdr->replen += decode_getdeviceinfo_maxsz;
>> +}
>> +
>> +static void
>> +encode_layoutget(struct xdr_stream *xdr,
>> +                   const struct nfs4_layoutget_args *args,
>> +                   struct compound_hdr *hdr)
>> +{
>> +     nfs4_stateid stateid;
>> +     __be32 *p;
>> +
>> +     p = reserve_space(xdr, 44 + NFS4_STATEID_SIZE);
>> +     *p++ = cpu_to_be32(OP_LAYOUTGET);
>> +     *p++ = cpu_to_be32(0);     /* Signal layout available */
>> +     *p++ = cpu_to_be32(args->type);
>> +     *p++ = cpu_to_be32(args->range.iomode);
>> +     p = xdr_encode_hyper(p, args->range.offset);
>> +     p = xdr_encode_hyper(p, args->range.length);
>> +     p = xdr_encode_hyper(p, args->minlength);
>> +     pnfs_get_layout_stateid(&stateid, NFS_I(args->inode)->layout);
>> +     p = xdr_encode_opaque_fixed(p, &stateid.data, NFS4_STATEID_SIZE);
>> +     *p = cpu_to_be32(args->maxcount);
>> +
>> +     dprintk("%s: 1st type:0x%x iomode:%d off:%lu len:%lu mc:%d\n",
>> +             __func__,
>> +             args->type,
>> +             args->range.iomode,
>> +             (unsigned long)args->range.offset,
>> +             (unsigned long)args->range.length,
>> +             args->maxcount);
>> +     hdr->nops++;
>> +     hdr->replen += decode_layoutget_maxsz;
>> +}
>> +#endif /* CONFIG_NFS_V4_1 */
>> +
>>  /*
>>   * END OF "GENERIC" ENCODE ROUTINES.
>>   */
>> @@ -2543,6 +2626,51 @@ static int nfs4_xdr_enc_reclaim_complete(struct rpc_rqst *req, uint32_t *p,
>>       return 0;
>>  }
>>
>> +/*
>> + * Encode GETDEVICEINFO request
>> + */
>> +static int nfs4_xdr_enc_getdeviceinfo(struct rpc_rqst *req, uint32_t *p,
>> +                                   struct nfs4_getdeviceinfo_args *args)
>> +{
>> +     struct xdr_stream xdr;
>> +     struct compound_hdr hdr = {
>> +             .minorversion = nfs4_xdr_minorversion(&args->seq_args),
>> +     };
>> +
>> +     xdr_init_encode(&xdr, &req->rq_snd_buf, p);
>> +     encode_compound_hdr(&xdr, req, &hdr);
>> +     encode_sequence(&xdr, &args->seq_args, &hdr);
>> +     encode_getdeviceinfo(&xdr, args, &hdr);
>> +
>> +     /* set up reply kvec. Subtract notification bitmap max size (2)
>> +      * so that notification bitmap is put in xdr_buf tail */
>> +     xdr_inline_pages(&req->rq_rcv_buf, (hdr.replen - 2) << 2,
>> +                      args->pdev->pages, args->pdev->pgbase,
>> +                      args->pdev->pglen);
>> +
>> +     encode_nops(&hdr);
>> +     return 0;
>> +}
>> +
>> +/*
>> + *  Encode LAYOUTGET request
>> + */
>> +static int nfs4_xdr_enc_layoutget(struct rpc_rqst *req, uint32_t *p,
>> +                               struct nfs4_layoutget_args *args)
>> +{
>> +     struct xdr_stream xdr;
>> +     struct compound_hdr hdr = {
>> +             .minorversion = nfs4_xdr_minorversion(&args->seq_args),
>> +     };
>> +
>> +     xdr_init_encode(&xdr, &req->rq_snd_buf, p);
>> +     encode_compound_hdr(&xdr, req, &hdr);
>> +     encode_sequence(&xdr, &args->seq_args, &hdr);
>> +     encode_putfh(&xdr, NFS_FH(args->inode), &hdr);
>> +     encode_layoutget(&xdr, args, &hdr);
>> +     encode_nops(&hdr);
>> +     return 0;
>> +}
>>  #endif /* CONFIG_NFS_V4_1 */
>>
>>  static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
>> @@ -4788,6 +4916,131 @@ out_overflow:
>>  #endif /* CONFIG_NFS_V4_1 */
>>  }
>>
>> +#if defined(CONFIG_NFS_V4_1)
>> +
>> +static int decode_getdeviceinfo(struct xdr_stream *xdr,
>> +                             struct pnfs_device *pdev)
>> +{
>> +     __be32 *p;
>> +     uint32_t len, type;
>> +     int status;
>> +
>> +     status = decode_op_hdr(xdr, OP_GETDEVICEINFO);
>> +     if (status) {
>> +             if (status == -ETOOSMALL) {
>> +                     p = xdr_inline_decode(xdr, 4);
>> +                     if (unlikely(!p))
>> +                             goto out_overflow;
>> +                     pdev->mincount = be32_to_cpup(p);
>> +                     dprintk("%s: Min count too small. mincnt = %u\n",
>> +                             __func__, pdev->mincount);
>> +             }
>> +             return status;
>> +     }
>> +
>> +     p = xdr_inline_decode(xdr, 8);
>> +     if (unlikely(!p))
>> +             goto out_overflow;
>> +     type = be32_to_cpup(p++);
>> +     if (type != pdev->layout_type) {
>> +             dprintk("%s: layout mismatch req: %u pdev: %u\n",
>> +                     __func__, pdev->layout_type, type);
>> +             return -EINVAL;
>> +     }
>> +     /*
>> +      * Get the length of the opaque device_addr4. xdr_read_pages places
>> +      * the opaque device_addr4 in the xdr_buf->pages (pnfs_device->pages)
>> +      * and places the remaining xdr data in xdr_buf->tail
>> +      */
>> +     pdev->mincount = be32_to_cpup(p);
>> +     xdr_read_pages(xdr, pdev->mincount); /* include space for the length */
>> +
>> +     /*
>> +      * At most one bitmap word. If the server returns a bitmap of more
>> +      * than one word we ignore the extra invalid words given that
>> +      * getdeviceinfo is the final operation in the compound.
>> +      */
>> +     p = xdr_inline_decode(xdr, 4);
>> +     if (unlikely(!p))
>> +             goto out_overflow;
>> +     len = be32_to_cpup(p);
>> +     if (len) {
>> +             p = xdr_inline_decode(xdr, 4);
>> +             if (unlikely(!p))
>> +                     goto out_overflow;
>> +             pdev->dev_notify_types = be32_to_cpup(p);
>> +     } else
>> +             pdev->dev_notify_types = 0;
>
> Again, we don't support notifications.
>

OK.


>> +     return 0;
>> +out_overflow:
>> +     print_overflow_msg(__func__, xdr);
>> +     return -EIO;
>> +}
>> +
>> +static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
>> +                         struct nfs4_layoutget_res *res)
>> +{
>> +     __be32 *p;
>> +     int status;
>> +     u32 layout_count;
>> +
>> +     status = decode_op_hdr(xdr, OP_LAYOUTGET);
>> +     if (status)
>> +             return status;
>> +     p = xdr_inline_decode(xdr, 8 + NFS4_STATEID_SIZE);
>> +     if (unlikely(!p))
>> +             goto out_overflow;
>> +     res->return_on_close = be32_to_cpup(p++);
>> +     p = xdr_decode_opaque_fixed(p, res->stateid.data, NFS4_STATEID_SIZE);
>> +     layout_count = be32_to_cpup(p);
>> +     if (!layout_count) {
>> +             dprintk("%s: server responded with empty layout array\n",
>> +                     __func__);
>> +             return -EINVAL;
>> +     }
>> +
>> +     p = xdr_inline_decode(xdr, 24);
>> +     if (unlikely(!p))
>> +             goto out_overflow;
>> +     p = xdr_decode_hyper(p, &res->range.offset);
>> +     p = xdr_decode_hyper(p, &res->range.length);
>> +     res->range.iomode = be32_to_cpup(p++);
>> +     res->type = be32_to_cpup(p++);
>> +
>> +     status = decode_opaque_inline(xdr, &res->layout.len, (char **)&p);
>> +     if (unlikely(status))
>> +             return status;
>> +
>> +     dprintk("%s roff:%lu rlen:%lu riomode:%d, lo_type:0x%x, lo.len:%d\n",
>> +             __func__,
>> +             (unsigned long)res->range.offset,
>> +             (unsigned long)res->range.length,
>> +             res->range.iomode,
>> +             res->type,
>> +             res->layout.len);
>> +
>> +     /* nfs4_proc_layoutget allocated a single page */
>> +     if (res->layout.len > PAGE_SIZE)
>> +             return -ENOMEM;
>> +     memcpy(res->layout.buf, p, res->layout.len);
>> +
>> +     if (layout_count > 1) {
>> +             /* We only handle a length one array at the moment.  Any
>> +              * further entries are just ignored.  Note that this means
>> +              * the client may see a response that is less than the
>> +              * minimum it requested.
>> +              */
>> +             dprintk("%s: server responded with %d layouts, dropping tail\n",
>> +                     __func__, layout_count);
>> +     }
>> +
>> +     return 0;
>> +out_overflow:
>> +     print_overflow_msg(__func__, xdr);
>> +     return -EIO;
>> +}
>> +#endif /* CONFIG_NFS_V4_1 */
>> +
>>  /*
>>   * END OF "GENERIC" DECODE ROUTINES.
>>   */
>> @@ -5815,6 +6068,53 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp, uint32_t *p,
>>               status = decode_reclaim_complete(&xdr, (void *)NULL);
>>       return status;
>>  }
>> +
>> +/*
>> + * Decode GETDEVINFO response
>> + */
>> +static int nfs4_xdr_dec_getdeviceinfo(struct rpc_rqst *rqstp, uint32_t *p,
>> +                                   struct nfs4_getdeviceinfo_res *res)
>> +{
>> +     struct xdr_stream xdr;
>> +     struct compound_hdr hdr;
>> +     int status;
>> +
>> +     xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
>> +     status = decode_compound_hdr(&xdr, &hdr);
>> +     if (status != 0)
>> +             goto out;
>> +     status = decode_sequence(&xdr, &res->seq_res, rqstp);
>> +     if (status != 0)
>> +             goto out;
>> +     status = decode_getdeviceinfo(&xdr, res->pdev);
>> +out:
>> +     return status;
>> +}
>> +
>> +/*
>> + * Decode LAYOUTGET response
>> + */
>> +static int nfs4_xdr_dec_layoutget(struct rpc_rqst *rqstp, uint32_t *p,
>> +                               struct nfs4_layoutget_res *res)
>> +{
>> +     struct xdr_stream xdr;
>> +     struct compound_hdr hdr;
>> +     int status;
>> +
>> +     xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
>> +     status = decode_compound_hdr(&xdr, &hdr);
>> +     if (status)
>> +             goto out;
>> +     status = decode_sequence(&xdr, &res->seq_res, rqstp);
>> +     if (status)
>> +             goto out;
>> +     status = decode_putfh(&xdr);
>> +     if (status)
>> +             goto out;
>> +     status = decode_layoutget(&xdr, rqstp, res);
>> +out:
>> +     return status;
>> +}
>>  #endif /* CONFIG_NFS_V4_1 */
>>
>>  __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
>> @@ -5993,6 +6293,8 @@ struct rpc_procinfo     nfs4_procedures[] = {
>>    PROC(SEQUENCE,     enc_sequence,   dec_sequence),
>>    PROC(GET_LEASE_TIME,       enc_get_lease_time,     dec_get_lease_time),
>>    PROC(RECLAIM_COMPLETE, enc_reclaim_complete,  dec_reclaim_complete),
>> +  PROC(GETDEVICEINFO, enc_getdeviceinfo, dec_getdeviceinfo),
>> +  PROC(LAYOUTGET,  enc_layoutget,     dec_layoutget),
>>  #endif /* CONFIG_NFS_V4_1 */
>>  };
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index cbce942..faf6c4c 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -128,6 +128,12 @@ pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
>>               return status;
>>       }
>>
>> +     if (!io_ops->alloc_lseg || !io_ops->free_lseg) {
>> +             printk(KERN_ERR "%s Layout driver must provide "
>> +                    "alloc_lseg and free_lseg.\n", __func__);
>> +             return status;
>> +     }
>> +
>>       spin_lock(&pnfs_spinlock);
>>       if (!find_pnfs_driver_locked(ld_type->id)) {
>>               list_add(&ld_type->pnfs_tblid, &pnfs_modules_tbl);
>> @@ -153,6 +159,10 @@ pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *ld_type)
>>  }
>>  EXPORT_SYMBOL(pnfs_unregister_layoutdriver);
>>
>> +/*
>> + * pNFS client layout cache
>> + */
>> +
>>  static void
>>  get_layout_hdr_locked(struct pnfs_layout_hdr *lo)
>>  {
>> @@ -175,6 +185,15 @@ put_layout_hdr_locked(struct pnfs_layout_hdr *lo)
>>       }
>>  }
>>
>> +void
>> +put_layout_hdr(struct inode *inode)
>> +{
>> +     spin_lock(&inode->i_lock);
>> +     put_layout_hdr_locked(NFS_I(inode)->layout);
>> +     spin_unlock(&inode->i_lock);
>> +
>> +}
>> +
>>  static void
>>  init_lseg(struct pnfs_layout_hdr *lo, struct pnfs_layout_segment *lseg)
>>  {
>> @@ -191,7 +210,7 @@ destroy_lseg(struct kref *kref)
>>       struct pnfs_layout_hdr *local = lseg->layout;
>>
>>       dprintk("--> %s\n", __func__);
>> -     kfree(lseg);
>> +     PNFS_LD_IO_OPS(local)->free_lseg(lseg);
>
> Where is PNFS_LD_IO_OPS() defined? Besides, I thought we agreed to get
> rid of that.

This is defined in pnfs.h as
PNFS_NFS_SERVER()->pnfs_curr_ld->ld_io_iops, mainly to save typing.

The macro that you had objected to was PNFS_EXISTS_LDIO_OP form
Benny's tree, which is now gone.

>
>>       /* Matched by get_layout_hdr_locked in pnfs_insert_layout */
>>       put_layout_hdr_locked(local);
>>  }
>> @@ -226,6 +245,7 @@ pnfs_clear_lseg_list(struct pnfs_layout_hdr *lo)
>>       /* List does not take a reference, so no need for put here */
>>       list_del_init(&lo->layouts);
>>       spin_unlock(&clp->cl_lock);
>> +     pnfs_set_layout_stateid(lo, &zero_stateid);
>>
>>       dprintk("%s:Return\n", __func__);
>>  }
>> @@ -268,40 +288,120 @@ pnfs_destroy_all_layouts(struct nfs_client *clp)
>>       }
>>  }
>>
>> -static void pnfs_insert_layout(struct pnfs_layout_hdr *lo,
>> -                            struct pnfs_layout_segment *lseg);
>> +void
>> +pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>> +                     const nfs4_stateid *stateid)
>> +{
>> +     write_seqlock(&lo->seqlock);
>> +     memcpy(lo->stateid.data, stateid->data, sizeof(lo->stateid.data));
>> +     write_sequnlock(&lo->seqlock);
>> +}
>> +
>> +void
>> +pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo)
>> +{
>> +     int seq;
>>
>> -/* Get layout from server. */
>> +     dprintk("--> %s\n", __func__);
>> +
>> +     do {
>> +             seq = read_seqbegin(&lo->seqlock);
>> +             memcpy(dst->data, lo->stateid.data,
>> +                    sizeof(lo->stateid.data));
>> +     } while (read_seqretry(&lo->seqlock, seq));
>> +
>> +     dprintk("<-- %s\n", __func__);
>> +}
>> +
>> +static void
>> +pnfs_layout_from_open_stateid(struct pnfs_layout_hdr *lo,
>> +                           struct nfs4_state *state)
>> +{
>> +     int seq;
>> +
>> +     dprintk("--> %s\n", __func__);
>> +
>> +     write_seqlock(&lo->seqlock);
>> +     /* Zero stateid, which is illegal to use in layout, is our
>> +      * marker for an un-initialized stateid.
>> +      */
>
> Isn't it easier just to have a flag in the layout?
>
>> +     if (!memcmp(lo->stateid.data, &zero_stateid, NFS4_STATEID_SIZE))
>> +             do {
>> +                     seq = read_seqbegin(&state->seqlock);
>> +                     memcpy(lo->stateid.data, state->stateid.data,
>> +                                     sizeof(state->stateid.data));
>> +             } while (read_seqretry(&state->seqlock, seq));
>> +     write_sequnlock(&lo->seqlock);
>
> ...and if memcmp(), is the caller supposed to detect that nothing was
> done?
>
>> +     dprintk("<-- %s\n", __func__);
>> +}
>> +
>> +/*
>> +* Get layout from server.
>> +*    for now, assume that whole file layouts are requested.
>> +*    arg->offset: 0
>> +*    arg->length: all ones
>> +*/
>>  static struct pnfs_layout_segment *
>>  send_layoutget(struct pnfs_layout_hdr *lo,
>>          struct nfs_open_context *ctx,
>>          u32 iomode)
>>  {
>>       struct inode *ino = lo->inode;
>> -     struct pnfs_layout_segment *lseg;
>> +     struct nfs_server *server = NFS_SERVER(ino);
>> +     struct nfs4_layoutget *lgp;
>> +     struct pnfs_layout_segment *lseg = NULL;
>>
>> -     /* Lets pretend we sent LAYOUTGET and got a response */
>> -     lseg = kzalloc(sizeof(*lseg), GFP_KERNEL);
>> +     dprintk("--> %s\n", __func__);
>> +
>> +     BUG_ON(ctx == NULL);
>> +     lgp = kzalloc(sizeof(*lgp), GFP_KERNEL);
>> +     if (lgp == NULL) {
>> +             put_layout_hdr(lo->inode);
>> +             return NULL;
>> +     }
>> +     lgp->args.minlength = NFS4_MAX_UINT64;
>> +     lgp->args.maxcount = PNFS_LAYOUT_MAXSIZE;
>> +     lgp->args.range.iomode = iomode;
>> +     lgp->args.range.offset = 0;
>> +     lgp->args.range.length = NFS4_MAX_UINT64;
>> +     lgp->args.type = server->pnfs_curr_ld->id;
>> +     lgp->args.inode = ino;
>> +     lgp->args.ctx = get_nfs_open_context(ctx);
>> +     lgp->lsegpp = &lseg;
>> +
>> +     if (!memcmp(lo->stateid.data, &zero_stateid, NFS4_STATEID_SIZE))
>> +             pnfs_layout_from_open_stateid(NFS_I(ino)->layout, ctx->state);
>
> Why do an extra memcmp() here?

OK, clearly the function and call to pnfs_layout_from_open_stateid
need to be reexamined.

Fred

>
>> +
>> +     /* Synchronously retrieve layout information from server and
>> +      * store in lseg.
>> +      */
>> +     nfs4_proc_layoutget(lgp);
>>       if (!lseg) {
>> +             /* remember that LAYOUTGET failed and suspend trying */
>>               set_bit(lo_fail_bit(iomode), &lo->state);
>> -             spin_lock(&ino->i_lock);
>> -             put_layout_hdr_locked(lo);
>> -             spin_unlock(&ino->i_lock);
>> -             return NULL;
>>       }
>> -     init_lseg(lo, lseg);
>> -     lseg->iomode = IOMODE_RW;
>> -     spin_lock(&ino->i_lock);
>> -     pnfs_insert_layout(lo, lseg);
>> -     put_layout_hdr_locked(lo);
>> -     spin_unlock(&ino->i_lock);
>>       return lseg;
>>  }
>>
>> +/*
>> + * Compare two layout segments for sorting into layout cache.
>> + * We want to preferentially return RW over RO layouts, so ensure those
>> + * are seen first.
>> + */
>> +static s64
>> +cmp_layout(u32 iomode1, u32 iomode2)
>> +{
>> +     /* read > read/write */
>> +     return (int)(iomode2 == IOMODE_READ) - (int)(iomode1 == IOMODE_READ);
>> +}
>> +
>>  static void
>>  pnfs_insert_layout(struct pnfs_layout_hdr *lo,
>>                  struct pnfs_layout_segment *lseg)
>>  {
>> +     struct pnfs_layout_segment *lp;
>> +     int found = 0;
>> +
>>       dprintk("%s:Begin\n", __func__);
>>
>>       assert_spin_locked(&lo->inode->i_lock);
>> @@ -313,13 +413,28 @@ pnfs_insert_layout(struct pnfs_layout_hdr *lo,
>>               list_add_tail(&lo->layouts, &clp->cl_layouts);
>>               spin_unlock(&clp->cl_lock);
>>       }
>> -     /* STUB - add the constructed lseg if necessary */
>> -     if (list_empty(&lo->segs)) {
>> +     list_for_each_entry(lp, &lo->segs, fi_list) {
>> +             if (cmp_layout(lp->range.iomode, lseg->range.iomode) > 0)
>> +                     continue;
>> +             list_add_tail(&lseg->fi_list, &lp->fi_list);
>> +             dprintk("%s: inserted lseg %p "
>> +                     "iomode %d offset %llu length %llu before "
>> +                     "lp %p iomode %d offset %llu length %llu\n",
>> +                     __func__, lseg, lseg->range.iomode,
>> +                     lseg->range.offset, lseg->range.length,
>> +                     lp, lp->range.iomode, lp->range.offset,
>> +                     lp->range.length);
>> +             found = 1;
>> +             break;
>> +     }
>> +     if (!found) {
>>               list_add_tail(&lseg->fi_list, &lo->segs);
>> -             get_layout_hdr_locked(lo);
>> -             dprintk("%s: inserted lseg %p iomode %d at tail\n",
>> -                     __func__, lseg, lseg->iomode);
>> +             dprintk("%s: inserted lseg %p "
>> +                     "iomode %d offset %llu length %llu at tail\n",
>> +                     __func__, lseg, lseg->range.iomode,
>> +                     lseg->range.offset, lseg->range.length);
>>       }
>> +     get_layout_hdr_locked(lo);
>>
>>       dprintk("%s:Return\n", __func__);
>>  }
>> @@ -335,6 +450,7 @@ alloc_init_layout_hdr(struct inode *ino)
>>       lo->refcount = 1;
>>       INIT_LIST_HEAD(&lo->layouts);
>>       INIT_LIST_HEAD(&lo->segs);
>> +     seqlock_init(&lo->seqlock);
>>       lo->inode = ino;
>>       return lo;
>>  }
>> @@ -362,11 +478,46 @@ pnfs_find_alloc_layout(struct inode *ino)
>>       return nfsi->layout;
>>  }
>>
>> -/* STUB - LAYOUTGET never succeeds, so cache is empty */
>> +/*
>> + * iomode matching rules:
>> + * iomode    lseg    match
>> + * -----     -----   -----
>> + * ANY               READ    true
>> + * ANY               RW      true
>> + * RW                READ    false
>> + * RW                RW      true
>> + * READ              READ    true
>> + * READ              RW      true
>> + */
>> +static int
>> +is_matching_lseg(struct pnfs_layout_segment *lseg, u32 iomode)
>> +{
>> +     return (iomode != IOMODE_RW || lseg->range.iomode == IOMODE_RW);
>> +}
>> +
>> +/*
>> + * lookup range in layout
>> + */
>>  static struct pnfs_layout_segment *
>>  pnfs_has_layout(struct pnfs_layout_hdr *lo, u32 iomode)
>>  {
>> -     return NULL;
>> +     struct pnfs_layout_segment *lseg, *ret = NULL;
>> +
>> +     dprintk("%s:Begin\n", __func__);
>> +
>> +     assert_spin_locked(&lo->inode->i_lock);
>> +     list_for_each_entry(lseg, &lo->segs, fi_list) {
>> +             if (is_matching_lseg(lseg, iomode)) {
>> +                     ret = lseg;
>> +                     break;
>> +             }
>> +             if (cmp_layout(iomode, lseg->range.iomode) > 0)
>> +                     break;
>> +     }
>> +
>> +     dprintk("%s:Return lseg %p ref %d\n",
>> +             __func__, ret, ret ? atomic_read(&ret->kref.refcount) : 0);
>> +     return ret;
>>  }
>>
>>  /*
>> @@ -403,7 +554,7 @@ pnfs_update_layout(struct inode *ino,
>>       if (test_bit(lo_fail_bit(iomode), &nfsi->layout->state))
>>               goto out_unlock;
>>
>> -     get_layout_hdr_locked(lo);
>> +     get_layout_hdr_locked(lo); /* Matched in nfs4_layoutget_release */
>>       spin_unlock(&ino->i_lock);
>>
>>       lseg = send_layoutget(lo, ctx, iomode);
>> @@ -415,3 +566,184 @@ out_unlock:
>>       spin_unlock(&ino->i_lock);
>>       goto out;
>>  }
>> +
>> +int
>> +pnfs_layout_process(struct nfs4_layoutget *lgp)
>> +{
>> +     struct pnfs_layout_hdr *lo = NFS_I(lgp->args.inode)->layout;
>> +     struct nfs4_layoutget_res *res = &lgp->res;
>> +     struct pnfs_layout_segment *lseg;
>> +     struct inode *ino = lo->inode;
>> +     int status = 0;
>> +
>> +     /* Inject layout blob into I/O device driver */
>> +     lseg = PNFS_LD_IO_OPS(lo)->alloc_lseg(lo, res);
>                 ^^^^^^^^^^^^^^
>
>> +     if (!lseg || IS_ERR(lseg)) {
>> +             if (!lseg)
>> +                     status = -ENOMEM;
>> +             else
>> +                     status = PTR_ERR(lseg);
>> +             dprintk("%s: Could not allocate layout: error %d\n",
>> +                    __func__, status);
>> +             goto out;
>> +     }
>> +
>> +     spin_lock(&ino->i_lock);
>> +     init_lseg(lo, lseg);
>> +     lseg->range = res->range;
>> +     *lgp->lsegpp = lseg;
>> +     pnfs_insert_layout(lo, lseg);
>> +
>> +     /* Done processing layoutget. Set the layout stateid */
>> +     pnfs_set_layout_stateid(lo, &res->stateid);
>> +     spin_unlock(&ino->i_lock);
>> +out:
>> +     return status;
>> +}
>> +
>> +/*
>> + * Device ID cache. Currently supports one layout type per struct nfs_client.
>> + * Add layout type to the lookup key to expand to support multiple types.
>> + */
>> +int
>> +nfs4_alloc_init_deviceid_cache(struct nfs_client *clp,
>> +                      void (*free_callback)(struct nfs4_deviceid *))
>> +{
>> +     struct nfs4_deviceid_cache *c;
>> +
>> +     c = kzalloc(sizeof(struct nfs4_deviceid_cache), GFP_KERNEL);
>> +     if (!c)
>> +             return -ENOMEM;
>> +     spin_lock(&clp->cl_lock);
>> +     if (clp->cl_devid_cache != NULL) {
>> +             atomic_inc(&clp->cl_devid_cache->dc_ref);
>> +             dprintk("%s [kref [%d]]\n", __func__,
>> +                     atomic_read(&clp->cl_devid_cache->dc_ref));
>> +             kfree(c);
>> +     } else {
>> +             /* kzalloc initializes hlists */
>> +             spin_lock_init(&c->dc_lock);
>> +             atomic_set(&c->dc_ref, 1);
>> +             c->dc_free_callback = free_callback;
>> +             clp->cl_devid_cache = c;
>> +             dprintk("%s [new]\n", __func__);
>> +     }
>> +     spin_unlock(&clp->cl_lock);
>> +     return 0;
>> +}
>> +EXPORT_SYMBOL(nfs4_alloc_init_deviceid_cache);
>> +
>> +void
>> +nfs4_init_deviceid_node(struct nfs4_deviceid *d)
>> +{
>> +     INIT_HLIST_NODE(&d->de_node);
>> +     atomic_set(&d->de_ref, 1);
>> +}
>> +EXPORT_SYMBOL(nfs4_init_deviceid_node);
>> +
>> +/* Called from layoutdriver_io_operations->alloc_lseg */
>> +void
>> +nfs4_set_layout_deviceid(struct pnfs_layout_segment *l, struct nfs4_deviceid *d)
>> +{
>> +     dprintk("%s [%d]\n", __func__, atomic_read(&d->de_ref));
>> +     l->deviceid = d;
>> +}
>> +EXPORT_SYMBOL(nfs4_set_layout_deviceid);
>> +
>> +/*
>> + * Called from layoutdriver_io_operations->free_lseg
>> + * last layout segment reference frees deviceid
>> + */
>> +void
>> +nfs4_put_layout_deviceid(struct pnfs_layout_segment *l)
>> +{
>> +     struct nfs4_deviceid_cache *c =
>> +             NFS_SERVER(l->layout->inode)->nfs_client->cl_devid_cache;
>> +     struct pnfs_deviceid *id = &l->deviceid->de_id;
>> +     struct nfs4_deviceid *d;
>> +     struct hlist_node *n;
>> +     long h = nfs4_deviceid_hash(id);
>> +
>> +     dprintk("%s [%d]\n", __func__, atomic_read(&l->deviceid->de_ref));
>> +     if (!atomic_dec_and_lock(&l->deviceid->de_ref, &c->dc_lock))
>> +             return;
>> +
>> +     hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[h], de_node)
>> +             if (!memcmp(&d->de_id, id, sizeof(*id))) {
>> +                     hlist_del_rcu(&d->de_node);
>> +                     spin_unlock(&c->dc_lock);
>> +                     synchronize_rcu();
>> +                     c->dc_free_callback(l->deviceid);
>> +                     return;
>> +             }
>> +     spin_unlock(&c->dc_lock);
>> +}
>> +EXPORT_SYMBOL(nfs4_put_layout_deviceid);
>> +
>> +/* Find and reference a deviceid */
>> +struct nfs4_deviceid *
>> +nfs4_find_get_deviceid(struct nfs4_deviceid_cache *c, struct pnfs_deviceid *id)
>> +{
>> +     struct nfs4_deviceid *d;
>> +     struct hlist_node *n;
>> +     long hash = nfs4_deviceid_hash(id);
>> +
>> +     dprintk("--> %s hash %ld\n", __func__, hash);
>> +     rcu_read_lock();
>> +     hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_node) {
>> +             if (!memcmp(&d->de_id, id, sizeof(*id))) {
>> +                     if (!atomic_inc_not_zero(&d->de_ref)) {
>> +                             goto fail;
>> +                     } else {
>> +                             rcu_read_unlock();
>> +                             return d;
>> +                     }
>> +             }
>> +     }
>> +fail:
>> +     rcu_read_unlock();
>> +     return NULL;
>> +}
>> +EXPORT_SYMBOL(nfs4_find_get_deviceid);
>> +
>> +/*
>> + * Add a deviceid to the cache.
>> + * GETDEVICEINFOs for same deviceid can race. If deviceid is found, discard new
>> + */
>> +struct nfs4_deviceid *
>> +nfs4_add_deviceid(struct nfs4_deviceid_cache *c, struct nfs4_deviceid *new)
>> +{
>> +     struct nfs4_deviceid *d;
>> +     struct hlist_node *n;
>> +     long hash = nfs4_deviceid_hash(&new->de_id);
>> +
>> +     dprintk("--> %s hash %ld\n", __func__, hash);
>> +     spin_lock(&c->dc_lock);
>> +     hlist_for_each_entry_rcu(d, n, &c->dc_deviceids[hash], de_node) {
>> +             if (!memcmp(&d->de_id, &new->de_id, sizeof(new->de_id))) {
>> +                     spin_unlock(&c->dc_lock);
>> +                     dprintk("%s [discard]\n", __func__);
>> +                     c->dc_free_callback(new);
>> +                     return d;
>> +             }
>> +     }
>> +     hlist_add_head_rcu(&new->de_node, &c->dc_deviceids[hash]);
>> +     spin_unlock(&c->dc_lock);
>> +     dprintk("%s [new]\n", __func__);
>> +     return new;
>> +}
>> +EXPORT_SYMBOL(nfs4_add_deviceid);
>> +
>> +void
>> +nfs4_put_deviceid_cache(struct nfs_client *clp)
>> +{
>> +     struct nfs4_deviceid_cache *local = clp->cl_devid_cache;
>> +
>> +     dprintk("--> %s cl_devid_cache %p\n", __func__, clp->cl_devid_cache);
>> +     if (atomic_dec_and_lock(&local->dc_ref, &clp->cl_lock)) {
>> +             clp->cl_devid_cache = NULL;
>> +             spin_unlock(&clp->cl_lock);
>> +             kfree(local);
>> +     }
>> +}
>> +EXPORT_SYMBOL(nfs4_put_deviceid_cache);
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index dac6a72..d343f83 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -12,11 +12,14 @@
>>
>>  struct pnfs_layout_segment {
>>       struct list_head fi_list;
>> -     u32 iomode;
>> +     struct pnfs_layout_range range;
>>       struct kref kref;
>>       struct pnfs_layout_hdr *layout;
>> +     struct nfs4_deviceid *deviceid;
>>  };
>>
>> +#define NFS4_PNFS_DEVICEID4_SIZE 16
>> +
>>  #ifdef CONFIG_NFS_V4_1
>>
>>  #define LAYOUT_NFSV4_1_MODULE_PREFIX "nfs-layouttype4"
>> @@ -38,17 +41,86 @@ struct pnfs_layout_hdr {
>>       int                     refcount;
>>       struct list_head        layouts;   /* other client layouts */
>>       struct list_head        segs;      /* layout segments list */
>> +     seqlock_t               seqlock;   /* Protects the stateid */
>> +     nfs4_stateid            stateid;
>>       unsigned long           state;
>>       struct inode            *inode;
>>  };
>>
>>  /* Layout driver I/O operations. */
>>  struct layoutdriver_io_operations {
>> +     struct pnfs_layout_segment * (*alloc_lseg) (struct pnfs_layout_hdr *layoutid, struct nfs4_layoutget_res *lgr);
>> +     void (*free_lseg) (struct pnfs_layout_segment *lseg);
>> +
>>       /* Registration information for a new mounted file system */
>>       int (*initialize_mountpoint) (struct nfs_client *);
>>       int (*uninitialize_mountpoint) (struct nfs_client *);
>>  };
>>
>> +struct pnfs_deviceid {
>> +     char data[NFS4_PNFS_DEVICEID4_SIZE];
>> +};
>> +
>> +struct pnfs_device {
>> +     struct pnfs_deviceid dev_id;
>> +     unsigned int  layout_type;
>> +     unsigned int  mincount;
>> +     struct page **pages;
>> +     void          *area;
>> +     unsigned int  pgbase;
>> +     unsigned int  pglen;
>> +     unsigned int  dev_notify_types;
>> +};
>> +
>> +/*
>> + * Device ID RCU cache. A device ID is unique per client ID and layout type.
>> + */
>> +#define NFS4_DEVICE_ID_HASH_BITS     5
>> +#define NFS4_DEVICE_ID_HASH_SIZE     (1 << NFS4_DEVICE_ID_HASH_BITS)
>> +#define NFS4_DEVICE_ID_HASH_MASK     (NFS4_DEVICE_ID_HASH_SIZE - 1)
>> +
>> +static inline u32
>> +nfs4_deviceid_hash(struct pnfs_deviceid *id)
>> +{
>> +     unsigned char *cptr = (unsigned char *)id->data;
>> +     unsigned int nbytes = NFS4_PNFS_DEVICEID4_SIZE;
>> +     u32 x = 0;
>> +
>> +     while (nbytes--) {
>> +             x *= 37;
>> +             x += *cptr++;
>> +     }
>> +     return x & NFS4_DEVICE_ID_HASH_MASK;
>> +}
>> +
>> +struct nfs4_deviceid_cache {
>> +     spinlock_t              dc_lock;
>> +     atomic_t                dc_ref;
>> +     void                    (*dc_free_callback)(struct nfs4_deviceid *);
>> +     struct hlist_head       dc_deviceids[NFS4_DEVICE_ID_HASH_SIZE];
>> +     struct hlist_head       dc_to_free;
>> +};
>> +
>> +/* Device ID cache node */
>> +struct nfs4_deviceid {
>> +     struct hlist_node       de_node;
>> +     struct pnfs_deviceid    de_id;
>> +     atomic_t                de_ref;
>> +};
>> +
>> +extern int nfs4_alloc_init_deviceid_cache(struct nfs_client *,
>> +                             void (*free_callback)(struct nfs4_deviceid *));
>> +extern void nfs4_put_deviceid_cache(struct nfs_client *);
>> +extern void nfs4_init_deviceid_node(struct nfs4_deviceid *);
>> +extern struct nfs4_deviceid *nfs4_find_get_deviceid(
>> +                             struct nfs4_deviceid_cache *,
>> +                             struct pnfs_deviceid *);
>> +extern struct nfs4_deviceid *nfs4_add_deviceid(struct nfs4_deviceid_cache *,
>> +                             struct nfs4_deviceid *);
>> +extern void nfs4_set_layout_deviceid(struct pnfs_layout_segment *,
>> +                             struct nfs4_deviceid *);
>> +extern void nfs4_put_layout_deviceid(struct pnfs_layout_segment *);
>> +
>>  extern int pnfs_register_layoutdriver(struct pnfs_layoutdriver_type *);
>>  extern void pnfs_unregister_layoutdriver(struct pnfs_layoutdriver_type *);
>>
>> @@ -58,13 +130,30 @@ PNFS_NFS_SERVER(struct pnfs_layout_hdr *lo)
>>       return NFS_SERVER(lo->inode);
>>  }
>>
>> +static inline struct layoutdriver_io_operations *
>> +PNFS_LD_IO_OPS(struct pnfs_layout_hdr *lo)
>> +{
>> +     return PNFS_NFS_SERVER(lo)->pnfs_curr_ld->ld_io_ops;
>> +}
>> +
>> +/* nfs4proc.c */
>> +extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
>> +                                struct pnfs_device *dev);
>> +extern int nfs4_proc_layoutget(struct nfs4_layoutget *lgp);
>> +
>> +/* pnfs.c */
>>  struct pnfs_layout_segment *
>>  pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
>>                  enum pnfs_iomode access_type);
>>  void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
>>  void unset_pnfs_layoutdriver(struct nfs_server *);
>> +int pnfs_layout_process(struct nfs4_layoutget *lgp);
>> +void pnfs_set_layout_stateid(struct pnfs_layout_hdr *lo,
>> +                          const nfs4_stateid *stateid);
>>  void pnfs_destroy_layout(struct nfs_inode *);
>>  void pnfs_destroy_all_layouts(struct nfs_client *);
>> +void put_layout_hdr(struct inode *inode);
>> +void pnfs_get_layout_stateid(nfs4_stateid *dst, struct pnfs_layout_hdr *lo);
>>
>>
>>  static inline int lo_fail_bit(u32 iomode)
>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>> index 2dde7c8..dcdd11c 100644
>> --- a/include/linux/nfs4.h
>> +++ b/include/linux/nfs4.h
>> @@ -545,6 +545,8 @@ enum {
>>       NFSPROC4_CLNT_SEQUENCE,
>>       NFSPROC4_CLNT_GET_LEASE_TIME,
>>       NFSPROC4_CLNT_RECLAIM_COMPLETE,
>> +     NFSPROC4_CLNT_LAYOUTGET,
>> +     NFSPROC4_CLNT_GETDEVICEINFO,
>>  };
>>
>>  /* nfs41 types */
>> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
>> index e670a9c..7512886 100644
>> --- a/include/linux/nfs_fs_sb.h
>> +++ b/include/linux/nfs_fs_sb.h
>> @@ -83,6 +83,7 @@ struct nfs_client {
>>       u32                     cl_exchange_flags;
>>       struct nfs4_session     *cl_session;    /* sharred session */
>>       struct list_head        cl_layouts;
>> +     struct nfs4_deviceid_cache *cl_devid_cache; /* pNFS deviceid cache */
>>  #endif /* CONFIG_NFS_V4_1 */
>>
>>  #ifdef CONFIG_NFS_FSCACHE
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index 8a2c228..c4c6a61 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -186,6 +186,55 @@ struct nfs4_get_lease_time_res {
>>       struct nfs4_sequence_res        lr_seq_res;
>>  };
>>
>> +#define PNFS_LAYOUT_MAXSIZE 4096
>> +
>> +struct nfs4_layoutdriver_data {
>> +     __u32 len;
>> +     void *buf;
>> +};
>> +
>> +struct pnfs_layout_range {
>> +     u32 iomode;
>> +     u64 offset;
>> +     u64 length;
>> +};
>> +
>> +struct nfs4_layoutget_args {
>> +     __u32 type;
>> +     struct pnfs_layout_range range;
>> +     __u64 minlength;
>> +     __u32 maxcount;
>> +     struct inode *inode;
>> +     struct nfs_open_context *ctx;
>> +     struct nfs4_sequence_args seq_args;
>> +};
>> +
>> +struct nfs4_layoutget_res {
>> +     __u32 return_on_close;
>> +     struct pnfs_layout_range range;
>> +     __u32 type;
>> +     nfs4_stateid stateid;
>> +     struct nfs4_layoutdriver_data layout;
>> +     struct nfs4_sequence_res seq_res;
>> +};
>> +
>> +struct nfs4_layoutget {
>> +     struct nfs4_layoutget_args args;
>> +     struct nfs4_layoutget_res res;
>> +     struct pnfs_layout_segment **lsegpp;
>> +     int status;
>> +};
>> +
>> +struct nfs4_getdeviceinfo_args {
>> +     struct pnfs_device *pdev;
>> +     struct nfs4_sequence_args seq_args;
>> +};
>> +
>> +struct nfs4_getdeviceinfo_res {
>> +     struct pnfs_device *pdev;
>> +     struct nfs4_sequence_res seq_res;
>> +};
>> +
>>  /*
>>   * Arguments to the open call.
>>   */
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
