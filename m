Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41615 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753668Ab3JBSPY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Oct 2013 14:15:24 -0400
Date: Wed, 2 Oct 2013 14:14:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, sandeen@redhat.com
Subject: Re: why is i_ino unsigned long, anyway?
Message-ID: <20131002181457.GG14808@fieldses.org>
References: <20130912160324.GE1462@fieldses.org>
 <20130912193328.GP13318@ZenIV.linux.org.uk>
 <20130929115454.GA3953@infradead.org>
 <20131002142527.GD14808@fieldses.org>
 <20131002154320.GE14808@fieldses.org>
 <20131002160448.GA23875@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131002160448.GA23875@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 02, 2013 at 09:04:48AM -0700, Christoph Hellwig wrote:
> On Wed, Oct 02, 2013 at 11:43:20AM -0400, J. Bruce Fields wrote:
> > 
> > Just for fun, I took a stab at an xfs-specific method.
> > 
> > Pretty much untested and probably wrong as I know nothing about xfs, but
> > it does seem like it allows some minor simplifications compared to the
> > common helper.
> > 
> > But as Christoph says other filesystems have the same problem so we
> > probably want to fix the common helper anyway.
> 
> You'll need this in at least ext4, btrfs, gfs2, ocfs2 and probably more.
> So fixing this for real sounds like the best deal.

Based on "git grep '\bget_name\b' fs/".... Actually gfs2 and btrfs
already have their own get_name methods.  They look like they probably
handle 64-bit inodes fine.

That leaves xfs, ext4, and ocfs2.

Anyway I'm still in favor of fixing the helper.

--b.
