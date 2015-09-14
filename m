Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:32974 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751944AbbINRxn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Sep 2015 13:53:43 -0400
Received: by oixx17 with SMTP id x17so81198489oix.0
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2015 10:53:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150913232529.GT26895@dastard>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <55EEFCEE.5090000@draigBrady.com> <55EF279B.3020101@Netapp.com>
 <CALCETrXxRB-LXVb+=nkwfj0zEjWuXXTctkSAc9Oec0fgyOQ5Yg@mail.gmail.com>
 <55EF3EFD.3080302@draigBrady.com> <20150908212907.GD30681@birch.djwong.org>
 <CALCETrWAotvN+MBsxq4QLQBr_WAyydqMnipcaTM88rM8sSx43w@mail.gmail.com>
 <20150908223959.GE30681@birch.djwong.org> <CALCETrVsWBdqvAgwxHcG=gbcWRNPG2ZziWUg1g=siKDrDu7S2Q@mail.gmail.com>
 <20150913232529.GT26895@dastard>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 14 Sep 2015 10:53:23 -0700
Message-ID: <CALCETrUALh=tiK9S0LhvJuy4jK-1vk5bjnz2b0faWhw0mSLs=g@mail.gmail.com>
Subject: Re: [PATCH v1 0/8] VFS: In-kernel copy system call
To: Dave Chinner <david@fromorbit.com>
Cc: Zach Brown <zab@zabbo.net>, Coreutils <coreutils@gnu.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        Anna Schumaker <Anna.Schumaker@netapp.com>, andros@netapp.com,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigbrady.com>,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Chris Mason <clm@fb.com>, Linux API <linux-api@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 13, 2015 4:25 PM, "Dave Chinner" <david@fromorbit.com> wrote:
>
> On Tue, Sep 08, 2015 at 04:08:43PM -0700, Andy Lutomirski wrote:
> > Can we have a clean way to figure out whether two file ranges are the
> > same in a way that allows false negatives?  I.e. return 1 if the
> > ranges are reflinks of each other and 0 if not?  Pretty please?  I've
> > implemented that in the past on btrfs by syncing the ranges and then
> > comparing FIEMAP output, but that's hideous.
>
> That fundamentally doesn't work for userspace, because the moment
> the filesystem drops it's locks on the inodes in the kernel after
> doing the comparison the mappings can change.  IOWs, by the time the
> information gets back to userspace, it's already wrong. e.g. cp made
> this mistake by trying to use FIEMAP to optimise hole detection in
> files and ended up with corrupt copies.
>
> It really doesn't matter what the syscall/ioctl interface is, trying
> to make application logic decisions based on inode block mappings
> from userspace is racy and not safe and will go wrong...
>

I agree, and that thing was just an experiment.  I'd love to see a
sane and correct interface, though.


--Andy
