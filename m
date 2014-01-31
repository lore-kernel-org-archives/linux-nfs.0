Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49832 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932795AbaAaTsc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Jan 2014 14:48:32 -0500
Date: Fri, 31 Jan 2014 14:47:58 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [PATCH] dcache: make d_splice_alias use d_materialise_unique
Message-ID: <20140131194758.GA24618@fieldses.org>
References: <20140115151749.GF23999@fieldses.org>
 <20140117121723.GA18375@infradead.org>
 <20140117153917.GA26636@fieldses.org>
 <20140117210343.GD26636@fieldses.org>
 <20140117212655.GE26636@fieldses.org>
 <20140123212700.GA30466@fieldses.org>
 <20140131184258.GN10323@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140131184258.GN10323@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 31, 2014 at 06:42:58PM +0000, Al Viro wrote:
> On Thu, Jan 23, 2014 at 04:27:00PM -0500, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > d_splice_alias can create duplicate directory aliases (in the !new
> > case), or (in the new case) d_move directories without holding
> > appropriate locks.
> 
> Details, please.  In the new case, we have IS_ROOT() alias found;
> what locks would that need?  Note that d_materialise_unique() won't
> bother with __d_unalias() in such case - it does what d_move() would've
> done, without taking any mutex.

Of course you're right, and Miklos had pointed this out already and I
forgot to update the changelog.  Apologies!

> In the !new case, we'd need a preexisting dentry alias, complete with
> parent.  IOW, that's the case when directory already in the tree
> has been found during lookup from another parent.  In which case
> we shouldn't be using d_splice_alias() at all, as it is (and it
> certainly can't happen for any local fs).

Yes, except: won't a local filesystem will still hit this case on a
filesystem that's corrupted to link a directory into multiple parents?

Though in that case arguably the right behavior might be, say, WARN and
return -EIO.

> Now, I agree that merging that with d_materialise_unique() might be
> a good idea, but commit message is wrong as it, AFAICS.

Agreed, I'll fix and resend.

Though now I wonder whether it's worth keeping two different interfaces,
one for the case when finding a parent in a different directory is an
error and one for the case when it's normal and you'd just like it fixed
up.

(Then one remaining thing I don't understand is how to make that fixing
up reliable.  Or is there some reason nobody hits the _EBUSY case of
__d_unalias?)

--b.
