From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Fix compatibility issue with AIX client using
	READDIR when directory contains a sub-mounted filesystem
Date: Tue, 27 Nov 2007 16:09:10 -0500
Message-ID: <20071127210910.GF27242@fieldses.org>
References: <1196111951.3265.26.camel@dyn9047022153> <20071126222804.GW5960@fieldses.org> <1196192046.3265.30.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS V4 Mailing List <nfsv4@linux-nfs.org>,
	NFS List <linux-nfs@vger.kernel.org>,
	Neil Brown <neilb@suse.de>, ffilz@us.ibm.com
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38213 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754617AbXK0VJO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2007 16:09:14 -0500
In-Reply-To: <1196192046.3265.30.camel@dyn9047022153>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 27, 2007 at 11:34:05AM -0800, Frank Filz wrote:
> On Mon, 2007-11-26 at 22:28 +0000, J. Bruce Fields wrote:
> > On Mon, Nov 26, 2007 at 01:19:11PM -0800, Frank Filz wrote:
> > OK, thanks!  My only superficial complaint--I find the
> > OBEY_CROSSMNT/IGNORE_CROSSMNT defines to be minor overkill.
> > 
> > If you want to stick with them, then you should probably use a
> > comparison to IGNORE_CROSSMNT here instead of assuming which is zero:
> > 
> > > +                if (!ignore_crossmnt &&
> > > +		    exp->ex_mnt->mnt_root->d_inode == dentry->d_inode) {
> > >  			err = vfs_getattr(exp->ex_mnt->mnt_parent,
> > >  				exp->ex_mnt->mnt_mountpoint, &stat);
> > 
> > But I think it'd be simplest just to use 0 and 1 directly instead of the
> > defines.
> 
> Ok, here's an updated patch removing the #defines. I did also explicitly
> test ignore_crossmnt for 0 instead of implicitly testing.

OK, in all I think the new version's a little more straightforward.
Thanks!  Applied and pushed out to

	git://linux-nfs.org/~bfields nfs-server-stable

and should go in 2.6.25.

--b.
