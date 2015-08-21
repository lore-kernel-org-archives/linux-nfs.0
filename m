Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36415 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbbHUB2Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Aug 2015 21:28:25 -0400
Received: by igxp17 with SMTP id p17so4157335igx.1
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2015 18:28:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1440069440-27454-20-git-send-email-jeff.layton@primarydata.com>
References: <1440069440-27454-1-git-send-email-jeff.layton@primarydata.com> <1440069440-27454-20-git-send-email-jeff.layton@primarydata.com>
From: Peng Tao <bergwolf@primarydata.com>
Date: Thu, 20 Aug 2015 18:28:05 -0700
Message-ID: <CAKVebiUdyX8+dVnq4nyBT5BzQaGp-9-aBwR+PpUPQHdonkiqxA@mail.gmail.com>
Subject: Re: [PATCH v3 19/20] nfsd: hook up nfs4_preprocess_stateid_op to the
 nfsd_file cache
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>, Kinglong Mee <kinglongmee@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 20, 2015 at 4:17 AM, Jeff Layton <jlayton@poochiereds.net> wrote:
> Have nfs4_preprocess_stateid_op pass back a nfsd_file instead of a filp.
> Since we now presume that the struct file will be persistent in most
> cases, we can stop fiddling with the raparms in the read code. This
> also means that we don't really care about the rd_tmp_file field
> anymore.
>
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> ---
>  fs/nfsd/nfs4proc.c  | 32 ++++++++++++++++----------------
>  fs/nfsd/nfs4state.c | 20 +++++++-------------
>  fs/nfsd/nfs4xdr.c   | 16 +++++-----------
>  fs/nfsd/state.h     |  2 +-
>  fs/nfsd/xdr4.h      | 15 +++++++--------
>  5 files changed, 36 insertions(+), 49 deletions(-)
>
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index b9681ee0ed19..42a3f8b50814 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -758,7 +758,7 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  {
>         __be32 status;
>
> -       read->rd_filp = NULL;
> +       read->rd_nf = NULL;
>         if (read->rd_offset >= OFFSET_MAX)
>                 return nfserr_inval;
>
> @@ -775,7 +775,7 @@ nfsd4_read(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>
>         /* check stateid */
>         status = nfs4_preprocess_stateid_op(rqstp, cstate, &read->rd_stateid,
> -                       RD_STATE, &read->rd_filp, &read->rd_tmp_file);
> +                       RD_STATE, &read->rd_nf);
>         if (status) {
>                 dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
>                 goto out;
> @@ -921,7 +921,7 @@ nfsd4_setattr(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>
>         if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
>                 status = nfs4_preprocess_stateid_op(rqstp, cstate,
> -                       &setattr->sa_stateid, WR_STATE, NULL, NULL);
> +                       &setattr->sa_stateid, WR_STATE, NULL);
>                 if (status) {
>                         dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
>                         return status;
> @@ -977,7 +977,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>             struct nfsd4_write *write)
>  {
>         stateid_t *stateid = &write->wr_stateid;
> -       struct file *filp = NULL;
> +       struct nfsd_file *nf = NULL;
>         __be32 status = nfs_ok;
>         unsigned long cnt;
>         int nvecs;
> @@ -986,7 +986,7 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>                 return nfserr_inval;
>
>         status = nfs4_preprocess_stateid_op(rqstp, cstate, stateid, WR_STATE,
> -                       &filp, NULL);
> +                       &nf);
>         if (status) {
>                 dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
>                 return status;
> @@ -999,10 +999,10 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>         nvecs = fill_in_write_vector(rqstp->rq_vec, write);
>         WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
>
> -       status = nfsd_vfs_write(rqstp, &cstate->current_fh, filp,
> +       status = nfsd_vfs_write(rqstp, &cstate->current_fh, nf->nf_file,
>                                 write->wr_offset, rqstp->rq_vec, nvecs, &cnt,
>                                 &write->wr_how_written);
> -       fput(filp);
> +       nfsd_file_put(nf);
>
>         write->wr_bytes_written = cnt;
>
> @@ -1014,21 +1014,21 @@ nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>                 struct nfsd4_fallocate *fallocate, int flags)
>  {
>         __be32 status = nfserr_notsupp;
> -       struct file *file;
> +       struct nfsd_file *nf;
>
>         status = nfs4_preprocess_stateid_op(rqstp, cstate,
>                                             &fallocate->falloc_stateid,
> -                                           WR_STATE, &file, NULL);
> +                                           WR_STATE, &nf);
>         if (status != nfs_ok) {
>                 dprintk("NFSD: nfsd4_fallocate: couldn't process stateid!\n");
>                 return status;
>         }
>
> -       status = nfsd4_vfs_fallocate(rqstp, &cstate->current_fh, file,
> +       status = nfsd4_vfs_fallocate(rqstp, &cstate->current_fh, nf->nf_file,
>                                      fallocate->falloc_offset,
>                                      fallocate->falloc_length,
>                                      flags);
> -       fput(file);
> +       nfsd_file_put(nf);
>         return status;
>  }
>
> @@ -1053,11 +1053,11 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>  {
>         int whence;
>         __be32 status;
> -       struct file *file;
> +       struct nfsd_file *nf;
>
>         status = nfs4_preprocess_stateid_op(rqstp, cstate,
>                                             &seek->seek_stateid,
> -                                           RD_STATE, &file, NULL);
> +                                           RD_STATE, &nf);
>         if (status) {
>                 dprintk("NFSD: nfsd4_seek: couldn't process stateid!\n");
>                 return status;
> @@ -1079,14 +1079,14 @@ nfsd4_seek(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>          * Note:  This call does change file->f_pos, but nothing in NFSD
>          *        should ever file->f_pos.
>          */
> -       seek->seek_pos = vfs_llseek(file, seek->seek_offset, whence);
> +       seek->seek_pos = vfs_llseek(nf->nf_file, seek->seek_offset, whence);
>         if (seek->seek_pos < 0)
>                 status = nfserrno(seek->seek_pos);
> -       else if (seek->seek_pos >= i_size_read(file_inode(file)))
> +       else if (seek->seek_pos >= i_size_read(file_inode(nf->nf_file)))
>                 seek->seek_eof = true;
>
>  out:
> -       fput(file);
> +       nfsd_file_put(nf);
>         return status;
>  }
>
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index f8394a4cd126..c626358c2bad 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4615,7 +4615,7 @@ nfs4_check_olstateid(struct svc_fh *fhp, struct nfs4_ol_stateid *ols, int flags)
>
>  static __be32
>  nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
> -               struct file **filpp, bool *tmp_file, int flags)
> +               struct nfsd_file **nfp, int flags)
>  {
>         int acc = (flags & RD_STATE) ? NFSD_MAY_READ : NFSD_MAY_WRITE;
>         struct nfsd_file *nf;
> @@ -4631,14 +4631,10 @@ nfs4_check_file(struct svc_rqst *rqstp, struct svc_fh *fhp, struct nfs4_stid *s,
>                 status = nfsd_file_acquire(rqstp, fhp, acc, &nf);
>                 if (status)
>                         return status;
> -
> -               if (tmp_file)
> -                       *tmp_file = true;
>         }
>
> -       *filpp = get_file(nf->nf_file);
> +       *nfp = nf;
>  out:
> -       nfsd_file_put(nf);
If nfsd_permission() fails, nf is leaked. Previous patch has:

@@ -4614,21 +4618,17 @@ nfs4_check_file(struct svc_rqst *rqstp, struct
svc_fh *fhp, struct nfs4_stid *s,
                struct file **filpp, bool *tmp_file, int flags)
 {
        int acc = (flags & RD_STATE) ? NFSD_MAY_READ : NFSD_MAY_WRITE;
-       struct file *file;
+       struct nfsd_file *nf;
        __be32 status;

-       file = nfs4_find_file(s, flags);
-       if (file) {
+       nf = nfs4_find_file(s, flags);
+       if (nf) {
                status = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
                                acc | NFSD_MAY_OWNER_OVERRIDE);
-               if (status) {
-                       fput(file);
-                       return status;
-               }
-
-               *filpp = file;
+               if (status)
+                       goto out;
        } else {
-               status = nfsd_open(rqstp, fhp, S_IFREG, acc, filpp);
+               status = nfsd_file_acquire(rqstp, fhp, acc, &nf);
                if (status)
                        return status;

Cheers,
Tao

>         return status;
>  }
>
> @@ -4648,7 +4644,7 @@ out:
>  __be32
>  nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
>                 struct nfsd4_compound_state *cstate, stateid_t *stateid,
> -               int flags, struct file **filpp, bool *tmp_file)
> +               int flags, struct nfsd_file **nfp)
>  {
>         struct svc_fh *fhp = &cstate->current_fh;
>         struct inode *ino = d_inode(fhp->fh_dentry);
> @@ -4657,10 +4653,8 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
>         struct nfs4_stid *s = NULL;
>         __be32 status;
>
> -       if (filpp)
> -               *filpp = NULL;
> -       if (tmp_file)
> -               *tmp_file = false;
> +       if (nfp)
> +               *nfp = NULL;
>
>         if (grace_disallows_io(net, ino))
>                 return nfserr_grace;
> @@ -4697,8 +4691,8 @@ nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
>         status = nfs4_check_fh(fhp, s);
>
>  done:
> -       if (!status && filpp)
> -               status = nfs4_check_file(rqstp, fhp, s, filpp, tmp_file, flags);
> +       if (status == nfs_ok && nfp)
> +               status = nfs4_check_file(rqstp, fhp, s, nfp, flags);
>  out:
>         if (s)
>                 nfs4_put_stid(s);
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 75e0563c09d1..7e25a31f8e60 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -49,6 +49,7 @@
>  #include "cache.h"
>  #include "netns.h"
>  #include "pnfs.h"
> +#include "filecache.h"
>
>  #ifdef CONFIG_NFSD_V4_SECURITY_LABEL
>  #include <linux/security.h>
> @@ -3418,14 +3419,14 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
>  {
>         unsigned long maxcount;
>         struct xdr_stream *xdr = &resp->xdr;
> -       struct file *file = read->rd_filp;
> +       struct file *file;
>         int starting_len = xdr->buf->len;
> -       struct raparms *ra = NULL;
>         __be32 *p;
>
>         if (nfserr)
>                 goto out;
>
> +       file = read->rd_nf->nf_file;
>         p = xdr_reserve_space(xdr, 8); /* eof flag and byte count */
>         if (!p) {
>                 WARN_ON_ONCE(test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags));
> @@ -3445,24 +3446,17 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
>                          (xdr->buf->buflen - xdr->buf->len));
>         maxcount = min_t(unsigned long, maxcount, read->rd_length);
>
> -       if (read->rd_tmp_file)
> -               ra = nfsd_init_raparms(file);
> -
>         if (file->f_op->splice_read &&
>             test_bit(RQ_SPLICE_OK, &resp->rqstp->rq_flags))
>                 nfserr = nfsd4_encode_splice_read(resp, read, file, maxcount);
>         else
>                 nfserr = nfsd4_encode_readv(resp, read, file, maxcount);
>
> -       if (ra)
> -               nfsd_put_raparams(file, ra);
> -
>         if (nfserr)
>                 xdr_truncate_encode(xdr, starting_len);
> -
>  out:
> -       if (file)
> -               fput(file);
> +       if (read->rd_nf)
> +               nfsd_file_put(read->rd_nf);
>         return nfserr;
>  }
>
> diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> index 8a317de773b9..cf7e27199507 100644
> --- a/fs/nfsd/state.h
> +++ b/fs/nfsd/state.h
> @@ -585,7 +585,7 @@ struct nfsd_net;
>
>  extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
>                 struct nfsd4_compound_state *cstate, stateid_t *stateid,
> -               int flags, struct file **filp, bool *tmp_file);
> +               int flags, struct nfsd_file **filp);
>  __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
>                      stateid_t *stateid, unsigned char typemask,
>                      struct nfs4_stid **s, struct nfsd_net *nn);
> diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
> index 9f991007a578..ea016fb24675 100644
> --- a/fs/nfsd/xdr4.h
> +++ b/fs/nfsd/xdr4.h
> @@ -268,15 +268,14 @@ struct nfsd4_open_downgrade {
>
>
>  struct nfsd4_read {
> -       stateid_t       rd_stateid;         /* request */
> -       u64             rd_offset;          /* request */
> -       u32             rd_length;          /* request */
> -       int             rd_vlen;
> -       struct file     *rd_filp;
> -       bool            rd_tmp_file;
> +       stateid_t               rd_stateid;         /* request */
> +       u64                     rd_offset;          /* request */
> +       u32                     rd_length;          /* request */
> +       int                     rd_vlen;
> +       struct nfsd_file        *rd_nf;
>
> -       struct svc_rqst *rd_rqstp;          /* response */
> -       struct svc_fh * rd_fhp;             /* response */
> +       struct svc_rqst         *rd_rqstp;          /* response */
> +       struct svc_fh           *rd_fhp;             /* response */
>  };
>
>  struct nfsd4_readdir {
> --
> 2.4.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
