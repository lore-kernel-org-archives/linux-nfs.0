Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39825 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751055AbdDCENX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 3 Apr 2017 00:13:23 -0400
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>, steved@redhat.com
Date: Mon, 03 Apr 2017 14:03:08 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC nfs-utils PATCH 1/2] idmapd: move the pipefs-directory config option to nfs.conf
In-Reply-To: <20170331215654.31570-2-smayhew@redhat.com>
References: <20170331215654.31570-1-smayhew@redhat.com> <20170331215654.31570-2-smayhew@redhat.com>
Message-ID: <87inmmkuir.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, Mar 31 2017, Scott Mayhew wrote:

> Changed idmapd to read its value for the pipefs-directory from
> /etc/nfs.conf rather than /etc/idmapd.conf.  All other configurations
> related to id mapping still reside in /etc/idmapd.conf for now.
>
> Removed the -c option, since it would be confusing as whether it should
> override nfs.conf, idmapd.conf, or both.

You didn't remove mention of the -c option from idmapd.man.
Otherwise:
  Reviewed-by: NeilBrown <neilb@suse.com>


Thanks,
NeilBrown


>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  nfs.conf                |  3 +++
>  systemd/nfs.conf.man    |  9 +++++++++
>  utils/idmapd/idmapd.c   | 35 ++++++++++++++---------------------
>  utils/idmapd/idmapd.man | 19 ++++++++++++++++++-
>  4 files changed, 44 insertions(+), 22 deletions(-)
>
> diff --git a/nfs.conf b/nfs.conf
> index 81ece06..4359904 100644
> --- a/nfs.conf
> +++ b/nfs.conf
> @@ -17,6 +17,9 @@
>  # cred-cache-directory=3D
>  # preferred-realm=3D
>  #
> +#[idmapd]
> +# pipefs-directory=3D/var/lib/nfs/rpc_pipefs
> +#
>  #[lockd]
>  # port=3D0
>  # udp-port=3D0
> diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
> index bdc0988..83cf84a 100644
> --- a/systemd/nfs.conf.man
> +++ b/systemd/nfs.conf.man
> @@ -215,6 +215,15 @@ See
>  for details.
>=20=20
>  .TP
> +.B idmapd
> +Recognized values:
> +.BR pipefs-directory .
> +
> +See
> +.BR rpc.idmapd (8)
> +for details.
> +
> +.TP
>  .B svcgssd
>  Recognized values:
>  .BR principal .
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index f4e083a..561a4b8 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -214,13 +214,11 @@ main(int argc, char **argv)
>  	struct event initialize;
>  	struct passwd *pw;
>  	struct group *gr;
> -	struct stat sb;
>  	char *xpipefsdir =3D NULL;
>  	int serverstart =3D 1, clientstart =3D 1;
>  	int ret;
>  	char *progname;
>=20=20
> -	conf_path =3D _PATH_IDMAPDCONF;
>  	nobodyuser =3D NFS4NOBODY_USER;
>  	nobodygroup =3D NFS4NOBODY_GROUP;
>  	strlcpy(pipefsdir, PIPEFS_DIR, sizeof(pipefsdir));
> @@ -231,11 +229,9 @@ main(int argc, char **argv)
>  		progname =3D argv[0];
>  	xlog_open(progname);
>=20=20
> -#define GETOPTSTR "hvfd:p:U:G:c:CS"
> +#define GETOPTSTR "hvfd:p:U:G:CS"
>  	opterr=3D0; /* Turn off error messages */
>  	while ((opt =3D getopt(argc, argv, GETOPTSTR)) !=3D -1) {
> -		if (opt =3D=3D 'c')
> -			conf_path =3D optarg;
>  		if (opt =3D=3D '?') {
>  			if (strchr(GETOPTSTR, optopt))
>  				warnx("'-%c' option requires an argument.", optopt);
> @@ -247,20 +243,19 @@ main(int argc, char **argv)
>  	}
>  	optind =3D 1;
>=20=20
> -	if (stat(conf_path, &sb) =3D=3D -1 && (errno =3D=3D ENOENT || errno =3D=
=3D EACCES)) {
> -		warn("Skipping configuration file \"%s\"", conf_path);
> -		conf_path =3D NULL;
> -	} else {
> -		conf_init();
> -		verbose =3D conf_get_num("General", "Verbosity", 0);
> -		cache_entry_expiration =3D conf_get_num("General",
> -				"Cache-Expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
> -		CONF_SAVE(xpipefsdir, conf_get_str("General", "Pipefs-Directory"));
> -		if (xpipefsdir !=3D NULL)
> -			strlcpy(pipefsdir, xpipefsdir, sizeof(pipefsdir));
> -		CONF_SAVE(nobodyuser, conf_get_str("Mapping", "Nobody-User"));
> -		CONF_SAVE(nobodygroup, conf_get_str("Mapping", "Nobody-Group"));
> -	}
> +	conf_path =3D NFS_CONFFILE;
> +	conf_init();
> +	CONF_SAVE(xpipefsdir, conf_get_str("idmapd", "pipefs-directory"));
> +	if (xpipefsdir !=3D NULL)
> +		strlcpy(pipefsdir, xpipefsdir, sizeof(pipefsdir));
> +
> +	conf_path =3D _PATH_IDMAPDCONF;
> +	conf_init();
> +	verbose =3D conf_get_num("General", "Verbosity", 0);
> +	cache_entry_expiration =3D conf_get_num("General",
> +			"cache-expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
> +	CONF_SAVE(nobodyuser, conf_get_str("Mapping", "Nobody-User"));
> +	CONF_SAVE(nobodygroup, conf_get_str("Mapping", "Nobody-Group"));
>=20=20
>  	while ((opt =3D getopt(argc, argv, GETOPTSTR)) !=3D -1)
>  		switch (opt) {
> @@ -307,8 +302,6 @@ main(int argc, char **argv)
>  #ifdef HAVE_NFS4_SET_DEBUG
>  	nfs4_set_debug(verbose, xlog_warn);
>  #endif
> -	if (conf_path =3D=3D NULL)
> -		conf_path =3D _PATH_IDMAPDCONF;
>  	if (nfs4_init_name_mapping(conf_path))
>  		errx(1, "Unable to create name to user id mappings.");
>=20=20
> diff --git a/utils/idmapd/idmapd.man b/utils/idmapd/idmapd.man
> index d4ab894..0fbc24c 100644
> --- a/utils/idmapd/idmapd.man
> +++ b/utils/idmapd/idmapd.man
> @@ -78,6 +78,21 @@ Client-only: perform no idmapping for any NFS server, =
even if one is detected.
>  .It Fl S
>  Server-only: perform no idmapping for any NFS client, even if one is det=
ected.
>  .El
> +.Sh CONFIGURATION FILES
> +The
> +.Sy [idmapd]
> +section of the
> +.Pa /etc/nfs.conf
> +configuration file recognizes the following value:
> +.Bl -tag -width Ds_imagedir
> +.It Sy pipefs-directory
> +Equivalent to
> +.Sy -p .
> +.El
> +.Pp
> +All other settings related to id mapping are found in the
> +.Pa /etc/idmapd.conf
> +configuration file.
>  .Sh EXAMPLES
>  .Cm rpc.idmapd -f -vvv
>  .Pp
> @@ -94,9 +109,11 @@ messages to console, and with a verbosity level of 3.
>  .\" This next request is for sections 1, 6, 7 & 8 only.
>  .\" .Sh ENVIRONMENT
>  .Sh FILES
> -.Pa /etc/idmapd.conf
> +.Pa /etc/idmapd.conf ,
> +.Pa /etc/nfs.conf
>  .Sh SEE ALSO
>  .Xr idmapd.conf 5 ,
> +.Xr nfs.conf 5 ,
>  .Xr nfsidmap 8
>  .\".Sh SEE ALSO
>  .\".Xr nylon.conf 4
> --=20
> 2.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljhyXwACgkQOeye3VZi
gbmxFhAAokNnTNTm8DVAwxjMcgXegUorIIB8q14+1RYjLFd6XnRZurw/CHvrg4cL
nacy9xAXP5nFJgTJCjw/EePsVQ701Sxf1eqqDNxAeTn6I4sP4w6+Y5/4e2YFGZ9I
CckBU9IinqY/ufWQZnAf34dtn5SMbNsFRFwrZHcXkIR6gYa1dbuE5FhbGGjwmn+F
MGadHRFQGuoE2ysgKU0IP1thLcv44Euh1157DAaFirfHbCwvdraNB3MkSBV/G9UM
+UOR2I+ppwyIsrcng8VWdkDVbCqDTpe3OAu34ZXTjC2wkLV83+BPnWg3TFQnjzi3
hHBxNaW3WOAFlC1KTbloESKrxZQ5Qgy9HgUxLqjO570AM3PN9SFuowv2obJTmKUB
6LKkXER0U7sQfkFylzeKQy9tA2RZ7ggLKAa0CKufIrtrdhfFfHMyLg84zcTqizO8
nNbNfichkiI/1pT+70/ZYnhdQuGUDbd2Q/ptLZuXGoXamPIhoS4Qx8VpPTfn77NL
gqF+2nJYwkg7np2fpgKmFVnnT6iDN0kqN9X23RQ9lYdhZtGVBT+ShsccmGGerG/C
W1G7BCSeP/PG3rIerP/h7v5Yz9/zkcMPbXlQMbpJHblx3wrAJmeCozHXLNVBk8z8
97eWe4xnOuV7okyWcST+QNW3i2Wto80FxFpPVRt/pPLNDd/jYFM=
=wT1e
-----END PGP SIGNATURE-----
--=-=-=--
