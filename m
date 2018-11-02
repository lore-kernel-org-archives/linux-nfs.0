Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9469C32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 19:25:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7BBF52082E
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 19:25:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="H2OL9kFA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7BBF52082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726147AbeKCEd4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Nov 2018 00:33:56 -0400
Received: from mail-vk1-f193.google.com ([209.85.221.193]:40254 "EHLO
        mail-vk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726024AbeKCEd4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Nov 2018 00:33:56 -0400
Received: by mail-vk1-f193.google.com with SMTP id v70so669287vkv.7
        for <linux-nfs@vger.kernel.org>; Fri, 02 Nov 2018 12:25:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NiZ9GmosHZmWPqyihJlGcPHlmB6t+/fWLTWgNzROcgk=;
        b=H2OL9kFAvJdrKF7C8wlY5Xy7KwP/q6cz4MbmVPalY4B2YquTKzgK8jvSIA+DLR5Ziv
         RHmaQ+MIF/4CCITNxHml9TpJkje972swU6szIuC+6fDJjt2MW7EJ3zKAs3Cg7XDGXvig
         o8OimsPA4hGMwa8GF948moruUaHk8R9OMSrRMxjvhU9EMky2BbEA8WIn8251+j+jZycU
         17uQnse4DlSLs0NGull7zYvf+g6skG/Lhfv2etg81RmR9/fdAw41chq4zxiHFy8dgcg9
         2LsJ3Lo+MSzIwAGEvHAD+PMwCQN0piXvWS3L4co2VXtC5bZJ6NVcnmS5ACRAOoUZl51O
         P2Hw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=NiZ9GmosHZmWPqyihJlGcPHlmB6t+/fWLTWgNzROcgk=;
        b=hTYTdfqrGNxbBGtsHEU9hczidq6SDJzbQQOGi2uwEvrMwfygaVWPzHyzM5CZZHebiM
         RYhQqa7kZcNvOyWj1Umd629sK+5fF9BnZHabr2MGgJVZshN6hrZTnRQB/JZbph2EqlR1
         EG/lqpGZRdKmSTAF1n66AIrIjatuU2WoUobAX/DzbZnyCsunFS7/IViw3XEB4bV/1P67
         uIjU2jrD1Aw/O7Ga/8+2kOOKzV71i+noay68hkHMqz87svDtt4ZtWLYSl6+OC1T0spLL
         Pu1+OobKaiFg3XBw7IV1CCFcVtx13C6QA4CWYQP9F4q7snNd713u5miltkFkGQfDI63N
         KDCw==
X-Gm-Message-State: AGRZ1gJxb36G1RzHeMS4bTmsoz6RwS9xRDJVOFZXt7D1HzLJnmr8531o
        4x5/gp01et46jCRUgKJSgyfeX+WbkjbNhdJe2M0=
X-Google-Smtp-Source: AJdET5eaTw3Z+HPZ8Kt6Hrw8SBoZkjj8gQCawkJfLwAFRPDKpjmlXeZbBv8RCgP/EFIIzIsHGVdwNz1VUdtyzjmWeUE=
X-Received: by 2002:a1f:ac4:: with SMTP id 187mr5580420vkk.31.1541186730409;
 Fri, 02 Nov 2018 12:25:30 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-9-olga.kornievskaia@gmail.com> <20181102190545.GC21442@fieldses.org>
In-Reply-To: <20181102190545.GC21442@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Fri, 2 Nov 2018 15:25:18 -0400
Message-ID: <CAN-5tyE+y54BmcBaCoriexUTYQ4rUEieaPswmiZ7ahUssLMnYw@mail.gmail.com>
Subject: Re: [PATCH v1 08/13] NFSD return nfs4_stid in nfs4_preprocess_stateid_op
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 2, 2018 at 3:06 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Oct 19, 2018 at 11:29:00AM -0400, Olga Kornievskaia wrote:
> > Needed for copy to add nfs4_cp_state to the nfs4_stid.
> >
> > Signed-off-by: Andy Adamson <andros@netapp.com>
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/nfsd/nfs4proc.c  | 17 ++++++++++-------
> >  fs/nfsd/nfs4state.c |  8 ++++++--
> >  fs/nfsd/state.h     |  3 ++-
> >  3 files changed, 18 insertions(+), 10 deletions(-)
> >
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index edff074..29686df 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -781,7 +781,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
>
> By the way, I wonder why git-diff is doing such a bad job of guessing
> the right function?  Not a big deal, the patches still apply fine, it
> just makes reading them in email a little harder.

Could it be because I worked against Trond's git repo (as that's my
default location)? This is against whatever is in 4.19-rc6. This is
also git from RHEL7.4 (1.8.3.1 version), don't know if that matters.
In the next version, I do the patches against your git repo. Hopefully
it'll be better.

