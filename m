Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8478C6786F
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:58:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9E14A2080A
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:58:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="NNnWt3HJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E14A2080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727817AbeJaFx6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:53:58 -0400
Received: from mail-yb1-f193.google.com ([209.85.219.193]:34506 "EHLO
        mail-yb1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727552AbeJaFx4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:53:56 -0400
Received: by mail-yb1-f193.google.com with SMTP id n140-v6so5681983yba.1
        for <linux-nfs@vger.kernel.org>; Tue, 30 Oct 2018 13:58:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:in-reply-to:references:from:date:message-id:subject:to
         :cc;
        bh=LpIdpzRClILpUZup6nsIZl5u2kpkq/WM5ywfhwtfMF0=;
        b=NNnWt3HJOE6+qFzr1PqH+tPM5N0sTEXau1wlpeO+28TJiwXJ+iDtri2fphbAdNYSio
         t5jMRoYuskteAQHpEg0a2pBbeB9av40T7DzIfQpOPbXHpiLg+lxJdj+MYff9AV8M0vsF
         USuV/blQIcq16ulzUgBAVwlE6bcGpWktZSfJU=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:in-reply-to:references:from:date
         :message-id:subject:to:cc;
        bh=LpIdpzRClILpUZup6nsIZl5u2kpkq/WM5ywfhwtfMF0=;
        b=kJEBqe9lqE49zfiu/6s2wOBrXmi3XJmLd3Aw9p4PcayoR46L96jsSDVWGiNNHhJAtO
         B9SvcF+Tb559NiDAAdRLuY9uDo6tyRVohDK3dprlOXPn09nhASN41uMABhgG+TZEo0gx
         VPxO/mcoBJCwU+eQKq6Fee92MgCe/rvp4cgBBPIkV/KxzRVgCprV//pjuQQeRUd7zD+C
         OfvgvHsmHtWe7x0ekxHot9KhmCKi/2VxYU0rPueNeYu2xfFnVlavIeTNvYXN19L10vmf
         61FBJ3sbJHHOL1I1bsQ66CUNlEFjIpkblLES1YvG6d1lhc+o2ApiEZSIRWmEfHHJLTqu
         9lXQ==
X-Gm-Message-State: AGRZ1gLyBMR3XHk/hUj6UKn0wo9PqOspKsIuOoLY8v6WTyY6SJp6ejXA
        efXBXc320oR5aM7tcd48ovS7bk8va5g=
X-Google-Smtp-Source: AJdET5cYfwnPeS9RDl2ZCNHu4m80RklIDX+J8n3wH76p6lgNc3WZ6xQi9qkNfvtbmbzgLkQlqAWWCQ==
X-Received: by 2002:a25:dbcd:: with SMTP id g196-v6mr340992ybf.391.1540933131138;
        Tue, 30 Oct 2018 13:58:51 -0700 (PDT)
Received: from mail-yw1-f51.google.com (mail-yw1-f51.google.com. [209.85.161.51])
        by smtp.gmail.com with ESMTPSA id 206-v6sm3252174ywy.104.2018.10.30.13.58.49
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Oct 2018 13:58:49 -0700 (PDT)
Received: by mail-yw1-f51.google.com with SMTP id v1-v6so5533421ywv.6
        for <linux-nfs@vger.kernel.org>; Tue, 30 Oct 2018 13:58:49 -0700 (PDT)
X-Received: by 2002:a0d:fec6:: with SMTP id o189-v6mr341870ywf.237.1540933128893;
 Tue, 30 Oct 2018 13:58:48 -0700 (PDT)
MIME-Version: 1.0
Received: by 2002:a25:3990:0:0:0:0:0 with HTTP; Tue, 30 Oct 2018 13:58:48
 -0700 (PDT)
In-Reply-To: <20181026232409.16100-1-linux@rasmusvillemoes.dk>
References: <20171108223020.24487-1-linux@rasmusvillemoes.dk> <20181026232409.16100-1-linux@rasmusvillemoes.dk>
From:   Kees Cook <keescook@chromium.org>
Date:   Tue, 30 Oct 2018 13:58:48 -0700
X-Gmail-Original-Message-ID: <CAGXu5j+eGQ3oo_1qSwW-BEVSK=vcLmNLWH8E7fPiawobo=_fbQ@mail.gmail.com>
Message-ID: <CAGXu5j+eGQ3oo_1qSwW-BEVSK=vcLmNLWH8E7fPiawobo=_fbQ@mail.gmail.com>
Subject: Re: [RFC PATCH 0/7] runtime format string checking
To:     Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc:     Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        linux-hwmon@vger.kernel.org,
        Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>,
        "Steven Rostedt (VMware)" <rostedt@goodmis.org>,
        Jean Delvare <jdelvare@suse.com>,
        Guenter Roeck <linux@roeck-us.net>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Oct 27, 2018 at 12:24 AM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> This is a resurrection of something I sent out about a year ago. In
> the relatively few places where we use a non-literal as format string,
> we can annotate the source with a fmtcheck() call that will (a) at
> build time, allow the compiler to check the variadic arguments against
> the template, and (b) at runtime, check that the format specifiers
> present in the actual format string match those in the template (and
> if not, WARN and use the template to ensure runtime type safety).
>
> Finding places to annotate is just
>
>   make -j8 KCFLAGS='-Wformat-nonliteral'
>
> So far, in about half the places I looked, one might as well get
> completely rid of the non-literal format string.

Agreed. When I was still updating format string sites regularly, I had
a couple "just make the build quiet" patches to do this:

https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/commit/?h=kspp/format-security&id=ce9b938574042d09920650cb3c63ec29658edc87
The above seemed to "noisy" to send, but perhaps we should just land
it anyway. They really _should_ be const.

https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/commit/?h=kspp/format-security&id=b7dcfc8f48caaafcc423e5793f7ef61b9bb5c458
This one covers cases where the pointer is pointing to a const string,
so really there's no sense in injecting the "%s", but I was collecting
them to make real ones stand out.

> Patches 5,6,7 are
> some examples of where one might add fmtcheck() calls. I don't think
> we can get to a state where we can unconditionally add
> -Wformat-nonliteral to the build, but I think there's a lot of
> low-hanging fruit.

How much work do you think it'd take to get to a
format-nonliteral-clean build? I think it's worth doing the work if
it's not totally intractable.

-Kees

>
> This is on top of Miguel's compiler attributes series [1], which I
> hope will land in mainline soon.
>
> [1] https://github.com/ojeda/linux.git tags/compiler-attributes-for-linus-4.20-rc1
>
> Rasmus Villemoes (7):
>   compiler_attributes.h: add __attribute__((format_arg)) shorthand
>   lib/vsprintf.c: add fmtcheck utility
>   kernel.h: implement fmtmatch() wrapper around fmtcheck()
>   lib/test_printf.c: add a few fmtcheck() test cases
>   kernel/kthread.c: do runtime check of format string in
>     kthread_create_on_cpu()
>   nfs: use fmtcheck() in root_nfs_data
>   drivers: hwmon: add runtime format string checking
>
>  drivers/hwmon/hwmon.c               |  3 +-
>  fs/nfs/nfsroot.c                    |  2 +-
>  include/linux/compiler_attributes.h | 13 ++++++
>  include/linux/kernel.h              | 25 +++++++++++
>  kernel/kthread.c                    |  4 +-
>  lib/Kconfig.debug                   |  9 ++++
>  lib/test_printf.c                   | 43 +++++++++++++++++++
>  lib/vsprintf.c                      | 65 +++++++++++++++++++++++++++++
>  8 files changed, 160 insertions(+), 4 deletions(-)
>
> --
> 2.19.1.6.gbde171bbf5
>



-- 
Kees Cook
