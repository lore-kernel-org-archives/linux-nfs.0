From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 06/26] statd: Introduce common routines to handle
 persistent storage
Date: Fri, 16 Oct 2009 10:05:44 -0400
Message-ID: <20091016100544.25f686c4@tlielax.poochiereds.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
	<20091013145506.2424.10505.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, chris.mason@oracle.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754249AbZJPOGR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Oct 2009 10:06:17 -0400
In-Reply-To: <20091013145506.2424.10505.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 13 Oct 2009 10:55:06 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> rpc.statd and sm-notify access the same set of files under
> /var/lib/nfs/statd, but both have their own code base to handle this.
> They should share this code.
> 
> In addition, the on-disk format used by statd and friends is
> considered a formal interface, so this new code will codify the API
> and provide documentation for it.
> 
> The shared code handles switching from the default parent statd
> directory, reducing privileges at start-up, and managing the NSM
> state files, in addition to handling normal operations on the
> monitored host and notification lists on disk.
> 
> The new code is simply a copy of the same logic that was used in
> rpc.statd and sm-notify, but wrapped in a nice API.  There should be
> minimal behavioral and no on-disk format changes with the new
> libnsm.a code.
> 
> The new code is more careful to check for bad corner cases.
> Occassionally this code may not allow an operation that was permitted
> in the past, but hopefully the error reporting has improved enough
> that it should be easy to track down any problems.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  support/include/Makefile.am |    1 
>  support/include/nsm.h       |   62 +++
>  support/nsm/Makefile.am     |    2 
>  support/nsm/file.c          |  774 +++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 838 insertions(+), 1 deletions(-)
>  create mode 100644 support/include/nsm.h
>  create mode 100644 support/nsm/file.c
> 
> diff --git a/support/include/Makefile.am b/support/include/Makefile.am
> index f5a77ec..027f37f 100644
> --- a/support/include/Makefile.am
> +++ b/support/include/Makefile.am
> @@ -9,6 +9,7 @@ noinst_HEADERS = \
>  	nfs_mntent.h \
>  	nfs_paths.h \
>  	nfslib.h \
> +	nsm.h \
>  	rpcmisc.h \
>  	tcpwrapper.h \
>  	xio.h \
> diff --git a/support/include/nsm.h b/support/include/nsm.h
> new file mode 100644
> index 0000000..594f0d9
> --- /dev/null
> +++ b/support/include/nsm.h
> @@ -0,0 +1,62 @@
> +/*
> + * Copyright 2009 Oracle.  All rights reserved.
> + *
> + * This file is part of nfs-utils.
> + *
> + * nfs-utils is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * nfs-utils is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +/*
> + * NSM for Linux.
> + */
> +
> +#ifndef _NFS_UTILS_SUPPORT_NSM_H
> +#define _NFS_UTILS_SUPPORT_NSM_H
> +
> +#include <sys/types.h>
> +#include <sys/socket.h>
> +
> +#include <netdb.h>
> +#include <time.h>
> +
> +#include "sm_inter.h"
> +
> +typedef unsigned int
> +		(*nsm_populate_t)(const char *hostname,
> +				const struct sockaddr *sap,
> +				const struct mon *mon,
> +				const time_t timestamp);
> +
> +/* file.c */
> +
> +extern int	nsm_setup_pathnames(const char *progname, const char *parentdir);
> +extern int	nsm_is_default_parentdir(void);
> +extern int	nsm_drop_privileges(const int pidfd);
> +
> +extern int	nsm_get_state(int update);
> +extern void	nsm_update_kernel_state(const int state);
> +
> +extern unsigned int
> +		nsm_retire_monitored_hosts(void);
> +extern unsigned int
> +		nsm_load_monitor_list(nsm_populate_t func);
> +extern unsigned int
> +		nsm_load_notify_list(nsm_populate_t func);
> +
> +extern int	nsm_insert_monitored_host(const char *hostname,
> +			const struct sockaddr *sap, const struct mon *mon);
> +extern void	nsm_delete_monitored_host(const char *hostname);
> +extern void	nsm_delete_notified_host(const char *hostname);
> +
> +#endif	/* !_NFS_UTILS_SUPPORT_NSM_H */
> diff --git a/support/nsm/Makefile.am b/support/nsm/Makefile.am
> index 4b8110d..e359a43 100644
> --- a/support/nsm/Makefile.am
> +++ b/support/nsm/Makefile.am
> @@ -10,7 +10,7 @@ GENFILES	= $(GENFILES_CLNT) $(GENFILES_SVC) $(GENFILES_XDR) $(GENFILES_H)
>  EXTRA_DIST	= sm_inter.x
>  
>  noinst_LIBRARIES = libnsm.a
> -libnsm_a_SOURCES = $(GENFILES)
> +libnsm_a_SOURCES = $(GENFILES) file.c
>  
>  BUILT_SOURCES = $(GENFILES)
>  
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> new file mode 100644
> index 0000000..83680f9
> --- /dev/null
> +++ b/support/nsm/file.c
> @@ -0,0 +1,774 @@
> +/*
> + * Copyright 2009 Oracle.  All rights reserved.
> + *
> + * This file is part of nfs-utils.
> + *
> + * nfs-utils is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + *
> + * nfs-utils is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
> + */
> +
> +/*
> + * NSM for Linux.
> + *
> + * Callback information and NSM state is stored in files, usually
> + * under /var/lib/nfs.  A database of information contained in local
> + * files stores NLM callback data and what remote peers to notify of
> + * reboots.
> + *
> + * For each monitored remote peer, a text file is created under the
> + * directory specified by NSM_MONITOR_DIR.  The name of the file
> + * is a valid DNS hostname.  The hostname string must be a valid
> + * ASCII DNS name, and must not contain slash characters, white space,
> + * or '\0' (ie. anything that might have some special meaning in a
> + * path name).
> + *
> + * The contents of each file include seven blank-separated fields of
> + * text, finished with '\n'.  The first field contains the network
> + * address of the NLM service to call back.  The current implementation
> + * supports using only IPv4 addresses, so the only contents of this
> + * field are a network order IPv4 address expressed in 8 hexadecimal
> + * characters.
> + *
> + * The next four fields are text strings of hexadecimal characters,
> + * representing:
> + *
> + * 2. A 4 byte RPC program number of the NLM service to call back
> + * 3. A 4 byte RPC version number of the NLM service to call back
> + * 4. A 4 byte RPC procedure number of the NLM service to call back
> + * 5. A 16 byte opaque cookie that the NLM service uses to identify
> + *    the monitored host
> + *
> + * The sixth field is the monitored host's mon_name, passed to statd
> + * via an SM_MON request.
> + *
> + * The seventh field is the my_name for this peer, which is the
> + * hostname of the local NLM (currently on Linux, the result of
> + * `uname -n`).  This can be used as the source address/hostname
> + * when sending SM_NOTIFY requests.
> + *
> + * The NSM protocol does not limit the contents of these strings
> + * in any way except that they must fit into 1024 bytes.  Our
> + * implementation requires that these strings not contain
> + * white space or '\0'.
> + */
> +
> +#ifdef HAVE_CONFIG_H
> +#include <config.h>
> +#endif
> +
> +#include <sys/types.h>
> +#include <sys/stat.h>
> +
> +#include <ctype.h>
> +#include <stdint.h>
> +#include <unistd.h>
> +#include <libgen.h>
> +#include <stdio.h>
> +#include <errno.h>
> +#include <fcntl.h>
> +#include <dirent.h>
> +#include <grp.h>
> +
> +#include "xlog.h"
> +#include "nsm.h"
> +
> +#define NSM_KERNEL_STATE_FILE	"/proc/sys/fs/nfs/nsm_local_state"
> +
> +/*
> + * Some distributions place statd's files in a subdirectory
> + */
> +#define NSM_PATH_EXTENSION
> +//#define NSM_PATH_EXTENSION	"/statd"
> +
> +#ifdef NFS_STATEDIR
> +#define NSM_DEFAULT_STATEDIR		NFS_STATEDIR NSM_PATH_EXTENSION
> +#else	/* !defined(NFS_STATEDIR) */
> +#define NSM_DEFAULT_STATEDIR		"/var/lib/nfs" NSM_PATH_EXTENSION
> +#endif	/* !defined(NFS_STATEDIR) */
> +
> +static char nsm_base_dirname[PATH_MAX] = NSM_DEFAULT_STATEDIR;
> +
> +#define NSM_MONITOR_DIR	"sm"
> +#define NSM_NOTIFY_DIR	"sm.bak"
> +#define NSM_STATE_FILE	"state"
> +
> +
> +static int
> +__error_check(const int len, const size_t buflen)
> +{
> +	return (len < 0) || ((size_t)len >= buflen);
> +}
> +
> +static int
> +__exact_error_check(const ssize_t len, const size_t buflen)
> +{
> +	return (len < 0) || ((size_t)len != buflen);
> +}
> +
> +/*
> + * Returns a dynamically allocated, '\0'-terminated buffer
> + * containing an appropriate pathname.  
> + *
> + * Caller must free the returned result.
> + */
> +static char *
> +nsm_make_record_pathname(const char *dirname, const char *hostname)
> +{
> +	const char *c;
> +	size_t size;
> +	char *path;
> +	int len;
> +
> +	/*
> +	 * Block hostnames that contain characters that have
> +	 * meaning to the file system (like '/').
> +	 */
> +	for (c = hostname; *c != '\0'; c++)
> +		if (*c == '/' || isspace(*c)) {
> +			xlog(D_GENERAL, "Hostname contains invalid characters");
> +			return NULL;
> +		}
> +
> +	size = strlen(nsm_base_dirname) + strlen(dirname) + strlen(hostname) + 3;
> +	if (size > PATH_MAX) {
> +		xlog(D_GENERAL, "Hostname results in pathname that is too long");
> +		return NULL;
> +	}
> +
> +	path = malloc(size);
> +	if (path == NULL) {
> +		xlog(D_GENERAL, "Failed to allocate memory for pathname");
> +		return NULL;
> +	}
> +
> +	len = snprintf(path, size, "%s/%s/%s",
> +			nsm_base_dirname, dirname, hostname);
> +	if (__error_check(len, size)) {
> +		xlog(D_GENERAL, "Pathname did not fit in specified buffer");
> +		free(path);
> +		return NULL;
> +	}
> +
> +	return path;
> +}
> +
> +/*
> + * Returns a dynamically allocated, '\0'-terminated buffer
> + * containing an appropriate pathname.  
> + *
> + * Caller must free the returned result.
> + */
> +static char *
> +nsm_make_pathname(const char *dirname)
> +{
> +	size_t size;
> +	char *path;
> +	int len;
> +
> +	size = strlen(nsm_base_dirname) + strlen(dirname) + 2;
> +	if (size > PATH_MAX)
> +		return NULL;
> +
> +	path = malloc(size);
> +	if (path == NULL)
> +		return NULL;
> +
> +	len = snprintf(path, size, "%s/%s", nsm_base_dirname, dirname);
> +	if (__error_check(len, size)) {
> +		free(path);
> +		return NULL;
> +	}
> +
> +	return path;
> +}
> +
> +/**
> + * nsm_setup_pathnames - set up pathname
> + * @progname: C string containing name of program, for error messages
> + * @parentdir: C string containing pathname to on-disk state, or NULL
> + *
> + * This runs before logging is set up, so errors are directed to stderr.
> + *
> + * Returns 1 and sets up our pathnames, if @parentdir was valid;
> + * otherwise 0 is returned.
> + */
> +int
> +nsm_setup_pathnames(const char *progname, const char *parentdir)
> +{
> +	static char buf[PATH_MAX];
> +	struct stat st;
> +	char *path;
> +
> +	/* First: test length of name and whether it exists */
> +	if (lstat(parentdir, &st) == -1) {
> +		fprintf(stderr, "%s: Failed to stat %s: %m",
> +				progname, parentdir);
> +		return 0;
> +	}
> +
> +	/* Ensure we have a clean directory pathname */
> +	strncpy(buf, parentdir, sizeof(buf));
> +	path = dirname(buf);
> +	if (*path == '.') {
> +		fprintf(stderr, "%s: Unusable directory %s", progname, parentdir);
> +		return 0;
> +	}
> +
> +	strncpy(nsm_base_dirname, path, sizeof(nsm_base_dirname));
> +	return 1;
> +}
> +
> +/**
> + * nsm_is_default_parentdir - check if parent directory is default
> + *
> + * Returns 1 if the active statd parent directory, set by
> + * nsm_change_pathname(), is the same as the built-in default
> + * parent directory.
> + */
> +int
> +nsm_is_default_parentdir(void)
> +{
> +	return strcmp(nsm_base_dirname, NSM_DEFAULT_STATEDIR) == 0;
> +}
> +
> +/**
> + * nsm_drop_privileges - drop root privileges
> + * @pidfd: file descriptor of a pid file
> + *
> + * Returns 1 if successful, or 0 if some error occurred.
> + *
> + * Set our effective UID and GID to that of our on-disk database.
> + */
> +int
> +nsm_drop_privileges(const int pidfd)
> +{
> +	struct stat st;
> +
> +	(void)umask(S_IRWXO);
> +
> +	/*
> +	 * XXX: If we can't stat dirname, or if dirname is owned by
> +	 *      root, we should use "statduser" instead, which is set up
> +	 *      by configure.ac.  Nothing in nfs-utils seems to use
> +	 *      "statduser," though.
> +	 */
> +	if (lstat(nsm_base_dirname, &st) == -1) {
> +		xlog(L_ERROR, "Failed to stat %s: %m", nsm_base_dirname);
> +		return 0;
> +	}
> +
> +	if (st.st_uid == 0) {
> +		xlog_warn("Running as root.  "
> +			"chown %s to choose different user", nsm_base_dirname);
> +		return 1;
> +	}
> +
> +	if (chdir(nsm_base_dirname) == -1) {
> +		xlog(L_ERROR, "Failed to change working directory to %s: %m",
> +				nsm_base_dirname);
> +		return 0;
> +	}
> +
> +	/*
> +	 * If the pidfile happens to reside on NFS, dropping privileges
> +	 * will probably cause us to lose access, even though we are
> +	 * holding it open.  Chown it to prevent this.
> +	 */
> +	if (pidfd >= 0)
> +		if (fchown(pidfd, st.st_uid, st.st_gid) == -1)
> +			xlog_warn("Failed to change owner of pidfile: %m");
> +
> +	if (setgroups(0, NULL) == -1) {
> +		xlog(L_ERROR, "Failed to drop supplementary groups: %m");
> +		return 0;
> +	}
> +
> +	/*
> +	 * ORDER
> +	 *
> +	 * setgid(2) first, as setuid(2) may remove privileges needed
> +	 * to set the group id.
> +	 */
> +	if (setgid(st.st_gid) == -1 || setuid(st.st_uid) == -1) {
> +		xlog(L_ERROR, "Failed to drop privileges: %m");
> +		return 0;
> +	}
> +
> +	xlog(D_CALL, "Effective UID, GID: %u, %u", st.st_uid, st.st_gid);
> +	return 1;
> +}
> +
> +/**
> + * nsm_get_state - retrieve on-disk NSM state number
> + *
> + * Returns an odd NSM state number read from disk, or an initial
> + * state number.  Zero is returned if some error occurs.
> + */
> +int
> +nsm_get_state(int update)
> +{
> +	int fd, state = 0;
> +	ssize_t result;
> +	char *path = NULL;
> +	char *newpath = NULL;
> +
> +	path = nsm_make_pathname(NSM_STATE_FILE);
> +	if (path == NULL) {
> +		xlog(L_ERROR, "Failed to create NSM state path name");
> +		goto out;
> +	}
> +
> +	fd = open(path, O_RDONLY);
> +	if (fd < 0) {
> +		if (errno != ENOENT) {
> +			xlog(L_ERROR, "Failed to open NSM state file %s: %m",
> +					path);
> +			goto out;
> +		}
> +
> +		xlog(L_NOTICE, "Initializing NSM state");
> +		state = 1;
> +		update = 1;
> +		goto update;
> +	}
> +
> +	result = read(fd, &state, sizeof(state));
> +	if (__exact_error_check(result, sizeof(state))) {
> +		xlog_warn("Failed to read NSM state file %s: %m",
> +				path);
> +		xlog(L_NOTICE, "Initializing NSM state");
> +		state = 1;
> +		update = 1;
> +		goto update;
> +	}
> +
> +	if (!(state & 1))
> +		state++;
> +
> +update:
> +	(void)close(fd);
> +
> +	if (update) {
> +		char *newpath;
> +
> +		state += 2;
> +
> +		newpath = nsm_make_pathname(NSM_STATE_FILE ".new");
> +		if (path == NULL) {
> +			xlog(L_ERROR, "Failed to create new NSM state path name");
> +			state = 0;
> +			goto out;
> +		}
> +
> +		fd = open(newpath, O_CREAT | O_SYNC | O_WRONLY, 0644);
> +		if (fd < 0) {
> +			xlog(L_ERROR, "Failed to create NSM state file %s: %m",
> +					newpath);
> +			state = 0;
> +			goto out;
> +		}
> +
> +		result = write(fd, &state, sizeof(state));
> +		if (__exact_error_check(result, sizeof(state))) {
> +			xlog(L_ERROR, "Failed to write NSM state file %s: %m",
> +					newpath);
> +			(void)close(fd);
> +			state = 0;
> +			goto out;
> +		}
> +
> +		if (close(fd) == -1) {
> +			xlog(L_ERROR, "Failed to close NSM state file %s: %m",
> +					newpath);
> +			state = 0;
> +			goto out;
> +		}
> +
> +		if (rename(newpath, path) < 0) {
> +			xlog(L_ERROR, "Failed to rename NSM state file %s: %m",
> +					newpath);
> +			state = 0;
> +			goto out;
> +		}
> +
> +		/* Ostensibly, a sync(2) is not needed here because
> +		 * open(O_CREAT), write(O_SYNC), and rename(2) are
> +		 * already synchronous with persistant storage, for
> +		 * any file system we care about. */
> +	}
> +
> +out:
> +	free(newpath);
> +	free(path);
> +	return state;
> +}
> +
> +/**
> + * nsm_update_kernel_state - attempt to post new NSM state to kernel
> + * @state: NSM state number
> + *
> + */
> +void
> +nsm_update_kernel_state(const int state)
> +{
> +	ssize_t result;
> +	char buf[20];
> +	int fd, len;
> +
> +	fd = open(NSM_KERNEL_STATE_FILE, O_WRONLY);
> +	if (fd < 0) {
> +		xlog(D_GENERAL, "Failed to open kernel NSM state file "
> +				NSM_KERNEL_STATE_FILE ": %m");
> +		return;
> +	}
> +
> +	len = snprintf(buf, sizeof(buf), "%d", state);
> +	if (__error_check(len, sizeof(buf))) {
> +		xlog_warn("Failed to form NSM state number string");
> +		return;
> +	}
> +
> +	result = write(fd, buf, strlen(buf));
> +	if (__exact_error_check(result, strlen(buf)))
> +		xlog_warn("Failed to write NSM state number: %m");
> +
> +	if (close(fd) == -1)
> +		xlog(L_ERROR, "Failed to close NSM state file "
> +				NSM_KERNEL_STATE_FILE ": %m");
> +}
> +
> +/**
> + * nsm_retire_monitored_hosts - back up all hosts from "sm/" to "sm.bak/"
> + *
> + * Returns the count of host records that were moved.
> + *
> + * Note that if any error occurs during this process, some monitor
> + * records may be left in the "sm" directory.
> + */
> +unsigned int
> +nsm_retire_monitored_hosts(void)
> +{
> +	unsigned int count = 0;
> +	struct dirent *de;
> +	char *path;
> +	DIR *dir;
> +
> +	path = nsm_make_pathname(NSM_MONITOR_DIR);
> +	if (path == NULL) {
> +		xlog(L_ERROR, "Failed to allocate path for " NSM_MONITOR_DIR);
> +		return count;
> +	}
> +
> +	dir = opendir(path);
> +	free(path);
> +	if (dir == NULL) {
> +		xlog_warn("Failed to open " NSM_MONITOR_DIR ": %m");
> +		return count;
> +	}
> +
> +	while ((de = readdir(dir)) != NULL) {
> +		char *src, *dst;
> +
> +		if (de->d_type != DT_REG)
> +			continue;
> +		if (de->d_name[0] == '.')
> +			continue;
> +
> +		src = nsm_make_record_pathname(NSM_MONITOR_DIR, de->d_name);
> +		if (src == NULL) {
> +			xlog_warn("Bad monitor file name, skipping");
> +			continue;
> +		}
> +
> +		dst = nsm_make_record_pathname(NSM_NOTIFY_DIR, de->d_name);
> +		if (dst == NULL) {
> +			free(src);
> +			xlog_warn("Bad notify file name, skipping");
> +			continue;
> +		}
> +
> +		if (rename(src, dst) < 0)
> +			xlog_warn("Failed to rename %s -> %s: %m",
> +				src, dst);
> +		else {
> +			xlog(D_GENERAL, "Retired record for mon_name %s",
> +					de->d_name);
> +			count++;
> +		}
> +
> +		free(dst);
> +		free(src);
> +	}
> +
> +	closedir(dir);
> +	return count;
> +}
> +
> +/**
> + * nsm_insert_monitored_host - write callback data for one host to disk
> + * @hostname: C string containing a hostname
> + * @sap: sockaddr containing NLM callback address
> + * @mon: SM_MON arguments to save
> + *
> + * Returns 1 if successful, otherwise 0 if some error occurs.
> + */
> +int
> +nsm_insert_monitored_host(const char *hostname, const struct sockaddr *sap,
> +		const struct mon *mon)
> +{
> +	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
> +	static char line[4096];
> +	char *c, *path;
> +	int result;
> +	ssize_t len;
> +	int i, fd;
> +
> +	path = nsm_make_record_pathname(NSM_MONITOR_DIR, hostname);
> +	if (path == NULL) {
> +		xlog(L_ERROR, "Failed to insert: bad monitor hostname '%s'",
> +				hostname);
> +		return 0;
> +	}
> +
> +	fd = open(path, O_WRONLY | O_CREAT | O_SYNC, S_IRUSR | S_IWUSR);
> +	if (fd < 0) {
> +		xlog(L_ERROR, "Failed to insert: creating %s: %m", path);
> +		return 0;
> +	}
> +
> +	c = line + sprintf(line, "%08x %08x %08x %08x ",
> +			sin->sin_addr.s_addr,
> +			mon->mon_id.my_id.my_prog,
> +			mon->mon_id.my_id.my_vers,
> +			mon->mon_id.my_id.my_proc);
> +
> +	for (i = 0; i < SM_PRIV_SIZE; i++)
> +		c += sprintf(c, "%02x", 0xff & mon->priv[i]);
> +
> +	c += sprintf(c, " %s %s\n", mon->mon_id.mon_name,
> +			mon->mon_id.my_id.my_name);
> +
> +	result = 1;
> +	len = write(fd, line, c - line);
> +	if (__exact_error_check(len, c - line)) {
> +		xlog_warn("Failed to insert: writing %s: %m", path);
> +		(void)unlink(path);
> +		result = 0;
> +	}
> +
> +	if (close(fd) == -1) {
> +		xlog(L_ERROR, "Failed to insert: closing %s: %m", path);
> +		(void)unlink(path);
> +		result = 0;
> +	}
> +
> +	free(path);
> +	return result;
> +}
> +
> +/*
> + * Stuff a 'struct mon' with callback data, and call @func.
> + *
> + * Returns the count of in-core records created.
> + */
> +static unsigned int
> +nsm_parse_line(const char *hostname, const time_t timestamp, char *line,
> +		nsm_populate_t func)
> +{
> +	struct sockaddr_in sin = {
> +		.sin_family	= AF_INET,
> +	};
> +	struct mon mon;
> +	int count, i;
> +	char *c;
> +
> +	c = strchr(line, '\n');
> +	if (c)
> +		*c = '\0';
> +
> +	count = sscanf(line, "%8x %8x %8x %8x ",
> +			&sin.sin_addr.s_addr,
> +			&mon.mon_id.my_id.my_prog,
> +			&mon.mon_id.my_id.my_vers,
> +			&mon.mon_id.my_id.my_proc);
> +	if (count != 4)
> +		return 0;
> +
> +	c = line + 36;
> +	for (i = 0; i < SM_PRIV_SIZE; i++) {
> +		unsigned int tmp;
> +		if (sscanf(c, "%2x", &tmp) != 1)
> +			return 0;
> +		mon.priv[i] = tmp;
> +		c += 2;
> +	}
> +

^^^
I think we need some bounds checking here. There doesn't seem to be any
guarantee that the line we read in from the "db" is a particular
length. A check to verify that before trying to convert the cookie
would be good.

> +	c++;
> +	mon.mon_id.mon_name = c;
> +	while (*c && *c != ' ')
> +		c++;
> +	if (*c)
> +		*c++ = '\0';
> +	while (*c == ' ')
> +		c++;
> +	mon.mon_id.my_id.my_name = c;
> +
> +	return func(hostname, (struct sockaddr *)&sin, &mon, timestamp);
> +}
> +
> +/*
> + * Given a filename, reads data from a file under NSM_MONITOR_DIR
> + * and invokes @func so caller can populate their in-core
> + * database with this data.
> + */
> +static unsigned int
> +nsm_load_host(const char *dirname, const char *filename, nsm_populate_t func)
> +{
> +	char *path, *line = NULL;
> +	unsigned int result = 0;
> +	struct stat stb;
> +	size_t len = 0;
> +	FILE *f;
> +
> +	path = nsm_make_record_pathname(dirname, filename);
> +	if (path == NULL)
> +		goto out_err;
> +
> +	if (stat(path, &stb) < 0) {
> +		xlog(L_ERROR, "Failed to stat %s: %m", path);
> +		goto out_freepath;
> +	}
> +
> +	f = fopen(path, "r");
> +	if (f == NULL) {
> +		xlog(L_ERROR, "Failed to open %s: %m", path);
> +		goto out_freepath;
> +	}
> +
> +	if (getline(&line, &len, f) == -1) {
> +		xlog(L_ERROR, "Failed to read %s: %m", path);
> +		goto out_close;
> +	}
> +
> +	result = nsm_parse_line(filename, stb.st_mtime, line, func);
> +	if (!result)
> +		xlog(L_ERROR, "Bad callback data in %s", path);
> +	free(line);
> +
> +out_close:
> +	fclose(f);
> +out_freepath:
> +	free(path);
> +out_err:
> +	return result;
> +}
> +
> +static unsigned int
> +nsm_load_dir(const char *dirname, nsm_populate_t func)
> +{
> +	unsigned int count;
> +	struct dirent *de;
> +	char *path;
> +	DIR *dir;
> +
> +	path = nsm_make_pathname(dirname);
> +	if (path == NULL) {
> +		xlog(L_ERROR, "Failed to allocate path for directory %s",
> +				dirname);
> +		return 0;
> +	}
> +
> +	dir = opendir(path);
> +	free(path);
> +	if (dir == NULL) {
> +		xlog(L_ERROR, "Failed to open directory %s: %m",
> +				dirname);
> +		return 0;
> +	}
> +
> +	count = 0;
> +	while ((de = readdir(dir)) != NULL) {
> +		if (de->d_type != DT_REG)
> +			continue;
> +		if (de->d_name[0] == '.')
> +			continue;
> +
> +		count += nsm_load_host(dirname, de->d_name, func);
> +	}
> +
> +	closedir(dir);
> +	return count;
> +}
> +
> +/**
> + * nsm_load_monitor_list - load list of hosts to monitor
> + * @func: callback function to create entry for one host
> + *
> + * Returns the count of hosts that were found in the directory.
> + */
> +unsigned int
> +nsm_load_monitor_list(nsm_populate_t func)
> +{
> +	return nsm_load_dir(NSM_MONITOR_DIR, func);
> +}
> +
> +/**
> + * nsm_load_notify_list - load list of hosts to notify
> + * @func: callback function to create entry for one host
> + *
> + * Returns the count of hosts that were found in the directory.
> + */
> +unsigned int
> +nsm_load_notify_list(nsm_populate_t func)
> +{
> +	return nsm_load_dir(NSM_NOTIFY_DIR, func);
> +}
> +
> +static void
> +nsm_delete_host(const char *dirname, const char *hostname)
> +{
> +	char *path;
> +
> +	path = nsm_make_record_pathname(dirname, hostname);
> +	if (path == NULL) {
> +		xlog(L_ERROR, "Bad filename, not deleting");
> +		return;
> +	}
> +
> +	if (unlink(path) == -1)
> +		xlog(L_ERROR, "Failed to unlink %s: %m", path);
> +
> +	free(path);
> +}
> +
> +/**
> + * nsm_delete_monitored_host - delete on-disk record for monitored host
> + * @hostname: '\0'-terminated C string containing hostname of record to delete
> + *
> + */
> +void
> +nsm_delete_monitored_host(const char *hostname)
> +{
> +	nsm_delete_host(NSM_MONITOR_DIR, hostname);
> +}
> +
> +/**
> + * nsm_delete_notified_host - delete on-disk host record after notification
> + * @hostname: '\0'-terminated C string containing hostname of record to delete
> + *
> + */
> +void
> +nsm_delete_notified_host(const char *hostname)
> +{
> +	nsm_delete_host(NSM_NOTIFY_DIR, hostname);
> +}
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Jeff Layton <jlayton@redhat.com>
