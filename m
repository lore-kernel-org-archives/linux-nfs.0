From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: netid in the NFS mount command
Date: Thu, 18 Sep 2008 14:04:20 -0500
Message-ID: <BE3BB0EF-ABC9-4BB3-A828-2ACE54220EC9@oracle.com>
References: <288393.82711.qm@web38108.mail.mud.yahoo.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:24844 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754929AbYIRTGc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2008 15:06:32 -0400
In-Reply-To: <288393.82711.qm-EWur9jtuEOivuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 18, 2008, at 6:16 AM, Mike Eisler wrote:
> http://article.gmane.org/gmane.linux.nfs/16950 has Chuck Lever's  
> patch to the nfs man page, which includes:
>
>
> -The default value depends on whether
> -.IR proto=udp
> [...]
> +.BI proto= netid
> +The transport protocol used by the RPC client
> +to transmit requests to the NFS server for this mount point.
> +The value of
> +.I netid
> +can be either
> +.B udp
> or
> -.IR proto=tcp
> -is in effect (see below).
>
> After talking to Chuck yesterday, it appears that he is being literal:
> the netid can only be either udp or tcp, and not also udp6 or tcp6,  
> which
> are the netids IETF defines (see RFC3530) for ONC RPC over UDP/IPv6
> and TCP/IPv6.
>
> If proto= is going to mean transport protocol in the Linux mount
> command (as opposed to meaning a netid as it does in the Solaris mount
> command), then please fix the man page to say that.

The man page should be corrected.

However, before we do that, we need to revisit the issue of how the  
kernel selects an RPC transport capability, and resolve as much as  
possible how this should work.

> But I think there is value in following the Solaris convention
> (which I established when I was at Sun in the 1990s working on the
> Solaris NFS/TCP stack) because by specifying "proto=tcp6" in the
> mount command, this can force the use of TCP over the IPv6 networking
> protocol in cases where the same host name is resolvable to both an
> IPv4 or IPv6 host address. Of course, one could edit nsswitch.conf  
> and /etc/hosts or ipnodes to insert an IPv6-only host name, but that  
> is cumbersome.

On the other hand, if a user mounts "server" with "proto=tcp" on  
Solaris, and the server drops its IPv4 addresses in favor of IPv6  
addresses, client sysadmins will have to be aware of this change, and  
modify their mount options.  On Linux, the server can change to IPv6- 
only, and the clients will adjust without intervention.

Perhaps for one user that operates both the client and server, this is  
not an issue.  However, this does become a problem if a large number  
of clients access a server that is being changed in another  
administrative domain.  Naturally this can be hidden with automounter,  
but we wander straight back into the realm of diddling with  
configuration files, which is cumbersome.  Not to mention that not  
everyone chooses to use an automounter.

It seems more natural to me to use an AF_INET6 address to choose NFS  
over IPv6, rather than a netid.  One of my interests is to keep the  
details of AF_INET v. AF_INET6 inconsequential to NFS.  It would be  
easy, however, to add a "netid=" mount option in addition to "proto="  
where a true netid could be used instead of a protocol name.

And finally, we had to do something to allow NFS/RDMA on InfiniBand,  
which still doesn't have a netid, as you point out.  According to the  
man page I have on my OpenSolaris system, it actually does allow  
"proto=rdma".

> BTW, the terse netid stuff in RFC3530 is being codified in a separate
> to-be-approved RFC. You can look at the internet draft at:
> http://tools.ietf.org/wg/nfsv4/draft-ietf-nfsv4-rpc-netid/


I personally am glad of any clarification around netids.

One thing I noticed was this in RFC 1833 (August 1995):

/*
* A mapping of (program, version, network ID) to address *
* The network identifier (r_netid):
* This is a string that represents a local identification for a
* network. This is defined by a system administrator based on local
* conventions, and cannot be depended on to have the same value on
* every system. */

 From this, I assumed that netids were not standardized on purpose.   
Mike, does your draft address and clarify this statement?  Will your  
draft supercede RFC 1833 and subsequent related RFCs?


> Netids for all the IETF transports that I am aware of are specified.
> Additional ones can be added after the RFC is published by registering
> with IANA via the process specified in the internet-draft.
>
> Note that rdma and rdma6, corresponding to the rdma over TCP/IP and
> rdma over TCP/IPv6 protocols are among the netids. If people want
> a netid for a raw, non-IP-based RDMA transport, that will have to be
> registered with IANA.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
