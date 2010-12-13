Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28500 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932234Ab0LMQyQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Dec 2010 11:54:16 -0500
Message-ID: <4D064FB4.1020209@RedHat.com>
Date: Mon, 13 Dec 2010 11:54:12 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] libnsm.a: sm-notify sometimes ignores monitored hosts
References: <20101206160206.18361.26178.stgit@matisse.1015granger.net> <20101206160944.18361.28275.stgit@matisse.1015granger.net>
In-Reply-To: <20101206160944.18361.28275.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Chuck,

On 12/06/2010 11:09 AM, Chuck Lever wrote:
> Monitored host information is stored in files under /var/lib/nfs.
> When visiting entries in the monitored hosts directory, libnsm.a
> examines the value of dirent.d_type to determine if an entry is a
> regular file.
> 
> According to readdir(3), the d_type field is not supported by all
> file system types.  My root file system happens to be one where d_type
> isn't supported.  Typical installations that use an ext-derived root
> file system are not exposed to this issue, but those who use xfs, for
> instance, are.
> 
> On such file systems, not only are remote peers not notified of
> reboots, but the NSM state number is never incremented.  A statd warm
> restart would not re-monitor any hosts that were monitored before
> the restart.
> 
> When writing support/nsm/file.c, I copied the use of d_type from the
> original statd code, so this has likely been an issue for some time.
> 
> Replace the use of d_type in support/nsm/file.c with a call to
> lstat(2).  It's extra code, but is guaranteed to work on all file
> system types.
> 
> Note there is a usage of d_type in gssd.  I'll let gssd and rpcpipefs
> experts decide whether that's worth changing.
> 
> Fix for:
> 
>   https://bugzilla.linux-nfs.org/show_bug.cgi?id=193
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  support/nsm/file.c |   38 ++++++++++++++++++++++++++++++--------
>  1 files changed, 30 insertions(+), 8 deletions(-)
> 
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index f4baeb9..ba2a9ce 100644
> --- a/support/nsm/file.c
> +++ b/support/nsm/file.c
> @@ -568,11 +568,13 @@ nsm_retire_monitored_hosts(void)
>  
>  	while ((de = readdir(dir)) != NULL) {
>  		char *src, *dst;
> +		struct stat stb;
>  
> -		if (de->d_type != (unsigned char)DT_REG)
> -			continue;
> -		if (de->d_name[0] == '.')
> +		if (de->d_name[0] == '.') {
> +			xlog(D_GENERAL, "Skipping dot file %s",
> +					de->d_name);
>  			continue;
> +		}
>  
>  		src = nsm_make_record_pathname(NSM_MONITOR_DIR, de->d_name);
>  		if (src == NULL) {
> @@ -580,6 +582,20 @@ nsm_retire_monitored_hosts(void)
>  			continue;
>  		}
>  
> +		/* NB: not all file systems fill in d_type correctly */
> +		if (lstat(src, &stb) == -1) {
> +			xlog_warn("Bad monitor file %s, skipping: %m",
> +					de->d_name);
> +			free(src);
> +			continue;
> +		}
> +		if (!S_ISREG(stb.st_mode)) {
> +			xlog(D_GENERAL, "Skipping non-regular file %s",
> +					de->d_name);
> +			free(src);
> +			continue;
> +		}
> +
>  		dst = nsm_make_record_pathname(NSM_NOTIFY_DIR, de->d_name);
>  		if (dst == NULL) {
>  			free(src);
> @@ -846,7 +862,7 @@ nsm_read_line(const char *hostname, const time_t timestamp, char *line,
>  }
>  
>  /*
> - * Given a filename, reads data from a file under NSM_MONITOR_DIR
> + * Given a filename, reads data from a file under "directory"
>   * and invokes @func so caller can populate their in-core
>   * database with this data.
>   */
> @@ -863,10 +879,15 @@ nsm_load_host(const char *directory, const char *filename, nsm_populate_t func)
>  	if (path == NULL)
>  		goto out_err;
>  
> -	if (stat(path, &stb) == -1) {
> +	if (lstat(path, &stb) == -1) {
>  		xlog(L_ERROR, "Failed to stat %s: %m", path);
>  		goto out_freepath;
>  	}
> +	if (!S_ISREG(stb.st_mode)) {
> +		xlog(D_GENERAL, "Skipping non-regular file %s",
> +				path);
Question, why do we care non-regular files are being ignored?

I understand logging the lstat() error but logging statements like
"ignoring this" or "not doing that" just make the debug output a 
bit too noisy IMHO... 

I'm thinking it would be better to log the files that 
are actually being used verses files that are being ignored.


> +		goto out_freepath;
> +	}
>  
>  	f = fopen(path, "r");
>  	if (f == NULL) {
> @@ -913,10 +934,11 @@ nsm_load_dir(const char *directory, nsm_populate_t func)
>  	}
>  
>  	while ((de = readdir(dir)) != NULL) {
> -		if (de->d_type != (unsigned char)DT_REG)
> -			continue;
> -		if (de->d_name[0] == '.')
> +		if (de->d_name[0] == '.') {
> +			xlog(D_GENERAL, "Skipping dot file %s",
> +					de->d_name);
The same goes with this... Do we really care "." and ".." are
being ignored? Isn't that expected? ;-)

steved.

>  			continue;
> +		}
>  
>  		count += nsm_load_host(directory, de->d_name, func);
>  	}
> 
