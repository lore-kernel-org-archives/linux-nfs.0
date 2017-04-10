Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37778 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752760AbdDJNfu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Apr 2017 09:35:50 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E24E0C04B93D
        for <linux-nfs@vger.kernel.org>; Mon, 10 Apr 2017 13:35:49 +0000 (UTC)
Subject: Re: [nfs-utils PATCH v4] systemd: add a generator for the rpc_pipefs
 mountpoint
To: Scott Mayhew <smayhew@redhat.com>
References: <ce6f6789-e0ae-e43b-4540-b8a58e3c8649@RedHat.com>
 <20170407170216.22223-1-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <a11639c6-b8a2-bc88-c852-115e35d744fe@RedHat.com>
Date: Mon, 10 Apr 2017 09:35:45 -0400
MIME-Version: 1.0
In-Reply-To: <20170407170216.22223-1-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/07/2017 01:02 PM, Scott Mayhew wrote:
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
> mountpoint indirectly via the rpc_pipefs target unit file.  Since both
> rpc-pipefs-generator.c and nfs-server-generator.c need to convert path
> names to unit file names, that functionality has been moved to
> systemd.c.
> 
> This patch also removes the dependency on the rpc_pipefs from the
> rpc-svcgssd.service unit file.  rpc.svcgssd uses the sunrpc cache
> mechanism to exchange data with the kernel, not the rpc_pipefs.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed with a couple corrections... 

