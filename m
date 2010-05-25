Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35149 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758771Ab0EYB6Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 21:58:25 -0400
Date: Tue, 25 May 2010 02:58:22 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
Message-ID: <20100525015822.GV31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
 <20100524115903.GP31073@ZenIV.linux.org.uk>
 <20100525111405.04eaf924@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100525111405.04eaf924@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 25, 2010 at 11:14:05AM +1000, Neil Brown wrote:

> I must confess though that I don't feel I understand VFS name lookup properly
> any more.  Since intents were added it seems to have become much more obscure
> and complex.  I cannot help thinking that there must be a better way:
> distinguish between the various cases at a higher level so we don't need as
> many flags being passed around and interpreted by widely separate pieces of
> code.  I don't have a concrete proposal but I would certainly be interested
> to work on one if there were any hope of real change.
> Thoughts?

Intents are vile crap that has been introduced by the nfs folks to start
with...  I've been trying to localize the mess and it's got a _lot_ better
than it used to be a year ago, but they are still not gone.  And yes, I
plan to kill that crap.  Basically, most of the do_last() guts will become
a method that would get struct file *explicitly* and ask the fs to do
(possibly atomic) open.  With normal filesystems defaulting to what's there
right now.

The main obstacle at the moment is in ->d_revalidate() abuses.  NFS, CIFS
*and* autofs, the last one in a way that isn't really compatible with what
NFS et.al. are trying to do.  Overloading of ->d_revalidate() and ->lookup()
to do the work of open() doesn't help, and the horrors nfs4 piles on top
of that are even scarier.

_Another_ fine piece of something is ->follow_link() abuses, including
referrals' treatment.  Also tied to the previous messes.

We definitely will need to get VFS-to-fs APIs in that area changed; most of
the mess has been created by the deeply misguided efforts to keep the API
changes minimal.

As for the flags, quite a few will be gone once we split "opening the final
component" from the normal cases.  Google for lookup_instantiate_filp+shit
for details of these plans...
