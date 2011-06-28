Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22085 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402Ab1F1UIV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jun 2011 16:08:21 -0400
Message-ID: <4E0A34B3.6090004@netapp.com>
Date: Tue, 28 Jun 2011 16:08:19 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS: Allow sec=none mounts in certain cases
References: <20110628181324.2866.98154.stgit@seurat.1015granger.net> <20110628182540.2866.42553.stgit@seurat.1015granger.net> <20110628190640.GB26517@fieldses.org> <20110628191004.GC26517@fieldses.org> <831D46A4-2C46-4895-8ABE-3C64533E2CBA@oracle.com>
In-Reply-To: <831D46A4-2C46-4895-8ABE-3C64533E2CBA@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/28/2011 03:34 PM, Chuck Lever wrote:
> 
> On Jun 28, 2011, at 3:10 PM, J. Bruce Fields wrote:
> 
>> On Tue, Jun 28, 2011 at 03:06:40PM -0400, bfields wrote:
>>> On Tue, Jun 28, 2011 at 02:25:41PM -0400, Chuck Lever wrote:
>>>> There is an undocumented convention (verified by reviewing network
>>>> traces from a NetApp filer and a Solaris NFS server) where a server
>>>> that returns a mount authflavor list containing an AUTH_NULL entry
>>>> is actually indicating it will accept any security flavor for the
>>>> export being mounted.
>>>
>>> This is only in the case of NLM?  (Not v4 secinfo?)
>> 			      ^^^
>> 			      (Sorry, I meant MOUNT !)
> 
> Right, this fix is specifically for the kernel's NFSv3 mount client.  I expect that SECINFO is probably the area where NFSv4 spec changes might help, but I haven't touched that in these patches.
> 
> At some point Bryan, Trond, and I should discuss how we can unify these pieces, and teach them how to determine the list of locally supported authflavors.  Maybe this is done already?

Do you mean something similar to gss_mech_list_pseudoflavors() in net/sunrpc/auth_gss/gss_mech_switch.c?  I use it to determine the sec flavor of an NFS v4.0 mount if AUTH_SYS fails (see nfs4_find_root_sec() in fs/nfs/nfs4proc.c)

- Bryan

> 
>>>
>>> --b.
>>>
>>>>
>>>> This might be used when the server maps all security flavors into the
>>>> same security mode.  For example, the server treats all accessors as,
>>>> say, UID 17.
>>>>
>>>> Essentially, AUTH_NULL is treated as a wildcard that matches the
>>>> flavor the mounter requested.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>>
>>>> fs/nfs/super.c |   15 +++++++++++----
>>>> 1 files changed, 11 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>>> index 4625a4c..543cf9f 100644
>>>> --- a/fs/nfs/super.c
>>>> +++ b/fs/nfs/super.c
>>>> @@ -1570,13 +1570,20 @@ static int nfs_walk_authlist(struct nfs_parsed_mount_data *args,
>>>> 	 * the first flavor in the list that it supports, on the
>>>> 	 * assumption that the best access is provided by the first
>>>> 	 * flavor."
>>>> +	 *
>>>> +	 * By convention we treat AUTH_NULL in the returned list as
>>>> +	 * a wild card.  The server will map our requested flavor to
>>>> +	 * something else.
>>>> 	 */
>>>> -	for (i = 0; i < args->auth_flavor_len; i++)
>>>> -		for (j = 0; j < server_authlist_len; j++)
>>>> -			if (args->auth_flavors[i] == server->auth_flavs[j]) {
>>>> -				args->auth_flavors[0] = server->auth_flavs[j];
>>>> +	for (i = 0; i < server_authlist_len; i++) {
>>>> +		if (server->auth_flavs[i] == RPC_AUTH_NULL)
>>>> +			goto out;
>>>> +		for (j = 0; j < args->auth_flavor_len; j++)
>>>> +			if (server->auth_flavs[i] == args->auth_flavors[j]) {
>>>> +				args->auth_flavors[0] = server->auth_flavs[i];
>>>> 				goto out;
>>>> 			}
>>>> +	}
>>>>
>>>> 	dfprintk(MOUNT, "NFS: server does not support requested auth flavor\n");
>>>> 	nfs_umount(server);
>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

