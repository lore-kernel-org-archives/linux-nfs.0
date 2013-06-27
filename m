Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:12586 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752067Ab3F0PJn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jun 2013 11:09:43 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Jeff Layton <jlayton@poochiereds.net>
CC: Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>
Subject: Re: [PATCH v2 3/3] nfs: have NFSv3 try server-specified auth
 flavors in turn
Date: Thu, 27 Jun 2013 15:09:42 +0000
Message-ID: <5CD5BC0D-885F-4DE1-A14A-5F89FACDFED6@netapp.com>
References: <1372275936-5360-1-git-send-email-jlayton@redhat.com>
 <1372275936-5360-4-git-send-email-jlayton@redhat.com>
 <439BCBA0-852B-4F83-802B-57BD86B3B0EB@oracle.com>
 <20130627090059.797c3e01@corrin.poochiereds.net>
 <20130627101421.34f2e0c7@tlielax.poochiereds.net>
In-Reply-To: <20130627101421.34f2e0c7@tlielax.poochiereds.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I think this looks reasonable. I agree with Jeff's use of bools - we don't want to try AUTH_UNIX twice.

I am currently cleaning up a patchset that adds support for multiple security flavors passed through mount with the same syntax as /etc/exports, i.e. sec=krb5:krb5i.  The initial motivation of the patchset is to handle crossing SECINFO boundaries in a sane way. Currently you could be mounted with krb5p, then follow a SECINFO to using AUTH_UNIX for a submount which is pretty confusing to users. This patchset will limit the client to mount-specified flavors when following a SECINFO (or any flavor if no sec= was specified).

Part of this patchset modifies how we track mount specified auth flavors - including keeping a list of parsed auth flavors that doesn't change (no more overwriting auth_flavor[0]).  I'll work this patch into my branch and hopefully will be able to clean up some of this logic.

-dros


On Jun 27, 2013, at 10:14 AM, Jeff Layton <jlayton@poochiereds.net> wrote:

> On Thu, 27 Jun 2013 09:00:59 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> 
>> On Wed, 26 Jun 2013 16:42:39 -0400
>> Chuck Lever <chuck.lever@oracle.com> wrote:
>> 
>>> 
>>> On Jun 26, 2013, at 3:45 PM, Jeff Layton <jlayton@redhat.com> wrote:
>>> 
>>>> The current scheme is to try and pick the auth flavor that the server
>>>> prefers. In some cases though, we may find that we're not actually
>>>> able to use that auth flavor later. For instance, the server may
>>>> prefer an AUTH_GSS flavor, but we may not be able to get GSSAPI creds.
>>>> 
>>>> The current code just gives up at that point. Change it instead to
>>>> try the ->create_server call using each of the different authflavors
>>>> in the server's list if one was not specified at mount time. Once
>>>> we have a successful ->create_server call, return the result. Only
>>>> give up and return error if all attempts fail.
>>> 
>>> Overall, looks about right.  Thanks for retaining the dprintk's!  Should Cc: Dros on these as well, since he was the last person to touch this code.
>>> 
>>> More below.
>>> 
>> 
>> Thanks for the review so far. Replies inline below...
>> 
>>>> 
>>>> Cc: Chuck Lever <chuck.lever@oracle.com>
>>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>>> ---
>>>> fs/nfs/super.c | 148 +++++++++++++++++++++++++++++++--------------------------
>>>> 1 file changed, 80 insertions(+), 68 deletions(-)
>>>> 
>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>>> index a0949f5..53ea73d 100644
>>>> --- a/fs/nfs/super.c
>>>> +++ b/fs/nfs/super.c
>>>> @@ -1608,29 +1608,20 @@ out_security_failure:
>>>> }
>>>> 
>>>> /*
>>>> - * Select a security flavor for this mount.  The selected flavor
>>>> - * is planted in args->auth_flavors[0].
>>>> - *
>>>> - * Returns 0 on success, -EACCES on failure.
>>>> + * Ensure that the specified authtype in args->auth_flavors[0] is supported by
>>>> + * the server. Returns 0 if it's ok, and -EACCES if not.
>>>> */
>>>> -static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
>>>> -			      struct nfs_mount_request *request)
>>>> +static int nfs_verify_authflavor(struct nfs_parsed_mount_data *args,
>>>> +			rpc_authflavor_t *server_authlist, unsigned int count)
>>>> {
>>>> -	unsigned int i, count = *(request->auth_flav_len);
>>>> -	rpc_authflavor_t flavor;
>>>> -
>>>> -	/*
>>>> -	 * The NFSv2 MNT operation does not return a flavor list.
>>>> -	 */
>>>> -	if (args->mount_server.version != NFS_MNT3_VERSION)
>>>> -		goto out_default;
>>>> +	int i;
>>> 
>>> count is unsigned, therefore i must also be.  Otherwise you get mixed sign comparisons in the for() loops.
>>> 
>> 
>> Thanks, fixed...
>> 
>>>> 
>>>> 	/*
>>>> -	 * Certain releases of Linux's mountd return an empty
>>>> -	 * flavor list in some cases.
>>>> +	 * The NFSv2 MNT operation does not return a flavor list and certain
>>>> +	 * releases of Linux's mountd return an empty flavor list in some cases.
>>>> 	 */
>>>> -	if (count == 0)
>>>> -		goto out_default;
>>>> +	if (args->mount_server.version != NFS_MNT3_VERSION || count == 0)
>>>> +		goto out;
>>> 
>>> The above chunk (except the function name change) seems like unnecessary churn.
>>> 
>>> We leave these checks separate from each other for clarity and because they are not logically related to each other, even if the outcome is the same.  Keep each check a separate, independent step with its own documentation.
>>> 
>> 
>> Ok, fair enough. I've reverted that consolidation and kept it more or less as-is.
>> 
>>>> 
>>>> 	/*
>>>> 	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
>>>> @@ -1640,60 +1631,19 @@ static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
>>>> 	 * means that the server will ignore the rpc creds, so any flavor
>>>> 	 * can be used.
>>>> 	 */
>>>> -	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
>>>> -		for (i = 0; i < count; i++) {
>>>> -			if (args->auth_flavors[0] == request->auth_flavs[i] ||
>>>> -			    request->auth_flavs[i] == RPC_AUTH_NULL)
>>>> -				goto out;
>>>> -		}
>>>> -		dfprintk(MOUNT, "NFS: auth flavor %d not supported by server\n",
>>>> -			args->auth_flavors[0]);
>>>> -		goto out_err;
>>>> -	}
>>>> -
>>>> -	/*
>>>> -	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
>>>> -	 * flavor listed first.  However, some servers list
>>>> -	 * AUTH_NULL first.  Avoid ever choosing AUTH_NULL.
>>>> -	 */
>>>> 	for (i = 0; i < count; i++) {
>>>> -		struct rpcsec_gss_info info;
>>>> -
>>>> -		flavor = request->auth_flavs[i];
>>>> -		switch (flavor) {
>>>> -		case RPC_AUTH_UNIX:
>>>> -			goto out_set;
>>>> -		case RPC_AUTH_NULL:
>>>> -			continue;
>>>> -		default:
>>>> -			if (rpcauth_get_gssinfo(flavor, &info) == 0)
>>>> -				goto out_set;
>>>> -		}
>>>> -	}
>>>> -
>>>> -	/*
>>>> -	 * As a last chance, see if the server list contains AUTH_NULL -
>>>> -	 * if it does, use the default flavor.
>>>> -	 */
>>>> -	for (i = 0; i < count; i++) {
>>>> -		if (request->auth_flavs[i] == RPC_AUTH_NULL)
>>>> -			goto out_default;
>>>> +		if (args->auth_flavors[0] == server_authlist[i] ||
>>>> +		    server_authlist[i] == RPC_AUTH_NULL)
>>>> +			goto out;
>>>> 	}
>>>> 
>>>> -	dfprintk(MOUNT, "NFS: no auth flavors in common with server\n");
>>>> -	goto out_err;
>>>> +	dfprintk(MOUNT, "NFS: auth flavor %u not supported by server\n",
>>>> +		args->auth_flavors[0]);
>>>> +	return -EACCES;
>>>> 
>>>> -out_default:
>>>> -	/* use default if flavor not already set */
>>>> -	flavor = (args->auth_flavors[0] == RPC_AUTH_MAXFLAVOR) ?
>>>> -		RPC_AUTH_UNIX : args->auth_flavors[0];
>>>> -out_set:
>>>> -	args->auth_flavors[0] = flavor;
>>>> out:
>>>> -	dfprintk(MOUNT, "NFS: using auth flavor %d\n", args->auth_flavors[0]);
>>>> +	dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
>>>> 	return 0;
>>>> -out_err:
>>>> -	return -EACCES;
>>>> }
>>>> 
>>>> /*
>>>> @@ -1756,13 +1706,16 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
>>>> 		return status;
>>>> 	}
>>>> 
>>>> -	return nfs_select_flavor(args, &request);
>>>> +	return 0;
>>>> }
>>>> 
>>>> static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_info,
>>>> 					struct nfs_subversion *nfs_mod)
>>>> {
>>>> -	int status;
>>>> +	int status, i;
>>> 
>>> As above, if authlist_len is unsigned, then i should be too.
>>> 
>> 
>> Fixed...
>> 
>>>> +	bool tried_auth_unix = false;
>>>> +	bool auth_null_in_list = false;
>>>> +	struct nfs_server *server = ERR_PTR(-EACCES);
>>>> 	struct nfs_parsed_mount_data *args = mount_info->parsed;
>>>> 	rpc_authflavor_t authlist[NFS_MAX_SECFLAVORS];
>>>> 	unsigned int authlist_len = ARRAY_SIZE(authlist);
>>>> @@ -1772,6 +1725,65 @@ static struct nfs_server *nfs_try_mount_request(struct nfs_mount_info *mount_inf
>>>> 	if (status)
>>>> 		return ERR_PTR(status);
>>>> 
>>>> +	/*
>>>> +	 * If the server's authlist is empty, and no sec= option was specified
>>>> +	 * then just default to AUTH_UNIX.
>>>> +	 */
>>>> +	if (args->auth_flavors[0] == RPC_AUTH_MAXFLAVOR &&
>>>> +	    (args->mount_server.version != NFS_MNT3_VERSION || authlist_len == 0)) {
>>>> +		dfprintk(MOUNT, "NFS: No authflavor specified, and no server list.");
>>>> +		args->auth_flavors[0] = RPC_AUTH_UNIX;
>>>> +	}
>>> 
>>> Why duplicate these checks?
>>> 
>> 
>> They're not duplicated (exactly).
>> 
>> When we have no authlist from the server, we need to set auth_flavor[0]
>> to something valid that we can try to use since iterating over the list
>> won't work at that point. Once we have auth_flavor[0] set to something,
>> we then call nfs_verify_authflavor to validate that it's usable.
>> 
>> So, yes we are doing those checks twice, but they serve different
>> purposes.
>> 
>>>> +
>>>> +	/*
>>>> +	 * Was a sec= authflavor specified in the options? First, verify
>>>> +	 * whether the server supports it, and then just try to use it if so.
>>>> +	 */
>>>> +	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
>>>> +		status = nfs_verify_authflavor(args, authlist, authlist_len);
>>>> +		dfprintk(MOUNT, "NFS: using auth flavor %u\n", args->auth_flavors[0]);
>>>> +		if (status)
>>>> +			return ERR_PTR(status);
>>>> +		return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
>>>> +	}
>>>> +
>>>> +	/*
>>>> +	 * No sec= option was provided. RFC 2623, section 2.7 suggests we
>>>> +	 * SHOULD prefer the flavor listed first. However, some servers list
>>>> +	 * AUTH_NULL first. Avoid ever choosing AUTH_NULL.
>>>> +	 */
>>>> +	for (i = 0; i < authlist_len; ++i) {
>>>> +		rpc_authflavor_t flavor;
>>>> +		struct rpcsec_gss_info info;
>>>> +
>>>> +		flavor = authlist[i];
>>>> +		switch (flavor) {
>>>> +		case RPC_AUTH_UNIX:
>>>> +			tried_auth_unix = true;
>>>> +			break;
>>>> +		case RPC_AUTH_NULL:
>>>> +			auth_null_in_list = true;
>>> 
>>> I think I complained about this when Dros proposed a similar optimization last month.  I'd rather not have this extra boolean here.  It makes the logic more fragile to have the next check below depend on this loop.  If someone decides to move or alter this loop, then it can silently break the check below.
>>> 
>>> The boolean feels like premature optimization especially because the flavor list is always short, and the check below is executed very infrequently.
>>> 
>>> The NFSv3 mount code will always be one giant heuristic.  IMO, the best approach is making the source code as plain as possible, rather than defaulting to our normal kernel style of terse, compact code.
>>> 
>> 
>> I don't know...the booleans seem a lot clearer to me. I can have the
>> code rewalk the list, but I'm not sure I buy the argument that it helps
>> future-proof this code. Anyone modifying this had _better_ understand
>> the logic first. ;)
>> 
> 
> Actually, now that I look, I'm not sure we can reasonably get away
> without using some sort of bool here. We only want to try using
> RPC_AUTH_UNIX if we haven't already tried it -- there's no point in
> trying it twice. If we rewalk the list and don't track what was done in
> the earlier loop, then we have to assume that just because it was in
> the list that we already tried it.
> 
> So, I think that keeping track of what was done in the earlier loop
> will be *more* resilient in the face of future changes, since that
> assumption is rather subtle. Besides, I like my bikesheds blue. ;)
> 
> 
>> 
>>>> +			continue;
>>>> +		default:
>>>> +			if (rpcauth_get_gssinfo(flavor, &info) != 0)
>>>> +				continue;
>>>> +		}
>>>> +		dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", flavor);
>>>> +		args->auth_flavors[0] = flavor;
>>>> +		server = nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
>>>> +		if (!IS_ERR(server))
>>>> +			return server;
>>>> +	}
>>>> +
>>>> +	/*
>>>> +	 * Nothing we tried so far worked. As a last ditch effort, try to use
>>>> +	 * AUTH_UNIX if we haven't already, and AUTH_NULL was in server's list.
>>>> +	 */
>>>> +	if (tried_auth_unix || !auth_null_in_list)
>>>> +		return server;
>>> 
>>> It would be more clear and less leaky if you "return ERR_PTR(-EACCES);" here, maybe?
>>> 
>> 
>> Possibly, though that means that you're then assuming that the last
>> call to ->create_server returned -EACCES. I'm not sure it's valid to
>> assume that.
>> 
>> I think it would be best to return whatever it ended up returning, and
>> only return an explicit -EACCES if we never called create_server at all
>> in the loop. The fact that we initialize server to ERR_PTR(-EACCES)
>> makes that work in this patch.
>> 
>> After all, in the !need_mount case, we end up returning whatever
>> ->create_server returned. If it's not valid to let that error bubble
>> up, then the place to fix that is in nfs_try_mount.
>> 
>>>> +
>>>> +	dfprintk(MOUNT, "NFS: attempting to use auth flavor %u\n", RPC_AUTH_UNIX);
>>>> +	args->auth_flavors[0] = RPC_AUTH_UNIX;
>>>> 	return nfs_mod->rpc_ops->create_server(mount_info, nfs_mod);
>>>> }
>>> 
>> 
> 
> 
> -- 
> Jeff Layton <jlayton@poochiereds.net>

