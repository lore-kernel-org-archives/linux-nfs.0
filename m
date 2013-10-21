Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:48449 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751765Ab3JUWZd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 18:25:33 -0400
Date: Tue, 22 Oct 2013 09:25:19 +1100
From: NeilBrown <neilb@suse.de>
To: Tony Asleson <tasleson@redhat.com>
Cc: linux-nfs@vger.kernel.org, Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] exportfs: Return non-zero exit value on error
Message-ID: <20131022092519.4f4683a8@notabene.brown>
In-Reply-To: <1380756584-13335-1-git-send-email-tasleson@redhat.com>
References: <1380756584-13335-1-git-send-email-tasleson@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/NKgq0.hlSTdRbrq.TT8rvVR"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/NKgq0.hlSTdRbrq.TT8rvVR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed,  2 Oct 2013 18:29:44 -0500 Tony Asleson <tasleson@redhat.com> wrote:

> To improve error handling when scripting exportfs it's useful
> to have non-zero exit codes when the requested operation did not
> succeed.
>=20
> This patch also returns a non-zero exit code if you request to
> unexport a non-existant share.
>=20
> Signed-off-by: Tony Asleson <tasleson@redhat.com>
> ---
>  support/export/hostname.c |  2 ++
>  utils/exportfs/exportfs.c | 37 +++++++++++++++++++++++++++----------
>  2 files changed, 29 insertions(+), 10 deletions(-)
>=20
> diff --git a/support/export/hostname.c b/support/export/hostname.c
> index 3e949a1..e53d692 100644
> --- a/support/export/hostname.c
> +++ b/support/export/hostname.c
> @@ -175,10 +175,12 @@ host_addrinfo(const char *hostname)
>  	case 0:
>  		return ai;
>  	case EAI_SYSTEM:
> +		export_errno =3D errno;
>  		xlog(D_GENERAL, "%s: failed to resolve %s: (%d) %m",
>  				__func__, hostname, errno);
>  		break;
>  	default:
> +		export_errno =3D EINVAL;
>  		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
>  				__func__, hostname, gai_strerror(error));
>  		break;
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 52fc03d..318deb3 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -35,8 +35,8 @@
>  #include "xlog.h"
> =20
>  static void	export_all(int verbose);
> -static void	exportfs(char *arg, char *options, int verbose);
> -static void	unexportfs(char *arg, int verbose);
> +static int	exportfs(char *arg, char *options, int verbose);
> +static int	unexportfs(char *arg, int verbose);
>  static void	exports_update(int verbose);
>  static void	dump(int verbose, int export_format);
>  static void	error(nfs_export *exp, int err);
> @@ -187,8 +187,12 @@ main(int argc, char **argv)
>  		if (f_all)
>  			export_all(f_verbose);
>  		else
> -			for (i =3D optind; i < argc ; i++)
> -				exportfs(argv[i], options, f_verbose);
> +			for (i =3D optind; i < argc ; i++) {
> +				if(!exportfs(argv[i], options, f_verbose)) {
> +					/* Only flag a generic EINVAL if no errno is set */
> +					export_errno =3D (export_errno) ? export_errno : EINVAL;
> +				}
> +			}
>  	}
>  	/* If we are unexporting everything, then
>  	 * don't care about what should be exported, as that
> @@ -201,8 +205,12 @@ main(int argc, char **argv)
>  		if (!f_reexport)
>  			xtab_export_read();
>  		if (!f_export)
> -			for (i =3D optind ; i < argc ; i++)
> -				unexportfs(argv[i], f_verbose);
> +			for (i =3D optind ; i < argc ; i++) {
> +				if (!unexportfs(argv[i], f_verbose)) {
> +					/* Only flag a generic EINVAL if no errno is set */
> +					export_errno =3D (export_errno) ? export_errno : EINVAL;
> +				}
> +			}
>  		if (!new_cache)
>  			rmtab_read();
>  	}
> @@ -296,9 +304,10 @@ export_all(int verbose)
>  }
> =20
> =20
> -static void
> +static int
>  exportfs(char *arg, char *options, int verbose)
>  {
> +	int rc =3D 0;
>  	struct exportent *eep;
>  	nfs_export	*exp =3D NULL;
>  	struct addrinfo	*ai =3D NULL;
> @@ -311,7 +320,8 @@ exportfs(char *arg, char *options, int verbose)
> =20
>  	if (!path || *path !=3D '/') {
>  		xlog(L_ERROR, "Invalid exporting option: %s", arg);
> -		return;
> +		export_errno =3D EINVAL;
> +		return rc;
>  	}
> =20
>  	if ((htype =3D client_gettype(hname)) =3D=3D MCL_FQDN) {
> @@ -339,13 +349,16 @@ exportfs(char *arg, char *options, int verbose)
>  	exp->m_warned =3D 0;
>  	validate_export(exp);
> =20
> +	rc =3D 1;
>  out:
>  	freeaddrinfo(ai);
> +	return rc;
>  }
> =20
> -static void
> +static int
>  unexportfs(char *arg, int verbose)
>  {
> +	int rc =3D 0;
>  	nfs_export	*exp;
>  	struct addrinfo *ai =3D NULL;
>  	char		*path;
> @@ -357,7 +370,8 @@ unexportfs(char *arg, int verbose)
> =20
>  	if (!path || *path !=3D '/') {
>  		xlog(L_ERROR, "Invalid unexporting option: %s", arg);
> -		return;
> +		export_errno =3D EINVAL;
> +		return rc;
>  	}
> =20
>  	if ((htype =3D client_gettype(hname)) =3D=3D MCL_FQDN) {
> @@ -397,9 +411,11 @@ unexportfs(char *arg, int verbose)
>  #endif
>  		exp->m_xtabent =3D 0;
>  		exp->m_mayexport =3D 0;
> +		rc =3D 1;
>  	}
> =20
>  	freeaddrinfo(ai);
> +	return rc;
>  }
> =20
>  static int can_test(void)
> @@ -728,6 +744,7 @@ error(nfs_export *exp, int err)
>  {
>  	xlog(L_ERROR, "%s:%s: %s", exp->m_client->m_hostname,
>  		exp->m_export.e_path, strerror(err));
> +	export_errno =3D (export_errno) ? export_errno : err;
>  }
> =20
>  static void

This seems the have been forgotten, so maybe by replying to it someone will
notice (hi Steve).

Though I agree with the need for the patch, I don't much like it's shape.

Why change exportfs and unexportfs to return a status?  The status is only
used to set export_errno, and they sometimes set export_errno anyway, so why
not leave them returning  void and just setting export_errno as needed?


My preference is actually to get 'xlog' to set export_errno.

See below.

Thanks,
NeilBrown



=46rom 2f63d6c3c38e673216a3351aff47d32059056638 Mon Sep 17 00:00:00 2001
From: Neil Brown <neilb@suse.de>
Date: Mon, 21 Oct 2013 17:40:55 +1100
Subject: [PATCH] exportfs: exit with error code if there was any error.

exportfs currently exits with a non-zero error for some errors,
but not for others.

It does this by having various support routines set the global
variable "export_errno".

Change this to have 'xlog' set export_errno if an ERROR is
reported.  That way all errors will be caught.

Note that the exit error code is changed from 22 (EINVAL)
to the more traditional '1'.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 1fbf754..97b2327 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -179,7 +179,4 @@ struct export_features {
 struct export_features *get_export_features(void);
 void fix_pseudoflavor_flags(struct exportent *ep);
=20
-/* Record export error.  */
-extern int export_errno;
-
 #endif /* EXPORTFS_H */
diff --git a/support/include/xlog.h b/support/include/xlog.h
index fd1a3f4..fd34ec2 100644
--- a/support/include/xlog.h
+++ b/support/include/xlog.h
@@ -35,6 +35,7 @@ struct xlog_debugfac {
 	int		df_fac;
 };
=20
+extern int export_errno;
 void			xlog_open(char *progname);
 void			xlog_stderr(int on);
 void			xlog_syslog(int on);
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index d3160d3..d18667f 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -47,8 +47,6 @@ struct flav_info flav_map[] =3D {
=20
 const int flav_map_size =3D sizeof(flav_map)/sizeof(flav_map[0]);
=20
-int export_errno;
-
 static char	*efname =3D NULL;
 static XFILE	*efp =3D NULL;
 static int	first;
@@ -133,7 +131,6 @@ getexportent(int fromkernel, int fromexports)
 	}
 	if (ok < 0) {
 		xlog(L_ERROR, "expected client(options...)");
-		export_errno =3D EINVAL;
 		return NULL;
 	}
 	first =3D 0;
@@ -153,7 +150,6 @@ getexportent(int fromkernel, int fromexports)
 		ok =3D getexport(exp, sizeof(exp));
 		if (ok < 0) {
 			xlog(L_ERROR, "expected client(options...)");
-			export_errno =3D EINVAL;
 			return NULL;
 		}
 	}
@@ -173,7 +169,6 @@ getexportent(int fromkernel, int fromexports)
 		*opt++ =3D '\0';
 		if (!(sp =3D strchr(opt, ')')) || sp[1] !=3D '\0') {
 			syntaxerr("bad option list");
-			export_errno =3D EINVAL;
 			return NULL;
 		}
 		*sp =3D '\0';
@@ -590,7 +585,6 @@ parseopts(char *cp, struct exportent *ep, int warn, int=
 *had_subtree_opt_ptr)
 				     flname, flline, opt);=09
 bad_option:
 				free(opt);
