Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:58558 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbbL0R5U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Dec 2015 12:57:20 -0500
Date: Sun, 27 Dec 2015 17:57:09 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Donald Buczek <buczek@molgen.mpg.de>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: Don't perform cached access checks before we've
 OPENed the file
Message-ID: <20151227175709.GH20997@ZenIV.linux.org.uk>
References: <CAHQdGtR1xE1dxjrBSGNY4hn6qKpmAhd+DAX=z=53mN0V84FiyQ@mail.gmail.com>
 <1451185588-69667-1-git-send-email-trond.myklebust@primarydata.com>
 <567FD72A.7090903@molgen.mpg.de>
 <CAHQdGtRSPrV=eV_VEGbpp47qfpW93GSouoEzaseHDq5enMtCDg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRSPrV=eV_VEGbpp47qfpW93GSouoEzaseHDq5enMtCDg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 27, 2015 at 11:23:55AM -0500, Trond Myklebust wrote:
> > PS:
> >
> > I don't yet understand the point of execute_ok. It doesn't even consider the
> > uid.
> 
> ...or the group ownership or anything other than whether or not at
> least one execute bit is set. That's a convention that was set in the
> VFS a long time ago,

... by yourself, if you recall the patch that moved that check from
open_exec() to permission(), to get consistency between access() and
execve().

> and that Miklos' patches later pushed down into
> the filesystems.
> I'm OK with removing it, if someone can explain to me what it was
> intended to enforce in the first place, so that we can have a
> discussion about why it may be obsolete.

"Not even root gets to execute a binary that doesn't have a single exec bit
on it" goes _way_ back.  And not just in terms of Linux -
v5 /usr/sys/ken/fio.c:access() has
        if(u.u_uid == 0) {
                if(m == IEXEC && (ip->i_mode & 
                        (IEXEC | (IEXEC>>3) | (IEXEC>>6))) == 0)
                                return(1);
                return(0);
        }
so this had been introduced somewhere between v3 and v5 (AFAIK, v4 source
is gone and I hadn't crawled through the v4 manpages to see if that has
got a mention).  At the very least it's been there since Nov 26 1974...
