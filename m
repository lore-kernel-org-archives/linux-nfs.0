Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A67A8ECDE4B
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 18:43:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6FFE9204FD
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 18:43:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Jiil5BMC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6FFE9204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727231AbeKIEUY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 23:20:24 -0500
Received: from mail-ua1-f65.google.com ([209.85.222.65]:40298 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727074AbeKIEUY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Nov 2018 23:20:24 -0500
Received: by mail-ua1-f65.google.com with SMTP id n7so7574776uao.7
        for <linux-nfs@vger.kernel.org>; Thu, 08 Nov 2018 10:43:36 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DO1c8PH4sAvl043zZxIUTrwPOVt+AqNC6I9gUwJM4rQ=;
        b=Jiil5BMCVLujW7XgIPcjpsd+XP65+Cr2VDc1xm+2QiNfyj3+Fu3TTDvRLutJypVIux
         YjNBsquFA3oYteduYPWXP4laUeb3Jxcw9lfWGXxVfGPPpEEwDCYnxObgXvSEkjLOOaJE
         9kyssl+tn0HZefGhRWXtldjCinZ4cGRozxXchHgrrLgPJD+Ie4pNNfldyB1SEPPRZXjn
         FxRmyVUA/2CcgPXkniJDJsSmhVZTr4cD7uGMFExlAXUN4aH7WwX5nBDcfyCTlfOSTYkB
         FCI7w2AjLwowiH9d2bTaX7MnN4tYgVSCYrQi9pTgy/OCG9zMx4LHJirFN60XFRCIQohO
         T1vQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=DO1c8PH4sAvl043zZxIUTrwPOVt+AqNC6I9gUwJM4rQ=;
        b=lhRjrySlkCoy8K0IVhLUjPxh67v+i00tKHKGKw94xJrVRz3bIVPPlAQD0X6SYwetJf
         nS2ihRvpnMm/WSJ4Bah+gW0LJH1S1v4G0fUwHXojrA476WVK04XSZPEwsc3GZgLPeur2
         TS4t98pTjtYDXMh+QQLX1QSe9P7TsJGDeuqrlePbIPbLJUYvitOlZIAYYfXg9dtjIbxr
         xynzbeZ65aA7TORYQQQNMXb3XTl4OKizRhXE3c2gOWArL6imqiPKpldk2p+idHZGLH6a
         61+IqB7BocSu3VZjHrzJBy+Ed4BwaW+t/vSfGfkTnKAxKvyn1Smy3IYS9yKk9InedE3Z
         hxjA==
X-Gm-Message-State: AGRZ1gJivbiV/TvFpqH3UwZiG+ei2xErR5rpX3917Xb+tdxJHvrMT4M6
        cmpoY3bnUp9nwK30R3qhvxwpM+A5ZbvhDEkgfXVdlw==
X-Google-Smtp-Source: AJdET5fkVUqdZaj2ANu9xXo1Tbm5I8WMBo1OCI3qVwcmw0EmW7B/A2iw74AZnUVX+HLggPHW/GK5e4OcxXi6DX06nHs=
X-Received: by 2002:ab0:918:: with SMTP id w24mr2727796uag.51.1541702615903;
 Thu, 08 Nov 2018 10:43:35 -0800 (PST)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-11-olga.kornievskaia@gmail.com> <20181105213358.GB9111@fieldses.org>
In-Reply-To: <20181105213358.GB9111@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 8 Nov 2018 13:43:23 -0500
Message-ID: <CAN-5tyFydrJoRqCjaKbYeGknJ3KQR9ZV+ZK_YGjg_f=gCL3KrQ@mail.gmail.com>
Subject: Re: [PATCH v1 10/13] NFSD check stateids against copy stateids
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 5, 2018 at 4:33 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Oct 19, 2018 at 11:29:02AM -0400, Olga Kornievskaia wrote:
> > From: Olga Kornievskaia <kolga@netapp.com>
> >
> > Incoming stateid (used by a READ) could be a saved copy stateid.
> > On first use make it active and check that the copy has started
> > within the allowable lease time.
> >
> > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > ---
> >  fs/nfsd/nfs4state.c | 43 +++++++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 43 insertions(+)
> >
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index 7764a8b..16359de 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -5206,6 +5206,47 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
> >
> >       return 0;
> >  }
> > +/*
> > + * A READ from an inter server to server COPY will have a
> > + * copy stateid. Return the parent nfs4_stid.
> > + */
> > +static __be32 _find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
> > +                  struct nfs4_cpntf_state **cps)
> > +{
> > +     struct nfs4_cpntf_state *state = NULL;
> > +
> > +     if (st->si_opaque.so_clid.cl_id != nn->s2s_cp_cl_id)
> > +             return nfserr_bad_stateid;
> > +     spin_lock(&nn->s2s_cp_lock);
> > +     state = idr_find(&nn->s2s_cp_stateids, st->si_opaque.so_id);
> > +     spin_unlock(&nn->s2s_cp_lock);
> > +     if (!state)
> > +             return nfserr_bad_stateid;
> > +     *cps = state;
> > +     return 0;
> > +}
> > +
> > +static __be32 find_cpntf_state(struct nfsd_net *nn, stateid_t *st,
> > +                            struct nfs4_stid **stid)
> > +{
> > +     __be32 status;
> > +     struct nfs4_cpntf_state *cps = NULL;
> > +
> > +     status = _find_cpntf_state(nn, st, &cps);
> > +     if (status)
> > +             return status;
> > +
> > +     /* Did the inter server to server copy start in time? */
> > +     if (cps->cp_active == false && !time_after(cps->cp_timeout, jiffies))
>
> Is there any other time limit, or can the destination server keeping
> using this stateid indefinitely as long as it manages to get its first
> READ in before cp_timeout?

I don't believe there is anything in the spec that prohibits the
stateid from being used once it was started within a timeout period (a
copy might take a long time). Then it's invalidated either by
OFFLOAD_CANCEL or the parent stateid going away.

>
> > +             return nfserr_partner_no_auth;
> > +     else
> > +             cps->cp_active = true;
> > +
> > +     *stid = cps->cp_p_stid;
> > +     refcount_inc(&cps->cp_p_stid->sc_count);
>
> Does the caller hold some lock?  If not, what's prevnting cps from being
> freed before we get around to incrementing sc_count here?
>
> I would have expected the refcount_inc to happen before we drop
> s2s_cp_lock, but, like I say, maybe I'm missing some other locking.

No you are not missing it, the lock is taken only to find it in the
list. I'll move the refcount_inc into the lock section.

>
> --b.
>
> > +
> > +     return nfs_ok;
> > +}
> >
> >  /*
> >   * Checks for stateid operations
> > @@ -5238,6 +5279,8 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
> >       status = nfsd4_lookup_stateid(cstate, stateid,
> >                               NFS4_DELEG_STID|NFS4_OPEN_STID|NFS4_LOCK_STID,
> >                               &s, nn);
> > +     if (status == nfserr_bad_stateid)
> > +             status = find_cpntf_state(nn, stateid, &s);
> >       if (status)
> >               return status;
> >       status = nfsd4_stid_check_stateid_generation(stateid, s,
> > --
> > 1.8.3.1
