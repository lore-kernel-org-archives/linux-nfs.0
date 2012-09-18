Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:43798 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756783Ab2IRPbf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Sep 2012 11:31:35 -0400
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only server?
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120918162948.47840d42@notabene.brown>
Date: Tue, 18 Sep 2012 11:31:28 -0400
Cc: NFS <linux-nfs@vger.kernel.org>
Message-Id: <ECDC5BA9-29CC-4867-8737-CA1110E6C4C6@oracle.com>
References: <20120918115450.5c65973f@notabene.brown> <F8762BC2-F211-482E-8B5A-A2E991E3F937@oracle.com> <20120918162948.47840d42@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Sep 18, 2012, at 2:29 AM, NeilBrown wrote:

> On Tue, 18 Sep 2012 01:28:09 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Hi Neil-
>> 
>> On Sep 17, 2012, at 9:54 PM, NeilBrown wrote:
>> 
>>> It seems that with current nfs-utils, "proto=udp" (either
>>> in /etc/nfsmount.conf or on the command line) restricts the mount to using
>>> IPv4, not IPv6.
>>> For IPv6 you need "udp6".
>>> 
>>> This isn't made crystal clear by the documentation.  I could fix the
>>> documentation, but first I wanted to check if this really is appropriate.
>>> Is there a good reason for this, or should we make "udp" mean "udp4 or udp6"
>>> and require either "udp4" or "udp6" if we want a particular IP version.
>>> 
>>> i.e. instead of treating the "proto=" value as a "netid", should we treat it
>>> as a "protoname" and match any "netid" in /etc/netconfig with that
>>> "protoname"??
>> 
>> This is working as designed.
>> 
>> The meaning of each netid is defined in RFC 5665.  "udp" means UDP over IPv4.  This matches precisely what "proto=udp" meant before TI-RPC.  These netids force a particular protocol family when the server is specified by hostname and not IP address.
>> 
>> What's more, we mean this to match the behavior of the Solaris mount command, where "proto=udp" also has this meaning.
>> 
>> Which part of the documentation do you think is unclear?
>> 
> 
> Hi Chuck,
> Thanks for the reply.
> 
> It is unfortunate that the tag "proto" is used to choose the "netid".
> In common parlance, "udp" and "tcp" are protocols independent of the
> underlying transport (IPv4 or IPv6)  much as "nfsv3" or "nfsv4" are
> independent of the underlying transport (tcp, udp6, rdma etc).
> 
> Give this obvious opportunity for confusion it would be good if the
> documentation took significant steps to minimise it.
> 
> I note that nfs(5) does mention /etc/netconfig and the "netid"s that it
> contains.  However "udp6" and "tcp6" are never given as examples - doing so
> would help the reader see the import of the distinction.
> 
>       proto=netid    The transport protocol name and protocol family the  NFS
>                      client  uses  to transmit requests to the NFS server for
>                      this mount point.  If an NFS server has both an IPv4 and
>                      an  IPv6  address, using a specific netid will force the
>                      use of IPv4 or IPv6 networking to communicate with  that
>                      server.
> 
> I don't think the second sentence would be very helpful to someone who didn't
> already understand the subtleties. 
> Something like:
> 
>    A particular netid completely specifies the protocol, so for example
>    "tcp" is TCP over IPv4, and "udp6" is UDP over IPv6.  It is not possible
>    to request "UDP" without also specifying which version of IP should be
>    used.

The "proto=" section is already five paragraphs long, thanks to the complexity of transport autonegotiation and RPC timeout settings.  What might be better is simply to add "See netconfig(5) for a description of netids."

> 
> man nfsmount.conf gives the example:
> 
>       [ NFSMount_Global_Options ]
>           Proto=Tcp
> 
>              The TCP protocol will be used on every NFS mount.
> 
> which is incomplete.  Not just TCP, but TCP/IPv4 will be used on every NFS
> mount.  And again, not IPv6 examples.

Agreed, that should be fixed.  A simple reference to nfs(5) would probably be enough.

> (and nfsmount.conf doesn't mention the "default$OPTION=value" syntax...)
> 
> 
> For a usability perspective, I think that treating "udp" as meaning
> "udp/ipv4" is a serious mistake and I'm not at all convinced that "Solaris
> compatibility" is sufficient justification, but as I have no interest in
> offering patches, I won't pursue that line of argument further :-)

Others have been concerned about this point in the past, so let me continue just for a moment.  The selling point is backwards compatibility, which beats usability nearly every time (for better or worse).

When support for IPv6 is introduced, we want the behavior of "proto=udp" to stay the same.  Without TI-RPC support, it means connect to the server via UDP on IPv4.  With TI-RPC, it means precisely the same thing.

For example, suppose an administrator upgrades a system from an O/S without NFS/IPv6 support to an O/S with NFS/IPv6 support.  Suppose further the upgrade was done to get critical bug fixes, and the administrator has no interest in IPv6 at the moment.

Without any further administrative action, should the new O/S now assume that it is OK to use IPv6 for NFS mounts?  Because of the amount of planning and configuration needed to transition a network from IPv4 to IPv6, it would be surprising to most people to find NFS suddenly going over IPv6 in this case.

Personally I think this is less confusing than "proto=udp" meaning something different on old systems, or newer systems built without TI-RPC support, than it does on typical newer systems built with TI-RPC.  Think how much harder it would be to explain in nfs(5).  ;-)

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




