From: Frans Pop <elendil@planet.nl>
Subject: Re: nfs: __setup_str_nfs_root_setup causes a section type conflict
Date: Mon, 3 Aug 2009 22:57:49 +0200
Message-ID: <200908032257.51739.elendil@planet.nl>
References: <200907311446.33486.elendil@planet.nl> <200908032121.10635.elendil@planet.nl> <1249328851.18161.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	parisc-linux@lists.parisc-linux.org, Helge Deller <deller@gmx.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753255AbZHCU5z@vger.kernel.org>
In-Reply-To: <1249328851.18161.32.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 03 August 2009, Trond Myklebust wrote:
> On Mon, 2009-08-03 at 21:21 +0200, Frans Pop wrote:
> > On Monday 03 August 2009, Trond Myklebust wrote:
> > > > > /home/fjp/projects/kernel/linux-2.6/fs/nfs/nfsroot.c:403:
> > > > >     error: __setup_str_nfs_root_setup causes a section type
> > > > > conflict
> > >
> > > If you do a 'make fs/nfs/nfsroot.i', and then look at the resulting
> > > file fs/nfs/nfsroot.i, what does the line that defines
> > > '__setup_str_nfs_root_setup' look like?
> >
> > $ grep __setup_str_nfs_root_setup fs/nfs/nfsroot.i
> >
> > static const char __setup_str_nfs_root_setup[] __attribute__
> > ((__section__(".init.rodata"))) __attribute__((aligned(1))) = "nfsroot=";
> > static struct obs_kernel_param __setup_nfs_root_setup __attribute__((__used__))
> > __attribute__ ((__section__(".init.setup")))
> > __attribute__((aligned((sizeof(long))))) = { __setup_str_nfs_root_setup,
> > nfs_root_setup, 0 }; 
>
> Yup. That matches what I get on an x86_64 platform, where it appears to
> compile without any trouble. I can see no reason why it shouldn't
> compile on parisc too. In fact you should have tons of these in
> init/do_mounts.c: do they generate compile errors too?

Yes, that does have similar constructs, but that does compiles OK:

$ make init/do_mounts.o
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  SYMLINK include/asm -> include/asm-parisc
  CALL    scripts/checksyscalls.sh
  CC      init/do_mounts.o

while:

$ make fs/nfs/nfsroot.o
  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  SYMLINK include/asm -> include/asm-parisc
  CALL    scripts/checksyscalls.sh
  CC      fs/nfs/nfsroot.o
fs/nfs/nfsroot.c:403: error: __setup_str_nfs_root_setup causes a section type 
conflict
