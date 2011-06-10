Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:29505 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932167Ab1FJSjf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 14:39:35 -0400
Subject: Re: [PATCH 5/7] nfs-utils:  Support srcaddr=n option for string mount.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1307729379-7702-6-git-send-email-greearb@candelatech.com>
Date: Fri, 10 Jun 2011 14:39:22 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <B137C1C3-9DC6-48A4-B849-B122ED056124@oracle.com>
References: <1307729379-7702-1-git-send-email-greearb@candelatech.com> <1307729379-7702-6-git-send-email-greearb@candelatech.com>
To: greearb@candelatech.com
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 10, 2011, at 2:09 PM, greearb@candelatech.com wrote:

> From: Ben Greear <greearb@candelatech.com>
> 
> Look for and parse the srcaddr=n argument.  If parsing
> succeeds, pass this down the call chain.  This fully
> implements binding to a specified source address when
> mounting.
> 
> Signed-off-by: Ben Greear <greearb@candelatech.com>
> ---
> :100644 100644 71417df... b02a469... M	utils/mount/stropts.c
> utils/mount/stropts.c |   35 +++++++++++++++++++++++++++++++----
> 1 files changed, 31 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 71417df..b02a469 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -92,6 +92,7 @@ struct nfsmount_info {
> 	int			flags,		/* MS_ flags */
> 				fake,		/* actually do the mount? */
> 				child;		/* forked bg child? */
> +	struct local_bind_info  *local_ip;      /* Local IP binding info */
> };
> 
> #ifdef MOUNT_CONFIG
> @@ -484,7 +485,8 @@ static int nfs_construct_new_options(struct mount_options *options,
>  * FALSE is returned if some failure occurred.
>  */
> static int
> -nfs_rewrite_pmap_mount_options(struct mount_options *options)
> +nfs_rewrite_pmap_mount_options(struct mount_options *options,
> +			       struct local_bind_info *local_ip)
> {
> 	union nfs_sockaddr nfs_address;
> 	struct sockaddr *nfs_saddr = &nfs_address.sa;
> @@ -534,7 +536,8 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
> 	 * negotiate.  Bail now if we can't contact it.
> 	 */
> 	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
> -				 nfs_saddr, nfs_salen, &nfs_pmap, NULL)) {
> +				 nfs_saddr, nfs_salen, &nfs_pmap,
> +				 local_ip)) {
> 		errno = ESPIPE;
> 		if (rpc_createerr.cf_stat == RPC_PROGNOTREGISTERED)
> 			errno = EOPNOTSUPP;
> @@ -589,7 +592,7 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
> }
> 
> static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
> -		struct sockaddr *sap, socklen_t salen)
> +			     struct sockaddr *sap, socklen_t salen)
> {
> 	struct mount_options *options = po_dup(mi->options);
> 	int result = 0;
> @@ -631,7 +634,7 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
> 		printf(_("%s: trying text-based options '%s'\n"),
> 			progname, *mi->extra_opts);
> 
> -	if (!nfs_rewrite_pmap_mount_options(options))
> +	if (!nfs_rewrite_pmap_mount_options(options, mi->local_ip))
> 		goto out_fail;
> 
> 	result = nfs_sys_mount(mi, options);
> @@ -1039,8 +1042,31 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
> 		.flags		= flags,
> 		.fake		= fake,
> 		.child		= child,
> +		.local_ip	= NULL,
> 	};
> 	int retval = EX_FAIL;
> +	char *opt = strstr(*extra_opts, "srcaddr=");
> +	struct local_bind_info local_ip;
> +	memset(&local_ip, 0, sizeof(local_ip));
> +
> +	if (opt) {
> +		char *tmp = xstrdup(opt);
> +		unsigned int i;
> +		int olen = strlen("srcaddr=");
> +		for (i = olen; i < strlen(tmp); i++) {
> +			if (tmp[i] == ',') {
> +				tmp[i] = 0;
> +				break;
> +			}
> +		}
> +		parse_local_bind(&local_ip, tmp + olen);
> +		free(tmp);
> +		if (!local_ip.is_set)
> +			goto fail;
> +	}
> +
> +	if (local_ip.is_set)
> +		mi.local_ip = &local_ip;

This doesn't belong here; it probably goes in nfs_validate_options().

Use the parsing tools that are available for string-based mount options.  Open-coding checks for srcaddr= and dealing with the comma yourself is unnecessary.  For instance, after the po_split() is done, you can just do a po_get(options, "srcaddr") to extract the value of the srcaddr mount option if it exists.

> 	mi.options = po_split(*extra_opts);
> 	if (mi.options) {
> @@ -1049,6 +1075,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
> 	} else
> 		nfs_error(_("%s: internal option parsing error"), progname);
> 
> +fail:
> 	freeaddrinfo(mi.address);
> 	free(mi.hostname);
> 	return retval;
> -- 
> 1.7.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




