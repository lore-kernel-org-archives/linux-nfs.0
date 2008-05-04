From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] exportfs: fix incorrect EACCES in reconnect_path()
Date: Mon, 5 May 2008 09:22:49 +1000
Message-ID: <18462.17737.353976.999538@notabene.brown>
References: <20080407184346.GF3305@fieldses.org>
	<20080409133639.GA9588@lst.de>
	<18454.45086.254692.412079@notabene.brown>
	<20080429163554.GE20420@fieldses.org>
	<20080429174004.GA28719@janus>
	<20080430174736.GB20377@fieldses.org>
	<20080502151646.GA5515@janus>
	<20080502153439.GC7376@infradead.org>
	<20080502155617.GD18401@fieldses.org>
	<1209744293.8294.19.camel@heimdal.trondhjem.org>
	<20080502221216.GP21918@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Christoph Hellwig <hch@infradead.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Christoph Hellwig <hch@lst.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39109 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757323AbYEEC0c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 May 2008 22:26:32 -0400
In-Reply-To: message from J. Bruce Fields on Friday May 2
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday May 2, bfields@fieldses.org wrote:
> On Fri, May 02, 2008 at 12:04:53PM -0400, Trond Myklebust wrote:
> > 
> > AFAICS, the real problem here is that nfsd is dropping its privileged
> > mode too early. Why can't you call reconnect_path() using nfsd's root
> > permissions instead of dropping permissions checks altogether?
> 
> That's an interesting idea.
> 
> As I understand it, nfsd sets the current task's credentials only once,
> in nfsd_setuser, called from fh_verify().  The change lingers around
> until next time we do fh_verify().  So in addition to moving the
> nfsd_setuser() call to after the lookup of the dentry (so after
> exportfs_decode_fh(), we'd also need to add an explicit acquisition of
> whatever permissions we need before we do that lookup.

I have substantial sympathy for this approach.
The "explicit acquisition" would probably just be
		current->cap_effective =
			cap_raise_nfsd_set(current->cap_effective,
					   current->cap_permitted);
(from nfsd_setuser).  This should reclaim the RACOVERRIDE permission
which should be enough.

The one problem that I see is that it would invalidate the
		err = permission(parent->d_inode, MAY_EXEC, NULL);
check in nfsd_acceptable.

Currently if we have "subtree_check" set, not only must the file be in
the right subtree of the filesystem, but the user accessing the file
must have 'x' permission on every parent directory.  For that test to
work we must have already set the effective uid correctly.

Now it could be argued that this permission test is really a dumb idea
that buys nothing and costs much.  And if you were to queue a patch to
get rid of it, I doubt you would get any objections .... certainly not
from me :-)

NeilBrown
