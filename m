From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Change default behavior when "sec=" is not specified by user
Date: Tue, 1 Sep 2009 11:10:36 -0400
Message-ID: <7C5C14D9-F315-4DF8-A2F4-C7F0981AC968@oracle.com>
References: <20090901143012.3978.11441.stgit@matisse.1015granger.net> <20090901150545.GA22846@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:60030 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751256AbZIAPKw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 11:10:52 -0400
In-Reply-To: <20090901150545.GA22846@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 1, 2009, at 11:05 AM, J. Bruce Fields wrote:
> On Tue, Sep 01, 2009 at 10:31:38AM -0400, Chuck Lever wrote:
>> Currently the kernel's MNT client always uses AUTH_UNIX if no "sec="
>> mount option was specified.  In the interest of conforming more
>> closely to RFC 2623, teach the MNT client to use the first flavor on
>> the server's returned authflavor list instead of AUTH_UNIX, if "sec="
>> was not specified.
>>
>> When the user does not specify "sec=" :
>>
>> o  For NFSv2 and NFSv4: the default is always AUTH_UNIX (unchanged).
>>
>> o  For NFSv3: if the server does not return an auth flavor list, use
>>    AUTH_UNIX by default; if the server does return a list, use the
>>    first entry on the list by default.
>
> Sounds good, but also:
>
> 	1. Even when sec= is provided, we should probably still check
> 	the passed-in security against the server-returned list.
> 	(Otherwise AUTH_NULL mounts will almost *always* succeed, even
> 	when no subsequent file operation would, thanks to the
> 	allow-AUTH_NULL-on-mount behavior recommended by rfc 2523).
> 	http://marc.info/?l=linux-nfs&m=125088837303339&w=2
>
> 	2. In the absence of sec=, we should probably *not* choose
> 	AUTH_NULL.  (All mountd's before 1.1.3 list AUTH_NULL first on
> 	the returned list, so users with older servers may wonder why a
> 	client upgrade is making files they create suddenly be owned by
> 	nobody.) http://marc.info/?l=linux-nfs&m=125089022306281&w=2
>
> 	3. As a special exception, we should probably allow an explicit
> 	"sec=null" to override #1 above, since ommission of AUTH_NULL
> 	from post-1.1.3 mountd returns will make it otherwise impossible
> 	to mount with AUTH_NULL.
> 	http://marc.info/?l=linux-nfs&m=125113569524411&w=2
>
> Oops, my bad: I see now from the code that you did actually do #1, you
> just didn't mention it above.  OK!
>
> I don't see #2 or #3, though maybe they're already handled  
> somewhere....

No, not in the kernel's MNT client.  #3 seems like a server bug to me,  
though.

