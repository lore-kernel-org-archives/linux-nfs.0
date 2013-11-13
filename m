Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:21840 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756132Ab3KMQLB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Nov 2013 11:11:01 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH v2 3/3] nfs: check if gssd is running before attempting to use krb5i auth in SETCLIENTID call
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20131113110905.1e0cc276@corrin.poochiereds.net>
Date: Wed, 13 Nov 2013 11:10:52 -0500
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Neil Brown <neilb@suse.de>, Steve Dickson <steved@redhat.com>
Message-Id: <65F8741A-B846-472B-A569-A1C6FB39DEC7@oracle.com>
References: <1384353053-30002-1-git-send-email-jlayton@redhat.com> <1384353053-30002-4-git-send-email-jlayton@redhat.com> <DF1DECB2-B736-4B70-87DC-52CD695C44F3@oracle.com> <1CFBCCB6-37CE-4C49-91EE-0FB33D11B57A@netapp.com> <4226B463-0DB1-4847-9C30-252E67B46859@oracle.com> <20131113103510.6f89a998@corrin.poochiereds.net> <A8619700-BAA2-4E99-AFFA-579115D4B68A@netapp.com> <20131113105702.6196aef0@corrin.poochiereds.net> <20131113110905.1e0cc276@corrin.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 13, 2013, at 11:09 AM, Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 13 Nov 2013 10:57:02 -0500
> Jeff Layton <jlayton@redhat.com> wrote:
> 
>> On Wed, 13 Nov 2013 15:49:13 +0000
>> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>> 
>>> 
>>> On Nov 13, 2013, at 10:35, Jeff Layton <jlayton@redhat.com> wrote:
>>> 
>>>> On Wed, 13 Nov 2013 10:14:30 -0500
>>>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>>> 
>>>>> 
>>>>> On Nov 13, 2013, at 9:48 AM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>>>> 
>>>>>> 
>>>>>> On Nov 13, 2013, at 9:38, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>> 
>>>>>>> 
>>>>>>> On Nov 13, 2013, at 9:30 AM, Jeff Layton <jlayton@redhat.com> wrote:
>>>>>>> 
>>>>>>>> Currently, the client will attempt to use krb5i in the SETCLIENTID call
>>>>>>>> even if rpc.gssd is running. If that fails, it'll then fall back to
>>>>>>>> RPC_AUTH_UNIX. This introduced a delay when mounting if rpc.gssd isn't
>>>>>>>> running, and causes warning messages to pop up in the ring buffer.
>>>>>>>> 
>>>>>>>> Check to see if rpc.gssd is running before even attempting to use krb5i
>>>>>>>> auth, and just silently skip trying to do so if it isn't.
>>>>>>>> 
>>>>>>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>>>>>>> ---
>>>>>>>> 
>>>>>>>> diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
>>>>>>>> index b4a160a..988aebf 100644
>>>>>>>> --- a/fs/nfs/nfs4client.c
>>>>>>>> +++ b/fs/nfs/nfs4client.c
>>>>>>>> @@ -8,6 +8,7 @@
>>>>>>>> #include <linux/nfs_mount.h>
>>>>>>>> #include <linux/sunrpc/addr.h>
>>>>>>>> #include <linux/sunrpc/auth.h>
>>>>>>>> +#include <linux/sunrpc/auth_gss.h>
>>>>>>>> #include <linux/sunrpc/xprt.h>
>>>>>>>> #include <linux/sunrpc/bc_xprt.h>
>>>>>>>> #include "internal.h"
>>>>>>>> @@ -351,7 +352,7 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
>>>>>>>> */
>>>>>>>> struct nfs_client *nfs4_init_client(struct nfs_client *clp,
>>>>>>>> 				    const struct rpc_timeout *timeparms,
>>>>>>>> -				    const char *ip_addr)
>>>>>>>> +				    const char *ip_addr, struct net *net)
>>>>>> 
>>>>>> Why the ‘struct net’ argument? clp->cl_net should already be initialized here.
>>>>>> 
>>>>>>>> {
>>>>>>>> 	char buf[INET6_ADDRSTRLEN + 1];
>>>>>>>> 	struct nfs_client *old;
>>>>>>>> @@ -370,7 +371,10 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
>>>>>>>> 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
>>>>>>>> 	__set_bit(NFS_CS_DISCRTRY, &clp->cl_flags);
>>>>>>>> 	__set_bit(NFS_CS_NO_RETRANS_TIMEOUT, &clp->cl_flags);
>>>>>>>> -	error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_GSS_KRB5I);
>>>>>>>> +
>>>>>>>> +	error = -EINVAL;
>>>>>>>> +	if (gssd_running(net))
>>>>>>>> +		error = nfs_create_rpc_client(clp, timeparms,RPC_AUTH_GSS_KRB5I);
>>>>>>>> 	if (error == -EINVAL)
>>>>>>>> 		error = nfs_create_rpc_client(clp, timeparms, RPC_AUTH_UNIX);
>>>>>>> 
>>>>>>> This feels like a layering violation.  Why wouldn't you put a gssd_running check in gss_create(), for example, and have rpcauth_create() return -EINVAL?
>>>>>>> 
>>>>>> 
>>>>>> It would be better to put it in the upcall.
>>>>> 
>>>>> Waiting until the upcall has its benefits.  At that point, GSSD (if it is running) can report other errors, such as that there is no material to form a machine credential.
>>>>> 
>>>>> My point to Jeff is that, aside from architectural aesthetics, direct calls from RPC consumers to the GSS layer causes a module dependency problem.  The right way to plumb this is to create an RPC client API that invokes gssd_running() but only if auth_rpcgss.ko is loaded.
>>> 
>>> Chuck, I’ve already told you that the auth_rpcgss dependency is a non-starter. Turning off automatic loading of rpcsec_gss modules is a _worse_ regression than the ones we already have and (as I already said) can be trivially defeated by just compiling them into the kernel.
>>> 
>>> We _want_ the kernel to be able to autoload modules so that we can add new security flavours etc without having to recompile.
>>> 
> 
> Right, and just because auth_gss isn't currently plugged in, doesn't
> mean that it's not able to be plugged in. If this is the first mount
> attempt then it's likely that auth_gss isn't loaded yet, even if
> rpc.gssd is running.
> 
>>>>> However, I don't see why the existing RPC client APIs shouldn't just fail where appropriate if GSSD isn't available.  Is there a strong need to expose gssd_running() as a separate API?
>>>>> 
>>>> 
>>>> One of the complaints about this whole "use krb5i by default" change is
>>>> that we now get the warnings in the ring buffer when gssd isn't
>>>> running. That's a good thing if krb5 was explicitly requested, but is
>>>> useless and confusing if the user just wants to use AUTH_SYS.
>>>> 
>>>> If we wait until gss_create, it's too late to know what the "intent"
>>>> was. We'll either fire the warning inappropriately like we do now, or
>>>> miss it altogether when we actually should have printed it.
>>> 
>>> What if the user intended to use krb5i, but the daemon failed to start? This whole “kernel second guessing what the admin _actually_ wanted to do” thing is a red herring. Let’s just fix the real problem and then leave it at that.
>>> 
>> 
>> In that case, they will get a failure and warning when they go to the
>> next stage of the mount (I forget which RPC it is). With this change,
>> krb5/krb5i mounts will still fail just like they do today when gssd
>> isn't running. You just get a single warning in the ring buffer about
>> it instead of two.
>> 
> 
> So to clarify...today we do this when gssd isn't running and we try an
> AUTH_GSS mount:
> 
> - attempt SETCLIENTID with krb5i
> - when that fails, log a warning to ring buffer
> - attempt SETCLIENTID with AUTH_SYS
> - attempt rest of mount with krb5i

Hold it.  This step should not be happening.  Lease management should try krb5i by default, but why is the rest of the mount attempted with krb5i?

> - log another warning to ring buffer when it fails
> 
> ...with the first two patches, that doesn't really change. With the
> third patch in place, we just skip the first two steps if gssd isn't
> running. You'll still get a single warning in the ring buffer (which is
> as expected).
> 
> Trond, is that acceptable or do you want me to just drop the 3rd patch?

NAK from me on the third patch as it stands.  Find some other way to invoke gssd_running() if you really need to do that.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




