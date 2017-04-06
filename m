Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44898 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751596AbdDFFfU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Apr 2017 01:35:20 -0400
From: NeilBrown <neilb@suse.com>
To: Scott Mayhew <smayhew@redhat.com>, steved@redhat.com
Date: Thu, 06 Apr 2017 15:34:40 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v2 4/4] systemd: add a generator for the rpc_pipefs mountpoint
In-Reply-To: <20170405211243.12282-5-smayhew@redhat.com>
References: <20170405211243.12282-1-smayhew@redhat.com> <20170405211243.12282-5-smayhew@redhat.com>
Message-ID: <87d1cq14lr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 05 2017, Scott Mayhew wrote:

> The nfs.conf has config options for the rpc_pipefs mountpoint.
> Currently, changing these from the default also requires manually
> overriding the systemd unit files that are hard-coded to mount the
> filesystem on /var/lib/nfs/rpc_pipefs.
>
> This patch adds a generator that creates a mount unit file for the
> rpc_pipefs when a non-default value is specified in /etc/nfs.conf, as
> well as a target unit file to override the dependencies for the systemd
> units using the rpc_pipefs.  The blkmapd, idmapd, and gssd service unit
> files have been modified to define their dependencies on the rpc_pipefs
> mountpoint indirectly via the rpc_pipefs target unit file.
>
> This patch also removes the dependency on the rpc_pipefs from the
> rpc-svcgssd.service unit file.  rpc.svcgssd uses the sunrpc cache
> mechanism to exchange data with the kernel, not the rpc_pipefs.
>
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>

I was reading through this, which I really thought would be a good patch
that I would give an Ack to, and looking at some of the detail involved,
I started to wonder if we were really doing the right thing here.
You go to some trouble to make the name of the .mount unit file match
the name of the location of the mountpoint.  Is that really necessary?

Unit files created by systemd-fstab-generator do follow that pattern,
but they don't have to.

Maybe we should just:

1/ rename var-lib-nfs-rpc_pipefs.mount to rpc_pipefs.mount,
   and modify the dependencies accordingly.

2/ write a generator which (if necessary) creates a drop-in for
   rpc_pipefs.mount which simply overrides "Where".

 i.e /run/systemd/generator/rpc_pipefs.mount.d/pipefs.conf
 would contain

    [Mount]
    Where=3D/foo/bar

I'm sorry to discard your good work, but I now think that a lot of it is
unnecessary.  Sorry for not seeing that earlier.

Thanks,
NeilBrown