> --b.
>
>>
>> See http://marc.info/?t=125075305400001&r=1&w=2 .
>>
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>> Trond, Bruce-
>>
>> Based on last week's e-mail discussion, maybe this should also be
>> included in 2.6.32?
>>
>> fs/nfs/super.c                  |   38 +++++++++++++++++++++++++ 
>> +------------
>> include/linux/sunrpc/msg_prot.h |    2 ++
>> 2 files changed, 28 insertions(+), 12 deletions(-)
>>
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index bde444b..5165847 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -1380,19 +1380,25 @@ static int nfs_walk_authlist(struct  
>> nfs_parsed_mount_data *args,
>> 	 * succeed), revert to pre-2.6.32 behavior (no checking)
>> 	 * if the returned flavor list is empty.
>> 	 */
>> -	if (server_authlist_len == 0)
>> +	if (server_authlist_len == 0) {
>> +		if (args->auth_flavors[0] == RPC_AUTH_UNSPEC)
>> +			args->auth_flavors[0] = RPC_AUTH_UNIX;
>> 		return 0;
>> +	}
>>
>> 	/*
>> -	 * We avoid sophisticated negotiating here, as there are
>> -	 * plenty of cases where we can get it wrong, providing
>> -	 * either too little or too much security.
>> -	 *
>> 	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
>> -	 * flavor listed first.  However, some servers list
>> -	 * AUTH_NULL first.  Our caller plants AUTH_SYS, the
>> -	 * preferred default, in args->auth_flavors[0] if user
>> -	 * didn't specify sec= mount option.
>> +	 * first flavor on the list if the user did not request
>> +	 * a specific flavor.
>> +	 */
>> +	if (args->auth_flavors[0] == RPC_AUTH_UNSPEC) {
>> +		args->auth_flavors[0] = request->auth_flavs[0];
>> +		return 0;
>> +	}
>> +
>> +	/*
>> +	 * Otherwise, check if the user-specified flavor is on the
>> +	 * server's list, and fail the mount if it is not found.
>> 	 */
>> 	for (i = 0; i < args->auth_flavor_len; i++)
>> 		for (j = 0; j < server_authlist_len; j++)
>> @@ -1467,8 +1473,12 @@ static int nfs_try_mount(struct  
>> nfs_parsed_mount_data *args,
>> 	/*
>> 	 * MNTv1 (NFSv2) does not support auth flavor negotiation.
>> 	 */
>> -	if (args->mount_server.version != NFS_MNT3_VERSION)
>> +	if (args->mount_server.version != NFS_MNT3_VERSION) {
>> +		if (args->auth_flavors[0] == RPC_AUTH_UNSPEC)
>> +			args->auth_flavors[0] = RPC_AUTH_UNIX;
>> 		return 0;
>> +	}
>> +
>> 	return nfs_walk_authlist(args, &request);
>> }
>>
>> @@ -1644,7 +1654,7 @@ static int nfs_validate_mount_data(void  
>> *options,
>> 	args->mount_server.port	= NFS_UNSPEC_PORT;
>> 	args->nfs_server.port	= NFS_UNSPEC_PORT;
>> 	args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
>> -	args->auth_flavors[0]	= RPC_AUTH_UNIX;
>> +	args->auth_flavors[0]	= RPC_AUTH_UNSPEC;
>> 	args->auth_flavor_len	= 1;
>> 	args->minorversion	= 0;
>>
>> @@ -1703,6 +1713,7 @@ static int nfs_validate_mount_data(void  
>> *options,
>> 		args->namlen		= data->namlen;
>> 		args->bsize		= data->bsize;
>>
>> +		args->auth_flavors[0] = RPC_AUTH_UNIX;
>> 		if (data->flags & NFS_MOUNT_SECFLAVOUR)
>> 			args->auth_flavors[0] = data->pseudoflavor;
>> 		if (!args->nfs_server.hostname)
>> @@ -2323,6 +2334,8 @@ static int nfs4_validate_text_mount_data(void  
>> *options,
>> 			 "NFS4: Too many RPC auth flavours specified\n");
>> 		return -EINVAL;
>> 	}
>> +	if (args->auth_flavors[0] == RPC_AUTH_UNSPEC)
>> +		args->auth_flavors[0] = RPC_AUTH_UNIX;
>>
>> 	if (args->client_address == NULL) {
>> 		dfprintk(MOUNT,
>> @@ -2358,7 +2371,7 @@ static int nfs4_validate_mount_data(void  
>> *options,
>> 	args->acdirmin		= NFS_DEF_ACDIRMIN;
>> 	args->acdirmax		= NFS_DEF_ACDIRMAX;
>> 	args->nfs_server.port	= NFS_UNSPEC_PORT;
>> -	args->auth_flavors[0]	= RPC_AUTH_UNIX;
>> +	args->auth_flavors[0]	= RPC_AUTH_UNSPEC;
>> 	args->auth_flavor_len	= 1;
>> 	args->minorversion	= 0;
>>
>> @@ -2374,6 +2387,7 @@ static int nfs4_validate_mount_data(void  
>> *options,
>> 		if (!nfs_verify_server_address(sap))
>> 			goto out_no_address;
>>
>> +		args->auth_flavors[0] = RPC_AUTH_UNIX;
>> 		if (data->auth_flavourlen) {
>> 			if (data->auth_flavourlen > 1)
>> 				goto out_inval_auth;
>> diff --git a/include/linux/sunrpc/msg_prot.h b/include/linux/sunrpc/ 
>> msg_prot.h
>> index 77e6248..7d6d3ed 100644
>> --- a/include/linux/sunrpc/msg_prot.h
>> +++ b/include/linux/sunrpc/msg_prot.h
>> @@ -35,6 +35,8 @@ enum rpc_auth_flavors {
>> 	RPC_AUTH_GSS_SPKM  = 390009,
>> 	RPC_AUTH_GSS_SPKMI = 390010,
>> 	RPC_AUTH_GSS_SPKMP = 390011,
>> +	/* flavor was unspecified: */
>> +	RPC_AUTH_UNSPEC = 0xffffffff,
>> };
>>
>> /* Maximum size (in bytes) of an rpc credential or verifier */
>>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



