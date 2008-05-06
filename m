From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] exportfs: fix incorrect EACCES in reconnect_path()
Date: Tue, 6 May 2008 15:50:41 -0400
Message-ID: <20080506195041.GD13484@fieldses.org>
References: <20080429174004.GA28719@janus> <20080430174736.GB20377@fieldses.org> <20080502151646.GA5515@janus> <20080502153439.GC7376@infradead.org> <20080502155617.GD18401@fieldses.org> <1209744293.8294.19.camel@heimdal.trondhjem.org> <20080502221216.GP21918@fieldses.org> <18462.17737.353976.999538@notabene.brown> <20080505174716.GA12814@fieldses.org> <18463.42978.531115.344884@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Christoph Hellwig <hch@infradead.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Christoph Hellwig <hch@lst.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43717 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932879AbYEFTvB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 15:51:01 -0400
In-Reply-To: <18463.42978.531115.344884-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 06, 2008 at 10:35:46AM +1000, Neil Brown wrote:
> On Monday May 5, bfields@fieldses.org wrote:
> > On Mon, May 05, 2008 at 09:22:49AM +1000, Neil Brown wrote:
> > > 
> > > Now it could be argued that this permission test is really a dumb idea
> > > that buys nothing and costs much.  And if you were to queue a patch to
> > > get rid of it, I doubt you would get any objections .... certainly not
> > > from me :-)
> > 
> > Dumb idea or not, it looks like it's explicitly documented in
> > exports(5):
> > 
> > 	" subtree  checking  is  also  used to make sure that files
> > 	inside directories to which only root has access can only be
> > 	accessed if  the  filesystem is exported with no_root_squash
> > 	(see below), even if the file itself allows more general
> > 	access."
> > 
> > So as much as I'd like to I'm not comfortable silently turning off that
> > check.
> 
> Ack.
> 
> > 
> > I suppose we could choose to acquire those capabilities only in the
> > no_subtree_check case.
> 
> If only it were that easy ;-)
> 
> reconnect_path potentially requires both 'r' and 'x' permission on
> parent directories.  'r' to be able to read the directory to find the
> name of the object being reconnected, and 'x' to do the lookup which
> effects the reconnect.
> 
> To fix the current bug properly, reconnect_path still needs to bypass
> normal permission checks even when subtree_check is in effect, so it
> can be sure of getting read permission on the parent directory.

OK, but why not just forget the subtree_check case?  It would be just
another item on the "reasons not to use subtree_check" list.

If a fix for the subtree checking case were easy (or if someone else had
the time to do a very careful job of it), then fine, but maybe we should
just fix the easy case and leave the subtree checking as is for now.

--b.

> 
> There is another way .... but it would need careful consideration.
> 
> While the dentry returned by exportfs_decode_fh (for a directory) must
> be connected in the dcache tree, it does *not* need to have a correct
> name.  All that is needed is that d_parent is correct  (this is used,
> as mentioned before, to correctly lock directory renames).
> 
> We can leave the dentry unhashed but with a correct d_parent pointer.
> If the directory is ever access by name, d_slice_alias will be called
> and this will update the name in the dentry to be correct.
> 
> We could then get rid of exportfs_get_name and the call to
> lookup_one_len, and add some dcache magic after the ->get_parent call
> to make 'pd' an anonymous child of 'ppd'.
> 
> Some matching changes to d_splice_alias should finish the task.
> 
> Does this seem sane to anyone else?  Is it worth a try?
> 
> 
> NeilBrown
