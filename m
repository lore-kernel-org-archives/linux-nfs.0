Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9202AECDE4B
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 18:37:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4ABEA20684
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 18:37:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QTUAUwba"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4ABEA20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726845AbeKIEOn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 23:14:43 -0500
Received: from mail-vs1-f67.google.com ([209.85.217.67]:37410 "EHLO
        mail-vs1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726801AbeKIEOn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Nov 2018 23:14:43 -0500
Received: by mail-vs1-f67.google.com with SMTP id h18so12213787vsj.4
        for <linux-nfs@vger.kernel.org>; Thu, 08 Nov 2018 10:37:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bATul5rC2wtqzHeuLTxfTueZsYLJutd7FnoiB9bGI74=;
        b=QTUAUwbaQ+5tRbJXSGJkA5+8rt99Ft5oheOOQn2FKM5UNZ1J8k13kvnTsaw+Our0x/
         UawfM0iScS5t393RTCszspHCZy6mBpKvMSerexizEpj6N+m+toxf9HWDSEOT4hg32gsX
         Uy3OvtSHHB0vbWDu29eWUyCeZcqlSf8kFlJeWvf7HG1WBfhleoUSMs8yaZa1aJ17/m1I
         Rev0DIhdt1BK5GYoLSBHXcDePg2G+S9KnYVZLUq7zK86GnCydHVgn3fL1/JCQ6iY/m8+
         M+mfFPadZomTOGOpHqPNJyyd+eYoU7UQ76WHNy7XYjvl8tw80GamogY0S2gPLuyU+kDX
         rjtA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=bATul5rC2wtqzHeuLTxfTueZsYLJutd7FnoiB9bGI74=;
        b=DphKuj98T9k1Ofshsu7y6OI8FNJ+iVU04lD7QjS9rHAnd16EuJq46NPlC7y7WnROrr
         p+AC5xyWdIfstLdqQqaeBquI0D3LbLfDZcSqHeXYFumjdIb4R3CPq4PCpCqHDTTxXSCV
         NYhZRFpSsH4PSgJAJZBf5hJcPIuRcfwA8PM+qyoj8Ojj681cVMfjxUc2ks9tWbx7LUZP
         5aGP9rMZV5o09E2O1XAlZEHYYUDM2p+P+CzBeWkuXaCtnzOj/l3CsGfdcbMrQnlZgZnn
         PKwxDD61byspcVkJa5qOiRklQqVHFXYqkd9XQJ4FnEXYjvsT5xr1B7zNTZe4dW7RB26S
         1FsQ==
X-Gm-Message-State: AGRZ1gJgI8a2PV983gfITiTgTvKWrjr451oO7sxFU01lltcT8g3kw9vi
        ohfSCblnTs5nW/ulufWlFIAAq9+umuBw5X59qQo=
X-Google-Smtp-Source: AJdET5eWuy2O9Er4dHTFTQiQl0+GOjA9hC0fCux4jjsmXIazqImYAk2yjvzK+zrZPstuGSRgM3DNsoSQE3S4IqdLvyg=
X-Received: by 2002:a67:f453:: with SMTP id r19mr2472786vsn.164.1541701779823;
 Thu, 08 Nov 2018 10:29:39 -0800 (PST)
MIME-Version: 1.0
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
 <20181019152905.32418-10-olga.kornievskaia@gmail.com> <20181105175006.GA9111@fieldses.org>
In-Reply-To: <20181105175006.GA9111@fieldses.org>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Thu, 8 Nov 2018 13:29:26 -0500
Message-ID: <CAN-5tyELmi6Obv-Ak2gikZ8sBfZ2AamaH6YdmjfGV22j7Zyrkw@mail.gmail.com>
Subject: Re: [PATCH v1 09/13] NFSD add COPY_NOTIFY operation
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Nov 5, 2018 at 12:50 PM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Oct 19, 2018 at 11:29:01AM -0400, Olga Kornievskaia wrote:
> > @@ -1345,6 +1347,44 @@ struct nfsd4_copy *
> >  }
> >
> >  static __be32
> > +nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> > +               union nfsd4_op_u *u)
> > +{
> > +     struct nfsd4_copy_notify *cn = &u->copy_notify;
> > +     __be32 status;
> > +     struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
> > +     struct nfs4_stid *stid;
> > +     struct nfs4_cpntf_state *cps;
> > +
> > +     status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> > +                                     &cn->cpn_src_stateid, RD_STATE, NULL,
> > +                                     NULL, &stid);
> > +     if (status)
> > +             return status;
> > +
> > +     cn->cpn_sec = nn->nfsd4_lease;
> > +     cn->cpn_nsec = 0;
> > +
> > +     status = nfserrno(-ENOMEM);
> > +     cps = nfs4_alloc_init_cpntf_state(nn, stid);
> > +     if (!cps)
> > +             return status;
> > +     memcpy(&cn->cpn_cnr_stateid, &cps->cp_stateid, sizeof(stateid_t));
> > +
> > +     /**
> > +      * For now, only return one server address in cpn_src, the
> > +      * address used by the client to connect to this server.
> > +      */
> > +     cn->cpn_src.nl4_type = NL4_NETADDR;
> > +     status = nfsd4_set_netaddr((struct sockaddr *)&rqstp->rq_daddr,
> > +                              &cn->cpn_src.u.nl4_addr);
> > +     if (status != 0)
> > +             nfs4_free_cpntf_state(cps);
>
> It looks like this would free cps while it was still on the parent's
> sc_cp_list.
>
> Is an error actually possible here? If not, just remove this check or
> replace it by WARN_ON_ONCE(status).

