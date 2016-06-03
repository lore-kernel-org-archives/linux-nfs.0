Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49642 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbcFCExE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jun 2016 00:53:04 -0400
Date: Fri, 3 Jun 2016 05:53:01 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Subject: Re: NFS/d_splice_alias breakage
Message-ID: <20160603045301.GP14480@ZenIV.linux.org.uk>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru>
 <20160603033750.GL14480@ZenIV.linux.org.uk>
 <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru>
 <20160603042648.GN14480@ZenIV.linux.org.uk>
 <20160603044253.GO14480@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160603044253.GO14480@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 03, 2016 at 05:42:53AM +0100, Al Viro wrote:
> On Fri, Jun 03, 2016 at 05:26:48AM +0100, Al Viro wrote:
> 
> > Looks like the right thing to do would be to do d_drop() at no_open:,
> > just before we call nfs_lookup().  If not earlier, actually...  How
> > about the following?
> 
> A bit of rationale: dentry in question is negative and attempt to open
> it has just failed; in case it's really negative we did that d_drop()
> anyway (and then unconditionally rehashed it).  In case when we proceed to
> nfs_lookup() and it does not fail, we'll have it rehashed there (with the
> right inode).  What do we lose from doing d_drop() on *any* error here?
> It's negative, with dubious validity.  In the worst case, we had open
> and lookup fail, but it's just us - the sucker really is negative and
> somebody else would be able to revalidate it.  If we drop it here (and
> not rehash later), that somebody else will have to allocate an in-core
> dentry before doing lookup or atomic_open.  Which is negligible extra
> burden.

I suspect that it got broken in commit 275bb3078 (NFSv4: Move dentry
instantiation into the NFSv4-specific atomic open code).  Prior to that
commit, d_drop() was there (error or no error).  Looks like 3.10+, indeed.
I agree that we shouldn't drop it on successful open, but it needs to be
done on errors.  All of them, not just ENOENT, as in that commit.
