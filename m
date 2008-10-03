From: Mike Eisler <email2mre-linuxv4@yahoo.com>
Subject: Re: netid in the NFS mount command
Date: Fri, 3 Oct 2008 05:56:35 -0700 (PDT)
Message-ID: <433830.69599.qm@web38108.mail.mud.yahoo.com>
References: <BE3BB0EF-ABC9-4BB3-A828-2ACE54220EC9@oracle.com>
Reply-To: email2mre-linuxv4@yahoo.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web38108.mail.mud.yahoo.com ([209.191.124.135]:21646 "HELO
	web38108.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750813AbYJCM4g (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Oct 2008 08:56:36 -0400
In-Reply-To: <BE3BB0EF-ABC9-4BB3-A828-2ACE54220EC9@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>




--- On Thu, 9/18/08, Chuck Lever <chuck.lever@oracle.com> wrote:


> > But I think there is value in following the Solaris
> convention
> > (which I established when I was at Sun in the 1990s
> working on the
> > Solaris NFS/TCP stack) because by specifying
> "proto=tcp6" in the
> > mount command, this can force the use of TCP over the
> IPv6 networking
> > protocol in cases where the same host name is
> resolvable to both an
> > IPv4 or IPv6 host address. Of course, one could edit
> nsswitch.conf  
> > and /etc/hosts or ipnodes to insert an IPv6-only host
> name, but that  
> > is cumbersome.
> 
> On the other hand, if a user mounts "server" with
> "proto=tcp" on  
> Solaris, and the server drops its IPv4 addresses in favor
> of IPv6  
> addresses, client sysadmins will have to be aware of this
> change, and  
> modify their mount options.  On Linux, the server can
> change to IPv6- 
> only, and the clients will adjust without intervention.

Right, well the mount would fail in the Solaris case, so awareness
will come quickly. Optimizing for the infrequent case of
transition to IPv6 doesn't see like the better choice to me.

And if the server supports both IPv4 and IPv6, maybe the client's
system administrator wants to make sure IPv4 is used, because,
he's discovered that the IPv6 checksum support for the ethernet
chips being used on the client and/or server does not exist, or it does
exist, but the TCP/IP stacks in the client and/or server don't take
advantage of it, and thus CPU utilization jumps by 25% and performance
by say 35%.

> 
> Perhaps for one user that operates both the client and
> server, this is  
> not an issue.  However, this does become a problem if a
> large number  
> of clients access a server that is being changed in another
>  
> administrative domain.  Naturally this can be hidden with
> automounter,  
> but we wander straight back into the realm of diddling with
>  
> configuration files, which is cumbersome.  Not to mention
> that not  
> everyone chooses to use an automounter.
> 
> It seems more natural to me to use an AF_INET6 address to
> choose NFS  
> over IPv6, rather than a netid.  One of my interests is to

I think is is unnatural to tell a customer that if he wants to
force the use IPv6 or IPv4 on the command line, he has to specify
a IPv4 or IPv6 address.

> keep the  
> details of AF_INET v. AF_INET6 inconsequential to NFS.  It
> would be  
> easy, however, to add a "netid=" mount option in
> addition to "proto="  
> where a true netid could be used instead of a protocol
> name.

I hope you at least do that. It would be nice if the 
Solaris and Linux mount commands could agree on this in order
to avoid enraging customers that use both, but so be it.

> 
> And finally, we had to do something to allow NFS/RDMA on
> InfiniBand,  
> which still doesn't have a netid, as you point out. 
> According to the  
> man page I have on my OpenSolaris system, it actually does
> allow  
> "proto=rdma".

If "rdma" does not have an entry in /etc/netconfig then apparently 
OpenSolaris is not consistent with the TI-RPC architecture of Solaris.

> > BTW, the terse netid stuff in RFC3530 is being
> codified in a separate
> > to-be-approved RFC. You can look at the internet draft
> at:
> >
> http://tools.ietf.org/wg/nfsv4/draft-ietf-nfsv4-rpc-netid/
> 
> 
> I personally am glad of any clarification around netids.
> 
> One thing I noticed was this in RFC 1833 (August 1995):
> 
> /*
> * A mapping of (program, version, network ID) to address *
> * The network identifier (r_netid):
> * This is a string that represents a local identification
> for a
> * network. This is defined by a system administrator based
> on local
> * conventions, and cannot be depended on to have the same
> value on
> * every system. */
> 
>  From this, I assumed that netids were not standardized on
> purpose.   
> Mike, does your draft address and clarify this statement? 
> Will your  
> draft supercede RFC 1833 and subsequent related RFCs?

The netid draft updates RFC 1833, and so "cannot be depended on to have the same value on every system." will no longer be true.