Yes i think it can fail (socket type is not a IPv4/v6. don't know how
real it is that it's something else)  so I need to change it so that
it's freed and removed from the list.

> > +
> > +     return status;
> > +}
> ...
> > @@ -2720,6 +2775,12 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
> >               .op_name = "OP_OFFLOAD_CANCEL",
> >               .op_rsize_bop = nfsd4_only_status_rsize,
> >       },
> > +     [OP_COPY_NOTIFY] = {
> > +             .op_func = nfsd4_copy_notify,
> > +             .op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
>
> CACHEME is actually only used for 4.0, let's drop it from
> nfs4.1/4.2-only operations.

Ah well COPY And CLONE had the CACHEME and thus I had it. I'll remove
it. We provably need to remove it from 4.2 ops: COPY, CLONE, ALLOCATE,
DEALLOCATE...

> > +             .op_name = "OP_COPY_NOTIFY",
> > +             .op_rsize_bop = nfsd4_copy_notify_rsize,
> > +     },
> >  };
> >
> >  /**
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index e263fd0..7764a8b 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -697,6 +697,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
> >       /* Will be incremented before return to client: */
> >       refcount_set(&stid->sc_count, 1);
> >       spin_lock_init(&stid->sc_lock);
> > +     INIT_LIST_HEAD(&stid->sc_cp_list);
> >
> >       /*
> >        * It shouldn't be a problem to reuse an opaque stateid value.
> > @@ -716,33 +717,85 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
> >  /*
> >   * Create a unique stateid_t to represent each COPY.
> >   */
> > -int nfs4_init_cp_state(struct nfsd_net *nn, struct nfsd4_copy *copy)
> > +int _nfs4_init_state(struct nfsd_net *nn, void *ptr, stateid_t *stid)
>
> This is still copy-specific code, so the names might be more
> helpful if they left that in.  Maybe:
>
>         _nfs4_init_state -> nfs4_init_cp_state
>         nfs4_init_cp_state -> nfs4_init_copy_state
>         nfs4_init_cp_state -> nfs4_init_cpnotify_state
>
> ?  Unless you can think of something better.

I will change the names.

