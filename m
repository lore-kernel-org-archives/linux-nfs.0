Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53635 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751439Ab2JBOdf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Oct 2012 10:33:35 -0400
Date: Tue, 2 Oct 2012 10:33:34 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121002143334.GA1435@fieldses.org>
References: <20120918112329.7d88ed9e@notabene.brown>
 <20121001154309.GD18400@fieldses.org>
 <20121002123810.15bd1ee2@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121002123810.15bd1ee2@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 02, 2012 at 12:38:10PM +1000, NeilBrown wrote:
> On Mon, 1 Oct 2012 11:43:10 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Tue, Sep 18, 2012 at 11:23:29AM +1000, NeilBrown wrote:
> > > 
> > > Suppose that on an NFS server I have a directory
> > >    /foo/bar/baz
> > > 
> > > which I export, and that /foo/bar does not have world access.  e.g.
> > > permissions are '750' and everyone who owns files in there is a member of the
> > > group which owns /foo/bar.
> > > 
> > > Then with NFSv3 I can
> > >   mount server:/foo/bar/baz  /somewhere
> > > because the lookup of /foo/bar/baz happens as root on the server in mountd.
> > > 
> > > With NFSv4 using 'sec=sys' I can only do this if I export with
> > > "no_root_squash", as the lookup happens on the client as root, and if root
> > > were squashed, it wouldn't have access beyond /foo/bar.
> > > 
> > > But if I use NFSv4 using 'sec=krb5', the lookup happens on the client using a
> > > machine credential which gets mapped to 'nobody/nogroup' (or whatever anonuid
> > > and anongid are set to for the export).  So I cannot perform the mount at all.
> > > 
> > > This is - at best - inconsistent and can cause confusion (hey - I was
> > > confused for a while there).
> > > 
> > > Should something be done?  Can anything be done?
> > 
> > I think nfsd_lookup_dentry() would need a special exception for the
> > NFSEXP_V4ROOT case.
> 
> I don't think that would help in general.
> If I export /foo and want to mount /foo/bar/baz, then for the last lookup at
> least, NFSEXP_V4ROOT isn't set anywhere near.

I'm not entirely clear why mountd even allows that, but no point trying
to change it now anyway.

> An exception would need to be made for every 'nfs4_lookup_dentry', provided
> it found a directory, or nothing (or a symlink...).  Possibly this could only
> be done for anonymous credentials (as are used by the nfs4 mount operation).

Yuch.

> It would be nice if we could clearly differentiate a mount-time lookup from a
> regular lookup, but I don't think the protocol allows for that.

I guess you're right.  So it starts to sound more like: "you have a
confusing setup.  Your export configuration says one thing, and your
filesystem permissions say another.  Under NFSv3 the confusion didn't
matter, but now it does--time to fix it."

--b.
