From: Dustin Kirkland <kirkland@canonical.com>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
 protocol
Date: Tue, 13 Oct 2009 23:56:13 -0500
Message-ID: <1255496173.21570.142.camel@x200>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org>
	 <4ACB5FC0.7060307@redhat.com>
	 <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org>
	 <4AD36C82.8080904@redhat.com>
	 <CA06CB5C-6084-45AA-B185-FBDA7E3B9754@excfb.com>
	 <4AD384BE.2090008@redhat.com>
	 <1255388158.3711.57.camel@heimdal.trondhjem.org>
	 <alpine.LRH.2.00.0910131733070.28896@tundra.namei.org>
	 <1255458444.3711.113.camel@heimdal.trondhjem.org>
	 <alpine.LRH.2.00.0910141134410.4671@tundra.namei.org>
Reply-To: kirkland@canonical.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-Kb6i1iSCSoBpbZoyHen2"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Peter Staubach <staubach@redhat.com>,
	Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
	David Patrick Quigley <dpquigl@tycho.nsa.gov>,
	Tyler Hicks <tyhicks@linux.vnet.ibm.com>
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:54482 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbZJNE5J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Oct 2009 00:57:09 -0400
In-Reply-To: <alpine.LRH.2.00.0910141134410.4671-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-Kb6i1iSCSoBpbZoyHen2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2009-10-14 at 11:48 +1100, James Morris wrote:
> I wonder how to handle ecryptfs -- it strikes me as a special case
> where the semantics are always local i.e. files can always be
> decrypted locally because of the crypto metatdata stored with them.

Hi James-

Yes, ecryptfs-on-NFS has long been a holy grail for the eCryptfs
project.  More generally, getting ecryptfs working on top of *any*
network filesystem (NFS, Samba, sshfs) would be brilliant.

As you say, the beauty is that the decryption happens locally, on your
CPU, and the storage server would just dutifully and agnosticly write
your encrypted bits, and would never see any keys.

We've hit a number of roadblocks, though, most of them of the
filesystems-don't-layer-on-top-of-NFS-well variety.

I don't suppose your present discussion gets us any closer to solving
those?

Regarding metadata, ecryptfs typically stores the metadata in the file
headers, rather than XATTRs.

Cheers,
--=20
:-Dustin

Dustin Kirkland
Canonical, LTD
kirkland@canonical.com
GPG: 1024D/83A61194

--=-Kb6i1iSCSoBpbZoyHen2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkrVWe0ACgkQs7pNXIOmEZQEgQCgtVWV5p7/ej9BkKxH9Wbgh/wk
UqIAoMaveDeX8ZKe/n00U1K1npP/Ejob
=Z/Vg
-----END PGP SIGNATURE-----

--=-Kb6i1iSCSoBpbZoyHen2--

