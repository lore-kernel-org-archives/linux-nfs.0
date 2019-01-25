Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7876FC282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 16:42:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 29F54218CD
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 16:42:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umich.edu header.i=@umich.edu header.b="LFc9XrO2"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726778AbfAYQm3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 11:42:29 -0500
Received: from mail-vk1-f196.google.com ([209.85.221.196]:35396 "EHLO
        mail-vk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726265AbfAYQm3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jan 2019 11:42:29 -0500
Received: by mail-vk1-f196.google.com with SMTP id b18so2268183vke.2
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2019 08:42:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umich.edu; s=google-2016-06-03;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=x3hiSTQZGO1pUMx+FV+cdbWbSAnjwEhtsNd6zNKuiFc=;
        b=LFc9XrO2FCFL8tqIfJW/74tW5Ic9M5ZqKVZ5m+AnGwaCWcysOsW5itHeQQES54qaYw
         92QV71eqCHl567edJhNIrDO2NFJHNSKNU8e/5YQ5bchazsx2PFSh/ox5hcq32UrjNqGK
         UmrNTwfg1wGRXJKyvfOTj2wlJO2iKJK80l+dLtv95DrGY9vC2tc9SLL6LsiWQ9DXW2I0
         c0Pou124AMzrfTqDWT+lUQ+ppYW0uIoRzEqp4MdwKnNJ4xK0k1udA+lf4PnrUYMgfHKs
         pIpBql3m1w3+GXOr135mgvjMdWSpjytWRu7o7vn+Vu7D+oRfod66aEvCRAcTwHaoG3Dr
         7XWw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=x3hiSTQZGO1pUMx+FV+cdbWbSAnjwEhtsNd6zNKuiFc=;
        b=arDBPJCZA+9cCLtnro7oY3BNIwl92IUl5ed0nQ4YLdLyelFpt7o9sa0elkVr6/ukpu
         nCgqeiqZ8aBeEAggFAalX9kfE5hHEjhbYYI/scq6fq60z1D2ycLksFCtzj9BIR7SVBsb
         ekttMouvqLdohi8oZQgyhThEwBH35E1tywhra7lqu/dBTEWF+Mi2ql98UYglYgq1mwOS
         j8VuYTZQFumCXfBLB6odHlzaPZFPUnjtoUScOOl6nAUuqHybbW4uDzolsRlzqV1sK+iu
         LR0sMSiNzdmvigye+OZRFlGGOMsb/ocFjaIVPahCYaYL6A7FWz9myQwSlTVDiKNCgqEg
         6A2Q==
X-Gm-Message-State: AJcUukdm8n5WQzvWTcUwWC/svPNmQLbMpQRJ1hrTK93phT6zuxWMzyZf
        fSviGlZZ3w9NFfKJRlkXqpx8veeig0DgkQYMgP8=
X-Google-Smtp-Source: ALg8bN4m6zilYgbLssddiK5iX770ZpJDQlRau+lqLq1nC9Pfq6onAutj7+DsWN3A1NYafSwXIE+roBPLAl9QWIgIrgg=
X-Received: by 2002:a1f:a414:: with SMTP id n20mr4771212vke.83.1548434548283;
 Fri, 25 Jan 2019 08:42:28 -0800 (PST)
MIME-Version: 1.0
References: <20190121205838.18680-1-trond.myklebust@hammerspace.com>
 <20190125004658.GB3953@fieldses.org> <698446e18a6718ee1ced06ecfd06e2de802fa16e.camel@gmail.com>
 <20190125163218.GA2752@fieldses.org>
In-Reply-To: <20190125163218.GA2752@fieldses.org>
From:   Olga Kornievskaia <aglo@umich.edu>
Date:   Fri, 25 Jan 2019 11:42:17 -0500
Message-ID: <CAN-5tyEZhVEMSjxbWfGoODb6eAmO7VJLjYkMv2HwUyXKHjyyWw@mail.gmail.com>
Subject: Re: [PATCH] nfsd: Fix error return values for nfsd4_clone_file_range()
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Trond Myklebust <trondmy@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Jan 25, 2019 at 11:32 AM J. Bruce Fields <bfields@fieldses.org> wrote:
>
> On Fri, Jan 25, 2019 at 12:50:09AM -0500, Trond Myklebust wrote:
> > On Thu, 2019-01-24 at 19:46 -0500, J. Bruce Fields wrote:
> > > On Mon, Jan 21, 2019 at 03:58:38PM -0500, Trond Myklebust wrote:
> > > > If the parameter 'count' is non-zero, nfsd4_clone_file_range() will
> > > > currently clobber all errors returned by vfs_clone_file_range() and
> > > > replace them with EINVAL.
> > >
> > > Oops, thanks for the fix.  I'm still a little confused, though:
> ...
> > > > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > > > index 9824e32b2f23..7dc98e14655d 100644
> > > > --- a/fs/nfsd/vfs.c
> > > > +++ b/fs/nfsd/vfs.c
> > > > @@ -557,9 +557,11 @@ __be32 nfsd4_clone_file_range(struct file
> > > > *src, u64 src_pos, struct file *dst,
> > > >   loff_t cloned;
> > > >
> > > >   cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos,
> > > > count, 0);
> > > > + if (cloned < 0)
> > > > +         return nfserrno(cloned);
> > > >   if (count && cloned != count)
> > > > -         cloned = -EINVAL;
> > > > - return nfserrno(cloned < 0 ? cloned : 0);
> > > > +         return nfserrno(-EINVAL);
> > > > + return 0;
> > >
> > > I still don't understand the cloned != count case.  I thought clone
> > > was
> > > supposed to be all-or-nothing and atomic, can it really return a
> > > short
> > > copy?  And how is that inval, shouldn't that be serverfault?
> >
> > That, quite frankly, seems like more of a question for Darrick, not me.
> > I haven't changed that part of the code.
> >
> > The main thing I care about is being able to correctly report
> > EOPNOTSUPP errors for the vast majority of filesystems that don't
> > support clone() or dedup().
>
> Makes sense, and I'm happy just to apply this and then sort out the rest in a
> subsequent patch, but I'd really like to understand; Darrick?:
>
> ioctl_file_clone also converts short copies to EINVAL:
>
>         if (cloned < 0)
>                 ret = cloned;
>         else if (olen && cloned != olen)
>                 ret = -EINVAL;
>         else
>                 ret = 0;
>
> Maybe that happens iff we hit EOF in the short file?
>
> Does that mean we can successfully copy up to EOF and then return -EINVAL?
> That sounds wrong.
>
> There's a man page (IOCTL-FICLONERANGE(2)) but it doesn't cover this case.

I thought cloned by definition was all or nothing meaning there can't
be a "short" clone. If you allow for less then asked bytes to be
returned, then your next offsets might not be block aligned.
