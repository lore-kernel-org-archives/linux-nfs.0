Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60728 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932371AbdDFMGE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Apr 2017 08:06:04 -0400
Date: Thu, 6 Apr 2017 08:06:02 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v2 4/4] systemd: add a generator for the
 rpc_pipefs mountpoint
Message-ID: <20170406120602.vvsz2nujdtllvlf4@tonberry.usersys.redhat.com>
References: <20170405211243.12282-1-smayhew@redhat.com>
 <20170405211243.12282-5-smayhew@redhat.com>
 <87d1cq14lr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87d1cq14lr.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 06 Apr 2017, NeilBrown wrote:

> On Wed, Apr 05 2017, Scott Mayhew wrote:
> 
> > The nfs.conf has config options for the rpc_pipefs mountpoint.
> > Currently, changing these from the default also requires manually
> > overriding the systemd unit files that are hard-coded to mount the
> > filesystem on /var/lib/nfs/rpc_pipefs.
> >
> > This patch adds a generator that creates a mount unit file for the
> > rpc_pipefs when a non-default value is specified in /etc/nfs.conf, as
> > well as a target unit file to override the dependencies for the systemd
> > units using the rpc_pipefs.  The blkmapd, idmapd, and gssd service unit
> > files have been modified to define their dependencies on the rpc_pipefs
> > mountpoint indirectly via the rpc_pipefs target unit file.
> >
> > This patch also removes the dependency on the rpc_pipefs from the
> > rpc-svcgssd.service unit file.  rpc.svcgssd uses the sunrpc cache
> > mechanism to exchange data with the kernel, not the rpc_pipefs.
> >
> > Signed-off-by: Scott Mayhew <smayhew@redhat.com>
> 
> I was reading through this, which I really thought would be a good patch
> that I would give an Ack to, and looking at some of the detail involved,
> I started to wonder if we were really doing the right thing here.
> You go to some trouble to make the name of the .mount unit file match
> the name of the location of the mountpoint.  Is that really necessary?
> 
> Unit files created by systemd-fstab-generator do follow that pattern,
> but they don't have to.

I didn't know that.
> 
> Maybe we should just:
> 
> 1/ rename var-lib-nfs-rpc_pipefs.mount to rpc_pipefs.mount,
>    and modify the dependencies accordingly.
> 
> 2/ write a generator which (if necessary) creates a drop-in for
>    rpc_pipefs.mount which simply overrides "Where".
> 
>  i.e /run/systemd/generator/rpc_pipefs.mount.d/pipefs.conf
>  would contain
> 
>     [Mount]
>     Where=/foo/bar

Sounds good to me, I'll take a look.

