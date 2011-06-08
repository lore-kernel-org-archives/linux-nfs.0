Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52353 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755510Ab1FHUyj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 16:54:39 -0400
Message-ID: <4DEFE18C.3040308@candelatech.com>
Date: Wed, 08 Jun 2011 13:54:36 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com> <41FD62D9-1CAA-46CA-B2D7-2F52E58A917B@oracle.com>
In-Reply-To: <41FD62D9-1CAA-46CA-B2D7-2F52E58A917B@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/08/2011 01:41 PM, Chuck Lever wrote:
>
> On Jun 8, 2011, at 1:39 PM, greearb@candelatech.com wrote:
>
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This lets one specify the source IP address for
>> sockets, allowing users to leverage routing rules
>> on multi-homed systems.
>
>    [ ... snipped ... ]
>
>> diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
>> index 9af2543..3822b4b 100644
>> --- a/support/include/sockaddr.h
>> +++ b/support/include/sockaddr.h
>> @@ -46,6 +46,12 @@ union nfs_sockaddr {
>> 	struct sockaddr_in6	s6;
>> };
>>
>> +struct local_bind_info {
>> +	struct sockaddr_storage addr;
>
> For storing socket addresses, nfs_utils has "union nfs_sockaddr" which safely allows the equivalent of type-casting.  You should use that here.
>
>> +	int addrlen;
>
> socklen_t or size_t is preferred for sockaddr lengths.
>
>> +	int is_set;
>
> This should probably be _Bool or bool.
>
> But why is this structure needed?  Why can't you pass a bind address via a struct sockaddr * just as bind(2) does?

Someone might one day want to bind to an interface with SO_BINDTODEVICE, so I thought
it would be nice to pass a container around so that it would be easy to add a dev-name
argument without touching all of the method signatures again.

>
> When you specify a source address for mountd and statd, wouldn't they need to register that address with rpcbind? That won't work for non-TI-RPC builds, and neither would it work for the kernel, which, according to Trond, will never support listening on specific addresses (he NACKed a patch to the kernel's rpcbind client to support this). Are you sure you need server-side changes too?

Much of the changes are just required to make things compile with the changes to the
core socket building methods.  I don't notice any changes to mountd or statd in
the patch I posted.  What sections are you speaking of?

> You can't pass a bind address to the mount command using a command line option, since command line options aren't stored in /etc/fstab or /etc/mtab.  How would umount.nfs learn of the bind address if it can't find it in /etc/mtab?
>
> It should not read from an environment variable either... how would that work during system boot?  How would such a variable be set during system shutdown?  If we were to do this, it really should use a new mount option.

Ok, I've implemented it with a mount-option for my testing.  I'll remove the
cmd-line-arg and environ variable logic.

> If you repost, I would do mountd, statd, and mount's getport implementation all in separate patches.

I'm happy to work on this, but plz point me to what parts of my patch are messing with
mountd and statd.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

