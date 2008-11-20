From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 6/8] NFS: add "[no]resvport" mount option
Date: Thu, 20 Nov 2008 14:42:00 -0500
Message-ID: <C9F7A2D8-98BD-4B90-8830-5DD397F209D8@oracle.com>
References: <20081105202040.14469.32458.stgit@ingres.1015granger.net> <20081105202528.14469.59939.stgit@ingres.1015granger.net> <1227209228.7150.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:17232 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754876AbYKTToA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Nov 2008 14:44:00 -0500
In-Reply-To: <1227209228.7150.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Nov 20, 2008, at Nov 20, 2008, 2:27 PM, Trond Myklebust wrote:
> On Wed, 2008-11-05 at 15:25 -0500, Chuck Lever wrote:
>> The standard default security setting for NFS is AUTH_SYS.  An NFS
>> client connects to NFS servers via a privileged source port and a
>> fixed standard destination port (2049).  The client sends raw uid and
>> gid numbers to identify users making NFS requests, and the server
>> assumes an appropriate authority on the client has vetted these
>> values because the source port is privileged.
>>
>> On Linux, by default in-kernel RPC services use a privileged port in
>> the range between 650 and 1023 to avoid using source ports of well-
>> known IP services.  Using such a small range limits the number of NFS
>> mount points and the number of unique NFS servers to which a client
>> can connect concurrently.
>>
>> An NFS client can use unprivileged source ports to expand the range  
>> of
>> source port numbers, allowing more concurrent server connections and
>> more NFS mount points.  Servers must explicitly allow NFS connections
>> from unprivileged ports for this to work.
>>
>> In the past, bumping the value of the sunrpc.max_resvport sysctl on
>> the client would permit the NFS client to use unprivileged ports.
>> Bumping this setting also changes the maximum port number used by
>> other in-kernel RPC services, some of which still required a port
>> number less than 1023.
>>
>> This is exacerbated by the way source port numbers are chosen by the
>> Linux RPC client, which starts at the top of the range and works
>> downwards.  It means that bumping the maximum means all RPC services
>> requesting a source port will likely get an unprivileged port instead
>> of a privileged one.
>>
>> Changing this setting effects all NFS mount points on a client.  A
>> sysadmin could not selectively choose which mount points would use
>> non-privileged ports and which could not.
>>
>> Lastly, this mechanism of expanding the limit on the number of NFS
>> mount points was entirely undocumented.
>>
>> To address the need for the NFS client to use a large range of source
>> ports without interfering with the activity of other in-kernel RPC
>> services, we introduce a new NFS mount option.  This option  
>> explicitly
>> tells only the NFS client to use a non-privileged source port when
>> communicating with the NFS server for one specific mount point.
>>
>> This new mount option is called "resvport," like the similar NFS  
>> mount
>> option on FreeBSD and Mac OS X.  A sister patch for nfs-utils will be
>> submitted that documents this new option in nfs(5).
>>
>> The default setting for this new mount option requires the NFS client
>> to use a privileged port, as before.  Explicitly specifying the
>> "noresvport" mount option allows the NFS client to use an  
>> unprivileged
>> source port for this mount point when connecting to the NFS server
>> port.
>>
>> This mount option is supported only for text-based NFS mounts.
>>
>> [ Sidebar: it is widely known that security mechanisms based on the
>>  use of privileged source ports are ineffective.  However, the NFS
>>  client can combine the use of unprivileged ports with the use of
>>  secure authentication mechanisms, such as Kerberos.  This allows a
>>  large number of connections and mount points while ensuring a useful
>>  level of security.
>>
>>  Eventually we may change the default setting for this option
>>  depending on the security flavor used for the mount.  For example,
>>  if the mount is using only AUTH_SYS, then the default setting will
>>  be "resvport;" if the mount is using a strong security flavor such
>>  as krb5, the default setting will be "noresvport." ]
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> fs/nfs/client.c           |    9 ++++++---
>> fs/nfs/super.c            |   12 +++++++++++-
>> include/linux/nfs_mount.h |    3 ++-
>> 3 files changed, 19 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>> index 2719033..cd4a174 100644
>> --- a/fs/nfs/client.c
>> +++ b/fs/nfs/client.c
>> @@ -627,7 +627,8 @@ static int nfs_init_client(struct nfs_client  
>> *clp,
>> 	 * Create a client RPC handle for doing FSSTAT with UNIX auth only
>> 	 * - RFC 2623, sec 2.3.2
>> 	 */
>> -	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX, 0, 0);
>> +	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX,
>> +				      0, data->flags & NFS_MOUNT_NORESVPORT);
>> 	if (error < 0)
>> 		goto error;
>> 	nfs_mark_client_ready(clp, NFS_CS_READY);
>> @@ -969,6 +970,7 @@ error:
>> static int nfs4_init_client(struct nfs_client *clp,
>> 		const struct rpc_timeout *timeparms,
>> 		const char *ip_addr,
>> +		const int flags,
>> 		rpc_authflavor_t authflavour)
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>> {
>> 	int error;
>> @@ -983,7 +985,7 @@ static int nfs4_init_client(struct nfs_client  
>> *clp,
>> 	clp->rpc_ops = &nfs_v4_clientops;
>>
>> 	error = nfs_create_rpc_client(clp, timeparms, authflavour,
>> -				      1, 0);
>> +				      1, flags & NFS_MOUNT_NORESVPORT);
>> 	if (error < 0)
>> 		goto error;
>> 	memcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
>> @@ -1034,7 +1036,8 @@ static int nfs4_set_client(struct nfs_server  
>> *server,
>> 		error = PTR_ERR(clp);
>> 		goto error;
>> 	}
>> -	error = nfs4_init_client(clp, timeparms, ip_addr, authflavour);
>> +	error = nfs4_init_client(clp, timeparms, ip_addr, authflavour,
>> +					server->flags);
>                                          ^^^^^^^^^^^^^^^
> 	Hmm... You didn't ever actually test an NFSv4 mount with this patch
> applied, did you?

Perhaps not with the most recent version of this patch, but I do  
expect the compiler to identify problems like this.  Unfortunately not  
the case for simple integer types.

Do you want another version of this patch, or can you fix this yourself?

>> 	if (error < 0)
>> 		goto error_put;
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index 735ff2b..773594f 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -76,6 +76,7 @@ enum {
>> 	Opt_acl, Opt_noacl,
>> 	Opt_rdirplus, Opt_nordirplus,
>> 	Opt_sharecache, Opt_nosharecache,
>> +	Opt_resvport, Opt_noresvport,
>>
>> 	/* Mount options that take integer arguments */
>> 	Opt_port,
>> @@ -130,6 +131,8 @@ static const match_table_t  
>> nfs_mount_option_tokens = {
>> 	{ Opt_nordirplus, "nordirplus" },
>> 	{ Opt_sharecache, "sharecache" },
>> 	{ Opt_nosharecache, "nosharecache" },
>> +	{ Opt_resvport, "resvport" },
>> +	{ Opt_noresvport, "noresvport" },
>>
>> 	{ Opt_port, "port=%u" },
>> 	{ Opt_rsize, "rsize=%u" },
>> @@ -515,7 +518,8 @@ static void nfs_show_mount_options(struct  
>> seq_file *m, struct nfs_server *nfss,
>> 		{ NFS_MOUNT_NONLM, ",nolock", "" },
>> 		{ NFS_MOUNT_NOACL, ",noacl", "" },
>> 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
>> -		{ NFS_MOUNT_UNSHARED, ",nosharecache", ""},
>> +		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
>> +		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
>> 		{ 0, NULL, NULL }
>> 	};
>> 	const struct proc_nfs_info *nfs_infop;
>> @@ -916,6 +920,12 @@ static int nfs_parse_mount_options(char *raw,
>> 		case Opt_nosharecache:
>> 			mnt->flags |= NFS_MOUNT_UNSHARED;
>> 			break;
>> +		case Opt_resvport:
>> +			mnt->flags &= ~NFS_MOUNT_NORESVPORT;
>> +			break;
>> +		case Opt_noresvport:
>> +			mnt->flags |= NFS_MOUNT_NORESVPORT;
>> +			break;
>>
>> 		/*
>> 		 * options that take numeric values
>> diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
>> index 6549a06..4499016 100644
>> --- a/include/linux/nfs_mount.h
>> +++ b/include/linux/nfs_mount.h
>> @@ -45,7 +45,7 @@ struct nfs_mount_data {
>> 	char		context[NFS_MAX_CONTEXT_LEN + 1];	/* 6 */
>> };
>>
>> -/* bits in the flags field */
>> +/* bits in the flags field visible to user space */
>>
>> #define NFS_MOUNT_SOFT		0x0001	/* 1 */
>> #define NFS_MOUNT_INTR		0x0002	/* 1 */ /* now unused, but ABI */
>> @@ -68,5 +68,6 @@ struct nfs_mount_data {
>> /* The following are for internal use only */
>> #define NFS_MOUNT_LOOKUP_CACHE_NONEG	0x10000
>> #define NFS_MOUNT_LOOKUP_CACHE_NONE	0x20000
>> +#define NFS_MOUNT_NORESVPORT		0x40000
>>
>> #endif
>>
> -- 
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




