From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 12:48:36 -0400
Message-ID: <20110729164836.GL23194@fieldses.org>
References: <20110729153207.17af3085@notabene.brown>
 <4E324DB4.7060600@fastmail.fm>
 <1311921035.7845.10.camel@edumazet-laptop>
 <4E3258E1.6020000@fastmail.fm>
 <20110729103634.GA12050@infradead.org>
 <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
 <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Hellwig <hch@infradead.org>,
	NeilBrown <neilb@suse.de>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Greg Banks <gnb@fastmail.fm>
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 29, 2011 at 11:30:05PM +1000, Greg Banks wrote:
>=20
>=20
> Sent from my iPhone
>=20
> On 29/07/2011, at 22:11, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le vendredi 29 juillet 2011 =C3=A0 21:58 +1000, Greg Banks a =C3=A9=
crit :
> >
> >>
> >> Sure, and a whole lot of the callsites are ("..._%d", cpu), hence =
the
> >> unfortune :(
> >
> > BTW, we could name nfsd threads differently :
> >
> > Currently, they all are named : "nfsd"
> >
> > If SVC_POOL_PERCPU is selected, we could name them :
> > nfsd_c0 -> nfsd_cN
> >
> > If SVC_POOL_PERNODE is selected, we could name them :
> > nfsd_n0  -> nfsd_nN
> >
> > That would help to check with "ps aux" which cpu/nodes are under =20
> > stress.
> >
> >
>=20
> I like it!

Yup, patch welcomed.--b.
