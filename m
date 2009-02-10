From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] net/sunrpc/xprtsock.c: some common code found
Date: Tue, 10 Feb 2009 17:28:02 -0500
Message-ID: <20090210222802.GN32393@fieldses.org>
References: <20090206.140714.201930500.davem@davemloft.net> <CAF18546-B024-40C9-8276-8FCD89C98E72@oracle.com> <Pine.LNX.4.64.0902070040530.31875@wrl-59.cs.helsinki.fi> <20090206.192243.47948705.davem@davemloft.net> <1234023804.17241.14.camel@heimdal.trondhjem.org> <Pine.LNX.4.64.0902071831210.2805@wrl-59.cs.helsinki.fi> <20090208052543.GA20689@fieldses.org> <Pine.LNX.4.64.0902101514540.31742@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	chuck.lever@oracle.com, trond@netapp.com,
	linux-nfs@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Ilpo =?utf-8?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0902101514540.31742@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 10, 2009 at 03:20:36PM +0200, Ilpo J=C3=A4rvinen wrote:
> On Sun, 8 Feb 2009, J. Bruce Fields wrote:
>=20
> > (Where's diff-func from?)
>=20
> My own tool collection. I can make it available if you want to.

Sure, I'd be curious.

--b.

>=20
> > In similar cases in the future, if you want to cater to the more ti=
red
> > and/or mentally challenged among us (which may just be me), some cl=
ue
> > that visually distinguishes the quoted diff output in the comment m=
ight
> > help; e.g., maybe indent it like the below.
> >=20
> > (But that's intended as a suggestion, not a requirement.)
>=20
> Yeah, a good idea... I'll sed some spaces in front of them in the fut=
ure=20
> to make the difference more obvious. The expected outcome though is t=
hat=20
> somebody probably then hits reply button too soon claiming that the p=
atch=20
> is broken :-).
>=20
>=20
> --=20
>  i.
