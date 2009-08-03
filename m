From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs: __setup_str_nfs_root_setup causes a section type conflict
Date: Mon, 03 Aug 2009 18:11:33 -0400
Message-ID: <1249337493.18161.52.camel@heimdal.trondhjem.org>
References: <200907311446.33486.elendil@planet.nl>
	 <200908032121.10635.elendil@planet.nl>
	 <1249328851.18161.32.camel@heimdal.trondhjem.org>
	 <200908032257.51739.elendil@planet.nl>
	 <1249333643.18161.36.camel@heimdal.trondhjem.org>
	 <20090803215237.GA956@merkur.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org, parisc-linux-T/XaZq8tFt7U4lJK3ijXoz+iFHGzDt/a@public.gmane.org,
	Helge Deller <deller@gmx.de>
To: Sam Ravnborg <sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:47305 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752628AbZHCWLh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Aug 2009 18:11:37 -0400
In-Reply-To: <20090803215237.GA956-OoSGOWW0KRunlFQ6Q1D1Y0B+6BGkLq7r@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-08-03 at 23:52 +0200, Sam Ravnborg wrote:
> On Mon, Aug 03, 2009 at 05:07:23PM -0400, Trond Myklebust wrote:
> > On Mon, 2009-08-03 at 22:57 +0200, Frans Pop wrote:
> > > $ make init/do_mounts.o
> > >   CHK     include/linux/version.h
> > >   CHK     include/linux/utsrelease.h
> > >   SYMLINK include/asm -> include/asm-parisc
> > >   CALL    scripts/checksyscalls.sh
> > >   CC      init/do_mounts.o
> > > 
> > > while:
> > > 
> > > $ make fs/nfs/nfsroot.o
> > >   CHK     include/linux/version.h
> > >   CHK     include/linux/utsrelease.h
> > >   SYMLINK include/asm -> include/asm-parisc
> > >   CALL    scripts/checksyscalls.sh
> > >   CC      fs/nfs/nfsroot.o
> > > fs/nfs/nfsroot.c:403: error: __setup_str_nfs_root_setup causes a section type 
> > > conflict
> > 
> > To me that looks like some kind of compiler bug.
> 
> unspecified behaviour is a better name for it.
> 
> We have two variables we have forced a section on.
> One variable is marked RO by the compiler while the other is not.
> This results in a section type conflict because all
> symbols needs to have the same falgs.
> 
> We usually triggers this with powerpc builds (64 bit IIRC),
> and now with parisc too.
> 
> The only way to fix it is to move one of the offending
> variables to __initdata.
> There is two variales to consider - the compiler only
> mention one of them.
> 
> Trying to declare the variables const etc usually has
> no good effect.

So why would it be happening in the NFSroot case, but not in
do_mounts.c? They're both using the standard __setup() macro with a
constant string, and an __init function argument.

Futhermore, when grepping for '__initconst', it seems that the
combination with 'static const' is the norm rather than the exception.

Trond

