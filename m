From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH - nfs-utils] Make sure statd gets started when 'string options' are in use.
Date: Tue, 6 May 2008 17:36:39 -0400
Message-ID: <F7A5F2B8-A400-425C-9D90-EAACC9E5F086@oracle.com>
References: <18463.57567.260973.429439@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:54215 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752183AbYEFVhZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 May 2008 17:37:25 -0400
In-Reply-To: <18463.57567.260973.429439-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 6, 2008, at 12:38 AM, Neil Brown wrote:
> The code for checking and starting statd was only in the binary- 
> options
> branch of the code.
> This moves it into common code.
> ---
> utils/mount/mount.c    |   22 ++++++++++++++++++++--
> utils/mount/nfsmount.c |   11 -----------
> 2 files changed, 20 insertions(+), 13 deletions(-)
>
> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index 5076468..0036caa 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -334,7 +334,8 @@ static void parse_opt(const char *opt, int  
> *mask, char *extra_opts, int len)
>  * standard options (indicated by MS_ bits), and output parameter
>  * "@extra_opts" gets all the filesystem-specific options.
>  */
> -static void parse_opts(const char *options, int *flags, char  
> **extra_opts)
> +static void parse_opts(const char *options, int *flags, char  
> **extra_opts,
> +		       int *lock)
> {
> 	if (options != NULL) {
> 		char *opts = xstrdup(options);
> @@ -358,6 +359,10 @@ static void parse_opts(const char *options, int  
> *flags, char **extra_opts)
> 			/* end of option item or last item */
> 			if (*p == '\0' || *(p + 1) == '\0') {
> 				parse_opt(opt, flags, *extra_opts, len);
> +				if (strcmp(opt, "lock") == 0)
> +					*lock = 1;
> +				if (strcmp(opt, "nolock") == 0)
> +					*lock = 0;
> 				opt = NULL;
> 			}
> 		}
> @@ -421,6 +426,7 @@ int main(int argc, char *argv[])
> 	char *spec, *mount_point, *fs_type = "nfs";
> 	char *extra_opts = NULL, *mount_opts = NULL;
> 	uid_t uid = getuid();
> +	int lock = 1;
>
> 	progname = basename(argv[0]);
>
> @@ -531,7 +537,7 @@ int main(int argc, char *argv[])
> 		goto out;
> 	}
>
> -	parse_opts(mount_opts, &flags, &extra_opts);
> +	parse_opts(mount_opts, &flags, &extra_opts, &lock);
>
> 	if (uid != 0) {
> 		if (!(flags & (MS_USERS|MS_USER))) {
> @@ -546,6 +552,18 @@ int main(int argc, char *argv[])
> 		goto out;
> 	}
>
> +	if (!fake && lock) {
> +		if (!start_statd()) {
> +			nfs_error(_("%s: rpc.statd is not running but is "
> +				"required for remote locking.\n"
> +				"   Either use '-o nolock' to keep "
> +				"locks local, or start statd."),
> +					progname);
> +			mnt_err = EX_FAIL;
> +			goto out;
> +		}
> +	}
> +

You probably want to gate this based on NFS version (ie do the  
checking only for NFSv2/v3 mounts, and not for NFSv4 mounts)

There is already a function in stropts.c (called  
set_mandatory_options) that might be a better place to put the special  
option parsing, as you can use the nice po_* calls, and it already has  
a switch for detecting which NFS version is being requested.

Since the common part of this code (start_statd) is already in a  
helper, I would leave the existing logic in nfsmount.c, and just add a  
handful of lines in stropts.c:set_mandatory_options that worries about  
"lock/nolock" for NFSv2/v3 mounts.

> 	mnt_err = try_mount(spec, mount_point, flags, fs_type, &extra_opts,
> 				mount_opts, fake, nomtab, FOREGROUND);
> 	if (mnt_err == EX_BG) {
> diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
> index 6c0c365..e6ed019 100644
> --- a/utils/mount/nfsmount.c
> +++ b/utils/mount/nfsmount.c
> @@ -851,17 +851,6 @@ noauth_flavors:
>
> 	*extra_opts = xstrdup(new_opts);
>
> -	if (!fake && !(data.flags & NFS_MOUNT_NONLM)) {
> -		if (!start_statd()) {
> -			nfs_error(_("%s: rpc.statd is not running but is "
> -				"required for remote locking.\n"
> -				"   Either use '-o nolock' to keep "
> -				"locks local, or start statd."),
> -					progname);
> -			goto fail;
> -		}
> -	}
> -
> 	if (!fake) {
> 		if (mount(spec, node, "nfs",
> 				flags & ~(MS_USER|MS_USERS), &data)) {
> -- 
> 1.5.5.1

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
