From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: Problems with POSIX ACL <=> NFSv4 ACL mapping in mainline
Date: Mon, 26 Jun 2006 20:07:55 +0200
Message-ID: <200606262007.56097.agruen@suse.de>
References: <200606231745.23344.agruen@suse.de> <200606261730.09827.agruen@suse.de> <20060626175213.GU5817@schatzie.adilger.int>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Andreas Dilger <adilger@clusterfs.com>
In-Reply-To: <20060626175213.GU5817@schatzie.adilger.int>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Monday, 26 June 2006 19:52, Andreas Dilger wrote:
> On Jun 26, 2006  17:30 +0200, Andreas Gruenbacher wrote:
> > The result were errors when copying files with cp -p (which preserves
> > xattrs).
>
> Is that true of "cp" in general, or only SuSE "cp"?

It's our cp only right now.

> We get problems with 
> Lustre when root is copying files, because SuSE cp is incorrectly trying to
> copy all of the EAs by default.  If I have an EA that is specific to a
> file I don't necessarily want it to be copied.

There's a blacklist in libattr which we could add Lustre attributes to. A 
blacklist somewhere in /etc would be even better though I guess.

> It would probably be preferrable that cp only copy EAs that it understands.

What to do with unknown attributes? Warn? Err out?

Andreas
