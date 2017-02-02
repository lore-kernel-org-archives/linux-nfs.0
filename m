Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:58043 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750842AbdBBFke (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Feb 2017 00:40:34 -0500
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>, steved@redhat.com
Date: Thu, 02 Feb 2017 16:39:52 +1100
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v2 2/2] mountd/exportfs: implement the -s/--state-directory-path option
In-Reply-To: <1485962369-25852-3-git-send-email-smayhew@redhat.com>
References: <1485962369-25852-1-git-send-email-smayhew@redhat.com> <1485962369-25852-3-git-send-email-smayhew@redhat.com>
Message-ID: <87bmulxiaf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 01 2017, Scott Mayhew wrote:

> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> ---
>  support/export/xtab.c     | 82 +++++++++++++++++++++++++++++++++++++++++=
++++--
>  support/include/nfslib.h  | 17 ++++++++++
>  support/nfs/cacheio.c     |  4 ++-
>  support/nfs/rmtab.c       |  4 ++-
>  utils/exportfs/exportfs.c | 13 ++++++++
>  utils/mountd/auth.c       |  8 +++--
>  utils/mountd/mountd.c     | 31 +++++++++++-------
>  utils/mountd/mountd.man   |  2 +-
>  utils/mountd/rmtab.c      | 26 ++++++++-------
>  9 files changed, 156 insertions(+), 31 deletions(-)
>
> diff --git a/support/export/xtab.c b/support/export/xtab.c
> index 22cf539..a5bfa6e 100644
> --- a/support/export/xtab.c
> +++ b/support/export/xtab.c
> @@ -14,12 +14,20 @@
>  #include <unistd.h>
>  #include <stdlib.h>
>  #include <string.h>
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +#include <errno.h>
> +#include <libgen.h>
>=20=20
>  #include "nfslib.h"
>  #include "exportfs.h"
>  #include "xio.h"
>  #include "xlog.h"
>  #include "v4root.h"
> +#include "misc.h"
> +
> +static char state_base_dirname[PATH_MAX] =3D NFS_STATEDIR;
> +extern struct state_paths etab;
>=20=20
>  int v4root_needed;
>  static void cond_rename(char *newfile, char *oldfile);
> @@ -65,7 +73,7 @@ xtab_read(char *xtab, char *lockfn, int is_export)
>  int
>  xtab_export_read(void)
>  {
> -	return xtab_read(_PATH_ETAB, _PATH_ETABLCK, 1);
> +	return xtab_read(etab.statefn, etab.lockfn, 1);
>  }
>=20=20
>  /*
> @@ -112,7 +120,7 @@ xtab_write(char *xtab, char *xtabtmp, char *lockfn, i=
nt is_export)
>  int
>  xtab_export_write()
>  {
> -	return xtab_write(_PATH_ETAB, _PATH_ETABTMP, _PATH_ETABLCK, 1);
> +	return xtab_write(etab.statefn, etab.tmpfn, etab.lockfn, 1);
>  }
>=20=20
>  /*
> @@ -158,3 +166,73 @@ static void cond_rename(char *newfile, char *oldfile)
>  	rename(newfile, oldfile);
>  	return;
>  }
> +
> +/*
> + * Returns a dynamically allocated, '\0'-terminated buffer
> + * containing an appropriate pathname, or NULL if an error
> + * occurs.  Caller must free the returned result with free(3).
> + */
> +static char *
> +state_make_pathname(const char *tabname)
> +{
> +	return generic_make_pathname(state_base_dirname, tabname);
> +}
> +
> +/**
> + * state_setup_basedir - set up basedir
> + * @progname: C string containing name of program, for error messages
> + * @parentdir: C string containing pathname to on-disk state, or NULL
> + *
> + * This runs before logging is set up, so error messages are directed
> + * to stderr.
> + *
> + * Returns true and sets up our basedir, if @parentdir was valid
> + * and usable; otherwise false is returned.
> + */
> +_Bool
> +state_setup_basedir(const char *progname, const char *parentdir)
> +{
> +	return generic_setup_basedir(progname, parentdir, state_base_dirname);
> +}
> +
> +int
> +setup_state_path_names(const char *progname, const char *statefn,
> +		      const char *tmpfn, const char *lockfn,
> +		      struct state_paths *paths)
> +{
> +	paths->statefn =3D state_make_pathname(statefn);
> +	if (!paths->statefn) {
> +		fprintf(stderr, "%s: state_make_pathname(%s) failed\n",
> +			progname, statefn);
> +		goto out_err;
> +	}
> +	paths->tmpfn =3D state_make_pathname(tmpfn);
> +	if (!paths->tmpfn) {
> +		fprintf(stderr, "%s: state_make_pathname(%s) failed\n",
> +			progname, tmpfn);
> +		goto out_free_statefn;
> +	}
> +	paths->lockfn =3D state_make_pathname(lockfn);
> +	if (!paths->lockfn) {
> +		fprintf(stderr, "%s: state_make_pathname(%s) failed\n",
> +			progname, lockfn);
> +		goto out_free_tmpfn;
> +	}
> +	return 1;
> +
> +out_free_tmpfn:
> +	free(paths->tmpfn);
> +out_free_statefn:
> +	free(paths->statefn);
> +out_err:
> +	return 0;
> +
> +}
> +
> +void
> +free_state_path_names(struct state_paths *paths)
> +{
> +	free(paths->statefn);
> +	free(paths->tmpfn);
> +	free(paths->lockfn);
> +}
> diff --git a/support/include/nfslib.h b/support/include/nfslib.h
> index 1498977..adcbe43 100644
> --- a/support/include/nfslib.h
> +++ b/support/include/nfslib.h
> @@ -58,6 +58,19 @@
>  #define	_PATH_PROC_EXPORTS_ALT	"/proc/fs/nfsd/exports"
>  #endif
>=20=20
> +#define ETAB		"etab"
> +#define ETABTMP		"etab.tmp"
> +#define ETABLCK 	".etab.lock"
> +#define RMTAB		"rmtab"
> +#define RMTABTMP	"rmtab.tmp"
> +#define RMTABLCK	".rmtab.lock"

