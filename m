Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:35890 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643Ab1GMHeh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2011 03:34:37 -0400
Date: Wed, 13 Jul 2011 17:34:26 +1000
From: NeilBrown <neilb@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: mounting via udp from legacy multi-homed servers...
Message-ID: <20110713173426.03576562@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



This problem doesn't seem to go away, does it :-(


While modern Linux always replies to UDP requests from the same address that
the request was sent to, some legacy systems do not, and some customers use
these legacy systems and cannot upgrade.

And as they are legacy systems, it is often the case that UDP is more
performant than TCP.

nfs-utils always uses a connected UDP socket to talk to servers (which I think
is correct so we get errors when reported by ICMP-unreachable messages) and so
fails to talk to these legacy systems (when UDP is requested).

I had such a case recently and managed to make it work by using:

   proto=udp,mountproto=tcp,port=2049

By setting mountproto=tcp, nfs-utils uses tcp for almost all communication
with the server.
The one little problem is that mount does a portmap lookup to check the
port number to talk to the NFS server and seeing we requested UDP for NFS,
it talks to portmap via UDP and never sees the reply.
Setting "port=2049" avoids this lookup so the mount succeeds.

We could just decide that that is the way it is, document that this is how to
talk to systems over UDP when they have a broken portmaper and move on.

But it would be nice if we could find a way to make a solution less ugly and
easier to find.

So some thoughts:

1/ We could use tcp for all rpcbind lookups if tcp was requested for either
   MOUNT or NFS.

2/ If '-v' was given and a UDP lookup to portmap timedout, we could retry
   without connecting (and with a shorter timeout), and print an explanatory 
   message if that succeeded.

3/ We could have a mount option "bindproto=tcp" or maybe "bind=noconnect"
   which could be recommended by the above explanatory message.


Does anyone else have any good ideas, or any deep aversions to any of the
above.
I'm tempted to go for '1' and possibly add '2', but not bother with '3'.

??

Thanks,
NeilBrown
