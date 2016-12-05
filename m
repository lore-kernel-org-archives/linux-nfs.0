Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58658 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751605AbcLEWnO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Dec 2016 17:43:14 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Tue, 06 Dec 2016 09:42:41 +1100
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 03/15] Add /etc/nfs.conf support to rpc.nfsd
In-Reply-To: <20161205222750.GC20652@fieldses.org>
References: <148065078775.28046.5506130555300891075.stgit@noble> <148065110833.28046.2561331715736018574.stgit@noble> <20161205222750.GC20652@fieldses.org>
Message-ID: <874m2i576m.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Tue, Dec 06 2016, J. Bruce Fields wrote:

> On Fri, Dec 02, 2016 at 02:58:28PM +1100, NeilBrown wrote:
>> I haven't added -H support, but everything else should be able to be
>> set through /etc/nfs.conf.
>
> I'm unclear--is this just a temporary omission for the purposes of this
> RFC, or is there some reason you think -H shouldn't be set in nfs.conf?
>

Temporary omission.
I would need to decide how to store a list in nfs.conf.
1/
  [nfsd]
  host = foo
  host = bar

2/
  [nfsd]
    host = foo, bar

3/ ??

and I suspect that any -H on the command line would over-ride all host=
in nfs.conf, but I'm not certain.
I'm sure there is a good, defensible solution here, but I didn't want to
spend time on it for the RFC.

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhF7WEACgkQOeye3VZi
gbkrfw//Q+aJDi5UmQH0ZigSaSSBZ9pWnLjLqW20MTEUmxuV89fvcI2Qra4ud9bK
/lXQ9+UbNRjTxYTAjqeoYb7pINjItq81y4F34GyvUn6N66D6WduU7Nll1pvys6ji
vq6SlKKdQ0gjQo6X4rZFUqZAlg/Zv0G/BIq0LDvIR1OlDvPdYEkG56xEa5ZEzDOL
c++3/5Qk69D9e78lztUvQPzoAe1R8yzCKoJttUk0e16xmshARkcIglgsbF9yHj65
UuJOcrnBWJvEYIQZRmy5XsiC22QSLIy8wBLN0pqLiy4OzxmgikIRC673yRYVUDBG
aWiO9l/txXfN0ncAa7kq9Xk22mgScHUx3mvGxlb+wUCauXNe/zbYuWIZWqZauoAf
2xZK0oUTTsuqFJCXFQToWfEaRKrHrbUYK9zLQ9LHz+Fi21opqgvnHn0vclcwTTpQ
qyuDr9foI+C3mtzWpeJ3RmD3q+hv+8y0CQr3y2RHTjb2kzC8DpVlUfKMy1xPax3f
Jeyomuq6Rxqk4TZiaXARtuSZb0cshx81t5FcvU3OU3fDUvfh+NbqD5eX9d/m/uG7
VsRjmp6k5DbuYeG5IJncYXrqXK+SFY0JvHmlLlX9vTkfHnf5gxhYDSvM411MlxYr
IifGzkkBShnRxSSTYI1zDRoLHA17tuBySxRT8p/gWeoo+zLUH4E=
=lJcW
-----END PGP SIGNATURE-----
--=-=-=--