I would be happier if you completed removed _PATH_ETAB* and _PATH_RMTAB*
as well.  I don't think they are used any more, but they are still
defined (and mentioned in at least one comment).


> +
> +struct state_paths {
> +	char *statefn;
> +	char *tmpfn;
> +	char *lockfn;
> +};
> +
>  /* Maximum number of security flavors on an export: */
>  #define SECFLAVOR_COUNT 8
>=20=20
> @@ -120,6 +133,10 @@ void			fputrmtabent(FILE *fp, struct rmtabent *xep, =
long *pos);
>  void			fendrmtabent(FILE *fp);
>  void			frewindrmtabent(FILE *fp);
>=20=20
> +_Bool state_setup_basedir(const char *, const char *);
> +int setup_state_path_names(const char *, const char *, const char *, con=
st char *, struct state_paths *);
> +void free_state_path_names(struct state_paths *);
> +
>  /* mydaemon */
>  void daemon_init(bool fg);
>  void daemon_ready(void);
> diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
> index e5e2579..885a4bb 100644
> --- a/support/nfs/cacheio.c
> +++ b/support/nfs/cacheio.c
> @@ -27,6 +27,8 @@
>  #include <time.h>
>  #include <errno.h>
>=20=20
> +extern struct state_paths etab;
> +
>  void qword_add(char **bpp, int *lp, char *str)
>  {
>  	char *bp =3D *bpp;
> @@ -228,7 +230,7 @@ cache_flush(int force)
>  	};
>  	now =3D time(0);
>  	if (force ||
> -	    stat(_PATH_ETAB, &stb) !=3D 0 ||
> +	    stat(etab.statefn, &stb) !=3D 0 ||
>  	    stb.st_mtime > now)
>  		stb.st_mtime =3D time(0);
>=20=20=09
> diff --git a/support/nfs/rmtab.c b/support/nfs/rmtab.c
> index 59dfbdf..2ecb2cc 100644
> --- a/support/nfs/rmtab.c
> +++ b/support/nfs/rmtab.c
> @@ -33,12 +33,14 @@
>=20=20
>  static FILE	*rmfp =3D NULL;
>=20=20
> +extern struct state_paths rmtab;
> +
>  int
>  setrmtabent(char *type)
>  {
>  	if (rmfp)
>  		fclose(rmfp);
> -	rmfp =3D fsetrmtabent(_PATH_RMTAB, type);
> +	rmfp =3D fsetrmtabent(rmtab.statefn, type);
>  	return (rmfp !=3D NULL);
>  }
>=20=20
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 61dddfb..02d5b6d 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -52,6 +52,8 @@ static const char *lockfile =3D EXP_LOCKFILE;
>  static int _lockfd =3D -1;
>  char *conf_path =3D NFS_CONFFILE;
>=20=20
> +struct state_paths etab;
> +
>  /*
>   * If we aren't careful, changes made by exportfs can be lost
>   * when multiple exports process run at once:
> @@ -95,6 +97,7 @@ main(int argc, char **argv)
>  	int	f_ignore =3D 0;
>  	int	i, c;
>  	int	force_flush =3D 0;
> +	char	*s;
>=20=20
>  	if ((progname =3D strrchr(argv[0], '/')) !=3D NULL)
>  		progname++;
> @@ -108,6 +111,11 @@ main(int argc, char **argv)
>  	conf_init();
>  	xlog_from_conffile("exportfs");
>=20=20
> +	/* NOTE: following uses "mountd" section of nfs.conf !!!! */
> +	s =3D conf_get_str("mountd", "state-directory-path");
> +	if (s && !state_setup_basedir(argv[0], s))
> +		exit(1);
> +

