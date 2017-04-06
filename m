Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44007 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752247AbdDFFW6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Apr 2017 01:22:58 -0400
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>, steved@redhat.com
Date: Thu, 06 Apr 2017 15:22:51 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v2 1/4] idmapd: move the pipefs-directory config option to nfs.conf
In-Reply-To: <20170405211243.12282-2-smayhew@redhat.com>
References: <20170405211243.12282-1-smayhew@redhat.com> <20170405211243.12282-2-smayhew@redhat.com>
Message-ID: <87fuhm155g.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 05 2017, Scott Mayhew wrote:

> Changed idmapd to read its value for the pipefs-directory from
> /etc/nfs.conf rather than /etc/idmapd.conf.  All other configurations
> related to id mapping still reside in /etc/idmapd.conf for now.
>
> Added a warning to indicate that idmapd's -c option is deprecated.
>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  nfs.conf                |  3 +++
>  systemd/nfs.conf.man    |  9 +++++++++
>  utils/idmapd/idmapd.c   | 40 ++++++++++++++++++++++++++++------------
>  utils/idmapd/idmapd.man | 21 ++++++++++++++++++++-
>  4 files changed, 60 insertions(+), 13 deletions(-)
>
> diff --git a/nfs.conf b/nfs.conf
> index 81ece06..ed516f5 100644
> --- a/nfs.conf
> +++ b/nfs.conf
> @@ -2,6 +2,9 @@
>  # This is a general conifguration for the=20
>  # NFS daemons and tools
>  #
> +#[global]
> +# pipefs-directory=3D/var/lib/nfs/rpc_pipefs
> +#
>  #[exportfs]
>  # debug=3D0
>  #
> diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
> index bdc0988..f8849c5 100644
> --- a/systemd/nfs.conf.man
> +++ b/systemd/nfs.conf.man
> @@ -96,6 +96,15 @@ value, which can be one or more from the list
>  .BR all .
>  When a list is given, the members should be comma-separated.
>  .TP
> +.B global
> +Recognized values:
> +.BR pipefs-directory .
> +
> +See
> +.BR rpc.idmapd (8)
> +for details.
> +
> +.TP
>  .B nfsdcltrack
>  Recognized values:
>  .BR storagedir .
> diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
> index f4e083a..5cac3a5 100644
> --- a/utils/idmapd/idmapd.c
> +++ b/utils/idmapd/idmapd.c
> @@ -166,7 +166,7 @@ static uid_t nobodyuid;
>  static gid_t nobodygid;
>=20=20
>  /* Used by conffile.c in libnfs.a */
> -char *conf_path;
> +char *conf_path =3D NULL;
>=20=20
>  static int
>  flush_nfsd_cache(char *path, time_t now)
> @@ -220,7 +220,6 @@ main(int argc, char **argv)
>  	int ret;
>  	char *progname;
>=20=20
> -	conf_path =3D _PATH_IDMAPDCONF;
>  	nobodyuser =3D NFS4NOBODY_USER;
>  	nobodygroup =3D NFS4NOBODY_GROUP;
>  	strlcpy(pipefsdir, PIPEFS_DIR, sizeof(pipefsdir));
> @@ -234,8 +233,11 @@ main(int argc, char **argv)
>  #define GETOPTSTR "hvfd:p:U:G:c:CS"
>  	opterr=3D0; /* Turn off error messages */
>  	while ((opt =3D getopt(argc, argv, GETOPTSTR)) !=3D -1) {
> -		if (opt =3D=3D 'c')
> +		if (opt =3D=3D 'c') {
> +			warnx("-c is deprecated and may be removed in the "
> +			      "future.  See idmapd(8).");
>  			conf_path =3D optarg;
> +		}
>  		if (opt =3D=3D '?') {
>  			if (strchr(GETOPTSTR, optopt))
>  				warnx("'-%c' option requires an argument.", optopt);
> @@ -247,17 +249,33 @@ main(int argc, char **argv)
>  	}
>  	optind =3D 1;
>=20=20
> -	if (stat(conf_path, &sb) =3D=3D -1 && (errno =3D=3D ENOENT || errno =3D=
=3D EACCES)) {
> -		warn("Skipping configuration file \"%s\"", conf_path);
> -		conf_path =3D NULL;
> +	if (conf_path) { /* deprecated -c option was specified */
> +		if (stat(conf_path, &sb) =3D=3D -1 && (errno =3D=3D ENOENT || errno =
=3D=3D EACCES)) {
> +			warn("Skipping configuration file \"%s\"", conf_path);
> +			conf_path =3D NULL;
> +		} else {
> +			conf_init();
> +			verbose =3D conf_get_num("General", "Verbosity", 0);
> +			cache_entry_expiration =3D conf_get_num("General",
> +					"Cache-Expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
> +			CONF_SAVE(xpipefsdir, conf_get_str("General", "Pipefs-Directory"));
> +			if (xpipefsdir !=3D NULL)
> +				strlcpy(pipefsdir, xpipefsdir, sizeof(pipefsdir));
> +			CONF_SAVE(nobodyuser, conf_get_str("Mapping", "Nobody-User"));
> +			CONF_SAVE(nobodygroup, conf_get_str("Mapping", "Nobody-Group"));
> +		}
>  	} else {
> +		conf_path =3D NFS_CONFFILE;
>  		conf_init();
> -		verbose =3D conf_get_num("General", "Verbosity", 0);
> -		cache_entry_expiration =3D conf_get_num("General",
> -				"Cache-Expiration", DEFAULT_IDMAP_CACHE_EXPIRY);
> -		CONF_SAVE(xpipefsdir, conf_get_str("General", "Pipefs-Directory"));
> +		CONF_SAVE(xpipefsdir, conf_get_str("global", "pipefs-directory"));

Can we leave the global section of the config file named "general" -
i.e. it contains general configuration.
conf_get_str() uses strcasecmp() so "General","Pipefs-Directory" works
the same as "general","pipefs-directory".
Then gssd.c wouldn't need to be changed (unless you want to add a
deprecation warning when the gssd-specific setting is found).

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljl0KsACgkQOeye3VZi
gbmXIQ/+JjLKhmWnUrNWoxr9rNR011RgICwcVWaej8YyCRyxONjd9SnA6LYdrGt0
/UWdE6gO0HLy4IAL6JaBlBxOXbWdB98w5md2Ai/4TDRkV3CjYppWtcXi/Dmqwkbo
z1oOBMiSfhT5sDD/7sQj+kq5oR3tGnuCuT4EOLFPJb26FCH70fdsOFELfQtimAYy
w+EIOLCZ6mlYdVFG6b0Qn3ePPVTnH8QyXS1KBT5HHAIW55iZ8IYUax/ajk+k1uCq
rZ0dH6iuioI4AmjIyT/3ng4acdF2CBn2BlNO5+UCfnyz1R2zv8j84RXgZugwpZDY
4VqctU+RUIjfURP/wkudegTXtS9PBiYoAs80UZA2j4Egxwv5SXCBWMK+9Pfzu6Wi
mThVTn+qdB9ycIhuCAzDDUSRbrvlurYiyiJy+UWAuBpVtJkIyruzXRMsBddi+J6F
/Sd7ZCihjRh38q7hh1JX8dyJSkIUzPBUOl2SHIWeiuJp2agsmcikbTHv3to51+8/
vWlwYSijeqOoeS5hercyc41M4Kj7kHTBzDcwCBJ4ubax8UHn6138rBuU485lN8OC
9AYmAZ+Yro4uzSEvB6tlwbilhf6FbLwQii081445BuYHVUvetWqxK+aqwradPJis
p7Prtj1yyWnxeta4oxJFwtUQXJ7YfMYiqyYQnQIuOIN3UmUanKs=
=HYcR
-----END PGP SIGNATURE-----
--=-=-=--
