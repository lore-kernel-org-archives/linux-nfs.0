From: Andreas Dilger <adilger@clusterfs.com>
Subject: Re: Problems with POSIX ACL <=> NFSv4 ACL mapping in mainline
Date: Mon, 26 Jun 2006 12:57:41 -0600
Message-ID: <20060626185741.GV5817@schatzie.adilger.int>
References: <200606231745.23344.agruen@suse.de> <200606261730.09827.agruen@suse.de> <20060626175213.GU5817@schatzie.adilger.int> <200606262007.56097.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200606262007.56097.agruen@suse.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Jun 26, 2006  20:07 +0200, Andreas Gruenbacher wrote:
> On Monday, 26 June 2006 19:52, Andreas Dilger wrote:
> > On Jun 26, 2006  17:30 +0200, Andreas Gruenbacher wrote:
> > > The result were errors when copying files with cp -p (which preserves
> > > xattrs).
> >
> > Is that true of "cp" in general, or only SuSE "cp"?
> 
> It's our cp only right now.
> 
> > We get problems with 
> > Lustre when root is copying files, because SuSE cp is incorrectly trying to
> > copy all of the EAs by default.  If I have an EA that is specific to a
> > file I don't necessarily want it to be copied.
> 
> There's a blacklist in libattr which we could add Lustre attributes to.

I figured as much after digging through the SLES-patched cp, I just hadn't
gotten as far as grabbing the libattr source and seeing what that was.  Is
this blacklist specific to the SLES libattr, or is this in the released
version?

> A blacklist somewhere in /etc would be even better though I guess.

Definitely, yes.  Given that libselinx gropes around in a several files
already, adding one more won't hurt.  Something like /etc/libattr.conf?

> > It would probably be preferrable that cp only copy EAs that it understands.
> 
> What to do with unknown attributes? Warn? Err out?

Warn once, maybe with pointer to /etc/libattr.conf for adding to include or
exclude list.  Given that copying file attributes isn't guaranteed in any
case, we can probably safely live without copying everything.

Cheers, Andreas
--
Andreas Dilger
Principal Software Engineer
Cluster File Systems, Inc.

