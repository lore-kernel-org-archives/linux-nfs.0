Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:46458
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751390Ab3JASVK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Oct 2013 14:21:10 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Bruce Fields'" <bfields@fieldses.org>
Cc: "'Kernel NFS List'" <linux-nfs@vger.kernel.org>,
        "'Ganesha NFS List'" <nfs-ganesha-devel@lists.sourceforge.net>
References: <003301cebe09$5bf81090$13e831b0$@mindspring.com> <20130930221126.GD26382@fieldses.org> <003f01cebe38$75436480$5fca2d80$@mindspring.com> <20131001142601.GG26382@fieldses.org>
In-Reply-To: <20131001142601.GG26382@fieldses.org>
Subject: RE: pynfs updates
Date: Tue, 1 Oct 2013 14:21:01 -0400
Message-ID: <009a01cebed2$fcdacb50$f69061f0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> > > 		- SECNN4: is env.home necessarily unequal to "/"?  Would
> > > 		  seem better to do the lookup in a subdirectory just to
> > > 		  be certain.
> >
> > Env.home is the directory you specify on the command line, I think the
> > presumption is that it is a writeable file system. Pynfs creates tmp
> > and tree directories in home (and maybe some files also?). Guess if /
> > was writeable, you could specify /, so yea, maybe it should go into tmp.
> 
> Sounds good.

env.home does actually include traversing into tmp, so I will leave this
test alone.

> > A better test might actually be to do LOOKUP down to home and even
> > into tmp, looking for a junction, and then do the
> > SECINFO_NO_NAME(parent) on the directory handle just across the
> junction if one was found.
> 
> Yeah it'd be nice to check that cross-filesystem case but I don't think
it's
> necessary (and you still have to deal with the case where a mountpoint's
not
> found).
> 
> If tests at mountpoints were useful perhaps we could pass in a mountpoint
> on the commandline.  Or add some sort of export-configuration interface to
> the serverhelper script and let pynfs setup exports itself.

Yea, that might be something interesting to explore at some point.

Frank

