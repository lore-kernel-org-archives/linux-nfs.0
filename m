Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:35567 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811Ab3BRUPN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2013 15:15:13 -0500
Date: Mon, 18 Feb 2013 20:15:02 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@redhat.com>
Cc: NeilBrown <neilb@suse.de>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: More fun with unmounting ESTALE directories.
Message-ID: <20130218201502.GH4503@ZenIV.linux.org.uk>
References: <20130212113813.427b8e05@notabene.brown>
 <20130214104230.013b7f71@tlielax.poochiereds.net>
 <20130218132509.0ce779de@notabene.brown>
 <20130218184609.GF4503@ZenIV.linux.org.uk>
 <20130218144655.42b3f3e3@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130218144655.42b3f3e3@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 18, 2013 at 02:46:55PM -0500, Jeff Layton wrote:

> Ok, that helps. In that case, this patch might be a reasonable
> forward-port of the one Neil sent earlier today. Note that this doesn't
> really do anything for the umount problem, but it does seem to fix the
> testcase for the problem I've been looking at.
> 
> Thoughts?

If we really go for "in this case revalidate should be weaker", we might
as well introduce a separate method for it.

As it is, we have several callers of ->d_revalidate(); this one (in
complete_walk(), only for FS_REVAL_DOT filesystems) and ones in
lookup_dcache() and lookup_fast() (in both cases we have and want the
name to match).  There are only two fs with FS_REVAL_DOT present - nfs
and 9p.  *IF* we want to make ->d_revalidate() on NFS behave differently
in complete_walk() case, it would argue for just splitting the method
in two, replacing FS_REVAL_DOT with "dentry has this method" and probably
taking a good look at what 9p needs in the same case.
