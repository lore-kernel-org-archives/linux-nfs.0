Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:37333 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755980Ab2ISA7q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Sep 2012 20:59:46 -0400
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only server?
Mime-Version: 1.0 (Apple Message framework v1280)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120919091904.624ee54b@notabene.brown>
Date: Tue, 18 Sep 2012 21:00:01 -0400
Cc: NFS <linux-nfs@vger.kernel.org>
Message-Id: <ECD54A5F-C684-4057-96F5-1D29E7A9A551@oracle.com>
References: <20120918115450.5c65973f@notabene.brown> <F8762BC2-F211-482E-8B5A-A2E991E3F937@oracle.com> <20120918162948.47840d42@notabene.brown> <ECDC5BA9-29CC-4867-8737-CA1110E6C4C6@oracle.com> <20120919091904.624ee54b@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 18, 2012, at 7:19 PM, NeilBrown wrote:

> On Tue, 18 Sep 2012 11:31:28 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> 
>> On Sep 18, 2012, at 2:29 AM, NeilBrown wrote:
>> 
>>> On Tue, 18 Sep 2012 01:28:09 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
>>> 
>>>> Hi Neil-
>>>> 
>>>> On Sep 17, 2012, at 9:54 PM, NeilBrown wrote:
>>>> 
>>>>> It seems that with current nfs-utils, "proto=udp" (either
>>>>> in /etc/nfsmount.conf or on the command line) restricts the mount to using
>>>>> IPv4, not IPv6.
>>>>> For IPv6 you need "udp6".
>>>>> 
>>>>> This isn't made crystal clear by the documentation.  I could fix the
>>>>> documentation, but first I wanted to check if this really is appropriate.
>>>>> Is there a good reason for this, or should we make "udp" mean "udp4 or udp6"
>>>>> and require either "udp4" or "udp6" if we want a particular IP version.
>>>>> 
>>>>> i.e. instead of treating the "proto=" value as a "netid", should we treat it
>>>>> as a "protoname" and match any "netid" in /etc/netconfig with that
>>>>> "protoname"??
>>>> 
>>>> This is working as designed.
>>>> 
>>>> The meaning of each netid is defined in RFC 5665.  "udp" means UDP over IPv4.  This matches precisely what "proto=udp" meant before TI-RPC.  These netids force a particular protocol family when the server is specified by hostname and not IP address.
>>>> 
>>>> What's more, we mean this to match the behavior of the Solaris mount command, where "proto=udp" also has this meaning.
>>>> 
>>>> Which part of the documentation do you think is unclear?
>>>> 
>>> 
>>> Hi Chuck,
>>> Thanks for the reply.
>>> 
>>> It is unfortunate that the tag "proto" is used to choose the "netid".
>>> In common parlance, "udp" and "tcp" are protocols independent of the
>>> underlying transport (IPv4 or IPv6)  much as "nfsv3" or "nfsv4" are
>>> independent of the underlying transport (tcp, udp6, rdma etc).
>>> 
>>> Give this obvious opportunity for confusion it would be good if the
>>> documentation took significant steps to minimise it.
>>> 
>>> I note that nfs(5) does mention /etc/netconfig and the "netid"s that it
>>> contains.  However "udp6" and "tcp6" are never given as examples - doing so
>>> would help the reader see the import of the distinction.
>>> 
>>>      proto=netid    The transport protocol name and protocol family the  NFS
>>>                     client  uses  to transmit requests to the NFS server for
>>>                     this mount point.  If an NFS server has both an IPv4 and
>>>                     an  IPv6  address, using a specific netid will force the
>>>                     use of IPv4 or IPv6 networking to communicate with  that
>>>                     server.
>>> 
>>> I don't think the second sentence would be very helpful to someone who didn't
>>> already understand the subtleties. 
>>> Something like:
>>> 
>>>   A particular netid completely specifies the protocol, so for example
>>>   "tcp" is TCP over IPv4, and "udp6" is UDP over IPv6.  It is not possible
>>>   to request "UDP" without also specifying which version of IP should be
>>>   used.
>> 
>> The "proto=" section is already five paragraphs long, thanks to the complexity of transport autonegotiation and RPC timeout settings.  What might be better is simply to add "See netconfig(5) for a description of netids."
> 
> There are a lot of words in netconfig(5), very few of which are useful to a
> sysadmin wanting to deploy NFS.  So I don't think that addition by itself
> would be very helpful.

