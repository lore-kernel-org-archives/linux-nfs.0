Return-Path: <SRS0=f8xw=RT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56C72C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 05:39:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 16A87218E0
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 05:39:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="Av4y7/zt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725937AbfCPFio (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Mar 2019 01:38:44 -0400
Received: from mail-vs1-f66.google.com ([209.85.217.66]:33417 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725936AbfCPFin (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 16 Mar 2019 01:38:43 -0400
Received: by mail-vs1-f66.google.com with SMTP id z6so6657066vsc.0
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 22:38:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=McsnC6Ux6dcTlqrKjEcs95o7BHlPx6WeydGAsg43iK0=;
        b=Av4y7/zt4pg+TILmbNyFU5Jw2Y/UzjdGpPmtSugNeBxkjMs5KvqNxvno1loQCn7vcj
         zbZDzFBnoikRas6yMukwRngSrElNq3QbZh2UtlE+2lTLreo6eG1uUaa/nrJtUX7Zvc84
         ig4h1sg0ZQh4fWYXpP2A2i+gTyJgOKFoS71HU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=McsnC6Ux6dcTlqrKjEcs95o7BHlPx6WeydGAsg43iK0=;
        b=NtThKGTzmtUW5iG4lD98iChnRDQlltXiJg7bIiQs4rWmDDszZOOvQGvb7MaGoHkABu
         dAHKLWVOK/gYT00ppvxp5RYPy3L74yJ+SDSqSfWvlHunxSHUlGJ20uHHk07himr3jk2J
         BzxMUkjY+DsgcRt9+Dbd97nz6itZYd5HOkDlcFZ2RtUJ0u/8diQg9ILCWXDLJNA5btqs
         +oWkw7y6ugkuYdbPtzC0GN98q4LUgyNfc3/oE4FilKxQtzuQs9CfeVioz1y+INJfgSbX
         dRzg0hCZTJnqc5XyEDYl6jVJEL0mMF5PWxGattVzoQf/K3EJUGb3W0z9DeQAlTBJP0sc
         e52g==
X-Gm-Message-State: APjAAAXfcuRn3ZQwVzJq4oK/Cr+pkF1LJSMsXzXKUfnTY/7Ia2Q2woII
        gdRcaak0FJyjBAil6lmr3iAuFwgo/+I=
X-Google-Smtp-Source: APXvYqyz3SV/+1SAQcOKyxGPjXRe4bTzyYKdSNvru5KCNO8nxesHx+KJobN+Yul7Cx42TGsIs6MFRA==
X-Received: by 2002:a67:f5d9:: with SMTP id t25mr4028132vso.23.1552714721614;
        Fri, 15 Mar 2019 22:38:41 -0700 (PDT)
Received: from mail-ua1-f54.google.com (mail-ua1-f54.google.com. [209.85.222.54])
        by smtp.gmail.com with ESMTPSA id 123sm733850vsw.18.2019.03.15.22.38.40
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 22:38:40 -0700 (PDT)
Received: by mail-ua1-f54.google.com with SMTP id c6so1325179uan.1
        for <linux-nfs@vger.kernel.org>; Fri, 15 Mar 2019 22:38:40 -0700 (PDT)
X-Received: by 2002:ab0:768b:: with SMTP id v11mr1584271uaq.64.1552714719686;
 Fri, 15 Mar 2019 22:38:39 -0700 (PDT)
MIME-Version: 1.0
References: <20190315110555.0807d015@cakuba.netronome.com> <20190315120105.5541ad46@cakuba.netronome.com>
 <20190315165440.53b9db3c@cakuba.netronome.com> <CAGXu5jKHRPuaALQcPXvpDeuVgZR+EeRqo9Qj4j3kYatb3HUSSA@mail.gmail.com>
In-Reply-To: <CAGXu5jKHRPuaALQcPXvpDeuVgZR+EeRqo9Qj4j3kYatb3HUSSA@mail.gmail.com>
From:   Kees Cook <keescook@chromium.org>
Date:   Fri, 15 Mar 2019 22:38:28 -0700
X-Gmail-Original-Message-ID: <CAGXu5jL-e7bDEXfpUuT-HyFarR-8T0djXChR0cuzTwFQPQ0tOw@mail.gmail.com>
Message-ID: <CAGXu5jL-e7bDEXfpUuT-HyFarR-8T0djXChR0cuzTwFQPQ0tOw@mail.gmail.com>
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

On Fri, Mar 15, 2019 at 10:24 PM Kees Cook <keescook@chromium.org> wrote:
>
> On Fri, Mar 15, 2019 at 4:54 PM Jakub Kicinski
> <jakub.kicinski@netronome.com> wrote:
> >
> > On Fri, 15 Mar 2019 12:01:05 -0700, Jakub Kicinski wrote:
> > > On Fri, 15 Mar 2019 11:05:55 -0700, Jakub Kicinski wrote:
> > > > Hi,
> > > >
> > > > I just upgraded from:
> > > >
> > > > commit a3b1933d34d5bb26d7503752e3528315a9e28339 (net)
> > > > Merge: c6873d18cb4a 24319258660a
> > > > Author: David S. Miller <davem@davemloft.net>
> > > > Date:   Mon Mar 11 16:22:49 2019 -0700
> > > >
> > > > to
> > > >
> > > > commit 3b319ee220a8795406852a897299dbdfc1b09911
> > > > Merge: 9352ca585b2a b6e88119f1ed
> > > > Author: Linus Torvalds <torvalds@linux-foundation.org>
> > > > Date:   Thu Mar 14 10:48:14 2019 -0700
> > > >
> > > > and I'm seeing:
> > > >
> > > > # mount /home/
> > > > mount.nfs: Protocol error
> > > >
> > > > No errors in dmesg, please let me know if it's a known problem or what
> > > > other info could be of use.
> > >
> > > Hm.. I tried to bisect but reverting to that commit doesn't help.
> > >
> > > Looks like the server responds with:
> > >
> > >   ICMP parameter problem - octet 22, length 80
> > >
> > > pointing at some IP options (type 134)...
> >
> > Okay, figured it out, it's the commit 13e735c0e953 ("LSM: Introduce
> > CONFIG_LSM") and all the related changes in security/
> >
> > I did olddefconfig and it changed my security module from apparmor to
> > smack silently.  smack must be slapping those IP options on by default.
> >
> > Pretty awful user experience, and a non-zero chance that users who
> > upgrade their kernels will miss this and end up with the wrong security
> > module...
>
> I wonder if we can add some kind of logic to Kconfig to retain the old
> CONFIG_DEFAULT_SECURITY and include it as the first legacy-major LSM
> listed in CONFIG_LSM?
>
> Like, but the old selector back in, but mark is as "soon to be
> entirely replaced with CONFIG_LSM" and then make CONFIG_LSM's default
> be "yama,loadpin,safesetid,integrity,$(CONFIG_DEFAULT_SECURITY),selinux,smack,tomoyo,apparmor"
> ? Duplicates are ignored...

This would initialize a default order from the earlier Kconfig items:

diff --git a/security/Kconfig b/security/Kconfig
index 1d6463fb1450..e3813b5c6824 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -239,8 +239,40 @@ source "security/safesetid/Kconfig"

 source "security/integrity/Kconfig"

+choice
+       prompt "First legacy-major LSM to be initialized"
+       default DEFAULT_SECURITY_SELINUX if SECURITY_SELINUX
+       default DEFAULT_SECURITY_SMACK if SECURITY_SMACK
+       default DEFAULT_SECURITY_TOMOYO if SECURITY_TOMOYO
+       default DEFAULT_SECURITY_APPARMOR if SECURITY_APPARMOR
+       default DEFAULT_SECURITY_DAC
+
+       help
+         Select the legacy-major security module that will be initialize
+         first. Overridden by non-default CONFIG_LSM.
+
+       config DEFAULT_SECURITY_SELINUX
+               bool "SELinux" if SECURITY_SELINUX=y
+
+       config DEFAULT_SECURITY_SMACK
+               bool "Simplified Mandatory Access Control" if SECURITY_SMACK=y
+
+       config DEFAULT_SECURITY_TOMOYO
+               bool "TOMOYO" if SECURITY_TOMOYO=y
+
+       config DEFAULT_SECURITY_APPARMOR
+               bool "AppArmor" if SECURITY_APPARMOR=y
+
+       config DEFAULT_SECURITY_DAC
+               bool "Unix Discretionary Access Controls"
+
+endchoice
+
 config LSM
        string "Ordered list of enabled LSMs"
+       default
"yama,loadpin,safesetid,integrity,smack,selinux,tomoyo,apparmor" if
DEFAULT_SECURITY_SMACK
+       default
"yama,loadpin,safesetid,integrity,tomoyo,selinux,smack,apparmor" if
DEFAULT_SECURITY_TOMOYO
+       default
"yama,loadpin,safesetid,integrity,apparmor,selinux,smack,tomoyo" if
DEFAULT_SECURITY_APPARMOR
        default "yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor"
        help
          A comma-separated list of LSMs, in initialization order.

(I don't see a way to include an earlier config string in a new
default.) Thoughts?

-- 
Kees Cook
