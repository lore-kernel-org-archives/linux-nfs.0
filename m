Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:30199 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab3F1UQ5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jun 2013 16:16:57 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH 2/5] NFS: Use root's credential for lease management when keytab is missing
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1372450273.20188.7.camel@leira.trondhjem.org>
Date: Fri, 28 Jun 2013 16:16:52 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <EFB58A3D-9B17-486B-9653-3983ADBDB5E2@oracle.com>
References: <20130625162233.36416.34947.stgit@seurat.1015granger.net> <20130625162336.36416.51324.stgit@seurat.1015granger.net> <1372450273.20188.7.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 28, 2013, at 4:11 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-06-25 at 12:23 -0400, Chuck Lever wrote:
>> Commit 05f4c350 "NFS: Discover NFSv4 server trunking when mounting"
>> Fri Sep 14 17:24:32 2012 introduced Uniform Client String support,
>> which forces our NFS client to establish a client ID immediately
>> during a mount operation rather than waiting until a user wants to
>> open a file.
>> 
>> Normally machine credentials (eg. from a keytab) are used to perform
>> a mount operation that is protected by Kerberos.  Before 05fc350,
>> SETCLIENTID used a machine credential, or fell back to a regular
>> user's credential if no keytab is available.
>> 
>> On clients that don't have a keytab, performing SETCLIENTID early
>> means there's no user credential to fall back on, since no regular
>> user has kinit'd yet.  05f4c350 seems to have broken the ability
>> to mount with sec=krb5 on clients that don't have a keytab in
>> kernels 3.7 - 3.10.
>> 
>> To address this regression, commit 4edaa308 (NFS: Use "krb5i" to
>> establish NFSv4 state whenever possible), Sat Mar 16 15:56:20 2013,
>> was merged in 3.10.  This commit forces the NFS client to fall back
>> to AUTH_SYS for lease management operations if no keytab is
>> available.
>> 
>> Neil Brown noticed that, since root is required to kinit to do a
>> sec=krb5 mount when a client doesn't have a keytab, we can try to
>> use root's Kerberos credential before AUTH_SYS.
>> 
>> Now, when determining a principal and flavor to use for lease
>> management, the NFS client tries in this order:
>> 
>>  1.  Flavor: AUTH_GSS, krb5i
>>      Principal: service principal (via keytab)
>> 
>>  2.  Flavor: AUTH_GSS, krb5i
>>      Principal: user principal established for UID 0 (via kinit)
>> 
>>  3.  Flavor: AUTH_SYS
>>      Principal: UID 0 / GID 0
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> fs/nfs/nfs4state.c |   20 +++++++++++++++++++-
>> 1 file changed, 19 insertions(+), 1 deletion(-)
>> 
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index 1fab140..6ceece7 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -154,6 +154,19 @@ struct rpc_cred *nfs4_get_machine_cred_locked(struct nfs_client *clp)
>> 	return cred;
>> }
>> 
>> +static void nfs4_root_machine_cred(struct nfs_client *clp)
>> +{
>> +	struct rpc_cred *cred, *new;
>> +
>> +	new = rpc_lookup_machine_cred(NULL);
>> +	spin_lock(&clp->cl_lock);
>> +	cred = clp->cl_machine_cred;
>> +	clp->cl_machine_cred = new;
>> +	spin_unlock(&clp->cl_lock);
>> +	if (cred != NULL)
>> +		put_rpccred(cred);
>> +}
>> +
>> static struct rpc_cred *
>> nfs4_get_renew_cred_server_locked(struct nfs_server *server)
>> {
>> @@ -1888,9 +1901,14 @@ again:
>> 	case -NFS4ERR_STALE_CLIENTID:
>> 		dprintk("NFS: %s after status %d, retrying\n",
>> 			__func__, status);
>> +		i = 0;
> 
> This clearly isn't resetting clp->cl_machine_cred, so how is it intended
> to work?

This one line is not needed for the fix, and can be removed.  Or, we can add logic here to reset cl_machine_cred.

You probably want to remove that line, and have a separate patch to make sure the machine cred is reset when the client receives STALE_CLIENTID.

> 
>> 		goto again;
>> 	case -EACCES:
>> -		if (i++)
>> +		if (i++ == 0) {
>> +			nfs4_root_machine_cred(clp);
>> +			goto again;
>> +		}
>> +		if (i > 2)
>> 			break;
>> 	case -NFS4ERR_CLID_INUSE:
>> 	case -NFS4ERR_WRONGSEC:
>> 
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




