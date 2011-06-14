Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:56492 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab1FNPRt convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 11:17:49 -0400
Received: by vxi39 with SMTP id 39so4518146vxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 08:17:48 -0700 (PDT)
In-Reply-To: <4DF67EF6.6040707@gmail.com>
References: <cover.1307921137.git.rees@umich.edu> <7f60aa4b7494834319738eb61a05057bc86a498d.1307921138.git.rees@umich.edu>
 <4DF67EF6.6040707@gmail.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Tue, 14 Jun 2011 23:16:51 +0800
Message-ID: <BANLkTinB__v1EOv05sknuqATRUYmdDAM_w@mail.gmail.com>
Subject: Re: [PATCH 06/34] pnfs: cleanup_layoutcommit
To: Benny Halevy <bhalevy.lists@gmail.com>
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 14, 2011 at 5:19 AM, Benny Halevy <bhalevy.lists@gmail.com> wrote:
> On 2011-06-12 19:44, Jim Rees wrote:
>> From: Peng Tao <bergwolf@gmail.com>
>>
>> This gives layout driver a chance to cleanup structures they put in.
>> Also ensure layoutcommit does not commit more than isize, as block layout
>> driver may dirty pages beyond EOF.
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> [fixup layout header pointer for layoutcommit]
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> Signed-off-by: Peng Tao <bergwolf@gmail.com>
>> ---
>>  fs/nfs/nfs4proc.c       |    1 +
>>  fs/nfs/nfs4xdr.c        |    3 ++-
>>  fs/nfs/pnfs.c           |   15 +++++++++++++++
>>  fs/nfs/pnfs.h           |    4 ++++
>>  include/linux/nfs_xdr.h |    1 +
>>  5 files changed, 23 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 5246db8..e27a648 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -5890,6 +5890,7 @@ static void nfs4_layoutcommit_release(void *calldata)
>>  {
>>       struct nfs4_layoutcommit_data *data = calldata;
>>
>> +     pnfs_cleanup_layoutcommit(data->args.inode, data);
>
> The layout driver better be passed the status on the done method
> rather than on release so that it can roll back on error.
>
> Although it is quite complicated to roll back after permanent errors like
> NFS4ERR_BADLAYOUT where the client is really screwed and it
> essentially needs to redirty and rewrite the data (to the MDS
> to simplify the error handling path), rolling back from
> transient errors like NFS4ERR_DELAY should be fairly easy.
I agree that it can be put in layoutcommit_done. But why is it related
to rolling back in error case? IMHO, layoutcommit error handling
should be implemented in generic code. e.g., for NFS4ERR_DELAY,
current code will retry layoutcommit in generic layer.
pnfs_cleanup_layoutcommit is simply an interface for layout driver to
cleanup its private data associated with this layoutcommit operation.
For block layout specifically, clean up commiting extent list.

Thanks,
Tao

>
> Benny
>
>>       /* Matched by references in pnfs_set_layoutcommit */
>>       put_lseg(data->lseg);
>>       put_rpccred(data->cred);
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index fdcbd8f..57295d1 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -1963,7 +1963,7 @@ encode_layoutcommit(struct xdr_stream *xdr,
>>       *p++ = cpu_to_be32(OP_LAYOUTCOMMIT);
>>       /* Only whole file layouts */
>>       p = xdr_encode_hyper(p, 0); /* offset */
>> -     p = xdr_encode_hyper(p, NFS4_MAX_UINT64); /* length */
>> +     p = xdr_encode_hyper(p, args->lastbytewritten+1); /* length */
>>       *p++ = cpu_to_be32(0); /* reclaim */
>>       p = xdr_encode_opaque_fixed(p, args->stateid.data, NFS4_STATEID_SIZE);
>>       *p++ = cpu_to_be32(1); /* newoffset = TRUE */
>> @@ -5467,6 +5467,7 @@ static int decode_layoutcommit(struct xdr_stream *xdr,
>>       int status;
>>
>>       status = decode_op_hdr(xdr, OP_LAYOUTCOMMIT);
>> +     res->status = status;
>>       if (status)
>>               return status;
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index e693718..48a06a1 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -1248,6 +1248,7 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>>  {
>>       struct nfs_inode *nfsi = NFS_I(wdata->inode);
>>       loff_t end_pos = wdata->mds_offset + wdata->res.count;
>> +     loff_t isize = i_size_read(wdata->inode);
>>       bool mark_as_dirty = false;
>>
>>       spin_lock(&nfsi->vfs_inode.i_lock);
>> @@ -1261,9 +1262,13 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>>               dprintk("%s: Set layoutcommit for inode %lu ",
>>                       __func__, wdata->inode->i_ino);
>>       }
>> +     if (end_pos > isize)
>> +             end_pos = isize;
>>       if (end_pos > wdata->lseg->pls_end_pos)
>>               wdata->lseg->pls_end_pos = end_pos;
>>       spin_unlock(&nfsi->vfs_inode.i_lock);
>> +     dprintk("%s: lseg %p end_pos %llu\n",
>> +             __func__, wdata->lseg, wdata->lseg->pls_end_pos);
>>
>>       /* if pnfs_layoutcommit_inode() runs between inode locks, the next one
>>        * will be a noop because NFS_INO_LAYOUTCOMMIT will not be set */
>> @@ -1272,6 +1277,16 @@ pnfs_set_layoutcommit(struct nfs_write_data *wdata)
>>  }
>>  EXPORT_SYMBOL_GPL(pnfs_set_layoutcommit);
>>
>> +void pnfs_cleanup_layoutcommit(struct inode *inode,
>> +                               struct nfs4_layoutcommit_data *data)
>> +{
>> +        struct nfs_server *nfss = NFS_SERVER(inode);
>> +
>> +        if (nfss->pnfs_curr_ld->cleanup_layoutcommit)
>> +                nfss->pnfs_curr_ld->cleanup_layoutcommit(
>> +                                        NFS_I(inode)->layout, data);
>> +}
>> +
>>  void pnfs_free_fsdata(struct pnfs_fsdata *fsdata)
>>  {
>>       /* lseg refcounting handled directly in nfs_write_end */
>> diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
>> index 525ec55..5048898 100644
>> --- a/fs/nfs/pnfs.h
>> +++ b/fs/nfs/pnfs.h
>> @@ -127,6 +127,9 @@ struct pnfs_layoutdriver_type {
>>                                    struct xdr_stream *xdr,
>>                                    const struct nfs4_layoutreturn_args *args);
>>
>> +        void (*cleanup_layoutcommit) (struct pnfs_layout_hdr *layoutid,
>> +                                      struct nfs4_layoutcommit_data *data);
>> +
>>       void (*encode_layoutcommit) (struct pnfs_layout_hdr *layoutid,
>>                                    struct xdr_stream *xdr,
>>                                    const struct nfs4_layoutcommit_args *args);
>> @@ -213,6 +216,7 @@ void pnfs_roc_release(struct inode *ino);
>>  void pnfs_roc_set_barrier(struct inode *ino, u32 barrier);
>>  bool pnfs_roc_drain(struct inode *ino, u32 *barrier);
>>  void pnfs_set_layoutcommit(struct nfs_write_data *wdata);
>> +void pnfs_cleanup_layoutcommit(struct inode *inode, struct nfs4_layoutcommit_data *data);
>>  int pnfs_layoutcommit_inode(struct inode *inode, bool sync);
>>  int _pnfs_return_layout(struct inode *);
>>  int pnfs_ld_write_done(struct nfs_write_data *);
>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>> index a9c43ba..2c3ffda 100644
>> --- a/include/linux/nfs_xdr.h
>> +++ b/include/linux/nfs_xdr.h
>> @@ -270,6 +270,7 @@ struct nfs4_layoutcommit_res {
>>       struct nfs_fattr *fattr;
>>       const struct nfs_server *server;
>>       struct nfs4_sequence_res seq_res;
>> +     int status;
>>  };
>>
>>  struct nfs4_layoutcommit_data {
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