Could you add to the systemd/nfs.conf.man man page, in the
 .TP
 .B mountd
 Recognized values:

section, that "state-directory-path" is also used by exportfs
(much like the 'nfsd' section mentions that some values are also used by
rpc.mountd).
Also the exportfs.man page should get a small ".SH CONFIGURATION FILE"
section.

With those issues resolved,
  Reviewed-by: NeilBrown <neilb@suse.com>

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliSxigACgkQOeye3VZi
gble0A//QwkKrOF+l7CZaX2RPlAdkM8/9Jv1YUj5hWWumWAoPOXWMZsXfrfqvZJa
IEE8onTzTRUp4t0i0IAgTdElHyEmEkn/QsZzwUS0RR7PkW3U+210f8nwA37qQHBW
S44NJ2aoqSivAPO3q6P55s5wS4OUQrDieo/k+vtDSJbVMKJPt6Z1wOfbYPX0/5MG
axRXtFPuwTSjmcUIB4FTLxrnJDnbos0gpm1TXnaWd3r6+bmnr7KiYR68b+V5hKlB
RKzXvs9UkjvKDJ8DVBOZ6rkVZk1wAGHXgsw/TkgpEUf3qY2xJyc76zHu8Z4P0xgw
iCk1gNw2BoMgW97Jeb2qDTBY3e5MSDt3oaJ3N+dl5EMgz0G1vvBDTx/LTYGlk28V
8JUQRYXf4TVHIW6GU4814jabqcCIVB1DPva2dpkeWW7f4O1GGTZxKnIMeiu0MQoT
U4jA/tNN/L4rZL2bgmdHizPMHaWJnZtpfm6rzdaPSguqLFE6TqpxedS9IxTFeCFz
wgSouwgPWuDoAND2uZ6Tjm5XUSTQ/QHgkmgixMFLnCVAIN8mKsVwLG4ahn620s5S
eehkIwMt3GEaHjN0t3a+zIFNlLTYyr4Nb7y/TJeoHKxsrVsbQBE2JyefGHyCepea
77i79rA8dB/veLuINhE76vH9Cyun73kOP9GmFMoV+KsbrrloB8U=
=4rrB
-----END PGP SIGNATURE-----
--=-=-=--
