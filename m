Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:49818 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756893Ab3EFUtU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 May 2013 16:49:20 -0400
From: "Adamson, Dros" <Weston.Adamson@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv3: match sec= flavor against server list
Date: Mon, 6 May 2013 20:49:18 +0000
Message-ID: <751BC7B3-A726-4EE3-A4A9-58AFDAEDF283@netapp.com>
References: <1367869268-3741-1-git-send-email-dros@netapp.com>
 <E6F80985-86E0-469A-AD79-433837BBFEC1@oracle.com>
In-Reply-To: <E6F80985-86E0-469A-AD79-433837BBFEC1@oracle.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 6, 2013, at 4:44 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On May 6, 2013, at 3:41 PM, Weston Andros Adamson <dros@netapp.com> wrote:
> 
>> Older linux clients match the 'sec=' mount option flavor against the server's
>> flavor list (if available) and return EPERM if the specified flavor or AUTH_NULL
>> (which "matches" any flavor) is not found.
>> 
>> Recent changes skip this step and allow the vfs mount even though no operations
>> will succeed, creating a 'dud' mount.
>> 
>> This patch reverts back to the old behavior of matching specified flavors
>> against the server list and also returns EPERM when no sec= is specified and
>> none of the flavors returned by the server are supported by the client.
>> 
>> Example of behavior change:
>> 
>> the server's /etc/exports:
>> 
>> /export/krb5      *(sec=krb5,rw,no_root_squash)
>> 
>> old client behavior:
>> 
>> $ uname -a
>> Linux one.apikia.fake 3.8.8-202.fc18.x86_64 #1 SMP Wed Apr 17 23:25:17 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
>> $ sudo mount -v -o sec=sys,vers=3 zero:/export/krb5 /mnt
>> mount.nfs: timeout set for Sun May  5 17:32:04 2013
>> mount.nfs: trying text-based options 'sec=sys,vers=3,addr=192.168.100.10'
>> mount.nfs: prog 100003, trying vers=3, prot=6
>> mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
>> mount.nfs: prog 100005, trying vers=3, prot=17
>> mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
>> mount.nfs: mount(2): Permission denied
>> mount.nfs: access denied by server while mounting zero:/export/krb5
>> 
>> recently changed behavior:
>> 
>> $ uname -a
>> Linux one.apikia.fake 3.9.0-testing+ #2 SMP Fri May 3 20:29:32 EDT 2013 x86_64 x86_64 x86_64 GNU/Linux
>> $ sudo mount -v -o sec=sys,vers=3 zero:/export/krb5 /mnt
>> mount.nfs: timeout set for Sun May  5 17:37:17 2013
>> mount.nfs: trying text-based options 'sec=sys,vers=3,addr=192.168.100.10'
>> mount.nfs: prog 100003, trying vers=3, prot=6
>> mount.nfs: trying 192.168.100.10 prog 100003 vers 3 prot TCP port 2049
>> mount.nfs: prog 100005, trying vers=3, prot=17
>> mount.nfs: trying 192.168.100.10 prog 100005 vers 3 prot UDP port 20048
>> $ ls /mnt
>> ls: cannot open directory /mnt: Permission denied
>> $ sudo ls /mnt
>> ls: cannot open directory /mnt: Permission denied
>> $ sudo df /mnt
>> df: ‘/mnt’: Permission denied
>> df: no file systems processed
>> $ sudo umount /mnt
>> $
>> 
>> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> 
> I don't have any hard objections to this patch, so barring the change to return EACCES,
> 
>  Acked-by: Chuck Lever <chuck.lever@oracle.com>
> 
> Just a nit, perhaps, but...
> 
> I think that the optimization of setting the boolean, so that only one walk through the server list is needed, is premature.  It might be more clear if each test was done independently of the next to make it easier to reorder the tests, fix bugs in each test, and for readers to see exactly what each of these tests do.
> 
> This code is really our only documentation of the security flavor selection process, so making it as clear as possible should be a priority, IMO, over saving a few CPU cycles.
> 

I have no problem with this.  Will post a v4 patch.

