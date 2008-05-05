From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] exportfs: fix incorrect EACCES in reconnect_path()
Date: Mon, 5 May 2008 13:47:16 -0400
Message-ID: <20080505174716.GA12814@fieldses.org>
References: <18454.45086.254692.412079@notabene.brown> <20080429163554.GE20420@fieldses.org> <20080429174004.GA28719@janus> <20080430174736.GB20377@fieldses.org> <20080502151646.GA5515@janus> <20080502153439.GC7376@infradead.org> <20080502155617.GD18401@fieldses.org> <1209744293.8294.19.camel@heimdal.trondhjem.org> <20080502221216.GP21918@fieldses.org> <18462.17737.353976.999538@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Christoph Hellwig <hch@infradead.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Christoph Hellwig <hch@lst.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45720 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750799AbYEERr2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 May 2008 13:47:28 -0400
In-Reply-To: <18462.17737.353976.999538-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 05, 2008 at 09:22:49AM +1000, Neil Brown wrote:
> On Friday May 2, bfields@fieldses.org wrote:
> > On Fri, May 02, 2008 at 12:04:53PM -0400, Trond Myklebust wrote:
> > > 
> > > AFAICS, the real problem here is that nfsd is dropping its privileged
> > > mode too early. Why can't you call reconnect_path() using nfsd's root
> > > permissions instead of dropping permissions checks altogether?
> > 
> > That's an interesting idea.
> > 
> > As I understand it, nfsd sets the current task's credentials only once,
> > in nfsd_setuser, called from fh_verify().  The change lingers around
> > until next time we do fh_verify().  So in addition to moving the
> > nfsd_setuser() call to after the lookup of the dentry (so after
> > exportfs_decode_fh(), we'd also need to add an explicit acquisition of
> > whatever permissions we need before we do that lookup.
> 
> I have substantial sympathy for this approach.
> The "explicit acquisition" would probably just be
> 		current->cap_effective =
> 			cap_raise_nfsd_set(current->cap_effective,
> 					   current->cap_permitted);
> (from nfsd_setuser).  This should reclaim the RACOVERRIDE permission
> which should be enough.
> 
> The one problem that I see is that it would invalidate the
> 		err = permission(parent->d_inode, MAY_EXEC, NULL);
> check in nfsd_acceptable.
> 
> Currently if we have "subtree_check" set, not only must the file be in
> the right subtree of the filesystem, but the user accessing the file
> must have 'x' permission on every parent directory.  For that test to
> work we must have already set the effective uid correctly.
> 
> Now it could be argued that this permission test is really a dumb idea
> that buys nothing and costs much.  And if you were to queue a patch to
> get rid of it, I doubt you would get any objections .... certainly not
> from me :-)

Dumb idea or not, it looks like it's explicitly documented in
exports(5):

	" subtree  checking  is  also  used to make sure that files
	inside directories to which only root has access can only be
	accessed if  the  filesystem is exported with no_root_squash
	(see below), even if the file itself allows more general
	access."

So as much as I'd like to I'm not comfortable silently turning off that
check.

I suppose we could choose to acquire those capabilities only in the
no_subtree_check case.

--b.