steved.
> ---
>  .gitignore                     |   1 +
>  systemd/Makefile.am            |  14 ++++-
>  systemd/nfs-blkmap.service     |   4 +-
>  systemd/nfs-idmapd.service     |   4 +-
>  systemd/nfs-server-generator.c |  33 +---------
>  systemd/rpc-gssd.service.in    |   4 +-
>  systemd/rpc-pipefs-generator.c | 138 +++++++++++++++++++++++++++++++++++++++++
>  systemd/rpc-svcgssd.service    |   3 +-
>  systemd/rpc_pipefs.target      |   3 +
>  systemd/systemd.c              | 133 +++++++++++++++++++++++++++++++++++++++
>  systemd/systemd.h              |   6 ++
>  11 files changed, 302 insertions(+), 41 deletions(-)
>  create mode 100644 systemd/rpc-pipefs-generator.c
>  create mode 100644 systemd/rpc_pipefs.target
>  create mode 100644 systemd/systemd.c
>  create mode 100644 systemd/systemd.h
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
> index 0d15b9f..eef53c4 100644
> --- a/systemd/Makefile.am
> +++ b/systemd/Makefile.am
> @@ -4,6 +4,7 @@ MAINTAINERCLEANFILES = Makefile.in
>  
>  unit_files =  \
>      nfs-client.target \
> +    rpc_pipefs.target \
>      \
>      nfs-mountd.service \
>      nfs-server.service \
> @@ -42,14 +43,23 @@ EXTRA_DIST = $(unit_files) $(man5_MANS) $(man7_MANS)
>  unit_dir = /usr/lib/systemd/system
>  generator_dir = /usr/lib/systemd/system-generators
>  
> -EXTRA_PROGRAMS	= nfs-server-generator
> +EXTRA_PROGRAMS	= nfs-server-generator rpc-pipefs-generator
>  genexecdir = $(generator_dir)
> +
> +COMMON_SRCS = systemd.c systemd.h
> +
> +nfs_server_generator_SOURCES = $(COMMON_SRCS) nfs-server-generator.c
> +
> +rpc_pipefs_generator_SOURCES = $(COMMON_SRCS) rpc-pipefs-generator.c
> +
>  nfs_server_generator_LDADD = ../support/export/libexport.a \
>  			     ../support/nfs/libnfs.a \
>  			     ../support/misc/libmisc.a
>  
> +rpc_pipefs_generator_LDADD = ../support/nfs/libnfs.a
> +
>  if INSTALL_SYSTEMD
> -genexec_PROGRAMS = nfs-server-generator
> +genexec_PROGRAMS = nfs-server-generator rpc-pipefs-generator
>  install-data-hook: $(unit_files)
>  	mkdir -p $(DESTDIR)/$(unitdir)
>  	cp $(unit_files) $(DESTDIR)/$(unitdir)
> diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> index ddc324e..2bbcee6 100644
> --- a/systemd/nfs-blkmap.service
> +++ b/systemd/nfs-blkmap.service
> @@ -2,8 +2,8 @@
>  Description=pNFS block layout mapping daemon
>  DefaultDependencies=no
>  Conflicts=umount.target
> -After=var-lib-nfs-rpc_pipefs.mount
> -Requires=var-lib-nfs-rpc_pipefs.mount
> +After=rpc_pipefs.target
> +Requires=rpc_pipefs.target
>  
>  PartOf=nfs-utils.service
>  
> diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> index acca86b..f38fe52 100644
> --- a/systemd/nfs-idmapd.service
> +++ b/systemd/nfs-idmapd.service
> @@ -1,8 +1,8 @@
>  [Unit]
>  Description=NFSv4 ID-name mapping service
>  DefaultDependencies=no
> -Requires=var-lib-nfs-rpc_pipefs.mount
> -After=var-lib-nfs-rpc_pipefs.mount local-fs.target
> +Requires=rpc_pipefs.target
> +After=rpc_pipefs.target local-fs.target
>  
>  BindsTo=nfs-server.service
>  
> diff --git a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
> index 4aa6509..ce3d7fd 100644
> --- a/systemd/nfs-server-generator.c
> +++ b/systemd/nfs-server-generator.c
> @@ -29,6 +29,7 @@
>  #include "misc.h"
>  #include "nfslib.h"
>  #include "exportfs.h"
> +#include "systemd.h"
>  
>  /* A simple "set of strings" to remove duplicates
>   * found in /etc/exports
> @@ -55,35 +56,6 @@ static int is_unique(struct list **lp, char *path)
>  	return 1;
>  }
>  
> -/* We need to convert a path name to a systemd unit
> - * name.  This requires some translation ('/' -> '-')
> - * and some escaping.
> - */
> -static void systemd_escape(FILE *f, char *path)
> -{
> -	while (*path == '/')
> -		path++;
> -	if (!*path) {
> -		/* "/" becomes "-", otherwise leading "/" is ignored */
> -		fputs("-", f);
> -		return;
> -	}
> -	while (*path) {
> -		char c = *path++;
> -
> -		if (c == '/') {
> -			/* multiple non-trailing slashes become '-' */
> -			while (*path == '/')
> -				path++;
> -			if (*path)
> -				fputs("-", f);
> -		} else if (isalnum(c) || c == ':' || c == '.')
> -			fputc(c, f);
> -		else
> -			fprintf(f, "\\x%02x", c & 0xff);
> -	}
> -}
> -
>  static int has_noauto_flag(char *path)
>  {
>  	FILE		*fstab;
> @@ -168,8 +140,7 @@ int main(int argc, char *argv[])
>  		    strcmp(mnt->mnt_type, "nfs4") != 0)
>  			continue;
>  		fprintf(f, "Before= ");
> -		systemd_escape(f, mnt->mnt_dir);
> -		fprintf(f, ".mount\n");
> +		fprintf(f, "%s\n", systemd_escape(mnt->mnt_dir, ".mount"));
>  	}
>  
>  	fclose(fstab);
> diff --git a/systemd/rpc-gssd.service.in b/systemd/rpc-gssd.service.in
> index b353027..6807db3 100644
> --- a/systemd/rpc-gssd.service.in
> +++ b/systemd/rpc-gssd.service.in
> @@ -2,8 +2,8 @@
>  Description=RPC security service for NFS client and server
>  DefaultDependencies=no
>  Conflicts=umount.target
> -Requires=var-lib-nfs-rpc_pipefs.mount
> -After=var-lib-nfs-rpc_pipefs.mount
> +Requires=rpc_pipefs.target
> +After=rpc_pipefs.target
>  
>  ConditionPathExists=@_sysconfdir@/krb5.keytab
>  
> diff --git a/systemd/rpc-pipefs-generator.c b/systemd/rpc-pipefs-generator.c
> new file mode 100644
> index 0000000..66addb9
> --- /dev/null
> +++ b/systemd/rpc-pipefs-generator.c
> @@ -0,0 +1,138 @@
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
> +#include "systemd.h"
> +
> +#define RPC_PIPEFS_DEFAULT "/var/lib/nfs/rpc_pipefs"
> +char *conf_path = NFS_CONFFILE;
> +
> +static int generate_mount_unit(const char *pipefs_path, const char *pipefs_unit,
> +			       const char *dirname)
> +{
> +	char	*path;
> +	FILE	*f;
> +
> +	path = malloc(strlen(dirname) + 1 + strlen(pipefs_unit));
> +	if (!path)
> +		return 1;
> +	sprintf(path, "%s/%s", dirname, pipefs_unit);
> +	f = fopen(path, "w");
> +	if (!f)
> +		return 1;
> +
> +	fprintf(f, "# Automatically generated by rpc-pipefs-generator\n\n[Unit]\n");
> +	fprintf(f, "Description=RPC Pipe File System\n");
> +	fprintf(f, "DefaultDependencies=no\n");
> +	fprintf(f, "After=systemd-tmpfiles-setup.service\n");
> +	fprintf(f, "Conflicts=umount.target\n");
> +	fprintf(f, "\n[Mount]\n");
> +	fprintf(f, "What=sunrpc\n");
> +	fprintf(f, "Where=%s\n", pipefs_path);
> +	fprintf(f, "Type=rpc_pipefs\n");
> +
> +	fclose(f);
> +	return 0;
> +}
> +
> +static
> +int generate_target(char *pipefs_path, const char *dirname)
> +{
> +	char	*path;
> +	char	filebase[] = "/rpc_pipefs.target";
> +	char	*pipefs_unit;
> +	FILE	*f;
> +	int 	ret = 0;
> +
> +	pipefs_unit = systemd_escape(pipefs_path, ".mount");
> +	if (!pipefs_unit)
> +		return 1;
> +
> +	ret = generate_mount_unit(pipefs_path, pipefs_unit, dirname);
> +	if (ret)
> +		return ret;
> +
> +	path = malloc(strlen(dirname) + 1 + sizeof(filebase));
> +	if (!path)
> +		return 2;
> +	sprintf(path, "%s", dirname);
> +	mkdir(path, 0755);
> +	strcat(path, filebase);
> +	f = fopen(path, "w");
> +	if (!f)
> +		return 1;
> +
> +	fprintf(f, "# Automatically generated by rpc-pipefs-generator\n\n[Unit]\n");
> +	fprintf(f, "Requires=%s\n", pipefs_unit);
> +	fprintf(f, "After=%s\n", pipefs_unit);
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
> +	mtab = setmntent("/etc/mtab", "r");
> +	if (!mtab)
> +		return 0;
> +
> +	while ((mnt = getmntent(mtab)) != NULL) {
> +		if (strlen(mnt->mnt_dir) != strlen(path))
> +			continue;
> +		if (strncmp(mnt->mnt_dir, path, strlen(mnt->mnt_dir)))
> +			continue;
> +		if (strncmp(mnt->mnt_type, "rpc_pipefs", strlen(mnt->mnt_type)))
> +			break;
> +	}
> +	fclose(mtab);
> +	return mnt != NULL;
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
> +	if (argc != 4 || argv[1][0] != '/') {
> +		fprintf(stderr, "rpc-pipefs-generator: create systemd dependencies for nfs services\n");
> +		fprintf(stderr, "Usage: normal-dir early-dir late-dir\n");
> +		exit(1);
> +	}
> +
> +	conf_init();
> +	s = conf_get_str("general", "pipefs-directory");
> +	if (!s)
> +		exit(0);
> +	if (strlen(s) == strlen(RPC_PIPEFS_DEFAULT) &&
> +			strcmp(s, RPC_PIPEFS_DEFAULT) == 0)
> +		exit(0);
> +
> +	if (is_non_pipefs_mountpoint(s))
> +		exit(1);
> +
> +	ret = generate_target(s, argv[1]);
> +	exit(ret);
> +}
> diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> index 7187e3c..cb2bcd4 100644
> --- a/systemd/rpc-svcgssd.service
> +++ b/systemd/rpc-svcgssd.service
> @@ -1,8 +1,7 @@
>  [Unit]
>  Description=RPC security service for NFS server
>  DefaultDependencies=no
> -Requires=var-lib-nfs-rpc_pipefs.mount
> -After=var-lib-nfs-rpc_pipefs.mount local-fs.target
> +After=local-fs.target
>  PartOf=nfs-server.service
>  PartOf=nfs-utils.service
>  
> diff --git a/systemd/rpc_pipefs.target b/systemd/rpc_pipefs.target
> new file mode 100644
> index 0000000..01d4d27
> --- /dev/null
> +++ b/systemd/rpc_pipefs.target
> @@ -0,0 +1,3 @@
> +[Unit]
> +Requires=var-lib-nfs-rpc_pipefs.mount
> +After=var-lib-nfs-rpc_pipefs.mount
> diff --git a/systemd/systemd.c b/systemd/systemd.c
> new file mode 100644
> index 0000000..e10da52
> --- /dev/null
> +++ b/systemd/systemd.c
> @@ -0,0 +1,133 @@
> +/*
> + * Helper functions for systemd generators in nfs-utils.
> + *
> + * Currently just systemd_escape().
> + */
> +
> +#include <stdio.h>
> +#include <stdlib.h>
> +#include <ctype.h>
> +#include <string.h>
> +
> +static const char hex[16] =
> +{
> +  '0', '1', '2', '3', '4', '5', '6', '7',
> +  '8', '9', 'a', 'b', 'c', 'd', 'e', 'f',
> +};
> +
> +/*
> + * determine length of the string that systemd_escape() needs to allocate
> + */
> +static int systemd_len(char *path)
> +{
> +	char *p;
> +	int len = 0;
> +
> +	p = path;
> +	while (*p == '/')
> +		/* multiple leading "/" are ignored */
> +		p++;
> +
> +	if (!*p)
> +		/* root directory "/" becomes is encoded as a single "-" */
> +		return 1;
> +
> +	if (*p == '.')
> +		/*
> +		 * replace "." with "\x2d" escape sequence if
> +		 * it's the first character in escaped path
> +		 * */
> +		len += 4;
> +
> +	while (*p) {
> +		unsigned char c = *p++;
> +
> +		if (c == '/') {
> +			/* multiple non-trailing slashes become '-' */
> +			while (*p == '/')
> +				p++;
> +			if (*p)
> +				len++;
> +		} else if (isalnum(c) || c == ':' || c == '.' || c == '_')
> +			/* these characters are not replaced */
> +			len++;
> +		else
> +			/* replace with "\x2d" escape sequence */
> +			len += 4;
> +	}
> +
> +	return len;
> +}
> +
> +/*
> + * convert c to "\x2d" escape sequence and append to string
> + * at position p, advancing p
> + */
> +static char *hexify(unsigned char c, char *p)
> +{
> +	*p++ = '\\';
> +	*p++ = 'x';
> +	*p++ = hex[c >> 4];
> +	*p++ = hex[c & 0xf];
> +	return p;
> +}
> +
> +/*
> + * convert a path to a unit name according to the logic in systemd.unit(5):
> + *
> + *     Basically, given a path, "/" is replaced by "-", and all other
> + *     characters which are not ASCII alphanumerics are replaced by C-style
> + *     "\x2d" escapes (except that "_" is never replaced and "." is only
> + *     replaced when it would be the first character in the escaped path).
> + *     The root directory "/" is encoded as single dash, while otherwise the
> + *     initial and ending "/" are removed from all paths during
> + *     transformation.
> + *
> + * NB: Although the systemd.unit(5) doesn't mention it, the ':' character
> + * is not escaped.
> + */
> +char *systemd_escape(char *path, char *suffix)
> +{
> +	char *result;
> +	char *p;
> +	int len;
> +
> +	len = systemd_len(path);
> +	result = malloc(len + strlen(suffix) + 1);
> +	p = result;
> +	while (*path == '/')
> +		/* multiple leading "/" are ignored */
> +		path++;
> +	if (!*path) {
> +		/* root directory "/" becomes is encoded as a single "-" */
> +		*p++ = '-';
> +		goto out;
> +	}
> +	if (*path == '.')
> +		/*
> +		 * replace "." with "\x2d" escape sequence if
> +		 * it's the first character in escaped path
> +		 * */
> +		p = hexify(*path++, p);
> +
> +	while (*path) {
> +		unsigned char c = *path++;
> +
> +		if (c == '/') {
> +			/* multiple non-trailing slashes become '-' */
> +			while (*path == '/')
> +				path++;
> +			if (*path)
> +				*p++ = '-';
> +		} else if (isalnum(c) || c == ':' || c == '.' || c == '_')
> +			/* these characters are not replaced */
> +			*p++ = c;
> +		else
> +			/* replace with "\x2d" escape sequence */
> +			p = hexify(c, p);
> +	}
> +
> +out:
> +	sprintf(p, suffix);
> +	return result;
> +}
> diff --git a/systemd/systemd.h b/systemd/systemd.h
> new file mode 100644
> index 0000000..25235ec
> --- /dev/null
> +++ b/systemd/systemd.h
> @@ -0,0 +1,6 @@
> +#ifndef SYSTEMD_H
> +#define SYSTEMD_H
> +
> +char *systemd_escape(char *path, char *suffix);
> +
> +#endif /* SYSTEMD_H */
> 