-dros

> 
>> ---
>> 
>> Version 2:
>> - now just uses specified flavor when:
>>  - AUTH_NULL is in the server list
>>  - flavor is in the server list
>> 
>> - now returns EPERM when no sec= specified and no client supported flavors are
>>  in the server list
>> 
>> - includes example in the changelog
>> 
>> fs/nfs/super.c | 37 ++++++++++++++++++++++++++++++-------
>> 1 file changed, 30 insertions(+), 7 deletions(-)
>> 
>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>> index eb494f6..0e36807 100644
>> --- a/fs/nfs/super.c
>> +++ b/fs/nfs/super.c
>> @@ -1611,14 +1611,12 @@ out_security_failure:
>> * Select a security flavor for this mount.  The selected flavor
>> * is planted in args->auth_flavors[0].
>> */
>> -static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
>> +static int nfs_select_flavor(struct nfs_parsed_mount_data *args,
>> 			      struct nfs_mount_request *request)
>> {
>> 	unsigned int i, count = *(request->auth_flav_len);
>> 	rpc_authflavor_t flavor;
>> -
>> -	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR)
>> -		goto out;
>> +	bool auth_null_seen = false;
>> 
>> 	/*
>> 	 * The NFSv2 MNT operation does not return a flavor list.
>> @@ -1634,6 +1632,21 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
>> 		goto out_default;
>> 
>> 	/*
>> +	 * If the sec= mount option is used, the specified flavor or AUTH_NULL
>> +	 * must be in the list returned by the server.
>> +	 */
>> +	if (args->auth_flavors[0] != RPC_AUTH_MAXFLAVOR) {
>> +		for (i = 0; i < count; i++) {
>> +			if (args->auth_flavors[0] == request->auth_flavs[i] ||
>> +			    request->auth_flavs[i] == RPC_AUTH_NULL)
>> +				goto out;
>> +		}
>> +		dfprintk(MOUNT, "NFS: auth flavor %d not supported server\n",
>> +			args->auth_flavors[0]);
>> +		goto out_err;
>> +	}
>> +
>> +	/*
>> 	 * RFC 2623, section 2.7 suggests we SHOULD prefer the
>> 	 * flavor listed first.  However, some servers list
>> 	 * AUTH_NULL first.  Avoid ever choosing AUTH_NULL.
>> @@ -1646,6 +1659,7 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
>> 		case RPC_AUTH_UNIX:
>> 			goto out_set;
>> 		case RPC_AUTH_NULL:
>> +			auth_null_seen = true;
>> 			continue;
>> 		default:
>> 			if (rpcauth_get_gssinfo(flavor, &info) == 0)
>> @@ -1653,12 +1667,22 @@ static void nfs_select_flavor(struct nfs_parsed_mount_data *args,
>> 		}
>> 	}
>> 
>> +	if (!auth_null_seen) {
>> +		dfprintk(MOUNT, "NFS: no auth flavors in common with server\n");
>> +		goto out_err;
>> +	}
>> +
>> out_default:
>> -	flavor = RPC_AUTH_UNIX;
>> +	/* use default if flavor not already set */
>> +	flavor = (args->auth_flavors[0] == RPC_AUTH_MAXFLAVOR) ?
>> +		RPC_AUTH_UNIX : args->auth_flavors[0];
>> out_set:
>> 	args->auth_flavors[0] = flavor;
>> out:
>> 	dfprintk(MOUNT, "NFS: using auth flavor %d\n", args->auth_flavors[0]);
>> +	return 0;
>> +out_err:
>> +	return -EPERM;
>> }
>> 
>> /*
>> @@ -1721,8 +1745,7 @@ static int nfs_request_mount(struct nfs_parsed_mount_data *args,
>> 		return status;
>> 	}
>> 
>> -	nfs_select_flavor(args, &request);
>> -	return 0;
>> +	return nfs_select_flavor(args, &request);
>> }
>> 
>> struct dentry *nfs_try_mount(int flags, const char *dev_name,
>> -- 
>> 1.7.12.4 (Apple Git-37)
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 

