Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:34539 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758306Ab0EYBOP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 21:14:15 -0400
Date: Tue, 25 May 2010 11:14:05 +1000
From: Neil Brown <neilb@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
Message-ID: <20100525111405.04eaf924@notabene.brown>
In-Reply-To: <20100524115903.GP31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
	<20100524115903.GP31073@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 24 May 2010 12:59:03 +0100
Al Viro <viro@ZenIV.linux.org.uk> wrote:

> On Mon, May 24, 2010 at 04:57:56PM +1000, Neil Brown wrote:
> > 
> > Commit 1f36f774b22a0ceb7dd33eca626746c81a97b6a5 broke FS_REVAL_DOT semantics.
> > 
> > In particular, before this patch, the command
> >    ls -l
> > in an NFS mounted directory would always check if the directory on the server
> > had changed and if so would flush and refill the pagecache for the dir.
> > After this patch, the same "ls -l" will repeatedly return stale date until
> > the cached attributes for the directory time out.
> > 
> > The following patch fixes this by ensuring the d_revalidate is called by
> > do_last when "." is being looked-up.
> > link_path_walk has already called d_revalidate, but in that case LOOKUP_OPEN
> > is not set so nfs_lookup_verify_inode chooses not to do any validation.
> > 
> > The following patch restores the original behaviour.
> > 
> > Cc: stable@kernel.org
> > Signed-off-by: NeilBrown <neilb@suse.de>
> 
> Applied, but I really don't like the way you do it; note that e.g. foo/bar/.
> gets that revalidation as well, for no good reason.  If anything, shouldn't
> we handle that thing in the _beginning_ of pathname resolution, not in
> the end?  For now it'd do, and it's a genuine regression, but...
> 

Thanks.

I think I see what you mean by "at the beginning" - the problem path is
simply ".", and both the start and end of that are "." so we can handle at
either end...  But I don't think there is any other special handling of the
'start' of a path, so I imagine it would be a fairly ugly special case.

We could avoid the extra GETATTR in "foo/bar/." by allowing NFS to keep some
state in the namei_data to record that it has valid attributes for a given
dentry so if it sees the same dentry again it doesn't need to revalidate.

I must confess though that I don't feel I understand VFS name lookup properly
any more.  Since intents were added it seems to have become much more obscure
and complex.  I cannot help thinking that there must be a better way:
distinguish between the various cases at a higher level so we don't need as
many flags being passed around and interpreted by widely separate pieces of
code.  I don't have a concrete proposal but I would certainly be interested
to work on one if there were any hope of real change.
Thoughts?

Thanks,
NeilBrown

> BTW, here's a question for nfs client folks: is it true that for any two
> pathnames on _client_ resolving to pairs (mnt1, dentry) and (mnt2, dentry)
> resp., nfs_devname(mnt1, dentry, ...) and nfs_devname(mnt2, dentry, ...)
> should yield the strings that do not differ past the ':' (i.e. that the
> only possible difference is going to be in spelling the server name)?