> ---
>  .gitignore                     |   1 +
>  systemd/Makefile.am            |   5 +-
>  systemd/nfs-blkmap.service     |   4 +-
>  systemd/nfs-idmapd.service     |   4 +-
>  systemd/rpc-gssd.service.in    |   4 +-
>  systemd/rpc-pipefs-generator.c | 216 +++++++++++++++++++++++++++++++++++=
++++++
>  systemd/rpc-svcgssd.service    |   3 +-
>  systemd/rpc_pipefs.target      |   3 +
>  8 files changed, 231 insertions(+), 9 deletions(-)
>  create mode 100644 systemd/rpc-pipefs-generator.c
>  create mode 100644 systemd/rpc_pipefs.target
>
> diff --git a/.gitignore b/.gitignore
> index 126d12c..941aca0 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -70,6 +70,7 @@ tests/nsm_client/nlm_sm_inter_svc.c
>  tests/nsm_client/nlm_sm_inter_xdr.c
>  utils/nfsidmap/nfsidmap
>  systemd/nfs-server-generator
> +systemd/rpc-pipefs-generator
>  systemd/nfs-config.service
>  systemd/rpc-gssd.service
>  # cscope database files
> diff --git a/systemd/Makefile.am b/systemd/Makefile.am
> index 0d15b9f..4becb77 100644
> --- a/systemd/Makefile.am
> +++ b/systemd/Makefile.am
> @@ -4,6 +4,7 @@ MAINTAINERCLEANFILES =3D Makefile.in
>=20=20
>  unit_files =3D  \
>      nfs-client.target \
> +    rpc_pipefs.target \
>      \
>      nfs-mountd.service \
>      nfs-server.service \
> @@ -42,12 +43,14 @@ EXTRA_DIST =3D $(unit_files) $(man5_MANS) $(man7_MANS)
>  unit_dir =3D /usr/lib/systemd/system
>  generator_dir =3D /usr/lib/systemd/system-generators
>=20=20
> -EXTRA_PROGRAMS	=3D nfs-server-generator
> +EXTRA_PROGRAMS	=3D nfs-server-generator rpc-pipefs-generator
>  genexecdir =3D $(generator_dir)
>  nfs_server_generator_LDADD =3D ../support/export/libexport.a \
>  			     ../support/nfs/libnfs.a \
>  			     ../support/misc/libmisc.a
>=20=20
> +rpc_pipefs_generator_LDADD =3D ../support/nfs/libnfs.a
> +
>  if INSTALL_SYSTEMD
>  genexec_PROGRAMS =3D nfs-server-generator
>  install-data-hook: $(unit_files)
> diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> index ddc324e..2bbcee6 100644
> --- a/systemd/nfs-blkmap.service
> +++ b/systemd/nfs-blkmap.service
> @@ -2,8 +2,8 @@
>  Description=3DpNFS block layout mapping daemon
>  DefaultDependencies=3Dno
>  Conflicts=3Dumount.target
> -After=3Dvar-lib-nfs-rpc_pipefs.mount
> -Requires=3Dvar-lib-nfs-rpc_pipefs.mount
> +After=3Drpc_pipefs.target
> +Requires=3Drpc_pipefs.target
>=20=20
>  PartOf=3Dnfs-utils.service
>=20=20
> diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> index acca86b..f38fe52 100644
> --- a/systemd/nfs-idmapd.service
> +++ b/systemd/nfs-idmapd.service
> @@ -1,8 +1,8 @@
>  [Unit]
>  Description=3DNFSv4 ID-name mapping service
>  DefaultDependencies=3Dno
> -Requires=3Dvar-lib-nfs-rpc_pipefs.mount
> -After=3Dvar-lib-nfs-rpc_pipefs.mount local-fs.target
> +Requires=3Drpc_pipefs.target
> +After=3Drpc_pipefs.target local-fs.target
>=20=20
>  BindsTo=3Dnfs-server.service
>=20=20
> diff --git a/systemd/rpc-gssd.service.in b/systemd/rpc-gssd.service.in
> index b353027..6807db3 100644
> --- a/systemd/rpc-gssd.service.in
> +++ b/systemd/rpc-gssd.service.in
> @@ -2,8 +2,8 @@
>  Description=3DRPC security service for NFS client and server
>  DefaultDependencies=3Dno
>  Conflicts=3Dumount.target
> -Requires=3Dvar-lib-nfs-rpc_pipefs.mount
> -After=3Dvar-lib-nfs-rpc_pipefs.mount
> +Requires=3Drpc_pipefs.target
> +After=3Drpc_pipefs.target
>=20=20
>  ConditionPathExists=3D@_sysconfdir@/krb5.keytab
>=20=20
> diff --git a/systemd/rpc-pipefs-generator.c b/systemd/rpc-pipefs-generato=
r.c
> new file mode 100644
> index 0000000..b0a6c19
> --- /dev/null
> +++ b/systemd/rpc-pipefs-generator.c
> @@ -0,0 +1,216 @@
> +/*
> + * rpc-pipefs-generator:
> + *   systemd generator to create ordering dependencies between
> + *   nfs services and the rpc_pipefs mountpoint
> + */
> +
> +#ifdef HAVE_CONFIG_H
> +#include <config.h>
> +#endif
> +
> +#include <sys/stat.h>
> +#include <sys/types.h>
> +#include <unistd.h>
> +#include <stdlib.h>
> +#include <string.h>
> +#include <ctype.h>
> +#include <stdio.h>
> +#include <mntent.h>
> +
> +#include "nfslib.h"
> +#include "conffile.h"
> +
> +#define RPC_PIPEFS_DEFAULT "/var/lib/nfs/rpc_pipefs"
> +char *conf_path =3D NFS_CONFFILE;
> +
> +int systemd_len(char *path)
> +{
> +	char *p;
> +	int len =3D 0;
> +
> +	p =3D path;
> +	while (*p =3D=3D '/')
> +		p++;
> +
> +	if (!*p)
> +		/* "/" becomes "-", otherwise leading "/" is ignored */
> +		return 1;
> +
> +	while (*p) {
> +		unsigned char c =3D *p++;
> +
> +		if (c =3D=3D '/') {
> +			/* multiple non-trailing slashes become '-' */
> +			while (*p =3D=3D '/')
> +				p++;
> +			if (*p)
> +				len++;
> +		} else if (isalnum(c) || c =3D=3D ':' || c =3D=3D '.' || c =3D=3D '_')
> +			len++;
> +		else {
> +			len +=3D 4;
> +		}
> +	}
> +
> +	return len;
> +}
> +
> +char *systemd_escape(char *path)
> +{
> +	char *result =3D NULL;
> +	char *p;
> +	int len;
> +
> +	len =3D systemd_len(path);
> +	if (!len)
> +		goto out;
> +
> +	result =3D malloc(len + strlen(".mount") + 1);
> +	if (!result)
> +		goto out;
> +
> +	p =3D result;
> +	while (*path =3D=3D '/')
> +		path++;
> +	if (!*path) {
> +		/* "/" becomes "-", otherwise leading "/" is ignored */
> +		*p++ =3D '-';
> +		goto out_append;
> +	}
> +	while (*path) {
> +		unsigned char c =3D *path++;
> +
> +		if (c =3D=3D '/') {
> +			/* multiple non-trailing slashes become '-' */
> +			while (*path =3D=3D '/')
> +				path++;
> +			if (*path)
> +				*p++ =3D '-';
> +		} else if (isalnum(c) || c =3D=3D ':' || c =3D=3D '.' || c =3D=3D '_')
> +			*p++ =3D c;
> +		else {
> +			*p++ =3D '\\';
> +			*p++ =3D 'x';
> +			*p++ =3D '0' + ((c&0xf0)>>4) + (c>=3D0xa0)*('a'-'9'-1);
> +			*p++ =3D '0' + (c&0x0f) + ((c&0x0f)>=3D0x0a)*('a'-'9'-1);
> +		}
> +	}
> +
> +out_append:
> +	sprintf(p, ".mount");
> +out:
> +	return result;
> +}
> +
> +static int generate_mount_unit(const char *pipefs_path, const char *pipe=
fs_unit,
> +			       const char *dirname)
> +{
> +	char	*path;
> +	FILE	*f;
> +
> +	path =3D malloc(strlen(dirname) + 1 + strlen(pipefs_unit));
> +	if (!path)
> +		return 1;
> +	sprintf(path, "%s/%s", dirname, pipefs_unit);
> +	f =3D fopen(path, "w");
> +	if (!f)
> +		return 1;
> +
> +	fprintf(f, "# Automatically generated by rpc-pipefs-generator\n\n[Unit]=
\n");
> +	fprintf(f, "Description=3DRPC Pipe File System\n");
> +	fprintf(f, "DefaultDependencies=3Dno\n");
> +	fprintf(f, "After=3Dsystemd-tmpfiles-setup.service\n");
> +	fprintf(f, "Conflicts=3Dumount.target\n");
> +	fprintf(f, "\n[Mount]\n");
> +	fprintf(f, "What=3Dsunrpc\n");
> +	fprintf(f, "Where=3D%s\n", pipefs_path);
> +	fprintf(f, "Type=3Drpc_pipefs\n");
> +
> +	fclose(f);
> +	return 0;
> +}
> +
> +static
> +int generate_target(char *pipefs_path, const char *dirname)
> +{
> +	char	*path;
> +	char	filebase[] =3D "/rpc_pipefs.target";
> +	char	*pipefs_unit;
> +	FILE	*f;
> +	int 	ret =3D 0;
> +
> +	pipefs_unit =3D systemd_escape(pipefs_path);
> +	if (!pipefs_unit)
> +		return 1;
> +
> +	ret =3D generate_mount_unit(pipefs_path, pipefs_unit, dirname);
> +	if (ret)
> +		return ret;
> +
> +	path =3D malloc(strlen(dirname) + 1 + sizeof(filebase));
> +	if (!path)
> +		return 2;
> +	sprintf(path, "%s", dirname);
> +	mkdir(path, 0755);
> +	strcat(path, filebase);
> +	f =3D fopen(path, "w");
> +	if (!f)
> +		return 1;
> +
> +	fprintf(f, "# Automatically generated by rpc-pipefs-generator\n\n[Unit]=
\n");
> +	fprintf(f, "Requires=3D%s\n", pipefs_unit);
> +	fprintf(f, "After=3D%s\n", pipefs_unit);
> +	fclose(f);
> +
> +	return 0;
> +}
> +
> +static int is_non_pipefs_mountpoint(char *path)
> +{
> +	FILE		*mtab;
> +	struct mntent	*mnt;
> +
> +	mtab =3D setmntent("/etc/mtab", "r");
> +	if (!mtab)
> +		return 0;
> +
> +	while ((mnt =3D getmntent(mtab)) !=3D NULL) {
> +		if (strlen(mnt->mnt_dir) !=3D strlen(path))
> +			continue;
> +		if (strncmp(mnt->mnt_dir, path, strlen(mnt->mnt_dir)))
> +			continue;
> +		if (strncmp(mnt->mnt_type, "rpc_pipefs", strlen(mnt->mnt_type)))
> +			break;
> +	}
> +	fclose(mtab);
> +	return mnt !=3D NULL;
> +}
> +
> +int main(int argc, char *argv[])
> +{
> +	int 	ret;
> +	char	*s;
> +
> +	/* Avoid using any external services */
> +	xlog_syslog(0);
> +
> +	if (argc !=3D 4 || argv[1][0] !=3D '/') {
> +		fprintf(stderr, "rpc-pipefs-generator: create systemd dependencies for=
 nfs services\n");
> +		fprintf(stderr, "Usage: normal-dir early-dir late-dir\n");
> +		exit(1);
> +	}
> +
> +	conf_init();
> +	s =3D conf_get_str("global", "pipefs-directory");
> +	if (!s)
> +		exit(0);
> +	if (strlen(s) =3D=3D strlen(RPC_PIPEFS_DEFAULT) &&
> +			strcmp(s, RPC_PIPEFS_DEFAULT) =3D=3D 0)
> +		exit(0);
> +
> +	if (is_non_pipefs_mountpoint(s))
> +		exit(1);
> +
> +	ret =3D generate_target(s, argv[1]);
> +	exit(ret);
> +}
> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> index 7187e3c..cb2bcd4 100644
> --- a/systemd/rpc-svcgssd.service
> +++ b/systemd/rpc-svcgssd.service
> @@ -1,8 +1,7 @@
>  [Unit]
>  Description=3DRPC security service for NFS server
>  DefaultDependencies=3Dno
> -Requires=3Dvar-lib-nfs-rpc_pipefs.mount
> -After=3Dvar-lib-nfs-rpc_pipefs.mount local-fs.target
> +After=3Dlocal-fs.target
>  PartOf=3Dnfs-server.service
>  PartOf=3Dnfs-utils.service
>=20=20
> diff --git a/systemd/rpc_pipefs.target b/systemd/rpc_pipefs.target
> new file mode 100644
> index 0000000..01d4d27
> --- /dev/null
> +++ b/systemd/rpc_pipefs.target
> @@ -0,0 +1,3 @@
> +[Unit]
> +Requires=3Dvar-lib-nfs-rpc_pipefs.mount
> +After=3Dvar-lib-nfs-rpc_pipefs.mount
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

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljl03AACgkQOeye3VZi
gbmgLg/+LYidI1TlGQNy0xk7jpl8QukRze8LWywMvlFTgixFzAJU6PeVInR49N0M
s88lV798jCn1ShbyZwffNmMkdHc6ONcXc8IdIF7txnkbWlOyNUlcIVvrwQxYZTL0
xM0fy8zKric1jtAr1659ZrlGXzq3HTHA+CNPJtcjKvEg0oeh7GTQ/Mwqzc/NjEnC
gj1FZfTYvQOaiQryLETkkq06IMccbZfdKRqf9BangnKn4MUR7o/pUH/eiTw7zXoz
XGFDlT4j2uqPPtUT+AvAPnC7tcDpJ8a93AVISOrtuLP+onb6pJBhZVOwrvP7z/4/
wQ8b8OMDUDV58FTOhWRQi6By/mWHRgubmnd1au07Om57El093/VccWJHg7wwAhjh
eeDyiM7CVXIbWR1ADfLLheD40mf6PqlqkC5ob4H7HdKN0oi5rakY7aNP+HEX4B1p
8yYTCozyIsGxHHGXN5wci0kG+cMBTT4Qf4uGZ0TJj045yROzr+NSKi+GGiOJOuSX
RPBbekdHjRN11B3VKI14n4HBaB/n2mN1kr00LROleCfYvqSfISCt940N73Q/woy1
5Kvkw1OOoHws3gqFAgrFaNpsKZoUXw9JUOjxVkek/gZBttBT7yj75BJmvDQQACKP
muRNA+i88MTNOQVMtbsPEO3PF9dfxrLev7yt4fN0UeWe3qT2XVM=
=kYwh
-----END PGP SIGNATURE-----
--=-=-=--
