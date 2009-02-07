From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Sat, 07 Feb 2009 12:22:01 -0500
Message-ID: <1234027321.17241.25.camel@heimdal.trondhjem.org>
References: <20090206.140714.201930500.davem@davemloft.net>
	 <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com>
	 <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi>
	 <20090206.192243.47948705.davem@davemloft.net>
	 <1234023804.17241.14.camel@heimdal.trondhjem.org>
	 <Pine.LNX.4.64.0902071831210.2805@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	chuck.lever@oracle.com, bfields@fieldses.org, trond@netapp.com,
	linux-nfs@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0902071831210.2805@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2009-02-07 at 18:56 +0200, Ilpo J=C3=A4rvinen wrote:
> Can you please tell if you're still under impression that there wasn'=
t
> any changelog? What about those other guys who raised their concerns?
> (I can certainly understand why this impression might develop but it'=
s a=20
> problem in the canonial patch format, not in my actual changelog, I e=
ven=20
> need to circumvent ^--- by adding a space the to prevent tools for ma=
king=20
> a mistake). It will make a lot more sense after getting applied.
> ...Because there certainly was a changelog, and I didn't have any=20
> diffstat output there in the changelog?!? The output that *is* in the=
=20
> changelog is supposed to *help* the reviewer to see what will be stil=
l=20
> necessary to keep in the separate functions, but I guess people misse=
d=20
> that because the changelog looks too similar to what you will categor=
ize=20
> as patch (diff-funcs uses output which is familiar to all who who dea=
l=20
> with patches, and that's for purpose!).

If Chuck and Bruce are happy with it, then there is no problem, however
I have yet to see an acked-by from either one of them. My point is that
the process for accepting patches into the kernel involves ensuring tha=
t
there is consensus. It does not allow for one group to ride roughshod
over the objections of another.

   Trond
--=20
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
