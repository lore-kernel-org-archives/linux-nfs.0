Return-Path: <SRS0=f8xw=RT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA4EEC10F03
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 05:25:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A57E8218FC
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 05:25:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="PHpq2Y6E"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725936AbfCPFZJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Mar 2019 01:25:09 -0400
Received: from mail-vs1-f66.google.com ([209.85.217.66]:37168 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725940AbfCPFZI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2019 01:25:08 -0400
Received: by mail-vs1-f66.google.com with SMTP id w13so609211vsc.4
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 22:25:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XUbM3rN6drZ5zRdiVKP0Jupxp7VX7qkDWLnxB94bLb4=;
        b=PHpq2Y6EoC7crtH3QoJhAhEHi1h5Ttz1exB6gxDFa2jykFZZJ0CQOuRFbrE/tnU63Z
         Utb5Aw7HOdRT7kwLllWlEERORUgRvPWjz4RkDoSoKKgZTIlIwWzRRcyCOwB7nUXyuE9D
         tdJFI+fkmyEPF1/MhX4uKLgEV0RuKzE3hNXjM=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=XUbM3rN6drZ5zRdiVKP0Jupxp7VX7qkDWLnxB94bLb4=;
        b=GMfqaCahey66rfyvq4KACJ0hl2ZMt737Q3Bc3VmlgbcViPgt1triipbLx91jMV1JSW
         ItksdIIjlnpq+hBL892xV7vLme1WzM1c8EdAG1qy2pFtJkBan9vqGQ1aAYhLcPsnsfSW
         AwkMq80L1/iO7VQlHA5Ob6EtkCgyY3A8W6ufd3ZRluGaAE2OhE1+MSKSbwnHkROjRz69
         I/4r2u5YiWXcgaPon96Zqc9tiAh2fWOlojg6v91J3J7ejdcosysD+1W5pi8IdSpkE17N
         UHPjegu4X3J8EGc31fjDP8q5drMkYUdMmR3QkjxVCn/5yZ0Gj68T0Zrm7tElX4A/JBho
         pH7A==
X-Gm-Message-State: APjAAAXm2s1RIgMCfYayewG45gRsfr5S1tXj7fxhVvWdo39bBY27unqN
        kTBPcKdQ7NcBUY7o/Y7hoERLRNX6UGo=
X-Google-Smtp-Source: APXvYqx1bC9VJicPuVrlqaIZ3rKPcYZds97i4fJgbJPpLquuNsMJSFCBRoRFXUnM+QhVcVh/2ky56g==
X-Received: by 2002:a67:fc8e:: with SMTP id x14mr3999832vsp.3.1552713906679;
        Fri, 15 Mar 2019 22:25:06 -0700 (PDT)
Received: from mail-vs1-f44.google.com (mail-vs1-f44.google.com. [209.85.217.44])
        by smtp.gmail.com with ESMTPSA id t4sm1015480uaq.0.2019.03.15.22.25.05
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 22:25:05 -0700 (PDT)
Received: by mail-vs1-f44.google.com with SMTP id c189so6620480vsd.9
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 22:25:05 -0700 (PDT)
X-Received: by 2002:a67:ed0c:: with SMTP id l12mr3959329vsp.66.1552713904745;
 Fri, 15 Mar 2019 22:25:04 -0700 (PDT)
MIME-Version: 1.0
References: <20190315110555.0807d015@cakuba.netronome.com> <20190315120105.5541ad46@cakuba.netronome.com>
 <20190315165440.53b9db3c@cakuba.netronome.com>
In-Reply-To: <20190315165440.53b9db3c@cakuba.netronome.com>
From:   Kees Cook <keescook@chromium.org>
Date:   Fri, 15 Mar 2019 22:24:53 -0700
X-Gmail-Original-Message-ID: <CAGXu5jKHRPuaALQcPXvpDeuVgZR+EeRqo9Qj4j3kYatb3HUSSA@mail.gmail.com>
Message-ID: <CAGXu5jKHRPuaALQcPXvpDeuVgZR+EeRqo9Qj4j3kYatb3HUSSA@mail.gmail.com>
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
To:     Jakub Kicinski <jakub.kicinski@netronome.com>,
        linux-security-module <linux-security-module@vger.kernel.org>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Mar 15, 2019 at 4:54 PM Jakub Kicinski
<jakub.kicinski@netronome.com> wrote:
>
> On Fri, 15 Mar 2019 12:01:05 -0700, Jakub Kicinski wrote:
> > On Fri, 15 Mar 2019 11:05:55 -0700, Jakub Kicinski wrote:
> > > Hi,
> > >
> > > I just upgraded from:
> > >
> > > commit a3b1933d34d5bb26d7503752e3528315a9e28339 (net)
> > > Merge: c6873d18cb4a 24319258660a
> > > Author: David S. Miller <davem@davemloft.net>
> > > Date:   Mon Mar 11 16:22:49 2019 -0700
> > >
> > > to
> > >
> > > commit 3b319ee220a8795406852a897299dbdfc1b09911
> > > Merge: 9352ca585b2a b6e88119f1ed
> > > Author: Linus Torvalds <torvalds@linux-foundation.org>
> > > Date:   Thu Mar 14 10:48:14 2019 -0700
> > >
> > > and I'm seeing:
> > >
> > > # mount /home/
> > > mount.nfs: Protocol error
> > >
> > > No errors in dmesg, please let me know if it's a known problem or what
> > > other info could be of use.
> >
> > Hm.. I tried to bisect but reverting to that commit doesn't help.
> >
> > Looks like the server responds with:
> >
> >   ICMP parameter problem - octet 22, length 80
> >
> > pointing at some IP options (type 134)...
>
> Okay, figured it out, it's the commit 13e735c0e953 ("LSM: Introduce
> CONFIG_LSM") and all the related changes in security/
>
> I did olddefconfig and it changed my security module from apparmor to
> smack silently.  smack must be slapping those IP options on by default.
>
> Pretty awful user experience, and a non-zero chance that users who
> upgrade their kernels will miss this and end up with the wrong security
> module...

I wonder if we can add some kind of logic to Kconfig to retain the old
CONFIG_DEFAULT_SECURITY and include it as the first legacy-major LSM
listed in CONFIG_LSM?

Like, but the old selector back in, but mark is as "soon to be
entirely replaced with CONFIG_LSM" and then make CONFIG_LSM's default
be "yama,loadpin,safesetid,integrity,$(CONFIG_DEFAULT_SECURITY),selinux,smack,tomoyo,apparmor"
? Duplicates are ignored...

-- 
Kees Cook
