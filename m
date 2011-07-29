From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] sunrpc: use better NUMA affinities
Date: Fri, 29 Jul 2011 19:48:57 -0400
Message-ID: <20110729234857.GA30941@fieldses.org>
References: <1311921035.7845.10.camel@edumazet-laptop>
 <4E3258E1.6020000@fastmail.fm>
 <20110729103634.GA12050@infradead.org>
 <5933F48C-49D6-492D-AB7B-B76A3ADDB6C6@fastmail.fm>
 <1311941491.2843.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <F67B6E82-9FA8-464E-B3FB-DC0D4EC18BB0@fastmail.fm>
 <20110729164836.GL23194@fieldses.org>
 <20110729165345.GM23194@fieldses.org>
 <F562C6F4-3FC2-4952-A903-8E87E9EF2D9D@fastmail.fm>
 <20110730093025.716f3f50@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Greg Banks <gnb@fastmail.fm>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Christoph Hellwig <hch@infradead.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34780 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753220Ab1G2XtG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2011 19:49:06 -0400
In-Reply-To: <20110730093025.716f3f50-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 30, 2011 at 09:30:25AM +1000, NeilBrown wrote:
> On Sat, 30 Jul 2011 06:34:44 +1000 Greg Banks <gnb@fastmail.fm> wrote=
:
>=20
> >=20
> >=20
> > Sent from my iPhone
> >=20
> > On 30/07/2011, at 2:53, "J. Bruce Fields" <bfields@fieldses.org> wr=
ote:
> >=20
> > > On Fri, Jul 29, 2011 at 12:48:36PM -0400, bfields wrote:
> > >> On Fri, Jul 29, 2011 at 11:30:05PM +1000, Greg Banks wrote:
> > >>>
> > >>>
> > >>> Sent from my iPhone
> > >>>
> > >>> On 29/07/2011, at 22:11, Eric Dumazet <eric.dumazet@gmail.com> =
=20
> > >>> wrote:
> > >>>
> > >>>> Le vendredi 29 juillet 2011 =C3=A0 21:58 +1000, Greg Banks a =C3=
=A9crit :
> > >>>>
> > >>>>>
> > >>>>> Sure, and a whole lot of the callsites are ("..._%d", cpu), =20
> > >>>>> hence the
> > >>>>> unfortune :(
> > >>>>
> > >>>> BTW, we could name nfsd threads differently :
> > >>>>
> > >>>> Currently, they all are named : "nfsd"
> > >>>>
> > >>>> If SVC_POOL_PERCPU is selected, we could name them :
> > >>>> nfsd_c0 -> nfsd_cN
> > >>>>
> > >>>> If SVC_POOL_PERNODE is selected, we could name them :
> > >>>> nfsd_n0  -> nfsd_nN
> > >>>>
> > >>>> That would help to check with "ps aux" which cpu/nodes are und=
er
> > >>>> stress.
> > >>>>
> > >>>>
> > >>>
> > >>> I like it!
> > >>
> > >> Yup, patch welcomed.--b.
> > >
> > > (Annoying fact: some initscripts stop nfsd using a rough equivale=
nt of
> > > "killall nfsd".  So the name of the threads is arguably ABI.  I t=
hink
> > > those initscripts are nuts and deserve what they get, but that ma=
y be
> > > because I'm forgetting the reason they do that.)
> > >
> >=20
> > We had this discussion in May-June 2008; it's because the nfsds wer=
e =20
> > once  many many years ago userspace threads.
>=20
> Even when they became kernel threads, 'kill' was the only way to kill=
 them -
> at first.
>=20
> >=20
> > The "killall nfsd" semantics in those scripts are awful and lead to=
 =20
> > problems shutting down when there are lots of threads. It would =20
> > probably be an improvement to provide a better shutdown mechanism a=
nd =20
> > force distros to use it.
>=20
> rpc.nfsd 0
>=20
> will stop all nfsd threads.  Follow with
>=20
>   exportfs -f
>=20
> and you should be done.  I'm not 100% sure about the nfsv4 thread tho=
ugh -
> would need to check.

Should be fine.

--b.
