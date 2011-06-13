Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300Ab1FMUh2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2011 16:37:28 -0400
Message-ID: <4DF67506.5050704@RedHat.com>
Date: Mon, 13 Jun 2011 16:37:26 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: greearb@candelatech.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 4/6] nfs-utils:  Support srcaddr=n option for string
 mount.
References: <1307740096-19933-1-git-send-email-greearb@candelatech.com> <1307740096-19933-5-git-send-email-greearb@candelatech.com> <D9DC610C-5620-403C-BF0A-CCD37AFAF4BB@oracle.com>
In-Reply-To: <D9DC610C-5620-403C-BF0A-CCD37AFAF4BB@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/10/2011 06:07 PM, Chuck Lever wrote:
> 
> On Jun 10, 2011, at 5:08 PM, greearb@candelatech.com wrote:
> 
>> From: Ben Greear <greearb@candelatech.com>
>>
>> Look for and parse the srcaddr=n argument.  If parsing
>> succeeds, pass this down the call chain.  This fully
>> implements binding to a specified source address when
>> mounting.
>>
>> Signed-off-by: Ben Greear <greearb@candelatech.com>
>> ---
>> :100644 100644 71417df... aba4252... M	utils/mount/stropts.c
>> utils/mount/stropts.c |   29 +++++++++++++++++++++++++----
>> 1 files changed, 25 insertions(+), 4 deletions(-)
>>
>> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
>> index 71417df..aba4252 100644
>> --- a/utils/mount/stropts.c
>> +++ b/utils/mount/stropts.c
>> @@ -92,6 +92,7 @@ struct nfsmount_info {
>> 	int			flags,		/* MS_ flags */
>> 				fake,		/* actually do the mount? */
>> 				child;		/* forked bg child? */
>> +	struct local_bind_info  *local_ip;      /* Local IP binding info */
>> };
>>
>> #ifdef MOUNT_CONFIG
>> @@ -345,6 +346,7 @@ static int nfs_validate_options(struct nfsmount_info *mi)
>> 	};
>> 	sa_family_t family;
>> 	int error;
>> +	char *option;
>>
>> 	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
>> 		return 0;
>> @@ -371,6 +373,20 @@ static int nfs_validate_options(struct nfsmount_info *mi)
>> 					mi->address->ai_addrlen, mi->options))
>> 		return 0;
>>
>> +	option = po_get(mi->options, "srcaddr");
>> +	if (option) {
>> +		struct local_bind_info *local_ip;
>> +		local_ip = malloc(sizeof(*local_ip));
>> +		memset(local_ip, 0, sizeof(*local_ip));
>> +		parse_local_bind(local_ip, option);
> 
> Nit: Steve may not agree with this, possibly, but it is better IMO if we name new functions like parse_local_bind() with an nfs_ prefix so that, when debugging, we can immediately tell in a backtrace what functions are in mount.nfs and which are in a system library.
I do agree... We might as well stay with the naming convention
that already been established... 

steved.
 
> 
>> +
>> +		if (!local_ip->is_set) {
>> +			free(local_ip);
>> +			return 0;
>> +		}
>> +		mi->local_ip = local_ip;
>> +	}
> 
> I'm wondering what kind of sanity checking is done on the srcaddr value.
> 
> 1.  Do we verify that srcaddr == clientaddr?
> 
> 2.  Do we verify that srcaddr.sa_family == addr.sa_family ?
> 
>> +
>> 	return 1;
>> }
>>
>> @@ -484,7 +500,8 @@ static int nfs_construct_new_options(struct mount_options *options,
>>  * FALSE is returned if some failure occurred.
>>  */
>> static int
>> -nfs_rewrite_pmap_mount_options(struct mount_options *options)
>> +nfs_rewrite_pmap_mount_options(struct mount_options *options,
>> +			       struct local_bind_info *local_ip)
>> {
>> 	union nfs_sockaddr nfs_address;
>> 	struct sockaddr *nfs_saddr = &nfs_address.sa;
>> @@ -534,7 +551,8 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
>> 	 * negotiate.  Bail now if we can't contact it.
>> 	 */
>> 	if (!nfs_probe_bothports(mnt_saddr, mnt_salen, &mnt_pmap,
>> -				 nfs_saddr, nfs_salen, &nfs_pmap, NULL)) {
>> +				 nfs_saddr, nfs_salen, &nfs_pmap,
>> +				 local_ip)) {
>> 		errno = ESPIPE;
>> 		if (rpc_createerr.cf_stat == RPC_PROGNOTREGISTERED)
>> 			errno = EOPNOTSUPP;
>> @@ -589,7 +607,7 @@ static int nfs_sys_mount(struct nfsmount_info *mi, struct mount_options *opts)
>> }
>>
>> static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
>> -		struct sockaddr *sap, socklen_t salen)
>> +			     struct sockaddr *sap, socklen_t salen)
>> {
>> 	struct mount_options *options = po_dup(mi->options);
>> 	int result = 0;
>> @@ -631,7 +649,7 @@ static int nfs_do_mount_v3v2(struct nfsmount_info *mi,
>> 		printf(_("%s: trying text-based options '%s'\n"),
>> 			progname, *mi->extra_opts);
>>
>> -	if (!nfs_rewrite_pmap_mount_options(options))
>> +	if (!nfs_rewrite_pmap_mount_options(options, mi->local_ip))
>> 		goto out_fail;
>>
>> 	result = nfs_sys_mount(mi, options);
>> @@ -1039,6 +1057,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
>> 		.flags		= flags,
>> 		.fake		= fake,
>> 		.child		= child,
>> +		.local_ip	= NULL,
>> 	};
>> 	int retval = EX_FAIL;
>>
>> @@ -1051,5 +1070,7 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
>>
>> 	freeaddrinfo(mi.address);
>> 	free(mi.hostname);
>> +	if (mi.local_ip)
>> +		free(mi.local_ip);
> 
> Nit: free(3) works when passed NULL, you don't need the extra "if (mi.local_ip)" in front of it.
> 
>> 	return retval;
>> }
>> -- 
>> 1.7.3.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
