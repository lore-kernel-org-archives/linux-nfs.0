Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60110 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754765AbaDXQeP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Apr 2014 12:34:15 -0400
Date: Thu, 24 Apr 2014 12:34:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Layton Jeff <jlayton@redhat.com>
Subject: Re: nfsd bug fixes for 3.15
Message-ID: <20140424163414.GA16429@fieldses.org>
References: <20140424062516.GA8891@fieldses.org>
 <CAHQdGtRfybuqsxiS=Hd4Stkm1ex13f6SeEk5XbQcy35UZStHRA@mail.gmail.com>
 <20140424153116.GA15459@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140424153116.GA15459@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 24, 2014 at 11:31:16AM -0400, J. Bruce Fields wrote:
> On Thu, Apr 24, 2014 at 06:51:03AM -0400, Trond Myklebust wrote:
> > Hi Bruce,
> > 
> > On Thu, Apr 24, 2014 at 2:25 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > Please pull the following bug fixes for 3.15 from:
> > >
> > >   git://linux-nfs.org/~bfields/linux.git for-3.15
> > >
> > > Three small nfsd bugfixes (including one locks.c fix for a bug triggered
> > > only from nfsd).
> > >
> > > Jeff's patches are for long-existing problems that became easier to
> > > trigger since the addition of vfs delegation support.
> > >
> > > --b.
> > >
> > > ----------------------------------------------------------------
> > > J. Bruce Fields (1):
> > >       Revert "nfsd4: fix nfs4err_resource in 4.1 case"
> > >
> > 
> > Wait. Why?
> 
> Have you changed your mind since our previous discussion, or just
> forgotten it?  (Or did I screw up and revert the wrong commit?)  See
> 
> 	http://mid.gmane.org/<BAD6904F-A82A-4FBC-807F-16560B2A23E0@primarydata.com>
> 
> > NFS4ERR_RESOURCE breaks the Linux client.
> 
> This returns us to pre-3.15 behavior so shouldn't introduce any new
> breakage.
> 
> Fundamentally the problem is that we're returning an error in cases that
> shouldn't succeed, and rather than replacing one incorrect error by

s/shouldn't/should/, apologies!--b.

> another it seemed better to wait for a proper fix.
> 
> --b.
