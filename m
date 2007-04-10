From: Lon Hohberger <lhh@redhat.com>
Subject: Re: [PATCH 3/4 Revised] NLM - kernel lockd-statd changes
Date: Tue, 10 Apr 2007 10:41:55 -0400
Message-ID: <20070410144155.GD23134@redhat.com>
References: <46156FA0.4030506@redhat.com> <200704101109.44333.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hbh0a-00034N-4s
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 10:53:28 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hbh0c-0000Zh-9u
	for nfs@lists.sourceforge.net; Wed, 11 Apr 2007 10:53:30 -0700
In-Reply-To: <200704101109.44333.okir@lst.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, Apr 10, 2007 at 11:09:43AM +0200, Olaf Kirch wrote:
> On Thursday 05 April 2007 23:52, Wendy Cheng wrote:
> > The changes record the ip interface that accepts the lock requests and 
> > passes the correct "my_name" (in standard IPV4 dot notation) to user 
> > mode statd (instead of system_utsname.nodename). This enables rpc.statd 
> > to add the correct taken-over IPv4 address into the 3rd parameter of 
> > ha_callout program. Current nfs-utils always resets "my_name" into 
> > loopback address (127.0.0.1), regardless the statement made in rpc.statd 
> > man page. Check out "man rpc.statd" and "man sm-notify" for details.
> 
> I don't think this is the right approach. For one, there's not enough
> room in the SM_MON request to accomodate an additional IPv6
> address, so you would have to come up with something entirely
> different for IPv6 anyway.

This is true.

> But more importantly, I think we should
> move away from associating all sorts of network level addresses
> with lockd state - addresses are just smoke and mirrors.

> Despite
> all of NLM/NSMs shortcomings, there's a vehicle to convey identity,
> and that's mon_name. IMHO the focus should be on making it work
> properly if it doesn't do what you do.

We'd have to give it an arbitrary name, completely disassociated from
all network addresses/hostnames/etc.  That could work.  The problems
don't go away, though - they just become different:

* multiple mon_names must be able to exist per-server, since
services in a cluster are not always advertised on the same node (and,
of course, multiple NFS services may exist and *MUST* operate
independently without affecting one-another)

* we have to tell clients our mon_name somehow; since it's not
associated with a server or an IP address

I guess the question is: How is mon_name determined currently by the
clients?


> But - why do you need to record the address on which the request was
> received. at all? Don't you know beforehand on which IP addresses you
> will be servicing NFS requests, and which will need to be migrated?

Here's an answer to the 'why'.  [Clearly, this is an IPv4-centric
example, but it's been implemented this way in the past, so we'll use
it.]

It matters if you have multiple virtual IPs servicing multiple file
systems.  Here's an overly complicated example, which indicates a 'why'
we might need per-address monitoring:

ip address 1
ip address 2
ip address 3
export 1 (file system 1)
export 2 (file system 1)
export 3 (file system 2)
export 4 (file system 2)
export 5 (file system 3)

client A mounts export 1 and 3 via IP address 1
client A mounts export 5 via IP address 2
client B mounts export 2 and 4 via IP address 2
client B mounts export 5 via IP address 1
client C mounts export 5 via IP address 3

Assume locks are taken in all cases.

The mapping we need to know becomes:

file system 1:
   client A via IP 1
   client B via IP 2
file system 2:
   client A via IP 1
   client B via IP 2
file system 3:
   client A via IP 2
   client B via IP 1
   client C via IP 3

For *correct* reclaim (no extraneous SM_NOTIFY requests to the wrong
clients, SM_NOTIFY correctly sent to each client), we must send the
following using the NSM design:

   SM_NOTIFY to client A via IP 1
   SM_NOTIFY to client A via IP 2
   SM_NOTIFY to client B via IP 1
   SM_NOTIFY to client B via IP 2
   SM_NOTIFY to client C via IP 3

Currently, if we do it by file system, fsid, etc - there is no
indication of the path SM_NOTIFY messages need to take.  I.e. If we
send to all clients via any old IP address for a specific file system,
rpc.statd on the remote host will drop the request, and locks won't get
reclaimed.  

One beautiful thing about the above (perhaps otherwise ugly) approach
(storing the entire fs/client/server-ip mapping) is that we maintain
compatibility with other NFS implementations.  We don't break anything
from the client's perspective; it works like it always did.

If we were able to use mon_name for the above set, it would be a single
message per client.  On the client side, there would need to be a
mapping of the mon_name to each network-level address.  When we send
SM_NOTIFY to each client, it can then reclaim the locks for all
associated server addresses (which may be different network protocols).

> Side note: should we think about replacing SM_MON with some new
> design altogether

Possibly.

> (think netlink)?

Redesign of the SM_MON messaging doesn't necessarily require rewriting
the underlying lockd->statd communication path.  That said, I have no
opinion about the merits (or not) of using netlink over the current
implementation.

We could also make a file system...

-- Lon

-- 
Lon Hohberger - Software Engineer - Red Hat, Inc.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
