From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: [NFS] Re: [PATCH] zerocopy NFS for 2.5.36
Date: Thu, 19 Sep 2002 22:15:13 +0900 (JST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20020919.221513.28808421.taka@valinux.co.jp>
References: <20020918.160057.17194839.davem@redhat.com>
	<1032393277.24895.8.camel@irongate.swansea.linux.org.uk>
	<3D89176B.40FFD09B@digeo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, davem@redhat.com, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: akpm@digeo.com
In-Reply-To: <3D89176B.40FFD09B@digeo.com>
List-ID: <nfs.lists.sourceforge.net>

Hello,

> > > details, but I do know that using copy_from_user() is not a real
> > > improvement at least on x86 architecture.
> > 
> > The same as bit is easy to explain. Its totally memory bandwidth limited
> > on current x86-32 processors. (Although I'd welcome demonstrations to
> > the contrary on newer toys)
> 
> Nope.  There are distinct alignment problems with movsl-based
> memcpy on PII and (at least) "Pentium III (Coppermine)", which is
> tested here:
...
> I have various scriptlets which generate the entire matrix.
> 
> I think I ended up deciding that we should use movsl _only_
> when both src and dsc are 8-byte-aligned.  And that when you
> multiply the gain from that by the frequency*size with which
> funny alignments are used by TCP the net gain was 2% or something.

Amazing! I beleived 4-byte-aligned was enough.
read/write systemcalls may also reduce their penalties.

> It needs redoing.  These differences are really big, and this
> is the kernel's most expensive function.
> 
> A little project for someone.

OK, if there is nobody who wants to do it I'll do it by myself.

> The tools are at http://www.zip.com.au/~/linux/cptimer.tar.gz