-Scott
> 
> I'm sorry to discard your good work, but I now think that a lot of it is
> unnecessary.  Sorry for not seeing that earlier.
> 
> Thanks,
> NeilBrown
> 
> 
> > ---
> >  .gitignore                     |   1 +
> >  systemd/Makefile.am            |   5 +-
> >  systemd/nfs-blkmap.service     |   4 +-
> >  systemd/nfs-idmapd.service     |   4 +-
> >  systemd/rpc-gssd.service.in    |   4 +-
> >  systemd/rpc-pipefs-generator.c | 216 +++++++++++++++++++++++++++++++++++++++++
> >  systemd/rpc-svcgssd.service    |   3 +-
> >  systemd/rpc_pipefs.target      |   3 +
> >  8 files changed, 231 insertions(+), 9 deletions(-)
> >  create mode 100644 systemd/rpc-pipefs-generator.c
> >  create mode 100644 systemd/rpc_pipefs.target
> >
> > diff --git a/.gitignore b/.gitignore
> > index 126d12c..941aca0 100644
> > --- a/.gitignore
> > +++ b/.gitignore
> > @@ -70,6 +70,7 @@ tests/nsm_client/nlm_sm_inter_svc.c
> >  tests/nsm_client/nlm_sm_inter_xdr.c
> >  utils/nfsidmap/nfsidmap
> >  systemd/nfs-server-generator
> > +systemd/rpc-pipefs-generator
> >  systemd/nfs-config.service
> >  systemd/rpc-gssd.service
> >  # cscope database files
> > diff --git a/systemd/Makefile.am b/systemd/Makefile.am
> > index 0d15b9f..4becb77 100644
> > --- a/systemd/Makefile.am
> > +++ b/systemd/Makefile.am
> > @@ -4,6 +4,7 @@ MAINTAINERCLEANFILES = Makefile.in
> >  
> >  unit_files =  \
> >      nfs-client.target \
> > +    rpc_pipefs.target \
> >      \
> >      nfs-mountd.service \
> >      nfs-server.service \
> > @@ -42,12 +43,14 @@ EXTRA_DIST = $(unit_files) $(man5_MANS) $(man7_MANS)
> >  unit_dir = /usr/lib/systemd/system
> >  generator_dir = /usr/lib/systemd/system-generators
> >  
> > -EXTRA_PROGRAMS	= nfs-server-generator
> > +EXTRA_PROGRAMS	= nfs-server-generator rpc-pipefs-generator
> >  genexecdir = $(generator_dir)
> >  nfs_server_generator_LDADD = ../support/export/libexport.a \
> >  			     ../support/nfs/libnfs.a \
> >  			     ../support/misc/libmisc.a
> >  
> > +rpc_pipefs_generator_LDADD = ../support/nfs/libnfs.a
> > +
> >  if INSTALL_SYSTEMD
> >  genexec_PROGRAMS = nfs-server-generator
> >  install-data-hook: $(unit_files)
> > diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
> > index ddc324e..2bbcee6 100644
> > --- a/systemd/nfs-blkmap.service
> > +++ b/systemd/nfs-blkmap.service
> > @@ -2,8 +2,8 @@
> >  Description=pNFS block layout mapping daemon
> >  DefaultDependencies=no
> >  Conflicts=umount.target
> > -After=var-lib-nfs-rpc_pipefs.mount
> > -Requires=var-lib-nfs-rpc_pipefs.mount
> > +After=rpc_pipefs.target
> > +Requires=rpc_pipefs.target
> >  
> >  PartOf=nfs-utils.service
> >  
> > diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
> > index acca86b..f38fe52 100644
> > --- a/systemd/nfs-idmapd.service
> > +++ b/systemd/nfs-idmapd.service
> > @@ -1,8 +1,8 @@
> >  [Unit]
> >  Description=NFSv4 ID-name mapping service
> >  DefaultDependencies=no
> > -Requires=var-lib-nfs-rpc_pipefs.mount
> > -After=var-lib-nfs-rpc_pipefs.mount local-fs.target
> > +Requires=rpc_pipefs.target
> > +After=rpc_pipefs.target local-fs.target
> >  
> >  BindsTo=nfs-server.service
> >  
> > diff --git a/systemd/rpc-gssd.service.in b/systemd/rpc-gssd.service.in
> > index b353027..6807db3 100644
> > --- a/systemd/rpc-gssd.service.in
> > +++ b/systemd/rpc-gssd.service.in
> > @@ -2,8 +2,8 @@
> >  Description=RPC security service for NFS client and server
> >  DefaultDependencies=no
> >  Conflicts=umount.target
> > -Requires=var-lib-nfs-rpc_pipefs.mount
> > -After=var-lib-nfs-rpc_pipefs.mount
> > +Requires=rpc_pipefs.target
> > +After=rpc_pipefs.target
> >  
> >  ConditionPathExists=@_sysconfdir@/krb5.keytab
> >  
> > diff --git a/systemd/rpc-pipefs-generator.c b/systemd/rpc-pipefs-generator.c
> > new file mode 100644
> > index 0000000..b0a6c19
> > --- /dev/null
> > +++ b/systemd/rpc-pipefs-generator.c
> > @@ -0,0 +1,216 @@
> > +/*
> > + * rpc-pipefs-generator:
> > + *   systemd generator to create ordering dependencies between
> > + *   nfs services and the rpc_pipefs mountpoint
> > + */
> > +
> > +#ifdef HAVE_CONFIG_H
> > +#include <config.h>
> > +#endif
> > +
> > +#include <sys/stat.h>
> > +#include <sys/types.h>
> > +#include <unistd.h>
> > +#include <stdlib.h>
> > +#include <string.h>
> > +#include <ctype.h>
> > +#include <stdio.h>
> > +#include <mntent.h>
> > +
> > +#include "nfslib.h"
> > +#include "conffile.h"
> > +
> > +#define RPC_PIPEFS_DEFAULT "/var/lib/nfs/rpc_pipefs"
> > +char *conf_path = NFS_CONFFILE;
> > +
> > +int systemd_len(char *path)
> > +{
> > +	char *p;
> > +	int len = 0;
> > +
> > +	p = path;
> > +	while (*p == '/')
> > +		p++;
> > +
> > +	if (!*p)
> > +		/* "/" becomes "-", otherwise leading "/" is ignored */
> > +		return 1;
> > +
> > +	while (*p) {
> > +		unsigned char c = *p++;
> > +
> > +		if (c == '/') {
> > +			/* multiple non-trailing slashes become '-' */
> > +			while (*p == '/')
> > +				p++;
> > +			if (*p)
> > +				len++;
> > +		} else if (isalnum(c) || c == ':' || c == '.' || c == '_')
> > +			len++;
> > +		else {
> > +			len += 4;
> > +		}
> > +	}
> > +
> > +	return len;
> > +}
> > +
> > +char *systemd_escape(char *path)
> > +{
> > +	char *result = NULL;
> > +	char *p;
> > +	int len;
> > +
> > +	len = systemd_len(path);
> > +	if (!len)
> > +		goto out;
> > +
> > +	result = malloc(len + strlen(".mount") + 1);
> > +	if (!result)
> > +		goto out;
> > +
> > +	p = result;
> > +	while (*path == '/')
> > +		path++;
> > +	if (!*path) {
> > +		/* "/" becomes "-", otherwise leading "/" is ignored */
> > +		*p++ = '-';
> > +		goto out_append;
> > +	}
> > +	while (*path) {
> > +		unsigned char c = *path++;
> > +
> > +		if (c == '/') {
> > +			/* multiple non-trailing slashes become '-' */
> > +			while (*path == '/')
> > +				path++;
> > +			if (*path)
> > +				*p++ = '-';
> > +		} else if (isalnum(c) || c == ':' || c == '.' || c == '_')
> > +			*p++ = c;
> > +		else {
> > +			*p++ = '\\';
> > +			*p++ = 'x';
> > +			*p++ = '0' + ((c&0xf0)>>4) + (c>=0xa0)*('a'-'9'-1);
> > +			*p++ = '0' + (c&0x0f) + ((c&0x0f)>=0x0a)*('a'-'9'-1);
> > +		}
> > +	}
> > +
> > +out_append:
> > +	sprintf(p, ".mount");
> > +out:
> > +	return result;
> > +}
> > +
> > +static int generate_mount_unit(const char *pipefs_path, const char *pipefs_unit,
> > +			       const char *dirname)
> > +{
> > +	char	*path;
> > +	FILE	*f;
> > +
> > +	path = malloc(strlen(dirname) + 1 + strlen(pipefs_unit));
> > +	if (!path)
> > +		return 1;
> > +	sprintf(path, "%s/%s", dirname, pipefs_unit);
> > +	f = fopen(path, "w");
> > +	if (!f)
> > +		return 1;
> > +
> > +	fprintf(f, "# Automatically generated by rpc-pipefs-generator\n\n[Unit]\n");
> > +	fprintf(f, "Description=RPC Pipe File System\n");
> > +	fprintf(f, "DefaultDependencies=no\n");
> > +	fprintf(f, "After=systemd-tmpfiles-setup.service\n");
> > +	fprintf(f, "Conflicts=umount.target\n");
> > +	fprintf(f, "\n[Mount]\n");
> > +	fprintf(f, "What=sunrpc\n");
> > +	fprintf(f, "Where=%s\n", pipefs_path);
> > +	fprintf(f, "Type=rpc_pipefs\n");
> > +
> > +	fclose(f);
> > +	return 0;
> > +}
> > +
> > +static
> > +int generate_target(char *pipefs_path, const char *dirname)
> > +{
> > +	char	*path;
> > +	char	filebase[] = "/rpc_pipefs.target";
> > +	char	*pipefs_unit;
> > +	FILE	*f;
> > +	int 	ret = 0;
> > +
> > +	pipefs_unit = systemd_escape(pipefs_path);
> > +	if (!pipefs_unit)
> > +		return 1;
> > +
> > +	ret = generate_mount_unit(pipefs_path, pipefs_unit, dirname);
> > +	if (ret)
> > +		return ret;
> > +
> > +	path = malloc(strlen(dirname) + 1 + sizeof(filebase));
> > +	if (!path)
> > +		return 2;
> > +	sprintf(path, "%s", dirname);
> > +	mkdir(path, 0755);
> > +	strcat(path, filebase);
> > +	f = fopen(path, "w");
> > +	if (!f)
> > +		return 1;
> > +
> > +	fprintf(f, "# Automatically generated by rpc-pipefs-generator\n\n[Unit]\n");
> > +	fprintf(f, "Requires=%s\n", pipefs_unit);
> > +	fprintf(f, "After=%s\n", pipefs_unit);
> > +	fclose(f);
> > +
> > +	return 0;
> > +}
> > +
> > +static int is_non_pipefs_mountpoint(char *path)
> > +{
> > +	FILE		*mtab;
> > +	struct mntent	*mnt;
> > +
> > +	mtab = setmntent("/etc/mtab", "r");
> > +	if (!mtab)
> > +		return 0;
> > +
> > +	while ((mnt = getmntent(mtab)) != NULL) {
> > +		if (strlen(mnt->mnt_dir) != strlen(path))
> > +			continue;
> > +		if (strncmp(mnt->mnt_dir, path, strlen(mnt->mnt_dir)))
> > +			continue;
> > +		if (strncmp(mnt->mnt_type, "rpc_pipefs", strlen(mnt->mnt_type)))
> > +			break;
> > +	}
> > +	fclose(mtab);
> > +	return mnt != NULL;
> > +}
> > +
> > +int main(int argc, char *argv[])
> > +{
> > +	int 	ret;
> > +	char	*s;
> > +
> > +	/* Avoid using any external services */
> > +	xlog_syslog(0);
> > +
> > +	if (argc != 4 || argv[1][0] != '/') {
> > +		fprintf(stderr, "rpc-pipefs-generator: create systemd dependencies for nfs services\n");
> > +		fprintf(stderr, "Usage: normal-dir early-dir late-dir\n");
> > +		exit(1);
> > +	}
> > +
> > +	conf_init();
> > +	s = conf_get_str("global", "pipefs-directory");
> > +	if (!s)
> > +		exit(0);
> > +	if (strlen(s) == strlen(RPC_PIPEFS_DEFAULT) &&
> > +			strcmp(s, RPC_PIPEFS_DEFAULT) == 0)
> > +		exit(0);
> > +
> > +	if (is_non_pipefs_mountpoint(s))
> > +		exit(1);
> > +
> > +	ret = generate_target(s, argv[1]);
> > +	exit(ret);
> > +}
> > diff --git a/systemd/rpc-svcgssd.service b/systemd/rpc-svcgssd.service
> > index 7187e3c..cb2bcd4 100644
> > --- a/systemd/rpc-svcgssd.service
> > +++ b/systemd/rpc-svcgssd.service
> > @@ -1,8 +1,7 @@
> >  [Unit]
> >  Description=RPC security service for NFS server
> >  DefaultDependencies=no
> > -Requires=var-lib-nfs-rpc_pipefs.mount
> > -After=var-lib-nfs-rpc_pipefs.mount local-fs.target
> > +After=local-fs.target
> >  PartOf=nfs-server.service
> >  PartOf=nfs-utils.service
> >  
> > diff --git a/systemd/rpc_pipefs.target b/systemd/rpc_pipefs.target
> > new file mode 100644
> > index 0000000..01d4d27
> > --- /dev/null
> > +++ b/systemd/rpc_pipefs.target
> > @@ -0,0 +1,3 @@
> > +[Unit]
> > +Requires=var-lib-nfs-rpc_pipefs.mount
> > +After=var-lib-nfs-rpc_pipefs.mount
> > -- 
> > 2.9.3
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html


