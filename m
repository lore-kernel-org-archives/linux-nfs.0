Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35A7EC0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:38:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D208620657
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 20:38:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fjXZm5J2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D208620657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726021AbeKBFn3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 2 Nov 2018 01:43:29 -0400
Received: from mail-ua1-f65.google.com ([209.85.222.65]:41546 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725963AbeKBFn3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Nov 2018 01:43:29 -0400
Received: by mail-ua1-f65.google.com with SMTP id o17so7695956uad.8
        for <linux-nfs@vger.kernel.org>; Thu, 01 Nov 2018 13:38:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ftkUo6LueuXbfZA5QARSkldMch1EvMJMIujMKRrk9UE=;
        b=fjXZm5J2X/vM44TSw8uZ21enWLyuaY7bXezJ7xd7+qIGPAwx4ve+AnkW4OwEhpHxtz
         ueJ1HV2bLcSzW3rrHD+710bjuuUg2JXcjBUACPROJWIxZd59BsGU0OH9MhP7JyfcxLpl
         dUSukzzFIFogS77waFc998sPFejKTwYcTCzb8vHQIvKwR6tVU4L+z4kBHdZfWFrvPLKq
         wfMpaUrHOZBaoqWVjFp1hsncWs2SVL9HC/69QK05s8Lhnn4NIDavn8K/xdxxdyNu3aYn
         AACMaTcnd0a6C3x0iBspGpBF6DJxl9x3YSibgcmefg2L06hbZrFTQONUtlChULR/g6Uc
         h8bQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=ftkUo6LueuXbfZA5QARSkldMch1EvMJMIujMKRrk9UE=;
        b=TgmfMYwYNjVNWKKKma3N3Y+FfeSEx5/9Mgv9difuWFJtG6PXexnV/Zd3eAEj4cEpsd
         PmdGmIn+oxqBqDadUsODOU2dPUeLhrXEIXGUQutx4NZXDS5LJLUh5kgmJWnePsgcbHlC
         q9NXh91Vprj9YhUDmBzDL46bQqZa93+8P5RkV70oHH57pf1bUaQfu7vNeygVKY2wDGrr
         5b6CJZDZXnsB9upvx1NsWLJjLAZ6mDTYp8U8m6VgbFJ53hO+ko42mQJEMD9Z2ZIG8H0I
         JmOpPSNbXiZaycz/3E9s8xvVakTszcxTchC9beD0QKARptzGAgZmMyJI3uyd0zzgOJDV
         NMFQ==
X-Gm-Message-State: AGRZ1gK63zRCjR6N7qsC6Qg+wMyGfVJBZ9viUoUMGE/QWHPCujTthpIC
        4aNPSS51/krv3UhXhvpDEo7LejGTlhl2BsswPGw=
X-Google-Smtp-Source: AJdET5dT0fjGsQ0jVUZombaP9UDve1+11GtM3Yp95MRMTxL7rgqp1aPI87zAD6CBDFLKIUKYcTPjzstQ13+CjUGERvk=
X-Received: by 2002:ab0:60da:: with SMTP id g26mr340773uam.104.1541104735498;
 Thu, 01 Nov 2018 13:38:55 -0700 (PDT)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-6-olga.kornievskaia@gmail.com> <20181101201955.GB12930@fieldses.org>
In-Reply-To: <20181101201955.GB12930@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 1 Nov 2018 16:38:43 -0400
Message-ID: <CAN-5tyF08cLZAtPivj7t_f94HgY7mC3zBh=vp0E8Ez-GQhL7RA@mail.gmail.com>
Subject: Re: [PATCH v1 05/13] NFS skip recovery of copy open on dest server
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Nov 1, 2018 at 4:20 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Oct 19, 2018 at 11:28:57AM -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > Mark the open created for the source file on the destination
> > server. Then if this open is going thru a recovery, then fail
> > the recovery as we don't need to be recoving a "fake" open.
> > We need to fail the ongoing READs and vfs_copy_file_range().
>
> Nothing to do with this patch, really, but:

And because it not related to this patch, then I'm confused.

> I'm not always a stickler about the 80-character-column rule, but, man,
> nfs4_reclaim_open_state is deeply nested, could that be broken up a
> little?

really? it's nested? Anna reworked the reclaim state code and nesting
has gone done considerably. It's only 2 tabs in?

>  Also I notice there's a printk("AGLO: ...") in there that you
> probably didn't mean to leave upstream?

I don't believe I've ever had a printk() in the code. I did have a
leftover dprintk() and that has since been removed.

It looks like my attempt at providing you with the client side patches
might have created a problem where you are reviewing (now) an outdated
code. I never expected you to review the client side patches. However,
if you are so inclined then could you please just look at my latest
submission (v8) of the client patches as oppose to looking the version
submitted for the nfsd.

>
> --b.
>
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/nfs/nfs4_fs.h   |  1 +
> >  fs/nfs/nfs4file.c  |  1 +
> >  fs/nfs/nfs4state.c | 14 ++++++++++++++
> >  3 files changed, 16 insertions(+)
> >
> > diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
> > index f229864..8b00c90 100644
> > --- a/fs/nfs/nfs4_fs.h
> > +++ b/fs/nfs/nfs4_fs.h
> > @@ -165,6 +165,7 @@ enum {
> >       NFS_STATE_CHANGE_WAIT,          /* A state changing operation is outstanding */
> >  #ifdef CONFIG_NFS_V4_2
> >       NFS_CLNT_DST_SSC_COPY_STATE,    /* dst server open state on client*/
> > +     NFS_SRV_SSC_COPY_STATE,         /* ssc state on the dst server */
> >  #endif /* CONFIG_NFS_V4_2 */
> >  };
> >
> > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > index f82cb05..7909cd4 100644
> > --- a/fs/nfs/nfs4file.c
> > +++ b/fs/nfs/nfs4file.c
> > @@ -309,6 +309,7 @@ struct file *
> >       if (ctx->state == NULL)
> >               goto out_stateowner;
> >
> > +     set_bit(NFS_SRV_SSC_COPY_STATE, &ctx->state->flags);
> >       set_bit(NFS_OPEN_STATE, &ctx->state->flags);
> >       memcpy(&ctx->state->open_stateid.other, &stateid->other,
> >              NFS4_STATEID_OTHER_SIZE);
> > diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
> > index 62ae0fd..b0b82c6 100644
> > --- a/fs/nfs/nfs4state.c
> > +++ b/fs/nfs/nfs4state.c
> > @@ -1606,6 +1606,9 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
> >  {
> >       struct nfs4_state *state;
> >       int status = 0;
> > +#ifdef CONFIG_NFS_V4_2
> > +     bool found_ssc_copy_state = false;
> > +#endif /* CONFIG_NFS_V4_2 */
> >
> >       /* Note: we rely on the sp->so_states list being ordered
> >        * so that we always reclaim open(O_RDWR) and/or open(O_WRITE)
> > @@ -1625,6 +1628,13 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
> >                       continue;
> >               if (state->state == 0)
> >                       continue;
> > +#ifdef CONFIG_NFS_V4_2
> > +             if (test_bit(NFS_SRV_SSC_COPY_STATE, &state->flags)) {
> > +                     nfs4_state_mark_recovery_failed(state, -EIO);
> > +                     found_ssc_copy_state = true;
> > +                     continue;
> > +             }
> > +#endif /* CONFIG_NFS_V4_2 */
> >               refcount_inc(&state->count);
> >               spin_unlock(&sp->so_lock);
> >               status = __nfs4_reclaim_open_state(sp, state, ops);
> > @@ -1671,6 +1681,10 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
> >       }
> >       raw_write_seqcount_end(&sp->so_reclaim_seqcount);
> >       spin_unlock(&sp->so_lock);
> > +#ifdef CONFIG_NFS_V4_2
> > +     if (found_ssc_copy_state)
> > +             return -EIO;
> > +#endif /* CONFIG_NFS_V4_2 */
> >       return 0;
> >  out_err:
> >       nfs4_put_open_state(state);
> > --
> > 1.8.3.1
