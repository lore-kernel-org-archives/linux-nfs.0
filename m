Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49364 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933979AbdDGPEh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 11:04:37 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 11C263DBD8
        for <linux-nfs@vger.kernel.org>; Fri,  7 Apr 2017 15:04:37 +0000 (UTC)
Date: Fri, 7 Apr 2017 11:04:36 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Steve Dickson <SteveD@RedHat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils PATCH v3 4/4] systemd: add a generator for the
 rpc_pipefs mountpoint
Message-ID: <20170407150436.7johvexw5zx5apsm@tonberry.usersys.redhat.com>
References: <20170406163104.28397-1-smayhew@redhat.com>
 <20170406163104.28397-5-smayhew@redhat.com>
 <ce6f6789-e0ae-e43b-4540-b8a58e3c8649@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ce6f6789-e0ae-e43b-4540-b8a58e3c8649@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 06 Apr 2017, Steve Dickson wrote:

> Hello,
> 
> On 04/06/2017 12:31 PM, Scott Mayhew wrote:
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
> > index 0000000..512a464
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
> We already have one of these in nfs-server-generator.c
> Is there any reason we can not used that one? 

The one in nfs-server-generator.c writes the value directly to a file.
I need the escaped value to be returned as a string because in addition
to writing the value out to an existing file, I need need to create a
file with that as the filename.
> 
> I'm just concern that with every generator we'll get
> another one of these routines... It is not a huge deal,
> but hopefully we can start reusing this routines. 

I'll make nfs-server-generator.c use the new function.
> 
> At lease ad a header comment saying what this routine
> is doing.... This systemd-generator stuff is all black 
> magic IMHO..The more comments the better... 

Will do.
> 
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
> Talk about black magic... What in world is going on here. 8-)
> 
> I'm sure I could stare at it for a while to figure it out but,
> I would much rather have a comment telling what happening
> or rewrite it in more straightforward way or both.

That's converting a character to a "\x2d" escape sequence.  FWIW I
pretty much lifted that from qword_addhex().  I'll make it clearer.
> 
> > +		}
> > +	}
> > +
> > +out_append:
> > +	sprintf(p, ".mount");
> > +out:
> > +	return result;
> Finally the output of these two routines are different using the 
> same path (/var/lib/nfs/rpc_pipefs) 
> 
> rpc-pipefs-generator generates 'var-lib-nfs-rpc_pipefs.mount'
> nfs-server-generator generates 'var-lib-nfs-rpc\x5fpipefs.mount'
> 
> Should the '_' be turned into a \x5 or the other way around?

The string generated by rpc-pipefs-generator is correct.  You can
compare it to the output of the systemd-escape(1) command 

$ systemd-escape -p --suffix=mount /var/lib/nfs/rpc_pipefs
var-lib-nfs-rpc_pipefs.mount

Also the function isn't properly escaping paths with a leading '.' --
I'll fix that.

-Scott
> 
> Note, since the rest of the patches are fine just repost
> this patch with the appropriated  Message-Id using --in-reply-to
> to keep it in the same thread. 
> 
> steved.
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
> > +	s = conf_get_str("general", "pipefs-directory");
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
> > 
