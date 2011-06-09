Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:62313 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752008Ab1FISjy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 14:39:54 -0400
Subject: Re: [PATCH v2] nfs-utils:  Support binding to source address.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4DF0EBBA.8090703@candelatech.com>
Date: Thu, 9 Jun 2011 14:39:42 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <CE8E8AB7-AC6F-4715-B282-CAAE8F63A98B@oracle.com>
References: <1307574083-27608-1-git-send-email-greearb@candelatech.com> <A1094CD0-08C4-42C8-8928-DDD1BFC27C7B@oracle.com> <4DF0EBBA.8090703@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jun 9, 2011, at 11:50 AM, Ben Greear wrote:

> On 06/09/2011 07:05 AM, Chuck Lever wrote:
>> 
>> On Jun 8, 2011, at 7:01 PM, greearb@candelatech.com wrote:
>> 
>>> From: Ben Greear<greearb@candelatech.com>
>>> 
>>> This lets one specify the source IP address for
>>> sockets, allowing users to leverage routing rules
>>> on multi-homed systems.
>>> 
>>> Kernel patches to RPC and NFS are needed to complete
>>> full functionality.
>>> 
>>> Signed-off-by: Ben Greear<greearb@candelatech.com>
>>> ---
>>> 
>>> v2:  Use union nfs_sockaddr in local_bind_info struct.
>>>     Remove cmd-line and getenv parsing.
>>>     Add option parsing to umount logic.
>>>     Update man.nfs page.
>> 
>> Thanks for that, but...
>> 
>> I'm going to side with Neil on this: your solution is invasive.  We need to see much better rationale for the complexity of your design.  Why isn't an automatic solution adequate for your needs?  Don't design for every general case, just solve your immediate problem and explain your solution.
>> 
>> I'm not saying "no" just please show your work more.  Clearly our community has not had to address this problem before now, so we need some explanation to do a proper review.
> 
> Ok, first my use case:
> 
> I want to have multiple interfaces on the system each make an independent
> connection to the nfs server(s).  Each interface may be on the same subnet,
> or on different subnets, and there may be routers attached to each
> interface.  In order to make the traffic go out one interface or another,
> I set up ip routing rules that say: use routing table X if source-ip is Y.
> I can then set up the various routing tables to go to the correct external
> routers.  If it's not a routed network, then the traffic will still originate
> on the correct interface.
> 
> We use this primarily for stress-testing NFS servers (create 1000 unique
> mounts, for instance).

Typically this kind of server testing is better done with multiple clients.  This can be done with virtual guests, for example, if you don't have a lot of hardware.  It's certainly not a common use case, though.  (A frequently occurring use case would be one justification for significant additional complexity).

> Other users might want the same functionality to use two interfaces on the
> same network to communicate to an nfs server, perhaps to utilize two 1Gbps
> network interfaces that eventually connect to a 10Gbps file-server, and thus
> get double the total throughput.

Bonding is supposed to be supported by pNFS, I thought.

> A second use case:
> 
> User has two IPs on the same interface, and wants to use a specific
> one for NFS traffic.  Aside from the testing scenario above, I'm not
> sure how this helps, but I also know that people do clever things that
> no one has thought of if you allow them the tools.
> 
> Third case:
> 
> User has trusted network A and un-trusted B.  They would like to make
> sure that NFS traffic always originates on A.  So, they can bind the
> local IP to A and not have to worry about what automatic address selection
> might choose.

NFS has krb5p for preventing traffic sniffing.  It's all done well above the IP layer.

I'm not convinced.  I think we can accomplish these items more simply by refining other areas of the NFS client.

>>> +struct local_bind_info {
>>> +	union nfs_sockaddr addr;
>>> +	socklen_t addrlen;
>>> +	bool is_set;
>>> +};
>> 
>> Please use "struct sockaddr *" or provide a very clear rationale (not "we may need this someday") for why "struct sockaddr *" is not adequate for solving your immediate problem.
> 
> First, it's nice to be able to pass around the addrlen and not just
> assume the length based on the family.

Can you elaborate on "nice" ?  We're really only concerned about just three families: AF_INET, AF_INET6, and AF_LOCAL.

> Second:  I *will* submit a patch to allow binding to a network device with
> SO_BINDTODEVICE if I can get this first patch accepted.

Then that subsequent patch is where this new structure belongs.  That groups the changes together logically.

> Using SO_BINDTODEVICE
> offers similar functionality, but it doesn't require routing rules to force
> traffic out an interface.  This is another way to help keep nfs traffic on
> trusted interfaces, for instance.

