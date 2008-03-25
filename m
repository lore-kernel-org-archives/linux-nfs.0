From: "Josef 'Jeff' Sipek" <jeffpc-PM1Ls4bqFqUFEYicpp4bmg@public.gmane.org>
Subject: Re: [opensuse] nfs_update_inode: inode X mode changed, Y to Z
Date: Tue, 25 Mar 2008 17:24:25 -0400
Message-ID: <20080325212425.GA20257@josefsipek.net>
References: <47CF62C5.7000908@m2000.com> <18384.50909.866848.966192@notabene.brown> <9a8748490803121513w285cd45rb6b26a3d842cac1b@mail.gmail.com> <20080312221511.GC31632@fieldses.org> <9a8748490803121516u36395872i70cc88b0439adc74@mail.gmail.com> <18394.1501.991087.80264@notabene.brown> <47DAEFD0.9020407@m2000.com> <47E92F8E.7030504@m2000.com> <20080325190943.GF2237@fieldses.org> <32953.192.168.1.70.1206477121.squirrel@neil.brown.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>, xfs@oss.sgi.com,
	Adam Schrotenboer <adam-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	Jesper Juhl <jesper.juhl@gmail.com>,
	Trond Myklebust <trond.myklebust@netapp.com>,
	lkml@vger.kernel.org, linux-nfs@vger.kernel.org,
	Thomas Daniel <tdaniel-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	Frederic Revenu <frevenu-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>,
	Jeff Doan <jdoan-PMR2DCmmWYEAvxtiuMwx3w@public.gmane.org>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from filer.fsl.cs.sunysb.edu ([130.245.126.2]:56838 "EHLO
	filer.fsl.cs.sunysb.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbYCYVYr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Mar 2008 17:24:47 -0400
In-Reply-To: <32953.192.168.1.70.1206477121.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 26, 2008 at 07:32:01AM +1100, NeilBrown wrote:
> I suggest taking it up with the XFS developers...
> 
> Dear XFS developers.
>  Adam (and Jesper, though that was some time ago) was having problems
> with an XFS filesystem that was exported via NFS.  The client would
> occasionally report the message given in the subject line.
> Examining the NFS code suggested that the most likely explanation
> was that the generation number used in the file handle was the same
> every time that the inode number was re-used.
> 
> Examining the XFS code suggested that when the 'ikeep' mount option was
> used, the generation number be explicitly incremented for each
> re-use, while without 'ikeep', no evidence of setting the generation
> number could be found.  Maybe it defaults to zero.
> 
> Experimental evidence suggests that setting 'ikeep' removes the symptom.
> 
> Question:  Is is possible that without 'ikeep', XFS does not even try
> to provide unique generation numbers?  If this is the case, could it
> please be fixed.  If it is not the case, please help me find the code
> responsible.

Unless you specify the "ikeep" mount option, XFS will remove unused inode
clusters.  The newly freed blocks can be then used to store data or possibly
a new inode cluster.  If the blocks get reused for inodes, you'll end up
with inodes whose generation numbers regressed. (inode number = f(block
number))

Using the "ikeep" mount option causes to _never_ free empty inode clusters.
This means that if you create many files and then unlink them, you'll end up
with many unused inodes that are still allocated (and taking up disk space)
but free to be used by the next creat(2)/mkdir(2)/etc..

This "problem" is inherent to any file system which dynamically allocates
inodes.

Josef 'Jeff' Sipek.

-- 
Linux, n.:
  Generous programmers from around the world all join forces to help
  you shoot yourself in the foot for free. 
