Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48468 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754365Ab2IQTxD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 15:53:03 -0400
Date: Mon, 17 Sep 2012 15:53:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: readdir cookies
Message-ID: <20120917195300.GB9672@fieldses.org>
References: <20120917155426.GK30673@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FC8D4C@SACEXCMBX04-PRD.hq.netapp.com>
 <20120917165126.GL30673@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FC9F10@SACEXCMBX04-PRD.hq.netapp.com>
 <20120917175004.GA9672@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FCA350@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FCA350@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 17, 2012 at 06:03:26PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > Sent: Monday, September 17, 2012 1:50 PM
> > To: Myklebust, Trond
> > Cc: Schumaker, Bryan; linux-nfs@vger.kernel.org
> > Subject: Re: readdir cookies
> > 
> > On Mon, Sep 17, 2012 at 04:56:10PM +0000, Myklebust, Trond wrote:
> > > > -----Original Message-----
> > > > From: J. Bruce Fields [mailto:bfields@fieldses.org]
> > > > Sent: Monday, September 17, 2012 12:51 PM
> > > > To: Myklebust, Trond
> > > > Cc: Schumaker, Bryan; linux-nfs@vger.kernel.org
> > > > Subject: Re: readdir cookies
> > > >
> > > > On Mon, Sep 17, 2012 at 04:05:10PM +0000, Myklebust, Trond wrote:
> > > > > > -----Original Message-----
> > > > > > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > > > > > owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> > > > > > Sent: Monday, September 17, 2012 11:54 AM
> > > > > > To: Myklebust, Trond; Schumaker, Bryan
> > > > > > Cc: linux-nfs@vger.kernel.org
> > > > > > Subject: readdir cookies
> > > > > >
> > > > > > How does the nfs client decide what directory cookies to return?
> > > > > > (As the d_off field to readdir, for example).
> > > > > >
> > > > > > I'd assumed it would return the server's cookie, but testing
> > > > > > shows it returns a simple integer sequence.
> > > > >
> > > > > We cache the cookies and use them to figure out where the readdir
> > > > > cursor
> > > > is after a directory update, but we use positive integers for
> > telldir()/seekdir().
> > > > The reason is that too many servers return cookies that use > 32
> > > > bits (NFSv2-
> > > > incompatible) or are unsigned.
> > > >
> > > > Ok--so the tradeoff is that telldir/seekdir cookies may not be good
> > > > indefinitely?
> > >
> > > Yes. Most apps don't care about telldir()/seekdir(), so it isn't really much of
> > an issue. However, glibc has a bunch of assumptions about the 'd_offs'
> > entries returned by getdents()/getdents64() and will do "sanity checks" on
> > them that often end up failing when we just shove in the raw NFS cookies.
> > 
> > OK, thanks.  When did the client start doing that?
> 
> Years ago. You want to look at commit 00a2642 (NFS: Hide NFS server-generated readdir cookies from userland) which dates back to Linux-2.6.13.
>  
> > (And do you remember any details about the libc problems?  ext4 is
> > returning 64-bit cookies now in some cases, and we've seen a few problems
> > elsewhere, but none with glibc.)
> 
> IIRC: At one point, in glibc-2(.1?), they started using getdents64() instead of getdents() in order to avoid the problem of mismatched 'struct dirent' sizes on 32-bit ix86 platforms. Whenever the getdents64() interface returned a 64-bit cookie (or a 32-bit negative cookie), glibc would generate an EOVERFLOW error.

Got it, thanks.

--b.
