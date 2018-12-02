Return-Path: <SRS0=5YGM=OL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AE62C04EB9
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 03:17:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C12532064A
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 03:17:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hoA8Ugud"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C12532064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725536AbeLBDRW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 22:17:22 -0500
Received: from mail-vs1-f66.google.com ([209.85.217.66]:35406 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725290AbeLBDRW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 22:17:22 -0500
Received: by mail-vs1-f66.google.com with SMTP id e7so5637322vsc.2;
        Sat, 01 Dec 2018 19:17:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=xe1diu41nDpWSUYoy/i5iy1oy6ZKsgHMD/3gpP4jhYQ=;
        b=hoA8UgudMho7aGI+MxwN2gph8m6nD5pzaxcjZgq1/kDQLjTdTD/O6Qq7tE0QDm4IBn
         mLj7FAl+rB7hQ+X9X5GvNKOr/plq/LtwqX+ahvtxy5m7UIE2cegdvyV/xewzg3+3Dwrc
         5aIXBqjxFGvLMG/zvv4NPqNDjIsFHtnkIsS0J0bKBQKLNM4C/qWcuXm6+eZCW+/oluU/
         k694kLlPKTbKJgSSSEy7PfxQF7wsd15GJB0KX+DHP5pClp7pSorTOIZkKV/S6AMem0Pa
         jM8FxYglfql1LaJEhJtACjYUwM3rVibYL1xWoh8Ua8AlMm5wK7jBJiDkXRGtx0LU2ZLl
         D7cw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=xe1diu41nDpWSUYoy/i5iy1oy6ZKsgHMD/3gpP4jhYQ=;
        b=MBYBjnOwBW1+golazXXesYDeFLKx9njYsvSxTZVHboEdxpxDHF1h2EkQ6kHTzPkFZl
         NpVSVI53HFM5roQOw9L6pmVy4wNzSfl/3XGNuU6gIBLs2jK4msYB3PcWWE16RizLvmvA
         LRCJ4Xe/kUnZOcFOY/1x9S+ZfJYjDiczJGVG+XcCVnzUrjH1egYQ7yO76GRPOCzB8tn9
         bFsSERP5VYtlTGwDO9+JHfvPHjyfh8JllEWCow3NEEqnmUzQ6T8HuGzkT9FFAzTtQFR/
         3IIA2LPPudVqfVMq1cs+QJcY0zgY4uXrAO1ia3yySmoVsuYAACLWJB4qT5Ov2ctUea6F
         uB7A==
X-Gm-Message-State: AA+aEWaHX1+fuw1jwoQ0U3/pVsK63usV/zSqgph562vHQZln5x7gEDUp
        h6DpiT/H51Qpne31oubxtEAcHQLQahsFqNFGMuI=
X-Google-Smtp-Source: AFSGD/X8aIvxOcK3oepj0C3KtjJkZeErOKtC/KGg/G8QZwPUABMjVF7etESJUa1IYYH3lWsalP/Kxv9FAnv8JgED9ZA=
X-Received: by 2002:a67:4285:: with SMTP id p127mr4918883vsa.134.1543720336652;
 Sat, 01 Dec 2018 19:12:16 -0800 (PST)
MIME-Version: 1.0
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-2-olga.kornievskaia@gmail.com> <CAOQ4uxjXGPOPQTsgKnMx7YN2S1Oz3MDbg5kDf0VV1rK+9Ybu8A@mail.gmail.com>
 <20181201220045.GQ19305@dastard>
In-Reply-To: <20181201220045.GQ19305@dastard>
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
Date:   Sat, 1 Dec 2018 22:12:05 -0500
Message-ID: <CAN-5tyFBjVM6HOGZbjy+k4eCOHyDdvXsiGOHSR+gRXCHS3fosA@mail.gmail.com>
Subject: Re: [PATCH v2 01/10] VFS generic copy_file_range() support
To:     david@fromorbit.com
Cc:     Amir Goldstein <amir73il@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, willy@infradead.org,
        jlayton@kernel.org, stfrench@microsoft.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Dec 1, 2018 at 5:00 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Sat, Dec 01, 2018 at 10:11:48AM +0200, Amir Goldstein wrote:
> > On Fri, Nov 30, 2018 at 10:04 PM Olga Kornievskaia
> > <olga.kornievskaia@gmail.com> wrote:
> > >
> > > Relax the condition that input files must be from the same
> > > file systems.
> > >
> > > Add checks that input parameters adhere semantics.
> > >
> > > If no copy_file_range() support is found, then do generic
> > > checks for the unsupported page cache ranges, LFS, limits,
> > > and clear setuid/setgid if not running as root before calling
> > > do_splice_direct(). Update atime,ctime,mtime afterwards.
> > >
> > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > ---
> >
> > This patch is either going to bring you down or make you stronger ;-)
> >
> > This is not how its done. Behavior change and refactoring mixed into
> > one patch is wrong for several reasons. And when you relax same sb
> > check you need to restrict it inside filesystems, like your previous patch
> > did.
> .....
> > In any case, I hear that Dave is neck deep in fixing copy_file_range()
> > so changes to this function should be collaborated with him. Or better
> > yet, wait until he posts his fixes and carry on from there.
>
> Yeah, because I've heard nothing for a month and this is kinda
> important

Dave I think that's unfair. It is important. NFS is actually the file
system that needed VFS support for cross fs copy_file_range and I was
working on it. If you were in doubt, you could have emailed and asked
me.

I'm unsure now what does this mean. I have a patch series with a VFS
patch that went thru the extensive review (people spend time on it)
and an NFS patch series that depends on it that is ready for the
upstream push. Are you saying that the VFS patch is no longer welcomed
and thus NFS series is no longer viable either?

, I have a series of 8-9 patches that make all the fixes we
> need, push the cross-filesystem checks down into the filesystems,
> and let filesystems handle the fallback to a splice based copy
> themselves (because there are way more fallback cases than just
> EOPNOPSUPP and EXDEV).

Are you saying it is each individual filesystem responsibility to
fallback on splice? Isn't that a step backwards? Each individual
filesystem is going to implement the same code of calling
do_splice_direct() to do the functionally that could and should be in
VFS?

>
> I also have a patch for the man page that document all the missing
> failure cases, and document where things are filesystem specific or
> not.
>
> And I also have a fstests patch that exercises all the failure cases
> so that all filesystems will end up behaving the same way for all
> the same cases they should.
>
> I'm still sorting out the fstests patch (it requires changes
> to xfs_io's copy-range command) so I've got some confidence that the
> code actually does what it says in the man page, but I should have
> that sorted in a couple of days.
>
> Cheers,
>
> Dave.
>
> --
> Dave Chinner
> david@fromorbit.com
