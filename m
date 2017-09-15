Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38258 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751698AbdIODFJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Sep 2017 23:05:09 -0400
From: NeilBrown <neilb@suse.com>
To: "Jianhong.Yin" <yin-jianhong@163.com>, steved@redhat.com
Date: Fri, 15 Sep 2017 13:05:01 +1000
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: Re: [PATCH] nfsman: document minorversion
In-Reply-To: <20170907065729.4636-1-yin-jianhong@163.com>
References: <20170907065729.4636-1-yin-jianhong@163.com>
Message-ID: <87a81w8xwi.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 07 2017, Jianhong.Yin wrote:

> Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
> ---
>  utils/mount/nfs.man | 17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
>
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index cc6e992..7d42f19 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -779,6 +779,23 @@ so if this mount option is not specified, the NFS ve=
rsion 4 client
>  uses the TCP protocol.
>  Refer to the TRANSPORT METHODS section for more details.
>  .TP 1.5i
> +.BI minorversion=3D n
> +Specifies the protocol minor version number.
> +NFSv4 introduces "minor versioning," where NFS protocol enhancements can
> +be introduced without bumping the NFS protocol version number.
> +Before kernel 2.6.38, the minor version is always zero, and this
> +option is not recognized.
> +After this kernel, specifying "minorversion=3D1" enables a number of
> +advanced features, such as NFSv4 sessions.

This is not quite correct.  nfs-utils now defaults to the most recent
version of NFS that is supported by the kernel.  So if your kernel
supports v4.2, then specifying "minorversion=3D1" *disables* some features.

NeilBrown


> +.IP
> +Recent kernels allow the minor version to be specified using the
> +.B vers=3D
> +option.
> +For example, specifying
> +.B vers=3D4.1
> +is the same as specifying
> +.BR vers=3D4,minorversion=3D1 .
> +.TP 1.5i
>  .BI port=3D n
>  The numeric value of the server's NFS service port.
>  If the server's NFS service is not available on the specified port,
> --=20
> 2.13.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlm7Q14ACgkQOeye3VZi
gbnrdA/7BE954t6/GGiXjurjUulF7qSgFDvAzp7c7yJ1Vevln217vKA+rZkLwIUM
Iq1NhVdelh42bbLy3pNJbQVyyOgWsMGMvysopmlY2HuPE+m7oDOT3wkLV2n+2ASz
l2CMMj+5xPDVeCgDuZswq1BywHMTwl2ECj2yTml0bH2H4wmyWW9TgzDmi6NE1Sqq
dtceC2KpgHSKJuwcAsxbzivmgu4aq1Tgcu1K+YDiJzc3aff8A9SmTZBxs4PEwPu7
uStJmLoeACgA2Jq1mWWJB0H3ch+GHPKwXeCYsi4TPZusP785a3fgaXSvgQv6qW7K
jMhyj5m1FDf4IBvcpPG7gkn+4PsrZLQgK82vStzUPpN1E6Uh7hXrUKLOZwIdt5Go
QSECd36LkJ1DAcnPkh4GRzB7l/1l2Rca5GWC0+q4j0kR3FuM09bnCgqWWuwAadM0
+f55sf8fv4ofvPz6osDOkcaJ63hAx0SiQ6NygXAeJAtml7j6VWdgh8SfkmOFcxNY
GH1DJDvzJn7cC+A/0JbWBlhyGhhIXeMDjPhLDjPNTuT82qW2lnN1AmBBc8+OdmUB
NRScAnozREVf3gPd95LXqNO0TXgmsGUAs15eb6dljqjPoZWVXHFmwAAks4i3RHV/
/E+S6st+I1YYlMC/wiXy1XuzNlDi/Hsc0qKTV9QRj0k/5xmbn4U=
=4ArB
-----END PGP SIGNATURE-----
--=-=-=--