>
> --b.
>
> >       /* check stateid */
> >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> >                                       &read->rd_stateid, RD_STATE,
> > -                                     &read->rd_filp, &read->rd_tmp_file);
> > +                                     &read->rd_filp, &read->rd_tmp_file,
> > +                                     NULL);
> >       if (status) {
> >               dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
> >               goto out;
> > @@ -954,7 +955,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
> >       if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
> >               status = nfs4_preprocess_stateid_op(rqstp, cstate,
> >                               &cstate->current_fh, &setattr->sa_stateid,
> > -                             WR_STATE, NULL, NULL);
> > +                             WR_STATE, NULL, NULL, NULL);
> >               if (status) {
> >                       dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
> >                       return status;
> > @@ -1005,7 +1006,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
> >       trace_nfsd_write_start(rqstp, &cstate->current_fh,
> >                              write->wr_offset, cnt);
> >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> > -                                             stateid, WR_STATE, &filp, NULL);
> > +                                     stateid, WR_STATE, &filp, NULL, NULL);
> >       if (status) {
> >               dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
> >               return status;
> > @@ -1039,14 +1040,16 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
> >       __be32 status;
> >
> >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
> > -                                         src_stateid, RD_STATE, src, NULL);
> > +                                         src_stateid, RD_STATE, src, NULL,
> > +                                         NULL);
> >       if (status) {
> >               dprintk("NFSD: %s: couldn't process src stateid!\n", __func__);
> >               goto out;
> >       }
> >
> >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> > -                                         dst_stateid, WR_STATE, dst, NULL);
> > +                                         dst_stateid, WR_STATE, dst, NULL,
> > +                                         NULL);
> >       if (status) {
> >               dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
> >               goto out_put_src;
> > @@ -1350,7 +1353,7 @@ struct nfsd4_copy *
> >
> >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> >                                           &fallocate->falloc_stateid,
> > -                                         WR_STATE, &file, NULL);
> > +                                         WR_STATE, &file, NULL, NULL);
> >       if (status != nfs_ok) {
> >               dprintk("NFSD: nfsd4_fallocate: couldn't process stateid!\n");
> >               return status;
> > @@ -1409,7 +1412,7 @@ struct nfsd4_copy *
> >
> >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> >                                           &seek->seek_stateid,
> > -                                         RD_STATE, &file, NULL);
> > +                                         RD_STATE, &file, NULL, NULL);
> >       if (status) {
> >               dprintk("NFSD: nfsd4_seek: couldn't process stateid!\n");
> >               return status;
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 07a57d0..e263fd0 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -5159,7 +5159,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
> >  __be32
> >  nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
> >               struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
> > -             stateid_t *stateid, int flags, struct file **filpp, bool *tmp_file)
> > +             stateid_t *stateid, int flags, struct file **filpp,
> > +             bool *tmp_file, struct nfs4_stid **cstid)
> >  {
> >       struct inode *ino = d_inode(fhp->fh_dentry);
> >       struct net *net = SVC_NET(rqstp);
> > @@ -5210,8 +5211,11 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
> >       if (!status && filpp)
> >               status = nfs4_check_file(rqstp, fhp, s, filpp, tmp_file, flags);
> >  out:
> > -     if (s)
> > +     if (s) {
> > +             if (!status && cstid)
> > +                     *cstid = s;
> >               nfs4_put_stid(s);
> > +     }
> >       return status;
> >  }
> >
> > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > index 6aacb32..304de3b 100644
> > --- a/fs/nfsd/state.h
> > +++ b/fs/nfsd/state.h
> > @@ -606,7 +606,8 @@ struct nfsd4_blocked_lock {
> >
> >  extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
> >               struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
> > -             stateid_t *stateid, int flags, struct file **filp, bool *tmp_file);
> > +             stateid_t *stateid, int flags, struct file **filp,
> > +             bool *tmp_file, struct nfs4_stid **cstid);
> >  __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
> >                    stateid_t *stateid, unsigned char typemask,
> >                    struct nfs4_stid **s, struct nfsd_net *nn);
> > --
> > 1.8.3.1
