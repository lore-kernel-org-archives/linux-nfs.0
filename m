Return-Path: <SRS0=leyo=NN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E299C32789
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 19:53:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CBA1F20831
	for <linux-nfs@archiver.kernel.org>; Fri,  2 Nov 2018 19:53:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CBA1F20831
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fieldses.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726081AbeKCFCG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Nov 2018 01:02:06 -0400
Received: from fieldses.org ([173.255.197.46]:57930 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726498AbeKCFCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 3 Nov 2018 01:02:05 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 5AB9E3F3; Fri,  2 Nov 2018 15:53:35 -0400 (EDT)
Date:   Fri, 2 Nov 2018 15:53:35 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 08/13] NFSD return nfs4_stid in
 nfs4_preprocess_stateid_op
Message-ID: <20181102195335.GE21442@fieldses.org>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-9-olga.kornievskaia@gmail.com>
 <20181102190545.GC21442@fieldses.org>
 <CAN-5tyE+y54BmcBaCoriexUTYQ4rUEieaPswmiZ7ahUssLMnYw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyE+y54BmcBaCoriexUTYQ4rUEieaPswmiZ7ahUssLMnYw@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Nov 02, 2018 at 03:25:18PM -0400, Olga Kornievskaia wrote:
> On Fri, Nov 2, 2018 at 3:06 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Fri, Oct 19, 2018 at 11:29:00AM -0400, Olga Kornievskaia wrote:
> > > Needed for copy to add nfs4_cp_state to the nfs4_stid.
> > >
> > > Signed-off-by: Andy Adamson <andros@netapp.com>
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > ---
> > >  fs/nfsd/nfs4proc.c  | 17 ++++++++++-------
> > >  fs/nfsd/nfs4state.c |  8 ++++++--
> > >  fs/nfsd/state.h     |  3 ++-
> > >  3 files changed, 18 insertions(+), 10 deletions(-)
> > >
> > > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > > index edff074..29686df 100644
> > > --- a/fs/nfsd/nfs4proc.c
> > > +++ b/fs/nfsd/nfs4proc.c
> > > @@ -781,7 +781,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
> >
> > By the way, I wonder why git-diff is doing such a bad job of guessing
> > the right function?  Not a big deal, the patches still apply fine, it
> > just makes reading them in email a little harder.
> 
> Could it be because I worked against Trond's git repo (as that's my
> default location)? This is against whatever is in 4.19-rc6. This is
> also git from RHEL7.4 (1.8.3.1 version), don't know if that matters.
> In the next version, I do the patches against your git repo. Hopefully
> it'll be better.

I dunno.  I just spent more time than it's worth trying to figure out
what's going on.

I think it's ignoring functions written like

	static int
	somefunction(int arg1, int arg2,...)

and instead only catching functions like

	static int somefunction(int arg1, int arg2,...)

I'm using git version 2.17.2, your patches seem to be generated with
1.8.3.1, so that may be the difference, though I looked at the git logs
for git and didn't see an obvious commit saying "here we fixed the regex
that identifies C functions".  There are also configuration options (see
man gitattributes, under the "Defining a custom hunk-header" heading for
too many details), but I can't imagine why you'd have those set
differently.

Whatever, it's not important.

--b.

