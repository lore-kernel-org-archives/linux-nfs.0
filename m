Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45112 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883AbaGHG5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jul 2014 02:57:34 -0400
Date: Tue, 8 Jul 2014 16:57:27 +1000
From: NeilBrown <neilb@suse.de>
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is there a good reason that nfs4_state_manager should use a
 work_queue?
Message-ID: <20140708165727.7095e209@notabene.brown>
In-Reply-To: <20140708064641.GA16497@infradead.org>
References: <20140708152100.67cd93c7@notabene.brown>
	<20140708064641.GA16497@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/aYJOvA2Xu8J+uUEtyJ.DL+W"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/aYJOvA2Xu8J+uUEtyJ.DL+W
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 7 Jul 2014 23:46:41 -0700 Christoph Hellwig <hch@infradead.org> wro=
te:

> On Tue, Jul 08, 2014 at 03:21:00PM +1000, NeilBrown wrote:
> >  2/ would it be reasonable to have a single work queue for all nfs clie=
nts?
> >     In the worst case this could serialise reclaim across all clients s=
o we
> >     wouldn't want any reclaim attempt to block indefinitely.  Is that l=
ikely
> >     to be a big problem do you think?
>=20
> A workqueue isn't serialized, it has a max_active paramater to control
> the concurrency of execution.

True, but if memory is tight it may not be able to create new threads.
WQ_MEM_RECLAIM guarantees there will be at least one, but worst-case
that might be all that we have.

Thanks,
NeilBrown

--Sig_/aYJOvA2Xu8J+uUEtyJ.DL+W
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBU7uWWDnsnt1WYoG5AQI20hAAsxauQZjITeHvaFLfnB2OYisQOHIZhcjv
KBi+g0YQetNX6r3QFZrOiBOrmDge6hE8IpMY5Tt7nzNm50esChhoY8/DiuxjSm2o
cpYQjJMEpvw9JUAlfHGSQs+BaYOPaDvEoMRlTObPFCQbFkqLGmyvHA5l143fIMS4
lNR3+dToKrdhXL5BuE9DSMUyKRl0CwFKTg7dvxpgvQ9N4nzmvsRoSH9+lrJ17djI
g4nZZ8BcDznvyicxiMfb1vzJ5I2E5ppHKk6dW3RZ5KZrZVhdiG7ounUgHXvXS61B
T0JkS5YQylGpuBreHqCFYvp21UcjNhWQioqxnMrXppXiVf4SGQya1OS1e81rSONU
xClufjwfw5qkWFETC1BWLXlCNLQVorjIuBrpH6ToFdpBU36RIdB2YomI/gaFFkK0
YWveqeFkhKJoiRsmuq0a5DpZ7SvSOfn4gW5o0J6Uc/vin7nwW+9Kmq4+pXEaN/oX
y9P1oNNoA0V96ZwuDnm8wsE+TFs2g3Xz3thlyyViXukbn0ukkS3YM5BOypQ0iefF
qrtZvaZelm4/iwPGoCuJ7oNdKcwXhuOprVwBkURoAd9nEaaIyvrZdl4KzOimg7Qu
0nxqHVvaRpSty+9PI7RVeNu2d+dIYTK3saCZ3bTmRLv4Iq6kmZFbLSUtPKBn40Ht
Qow9xa7F9bA=
=1x1a
-----END PGP SIGNATURE-----

--Sig_/aYJOvA2Xu8J+uUEtyJ.DL+W--
