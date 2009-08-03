From: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Subject: Re: nfs: __setup_str_nfs_root_setup causes a section type conflict
Date: Mon, 3 Aug 2009 23:52:37 +0200
Message-ID: <20090803215237.GA956@merkur.ravnborg.org>
References: <200907311446.33486.elendil@planet.nl> <200908032121.10635.elendil@planet.nl> <1249328851.18161.32.camel@heimdal.trondhjem.org> <200908032257.51739.elendil@planet.nl> <1249333643.18161.36.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, parisc-linux-T/XaZq8tFt7U4lJK3ijXoz+iFHGzDt/a@public.gmane.org,
	Helge Deller <deller@gmx.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pfepb.post.tele.dk ([195.41.46.236]:54392 "EHLO
	pfepb.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbZHCVwi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Aug 2009 17:52:38 -0400
In-Reply-To: <1249333643.18161.36.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 03, 2009 at 05:07:23PM -0400, Trond Myklebust wrote:
> On Mon, 2009-08-03 at 22:57 +0200, Frans Pop wrote:
> > $ make init/do_mounts.o
> >   CHK     include/linux/version.h
> >   CHK     include/linux/utsrelease.h
> >   SYMLINK include/asm -> include/asm-parisc
> >   CALL    scripts/checksyscalls.sh
> >   CC      init/do_mounts.o
> > 
> > while:
> > 
> > $ make fs/nfs/nfsroot.o
> >   CHK     include/linux/version.h
> >   CHK     include/linux/utsrelease.h
> >   SYMLINK include/asm -> include/asm-parisc
> >   CALL    scripts/checksyscalls.sh
> >   CC      fs/nfs/nfsroot.o
> > fs/nfs/nfsroot.c:403: error: __setup_str_nfs_root_setup causes a section type 
> > conflict
> 
> To me that looks like some kind of compiler bug.

unspecified behaviour is a better name for it.

We have two variables we have forced a section on.
One variable is marked RO by the compiler while the other is not.
This results in a section type conflict because all
symbols needs to have the same falgs.

We usually triggers this with powerpc builds (64 bit IIRC),
and now with parisc too.

The only way to fix it is to move one of the offending
variables to __initdata.
There is two variales to consider - the compiler only
mention one of them.

Trying to declare the variables const etc usually has
no good effect.

	Sam
