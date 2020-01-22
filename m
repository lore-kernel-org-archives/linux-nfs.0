Return-Path: <SRS0=bKkf=3L=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BFD90C2D0DB
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jan 2020 16:13:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8F57221569
	for <linux-nfs@archiver.kernel.org>; Wed, 22 Jan 2020 16:13:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="uTvRVjIM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726911AbgAVQN6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 22 Jan 2020 11:13:58 -0500
Received: from mail-wm1-f68.google.com ([209.85.128.68]:55581 "EHLO
        mail-wm1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726167AbgAVQN5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jan 2020 11:13:57 -0500
Received: by mail-wm1-f68.google.com with SMTP id q9so7400527wmj.5
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jan 2020 08:13:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=6h0VfCxWx4ezMUmEQv35xdVPNYz6rLwN9c84X/pwvVA=;
        b=uTvRVjIMj7hITR+Juv1f4I+x6Ch9f06IbU3JY6MjgnAfAzCuAxq+WKi9CI5LB3b2MS
         3Iwenfx7Jfn3RXvRp8Dbw2UZ56mYuCG7+RjErmoCMjc6RxMxTp/PWRRD131YA23wA71D
         of2smphhj4wDbmV0Js9rZL2F/F/PvhvaFpUMcHFZdVQj9wZFrVIr+665D8NmMRL9FLaG
         sW00l7nmVFFGfdsk1TzRDngZeFbSGpzhryjzAytCyV4FOSUQnVfutKmdBAL4RPniFZ74
         YJ4FndemgO+DrT7Yy02jxV4Bk7tQUSPIo+5x2OQcD/aTv5VIt9QjWi/VebTTbzDJffKo
         nzzg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:reply-to
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=6h0VfCxWx4ezMUmEQv35xdVPNYz6rLwN9c84X/pwvVA=;
        b=nC1BJfUMa6OSew4gZuhHLuQeFRUecmY/ghOnav2xMt6+w6bMg29jo8tpz/EvWWzAhy
         LNnHqCa5U/cwuVtBrkamn7v8K0xdZDynC6yAQ4/+4IzsdqI4VTBvcNtve7dpE8WFlHkq
         WnQS4UuqGSgLMpoXk351S5CQPdKV1OiUHS/jhURQ3OIv7p6vFZQCcbDb9aZjuO3Bbo1v
         49TF2gJw2zffqz14z5lDIsoB/f9Y9wMC0NHL0SISXP70//q3i48L315GAKx6DkeFYSeS
         M7ETR7Zd912CLbo/KXmb1Q/RwHxPeYDrub4b1Xz1vCvoetNdpCinW8mBFtsvyznZ2Faz
         Z/uA==
X-Gm-Message-State: APjAAAUXe60JFuNGvHeJJIs2wFIW5zFa9zpl0gEwafFGeoYCGs3IfSmR
        7SzYIsQRN8x3J3yVO83jCHRuEd+MVSM=
X-Google-Smtp-Source: APXvYqx0nGYrl5J0L3zwlCdzloRdlzYlC84VtejNnv9AOxee0nIFopYiO2UOC+4kM0cjBWPpt8IS2A==
X-Received: by 2002:a7b:cd07:: with SMTP id f7mr3646788wmj.37.1579709636025;
        Wed, 22 Jan 2020 08:13:56 -0800 (PST)
Received: from dell5510 ([62.201.25.198])
        by smtp.gmail.com with ESMTPSA id f1sm59519071wro.85.2020.01.22.08.13.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 22 Jan 2020 08:13:55 -0800 (PST)
Date:   Wed, 22 Jan 2020 17:13:53 +0100
From:   Petr Vorel <petr.vorel@gmail.com>
To:     Steve Dickson <SteveD@redhat.com>
Cc:     Giulio Benetti <giulio.benetti@benettiengineering.com>,
        linux-nfs@vger.kernel.org, Mike Frysinger <vapier@gentoo.org>
Subject: Re: [nfs-utils PATCH] locktest: Makefile.am: remove host compiler
 costraint
Message-ID: <20200122161353.GA21075@dell5510>
Reply-To: Petr Vorel <petr.vorel@gmail.com>
References: <20200115160806.99991-1-giulio.benetti@benettiengineering.com>
 <20200119191047.GB11432@dell5510>
 <6606c604-61ef-a3fa-8ced-1d9dfb822f64@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6606c604-61ef-a3fa-8ced-1d9dfb822f64@RedHat.com>
User-Agent: Mutt/1.12.2 (2019-09-21)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Steve,

> >> Currently locktest can be built only for host because CC_FOR_BUILD is
> >> specified as CC, but this leads to build failure when passing CFLAGS not
> >> available on host gcc(i.e. -mlongcalls) and most of all locktest would
> >> be available on target systems the same way as rpcgen etc. So remove CC
> >> and LIBTOOL assignments.

> >> Signed-off-by: Giulio Benetti <giulio.benetti@benettiengineering.com>
> > Reviewed-by: Petr Vorel <petr.vorel@gmail.com>
> > Tested-by: Petr Vorel <petr.vorel@gmail.com>
> > NOTE: as I understand it's a compilation issue of a tool, so I didn't run
> > rpcgen, I just test various compilation variants for buildroot.
> Just to be clear... Giulio's patch, removing CC and LIBTOOL from the
> locktest/Makefile.am does allows your cross build to succeed, correct?
Yes, for buildroot it's ok. I'm just not able to verify Gentoo.

> steved.

Kind regards,
Petr
