Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.5 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28E7BC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 21:22:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DC54E2147C
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 21:22:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n42hxzr0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726329AbfCLVWy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 17:22:54 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:46877 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726141AbfCLVWy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Mar 2019 17:22:54 -0400
Received: by mail-io1-f68.google.com with SMTP id k21so3381239ior.13
        for <linux-nfs@vger.kernel.org>; Tue, 12 Mar 2019 14:22:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=v35i4uX0jw/CGmdSQHA1GfD3ZY3zDwgtxT408E2jDNg=;
        b=n42hxzr0cwiIvITdImKcXOVNLiUBlnMiT9US8R80vsJtTduTlXr8G1/9IPPFVpwGnD
         Rq+SaKUIDshFmkTTv93aSm+96FR8dKLAcSzIYiV666TxtEu+qyCJ0Qq4cQbpE/KK3gLv
         Uxmt3HyyTKP18hIe4CflNoEcFUg5vryD17Dj9Q/G/qgtfRl+4pOXycC2UOW5TEDJ39b8
         X0RfTO+zRTS8altPXtQAnwEcPPFdgBcUifSi6v2OA1tY1SRc2Jh6MhbMP5A3KTaM7QQP
         1EZZu1FQTFT/5IbnG+JE2fsXxblVvfsP+EVuidx+tUmvJD88OVI+kCRb2F1rNzrC/izc
         d8Mg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:cc:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=v35i4uX0jw/CGmdSQHA1GfD3ZY3zDwgtxT408E2jDNg=;
        b=Ez8iR4eHlGS+v1J89qDTJsg1NFembBJR6Kl1ZDUx0onVpSwoOAu2LaBFKsqGmtj4Ru
         B7myd+9AIVNqSaSrqRoRiTpMobp+In4yZARkT66KGJuU8EetiK3Rc/wIdaceZw7WhMkB
         KtzvPgaChdjT3V+2mRsuHR9Ir6w0NM3acz9u1VKQVnfowd1/9W2BnNHU4iBxh2nGMRGb
         5JZ6lay3Y5Oxf7thCLW91eEqD+HD+GRouJkA+TtFT38QjHr+vGHyF1rKaNbi7ImrW8Ki
         g4JwdjOjyg1b6kbCR3TcisQPRhyP15Db+8w1TmH2P86QQkTOSzeJd1kiogVGt5OAouPs
         1g3w==
X-Gm-Message-State: APjAAAVh0Aihkt01MNGMLaA3ooUBgyWzJckOj//AyetCtIT/pmyJlmAd
        aiu1FYOCFUIlX1LXHNSFrY+2DcRrULU=
X-Google-Smtp-Source: APXvYqzFg7gtxCWhYnlg55JTxJrvAl6M+KgB67mA/3eZKxpNbdeK4Es31u7M478KOupvAPEmwdkoMQ==
X-Received: by 2002:a6b:db19:: with SMTP id t25mr8154206ioc.140.1552425772542;
        Tue, 12 Mar 2019 14:22:52 -0700 (PDT)
Received: from gouda.nowheycreamery.com (c-73-145-169-100.hsd1.mi.comcast.net. [73.145.169.100])
        by smtp.googlemail.com with ESMTPSA id g4sm4650961ioc.1.2019.03.12.14.22.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Mar 2019 14:22:51 -0700 (PDT)
Message-ID: <672c7858f622e78973296bc0a504114c7610b761.camel@gmail.com>
Subject: Re: [PATCH 1/4] pNFS: Ensure we return the error if someone kills a
 waiting layoutget
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date:   Tue, 12 Mar 2019 17:22:50 -0400
In-Reply-To: <6057b85eea9d1b25189e2c1ead89112c91180ff0.camel@hammerspace.com>
References: <20180905180715.99485-1-trond.myklebust@hammerspace.com>
         <233f58676bee06fe87fae6c6ca04708a24716187.camel@netapp.com>
         <6057b85eea9d1b25189e2c1ead89112c91180ff0.camel@hammerspace.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, 2019-03-12 at 20:12 +0000, Trond Myklebust wrote:
> On Tue, 2019-03-12 at 20:04 +0000, Schumaker, Anna wrote:
> > Hi Trond,
> > 
> > I'm seeing a hang when testing xfstests generic/013 on v4.1 with pNFS
> > after this
> > patch:
> > 
> > On Wed, 2018-09-05 at 14:07 -0400, Trond Myklebust wrote:
> > > If someone interrupts a wait on one or more outstanding layoutgets
> > > in
> > > pnfs_update_layout() then return the ERESTARTSYS/EINTR error.
> > > 
> > > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> > > ---
> > >  fs/nfs/pnfs.c | 26 ++++++++++++++++----------
> > >  1 file changed, 16 insertions(+), 10 deletions(-)
> > > 
> > > diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> > > index e8f232de484f..7d9a51e6b847 100644
> > > --- a/fs/nfs/pnfs.c
> > > +++ b/fs/nfs/pnfs.c
> > > @@ -1740,16 +1740,16 @@ static bool pnfs_within_mdsthreshold(struct
> > > nfs_open_context *ctx,
> > >  	return ret;
> > >  }
> > >  
> > > -static bool pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr
> > > *lo)
> > > +static int pnfs_prepare_to_retry_layoutget(struct pnfs_layout_hdr
> > > *lo)
> > >  {
> > >  	/*
> > >  	 * send layoutcommit as it can hold up layoutreturn due to lseg
> > >  	 * reference
> > >  	 */
> > >  	pnfs_layoutcommit_inode(lo->plh_inode, false);
> > > -	return !wait_on_bit_action(&lo->plh_flags, NFS_LAYOUT_RETURN,
> > > +	return wait_on_bit_action(&lo->plh_flags, NFS_LAYOUT_RETURN,
> > >  				   nfs_wait_bit_killable,
> > > -				   TASK_UNINTERRUPTIBLE);
> > > +				   TASK_KILLABLE);
> > >  }
> > >  
> > >  static void nfs_layoutget_begin(struct pnfs_layout_hdr *lo)
> > > @@ -1830,7 +1830,9 @@ pnfs_update_layout(struct inode *ino,
> > >  	}
> > >  
> > >  lookup_again:
> > > -	nfs4_client_recover_expired_lease(clp);
> > > +	lseg = ERR_PTR(nfs4_client_recover_expired_lease(clp));
> > > +	if (IS_ERR(lseg))
> > > +		goto out;
> > >  	first = false;
> > >  	spin_lock(&ino->i_lock);
> > >  	lo = pnfs_find_alloc_layout(ino, ctx, gfp_flags);
> > > @@ -1863,9 +1865,9 @@ pnfs_update_layout(struct inode *ino,
> > >  	if (list_empty(&lo->plh_segs) &&
> > >  	    atomic_read(&lo->plh_outstanding) != 0) {
> > >  		spin_unlock(&ino->i_lock);
> > > -		if (wait_var_event_killable(&lo->plh_outstanding,
> > > -					atomic_read(&lo-
> > > > plh_outstanding) == 0
> > > -					|| !list_empty(&lo->plh_segs)))
> > > +		lseg = ERR_PTR(wait_var_event_killable(&lo-
> > > > plh_outstanding,
> > > +					atomic_read(&lo-
> > > > plh_outstanding)));
> > > +		if (IS_ERR(lseg) || !list_empty(&lo->plh_segs))
> > 
> > Was dropping the "== 0" condition attached to the atomic_read() here
> > a mistake?
> > I think what's happening is that my client is waiting for
> > plh_outstanding to be
> > anything other than 0 when there isn't any work left to do.
> 
> Yes. That's a bug. How about the following patch?

This patch works for me, but for some reason doing "!atomic_read()" takes 8
minutes longer to complete compared to doing "atomic_read() == 0".  I have not
run this multiple times to confirm that it's always the case.

Anna

> 
> 8<---------------------------------------------------
> From 400417b05f3ec0531544ca5f94e64d838d8b8849 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@hammerspace.com>
> Date: Tue, 12 Mar 2019 16:04:51 -0400
> Subject: [PATCH] pNFS: Fix a typo in pnfs_update_layout
> 
> We're supposed to wait for the outstanding layout count to go to zero,
> but that got lost somehow.
> 
> Fixes: d03360aaf5cca ("pNFS: Ensure we return the error if someone...")
> Reported-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  fs/nfs/pnfs.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 8247bd1634cb..7066cd7c7aff 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1889,7 +1889,7 @@ pnfs_update_layout(struct inode *ino,
>  	    atomic_read(&lo->plh_outstanding) != 0) {
>  		spin_unlock(&ino->i_lock);
>  		lseg = ERR_PTR(wait_var_event_killable(&lo->plh_outstanding,
> -					atomic_read(&lo->plh_outstanding)));
> +					!atomic_read(&lo->plh_outstanding)));
>  		if (IS_ERR(lseg) || !list_empty(&lo->plh_segs))
>  			goto out_put_layout_hdr;
>  		pnfs_put_layout_hdr(lo);
> -- 
> 2.20.1
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
> 
> 

