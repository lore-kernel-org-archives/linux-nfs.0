Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail05.adl6.internode.on.net ([150.101.137.143]:39944 "EHLO
	ipmail05.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751417AbbIMXZc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Sep 2015 19:25:32 -0400
Date: Mon, 14 Sep 2015 09:25:29 +1000
From: Dave Chinner <david@fromorbit.com>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>,
        =?iso-8859-1?Q?P=E1draig?= Brady <P@draigbrady.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com,
        Christoph Hellwig <hch@infradead.org>, Coreutils <coreutils@gnu.org>
Subject: Re: [PATCH v1 0/8] VFS: In-kernel copy system call
Message-ID: <20150913232529.GT26895@dastard>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <55EEFCEE.5090000@draigBrady.com>
 <55EF279B.3020101@Netapp.com>
 <CALCETrXxRB-LXVb+=nkwfj0zEjWuXXTctkSAc9Oec0fgyOQ5Yg@mail.gmail.com>
 <55EF3EFD.3080302@draigBrady.com>
 <20150908212907.GD30681@birch.djwong.org>
 <CALCETrWAotvN+MBsxq4QLQBr_WAyydqMnipcaTM88rM8sSx43w@mail.gmail.com>
 <20150908223959.GE30681@birch.djwong.org>
 <CALCETrVsWBdqvAgwxHcG=gbcWRNPG2ZziWUg1g=siKDrDu7S2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALCETrVsWBdqvAgwxHcG=gbcWRNPG2ZziWUg1g=siKDrDu7S2Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 08, 2015 at 04:08:43PM -0700, Andy Lutomirski wrote:
> Can we have a clean way to figure out whether two file ranges are the
> same in a way that allows false negatives?  I.e. return 1 if the
> ranges are reflinks of each other and 0 if not?  Pretty please?  I've
> implemented that in the past on btrfs by syncing the ranges and then
> comparing FIEMAP output, but that's hideous.

That fundamentally doesn't work for userspace, because the moment
the filesystem drops it's locks on the inodes in the kernel after
doing the comparison the mappings can change.  IOWs, by the time the
information gets back to userspace, it's already wrong. e.g. cp made
this mistake by trying to use FIEMAP to optimise hole detection in
files and ended up with corrupt copies.

It really doesn't matter what the syscall/ioctl interface is, trying
to make application logic decisions based on inode block mappings
from userspace is racy and not safe and will go wrong...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
