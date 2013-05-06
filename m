Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:51512 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753874Ab3EFPic convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 11:38:32 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH] NFSv3: match sec= flavor against server list
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <F0D8250F-E63E-40D8-8AA6-77A70A859EBD@netapp.com>
Date: Mon, 6 May 2013 11:38:28 -0400
Cc: "Haynes, Tom" <Tom.Haynes@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <CEC0147F-AC0C-443F-8DC1-FD4CD4DF5AF3@oracle.com>
References: <1367846874-1234-1-git-send-email-dros@netapp.com> <CFCA1AF9-4CC3-46A6-8E08-BAC8BF030146@oracle.com> <5FA4CAE8-023D-4799-A721-F5CD2D4513EF@netapp.com> <0CB40479-AD64-4E36-8D36-C0232E64BABB@oracle.com> <F0D8250F-E63E-40D8-8AA6-77A70A859EBD@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 6, 2013, at 11:34 AM, "Adamson, Dros" <Weston.Adamson@netapp.com> wrote:

> 
> On May 6, 2013, at 11:17 AM, Chuck Lever <chuck.lever@oracle.com>
> wrote:
> 
>> 
>> On May 6, 2013, at 10:49 AM, "Adamson, Dros" <Weston.Adamson@netapp.com> wrote:
>> 
>>> 
>>> On May 6, 2013, at 9:52 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> 
>>>> Hi-
>>>> 
>>>> On May 6, 2013, at 9:27 AM, Weston Andros Adamson <dros@netapp.com> wrote:
>>>> 
>>>>> Older clients match the 'sec=' mount option flavor against the server's
>>>>> flavor list (if available) and return EPERM if the specified flavor is not
>>>>> found. Recent changes would skip this step and allow the vfs mount even
>>>>> though no operations will succeed.
>>>>> 
>>>>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
>>>>> ---
>>>>> 
>>>>> Hey Chuck,
>>>>> 
>>>>> This fixes a regression that was introduced with the recent nfs_select_flavor 
>>>>> changes - I'm pretty sure we want to match the specified flavor instead of just
>>>>> using it.
>>>>> 
>>>>> Example of the regression:
>>>>> 
>>>>> the server's /etc/exports:
>>>>> 
>>>>> /export/krb5      *(sec=krb5,sec=none,rw,no_root_squash)
>>>>> 
>>>>> old client behavior:
>>>>> 
>>>>> $ uname -a
>>>>> Linux one.apikia.fake 3.8.8-202.fc18.x86_64 #1 SMP Wed Apr 17 23:25:17 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
>>>>> $ sudo mount -v -o sec=sys,vers=3 zero:/export/krb5 /mnt
>>>>> mount.nfs: timeout set for Sun May  5 17:32:04 2013
>>>>> mount.nfs: trying text-based options 'sec=sys,vers=3,addr=192.168.100.10'
>>>>> mount.nfs: prog 100003, trying vers=3, prot=6
>>>>> mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
>>>>> mount.nfs: prog 100005, trying vers=3, prot=17
>>>>> mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
>>>>> mount.nfs: mount(2): Permission denied
>>>>> mount.nfs: access denied by server while mounting zero:/export/krb5
>>>> 
>>>> This is wrong behavior, and is fixed by my patch.
>>>> 
>>>>> recently changed behavior:
>>>>> 
>>>>> $ uname -a
>>>>> Linux one.apikia.fake 3.9.0-testing+ #2 SMP Fri May 3 20:29:32 EDT 2013 x86_64 x86_64 x86_64 GNU/Linux
>>>>> $ sudo mount -v -o sec=sys,vers=3 zero:/export/krb5 /mnt
>>>>> mount.nfs: timeout set for Sun May  5 17:37:17 2013
>>>>> mount.nfs: trying text-based options 'sec=sys,vers=3,addr=192.168.100.10'
>>>>> mount.nfs: prog 100003, trying vers=3, prot=6
>>>>> mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
>>>>> mount.nfs: prog 100005, trying vers=3, prot=17
>>>>> mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
>>>>> $ ls /mnt
>>>>> ls: cannot open directory /mnt: Permission denied
>>>>> $ sudo ls /mnt
>>>>> ls: cannot open directory /mnt: Permission denied
>>>>> $ sudo df /mnt
>>>>> df: ‘/mnt’: Permission denied
>>>>> df: no file systems processed
>>>>> $ sudo umount /mnt
>>>>> $
>>>> 
>>>> This is correct behavior.  The server should map the user's AUTH_SYS credential to anonymous.  If anonymous does not have permission on /export/krb5, then the server should prevent its access to the export.
>>> 
>>> You're talking about AUTH_NULL behavior here, right?
>>> 
>>>> 
>>>> I assume this is a Linux NFS server.  Does the Linux server support sec=none listed in the export options in the same way that NetApp and Oracle Solaris do?
>>> 
>>> 
>>> So there are two issues here and I think they're getting confused.
>>> 
>>> The example is of the first issue: mounting a krb5 only export with sec=sys
>>> - client mounts sec=sys
>>> - the server list is [krb5]
>>> - the client completely ignores this list and just uses sys.
>>> - no operations work, it's a 'dud mount'
>>> 
>>> The second issue is the AUTH_NULL stuff - lets just ignore that for now.
>>> 
>>> Are you saying that the client should just use whatever sec= is specified and never try to match against the server list?
>> 
>> That's what my patch does.  The reason for this is that the server can interpret the mount's security flavor any way it likes.
>> 
>> Perhaps we should take that fallback position only if the server lists AUTH_NULL in the flavor list.  If AUTH_NULL is not listed, ensure the flavor requested on the mount command line is available on the server (the most recent previous behavior); fail if no matching flavor is found.
>> 
>> If the mount command line does not specify a flavor, we could look in the server's list for a flavor we support, then fail if none is found.
> 
> If I'm reading this right, that's what this patch does.
> 
> - if no sec= is specified, we look through the servers list for a supported flavor (same behavior as without this patch).

