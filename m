Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:18364 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102Ab2EISPf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 May 2012 14:15:35 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q49IFZmN015221
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 9 May 2012 14:15:35 -0400
Message-ID: <4FAAB430.6090908@RedHat.com>
Date: Wed, 09 May 2012 14:15:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfsdcld: add support for dropping capabilities
References: <1336563898-23218-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1336563898-23218-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/09/2012 07:44 AM, Jeff Layton wrote:
> As a long running daemon, we need to be security-conscious with nfsdcld,
> so let's prune what it can do down to nearly nothing.
> 
> We want the daemon to run as root so that it has access to open and
> reopen the rpc_pipefs pipe, but we don't actually need any of the
> superuser caps that come with it. Have it drop all capabilities early
> on. We don't need any of them as long as the fsuid continues to be 0.
> 
> Once we do that though, check to ensure that the db dir is actually
> usable by root w/o CAP_DAC_OVERRIDE. Do an access() check on it and
> throw a warning if it's not. Hopefully that will assist users in
> debugging if they get the ownership of the DB dir wrong.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
Committed...

steved.
> ---
>  utils/nfsdcld/Makefile.am |    2 +-
>  utils/nfsdcld/nfsdcld.c   |   82 ++++++++++++++++++++++++++++++++++++++++++++-
>  utils/nfsdcld/nfsdcld.man |    7 +++-
>  utils/nfsdcld/sqlite.c    |    6 +---
>  4 files changed, 89 insertions(+), 8 deletions(-)
> 
> diff --git a/utils/nfsdcld/Makefile.am b/utils/nfsdcld/Makefile.am
> index f320dff..073a71b 100644
> --- a/utils/nfsdcld/Makefile.am
> +++ b/utils/nfsdcld/Makefile.am
> @@ -8,7 +8,7 @@ sbin_PROGRAMS	= nfsdcld
>  
>  nfsdcld_SOURCES = nfsdcld.c sqlite.c
>  
> -nfsdcld_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT) $(LIBSQLITE)
> +nfsdcld_LDADD = ../../support/nfs/libnfs.a $(LIBEVENT) $(LIBSQLITE) $(LIBCAP)
>  
>  MAINTAINERCLEANFILES = Makefile.in
>  
> diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
> index 2f0b004..f4e9502 100644
> --- a/utils/nfsdcld/nfsdcld.c
> +++ b/utils/nfsdcld/nfsdcld.c
> @@ -34,6 +34,10 @@
>  #include <unistd.h>
>  #include <libgen.h>
>  #include <sys/inotify.h>
> +#ifdef HAVE_SYS_CAPABILITY_H
> +#include <sys/prctl.h>
> +#include <sys/capability.h>
> +#endif
>  
>  #include "xlog.h"
>  #include "nfslib.h"
> @@ -46,6 +50,10 @@
>  
>  #define DEFAULT_CLD_PATH	PIPEFS_DIR "/nfsd/cld"
>  
> +#ifndef CLD_DEFAULT_STORAGEDIR
> +#define CLD_DEFAULT_STORAGEDIR NFS_STATEDIR "/nfsdcld"
> +#endif
> +
>  #define UPCALL_VERSION		1
>  
>  /* private data structures */
> @@ -79,6 +87,47 @@ usage(char *progname)
>  	printf("%s [ -hFd ] [ -p pipe ] [ -s dir ]\n", progname);
>  }
>  
> +static int
> +cld_set_caps(void)
> +{
> +	int ret = 0;
> +#ifdef HAVE_SYS_CAPABILITY_H
> +	unsigned long i;
> +	cap_t caps;
> +
> +	if (getuid() != 0) {
> +		xlog(L_ERROR, "Not running as root. Daemon won't be able to "
> +			      "open the pipe after dropping capabilities!");
> +		return -EINVAL;
> +	}
> +
> +	/* prune the bounding set to nothing */
> +	for (i = 0; i <= CAP_LAST_CAP; ++i) {
> +		ret = prctl(PR_CAPBSET_DROP, i);
> +		if (ret) {
> +			xlog(L_ERROR, "Unable to prune capability %lu from "
> +				      "bounding set: %m", i);
> +			return -errno;
> +		}
> +	}
> +
> +	/* get a blank capset */
> +	caps = cap_init();
> +	if (caps == NULL) {
> +		xlog(L_ERROR, "Unable to get blank capability set: %m");
> +		return -errno;
> +	}
> +
> +	/* reset the process capabilities */
> +	if (cap_set_proc(caps) != 0) {
> +		xlog(L_ERROR, "Unable to set process capabilities: %m");
> +		ret = -errno;
> +	}
> +	cap_free(caps);
> +#endif
> +	return ret;
> +}
> +
>  #define INOTIFY_EVENT_MAX (sizeof(struct inotify_event) + NAME_MAX)
>  
>  static int
> @@ -453,7 +502,7 @@ main(int argc, char **argv)
>  	int rc = 0;
>  	bool foreground = false;
>  	char *progname;
> -	char *storagedir = NULL;
> +	char *storagedir = CLD_DEFAULT_STORAGEDIR;
>  	struct cld_client clnt;
>  
>  	memset(&clnt, 0, sizeof(clnt));
> @@ -502,6 +551,37 @@ main(int argc, char **argv)
>  		}
>  	}
>  
> +	/* drop all capabilities */
> +	rc = cld_set_caps();
> +	if (rc)
> +		goto out;
> +
> +	/*
> +	 * now see if the storagedir is writable by root w/o CAP_DAC_OVERRIDE.
> +	 * If it isn't then give the user a warning but proceed as if
> +	 * everything is OK. If the DB has already been created, then
> +	 * everything might still work. If it doesn't exist at all, then
> +	 * assume that the maindb init will be able to create it. Fail on
> +	 * anything else.
> +	 */
> +	if (access(storagedir, W_OK) == -1) {
> +		switch (errno) {
> +		case EACCES:
> +			xlog(L_WARNING, "Storage directory %s is not writable. "
> +					"Should be owned by root and writable "
> +					"by owner!", storagedir);
> +			break;
> +		case ENOENT:
> +			/* ignore and assume that we can create dir as root */
> +			break;
> +		default:
> +			xlog(L_ERROR, "Unexpected error when checking access "
> +				      "on %s: %m", storagedir);
> +			rc = -errno;
> +			goto out;
> +		}
> +	}
> +
>  	/* set up storage db */
>  	rc = sqlite_maindb_init(storagedir);
>  	if (rc) {
> diff --git a/utils/nfsdcld/nfsdcld.man b/utils/nfsdcld/nfsdcld.man
> index bad5f34..9ddaf64 100644
> --- a/utils/nfsdcld/nfsdcld.man
> +++ b/utils/nfsdcld/nfsdcld.man
> @@ -160,7 +160,7 @@ Runs the daemon in the foreground and prints all output to stderr
>  Location of the \*(L"cld\*(R" upcall pipe. The default value is
>  \&\fI/var/lib/nfs/rpc_pipefs/nfsd/cld\fR. If the pipe does not exist when the
>  daemon starts then it will wait for it to be created.
> -.IP "\fB\-s\fR \fIstoragedir\fR, \fB\-\-storagedir\fR=\fIstorage_dir\fR" 4
> +.IP "\fB\-s\fR \fIstorage_dir\fR, \fB\-\-storagedir\fR=\fIstorage_dir\fR" 4
>  .IX Item "-s storagedir, --storagedir=storage_dir"
>  Directory where stable storage information should be kept. The default
>  value is \fI/var/lib/nfs/nfsdcld\fR.
> @@ -175,6 +175,11 @@ This daemon requires a kernel that supports the nfsdcld upcall. If the
>  kernel does not support the new upcall, or is using the legacy client
>  name tracking code then it will not create the pipe that nfsdcld uses to
>  talk to the kernel.
> +.PP
> +This daemon should be run as root, as the pipe that it uses to communicate
> +with the kernel is only accessable by root. The daemon however does drop all
> +superuser capabilities after starting. Because of this, the \fIstoragedir\fR
> +should be owned by root, and be readable and writable by owner.
>  .SH "AUTHORS"
>  .IX Header "AUTHORS"
>  The nfsdcld daemon was developed by Jeff Layton <jlayton@redhat.com>.
> diff --git a/utils/nfsdcld/sqlite.c b/utils/nfsdcld/sqlite.c
> index 9e35774..bb2519d 100644
> --- a/utils/nfsdcld/sqlite.c
> +++ b/utils/nfsdcld/sqlite.c
> @@ -54,10 +54,6 @@
>  
>  #define CLD_SQLITE_SCHEMA_VERSION 1
>  
> -#ifndef CLD_SQLITE_TOPDIR
> -#define CLD_SQLITE_TOPDIR NFS_STATEDIR "/nfsdcld"
> -#endif
> -
>  /* in milliseconds */
>  #define CLD_SQLITE_BUSY_TIMEOUT 10000
>  
> @@ -112,7 +108,7 @@ sqlite_maindb_init(char *topdir)
>  	char *err = NULL;
>  	sqlite3_stmt *stmt = NULL;
>  
> -	sqlite_topdir = topdir ? topdir : CLD_SQLITE_TOPDIR;
> +	sqlite_topdir = topdir;
>  
>  	ret = mkdir_if_not_exist(sqlite_topdir);
>  	if (ret)
