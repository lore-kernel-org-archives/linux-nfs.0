From: Jason.V.Mock@L-3Com.com
Subject: RE: [NFS] Kernel Oops in NFS
Date: Fri, 19 Oct 2007 13:30:57 -0500
Message-ID: <F31FEAB987B7C2469181758C14265CFA040BBB86@gvlexch03.is.l-3com.com>
References: <F31FEAB987B7C2469181758C14265CFA040BBB64@gvlexch03.is.l-3com.com> <F31FEAB987B7C2469181758C14265CFA040BBB7A@gvlexch03.is.l-3com.com> <1192749866.7437.57.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>,
	"Kile, SE Scott @ IS" <scott.kile@L-3com.com>,
	<nfs@lists.sourceforge.net>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934586AbXJSSbU@vger.kernel.org>
In-Reply-To: <1192749866.7437.57.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no] 
> Sent: Thursday, October 18, 2007 18:24
> To: Mock, JV Jason @ IS
> Cc: nfs@lists.sourceforge.net; linux-kernel@vger.kernel.org; 
> Kile, SE Scott @ IS
> Subject: Re: [NFS] Kernel Oops in NFS
> 
> 
> On Thu, 2007-10-18 at 16:01 -0500, Jason.V.Mock@L-3Com.com wrote:
> > > We've come across an Oops, in what appears to NFS.
> > > 
> > > 2.6.22.6 vanilla + realtime-lsm
> > > RHEL4 over PXE/NFS_ROOT
...
> > > [<c01a9fb8>] nfs_lookup+0x11b/0x26a SS:ESP 0068:f63b5d4
> > > 
> > > We haven't seen any negative side-effects other than users seeing 
> > > this in Kwrited quite often.  We've yet to update to 2.6.22.9, 
> > > however we've examined the change logs and patches 
> associated with 
> > > NFS between then and now, and don't see anything 
> appropriate for the 
> > > errors we're receiving.  Let me know if you need anything 
> else for 
> > > this...
> > 
> > I was just checking to see if there's anything that I'm 
> missing here, 
> > in regards to never hearing a single thing back about this.
> > 
> > - Jason Mock
> 
> Well... Your Oops did have the 'tainted' flag set, but in 
> this case I believe that the issue is already known. Please try
> 
>   
> http://client.linux-nfs.org/Linux-2.6.x/2.6.22/linux-2.6.22-01
> 0-fix_nfs_reval_fsid.dif
> 
> Trond
> 

Thanks Trond.  The Tainted flag is *probably* due to the NVIDIA driver,
but I'd also have to check the realtime-lsm.  Either way we'll get that
built up and see...

Thanks again!!

- Jason Mock
