Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:11675 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933157Ab2JYNx3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Oct 2012 09:53:29 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9PDrTxp012790
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 25 Oct 2012 09:53:29 -0400
Date: Thu, 25 Oct 2012 09:53:27 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 05/10] nfsdcltrack: add a new "one-shot" program for
 manipulating the client tracking db
Message-ID: <20121025095327.1d463b4c@corrin.poochiereds.net>
In-Reply-To: <5089371A.9010005@RedHat.com>
References: <1351092359-25842-1-git-send-email-jlayton@redhat.com>
	<1351092359-25842-6-git-send-email-jlayton@redhat.com>
	<5089371A.9010005@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 25 Oct 2012 08:56:58 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> Over all it I think it look very good... but a couple small nits at the bottom... 
> 
> On 24/10/12 11:25, Jeff Layton wrote:
> > Usermode helper upcalls are all the rage these days for infrequent
> > upcalls, since they make it rather idiot-proof. No running daemon is
> > required, so there's really no setup beyond ensuring that the callout
> > exists and is runnable.
> > 
> > This program adds a callout program to nfs-utils for that purpose. The
> > storage engine on the backend is identical to the one used by nfsdcld.
> > This just adds a new frontend for it.
> > 
> > For now, building with --enable-nfsdcltrack gives you both nfsdcld and
> > nfsdcltrack programs. A later patch will remove nfsdcld altogether.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  utils/nfsdcltrack/Makefile.am   |   6 +-
> >  utils/nfsdcltrack/nfsdcltrack.c | 441 ++++++++++++++++++++++++++++++++++++++++
> >  2 files changed, 445 insertions(+), 2 deletions(-)
> >  create mode 100644 utils/nfsdcltrack/nfsdcltrack.c
> > 
> > diff --git a/utils/nfsdcltrack/Makefile.am b/utils/nfsdcltrack/Makefile.am
> > index 073a71b..afae455 100644
> > --- a/utils/nfsdcltrack/Makefile.am
> > +++ b/utils/nfsdcltrack/Makefile.am
> > @@ -4,11 +4,13 @@ man8_MANS	= nfsdcld.man
> >  EXTRA_DIST	= $(man8_MANS)
> >  
> >  AM_CFLAGS	+= -D_LARGEFILE64_SOURCE
> > -sbin_PROGRAMS	= nfsdcld
> > +sbin_PROGRAMS	= nfsdcld nfsdcltrack
> >  
> >  nfsdcld_SOURCES = nfsdcld.c sqlite.c
> > -
> >  nfsdcld_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT) $(LIBSQLITE) $(LIBCAP)
> >  
> > +nfsdcltrack_SOURCES = nfsdcltrack.c sqlite.c
> > +nfsdcltrack_LDADD = ../../support/nfs/libnfs.a $(LIBSQLITE) $(LIBCAP)
> > +
> >  MAINTAINERCLEANFILES = Makefile.in
> >  
> > diff --git a/utils/nfsdcltrack/nfsdcltrack.c b/utils/nfsdcltrack/nfsdcltrack.c
> > new file mode 100644
> > index 0000000..f8c3810
> > --- /dev/null
> > +++ b/utils/nfsdcltrack/nfsdcltrack.c
> > @@ -0,0 +1,441 @@
> > +/*
> > + * nfsdcltrack.c -- NFSv4 client name tracking program
> > + *
> > + * Copyright (C) 2012 Jeff Layton <jlayton@redhat.com>
> > + *
> > + * This program is free software; you can redistribute it and/or
> > + * modify it under the terms of the GNU General Public License
> > + * as published by the Free Software Foundation; either version 2
> > + * of the License, or (at your option) any later version.
> > + *
> > + * This program is distributed in the hope that it will be useful,
> > + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> > + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> > + * GNU General Public License for more details.
> > + *
> > + * You should have received a copy of the GNU General Public License
> > + * along with this program; if not, write to the Free Software
> > + * Foundation, Inc., 51 Franklin Street, Fifth Floor,
> > + * Boston, MA 02110-1301, USA.
> > + */
> > +
> > +#ifdef HAVE_CONFIG_H
> > +#include "config.h"
> > +#endif /* HAVE_CONFIG_H */
> > +
> > +#include <stdio.h>
> > +#include <stdlib.h>
> > +#include <ctype.h>
> > +#include <errno.h>
> > +#include <stdbool.h>
> > +#include <getopt.h>
> > +#include <string.h>
> > +#include <sys/stat.h>
> > +#include <sys/types.h>
> > +#include <fcntl.h>
> > +#include <unistd.h>
> > +#include <libgen.h>
> > +#include <sys/inotify.h>
> > +#ifdef HAVE_SYS_CAPABILITY_H
> > +#include <sys/prctl.h>
> > +#include <sys/capability.h>
> > +#endif
> > +
> > +#include "xlog.h"
> > +#include "sqlite.h"
> > +
> > +#ifndef CLD_DEFAULT_STORAGEDIR
> > +#define CLD_DEFAULT_STORAGEDIR NFS_STATEDIR "/nfsdcltrack"
> > +#endif
> > +
> > +/* defined by RFC 3530 */
> > +#define NFS4_OPAQUE_LIMIT	1024
> > +
> > +/* private data structures */
> > +struct cltrack_cmd {
> > +	char *name;
> > +	bool needs_arg;
> > +	int (*func)(const char *arg);
> > +};
> > +
> > +/* forward declarations */
> > +static int cltrack_init(const char *unused);
> > +static int cltrack_create(const char *id);
> > +static int cltrack_remove(const char *id);
> > +static int cltrack_check(const char *id);
> > +static int cltrack_gracedone(const char *gracetime);
> > +
> > +/* global variables */
> > +static struct option longopts[] =
> > +{
> > +	{ "help", 0, NULL, 'h' },
> > +	{ "debug", 0, NULL, 'd' },
> > +	{ "foreground", 0, NULL, 'f' },
> > +	{ "storagedir", 1, NULL, 's' },
> > +	{ NULL, 0, 0, 0 },
> > +};
> > +
> > +static struct cltrack_cmd commands[] =
> > +{
> > +	{ "init", false, cltrack_init },
> > +	{ "create", true, cltrack_create },
> > +	{ "remove", true, cltrack_remove },
> > +	{ "check", true, cltrack_check },
> > +	{ "gracedone", true, cltrack_gracedone },
> > +	{ NULL, false, NULL },
> > +};
> > +
> > +static char *storagedir = CLD_DEFAULT_STORAGEDIR;
> > +
> > +/* common buffer for holding id4 blobs */
> > +static unsigned char blob[NFS4_OPAQUE_LIMIT];
> > +
> > +static void
> > +usage(char *progname)
> > +{
> > +	printf("%s [ -hfd ] [ -s dir ] < cmd > < arg >\n", progname);
> > +	printf("Where < cmd > is one of the following and takes the following < arg >:\n");
> > +	printf("    init\n");
> > +	printf("    create <nfs_client_id4>\n");
> > +	printf("    remove <nfs_client_id4>\n");
> > +	printf("    check  <nfs_client_id4>\n");
> > +	printf("    gracedone <epoch time>\n");
> > +}
> > +
> > +
> > +/**
> > + * hex_to_bin - convert a hex digit to its real value
> > + * @ch: ascii character represents hex digit
> > + *
> > + * hex_to_bin() converts one hex digit to its actual value or -1 in case of bad
> > + * input.
> > + *
> > + * Note: borrowed from lib/hexdump.c in the Linux kernel sources.
> > + */
> > +static int
> > +hex_to_bin(char ch)
> > +{
> > +	if ((ch >= '0') && (ch <= '9'))
> > +		return ch - '0';
> > +	ch = tolower(ch);
> > +	if ((ch >= 'a') && (ch <= 'f'))
> > +		return ch - 'a' + 10;
> > +	return -1;
> > +}
> > +
> > +/**
> > + * hex_str_to_bin - convert a hexidecimal string into a binary blob
> > + *
> > + * @src: string of hex digit pairs
> > + * @dst: destination buffer to hold binary data
> > + * @dstsize: size of the destination buffer
> > + *
> > + * Walk a string of hex digit pairs and convert them into binary data. Returns
> > + * the resulting length of the binary data or a negative error code. If the
> > + * data will not fit in the buffer, it returns -ENOBUFS (but will likely have
> > + * clobbered the dst buffer in the process of determining that). If there are
> > + * non-hexidecimal characters in the src, or an odd number of them then it
> > + * returns -EINVAL.
> > + */
> > +static ssize_t
> > +hex_str_to_bin(const char *src, unsigned char *dst, ssize_t dstsize)
> > +{
> > +	unsigned char *tmpdst = dst;
> > +
> > +	while (*src) {
> > +		int hi, lo;
> > +
> > +		/* make sure we don't overrun the dst buffer */
> > +		if ((tmpdst - dst) >= dstsize)
> > +			return -ENOBUFS;
> > +
> > +		hi = hex_to_bin(*src++);
> > +
> > +		/* did we get an odd number of characters? */
> > +		if (!*src)
> > +			return -EINVAL;
> > +		lo = hex_to_bin(*src++);
> > +
> > +		/* one of the characters isn't a hex digit */
> > +		if (hi < 0 || lo < 0)
> > +			return -EINVAL;
> > +
> > +		/* now place it in the dst buffer */
> > +		*tmpdst++ = (hi << 4) | lo;
> > +	}
> > +
> > +	return (ssize_t)(tmpdst - dst);
> > +}
> > +
> > +/*
> > + * This program will almost always be run with root privileges since the
> > + * kernel will call out to run it. Drop all capabilities prior to doing
> > + * anything important to limit the exposure to potential compromise.
> > + *
> > + * FIXME: should we setuid to a different user early on instead?
> > + */
> > +static int
> > +cltrack_set_caps(void)
> > +{
> > +	int ret = 0;
> > +#ifdef HAVE_SYS_CAPABILITY_H
> > +	unsigned long i;
> > +	cap_t caps;
> > +
> > +	/* prune the bounding set to nothing */
> > +	for (i = 0; prctl(PR_CAPBSET_READ, i, 0, 0, 0) >= 0 ; ++i) {
> > +		ret = prctl(PR_CAPBSET_DROP, i, 0, 0, 0);
> > +		if (ret) {
> > +			xlog(L_ERROR, "Unable to prune capability %lu from "
> > +				      "bounding set: %m", i);
> > +			return -errno;
> > +		}
> > +	}
> > +
> > +	/* get a blank capset */
> > +	caps = cap_init();
> > +	if (caps == NULL) {
> > +		xlog(L_ERROR, "Unable to get blank capability set: %m");
> > +		return -errno;
> > +	}
> > +
> > +	/* reset the process capabilities */
> > +	if (cap_set_proc(caps) != 0) {
> > +		xlog(L_ERROR, "Unable to set process capabilities: %m");
> > +		ret = -errno;
> > +	}
> > +	cap_free(caps);
> > +#endif
> > +	return ret;
> > +}
> > +
> > +static int
> > +cltrack_init(const char __attribute__((unused)) *unused)
> > +{
> > +	int ret;
> > +
> > +	/*
> > +	 * see if the storagedir is writable by root w/o CAP_DAC_OVERRIDE.
> > +	 * If it isn't then give the user a warning but proceed as if
> > +	 * everything is OK. If the DB has already been created, then
> > +	 * everything might still work. If it doesn't exist at all, then
> > +	 * assume that the maindb init will be able to create it. Fail on
> > +	 * anything else.
> > +	 */
> > +	if (access(storagedir, W_OK) == -1) {
> > +		switch (errno) {
> > +		case EACCES:
> > +			xlog(L_WARNING, "Storage directory %s is not writable. "
> > +					"Should be owned by root and writable "
> > +					"by owner!", storagedir);
> > +			break;
> > +		case ENOENT:
> > +			/* ignore and assume that we can create dir as root */
> > +			break;
> > +		default:
> > +			xlog(L_ERROR, "Unexpected error when checking access "
> > +				      "on %s: %m", storagedir);
> > +			return -errno;
> > +		}
> > +	}
> > +
> > +	/* set up storage db */
> > +	ret = sqlite_maindb_init(storagedir);
> > +	if (ret) {
> > +		xlog(L_ERROR, "Failed to init database: %d", ret);
> > +		/*
> > +		 * Convert any error here into -EACCES. It's not truly
> > +		 * accurate in all cases, but it should cause the kernel to
> > +		 * stop upcalling until the problem is resolved.
> > +		 */
> > +		ret = -EACCES;
> > +	}
> > +	return ret;
> > +}
> > +
> > +static int
> > +cltrack_create(const char *id)
> > +{
> > +	int ret;
> > +	ssize_t len;
> > +
> > +	xlog(D_GENERAL, "%s: create client record.", __func__);
> > +
> > +	ret = sqlite_prepare_dbh(storagedir);
> > +	if (ret)
> > +		return ret;
> > +
> > +	len = hex_str_to_bin(id, blob, sizeof(blob));
> > +	if (len < 0)
> > +		return (int)len;
> > +
> > +	ret = sqlite_insert_client(blob, len);
> > +
> > +	return ret ? -EREMOTEIO : ret;
> > +}
> > +
> > +static int
> > +cltrack_remove(const char *id)
> > +{
> > +	int ret;
> > +	ssize_t len;
> > +
> > +	xlog(D_GENERAL, "%s: remove client record.", __func__);
> > +
> > +	ret = sqlite_prepare_dbh(storagedir);
> > +	if (ret)
> > +		return ret;
> > +
> > +	len = hex_str_to_bin(id, blob, sizeof(blob));
> > +	if (len < 0)
> > +		return (int)len;
> > +
> > +	ret = sqlite_remove_client(blob, len);
> > +
> > +	return ret ? -EREMOTEIO : ret;
> > +}
> > +
> > +static int
> > +cltrack_check(const char *id)
> > +{
> > +	int ret;
> > +	ssize_t len;
> > +
> > +	xlog(D_GENERAL, "%s: check client record", __func__);
> > +
> > +	ret = sqlite_prepare_dbh(storagedir);
> > +	if (ret)
> > +		return ret;
> > +
> > +	len = hex_str_to_bin(id, blob, sizeof(blob));
> > +	if (len < 0)
> > +		return (int)len;
> > +
> > +	ret = sqlite_check_client(blob, len);
> > +
> > +	return ret ? -EPERM : ret;
> > +}
> > +
> > +static int
> > +cltrack_gracedone(const char *timestr)
> > +{
> > +	int ret;
> > +	char *tail;
> > +	time_t gracetime;
> > +
> > +
> > +	ret = sqlite_prepare_dbh(storagedir);
> > +	if (ret)
> > +		return ret;
> > +
> > +	errno = 0;
> > +	gracetime = strtol(timestr, &tail, 0);
> > +
> > +	/* did the resulting value overflow? (Probably -ERANGE here) */
> > +	if (errno)
> > +		return -errno;
> > +
> > +	/* string wasn't fully converted */
> > +	if (*tail)
> > +		return -EINVAL;
> > +
> > +	xlog(D_GENERAL, "%s: grace done. gracetime=%ld", __func__, gracetime);
> > +
> > +	ret = sqlite_remove_unreclaimed(gracetime);
> > +
> > +	return ret ? -EREMOTEIO : ret;
> > +}
> > +
> > +static struct cltrack_cmd *
> > +find_cmd(char *cmdname)
> > +{
> > +	struct cltrack_cmd *current = &commands[0];
> > +
> > +	while (current->name) {
> > +		if (!strcmp(cmdname, current->name))
> > +			return current;
> > +		++current;
> > +	}
> > +
> > +	xlog(L_ERROR, "%s: '%s' doesn't match any known command",
> > +			__func__, cmdname);
> > +	return NULL;
> > +}
> > +
> > +int
> > +main(int argc, char **argv)
> > +{
> > +	char arg;
> > +	int rc = 0;
> > +	char *progname, *cmdarg = NULL;
> > +	struct cltrack_cmd *cmd;
> > +
> > +	progname = strdup(basename(argv[0]));
> > +	if (!progname) {
> > +		fprintf(stderr, "%s: unable to allocate memory.\n", argv[0]);
> > +		return 1;
> > +	}
> Small nit: Do we really want to fail because we cannot get memory for
> the program name? Why not just use the string returned from basename()?
> 
> > +
> > +	xlog_syslog(1);
> > +	xlog_stderr(0);
> > +
> > +	/* process command-line options */
> > +	while ((arg = getopt_long(argc, argv, "hdfs:", longopts,
> > +				  NULL)) != EOF) {
> > +		switch (arg) {
> > +		case 'd':
> > +			xlog_config(D_ALL, 1);
> > +		case 'f':
> > +			xlog_syslog(0);
> > +			xlog_stderr(1);
> > +			break;
> > +		case 's':
> > +			storagedir = optarg;
> > +			break;
> > +		default:
> > +			usage(progname);
> > +			return 0;
> > +		}
> > +	}
> > +
> > +	xlog_open(progname);
> > +
> > +	/* we expect a command, at least */
> > +	if (optind >= argc) {
> > +		xlog(L_ERROR, "Missing command name\n");
> > +		rc = -EINVAL;
> > +		goto out;
> > +	}
> > +
> > +	/* drop all capabilities */
> > +	rc = cltrack_set_caps();
> > +	if (rc)
> > +		goto out;
> > +
> > +	cmd = find_cmd(argv[optind]);
> > +	if (!cmd) {
> > +		/*
> > +		 * In the event that we get a command that we don't understand
> > +		 * then return a distinct error. The kernel can use this to
> > +		 * determine a new kernel/old userspace situation and cope
> > +		 * with it.
> > +		 */
> > +		rc = -ENOSYS;
> > +		goto out;
> > +	}
> > +
> > +	/* populate arg var if command needs it */
> > +	if (cmd->needs_arg) {
> > +		if (optind + 1 >= argc) {
> > +			xlog(L_ERROR, "Command %s requires an argument\n",
> > +				cmd->name);
> > +			rc = -EINVAL;
> > +			goto out;
> > +		}
> > +		cmdarg = argv[optind + 1];
> > +	}
> Is needs_arg really necessary? Once the function is found, just pass 
> it the rest of argv and let the function decide if there should
> be an argument or not... but again.. just a nit... 
> 
> steved. 

No, it's not strictly necessary. The alternative though is to make the
command functions do argv processing, which seemed more ugly to me. I
tend to prefer to keep argv processing in a single place since it can
get sort of hairy to work through the bounds checks after getopt and
such.

If you feel strongly about it, I can try to change it, but I don't
think the result will be cleaner.

> > +	rc = cmd->func(cmdarg);
> > +out:
> > +	free(progname);
> > +	return rc;
> > +}
> > 


-- 
Jeff Layton <jlayton@redhat.com>