We must be looking at different versions of netconfig(5).  My version has just 383 words (according to wc) and has a nice shiny table in it that precisely defines what each netid means.  I don't see how that is not relevant here.

My impression is that a man page is not a user guide; it is meant to be a command reference.  This is perhaps not the place for connecting every dot, but we can agree to disagree on that.


> 
>> 
>>> 
>>> man nfsmount.conf gives the example:
>>> 
>>>      [ NFSMount_Global_Options ]
>>>          Proto=Tcp
>>> 
>>>             The TCP protocol will be used on every NFS mount.
>>> 
>>> which is incomplete.  Not just TCP, but TCP/IPv4 will be used on every NFS
>>> mount.  And again, not IPv6 examples.
>> 
>> Agreed, that should be fixed.  A simple reference to nfs(5) would probably be enough.
> 
> Necessary, but not sufficient I think.  References are useful, but if you
> have to follow them to understand the documentation, then the documentation
> is lacking.

Doesn't "proto=tcp" here mean exactly what it means in nfs(5)?  Why repeat that information?  If it doesn't mean the same, then this is an ideal spot for explaining the difference.  Looks like you reached roughly the same conclusion below.

> 
>> 
>>> (and nfsmount.conf doesn't mention the "default$OPTION=value" syntax...)
>>> 
>>> 
>>> For a usability perspective, I think that treating "udp" as meaning
>>> "udp/ipv4" is a serious mistake and I'm not at all convinced that "Solaris
>>> compatibility" is sufficient justification, but as I have no interest in
>>> offering patches, I won't pursue that line of argument further :-)
>> 
>> Others have been concerned about this point in the past, so let me continue just for a moment.  The selling point is backwards compatibility, which beats usability nearly every time (for better or worse).
>> 
>> When support for IPv6 is introduced, we want the behavior of "proto=udp" to stay the same.  Without TI-RPC support, it means connect to the server via UDP on IPv4.  With TI-RPC, it means precisely the same thing.
>> 
>> For example, suppose an administrator upgrades a system from an O/S without NFS/IPv6 support to an O/S with NFS/IPv6 support.  Suppose further the upgrade was done to get critical bug fixes, and the administrator has no interest in IPv6 at the moment.
>> 
>> Without any further administrative action, should the new O/S now assume that it is OK to use IPv6 for NFS mounts?  Because of the amount of planning and configuration needed to transition a network from IPv4 to IPv6, it would be surprising to most people to find NFS suddenly going over IPv6 in this case.
>> 
>> Personally I think this is less confusing than "proto=udp" meaning something different on old systems, or newer systems built without TI-RPC support, than it does on typical newer systems built with TI-RPC.  Think how much harder it would be to explain in nfs(5).  ;-)
>> 
> 
> So if the sysadmin says "nfsvers=3", then upgrading could change that from
> nfsv3/tcp/ipv4 to nfsv3/tcp/ipv6.  However if they say "proto=udp", then that
> mustn't change from nfsv3/udp/ipv4 to nfsv3/udp/ipv6, even though it could
> allow a change to nfsv4/udp/ipv4.
> I don't really see that pattern here.

The NFS version setting does not control any aspect of the underlying transport, so I wouldn't expect it to have any influence on what address family is chosen.

Thus nfsvers option is, IMO, a red herring.  As we introduce support for TI-RPC, we are changing only the values that can be specified for "proto=" (and "mountproto=").  As such, we care only about the compatibility issues among the values of "proto=".

> Isn't it much easier to say "proto=udp means use UDP over whatever network
> protocol is available" that to mention netconfig which looks to me like some
> sort of internal implementation detail.

IPv6 support for NFS comes by virtue of TI-RPC.  I know there are folks in the Linux community who would prefer we didn't choose TI-RPC, but we really cannot provide interoperable support for NFS over IPv6 without TI-RPC.

Why are netids important for interoperability?  Because rpcbind on servers (eg. non-Linux systems like Solaris or NetApp) advertise IPv6 support by netid.  The "proto=" values match what is advertised.

Out of interest, do you have a use case that could make positive use of a "please use UDP but I don't care whether its IPv4 or IPv6" setting?


> Would you support the following patch?

I'm always game for improving our documentation.  Comment below.

