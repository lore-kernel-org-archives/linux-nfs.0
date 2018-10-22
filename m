Return-Path: <SRS0=k5hI=NC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96027C67863
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 05:42:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5E5C320644
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Oct 2018 05:42:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eDVdwQU+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E5C320644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727385AbeJVN7n (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Oct 2018 09:59:43 -0400
Received: from mail-yw1-f66.google.com ([209.85.161.66]:44957 "EHLO
        mail-yw1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726784AbeJVN7m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2018 09:59:42 -0400
Received: by mail-yw1-f66.google.com with SMTP id t78-v6so824328ywg.11;
        Sun, 21 Oct 2018 22:42:41 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bN/QTOFYlGzihYw12coFOWAJpI4OqQTPB1y4x703j1M=;
        b=eDVdwQU+e+vxO+oQlsQdggN2kYigbVMrkmCKxsHkK/GS38VLB2XhAI58e92EdoH+7u
         dTaNPvQ0AybBnWRRMMb1xuw0J1b3DYN5c9MNWZt3fQOn24by8+tvmzQmoUtlspZEVzBe
         nf0pJgLxikW68/HUViS8z54nhOp2e0Hx3nt6al0ZEdSh3Gi5zCys9x1Uyv5xrg8iyZir
         Fm1HDYO/NliNaUlVWlLlU+peWCnYdxF3FMKqesfs3wHSbK7+Vk5Pgx5+JO2vvzZKBt3+
         MUue1ubBo0ceniL4YjJzfxLB0cC9Mo4P18HwoEOGPu6Pzm8ELPoEoGxG9d8lXlT4N6A4
         EAGA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=bN/QTOFYlGzihYw12coFOWAJpI4OqQTPB1y4x703j1M=;
        b=cJnI0GUYyWxXHqltX3ELx4tKhI+xLXcUFcKjlRzaQ3SnCSAZdlJGW7xwn8+x8KKDAw
         WE0FLx74Ml/oO0WIl9lg/tqkqTSGstCXLNDCq3vvwPGoZFzMiLg3gK8Dkjv1lLaL4a0+
         GkReZJ56S1rYMycCZWkehYB8+7V3j4ACEyyuihPMiodDkPvOWig+5dfyMIU9rCLMIsQU
         ValF6Ii4fzzvVGZmOnAVPS/LOcviXZp6aOlyD8mipCxMISpUHx1jopea2xJrt6GbVhbZ
         OW8nx8YsoPbBQzJM93mvYUrdezfU1w8tQdb7mGlBvmSBRvSwuKQhPPrsoj/vivhtTprH
         QdBQ==
X-Gm-Message-State: ABuFfoi2/om70NDRFkT7Y6KThl+tYLQ3t86NtZ3TjWfk/NmL42KUnNh+
        2bVAl7p6Hr4IRvzNtIFfbHiIsbd7ZL3zYgRvvdk=
X-Google-Smtp-Source: ACcGV63mmG7OxWCXg8T//oq0p+/rRnpa1NnZAEAfJc5YzLvqbrx7ByY7EWbZ2sD4QikmtvJ8wuIK62p393S2FJhY8Vk=
X-Received: by 2002:a81:8604:: with SMTP id w4-v6mr31632728ywf.409.1540186961142;
 Sun, 21 Oct 2018 22:42:41 -0700 (PDT)
MIME-Version: 1.0
References: <154013850285.29026.16168387526580596209.stgit@magnolia>
 <20181022022112.GW6311@dastard> <20181022043741.GX6311@dastard>
 <20181022045249.GP32577@ZenIV.linux.org.uk> <20181022050851.GY6311@dastard>
In-Reply-To: <20181022050851.GY6311@dastard>
From:   Amir Goldstein <amir73il@gmail.com>
Date:   Mon, 22 Oct 2018 08:42:29 +0300
Message-ID: <CAOQ4uxhjpieVdDfrATStT8YQZZwX=rrWtiMX=FSXFdHdqsUaDg@mail.gmail.com>
Subject: Re: [PATCH v6 00/28] fs: fixes for serious clone/dedupe problems
To:     Dave Chinner <david@fromorbit.com>
Cc:     Al Viro <viro@zeniv.linux.org.uk>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Eric Sandeen <sandeen@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-cifs@vger.kernel.org,
        overlayfs <linux-unionfs@vger.kernel.org>,
        linux-xfs <linux-xfs@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>,
        Linux Btrfs <linux-btrfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        ocfs2-devel@oss.oracle.com
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 22, 2018 at 8:09 AM Dave Chinner <david@fromorbit.com> wrote:
>
> On Mon, Oct 22, 2018 at 05:52:49AM +0100, Al Viro wrote:
> > On Mon, Oct 22, 2018 at 03:37:41PM +1100, Dave Chinner wrote:
> >
> > > Ok, this is a bit of a mess. the patches do not merge cleanly to a
> > > 4.19-rc1 base kernel because of all the changes to
> > > include/linux/fs.h that have hit the tree after this. There's also
> > > failures against Documentation/filesystems/fs.h
> > >
> > > IOWs, it's not going to get merged through the main XFS tree because
> > > I don't have the patience to resolve all the patch application
> > > failures, then when it comes to merge make sure all the merge
> > > failures end up being resolved correctly.
> > >
> > > So if I take it through the XFS tree, it will being a standalone
> > > branch based on 4.19-rc8 and won't hit linux-next until after the
> > > first XFS merge when I can rebase the for-next branch...
> >
> > How many conflicts does it have with XFS tree?  I can take it via
> > vfs.git...
>
> I gave up after 4 of the first 6 or 7 patches had conflicts in vfs
> and documentation code.
>
> There were changes that went into 4.19-rc7 that changed
> {do|vfs}_clone_file_range() prototypes and this patchset hits
> prototypes adjacent to that multiple times. There's also a conflicts
> against a new f_ops->fadvise method. These all appear to be direct
> fallout of fixes needed for all the overlay f_ops changes.
>
> The XFS changes at the end of the patchset are based on
> commits that were merged into -rc7 and -rc8, so if you are using
> -rc8 as your base, then it all merges cleanly. There are no
> conflicts with the current xfs/for-next branch.
>
> I've just merged and built it into my test tree (-rc8, xfs/for-next,
> djwong/devel) so I can test it properly, but if it merges cleanly
> with the vfs tree you are building then that's probably the easiest
> way to merge it all...
>

Dave,

Pardon my ignorance, but its an opportunity for me to learn a thing
or two about kernel development process.

First, I asked Darrick to base his patches on top of -rc8 intentionally
to avoid the conflict with "swap names of {do|vfs}_clone_file_range()" (*).
My change pre dates his changes so it makes sense.

What I don't get is why does it need to create a problem?
Can you not back merge -rc8 into xfs/for-next (or into vfs/for-next for
that matter) and then merge Darrick's patches?

What is the culprit with doing that?

Thanks,
Amir.

(*) Yes, I do realize "swap names of {do|vfs}_clone_file_range()"
is a backporting landmine. It's been on my todo list to send it to Greg
here I am going to do it now...
