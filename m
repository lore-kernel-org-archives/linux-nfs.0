Return-Path: <SRS0=5YGM=OL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71032C04EB8
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 20:47:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4052720834
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 20:47:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4052720834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725778AbeLBUr7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 15:47:59 -0500
Received: from ipmail06.adl2.internode.on.net ([150.101.137.129]:38357 "EHLO
        ipmail06.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725710AbeLBUr7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 15:47:59 -0500
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl2.internode.on.net with ESMTP; 03 Dec 2018 07:17:51 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gTYeb-0002fZ-Fs; Mon, 03 Dec 2018 07:47:49 +1100
Date:   Mon, 3 Dec 2018 07:47:49 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     Amir Goldstein <amir73il@gmail.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, willy@infradead.org,
        jlayton@kernel.org, stfrench@microsoft.com
Subject: Re: [PATCH v2 01/10] VFS generic copy_file_range() support
Message-ID: <20181202204749.GS19305@dastard>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
 <20181130200348.59524-2-olga.kornievskaia@gmail.com>
 <CAOQ4uxjXGPOPQTsgKnMx7YN2S1Oz3MDbg5kDf0VV1rK+9Ybu8A@mail.gmail.com>
 <20181201220045.GQ19305@dastard>
 <CAN-5tyFBjVM6HOGZbjy+k4eCOHyDdvXsiGOHSR+gRXCHS3fosA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyFBjVM6HOGZbjy+k4eCOHyDdvXsiGOHSR+gRXCHS3fosA@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sat, Dec 01, 2018 at 10:12:05PM -0500, Olga Kornievskaia wrote:
> On Sat, Dec 1, 2018 at 5:00 PM Dave Chinner <david@fromorbit.com> wrote:
> >
> > On Sat, Dec 01, 2018 at 10:11:48AM +0200, Amir Goldstein wrote:
> > > On Fri, Nov 30, 2018 at 10:04 PM Olga Kornievskaia
> > > <olga.kornievskaia@gmail.com> wrote:
> > > >
> > > > Relax the condition that input files must be from the same
> > > > file systems.
> > > >
> > > > Add checks that input parameters adhere semantics.
> > > >
> > > > If no copy_file_range() support is found, then do generic
> > > > checks for the unsupported page cache ranges, LFS, limits,
> > > > and clear setuid/setgid if not running as root before calling
> > > > do_splice_direct(). Update atime,ctime,mtime afterwards.
> > > >
> > > > Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> > > > ---
> > >
> > > This patch is either going to bring you down or make you stronger ;-)
> > >
> > > This is not how its done. Behavior change and refactoring mixed into
> > > one patch is wrong for several reasons. And when you relax same sb
> > > check you need to restrict it inside filesystems, like your previous patch
> > > did.
> > .....
> > > In any case, I hear that Dave is neck deep in fixing copy_file_range()
> > > so changes to this function should be collaborated with him. Or better
> > > yet, wait until he posts his fixes and carry on from there.
> >
> > Yeah, because I've heard nothing for a month and this is kinda
> > important
> 
> Dave I think that's unfair. It is important. NFS is actually the file
> system that needed VFS support for cross fs copy_file_range and I was
> working on it. If you were in doubt, you could have emailed and asked
> me.

Last I heard from you was "this isn't my problem and I don't have
time to deal with it". You were fairly unambiguous in saying you
weren't going to spend any time on it.

> I'm unsure now what does this mean. I have a patch series with a VFS
> patch that went thru the extensive review (people spend time on it)
> and an NFS patch series that depends on it that is ready for the
> upstream push. Are you saying that the VFS patch is no longer welcomed
> and thus NFS series is no longer viable either?

No, I'm saying that this is urgent work and needs to be separated
from the NFS patch series, of which there are now two and you've
split copy_file_range() changes across both patch sets.
copy_file_range() is broken for *everyone*, not just NFS.  i.e.
fixing these problems should not be tied to some other filesystem
feature patchset.

> , I have a series of 8-9 patches that make all the fixes we
> > need, push the cross-filesystem checks down into the filesystems,
> > and let filesystems handle the fallback to a splice based copy
> > themselves (because there are way more fallback cases than just
> > EOPNOPSUPP and EXDEV).
> 
> Are you saying it is each individual filesystem responsibility to
> fallback on splice? Isn't that a step backwards? Each individual
> filesystem is going to implement the same code of calling
> do_splice_direct() to do the functionally that could and should be in
> VFS?

I've done this because one of the problems I've found is that
different filesystems *do not fall back consistently*. e.g. the NFS
client will return -EINVAL if src/dst are the same file, but -EINVAL
is not one of the errors that the vfs code falls back to a data copy
on.

This is despite the fact that the fallback path can copy to/from
the same file, we support same file copy through the
->remap_file_range offload, etc. IOWs, the behaviour of the syscall
when it comes to single file ranges is completely inconsistent
because fallbacks are implemented on a filesystem-by-filesystem
basis.

I called the fallback generic_copy_file_range(), and filesystems that
implement ->copy_file_range() are responsible for calling it
themselves if they want a fallback. That's because there may be
different error/constraint conditions at the filesystem level that
prevent offloading the copy, and we can't distinguish at the VFs
between "-EINVAL means fallback because it was a single file copy"
and "-EINVAL means fail, parameter out of range".

IOWs, if you implement ->copy_file_range() you take full
resposnsibility for implementing the copying function. This is
exactly what we do for all the other file methods, so this is just
making the implementation behaviour consistent with the rest of the
code.

FWIW, this also points out a problem with the copy_file_range()
definition - it does not say WTF should happen if the copy ranges
/overlap/ in the same file. clone is clear on that - support is
determined by the filesystem (i.e. "EINVAL [...] XFS and Btrfs do
not support overlapping reflink ranges in the same file."). For
copying, the fallback code can't copy the file data correctly if the
ranges overlap, so I've added checks to make this illegal and added
that overlapping ranges are not supported to the man page.....

These are the sort of API definition problems that I'm fixing with
right now, and I'm writing tests to make sure that all filesystems
will behave the same way for given copy scenarios.

i.e. I'm not doing this so I can get a NFS feature patchset merged,
I'm doing this to make the copy_file_range API well defined and
robust and allow implementations to be verified against the
specification the man page lays out.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