-				export_errno =3D EINVAL;
 				return -1;
 			}
 		} else if (strncmp(opt, "anongid=3D", 8) =3D=3D 0) {
diff --git a/support/nfs/xlog.c b/support/nfs/xlog.c
index 6820346..9f9e63e 100644
--- a/support/nfs/xlog.c
+++ b/support/nfs/xlog.c
@@ -38,6 +38,8 @@ static int  logmask =3D 0;		/* What will be logged		*/
 static char log_name[256];		/* name of this program		*/
 static int  log_pid =3D -1;		/* PID of this program		*/
=20
+int export_errno =3D 0;
+
 static void	xlog_toggle(int sig);
 static struct xlog_debugfac	debugnames[] =3D {
 	{ "general",	D_GENERAL, },
@@ -189,6 +191,8 @@ void
 xlog(int kind, const char* fmt, ...)
 {
 	va_list args;
+	if (kind & (L_ERROR|D_GENERAL))
+		export_errno =3D 1;
=20
 	va_start(args, fmt);
 	xlog_backend(kind, fmt, args);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 4331697..c2cb2fc 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -103,8 +103,6 @@ main(int argc, char **argv)
 	xlog_stderr(1);
 	xlog_syslog(0);
=20
-	export_errno =3D 0;
-
 	while ((c =3D getopt(argc, argv, "afhio:ruv")) !=3D EOF) {
 		switch(c) {
 		case 'a':

--Sig_/NKgq0.hlSTdRbrq.TT8rvVR
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUmWpzznsnt1WYoG5AQI3HhAAhWICEllV8Zs4lcL8/c6Z36IFzrWMdS3P
AaBt0FqqNYI8xU0jO+MVcd8F02fzC6O6rI1fqWD/N/WZYQpYV0EFSeuUT+RfPKtK
KUaf4bS1R+K4VUWPkBoBuDGf93CizEvZS4P34iVL5hg9m5iqgyLXR9yDk6L9Ehx2
P1xd6CjsiI7X/WDxrfeGcIXiWW7HyFufrTWDUqJd9i0XpIG+TWuHjjnP+bWMGhEW
y1CX+6Edtgo2LbZldSKVQlMGVwBQPWoeK1XwH7h/ZT6GDw2PH3/+a6ZW8oAPhcFT
4SL5PYAbyhaClvyP1F310TVHSzjidFkwe778UNS+JHB/Ii7G2KP5uCcckXeGnChM
+eGoB0qbtmrJ+t+xtExI3Ii2UG/0K8zl30v9d9sF9a2MgTk/IYHl1hFOGIJFoNQC
U1kXRw1OjNPFD60Bru0M3MYggLMcI2+SYTuWtEsoY/RaReoL9zvXcdaZBTWhB+v5
IjZNS0UTf/LwxOwTsLOGVOUjLXfQNu1R6IpWQDnasbhjjM4A262L2VCPLJXPwywv
0zONpWtsQ1gRHsc4TKg6RYj/anLa1QhLZrEZfhGR9CVW6MYRlziaqzBXaPY1230h
QbsHNDBbEIarR07clmdmkV/bceT7D151glhMVQe70O5VnpNnWcaSNITBHgv/O6fy
x/VwcNGk5o0=
=gdLK
-----END PGP SIGNATURE-----

--Sig_/NKgq0.hlSTdRbrq.TT8rvVR--
