Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:43708 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759030Ab3EOQXV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 12:23:21 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 2/2] NFS: Fall back to AUTH_SYS for SETCLIENTID (take 2)
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130515160424.GK16811@fieldses.org>
Date: Wed, 15 May 2013 12:23:12 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <961AC5FB-617E-48FB-A35F-5E1A25213292@oracle.com>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net> <20130513162528.1942.64673.stgit@seurat.1015granger.net> <20130515160424.GK16811@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 15, 2013, at 12:04 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, May 13, 2013 at 12:25:28PM -0400, Chuck Lever wrote:
>> Now that commit 4edaa308 "NFS: Use "krb5i" to establish NFSv4 state
>> whenever possible" is reverted...
>> 
>> NFSv4 server trunking detection was added with commit 05f4c350 "NFS:
>> Discover NFSv4 server trunking when mounting" in v3.7.  One of the
>> issues that the reverted commit 4edaa308 tried to address was that
>> when server trunking detection was added, we broke the ability to
>> mount krb5 exports when the client has no keytab.
> 
> And that happened because we started asking gssd explicitly for a
> context for a machine principal instead of for uid=0?  Or for some other
> reason?

We've asked gssd for a machine credential for SETCLIENTID for a while now, so "some other reason."  I honestly don't know exactly why it stopped working with my change, but someone bisected it to that one.

But we've always had some issue with the "no keytab" case because we do require a machine credential for SETCLIENTID.  I'm suggesting a fix for the broad class of problems using "sec=krb5?" that arise due to a missing keytab on the client.

In this case we need the fix sooner rather than later because it stopped working in 3.7.

> 
>> We still need to
>> address that regression.
>> 
>> Let's try a narrow approach to re-enabling sec=krb5 mounts without a
>> local system keytab, and worry about the other issues when we can
>> plan concomitant user space and kernel changes.
>> 
>> When a GSS security flavor is used on a mount, allow the security
>> flavor for state management to fall back to AUTH_SYS if there is
>> a problem setting up a GSS context for it.
> 
> This brings back the delay in the case gssd isn't running, doesn't it?

No.  "When a GSS flavor is used" means ONLY when a GSS flavor is used.  We make the minimal assumption that using a GSS flavor for a mount means the administrator either has gssd running or wants to know when it isn't, and can tolerate a delay in that case.

When a non-GSS flavor is used, we behave as we did before 3.10, and simply use the same security flavor that the mount point used.  So if sec=sys is specified, then SETCLIENTID will use AUTH_SYS, and a gssd upcall is avoided.

> Or am I missing something?
> --b.
> 
>> The existing situation is that the first NFSv4 mount of a server
>> determines the state management security flavor.  So, if a sec=sys
>> mount occurs first, all subsequent mounts will continue to use
>> AUTH_SYS for state management, even if they specified sec=krb5 or
>> higher.  The risk is allowing a malicious or broken client to purge
>> this client's open and lock state on the server; data is not
>> exposed.
>> 
>> Falling back if any error occurs while establishing a GSS context
>> for state management has its own risks.  A network intermediary can
>> prevent the establishment of a GSS context for state management,
>> forcing the client to use AUTH_SYS for this task.
>> 
>> However, given that the order of NFS mounts is non-deterministic
>> anyway, we already fail to provide robust security guarantees for
>> state management.
>> 
>> This will be remedied eventually, but changes co-ordinated with user
>> space are required for that.  When a gssd upcall fails, it currently
>> does not distinguish between "I don't have a keytab" and "some other
>> problem occurred".  To close this security hole, the kernel must
>> fall back only when there is no local keytab.
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> Cc: stable@vger.kernel.org [>=3.7]
>> ---
>> fs/nfs/nfs4state.c |   14 +++++++++++++-
>> 1 file changed, 13 insertions(+), 1 deletion(-)
>> 
>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>> index b5137c9..a2482c6 100644
>> --- a/fs/nfs/nfs4state.c
>> +++ b/fs/nfs/nfs4state.c
>> @@ -1911,11 +1911,23 @@ again:
>> 	switch (status) {
>> 	case 0:
>> 		break;
>> -
>> +	case -ENOKEY:
>> 	case -EACCES:
>> 		if (clp->cl_machine_cred == NULL)
>> 			break;
>> 		/* Handle case where the user hasn't set up machine creds */
>> +		if (clnt->cl_auth->au_flavor > RPC_AUTH_MAXFLAVOR) {
>> +			clnt = rpc_clone_client_set_auth(clnt, RPC_AUTH_UNIX);
>> +			if (IS_ERR(clnt)) {
>> +				status = PTR_ERR(clnt);
>> +				break;
>> +			}
>> +			clnt = xchg(&clp->cl_rpcclient, clnt);
>> +			rpc_shutdown_client(clnt);
>> +			clnt = clp->cl_rpcclient;
>> +			dprintk("NFS: retrying trunking detection with AUTH_SYS\n");
>> +			goto again;
>> +		}
>> 		nfs4_clear_machine_cred(clp);
>> 	case -NFS4ERR_DELAY:
>> 	case -ETIMEDOUT:
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




