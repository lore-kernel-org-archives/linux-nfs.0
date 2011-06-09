Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35604 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754825Ab1FIXrm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 19:47:42 -0400
Message-ID: <4DF15B9B.5010408@candelatech.com>
Date: Thu, 09 Jun 2011 16:47:39 -0700
From: Ben Greear <greearb@candelatech.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2] nfs-utils:  Support binding to source address.
References: <1307574083-27608-1-git-send-email-greearb@candelatech.com> <A1094CD0-08C4-42C8-8928-DDD1BFC27C7B@oracle.com> <4DF0EBBA.8090703@candelatech.com> <CE8E8AB7-AC6F-4715-B282-CAAE8F63A98B@oracle.com>
In-Reply-To: <CE8E8AB7-AC6F-4715-B282-CAAE8F63A98B@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 06/09/2011 11:39 AM, Chuck Lever wrote:
>
> On Jun 9, 2011, at 11:50 AM, Ben Greear wrote:
>
>> On 06/09/2011 07:05 AM, Chuck Lever wrote:
>>>
>>> On Jun 8, 2011, at 7:01 PM, greearb@candelatech.com wrote:
>>>
>>>> From: Ben Greear<greearb@candelatech.com>
>>>>
>>>> This lets one specify the source IP address for
>>>> sockets, allowing users to leverage routing rules
>>>> on multi-homed systems.
>>>>
>>>> Kernel patches to RPC and NFS are needed to complete
>>>> full functionality.
>>>>
>>>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>>>> ---
>>>>
>>>> v2:  Use union nfs_sockaddr in local_bind_info struct.
>>>>      Remove cmd-line and getenv parsing.
>>>>      Add option parsing to umount logic.
>>>>      Update man.nfs page.
>>>
>>> Thanks for that, but...
>>>
>>> I'm going to side with Neil on this: your solution is invasive.  We need to see much better rationale for the complexity of your design.  Why isn't an automatic solution adequate for your needs?  Don't design for every general case, just solve your immediate problem and explain your solution.
>>>
>>> I'm not saying "no" just please show your work more.  Clearly our community has not had to address this problem before now, so we need some explanation to do a proper review.
>>
>> Ok, first my use case:
>>
>> I want to have multiple interfaces on the system each make an independent
>> connection to the nfs server(s).  Each interface may be on the same subnet,
>> or on different subnets, and there may be routers attached to each
>> interface.  In order to make the traffic go out one interface or another,
>> I set up ip routing rules that say: use routing table X if source-ip is Y.
>> I can then set up the various routing tables to go to the correct external
>> routers.  If it's not a routed network, then the traffic will still originate
>> on the correct interface.
>>
>> We use this primarily for stress-testing NFS servers (create 1000 unique
>> mounts, for instance).
>
> Typically this kind of server testing is better done with multiple clients.  This can be done with virtual guests, for example, if you don't have a lot of hardware.  It's certainly not a common use case, though.  (A frequently occurring use case would be one justification for significant additional complexity).

I can get 1000+ emulated clients, each with it's own MAC, IP, etc on a mid-range
system, and even more on higher-end hardware.  I'm sure that's higher density
than you can get with virtual guests, and it's also a lot easier to manage.

Regardless, the ability for users to have control over their network config
is more useful than any of my personal use cases..

>> Other users might want the same functionality to use two interfaces on the
>> same network to communicate to an nfs server, perhaps to utilize two 1Gbps
>> network interfaces that eventually connect to a 10Gbps file-server, and thus
>> get double the total throughput.
>
> Bonding is supposed to be supported by pNFS, I thought.

What I propose is a very simple change from standard old nfs
usage.  Somehow I doubt bonding pNFS is quite so simple to deal
with.

>> A second use case:
>>
>> User has two IPs on the same interface, and wants to use a specific
>> one for NFS traffic.  Aside from the testing scenario above, I'm not
>> sure how this helps, but I also know that people do clever things that
>> no one has thought of if you allow them the tools.
>>
>> Third case:
>>
>> User has trusted network A and un-trusted B.  They would like to make
>> sure that NFS traffic always originates on A.  So, they can bind the
>> local IP to A and not have to worry about what automatic address selection
>> might choose.
>
> NFS has krb5p for preventing traffic sniffing.  It's all done well above the IP layer.
>
> I'm not convinced.  I think we can accomplish these items more simply by refining other areas of the NFS client.

