Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53044 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751512AbaAPPlf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jan 2014 10:41:35 -0500
Date: Thu, 16 Jan 2014 10:41:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Miklos Szeredi <mszeredi@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
Message-ID: <20140116154132.GB16829@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
 <1389807296.16290.32.camel@tucsk.piliscsaba.szeredi.hu>
 <20140115175723.GA4596@fieldses.org>
 <CAJfpegs0+t4S1y9mhRMJMAERh-a95KjK_JQ7F5SRrfsNZOdoMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegs0+t4S1y9mhRMJMAERh-a95KjK_JQ7F5SRrfsNZOdoMA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 15, 2014 at 07:25:11PM +0100, Miklos Szeredi wrote:
> On Wed, Jan 15, 2014 at 6:57 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Wed, Jan 15, 2014 at 06:34:56PM +0100, Miklos Szeredi wrote:
> >> On Wed, 2014-01-15 at 10:17 -0500, J. Bruce Fields wrote:
> >> > From: "J. Bruce Fields" <bfields@redhat.com>
> >> >
> >> > d_splice_alias can create duplicate directory aliases (in the !new
> >> > case), or (in the new case) d_move without holding appropriate locks.
> >>
> >> It can d_move, because the dentry is known to be disconnected, i.e. it
> >> doesn't have a parent for which we could obtain the lock.
> >
> > DCACHE_DISCONNECTED doesn't mean that.
> 
> You're right, but I'm also right, because __d_find_alias() will check
> IS_ROOT() too.  So only "root" disconnected dentries will be moved.

You're right, I forgot that check.

> >> One subtle difference is that for a non-directory d_splice_alias() will
> >> reconnect a DCACHE_DISCONNECTED dentry if one exists, while
> >> d_materialise_unique() will not.
...
> >> Does this matter in practice?   The small number of extra dentries
> >> probably does not matter.
> >
> > Directories are assumed to have unique aliases.  When they don't, the
> > kernel can deadlock or crash.
> 
> What I meant is that d_materialise_unique() will currently not reuse
> disconnected *nondirectory* dentries, hence there may be more aliases
> than necessary.  This could easily be fixed, though.

And, sorry, I did miss that you said "non-directory".  But I think you
have that backwards: d_splice_alias looks like:

	if (inode && S_ISDIR(inode->i_mode)) {
		...
	} else {
		d_instantiate(dentry, inode);
		if (d_unhashed(dentry))
			d_rehash(dentry);
	}

So it ignores any existing aliases in the non-directory case.

d_materialise_unique by contrast calls __d_instantiate_unique, which
looks like it should avoid adding duplicates.

So I think switching everyone to d_materialiase_unique would result in
fewer dentries.  But I've never seen any complaint about the issue and
like you don't see a reason this would matter much either way.

--b.
