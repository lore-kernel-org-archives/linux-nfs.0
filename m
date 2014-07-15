Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:47717 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467AbaGOIN3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 04:13:29 -0400
Date: Tue, 15 Jul 2014 18:13:17 +1000
From: NeilBrown <neilb@suse.de>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        NFS <linux-nfs@vger.kernel.org>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH/RFC] NFS: state manager thread must start running.
Message-ID: <20140715181317.2de14c51@notabene.brown>
In-Reply-To: <20140715074942.GA6166@infradead.org>
References: <20140715163942.1d94304f@notabene.brown>
	<20140715074942.GA6166@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_//uXPD65ExiytjEsdfYqexCx"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_//uXPD65ExiytjEsdfYqexCx
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 15 Jul 2014 00:49:42 -0700 Christoph Hellwig <hch@infradead.org>
wrote:

> On Tue, Jul 15, 2014 at 04:39:42PM +1000, NeilBrown wrote:
> > I suggested in an earlier email that it might be possible to use a
> > work-queue for this.  I concluded that it wasn't a good idea.
> > If a server was down, the manager cold block indefinitely.
> > If memory was tight and only one workqueue thread was active,
> > this would block other NFS mounts.
>=20
> So allocate one workqueue per mount?

Could do that (or per-client) but it doesn't really buy us anything does it?
The state manager assumes it is single threads, so it would need to be
a single-threaded workqueue with always at least one thread running.
That is much the same as a kthread.

And then there is that fact that the current code explicitly enabled SIGKILL
and maybe that is important.

NeilBrown

--Sig_//uXPD65ExiytjEsdfYqexCx
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU8TinTnsnt1WYoG5AQLnUg//X1Gl84LAUuBlAIYYTQggXwRy4XraX5eZ
umwnAF4W67BnSsFD5ljSLA9hOHntlcFUkoI4F8TaTRz+F0qxI7QPhk6mVj029vbk
8kKX+gG6B7rxMs89jnT/E36QoJjxH5r0dMugvX3Ao7ZxvK71aODjpJ+RIwNAVTxn
ut5fsXsss6yJaG1dxN5E7zcZ7TS0+IiSpyA26z9kL9WPmpuHT+Sifs+ctH95t4Vh
/fgNyaXEV6LteUkrqZB4I9AHYNodOvYY4dsZScL2bdb0OaA993keUjZDMm3CN+pM
PvkprDOeWGPKEld07DJCyIwDKlK1I4Ekb/Y7OeL+1vkNebFsnsnV2wVwMuaIMspD
99mFRaQcpNFIxhwBKayalRT5rn87dkaWxU8WjbiQLnNbPNemQDo//pCVk/mYcgSV
8EGSCV0xakB1h9VsqEQci1nofxT//QEbI281/cnuNqG5BhjxOVvKvMAyQy0e+gx2
NzPE2Q0lOsuVNqDm3KcnpHQWdbX4z81aOBpyT/SfopSJWangXHd+0SP44iTsLVb8
d5Db8qtR08rk8nlomLypNu/MSTVWYVxmVFuMaN5MY17aDVABGBpFndkSmjGI/iJA
/BdeV2rFSRhYU3jVKnChAekTTUqETz3Qi6AqLW17ideYH24OLESjsWNHFFIG1Vpo
1Xb38nb4Y/A=
=pIX8
-----END PGP SIGNATURE-----

--Sig_//uXPD65ExiytjEsdfYqexCx--
