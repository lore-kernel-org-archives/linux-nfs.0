Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:46376 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753801AbbIHV3r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2015 17:29:47 -0400
Date: Tue, 8 Sep 2015 14:29:07 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: =?iso-8859-1?Q?P=E1draig?= Brady <P@draigbrady.com>
Cc: Andy Lutomirski <luto@amacapital.net>,
        Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Linux btrfs Developers List <linux-btrfs@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>, Zach Brown <zab@zabbo.net>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        Michael Kerrisk-manpages <mtk.manpages@gmail.com>, andros@netapp.com,
        Christoph Hellwig <hch@infradead.org>, Coreutils <coreutils@gnu.org>
Subject: Re: [PATCH v1 0/8] VFS: In-kernel copy system call
Message-ID: <20150908212907.GD30681@birch.djwong.org>
References: <1441397823-1203-1-git-send-email-Anna.Schumaker@Netapp.com>
 <55EEFCEE.5090000@draigBrady.com>
 <55EF279B.3020101@Netapp.com>
 <CALCETrXxRB-LXVb+=nkwfj0zEjWuXXTctkSAc9Oec0fgyOQ5Yg@mail.gmail.com>
 <55EF3EFD.3080302@draigBrady.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <55EF3EFD.3080302@draigBrady.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 08, 2015 at 09:03:09PM +0100, Pádraig Brady wrote:
> On 08/09/15 20:10, Andy Lutomirski wrote:
> > On Tue, Sep 8, 2015 at 11:23 AM, Anna Schumaker
> > <Anna.Schumaker@netapp.com> wrote:
> >> On 09/08/2015 11:21 AM, Pádraig Brady wrote:
> >>> I see copy_file_range() is a reflink() on BTRFS?
> >>> That's a bit surprising, as it avoids the copy completely.
> >>> cp(1) for example considered doing a BTRFS clone by default,
> >>> but didn't due to expectations that users actually wanted
> >>> the data duplicated on disk for resilience reasons,
> >>> and for performance reasons so that write latencies were
> >>> restricted to the copy operation, rather than being
> >>> introduced at usage time as the dest file is CoW'd.
> >>>
> >>> If reflink() is a possibility for copy_file_range()
> >>> then could it be done optionally with a flag?
> >>
> >> The idea is that filesystems get to choose how to handle copies in the
> >> default case.  BTRFS could do a reflink, but NFS could do a server side

Eww, different default behaviors depending on the filesystem. :)

> >> copy instead.  I can change the default behavior to only do a data copy
> >> (unless the reflink flag is specified) instead, if that is desirable.
> >>
> >> What does everybody think?
> > 
> > I think the best you could do is to have a hint asking politely for
> > the data to be deep-copied.  After all, some filesystems reserve the
> > right to transparently deduplicate.
> > 
> > Also, on a true COW filesystem (e.g. btrfs sometimes), there may be no
> > advantage to deep copying unless you actually want two copies for
> > locality reasons.
> 
> Agreed. The relink and server side copy are separate things.
> There's no advantage to not doing a server side copy,
> but as mentioned there may be advantages to doing deep copies on BTRFS
> (another reason not previous mentioned in this thread, would be
> to avoid ENOSPC errors at some time in the future).
> 
> So having control over the deep copy seems useful.
> It's debatable whether ALLOW_REFLINK should be on/off by default
> for copy_file_range().  I'd be inclined to have such a setting off by default,
> but cp(1) at least will work with whatever is chosen.

So far it looks like people are interested in at least these "make data appear
in this other place" filesystem operations:

1. reflink
2. reflink, but only if the contents are the same (dedupe)
3. regular copy
4. regular copy, but make the hardware do it for us
5. regular copy, but require a second copy on the media (no-dedupe)
6. regular copy, but don't CoW (eatmyothercopies) (joke)

(Please add whatever ops I missed.)

I think I can see a case for letting (4) fall back to (3) since (4) is an
optimization of (3).

However, I particularly don't like the idea of (1) falling back to (3-5).
Either the kernel can satisfy a request or it can't, but let's not just
assume that we should transmogrify one type of request into another.  Userspace
should decide if a reflink failure should turn into one of the copy variants,
depending on whether the user wants to spread allocation costs over rewrites or
pay it all up front.  Also, if we allow reflink to fall back to copy, how do
programs find out what actually took place?  Or do we simply not allow them to
find out?

Also, programs that expect reflink either to finish or fail quickly might be
surprised if it's possible for reflink to take a longer time than usual and
with the side effect that a deep(er) copy was made.

I guess if someone asks for both (1) and (3) we can do the fallback in the
kernel, like how we handle it right now.

--D

> 
> thanks,
> Pádraig.
