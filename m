Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hr2.samba.org ([144.76.82.148]:38725 "EHLO hr2.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756437AbcCUSVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2016 14:21:46 -0400
Date: Mon, 21 Mar 2016 19:20:57 +0100
From: Michael Adam <obnox@samba.org>
To: Volker Lendecke <Volker.Lendecke@SerNet.DE>,
        Christoph Hellwig <hch@infradead.org>
Cc: Jeremy Allison <jra@samba.org>, Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Theodore Ts'o" <tytso@mit.edu>, linux-cifs@vger.kernel.org,
        Linux API <linux-api@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        LKML <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-ext4 <linux-ext4@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v18 00/22] Richacls (Core and Ext4)
Message-ID: <20160321182057.GF1044@samba.org>
References: <1456733847-17982-1-git-send-email-agruenba@redhat.com>
 <20160311140134.GA14808@infradead.org>
 <CAHc6FU4t3yisCM=MXrHRmCja_A8eZOpVa1smJ0gUhv+vuUAuXA@mail.gmail.com>
 <20160315071103.GC19747@infradead.org>
 <20160315154514.GB39038@jra3>
 <20160315201700.GA22945@sernet.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NklN7DEeGtkPCoo3"
In-Reply-To: <20160315201700.GA22945@sernet.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--NklN7DEeGtkPCoo3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2016-03-15 at 21:17 +0100, Volker Lendecke wrote:
> On Tue, Mar 15, 2016 at 08:45:14AM -0700, Jeremy Allison wrote:
> > On Tue, Mar 15, 2016 at 12:11:03AM -0700, Christoph Hellwig wrote:
> > > People have long learned that we only have 'alloc' permissions.  Any
> > > model that mixes allow and deny ACE is a mistake.
> >=20
> > People can also learn and change though :-). One of the
> > biggest complaints people deploying Samba on Linux have is the
> > incompatible ACL models.
>=20
> Just to confirm: I see this a lot in the field. NFSv4 ACLs, while not a
> perfect match for NTFS ACLs are a lot closer much more usable to people
> who want to serve Windows clients.
>=20
> Also in the pure linux world there is a lot that you can not express
> with just rwx, sgid, sticky bits and friends. If you want the additional
> functionality of the richacl bits, I would call it a big mistake to
> omit negative aces, if just for the reason not to create yet another
> ACLs flavor.
>=20
> > Whilst I have sympathy with your intense dislike of the
> > Windows ACL model, this comes down to the core of "who
> > do we serve ?"
>=20
> The world has enough confusion around ACL semanics, please do not add
> more to it by creating your own model of the day.

Exacty: Like it or not, Windows ACLs are a fact. And the
approximation by the NFSv4 ACLs is getting closer and closer
with each iteration... ;-) So it is not only that Windows world
looking into this.

As Volker and Jeremy have pointed out, the lack of ACL semantics
is one of things the users of Samba complain about most bitterly.
While Samba can work around it when it is acting exclusively on
the files, this is not an option when NFS or other protocols are
to access the data concurrently. In that case we need more
precision down in the file system. So because they make use of
*existing* formats and semantics, I think Andreas' richacls are
just the way to go, as alien as they may seem from the pure linux
filesystem point of view at first.

Cheers - Michael

--NklN7DEeGtkPCoo3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: comment

iEYEARECAAYFAlbwO4kACgkQyU9JOBhPkDSbLgCgg014joqbBszyQNQOfv6cNSVX
GSIAoJHvKMybjmmMy0l/xqCBjTDuVjzS
=vumV
-----END PGP SIGNATURE-----

--NklN7DEeGtkPCoo3--
