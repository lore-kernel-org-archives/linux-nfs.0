Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F83FC46475
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 02:58:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D24D12082F
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 02:58:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lyRyEqTX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D24D12082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726082AbeJXLYH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Oct 2018 07:24:07 -0400
Received: from mail-vs1-f67.google.com ([209.85.217.67]:36539 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725979AbeJXLYH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Oct 2018 07:24:07 -0400
Received: by mail-vs1-f67.google.com with SMTP id c205so2243158vsd.3
        for <linux-nfs@vger.kernel.org>; Tue, 23 Oct 2018 19:58:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Pj66CcUa9KE1jkTdN1i6xWH6nAbNVSBtbYQsG6hU5Ic=;
        b=lyRyEqTX+0ATOyBX5/LKDxqA8zO/Ez69q1bBf9zb/c2oqhqzl1AyD/Fq6/ppDds3qQ
         cSuOAF0Wl3a1w+cd6NqtahrjXkPqurdIeZZLiBc6nH5m45j7p/dywAYfA+JtGztK2s/c
         kcdLrhABInmdRNtazapacp5LcCNtHt2c12uyBk76JSDWwZyZvH50tnFmror+f3y1oYzF
         +FvX+eMbDecZLTMAcXksS3+Z3ssEdWZUZqnkzlVLsl3ABimvCEfNFZ3d3l11WV5IRQkk
         V+Y071OYIQpCHBYzbaIhMXddKQZxJo6c2ZpQo6ldbZUgaOA4e6v5dXaVoB8FVa301ahW
         wI2g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Pj66CcUa9KE1jkTdN1i6xWH6nAbNVSBtbYQsG6hU5Ic=;
        b=EY45FwPbDXrSxBmmQPXvTmt90Jy0Eox3YVmTm8LUTYcXgsRjAC4UeKhFfpQ1k6worm
         i+VcDSZnS3sHBd5yZ+O09Xc8iQZvgOVEKJqJd2A7MZjb00BA90QJe/rMJSfHjXk7mLgH
         IhgV+M8jcLBIrJj0LgLjAZv8zuwm0nir0drA/sF1x732fDvdmvPA50WSGjT4k1V2QhGQ
         AhnSgiRj47Xr+nV7/wLgmdnAIufcyUgwJ//gJteN1tZ2QrlbU99HaZ8SFSrpA+c6SbCq
         uNsRi34ANBdwN818ql43ite32dO07Y413Q22ZEWTC+HPU+NIUDr0OoJAQZPvh+qtWCD4
         A4IA==
X-Gm-Message-State: AGRZ1gL8lhyqRlA6skav2dgc8N+bmOHj+Wt0GkNYSEsUt04AcesOnAP2
        a7+g8DykEXuP7Lo1u/r+qsswnrisBTOyXxZibuMu0A==
X-Google-Smtp-Source: AJdET5eRKCIImzX0IMrd5N2NSE5OBsQ5eCnangzP3yi7xmnx42c/05yjoyNi2me5BEMmglOIBQFKzxMiV41FkdRvueU=
X-Received: by 2002:a67:3793:: with SMTP id j19mr240324vsi.215.1540343792658;
 Tue, 23 Oct 2018 18:16:32 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152932.32462-1-olga.kornievskaia@gmail.com>
 <20181019152932.32462-9-olga.kornievskaia@gmail.com> <ee6447e40382045f094789026ce2264001ab89b4.camel@netapp.com>
In-Reply-To: <ee6447e40382045f094789026ce2264001ab89b4.camel@netapp.com>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Tue, 23 Oct 2018 21:16:20 -0400
Message-ID: <CAN-5tyEZU0A153h_oPU+ruPqp3Vh0On9T-GDFYxyqCti6u=hpA@mail.gmail.com>
Subject: Re: [PATCH v1 08/11] NFS inter ssc open
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Oct 23, 2018 at 4:23 PM Schumaker, Anna
<Anna.Schumaker@netapp.com> wrote:
>
> Hi Olga,
>
> On Fri, 2018-10-19 at 11:29 -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > NFSv4.2 inter server to server copy requires the destination server to
> > READ the data from the source server using the provided stateid and
> > file handle.
> >
> > Given an NFSv4 stateid and filehandle from the COPY operaion, provide the
> > destination server with an NFS client function to create a struct file
> > suitable for the destiniation server to READ the data to be copied.
> >
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/nfs/nfs4_fs.h  |  7 ++++
> >  fs/nfs/nfs4file.c | 98
> > +++++++++++++++++++++++++++++++++++++++++++++++++++++++
> >  fs/nfs/nfs4proc.c |  5 ++-
> >  3 files changed, 107 insertions(+), 3 deletions(-)
> >
> > diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> > index 8d59c96..f229864 100644
> > --- a/fs/nfs/nfs4_fs.h
> > +++ b/fs/nfs/nfs4_fs.h
> > @@ -307,6 +307,13 @@ extern int nfs4_set_rw_stateid(nfs4_stateid *stateid,
> >               const struct nfs_open_context *ctx,
> >               const struct nfs_lock_context *l_ctx,
> >               fmode_t fmode);
> > +extern int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh
> > *fhandle,
> > +                          struct nfs_fattr *fattr, struct nfs4_label *label,
> > +                          struct inode *inode);
> > +extern int update_open_stateid(struct nfs4_state *state,
> > +                             const nfs4_stateid *open_stateid,
> > +                             const nfs4_stateid *deleg_stateid,
> > +                             fmode_t fmode);
> >
> >  #if defined(CONFIG_NFS_V4_1)
> >  extern int nfs41_sequence_done(struct rpc_task *, struct nfs4_sequence_res
> > *);
> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > index 005862e..7f226f4 100644
> > --- a/fs/nfs/nfs4file.c
> > +++ b/fs/nfs/nfs4file.c
> > @@ -8,6 +8,7 @@
> >  #include <linux/file.h>
> >  #include <linux/falloc.h>
> >  #include <linux/nfs_fs.h>
> > +#include <linux/file.h>
> >  #include "delegation.h"
> >  #include "internal.h"
> >  #include "iostat.h"
> > @@ -264,6 +265,103 @@ static int nfs42_clone_file_range(struct file *src_file,
> > loff_t src_off,
> >  out:
> >       return ret;
> >  }
> > +
> > +static int read_name_gen = 1;
> > +#define SSC_READ_NAME_BODY "ssc_read_%d"
> > +
> > +struct file *
> > +nfs42_ssc_open(struct vfsmount *ss_mnt, struct nfs_fh *src_fh,
> > +             nfs4_stateid *stateid)
> > +{
> > +     struct nfs_fattr fattr;
> > +     struct file *filep, *res;
> > +     struct nfs_server *server;
> > +     struct inode *r_ino = NULL;
> > +     struct nfs_open_context *ctx;
> > +     struct nfs4_state_owner *sp;
> > +     char *read_name;
> > +     int len, status = 0;
> > +
> > +     server = NFS_SERVER(ss_mnt->mnt_root->d_inode);
> > +
> > +     nfs_fattr_init(&fattr);
> > +
> > +     status = nfs4_proc_getattr(server, src_fh, &fattr, NULL, NULL);
> > +     if (status < 0) {
> > +             res = ERR_PTR(status);
> > +             goto out;
> > +     }
> > +
> > +     res = ERR_PTR(-ENOMEM);
> > +     len = strlen(SSC_READ_NAME_BODY) + 16;
> > +     read_name = kzalloc(len, GFP_NOFS);
> > +     if (read_name == NULL)
> > +             goto out;
> > +     snprintf(read_name, len, SSC_READ_NAME_BODY, read_name_gen++);
> > +     dprintk("%s read_name %s\n", __func__, read_name);
>
> Does this dprintk() need to be here?

Nope, doesn't need to be here, a left over debugging. I'll remove it.

> I'm wondering if it would work better as a
> tracepoint (or if it should just be removed altogether).
>
> Thanks,
> Anna
>
> > +
> > +     r_ino = nfs_fhget(ss_mnt->mnt_root->d_inode->i_sb, src_fh, &fattr,
> > +                     NULL);
> > +     if (IS_ERR(r_ino)) {
> > +             res = ERR_CAST(r_ino);
> > +             goto out;
> > +     }
> > +
> > +     filep = alloc_file_pseudo(r_ino, ss_mnt, read_name, FMODE_READ,
> > +                                  r_ino->i_fop);
> > +     if (IS_ERR(filep)) {
> > +             res = ERR_CAST(filep);
> > +             goto out;
> > +     }
> > +     filep->f_mode |= FMODE_READ;
> > +
> > +     ctx = alloc_nfs_open_context(filep->f_path.dentry, filep->f_mode,
> > +                                     filep);
> > +     if (IS_ERR(ctx)) {
> > +             res = ERR_CAST(ctx);
> > +             goto out_filep;
> > +     }
> > +
> > +     res = ERR_PTR(-EINVAL);
> > +     sp = nfs4_get_state_owner(server, ctx->cred, GFP_KERNEL);
> > +     if (sp == NULL)
> > +             goto out_ctx;
> > +
> > +     ctx->state = nfs4_get_open_state(r_ino, sp);
> > +     if (ctx->state == NULL)
> > +             goto out_stateowner;
> > +
> > +     set_bit(NFS_OPEN_STATE, &ctx->state->flags);
> > +     memcpy(&ctx->state->open_stateid.other, &stateid->other,
> > +            NFS4_STATEID_OTHER_SIZE);
> > +     update_open_stateid(ctx->state, stateid, NULL, filep->f_mode);
> > +
> > +     nfs_file_set_open_context(filep, ctx);
> > +     put_nfs_open_context(ctx);
> > +
> > +     file_ra_state_init(&filep->f_ra, filep->f_mapping->host->i_mapping);
> > +     res = filep;
> > +out:
> > +     dprintk("<-- %s error %ld filep %p r_ino %p\n",
> > +             __func__, IS_ERR(res) ? PTR_ERR(res) : 0, res, r_ino);
> > +
> > +     return res;
> > +out_stateowner:
> > +     nfs4_put_state_owner(sp);
> > +out_ctx:
> > +     put_nfs_open_context(ctx);
> > +out_filep:
> > +     fput(filep);
> > +     goto out;
> > +}
> > +EXPORT_SYMBOL_GPL(nfs42_ssc_open);
> > +void nfs42_ssc_close(struct file *filep)
> > +{
> > +     struct nfs_open_context *ctx = nfs_file_open_context(filep);
> > +
> > +     ctx->state->flags = 0;
> > +}
> > +EXPORT_SYMBOL_GPL(nfs42_ssc_close);
> >  #endif /* CONFIG_NFS_V4_2 */
> >
> >  const struct file_operations nfs4_file_operations = {
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index fec6e6b..e5178b2f 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -91,7 +91,6 @@
> >  static int _nfs4_recover_proc_open(struct nfs4_opendata *data);
> >  static int nfs4_do_fsinfo(struct nfs_server *, struct nfs_fh *, struct
> > nfs_fsinfo *);
> >  static void nfs_fixup_referral_attributes(struct nfs_fattr *fattr);
> > -static int nfs4_proc_getattr(struct nfs_server *, struct nfs_fh *, struct
> > nfs_fattr *, struct nfs4_label *label, struct inode *inode);
> >  static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh
> > *fhandle, struct nfs_fattr *fattr, struct nfs4_label *label, struct inode
> > *inode);
> >  static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
> >                           struct nfs_fattr *fattr, struct iattr *sattr,
> > @@ -1653,7 +1652,7 @@ static void nfs_state_clear_delegation(struct nfs4_state
> > *state)
> >       write_sequnlock(&state->seqlock);
> >  }
> >
> > -static int update_open_stateid(struct nfs4_state *state,
> > +int update_open_stateid(struct nfs4_state *state,
> >               const nfs4_stateid *open_stateid,
> >               const nfs4_stateid *delegation,
> >               fmode_t fmode)
> > @@ -3936,7 +3935,7 @@ static int _nfs4_proc_getattr(struct nfs_server *server,
> > struct nfs_fh *fhandle,
> >       return nfs4_call_sync(server->client, server, &msg, &args.seq_args,
> > &res.seq_res, 0);
> >  }
> >
> > -static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh
> > *fhandle,
> > +int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
> >                               struct nfs_fattr *fattr, struct nfs4_label
> > *label,
> >                               struct inode *inode)
> >  {
