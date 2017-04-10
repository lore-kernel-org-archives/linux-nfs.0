Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56702 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752877AbdDJNgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Apr 2017 09:36:50 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 0F6F031F3F4
        for <linux-nfs@vger.kernel.org>; Mon, 10 Apr 2017 13:36:50 +0000 (UTC)
Subject: Re: [nfs-utils PATCH v3 3/4] blkmapd: allow the rpc_pipefs mountpoint
 to be overridden
To: Scott Mayhew <smayhew@redhat.com>
References: <20170406163104.28397-1-smayhew@redhat.com>
 <20170406163104.28397-4-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <80d09057-7798-2c2d-a8fe-a75bfa480e56@RedHat.com>
Date: Mon, 10 Apr 2017 09:36:47 -0400
MIME-Version: 1.0
In-Reply-To: <20170406163104.28397-4-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/06/2017 12:31 PM, Scott Mayhew wrote:
> Allow the rpc_pipefs mountpoint to be overriden via the pipefs-directory
> variable in the [general] section of /etc/nfs.conf.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed...

steved.
> ---
>  systemd/nfs.conf.man             |  3 ++-
>  utils/blkmapd/blkmapd.man        | 17 ++++++++++++++-
>  utils/blkmapd/device-discovery.c | 47 ++++++++++++++++++++++++++++++++--------
>  3 files changed, 56 insertions(+), 11 deletions(-)
> 
> diff --git a/systemd/nfs.conf.man b/systemd/nfs.conf.man
> index 1a72da0..189b052 100644
> --- a/systemd/nfs.conf.man
> +++ b/systemd/nfs.conf.man
> @@ -101,7 +101,8 @@ Recognized values:
>  .BR pipefs-directory .
>  
>  See
> -.BR rpc.idmapd (8)
> +.BR blkmapd (8),
> +.BR rpc.idmapd (8),
>  and
>  .BR rpc.gssd (8)
>  for details.
> diff --git a/utils/blkmapd/blkmapd.man b/utils/blkmapd/blkmapd.man
> index 914b80f..4b3d3f0 100644
> --- a/utils/blkmapd/blkmapd.man
> +++ b/utils/blkmapd/blkmapd.man
> @@ -43,9 +43,24 @@ Performs device discovery only then exits.
>  Runs
>  .B blkmapd
>  in the foreground and sends output to stderr (as opposed to syslogd)
> +.SH CONFIGURATION FILE
> +The
> +.B blkmapd
> +daemon recognizes the following value from the
> +.B [general]
> +section of the
> +.I /etc/nfs.conf
> +configuration file:
> +.TP
> +.B pipefs-directory
> +Tells
> +.B blkmapd
> +where to look for the rpc_pipefs filesystem.  The default value is
> +.IR /var/lib/nfs/rpc_pipefs .
>  .SH SEE ALSO
>  .BR nfs (5),
> -.BR dmsetup (8)
> +.BR dmsetup (8),
> +.BR nfs.conf (5)
>  .sp
>  RFC 5661 for the NFS version 4.1 specification.
>  .br
> diff --git a/utils/blkmapd/device-discovery.c b/utils/blkmapd/device-discovery.c
> index 8eb3fd0..d2da764 100644
> --- a/utils/blkmapd/device-discovery.c
> +++ b/utils/blkmapd/device-discovery.c
> @@ -50,20 +50,36 @@
>  #include <errno.h>
>  #include <libdevmapper.h>
>  
> +#ifdef HAVE_CONFIG_H
> +#include "config.h"
> +#endif /* HAVE_CONFIG_H */
> +
>  #include "device-discovery.h"
>  #include "xcommon.h"
> +#include "nfslib.h"
> +#include "conffile.h"
>  
>  #define EVENT_SIZE (sizeof(struct inotify_event))
>  #define EVENT_BUFSIZE (1024 * EVENT_SIZE)
>  
> -#define BL_PIPE_FILE	"/var/lib/nfs/rpc_pipefs/nfs/blocklayout"
> -#define NFSPIPE_DIR	"/var/lib/nfs/rpc_pipefs/nfs"
>  #define RPCPIPE_DIR	"/var/lib/nfs/rpc_pipefs"
>  #define PID_FILE	"/var/run/blkmapd.pid"
>  
> +#define CONF_SAVE(w, f) do {			\
> +	char *p = f;				\
> +	if (p != NULL)				\
> +		(w) = p;			\
> +} while (0)
> +
> +static char bl_pipe_file[PATH_MAX];
> +static char nfspipe_dir[PATH_MAX];
> +static char rpcpipe_dir[PATH_MAX];
> +
>  struct bl_disk *visible_disk_list;
>  int    bl_watch_fd, bl_pipe_fd, nfs_pipedir_wfd, rpc_pipedir_wfd;
>  int    pidfd = -1;
> +char   *conf_path = NULL;
> +
>  
>  struct bl_disk_path *bl_get_path(const char *filepath,
>  				 struct bl_disk_path *paths)
> @@ -358,8 +374,8 @@ static void bl_rpcpipe_cb(void)
>  				continue;
>  			if (event->mask & IN_CREATE) {
>  				BL_LOG_WARNING("nfs pipe dir created\n");
> -				bl_watch_dir(NFSPIPE_DIR, &nfs_pipedir_wfd);
> -				bl_pipe_fd = open(BL_PIPE_FILE, O_RDWR);
> +				bl_watch_dir(nfspipe_dir, &nfs_pipedir_wfd);
> +				bl_pipe_fd = open(bl_pipe_file, O_RDWR);
>  			} else if (event->mask & IN_DELETE) {
>  				BL_LOG_WARNING("nfs pipe dir deleted\n");
>  				inotify_rm_watch(bl_watch_fd, nfs_pipedir_wfd);
> @@ -372,7 +388,7 @@ static void bl_rpcpipe_cb(void)
>  				continue;
>  			if (event->mask & IN_CREATE) {
>  				BL_LOG_WARNING("blocklayout pipe file created\n");
> -				bl_pipe_fd = open(BL_PIPE_FILE, O_RDWR);
> +				bl_pipe_fd = open(bl_pipe_file, O_RDWR);
>  				if (bl_pipe_fd < 0)
>  					BL_LOG_ERR("open %s failed: %s\n",
>  						event->name, strerror(errno));
> @@ -437,6 +453,19 @@ int main(int argc, char **argv)
>  {
>  	int opt, dflag = 0, fg = 0, ret = 1;
>  	char pidbuf[64];
> +	char *xrpcpipe_dir = NULL;
> +
> +	strncpy(rpcpipe_dir, RPCPIPE_DIR, sizeof(rpcpipe_dir));
> +	conf_path = NFS_CONFFILE;
> +	conf_init();
> +	CONF_SAVE(xrpcpipe_dir, conf_get_str("general", "pipefs-directory"));
> +	if (xrpcpipe_dir != NULL)
> +		strlcpy(rpcpipe_dir, xrpcpipe_dir, sizeof(rpcpipe_dir));
> +
> +	strncpy(nfspipe_dir, rpcpipe_dir, sizeof(nfspipe_dir));
> +	strlcat(nfspipe_dir, "/nfs", sizeof(nfspipe_dir));
> +	strncpy(bl_pipe_file, rpcpipe_dir, sizeof(bl_pipe_file));
> +	strlcat(bl_pipe_file, "/nfs/blocklayout", sizeof(bl_pipe_file));
>  
>  	while ((opt = getopt(argc, argv, "hdf")) != -1) {
>  		switch (opt) {
> @@ -496,12 +525,12 @@ int main(int argc, char **argv)
>  	}
>  
>  	/* open pipe file */
> -	bl_watch_dir(RPCPIPE_DIR, &rpc_pipedir_wfd);
> -	bl_watch_dir(NFSPIPE_DIR, &nfs_pipedir_wfd);
> +	bl_watch_dir(rpcpipe_dir, &rpc_pipedir_wfd);
> +	bl_watch_dir(nfspipe_dir, &nfs_pipedir_wfd);
>  
> -	bl_pipe_fd = open(BL_PIPE_FILE, O_RDWR);
> +	bl_pipe_fd = open(bl_pipe_file, O_RDWR);
>  	if (bl_pipe_fd < 0)
> -		BL_LOG_ERR("open pipe file %s failed: %s\n", BL_PIPE_FILE, strerror(errno));
> +		BL_LOG_ERR("open pipe file %s failed: %s\n", bl_pipe_file, strerror(errno));
>  
>  	while (1) {
>  		/* discover device when needed */
> 
