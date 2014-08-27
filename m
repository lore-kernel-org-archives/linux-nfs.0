Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47885 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933592AbaH0N0O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2014 09:26:14 -0400
Date: Wed, 27 Aug 2014 09:26:07 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andreas Fenkart <afenkart@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Daniel Mack <zonque@gmail.com>
Subject: Re: `ls` shows no files in mounted nfs folder, but ls 'file' works
Message-ID: <20140827132607.GA12766@fieldses.org>
References: <CALtMJECmW-yYgD3W5FUxQZJVZkb5NSJpQ5V9Q3ZE=1NKeCDtOA@mail.gmail.com>
 <20140710175136.GA26561@fieldses.org>
 <CALtMJECLdEOsmuW4AOnNsAyY+OMr3MtFN9W71DRw3tpidKrU8A@mail.gmail.com>
 <CAHQdGtQAgKyFgwp+6w64vXkcKkBQ=YVfiH0jgaonAMumHoTutg@mail.gmail.com>
 <CALtMJEDT=jCWMR0Akjo72fL3SW63dEmDTQbdg5Pv_DV5Oggz_g@mail.gmail.com>
 <CAHQdGtS_O3i6fBhW7vTurL=Y7cKmoeGjTXiEMU5mbb3tR3-LjA@mail.gmail.com>
 <CALtMJEALbP3DKpaL9Bz6tNjj3GHYUo7wb=VRbOcjB1+hOr6GCg@mail.gmail.com>
 <CAHQdGtS34K6S_59Huvx8EK+mh1QwSrjtUXaNogGYSm5aQZCA=w@mail.gmail.com>
 <20140826195033.GB25117@fieldses.org>
 <CALtMJECxo57CXw1=yKDGLm0o+jPLLpj+7rDMAMMJ95uYEC15Xw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALtMJECxo57CXw1=yKDGLm0o+jPLLpj+7rDMAMMJ95uYEC15Xw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 27, 2014 at 10:30:34AM +0200, Andreas Fenkart wrote:
> Hi
> 
> 2014-08-26 21:50 GMT+02:00 J. Bruce Fields <bfields@fieldses.org>:
> >>
> >> Still not seeing the readdir, but the getattrs are there and all looks OK.
> >> Question: the server is knfsd from a Linux 3.14.4 kernel, is that
> >> correct? So it does have commit 83b19121522 (nfsd: revert v2 half of
> >> "nfsd: don't return high mode bits")?
> >
> > Yeah, you can even see the high bits set (correctly) in the stat
> > returns, so he has that patch.
> >
> > Andreas, are you still seeing this problem?
> 
> No it's gone, but I upgraded my (server-)system meanwhile (debian unstable)
> I also tried downgrading my kernel to the version I had back then, but
> the problem doesn't show up anymore.

Well, maybe there was a server bug in the old server that this change
just happened to expose.

What was the server upgrade, out of curiosity?  (From what kernel
version, to what kernel version?)

--b.
