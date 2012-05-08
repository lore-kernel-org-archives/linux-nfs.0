Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57671 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755917Ab2EHTea (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 May 2012 15:34:30 -0400
Date: Tue, 8 May 2012 15:34:29 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsdcld: add support for dropping capabilities
Message-ID: <20120508193429.GA17669@fieldses.org>
References: <1336491712-29445-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1336491712-29445-1-git-send-email-jlayton@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 08, 2012 at 11:41:52AM -0400, Jeff Layton wrote:
> As a long running daemon, we need to be security-conscious with nfsdcld,
> so let's prune what it can do down to nearly nothing.
> 
> We want the daemon to run as root so that it has access to open and
> reopen the rpc_pipefs pipe, but we don't actually need any of the
> superuser caps that come with it. Have it drop all capabilities early
> on. We don't need any of them as long as the fsuid continues to be 0.

Makes sense to me.

(In practice, though, surely fsuid=0 is often enough to get everything?)

--b.

> 
> Once we do that though, check to ensure that the db dir is actually
> usable by root w/o CAP_DAC_OVERRIDE. Do an access() check on it and
> throw a warning if it's not. Hopefully that will assist users in
> debugging if they get the ownership of the DB dir wrong.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/nfsdcld/Makefile.am |    2 +-
>  utils/nfsdcld/nfsdcld.c   |   82 ++++++++++++++++++++++++++++++++++++++++++++-
>  utils/nfsdcld/sqlite.c    |    6 +---
>  3 files changed, 83 insertions(+), 7 deletions(-)
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
> index 2f0b004..2686183 100644
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
> +	for (i = 0; i <= CAP_LAST_CAP && ret == 0; ++i) {
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
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
