Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:49207 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051Ab1GOWzf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 18:55:35 -0400
Subject: Re: mounting via udp from legacy multi-homed servers...
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110713173426.03576562@notabene.brown>
Date: Fri, 15 Jul 2011 23:55:19 +0100
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-Id: <BCA784C6-89A9-459E-96CD-9D7BA1227CAE@oracle.com>
References: <20110713173426.03576562@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jul 13, 2011, at 8:34 AM, NeilBrown wrote:

> 
> 
> This problem doesn't seem to go away, does it :-(
> 
> 
> While modern Linux always replies to UDP requests from the same address that
> the request was sent to, some legacy systems do not, and some customers use
> these legacy systems and cannot upgrade.
> 
> And as they are legacy systems, it is often the case that UDP is more
> performant than TCP.
> 
> nfs-utils always uses a connected UDP socket to talk to servers (which I think
> is correct so we get errors when reported by ICMP-unreachable messages) and so
> fails to talk to these legacy systems (when UDP is requested).
> 
> I had such a case recently and managed to make it work by using:
> 
>   proto=udp,mountproto=tcp,port=2049
> 
> By setting mountproto=tcp, nfs-utils uses tcp for almost all communication
> with the server.
> The one little problem is that mount does a portmap lookup to check the
> port number to talk to the NFS server and seeing we requested UDP for NFS,
> it talks to portmap via UDP and never sees the reply.
> Setting "port=2049" avoids this lookup so the mount succeeds.
> 
> We could just decide that that is the way it is, document that this is how to
> talk to systems over UDP when they have a broken portmaper and move on.

libtirpc will always perform the rpcbind query on the same transport as the original protocol wants to use, for example.  The libtirpc v2 portmap service I believe performs all queries via UDP.  I don't have the code in front of me to confirm that.

> But it would be nice if we could find a way to make a solution less ugly and
> easier to find.
> 
> So some thoughts:
> 
> 1/ We could use tcp for all rpcbind lookups if tcp was requested for either
>   MOUNT or NFS.

This will probably break things that work today.

> 2/ If '-v' was given and a UDP lookup to portmap timedout, we could retry
>   without connecting (and with a shorter timeout), and print an explanatory 
>   message if that succeeded.

"-v" is already in use, as far as I know, and as has been pointed out.

> 3/ We could have a mount option "bindproto=tcp" or maybe "bind=noconnect"
>   which could be recommended by the above explanatory message.

And that would require some kernel mods too, since the kernel may also perform an rpcbind query in some cases.

4.  nfs(5) could explain more clearly that the transport protocol used for the rpcbind goes with the "proto=" and "mountproto=" options.  "Doctor, it hurts when I do that..."  But you might provide your workaround, above, in the EXAMPLES section.

> Does anyone else have any good ideas, or any deep aversions to any of the
> above.
> I'm tempted to go for '1' and possibly add '2', but not bother with '3'.
> 
> ??
> 
> Thanks,
> NeilBrown

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



