Return-Path: <neilb@suse.de>
From: NeilBrown <neilb@suse.com>
To: Malahal Naineni <malahal@us.ibm.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Date: Wed, 16 Mar 2016 11:19:37 +1100
Cc: Benjamin Coddington <bcodding@redhat.com>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils] systemd: remove the nfs-config service
In-Reply-To: <20160315233337.GA3543@us.ibm.com>
References: <dfec4f0fe32d23aff0ed608b8f2931059060479a.1457784247.git.bcodding@redhat.com> <20160315142432.GB419@fieldses.org> <20160315233337.GA3543@us.ibm.com>
Message-ID: <87zitzff52.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Mar 16 2016, Malahal Naineni wrote:

> Ben, if I understand, EnvironmentFile must be sourced after running
> ExecStartPre for this method to work, correct? I was planning on doing
> something like this for ganesha project but I couldn't find enough
> documentation that says this.

The only documentation I found was the source code :-)

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJW6KaaAAoJEDnsnt1WYoG5ou4P/RU0l4BDddmVRL55XE1q0Vuh
TEDlfgT0fOlCiuFltut4h42sbGndaJxshCD5z6SF8KQJVZsfw9OphYr2+XqhCGkB
9REWrNXz9XcN80kDzFJ4s5hWF1CkAXJh3HzwQA3y8GxZogS2Rb7s2RfsFidrkeGa
0ocD15xGw6M3JKZnXBi5ZGK04SttwncSDfhzOYFOYcTJ/0Ex7r97zCH7n+gJrjHT
rg2QtzefzPHdpJPrHnG/jvYJBRGmdFSpK694lJFy28dPZ2ayLts8RU8J1IZpnuPK
fIj8VkUUUVLdWYiVspOasMrCVjeAcctQexzqT6iyPTyNbLZfkiAWDM31Pe/LLlQU
BGmUUJjTzzRI8ufTsLcPSVi3S94YbrszB8bD8+h6SfX8Oj0i/NR4i+oYz5HrBoSa
dh57eS8lb3x1V8EO6x3zpfp+CcBd48tNvz6EItWuU0cQTCenF34DGOx0rlJV6juL
i69lYY3fXs7jAUt+M7Zo3uiS7S4ypOUYzyuJwJf26W+fB4hheXvgszEVSjZuz7FB
BBLYRpHb9BU5CUC8G++w2+LBjgZNvgFWu7Mfz4O0LmJfe6TeJ1uh8ceqflbfHwow
YBp8V6CZnizZOrdRsXOwx5v1/0fvWbjPbRHylxuI1Bc+iNujg5AgNP7EPbC+odVJ
J7/FZIsuqb9lk2N3DnpI
=wQ+z
-----END PGP SIGNATURE-----
--=-=-=--
