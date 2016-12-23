Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37473 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757445AbcLWWzT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 17:55:19 -0500
From: NeilBrown <neilb@suse.com>
To: andros@netapp.com, bfields@fieldses.org
Date: Sat, 24 Dec 2016 09:55:12 +1100
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH Version 4] SVCAUTH reap the rsc cache entry on RPC_SS_PROC_DESTROY
In-Reply-To: <1482428286-33744-1-git-send-email-andros@netapp.com>
References: <1482428286-33744-1-git-send-email-andros@netapp.com>
Message-ID: <877f6qp86n.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Fri, Dec 23 2016, andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
>
> Version 4 of this patch set uses the patch provided by Neil Brown
> that directly unhashes and put's the to be deleted cache entry.
>
> I took the liberty of providing the patch comments.
>
> Neil - of course, do what you want with the patch and comments.
>

I'm happy with the patch and comments as they stand.
Thanks for pursuing this!

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlhdq1AACgkQOeye3VZi
gblDuQ/9FyerEjwwo8k052RBjSI/VUTGaySoV/ULoWYz4cUH7NaPOdy5Nsdwf7ke
/uzGiI/c4rTk7PkEJm+wXVw38m3FKOjCynvxgvMwUXhVYGf0qj/2NNvmhu6e/vio
nnMDua4FMLlGKDcPD4E8Imf32EwdMwCFAyAgIXMhP+v+hYeyyacpYJyU5bHUlQ0e
vZzTMoBkbNisop8PHwDVIoGRRF/Cic0A/RHzrR8+KjVRVVGtLQtAh6sE551IcxBl
StW5SNH1s1On/BviJMIY3IA1lxKtowvBPNrRhv7cAEw/QZb0YjjncVMhZ/e5xVj7
m9zJ3JKgA2jYmNAUFnrtX3Llgw/sF1t41nSoctcjkpJdtJoCNlQMv9rrr0suK4XT
zbDuPGIceF/8aZMyzqHv8VIcPlZ/PYhFrpqlJLgR4UpKE2sn9x3c0lFdkRv0MudY
Hc4Bh++eqJEzTrnrYBsBD18U1WFLa3M43/F7ahyyCR1aEwChlShMh5lmhw94YkM/
xRSDQIDQZ+cdvlPTRQmvW3MojfDz2oNn0NhaQhBn0WwUYZjxs5nVPwhDTRKu5QSK
IWhf9nzatbT32LIbRrhbedpqKdHT7aT9Ct9epnJ3MjN0UTLDY7LELqSvve9USvK7
xQy7LvCW1CTKqYvjqgS1R6EP2WSP3ntRJjoCt1/hSyXPfzBRBuo=
=fh3E
-----END PGP SIGNATURE-----
--=-=-=--