> 
> Thanks,
> NeilBrown
> 
> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
> index da6d6d3..72b8a09 100644
> --- a/utils/mount/nfs.man
> +++ b/utils/mount/nfs.man
> @@ -1,5 +1,5 @@
> .\"@(#)nfs.5"
> -.TH NFS 5 "2 November 2007"
> +.TH NFS 5 "19 September 2012"
> .SH NAME
> nfs \- fstab format and options for the
> .B nfs
> @@ -474,9 +474,17 @@ for NFS versions 2 and 3 only.
> .BI proto= netid
> The transport protocol name and protocol family the NFS client uses
> to transmit requests to the NFS server for this mount point.
> -If an NFS server has both an IPv4 and an IPv6 address, using a specific
> -netid will force the use of IPv4 or IPv6 networking to communicate
> -with that server.
> +A
> +.I netid
> +determines both the
> +.I transport
> +and
> +.I network
> +protocols, so for example

"determines both the protocol family and transport" are closer to how these terms are defined in netconfig(5), and I prefer that formulation.  I still believe a citation of netconfig(5) would be correct and helpful.  A citation in the SEE ALSO section should also be added.

As a matter of word smithing, I think starting a new sentence at "so for example" would be easier to read.

> +.B udp
> +selects UDP over IPv4 while
> +.B tcp6
> +selects TCP over IPv6.
> .IP
> If support for TI-RPC is built into the
> .B mount.nfs
> @@ -775,9 +783,17 @@ for NFS version 4 and newer.
> .BI proto= netid
> The transport protocol name and protocol family the NFS client uses
> to transmit requests to the NFS server for this mount point.
> -If an NFS server has both an IPv4 and an IPv6 address, using a specific
> -netid will force the use of IPv4 or IPv6 networking to communicate
> -with that server.
> +A
> +.I netid
> +determines both the
> +.I transport
> +and
> +.I network
> +protocols, so for example
> +.B udp
> +selects UDP over IPv4 while
> +.B tcp6
> +selects TCP over IPv6.
> .IP
> If support for TI-RPC is built into the
> .B mount.nfs
> @@ -851,6 +867,8 @@ The DATA AND METADATA COHERENCE section discusses
> the behavior of this option in more detail.
> .TP 1.5i
> .BI clientaddr= n.n.n.n
> +.TP 1.5i
> +.BI clientaddr= n:n: ... :n
> Specifies a single IPv4 address (in dotted-quad form),
> or a non-link-local IPv6 address,
> that the NFS client advertises to allow servers
> diff --git a/utils/mount/nfsmount.conf.man b/utils/mount/nfsmount.conf.man
> index 12a3fe7..2258296 100644
> --- a/utils/mount/nfsmount.conf.man
> +++ b/utils/mount/nfsmount.conf.man
> @@ -1,5 +1,5 @@
> .\"@(#)nfsmount.conf.5"
> -.TH NFSMOUNT.CONF 5 "9 Mar 2008"
> +.TH NFSMOUNT.CONF 5 "19 September 2012"
> .SH NAME
> nfsmount.conf - Configuration file for NFS mounts
> .SH SYNOPSIS
> @@ -18,6 +18,10 @@ to particular variables using the
> .BR = 
> operator, as in 
> .BR Proto=Tcp .
> +The variables that can be assigned are exactly the set of NFS specific
> +mount options listed in
> +.BR nfs (5).
> +.PP
> Sections are broken up into three basic categories:
> Global options, Server options and Mount Point options.
> .HP
> @@ -54,7 +58,7 @@ are defined in the configuration file.
>     Proto=Tcp
> .RS
> .HP
> -The TCP protocol will be used on every NFS mount.
> +The TCP/IPv4 protocol will be used on every NFS mount.
> .HP
> .RE
> [ Server \(lqnfsserver.foo.com\(rq ]
> @@ -62,10 +66,13 @@ The TCP protocol will be used on every NFS mount.
>     rsize=32k
> .br
>     wsize=32k
> +.br
> +    proto=udp6
> .HP
> .RS
> -A 33k (32768 bytes) block size will be used as the read and write
> -size on all mounts to the 'nfsserver.foo.com' server.
> +A 32k (32768 bytes) block size will be used as the read and write
> +size on all mounts to the 'nfsserver.foo.com' server.  UDP/IPv6
> +is the protocol to be used.
> .HP
> .RE
> .BR 
> 
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



