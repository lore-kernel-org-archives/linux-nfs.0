Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48067 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756882Ab3IDXs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 19:48:58 -0400
Date: Thu, 5 Sep 2013 09:48:43 +1000
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - alt-2] NFSv4:  Don't try to recover NFSv4 locks when
 they are lost.
Message-ID: <20130905094843.3733515a@notabene.brown>
In-Reply-To: <1378305066.3527.8.camel@leira.trondhjem.org>
References: <20130904170449.7d2662cd@notabene.brown>
	<1378305066.3527.8.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/3orm/gprylXMvuz29WaPX9J"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/3orm/gprylXMvuz29WaPX9J
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 4 Sep 2013 14:31:07 +0000 "Myklebust, Trond"
<Trond.Myklebust@netapp.com> wrote:

> On Wed, 2013-09-04 at 17:04 +1000, NeilBrown wrote:
> >=20
> > When an NFSv4 client loses contact with the server it can lose any
> > locks that it holds.
> >=20
> > Currently when it reconnects to the server it simply tries to reclaim
> > those locks.  This might succeed even though some other client has
> > held and released a lock in the mean time.  So the first client might
> > think the file is unchanged, but it isn't.  This isn't good.
> >=20
> > If, when recovery happens, the locks cannot be claimed because some
> > other client still holds the lock, then we get a message in the kernel
> > logs, but the client can still write.  So two clients can both think
> > they have a lock and can both write at the same time.  This is equally
> > not good.
> >=20
> > There was a patch a while ago
> >   http://comments.gmane.org/gmane.linux.nfs/41917
> >=20
> > which tried to address some of this, but it didn't seem to go
> > anywhere.  That patch would also send a signal to the process.  That
> > might be useful but for now this patch just causes writes to fail.
> >=20
> > For NFSv4 (unlike v2/v3) there is a strong link between the lock and
> > the write request so we can fairly easily fail any IO of the lock is
> > gone.  While some applications might not expect this, it is still
> > safer than allowing the write to succeed.
> >=20
> > Because this is a fairly big change in behaviour a module parameter,
> > "recover_locks", is introduced which defaults to true (the current
> > behaviour) but can be set to "false" to tell the client not to try to
> > recover things that were lost.
> >=20
> > Signed-off-by: NeilBrown <neilb@suse.de>
>=20
> Thanks!
>=20
> > --
> > This alternative uses a module parameter which defaults to the current,
> > incorrect, behaviour.
> > I suspect we don't want that one..
>=20
> Agreed. We also need to document the module parameter, so I'm adding a
> little blurb in Documentation/kernel-parameters.txt (see attachment).
>=20
> I'd also like to change the parameter name to "recover_lost_locks" to
> make it a little more obvious.
>=20
> Finally, I'd like to move the parameter to fs/nfs/super.c so that we can
> use the same modprobe.conf 'options' lines for back ports of this patch
> (yes I strongly suspect we will want to back port this patch to distro
> kernels).
>=20
> See attachment.

Looks good - thanks.

NeilBrown

--Sig_/3orm/gprylXMvuz29WaPX9J
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUifG2znsnt1WYoG5AQJeDQ/9GDr7qxTXNFmJNcZ2Mxuqpo9nvpKGoguf
ofMPQ+BvDs5yXPSVG3na1BmXLBvZGw0chbl/7/XAKDfnHX0e4RAeghn5P89ghcxH
oew3mXwo/4FemKuGA3NKuDRoO9YX1GiiebXhScAK+Sj1osGJ/zlB7omjmJa1MxAN
SJNVjCntV/Ov8iaANplC+w9j2zbzj4xtD4DCseyHsaUAi5nJ8tfI3wi2ubiGpG8f
Ox4aPEkSbDK/AxlR+UcLkGvGv1MQu1Z4D3etEwqKGsWqhmzlRZJfIJeqJHVDQws7
WwDymlVWfu4wJQCdWwtuUXTg9AnZn5bND/3wqnClGDI7cYNZQX+OGA8+HIrudWeI
8R+/Z092/dP8+odVH7sK3cnIimu7bI09e4xdd7ZP1LB9/PKeC6MIzZkgw6IUqTIR
S1mKZEKqxqVnZphME5sdpLwI29mCv7f8LKrcdc4vg5QXxSyVfHq3qf7DenFDcPJ+
5zh0LPSeGgO/huzSb8sLWxOmMsgWi3ZV4vyrF9jjgYi11pGScUQJVfBZI/Rq6qoO
zRFS8TEHmqbs7kwIavjJHqZYPy7yzWJRDweYaqsyDEG9eF/vHh2XHzAb+GgQDWmP
l8sCOeXgAB4j0B/OZ2LGX6yAwZUm2sW3pnjcVUZzL/TRmmXluN5YVowoMTdbysXY
RBUK8FF9EXs=
=48D0
-----END PGP SIGNATURE-----

--Sig_/3orm/gprylXMvuz29WaPX9J--
