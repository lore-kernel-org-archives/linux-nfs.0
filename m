Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:42634 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab1FHVQ6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 17:16:58 -0400
Subject: Re: [PATCH] nfs-utils:  Support binding to source address.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DEFE18C.3040308@candelatech.com>
Date: Wed, 8 Jun 2011 17:16:44 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <A7E35DD6-C83B-4DAC-A64D-9D79EDA97C5F@oracle.com>
References: <1307554748-31757-1-git-send-email-greearb@candelatech.com> <41FD62D9-1CAA-46CA-B2D7-2F52E58A917B@oracle.com> <4DEFE18C.3040308@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 8, 2011, at 4:54 PM, Ben Greear wrote:

> On 06/08/2011 01:41 PM, Chuck Lever wrote:
>> 
>> On Jun 8, 2011, at 1:39 PM, greearb@candelatech.com wrote:
>> 
>>> From: Ben Greear<greearb@candelatech.com>
>>> 
>>> This lets one specify the source IP address for
>>> sockets, allowing users to leverage routing rules
>>> on multi-homed systems.
>> 
>>   [ ... snipped ... ]
>> 
>>> diff --git a/support/include/sockaddr.h b/support/include/sockaddr.h
>>> index 9af2543..3822b4b 100644
>>> --- a/support/include/sockaddr.h
>>> +++ b/support/include/sockaddr.h
>>> @@ -46,6 +46,12 @@ union nfs_sockaddr {
>>> 	struct sockaddr_in6	s6;
>>> };
>>> 
>>> +struct local_bind_info {
>>> +	struct sockaddr_storage addr;
>> 
>> For storing socket addresses, nfs_utils has "union nfs_sockaddr" which safely allows the equivalent of type-casting.  You should use that here.
>> 
>>> +	int addrlen;
>> 
>> socklen_t or size_t is preferred for sockaddr lengths.
>> 
>>> +	int is_set;
>> 
>> This should probably be _Bool or bool.
>> 
>> But why is this structure needed?  Why can't you pass a bind address via a struct sockaddr * just as bind(2) does?
> 
> Someone might one day want to bind to an interface with SO_BINDTODEVICE, so I thought
> it would be nice to pass a container around so that it would be easy to add a dev-name
> argument without touching all of the method signatures again.

My preference would be to go with something simple for now.  If we ever need more, it's easy to change.  These are not a published formal API.

Are you thinking of allowing users to specify either an IP address or a hostname as a value for this new option?

>> When you specify a source address for mountd and statd, wouldn't they need to register that address with rpcbind? That won't work for non-TI-RPC builds, and neither would it work for the kernel, which, according to Trond, will never support listening on specific addresses (he NACKed a patch to the kernel's rpcbind client to support this). Are you sure you need server-side changes too?
> 
> Much of the changes are just required to make things compile with the changes to the
> core socket building methods.  I don't notice any changes to mountd or statd in
> the patch I posted.  What sections are you speaking of?
> 
>> You can't pass a bind address to the mount command using a command line option, since command line options aren't stored in /etc/fstab or /etc/mtab.  How would umount.nfs learn of the bind address if it can't find it in /etc/mtab?
>> 
>> It should not read from an environment variable either... how would that work during system boot?  How would such a variable be set during system shutdown?  If we were to do this, it really should use a new mount option.
> 
> Ok, I've implemented it with a mount-option for my testing.  I'll remove the
> cmd-line-arg and environ variable logic.

I have to admit that parse_local_bind() doesn't make sense to me.  For example, I don't think there is any need for bind addresses to use the square bracket convention that is used for server addresses; that is there for the NFS special device simply because a colon is already the separator between the server IP address and the export path.  We don't have that problem for a bind address, since it always stands by itself.

I also imagine that the source address will need to be passed to the kernel via mount(2), yes?  That can only be done via a string mount option.  Anyway, point made.

And such a mount option would need to be documented in nfs(5) (see utils/mount/nfs.man), and changes included with your patches.

>> If you repost, I would do mountd, statd, and mount's getport implementation all in separate patches.
> 
> I'm happy to work on this, but plz point me to what parts of my patch are messing with
> mountd and statd.

I'm not sure why I had that impression, but I now see that there are no mountd or statd hunks.  If you are happy without server-side changes, then great!

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