It might be nicer if all of the parameters used to define the transport endpoints were included in the same structure.  Then you pass a single pointer around that encompasses both the remote address and the source address.  That seems more logical to me than passing a struct sockaddr * for the remote address and a pointer to an arbitrary structure for the source address.

Reshaping internal APIs is something you can split out of any patch to support source address binding.

>>> @@ -305,6 +307,9 @@ static void parse_opt(const char *opt, int *mask, char *extra_opts, size_t len)
>>> 
>>> 	if ((len -= strlen(opt))>  0)
>>> 		strcat(extra_opts, opt);
>>> +
>>> +	if (strncmp(opt, "srcaddr=", strlen("srcaddr=")) == 0)
>>> +		parse_local_bind(&glb_local_ip, opt + strlen("srcaddr="));
>>> }
>> 
>> Why is this needed?  Is it just to support legacy (non-string) mounts?
> 
> No, it allows us to bind mount.nfs sockets to the IP that the mount options are asking the
> kernel to bind to.  It's the *only* way to get the mount.nfs process to bind
> to an IP now that I removed the cmd-line args and environ variable hacks.

I don't understand how that can be the case.  The srcaddr mount option should be parsed in stropt.c, where it is used to generate sockets for rpcbind and MNT calls.  This works the same for all of the sockets mount.nfs uses for string mounts.  I don't see any need for this logic in mount.c, especially if you don't support srcaddr= for legacy (nfs_mount_data) style mounts.

> 
>>> /*
>>> @@ -345,21 +350,21 @@ static void parse_opts(const char *options, int *flags, char **extra_opts)
>>> }
>>> 
>>> static int try_mount(char *spec, char *mount_point, int flags,
>>> -			char *fs_type, char **extra_opts, char *mount_opts,
>>> -			int fake, int bg)
>>> +		     char *fs_type, char **extra_opts, char *mount_opts,
>>> +		     int fake, int bg, struct local_bind_info *local_ip)
>>> {
>>> 	int ret;
>>> 
>>> 	if (string)
>>> 		ret = nfsmount_string(spec, mount_point, fs_type, flags,
>>> -					extra_opts, fake, bg);
>>> +				      extra_opts, fake, bg, local_ip);
>>> 	else {
>>> 		if (strcmp(fs_type, "nfs4") == 0)
>>> 			ret = nfs4mount(spec, mount_point, flags,
>>> -					extra_opts, fake, bg);
>>> +					extra_opts, fake, bg, local_ip);
>>> 		else
>>> 			ret = nfsmount(spec, mount_point, flags,
>>> -					extra_opts, fake, bg);
>>> +				       extra_opts, fake, bg, local_ip);
>>> 	}
>> 
>> You're better off not supporting srcaddr= for legacy mounts.  The kernel will never ever support adding a srcaddr field to the nfs_mount_data blob, so why go to the trouble in user space?
> 
> Ok.  I wasn't attempting to support non-string mounts.  I'll look this over and try
> to clean it up.
> 
>>> +void
>>> +parse_local_bind(struct local_bind_info *laddr, const char* str) {
>>> +	/* str is an IP address. */
>>> +	int aiErr;
>>> +	unsigned int i;
>>> +	struct addrinfo *aiHead;
>>> +	struct addrinfo hints;
>>> +	char *node = NULL; /* ip addr */
>>> +	char *service = NULL; /* port */
>>> +	char *tmp = xstrdup(str);
>>> +
>>> +	laddr->is_set = 0;
>>> +
>>> +	memset(&hints, 0, sizeof(hints));
>>> +
>>> +	hints.ai_flags  = AI_NUMERICSERV;
>>> +	hints.ai_socktype = SOCK_STREAM;
>>> +	hints.ai_protocol = IPPROTO_TCP;
>>> +
>>> +	if (str[0] == '[') {
>> 
>> Please don't.  The square bracket thing is just for the NFS special device.  It really isn't needed for a mount option that takes just a presentation IP address.  Or, are you expecting the user to specify a source port number here as well?
> 
> I personally don't want to bind to a particular port, but it seems like something
> that someone might want to do some day, so it would be nice to get the parsing
> able to handle it up front to ease compatibility issues.

Unless you have a specific use case today, we prefer not to speculate about how this might be used.  Let's design exactly what we need right now.

If you want to look at a UI precedent for mount.nfs, ports are specified via separate mount options.  "srcport=" for example, might be used to specify the source port.  In any event, that support can be added later if desired.  Let's keep this as simple and to the point as possible.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




