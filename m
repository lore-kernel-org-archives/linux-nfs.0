Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11316 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754084Ab2IQQ4L convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Sep 2012 12:56:11 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: readdir cookies
Date: Mon, 17 Sep 2012 16:56:10 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA908FC9F10@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120917155426.GK30673@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FC8D4C@SACEXCMBX04-PRD.hq.netapp.com>
 <20120917165126.GL30673@fieldses.org>
In-Reply-To: <20120917165126.GL30673@fieldses.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Monday, September 17, 2012 12:51 PM
> To: Myklebust, Trond
> Cc: Schumaker, Bryan; linux-nfs@vger.kernel.org
> Subject: Re: readdir cookies
> 
> On Mon, Sep 17, 2012 at 04:05:10PM +0000, Myklebust, Trond wrote:
> > > -----Original Message-----
> > > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > > owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> > > Sent: Monday, September 17, 2012 11:54 AM
> > > To: Myklebust, Trond; Schumaker, Bryan
> > > Cc: linux-nfs@vger.kernel.org
> > > Subject: readdir cookies
> > >
> > > How does the nfs client decide what directory cookies to return?
> > > (As the d_off field to readdir, for example).
> > >
> > > I'd assumed it would return the server's cookie, but testing shows
> > > it returns a simple integer sequence.
> >
> > We cache the cookies and use them to figure out where the readdir cursor
> is after a directory update, but we use positive integers for telldir()/seekdir().
> The reason is that too many servers return cookies that use > 32 bits (NFSv2-
> incompatible) or are unsigned.
> 
> Ok--so the tradeoff is that telldir/seekdir cookies may not be good
> indefinitely?

Yes. Most apps don't care about telldir()/seekdir(), so it isn't really much of an issue. However, glibc has a bunch of assumptions about the 'd_offs' entries returned by getdents()/getdents64() and will do "sanity checks" on them that often end up failing when we just shove in the raw NFS cookies.

Cheers
  Trond
