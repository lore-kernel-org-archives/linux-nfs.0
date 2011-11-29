Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:57998 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752377Ab1K2Rdp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 12:33:45 -0500
Message-ID: <1322588023.4174.28.camel@lade.trondhjem.org>
Subject: Re: ore: FIX breakage when MISC_FILESYSTEMS is not set
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@tonian.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, Randy Dunlap <rdunlap@xenotime.net>,
        Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, Michal Marek <mmarek@suse.cz>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Date: Tue, 29 Nov 2011 12:33:43 -0500
In-Reply-To: <4ED4CE58.8090107@tonian.com>
References: <20111124174358.d88f11c0ff700e5e6b3bf73b@canb.auug.org.au>
	 <4ECE91F3.9010007@xenotime.net> <4ED422CC.60706@panasas.com>
	 <4ED4238F.4090407@panasas.com> <4ED4CE58.8090107@tonian.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-11-29 at 14:21 +0200, Benny Halevy wrote: 
> On 2011-11-29 02:13, Boaz Harrosh wrote:
> > 
> > As Reported by Randy Dunlap
> > 
> > When MISC_FILESYSTEMS is not enabled:
> > 
> > fs/built-in.o: In function `objio_alloc_io_state':
> > objio_osd.c:(.text+0xcb525): undefined reference to `ore_get_rw_state'
> > fs/built-in.o: In function `_write_done':
> > objio_osd.c:(.text+0xcb58d): undefined reference to `ore_check_io'
> > fs/built-in.o: In function `_read_done':
> > ...
> > 
> > When MISC_FILESYSTEMS, which is more of a GUI thing then anything else,
> > is not selected. exofs/Kconfig is never examined during Kconfig,
> > and it can not do it's magic stuff to automatically select everything
> 
> nit: s/it's/its/
> 
> > needed.
> > 
> > The solution is to force all users of ORE (exofs, nfs) to manually
> > select everything auto-magically selected before.
> 
> How about using "depend ORE" rather than "select ORE"?

Right. Make PNFS_OBJLAYOUT and EXOFS_FS depend on ASYNC_XOR (or select
it) and then make ORE depend on EXOFS_FS || PNFS_OBJLAYOUT.

There should be no need to add the 'select ORE'...

> > (This is  why it is a bad idea to put libraries in random parts of
> >  the tree)
> > 
> > Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> > Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> > ---
> >  fs/exofs/Kconfig |   17 +++++++++--------
> >  fs/nfs/Kconfig   |    2 ++
> >  2 files changed, 11 insertions(+), 8 deletions(-)
> > 
> > diff --git a/fs/exofs/Kconfig b/fs/exofs/Kconfig
> > index da42f32..6b05d99 100644
> > --- a/fs/exofs/Kconfig
> > +++ b/fs/exofs/Kconfig
> > @@ -1,17 +1,18 @@
> > -# Note ORE needs to "select ASYNC_XOR". So Not to force multiple selects
> > -# for every ORE user we do it like this. Any user should add itself here
> > -# at the "depends on EXOFS_FS || ..." with an ||. The dependencies are
> > -# selected here, and we default to "ON". So in effect it is like been
> > -# selected by any of the users.
> > +# ORE - Objects Raid Engine (libore.ko)
> > +# This library needs to be selected by it's users for example the below EXOFS
> > +# filesystem.
> 
> nit:
> This library needs to be selected by its users. For example, see
> EXOFS_FS below.
> 
> Benny
> 
> > +# All users must do:
> > +#	depends on SCSI_OSD_ULD
> > +#	select ASYNC_XOR
> > +#	select ORE
> >  config ORE
> >  	tristate

	depends on EXOFS_FS || PNFS_OBJLAYOUT
	default y


> >  
> >  config EXOFS_FS
> >  	tristate "exofs: OSD based file system support"

	depends on SCSI_OSD_ULD && ASYNC_XOR

> >  	help
> >  	  EXOFS is a file system that uses an OSD storage device,
> >  	  as its backing storage.
> > diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> > index dbcd821..3708d76 100644
> > --- a/fs/nfs/Kconfig
> > +++ b/fs/nfs/Kconfig
> > @@ -96,6 +96,8 @@ config PNFS_BLOCK
> >  config PNFS_OBJLAYOUT
> >  	tristate
> >  	depends on NFS_FS && NFS_V4_1 && SCSI_OSD_ULD

	depends on NFS_V4_1 && ASYNC_XOR && SCSI_OSD_ULD

> >  	default m
> >  
> >  config ROOT_NFS

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