Well, we differ in opinion.  I'm going to try a bit more to find some acceptable
solution, but if everyone sees this effort as DOA, please let me know now so I can
move on to other things.

>>>> +struct local_bind_info {
>>>> +	union nfs_sockaddr addr;
>>>> +	socklen_t addrlen;
>>>> +	bool is_set;
>>>> +};
>>>
>>> Please use "struct sockaddr *" or provide a very clear rationale (not "we may need this someday") for why "struct sockaddr *" is not adequate for solving your immediate problem.
>>
>> First, it's nice to be able to pass around the addrlen and not just
>> assume the length based on the family.
>
> Can you elaborate on "nice" ?  We're really only concerned about just three families: AF_INET, AF_INET6, and AF_LOCAL.
>
>> Second:  I *will* submit a patch to allow binding to a network device with
>> SO_BINDTODEVICE if I can get this first patch accepted.
>
> Then that subsequent patch is where this new structure belongs.  That groups the changes together logically.

That would be two huge boring patches that touch the same code.

>
>> Using SO_BINDTODEVICE
>> offers similar functionality, but it doesn't require routing rules to force
>> traffic out an interface.  This is another way to help keep nfs traffic on
>> trusted interfaces, for instance.
>
> It might be nicer if all of the parameters used to define the transport endpoints were included in the same structure.  Then you pass a single pointer around that encompasses both the remote address and the source address.  That seems more logical to me than passing a struct sockaddr * for the remote address and a pointer to an arbitrary structure for the source address.
>
> Reshaping internal APIs is something you can split out of any patch to support source address binding.

I made an attempt at this.  It seems way more risky, ugly, and more code than my
posted patch.  The primary reason being that often copies are made of the
addr before it's passed to other methods.  So, you would end up creating lots
of on-stack config structs and then doing copies before passing them on to
more functions.

If changing the 'local_ip' argument everywhere to be a sockaddr* will make
you happy, I will just do that and forget about implementing SO_BINDTODEVICE,
and assume salen based on the sa_family.

>>>> @@ -305,6 +307,9 @@ static void parse_opt(const char *opt, int *mask, char *extra_opts, size_t len)
>>>>
>>>> 	if ((len -= strlen(opt))>   0)
>>>> 		strcat(extra_opts, opt);
>>>> +
>>>> +	if (strncmp(opt, "srcaddr=", strlen("srcaddr=")) == 0)
>>>> +		parse_local_bind(&glb_local_ip, opt + strlen("srcaddr="));
>>>> }
>>>
>>> Why is this needed?  Is it just to support legacy (non-string) mounts?
>>
>> No, it allows us to bind mount.nfs sockets to the IP that the mount options are asking the
>> kernel to bind to.  It's the *only* way to get the mount.nfs process to bind
>> to an IP now that I removed the cmd-line args and environ variable hacks.
>
> I don't understand how that can be the case.  The srcaddr mount option should be parsed in stropt.c, where it is used to generate sockets for rpcbind and MNT calls.  This works the same for all of the sockets mount.nfs uses for string mounts.  I don't see any need for this logic in mount.c, especially if you don't support srcaddr= for legacy (nfs_mount_data) style mounts.

Ok, I will look at that again.

>> I personally don't want to bind to a particular port, but it seems like something
>> that someone might want to do some day, so it would be nice to get the parsing
>> able to handle it up front to ease compatibility issues.
>
> Unless you have a specific use case today, we prefer not to speculate about how this might be used.  Let's design exactly what we need right now.
>
> If you want to look at a UI precedent for mount.nfs, ports are specified via separate mount options.  "srcport=" for example, might be used to specify the source port.  In any event, that support can be added later if desired.  Let's keep this as simple and to the point as possible.

Ok, I'll make the srcaddr=n argument a plain numeric IP.  I'll try to resolve IPv4
first, and if that doesn't work, will try it as IPv6.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

