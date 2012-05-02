Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:49444 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758358Ab2EBCH2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 22:07:28 -0400
Date: Wed, 2 May 2012 12:07:12 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/3] mountd: prepend '$' to make use_ipaddr clients
 self-describing
Message-ID: <20120502120712.13b15f9a@notabene.brown>
In-Reply-To: <1335923014-2789-3-git-send-email-bfields@redhat.com>
References: <20120502014155.GA2684@fieldses.org>
	<1335923014-2789-3-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/+6bYXkHWWF1MaZhh5fSZZgR"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/+6bYXkHWWF1MaZhh5fSZZgR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue,  1 May 2012 21:43:34 -0400 "J. Bruce Fields" <bfields@redhat.com>
wrote:
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 6cc58d2..1833b3a 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -551,7 +551,7 @@ static void nfsd_fh(FILE *f)
> =20
>  	auth_reload();
> =20
> -	if (use_ipaddr) {
> +	if (dom[0] =3D=3D '$') {

        if (is_ipaddr_client(dom)) {
??

Otherwise:
  Reviewed-by: NeilBrown <neilb@suse.de>

Thanks,
NeilBrown

--Sig_/+6bYXkHWWF1MaZhh5fSZZgR
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBT6CW0Dnsnt1WYoG5AQJtGw/9HQLw2rirloqUC7g8h8tKLhE3E4IWN3SG
k/3evyuDo+1VgQzNUJ7SoTAbRuRgGmYcn6ZylFBN48aQb7SOuS9RvkIF3Uzv+r4u
S4WacMtYW7sHgDbQ3FwJMAlRPCnqAfnUPyb6NO51mpzDP5p1THaFPL+ICW2gOUZ9
pIiXGs90nJ6qPCFfeG+T9bdIZWJZOPPNOYbPAzWqUhMy+ViItzMjRZDoZHhawSYC
qxlvF4Czu9OYJAQCkK0yxmSnT0fU4HNdlKOyz3aQ4CKSjusdYLY5SGj5C4RgUthh
AldhmYUDevKCvHPQlyD0+Hv2LALt5jcgDCOqNnL5+6YlSJAhdCDlZtliDz2vUJ+2
r+um6fsyy+3YOpiXlqZJmqkdeTInQgCdJcWUUfQivUy2VIiv/B6Hm+39qbm7yFb+
/LB81h3EOMr8cWb0/Qi26M2QK+1ueRv8y2EIBW0O/pPhEtsafk5yCJ1ii/D7Spdu
x78uUq4uYILHtpgY+rLvhJsgt+pnW3VwDtbJ18ObKtoue5g7P02x55U8OrD3z4W8
dml1mwGL2aITa6O8EiBHdChEzdNMTmG1/JFa6hGe6YvklRZM3nhVqLjQSe0GLCw2
BiIeUJM1zuNNwzKdxYehtGVV76ReZ2+x9QSSfSHuACjg7rLSucOP8HMU17+3a31E
AJZu+8a+tFE=
=CQ0c
-----END PGP SIGNATURE-----

--Sig_/+6bYXkHWWF1MaZhh5fSZZgR--