> 
> >
> > --b.
> >
> > >       /* check stateid */
> > >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> > >                                       &read->rd_stateid, RD_STATE,
> > > -                                     &read->rd_filp, &read->rd_tmp_file);
> > > +                                     &read->rd_filp, &read->rd_tmp_file,
> > > +                                     NULL);
> > >       if (status) {
> > >               dprintk("NFSD: nfsd4_read: couldn't process stateid!\n");
> > >               goto out;
> > > @@ -954,7 +955,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
> > >       if (setattr->sa_iattr.ia_valid & ATTR_SIZE) {
> > >               status = nfs4_preprocess_stateid_op(rqstp, cstate,
> > >                               &cstate->current_fh, &setattr->sa_stateid,
> > > -                             WR_STATE, NULL, NULL);
> > > +                             WR_STATE, NULL, NULL, NULL);
> > >               if (status) {
> > >                       dprintk("NFSD: nfsd4_setattr: couldn't process stateid!\n");
> > >                       return status;
> > > @@ -1005,7 +1006,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
> > >       trace_nfsd_write_start(rqstp, &cstate->current_fh,
> > >                              write->wr_offset, cnt);
> > >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> > > -                                             stateid, WR_STATE, &filp, NULL);
> > > +                                     stateid, WR_STATE, &filp, NULL, NULL);
> > >       if (status) {
> > >               dprintk("NFSD: nfsd4_write: couldn't process stateid!\n");
> > >               return status;
> > > @@ -1039,14 +1040,16 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
> > >       __be32 status;
> > >
> > >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
> > > -                                         src_stateid, RD_STATE, src, NULL);
> > > +                                         src_stateid, RD_STATE, src, NULL,
> > > +                                         NULL);
> > >       if (status) {
> > >               dprintk("NFSD: %s: couldn't process src stateid!\n", __func__);
> > >               goto out;
> > >       }
> > >
> > >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> > > -                                         dst_stateid, WR_STATE, dst, NULL);
> > > +                                         dst_stateid, WR_STATE, dst, NULL,
> > > +                                         NULL);
> > >       if (status) {
> > >               dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
> > >               goto out_put_src;
> > > @@ -1350,7 +1353,7 @@ struct nfsd4_copy *
> > >
> > >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> > >                                           &fallocate->falloc_stateid,
> > > -                                         WR_STATE, &file, NULL);
> > > +                                         WR_STATE, &file, NULL, NULL);
> > >       if (status != nfs_ok) {
> > >               dprintk("NFSD: nfsd4_fallocate: couldn't process stateid!\n");
> > >               return status;
> > > @@ -1409,7 +1412,7 @@ struct nfsd4_copy *
> > >
> > >       status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> > >                                           &seek->seek_stateid,
> > > -                                         RD_STATE, &file, NULL);
> > > +                                         RD_STATE, &file, NULL, NULL);
> > >       if (status) {
> > >               dprintk("NFSD: nfsd4_seek: couldn't process stateid!\n");
> > >               return status;
> > > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > > index 07a57d0..e263fd0 100644
> > > --- a/fs/nfsd/nfs4state.c
> > > +++ b/fs/nfsd/nfs4state.c
> > > @@ -5159,7 +5159,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
> > >  __be32
> > >  nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
> > >               struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
> > > -             stateid_t *stateid, int flags, struct file **filpp, bool *tmp_file)
> > > +             stateid_t *stateid, int flags, struct file **filpp,
> > > +             bool *tmp_file, struct nfs4_stid **cstid)
> > >  {
> > >       struct inode *ino = d_inode(fhp->fh_dentry);
> > >       struct net *net = SVC_NET(rqstp);
> > > @@ -5210,8 +5211,11 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
> > >       if (!status && filpp)
> > >               status = nfs4_check_file(rqstp, fhp, s, filpp, tmp_file, flags);
> > >  out:
> > > -     if (s)
> > > +     if (s) {
> > > +             if (!status && cstid)
> > > +                     *cstid = s;
> > >               nfs4_put_stid(s);
> > > +     }
> > >       return status;
> > >  }
> > >
> > > diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
> > > index 6aacb32..304de3b 100644
> > > --- a/fs/nfsd/state.h
> > > +++ b/fs/nfsd/state.h
> > > @@ -606,7 +606,8 @@ struct nfsd4_blocked_lock {
> > >
> > >  extern __be32 nfs4_preprocess_stateid_op(struct svc_rqst *rqstp,
> > >               struct nfsd4_compound_state *cstate, struct svc_fh *fhp,
> > > -             stateid_t *stateid, int flags, struct file **filp, bool *tmp_file);
> > > +             stateid_t *stateid, int flags, struct file **filp,
> > > +             bool *tmp_file, struct nfs4_stid **cstid);
> > >  __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
> > >                    stateid_t *stateid, unsigned char typemask,
> > >                    struct nfs4_stid **s, struct nfsd_net *nn);
> > > --
> > > 1.8.3.1
