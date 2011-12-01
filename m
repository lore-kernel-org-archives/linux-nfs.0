Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:39645 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab1LAGuc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 01:50:32 -0500
Date: Thu, 1 Dec 2011 00:50:25 -0600
From: Tyler Hicks <tyhicks@canonical.com>
To: Chris Dunlop <chris@onthe.net.au>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        David Howells <dhowells@redhat.com>, Jan Harkes <jaharkes@cs.cmu.edu>,
        "maintainer:CODA FILE SYSTEM" <coda@cs.cmu.edu>,
        Dave Kleikamp <shaggy@kernel.org>,
        Petr Vandrovec <petr@vandrovec.name>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Greg Kroah-Hartman <gregkh@suse.de>, Al Viro <viro@zeniv.linux.org.uk>,
        v9fs-developer@lists.sourceforge.net, linux-afs@lists.infradead.org,
        codalist@TELEMANN.coda.cs.cmu.edu,
        jfs-discussion@lists.sourceforge.net, linux-nfs@vger.kernel.org,
        ecryptfs@vger.kernel.org
Subject: Re: [PATCH 1/1] fix d_revalidate oopsen on NFS exports
Message-ID: <20111201065024.GB495@boyd>
References: <1321861008-20611-1-git-send-email-chris@onthe.net.au>
 <20111129082501.GA569@onthe.net.au>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="wzJLGUyc3ArbnUjN"
In-Reply-To: <20111129082501.GA569@onthe.net.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--wzJLGUyc3ArbnUjN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 2011-11-29 19:25:01, Chris Dunlop wrote:
> Hi,
>=20
> I haven't seen any response to this patch which fixes an Oops in
> d_revalidate. I hit this using NFS, but various other file
> systems look to be likewise vulnerable, hence the broadness of
> the patch. The sequence leading to the Oops is:
>=20
> lookup_one_len() [fs/namei.c]
>    calls __lookup_hash() [fs/namei.c] with nd =3D=3D NULL,
>       which can then call the file system specific d_revalidate(), passin=
g in nd =3D=3D NULL
>          which will then Oops if nd is used without checking

Hey Chris - Can you share what you were trying to do when you hit this?
Were you stacking eCryptfs on top of NFS? Another stacked filesystem on
top of NFS?

Do you *need* a stacked filesystem to work on top of NFS? If so, we'll
need to discuss a way forward. Al has previously shown a dislike of
eCryptfs passing around nameidata (for good reason), but that is what
NFS currently requires. I looked at doing this a few months back, but
never got to the implementation stage.

As David mentioned, Al's atomic open patches might solve all of this in
the future, but I don't know much about that patchset. Is there any
relevant info you could provide about those patches, Al?

Tyler

--wzJLGUyc3ArbnUjN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCgAGBQJO1yOwAAoJENaSAD2qAscKpgsP/jbJrsnjhcXnxKLTMRRMZ+Pn
N2AQYEa74BEKGzSIA71kqhg4GlHH49M35BFl9APWaYPaAefUIEmkF9hVPUAekY72
d3GaZAIsNAnydTD2eR4kPrzU+QiKizMGkFLe60E5TIkxESQ1cNu/YkvrA0TrJyEZ
RFOY1/IIp605C/OXSeOjXAOPIylpVwEiJNy28xoH6Wa8eNLGuaoOJ2d6sZ30B01G
3mhjQO+Iib+SA2NZTSNqtqBMmGu72+fbmHQVlF7qUrVMv3b9g34NKEbzNiz3meXH
0cRdkb7C+tJUC5apdR0xr5Tp84UnOXERUlNW1CX/m6vVZ+cOgy86rGZ4EswA4Rfn
mKaNhd/tMRajTud86TGzrywayKfXmdy7QxApdYQOIdVuczqQHfwaaPOrVqQyruU0
zWt7T/LZVdKImvJH9B8KSeaS+lUE7VyBy/LslT4BAkplfavlivD4hyT9KQo7++uZ
AdZ7gqWvrog8dCrysot//dVhK8v8Kg8PaX2RZwIi6bMtxUGlIbBwOljGglD4XNEZ
Kw7AIZgZYztp4TmzEQl1sphidHC8DhTtOaLF4ia6qhQlHCNJH8mwJI/n3jY4ESw2
meDExAgRfcbRS/ontjAicKv/Q0WIamtfd7tMUQikPWATfjFtfb8zKHR8FcE5lfA5
e/AvHS+GLFmy73bkFvKv
=G/79
-----END PGP SIGNATURE-----

--wzJLGUyc3ArbnUjN--
