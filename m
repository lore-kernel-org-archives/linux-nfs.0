From: Tim Connors <tconnors+linuxkernel1094371411@astro.swin.edu.au>
Subject: Re: why do i get "Stale NFS file handle" for hours?
Date: Sun, 5 Sep 2004 19:02:31 +1000 (EST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.53.0409051901460.24133@radium.ssi.swin.edu.au>
References: <chdp06$e56$1@sea.gmane.org> <1094348385.13791.119.camel@lade.trondhjem.org>
 <413A7119.2090709@upb.de> <1094349744.13791.128.camel@lade.trondhjem.org>
 <413A789C.9000501@upb.de> <1094353267.13791.156.camel@lade.trondhjem.org>
 <slrn-0.9.7.4-19971-22570-200409051803-tc@hexane.ssi.swin.edu.au>
 <87y8jphz17.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S266449AbUIEJCy@vger.kernel.org>
To: Florian Weimer <fw@deneb.enyo.de>
In-Reply-To: <87y8jphz17.fsf@deneb.enyo.de>
List-ID: <nfs.lists.sourceforge.net>

On Sun, 5 Sep 2004, Florian Weimer wrote:

> * Tim Connors:
>
> > Background:
> >
> > We have a compute cluster of machines all running SuSE's 2.4.20, or
> > thereabouts. The nfs servers run Linus's 2.4.26, talking to ext3, on
> > bigass apple Xserves.
>
> Which NFS server software are you using?

kernel nfsd
Source RPM: nfs-utils-1.0.1-109.src.rpm


-- 
TimC -- http://astronomy.swin.edu.au/staff/tconnors/
Save the whales. Feed the hungry. Free the mallocs. --unk