>
> >  {
> >       int new_id;
> >
> >       idr_preload(GFP_KERNEL);
> >       spin_lock(&nn->s2s_cp_lock);
> > -     new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, copy, 0, 0, GFP_NOWAIT);
> > +     new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, ptr, 0, 0, GFP_NOWAIT);
> >       spin_unlock(&nn->s2s_cp_lock);
> >       idr_preload_end();
> >       if (new_id < 0)
> >               return 0;
> > -     copy->cp_stateid.si_opaque.so_id = new_id;
> > -     copy->cp_stateid.si_opaque.so_clid.cl_boot = nn->boot_time;
> > -     copy->cp_stateid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
> > +     stid->si_opaque.so_id = new_id;
> > +     stid->si_opaque.so_clid.cl_boot = nn->boot_time;
> > +     stid->si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
> >       return 1;
> >  }
> >
> > -void nfs4_free_cp_state(struct nfsd4_copy *copy)
> > +int nfs4_init_cp_state(struct nfsd_net *nn, struct nfsd4_copy *copy)
> > +{
> > +     return _nfs4_init_state(nn, copy, &copy->cp_stateid);
> > +}
> > +
> > +struct nfs4_cpntf_state *nfs4_alloc_init_cpntf_state(struct nfsd_net *nn,
> > +                                                  struct nfs4_stid *p_stid)
> > +{
> > +     struct nfs4_cpntf_state *cps;
> > +
> > +     cps = kzalloc(sizeof(struct nfs4_cpntf_state), GFP_KERNEL);
> > +     if (!cps)
> > +             return NULL;
> > +     if (!_nfs4_init_state(nn, cps, &cps->cp_stateid))
> > +             goto out_free;
> > +     cps->cp_p_stid = p_stid;
> > +     cps->cp_active = false;
> > +     cps->cp_timeout = jiffies + (nn->nfsd4_lease * HZ);
> > +     INIT_LIST_HEAD(&cps->cp_list);
> > +     list_add(&cps->cp_list, &p_stid->sc_cp_list);
>
> What prevents concurrent nfs4_alloc_init_cpntf_state()s from running and
> corrupting this list?

Nothing. I'll introduce a new lock.

>
> > +
> > +     return cps;
> > +out_free:
> > +     kfree(cps);
> > +     return NULL;
> > +}
> > +
> > +void _nfs4_free_state(struct net *n, stateid_t *stid)
>
> Ditto on the naming.
>
> >  {
> >       struct nfsd_net *nn;
> >
> > -     nn = net_generic(copy->cp_clp->net, nfsd_net_id);
> > +     nn = net_generic(n, nfsd_net_id);
> >       spin_lock(&nn->s2s_cp_lock);
> > -     idr_remove(&nn->s2s_cp_stateids, copy->cp_stateid.si_opaque.so_id);
> > +     idr_remove(&nn->s2s_cp_stateids, stid->si_opaque.so_id);
> >       spin_unlock(&nn->s2s_cp_lock);
> >  }
> >
> > +void nfs4_free_cp_state(struct nfsd4_copy *copy)
> > +{
> > +     _nfs4_free_state(copy->cp_clp->net, &copy->cp_stateid);
> > +}
> > +
> > +void nfs4_free_cpntf_state(struct nfs4_cpntf_state *cps)
> > +{
> > +     _nfs4_free_state(cps->cp_p_stid->sc_client->net, &cps->cp_stateid);
> > +     kfree(cps);
> > +}
> > +
> > +static void nfs4_free_cpntf_statelist(struct nfs4_stid *stid)
> > +{
> > +     struct nfs4_cpntf_state *cps;
> > +
> > +     might_sleep();
> > +
> > +     while (!list_empty(&stid->sc_cp_list)) {
> > +             cps = list_first_entry(&stid->sc_cp_list,
> > +                                    struct nfs4_cpntf_state, cp_list);
> > +             list_del(&cps->cp_list);
> > +             nfs4_free_cpntf_state(cps);
> > +     }
>
> Same question on concurrent modifications of this lock--do we need some
> more locking?
>
> --b.
