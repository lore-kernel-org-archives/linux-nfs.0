From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [Patch 7/10] NFS Mount Configuration File (Vers 3)
Date: Thu, 6 Aug 2009 16:35:44 -0400
Message-ID: <E3DFEA95-A38E-446C-B9AB-3BA7E9837E94@oracle.com>
References: <4A7B2324.9090406@RedHat.com> <4A7B2515.2040304@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:35363 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343AbZHFUgL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Aug 2009 16:36:11 -0400
In-Reply-To: <4A7B2515.2040304-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

How come the short descriptions (Subject:) for all of these patches  
are identical?

On Aug 6, 2009, at 2:46 PM, Steve Dickson wrote:
> commit eab66bd02db90965d1cbf4e100a274a4e3e6e29e
> Author: Steve Dickson <steved@redhat.com>
> Date:   Sun Aug 2 12:37:19 2009 -0400
>
>    Added hooks to the mount command that allow
>    mount options to be set in a configuration file
>
>    Signed-off-by: Steve Dickson <steved@redhat.com>
>
> diff --git a/utils/mount/mount.c b/utils/mount/mount.c
> index a668cd9..30d087e 100644
> --- a/utils/mount/mount.c
> +++ b/utils/mount/mount.c
> @@ -47,6 +47,11 @@
> #include "stropts.h"
> #include "version.h"
>
> +#ifdef MOUNT_CONFIG
> +#include "conffile.h"
> +extern char *conf_get_mntopts(char *, char *, char *);

Can this forward declaration be added to conffile.h ?

> +#endif
> +
> char *progname;
> int nfs_mount_data_version;
> int nomtab;
> @@ -474,6 +479,13 @@ int main(int argc, char *argv[])
> 	spec = argv[1];
> 	mount_point = argv[2];
>
> +#ifdef MOUNT_CONFIG
> +	/*
> +	 * Read the the default mount options
> +	 */
> +	conf_init();
> +#endif

It would be cleaner if the #ifdefs were moved to conf_init() (and  
above, for the #include, and below, into conf_get_mntopts()).  If  
MOUNT_CONFIG isn't set, then configfile.o would just contain stubs,  
but it would then always be built.

Otherwise, we end up with each new feature adding #ifdefs in the  
mainline code, and eventually it becomes unreadable.

> +
> 	argv[2] = argv[0]; /* so that getopt error messages are correct */
> 	while ((c = getopt_long(argc - 2, argv + 2, "rvVwfno:hs",
> 				longopts, NULL)) != -1) {
> @@ -559,6 +571,12 @@ int main(int argc, char *argv[])
> 		mnt_err = EX_USAGE;
> 		goto out;
> 	}
> +#ifdef MOUNT_CONFIG
> +	/*
> +	 * Concatenate mount options from the configuration file
> +	 */
> +	mount_opts = conf_get_mntopts(spec, mount_point, mount_opts);
> +#endif
>
> 	parse_opts(mount_opts, &flags, &extra_opts);

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
