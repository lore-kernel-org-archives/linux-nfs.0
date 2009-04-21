From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [BUILD FAILURE 03/04] Next April 21 : x86_64 randconfig
 [fs/nfs/nfs.ko]
Date: Tue, 21 Apr 2009 13:49:32 -0400
Message-ID: <1240336172.20441.0.camel@heimdal.trondhjem.org>
References: <1240332715.9110.39.camel@subratamodak.linux.ibm.com>
	 <49EE056C.1060605@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: subrata@linux.vnet.ibm.com, NFS list <linux-nfs@vger.kernel.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	sachinp <sachinp@linux.vnet.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Alexander Beregalov <a.beregalov@gmail.com>,
	Ingo Molnar <mingo@elte.hu>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753344AbZDURuD@vger.kernel.org>
In-Reply-To: <49EE056C.1060605@panasas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-04-21 at 20:42 +0300, Benny Halevy wrote:
> On Apr. 21, 2009, 19:51 +0300, Subrata Modak <subrata@linux.vnet.ibm.com> wrote:
> > I think i am observing this for the first time in any randconfig builds:
> > 
> > BUILD   arch/x86/boot/bzImage
> > Root device is (8, 3)
> > Setup is 13020 bytes (padded to 13312 bytes).
> > System is 5625 kB
> > CRC a80d60ee
> > Kernel: arch/x86/boot/bzImage is ready  (#1)
> >   Building modules, stage 2.
> >   MODPOST 514 modules
> > ERROR: "find_last_bit" [fs/nfs/nfs.ko] undefined!
> > make[1]: *** [__modpost] Error 1
> > make: *** [modules] Error 2
> > ---
> > 
> > Regards--
> > Subrata
> > 
> 
> Trond, can you please merge
> http://git.linux-nfs.org/?p=bhalevy/linux-pnfs.git;a=commitdiff;h=9f32944d1bca79038ef3e9c9a27f11803d093d8e
> into your nfsv41 and linux-next branches?
> 
> I've placed it right before "nfs41: free slot"
> in git://git.linux-nfs.org/projects/bhalevy/linux-pnfs.git nfs41-for-2.6.31
> 
> (see also this thread:
> http://article.gmane.org/gmane.linux.kernel.next/6951)

Could we just push that straight into the kernel? It seems like a
no-brainer...

Cheers
  Trond
