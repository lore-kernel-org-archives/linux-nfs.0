Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56488 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751895AbdFHWYt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jun 2017 18:24:49 -0400
From: NeilBrown <neilb@suse.com>
To: Justin Mitchell <jumitche@redhat.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 09 Jun 2017 08:24:39 +1000
Cc: Steve Dickson <SteveD@RedHat.com>
Subject: Re: [PATCH] Reimplement include functionality in nfs.conf
In-Reply-To: <1496939645.4216.13.camel@redhat.com>
References: <1496939645.4216.13.camel@redhat.com>
Message-ID: <87y3t29kyg.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08 2017, Justin Mitchell wrote:

> Re-implement include file functionality as documented.
>
> Existing implementation had various issues, one of which was it allowed
> a subordinate file to inadvertently change which section the subsequent
> tags back in the master config file got assigned to.
>
> Signed-off-by: Justin Mitchell <jumitche@redhat.com>
>

That all looks reasonably sensible - thanks.
I'll try to test it next week some time, but for now
 Acked-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown


>
>
> ---
>  support/nfs/conffile.c | 78 ++++++++++++++++++++++++++++++++++++--------=
------
>  1 file changed, 56 insertions(+), 22 deletions(-)
>
> diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
> index 449ac1c..05e0a6f 100644
> --- a/support/nfs/conffile.c
> +++ b/support/nfs/conffile.c
> @@ -56,9 +56,11 @@
>  #pragma GCC visibility push(hidden)
>=20=20
>  static void conf_load_defaults(void);
> -static int conf_load(int trans, const char *path);
> +static char * conf_load(const char *path);
>  static int conf_set(int , char *, char *, char *,=20
>  	char *, int , int );
> +static void conf_parse(int trans, char *buf,=20
> +	char **section, char **subsection);
>=20=20
>  struct conf_trans {
>  	TAILQ_ENTRY (conf_trans) link;
> @@ -202,7 +204,6 @@ conf_set_now(char *section, char *arg, char *tag,
>  	node->tag =3D strdup(tag);
>  	node->value =3D strdup(value);
>  	node->is_default =3D is_default;
> -
>  	LIST_INSERT_HEAD(&conf_bindings[conf_hash (section)], node, link);
>  	return 0;
>  }
> @@ -365,22 +366,47 @@ conf_parse_line(int trans, char *line, int lineno, =
char **section, char **subsec
>  		return;
>  	}
>=20=20
> -	/* XXX Perhaps should we not ignore errors?  */
> -	conf_set(trans, *section, *subsection, line, val, 0, 0);
> +	if (strcasecmp(line, "include")=3D=3D0) {
> +		/* load and parse subordinate config files */
> +		char * subconf =3D conf_load(val);
> +		if (subconf =3D=3D NULL) {
> +			xlog_warn("config file error: line %d: "
> +			"error loading included config", lineno);
> +			return;
> +		}
> +
> +		/* copy the section data so the included file can inherit it
> +		 * without accidentally changing it for us */
> +		char * inc_section =3D NULL;
> +		char * inc_subsection =3D NULL;
> +		if (*section !=3D NULL) {
> +			inc_section =3D strdup(*section);
> +			if (*subsection !=3D NULL)
> +				inc_subsection =3D strdup(*subsection);
> +		}
> +
> +		conf_parse(trans, subconf, &inc_section, &inc_subsection);
> +
> +		if (inc_section) free(inc_section);
> +		if (inc_subsection) free(inc_subsection);
> +		free(subconf);
> +	} else {
> +		/* XXX Perhaps should we not ignore errors?  */
> +		conf_set(trans, *section, *subsection, line, val, 0, 0);
> +	}
>  }
>=20=20
>  /* Parse the mapped configuration file.  */
>  static void
> -conf_parse(int trans, char *buf, size_t sz)
> +conf_parse(int trans, char *buf, char **section, char **subsection)
>  {
>  	char *cp =3D buf;
> -	char *bufend =3D buf + sz;
> +	char *bufend =3D NULL;
>  	char *line;
> -	char *section =3D NULL;
> -	char *subsection =3D NULL;
>  	int lineno =3D 0;
>=20=20
>  	line =3D cp;
> +	bufend =3D buf + strlen(buf);
>  	while (cp < bufend) {
>  		if (*cp =3D=3D '\n') {
>  			/* Check for escaped newlines.  */
> @@ -389,7 +415,7 @@ conf_parse(int trans, char *buf, size_t sz)
>  			else {
>  				*cp =3D '\0';
>  				lineno++;
> -				conf_parse_line(trans, line, lineno, &section, &subsection);
> +				conf_parse_line(trans, line, lineno, section, subsection);
>  				line =3D cp + 1;
>  			}
>  		}
> @@ -397,8 +423,6 @@ conf_parse(int trans, char *buf, size_t sz)
>  	}
>  	if (cp !=3D line)
>  		xlog_warn("conf_parse: last line non-terminated, ignored.");
> -	if (section) free(section);
> -	if (subsection) free(subsection);
>  }
>=20=20
>  static void
> @@ -408,21 +432,21 @@ conf_load_defaults(void)
>  	return;
>  }
>=20=20
> -static int
> -conf_load(int trans, const char *path)
> +static char *
> +conf_load(const char *path)
>  {
>  	struct stat sb;
>  	if ((stat (path, &sb) =3D=3D 0) || (errno !=3D ENOENT)) {
> -		char *new_conf_addr;
> +		char *new_conf_addr =3D NULL;
>  		size_t sz =3D sb.st_size;
>  		int fd =3D open (path, O_RDONLY, 0);
>=20=20
>  		if (fd =3D=3D -1) {
>  			xlog_warn("conf_reinit: open (\"%s\", O_RDONLY) failed", path);
> -			return -1;
> +			return NULL;
>  		}
>=20=20
> -		new_conf_addr =3D malloc(sz);
> +		new_conf_addr =3D malloc(sz+1);
>  		if (!new_conf_addr) {
>  			xlog_warn("conf_reinit: malloc (%lu) failed", (unsigned long)sz);
>  			goto fail;
> @@ -437,14 +461,13 @@ conf_load(int trans, const char *path)
>  		close(fd);
>=20=20
>  		/* XXX Should we not care about errors and rollback?  */
> -		conf_parse(trans, new_conf_addr, sz);
> -		free(new_conf_addr);
> -		return 0;
> +		new_conf_addr[sz] =3D '\0';
> +		return new_conf_addr;
>  	fail:
>  		close(fd);
> -		free(new_conf_addr);
> +		if (new_conf_addr) free(new_conf_addr);
>  	}
> -	return -1;
> +	return NULL;
>  }
>=20=20
>  /* remove and free up any existing config state */
> @@ -473,14 +496,25 @@ static void
>  conf_reinit(const char *conf_file)
>  {
>  	int trans;
> +	char * conf_data;
>=20=20
>  	trans =3D conf_begin();
> -	if (conf_load(trans, conf_file) < 0)
> +	conf_data =3D conf_load(conf_file);
> +
> +	if (conf_data =3D=3D NULL)
>  		return;
>=20=20
>  	/* Load default configuration values.  */
>  	conf_load_defaults();
>=20=20
> +	/* Parse config contents into the transaction queue */
> +	char *section =3D NULL;
> +	char *subsection =3D NULL;
> +	conf_parse(trans, conf_data, &section, &subsection);
> +	if (section) free(section);
> +	if (subsection) free(subsection);
> +	free(conf_data);
> +
>  	/* Free potential existing configuration.  */
>  	conf_free_bindings();
>=20=20
> --=20
> 1.8.3.1

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlk5zqgACgkQOeye3VZi
gbk8LQ/7BUUoa7+HVGYzQJnAK6uBZQvq6NVPuf2WW4jSbzJ7O99JI+5CCrANgUFV
grdgNbFBojAdVVJi364LXEujm21j1/dkTQbP2FWzbeYMUKFRGZpW3ZygMTUG7alM
dpfwinSJTFHG2rMgQcNYylZCWA2XUunfvY0L3mxPr3vhL2Ovdb7EmIFanOA1cCpG
GLCl0L28KvvU53oJv7W0rppCSd+y+b5K9CXezWyoD6DM8BKrww6peneIzCpZ0SIJ
JwpjzlV1tt+vDk782EmHPiOqiMCskJrOnGt0Z2Iwt1ifaBKqwuYHZTy5pOT/IOhT
YsXWBIV/U9wFyDK75KXHZ2LgJAED6+huEIT+TsY3annwgugVchGzAlS/F66t0rcu
h7DqU7BjdIBPgUck3mNHnkqWk51MTAZyh4TZPYhj9K8uRr2zDs38+lay9Qsg1CGb
0RJtTmxNNcsGL5Ab93lSoD9qYPZeSJ/MVjsVxd0m9eELaVKNyqRXyEFeRpZ2tbZV
IKa55K9c+RU+lEuy/NDZFBOuR57zAzTRtDif3SVnMyZYpLNrGqhZXFrqz3zK1ZbO
5whfrjFLNfsuy6neWldixQFiOnnQbWyTpddZmFW4Uixxs8/bzS80EOQOrvB/T0Po
ecDtLsR51DVm0N2LB3Bw4EwsIZHq7ahMbNA+HzTON2tgAvdl0qQ=
=8Q7a
-----END PGP SIGNATURE-----
--=-=-=--