If not found, return -EPERM.

> - if sec= is specified, check the server list
>   - if flavor is found, use it
>   - else if AUTH_NULL is in the list, just use the user specified sec= flavor
>   - else return -EPERM

Unconditionally use the user's flavor if AUTH_NULL is in the list.  So reverse the order of the first two checks.

> Also: if we don't get a server list for whatever reason, just use the specified sec= flavor.

Leave the first checks in nfs_select_flavor() intact, in other words.

> 
> Does that sound right? If so, does the patch look good?
> 
> -dros
> 
>> 
>>> A little background - I ran into this implementing a different patch that makes sure v4.x mounts are actually using the specified flavor (if one exists) to mount the export -- that is, it can follow SECINFOs to do initial lookup, but must be using the specified flavor on the export path passed to mount.  After the initial mount lookup, SECINFOs will be used normally. Trond thought that this was a bug that should be fixed - that it's wrong when client reports that it's using one flavor (as seen in mount output, etc) when it's really using another. This (other) patch works, but when no version is specified, it always falls back to v3 and the mount will always succeed - even if the auth flavor isn't supported by the export.
>>> 
>>> -dros
>>> 
>>> 
>>>> 
>>>>> I also made an attempt to support "AUTH_NULL means the server will ignore the
>>>>> cred, so just use the specified flavor" behavior from much older kernels, but 
>>>>> I'm not sure if we want this logic.
>>>>> 
>>>>> I'd actually prefer getting rid of this AUTH_NULL logic, it's just that some 
>>>>> older clients (RHEL 5, etc) would succeed in mounting when sec=sys specified,
>>>>> server list = [AUTH_NULL] (the client ends up sending AUTH_UNIX creds that are
>>>>> ignored by the server), while newer kernels do not. The workaround in newer
>>>>> kernels is to specify sec=none.
>>>>> 
>>>>> Thoughts?
>>>>> 
>>>>> -dros
>>>>> 
>>>>> fs/nfs/super.c | 39 ++++++++++++++++++++++++++++++++-------
>>>>> 1 file changed, 32 insertions(+), 7 deletions(-)
>>>>> 
>>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>>>> index eb494f6..6476b5d 100644
>>>>> --- a/fs/nfs/super.c
>>>>> +++ b/fs/nfs/super.c
>>>>> @@ -1611,14 +1611,12 @@ out_security_failure:
>>>>> * Select a security flavor for this mount.  The selected flavor
>>>>> * is planted in args->auth_flavors[0].
>>>>> */
>>>>> -static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
>>>>> +static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
>>>>> 			      struct nfs_mount_request *request)
>>>>> {
>>>>> 	unsigned int i, count = *(request->auth_flav_len);
>>>>> 	rpc_authflavor_t flavor;
>>>>> -
>>>>> -	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR)
>>>>> -		goto out;
>>>>> +	bool auth_null_seen = false;
>>>>> 
>>>>> 	/*
>>>>> 	 * The NFSv2 MNT operation does not return a flavor list.
>>>>> @@ -1634,6 +1632,26 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
>>>>> 		goto out_default;
>>>>> 
>>>>> 	/*
>>>>> +	 * If the sec= mount option is used, the flavor must be in the list
>>>>> +	 * returned by the server.
>>>>> +	 *
>>>>> +	 * One exception is when the server's flavor list includes AUTH_NULL:
>>>>> +	 * Some servers implement AUTH_NULL by completely ignoring the rpc
>>>>> +	 * cred, so the client can use any flavor.
>>>>> +	 */
>>>>> +	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
>>>>> +		for (i = 0; i < count; i++) {
>>>>> +			if (args->auth_flavors[0] == request->auth_flavs[i])
>>>>> +				goto out;
>>>>> +			if (request->auth_flavs[i] == RPC_AUTH_NULL)
>>>>> +				auth_null_seen = true;
>>>>> +		}
>>>>> +		if (auth_null_seen)
>>>>> +			goto out;
>>>>> +		goto out_nomatch;
>>>>> +	}
>>>>> +
>>>>> +	/*
>>>>> 	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
>>>>> 	 * flavor listed first.  However, some servers list
>>>>> 	 * AUTH_NULL first.  Avoid ever choosing AUTH_NULL.
>>>>> @@ -1654,11 +1672,19 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
>>>>> 	}
>>>>> 
>>>>> out_default:
>>>>> -	flavor = RPC_AUTH_UNIX;
>>>>> +	/* use default if flavor not already set */
>>>>> +	flavor = (args->auth_flavors[0] == RPC_AUTH_MAXFLAVOR) ?
>>>>> +		RPC_AUTH_UNIX : args->auth_flavors[0];
>>>>> out_set:
>>>>> 	args->auth_flavors[0] = flavor;
>>>>> out:
>>>>> 	dfprintk(MOUNT, "NFS: using auth flavor %d\n", args->auth_flavors[0]);
>>>>> +	return 0;
>>>>> +
>>>>> +out_nomatch:
>>>>> +	dfprintk(MOUNT, "NFS: auth flavor %d not supported by server\n",
>>>>> +		args->auth_flavors[0]);
>>>>> +	return -EPERM;
>>>>> }
>>>>> 
>>>>> /*
>>>>> @@ -1721,8 +1747,7 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
>>>>> 		return status;
>>>>> 	}
>>>>> 
>>>>> -	nfs_select_flavor(args, &request);
>>>>> -	return 0;
>>>>> +	return nfs_select_flavor(args, &request);
>>>>> }
>>>>> 
>>>>> struct dentry *nfs_try_mount(int flags, const char *dev_name,
>>>>> -- 
>>>>> 1.7.12.4 (Apple Git-37)
>>>>> 
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>> 
>>>> --
>>>> Chuck Lever
>>>> chuck[dot]lever[at]oracle[dot]com
>>>> 
>>>> 
>>>> 
>>> 
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> -- 
>> Chuck Lever
>> chuck[dot]lever[at]oracle[dot]com
>> 
>> 
>> 
>> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




