Return-Path: <SRS0=GLKr=PR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A338C43387
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 22:18:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0F5E0206B6
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Jan 2019 22:18:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="kVATatX0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725730AbfAIWSr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Jan 2019 17:18:47 -0500
Received: from mail-ua1-f65.google.com ([209.85.222.65]:46118 "EHLO
        mail-ua1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725681AbfAIWSr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2019 17:18:47 -0500
Received: by mail-ua1-f65.google.com with SMTP id v24so2949720uap.13
        for <linux-nfs@vger.kernel.org>; Wed, 09 Jan 2019 14:18:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DxwBDr5zsdOoWPAWfDsEWB7k6Acr9yLzX2VRM4vwImg=;
        b=kVATatX0lK4i2gsAVhOgJ0RUixD9mS9reiLuMF6MOHtWghMS9962FxB6SbcinjurKD
         yHLsxS9m2bz3PyZlPUsHNIFenM7Infi0cVhon0geDOZAHxnOlkOY+/pquq6Es48UU9rk
         1bcOmJaotb/cMteJkEb5Bnyyd9eewbodbXYFOglNmBj3U8xsNrjZ+WT/Wn+oygRE4Y1t
         FRdqlxPak+Aien3TZyrpbCEU2ECqfe9bk+NQQLGgobDnpuZp2CL6RHZzB7aD3HQwwbZJ
         2+mqh0SW4cDksRW1Lc8NhZX1frJkV0RQEiZadHF4jn/4s6ZsOYqXKL1zKzLumB7mZbYU
         klzA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=DxwBDr5zsdOoWPAWfDsEWB7k6Acr9yLzX2VRM4vwImg=;
        b=c3odeMHUnKOmGdqmI8ln1Gd4/2KZXq+lgGMvEBqb2zd/WLBjcKxnCnPPc9FzRUvfPE
         dsCLSXqYD1EC9J3hVsKzVLFuE0UWNr/XL5PsDO2h5SuA4DgWqLf8cIZOwfeRgYxfBtK3
         CmgIaBBip752+B599n6zDG9F3H3kyH1hbkcGulnl5XSr0f9t0dq7G2RvNjKURGcQCvLB
         zVwK5sTjQBjLsTp/3GMgWygTkGmxYICPHKVfnvMIVKjnYrTdGPbmqA9nukm4QIAhdzQN
         3nQ6fMsJF61ym9wmPbPilwnV+qxHPz/M8n8UH/wIR0rPlYPU2d5Z8HkVMC4cUUpTMsl/
         Yerw==
X-Gm-Message-State: AJcUukeVqgTcncK4qDnijqi9hk7FEmLgYYEfFMGK1rw9TXNAxokmhIWx
        sRP9HtlhzQzJ3RLw3aKopzh+7IPnRZtQ/M/6Cka3JspE
X-Google-Smtp-Source: ALg8bN43fZEtOOoIXCk47ptTmUSbEgT/wGqtyd05UqgPgrb/+c678nt3aVt8KdLPjBwj0jgfREZ0brZGQ1hC5K4eFCY=
X-Received: by 2002:ab0:aa:: with SMTP id 39mr2857065uaj.120.1547072325414;
 Wed, 09 Jan 2019 14:18:45 -0800 (PST)
MIME-Version: 1.0
References: <20170428172535.7945-1-trond.myklebust@primarydata.com>
 <CAN-5tyEp5=bF2mFjTCs2K2NdKWLY=msqN-5c94hwuXSm3QTDAw@mail.gmail.com> <27c2a121e83a6546d3a35aeb07ae6b1f9b372fe0.camel@hammerspace.com>
In-Reply-To: <27c2a121e83a6546d3a35aeb07ae6b1f9b372fe0.camel@hammerspace.com>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Wed, 9 Jan 2019 17:18:33 -0500
Message-ID: <CAN-5tyHuCZYfxtzFDg09cK0sfaGTFDt0vBTVj+j-4RROcs7NnQ@mail.gmail.com>
Subject: Re: [RFC PATCH 0/5] Fun with the multipathing code
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Jan 9, 2019 at 3:38 PM Trond Myklebust <trondmy@hammerspace.com> wrote:
>
> Hi Olga
>
> On Wed, 2019-01-09 at 14:39 -0500, Olga Kornievskaia wrote:
> > Hi Trond,
> >
> > Do you have any plans for this patch set?
> >
> > I applied the patches on top of 4.20-rc7 kernel I had and tested it
> > (linux to linux) with iozone on the hardware (40G link with Mellanox
> > CX-5 card).
> >
> > Results seem to show read IO improvement from 1.9GB to 3.9GB. Write
> > IO
> > speed seems to be the same (disk bound I'm guessing). I also tried
> > mounting tmpfs. Same thing.
> >
> > Seems like a useful feature to include?
>
> Thanks for testing this.
>
> Was this your own port of the original patches, or have you taken my
> branch from
> http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=shortlog;h=refs/heads/multipath_tcp
> ?

I didn't know one existed. I just took original patches from the
mailing list and applied to 4.20-rc7 (they applied without issues that
I recall).

> Either way I appreciate the data point. I haven't seen too many other
> reports of performance improvements, and that's the main reason why
> this patchset has languished.
>
> 3.9GB/s would be about 31Gbps, so that is not quite wire speed, but
> certainly a big improvement on 1.9GB/s.

Maybe it's the lab setup that's not tuned to achieve max performance.

> I'm a little surprised, tbough,
> that the write performance did not improve with the tmpfs. Was all this
> using aio+dio on the client?

It is what ever "iozone -i0 -i1 -s52m -y2k -az -I" translates to.

To clarify by "didn't improve" I didn't mean the write speed with disk
is same as write speed with tmpfs (disk write speed is ~168MB and
tmpfs write speed is 1.47GB). I meant that it seems with nconnect=1 it
achieves the "max" performance of disk/tmpfs.

>
> --
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>
>
