Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga01.intel.com ([192.55.52.88]:4335 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760334Ab2FHXaO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jun 2012 19:30:14 -0400
Date: Sat, 9 Jun 2012 02:31:27 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Boaz Harrosh <bharrosh@panasas.com>, Tao Ma <boyu.mt@taobao.com>,
        Nick Piggin <npiggin@kernel.dk>, "Dmitry V. Levin" <ldv@altlinux.org>,
        v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        codalist@TELEMANN.coda.cs.cmu.edu, ecryptfs@vger.kernel.org,
        osd-dev@open-osd.org, linux-ext4@vger.kernel.org,
        fuse-devel@lists.sourceforge.net, linux-mtd@lists.infradead.org,
        jfs-discussion@lists.sourceforge.net, logfs@logfs.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net, ocfs2-devel@oss.oracle.com,
        reiserfs-devel@vger.kernel.org
Subject: Re: [RFC, PATCH, RESEND] fs: push rcu_barrier() from
 deactivate_locked_super() to filesystems
Message-ID: <20120608233127.GB18981@otc-wbsnb-06>
References: <1339191663-17693-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120608150253.e42464a6.akpm@linux-foundation.org>
 <20120608221446.GA18250@otc-wbsnb-06>
 <20120608152550.258d6a30.akpm@linux-foundation.org>
 <20120608222734.GT30000@ZenIV.linux.org.uk>
 <20120608153120.b722d7c3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3uo+9/B/ebqu+fSQ"
In-Reply-To: <20120608153120.b722d7c3.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--3uo+9/B/ebqu+fSQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 08, 2012 at 03:31:20PM -0700, Andrew Morton wrote:
> On Fri, 8 Jun 2012 23:27:34 +0100
> Al Viro <viro@ZenIV.linux.org.uk> wrote:
>=20
> > On Fri, Jun 08, 2012 at 03:25:50PM -0700, Andrew Morton wrote:
> >=20
> > > A neater implementation might be to add a kmem_cache* argument to
> > > unregister_filesystem().  If that is non-NULL, unregister_filesystem()
> > > does the rcu_barrier() and destroys the cache.  That way we get to
> > > delete (rather than add) a bunch of code from all filesystems and new
> > > and out-of-tree filesystems cannot forget to perform the rcu_barrier(=
).
> >=20
> > There's often enough more than one cache, so that one is no-go.
>=20
> kmem_cache** ;)
>=20
> Which filesystems have multiple inode caches?

Multiple inode caches? No.
Multiple caches with call_rcu() free? See btrfs or gfs2.

--=20
 Kirill A. Shutemov

--3uo+9/B/ebqu+fSQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP0otPAAoJEAd+omnVudOM8pEP/j4da9wjUyer1zimYCUs0oA1
EQKJF+RlKs67b4j9eDRZKS/yDOC11CBemw333suupZugHnUmMrRIfbYw2c4vOsQs
C8E3glDJ3i6plLquzD2tBNmrs2rFFSEoLXQEuzpDuN5BVKB4ifXqnuwxVX8/lxTN
x3l81bt7sQvgO3OHL/DfuyVFsRG/N1qfaKJVjLhSFF971vPiz+xfn9uwiB8Be/Sa
28SBw4eVneaEZotHoNmDJmGH+LpRo0F5sy6gJNmh1VzK7eYN4pCr73f9tIL6x7XM
GBF84tK8uN8iNPqVoMXh4HtLCbS+q6TvVpHCWqab9u/ajvLPP0vY+Osm6Ryw2Exn
dnHjxqH9yyOsZmeHFP2osHNHbJMinKGX7iYoSAVuie5fTc27FkdyQkTS66KLpKGJ
UHCZ/PeDfRtxVo+3gV8g0PQJCWJ2LHz7b4g3q4zK44pNZDeyslgS+gMMG881tCBp
1Qy9Xq6Hb8MlkrlDY43hz4suQRCibG1nBZK37Ni02fEcj6S2lD6gsu5J91gNEEkc
49Ry0vBmCMRT+Zsl4YP9PPKSfsPG+2oTpf06xV8V+rApqwZ6nKBpWqyuJuVVpxIT
e/wamM+Ff6Ni6DVkXyXTO99wkSLHjdM+HL2MwhzQ38KMLrBAfzzZ8nGn67PahR/5
9q5U5UjNlz2F387CCYaK
=It/C
-----END PGP SIGNATURE-----

--3uo+9/B/ebqu+fSQ--
