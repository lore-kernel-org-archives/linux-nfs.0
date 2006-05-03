From: Ian Kent <raven@themaw.net>
Subject: Re: [autofs] [RFC] Multiple server selection and replicated mount
 failover
Date: Wed, 3 May 2006 11:53:53 +0800 (WST)
Message-ID: <Pine.LNX.4.64.0605031045090.3667@raven.themaw.net>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
 <Pine.LNX.4.63.0605021028330.17078@simba.math.ucla.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net,
	autofs mailing list <autofs@linux.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fb8SX-0007bf-IK
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 20:55:29 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1Fb8SV-0007Dg-Im
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 20:55:29 -0700
To: Jim Carter <jimc@math.ucla.edu>
In-Reply-To: <Pine.LNX.4.63.0605021028330.17078@simba.math.ucla.edu>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, 2 May 2006, Jim Carter wrote:

> On Tue, 2 May 2006, Ian Kent wrote:
> 
> > For some time now I have had code in autofs that attempts to select an 
> > appropriate server from a weighted list to satisfy server priority 
> > selection and Replicated Server requirements. The code has been 
> > problematic from the beginning and is still incorrect largely due to me 
> > not merging the original patch well and also not fixing it correctly 
> > afterward.
> > 
> > So I'd like to have this work properly and to do that I also need to 
> > consider read-only NFS mount fail over.
> 
> I'm glad to hear that there may be progress in server selection. But I'm
> not sure if you're looking at the problem from the direction that I am.
> 
> First, I don't think it's necessary to replicate the original Sun
> behavior exactly, although it would be helpful but not mandatory to
> allow something in the automount maps that resembles Solaris syntax, to
> ease user (sysop) training.  

Sure but if it's different it must be a superset of the existing expected 
functionality for compatibility reasons. The minimum requirement must be 
that existing maps behave as people have come to expect.

> 
> The current version of mount on Linux (util-linux-2.12) does not know
> about picking servers from a list; at least the man page doesn't know.
> This means that the whole job of server selection falls to automount.  I
> think that's the right way to design the system.  However, that also
> means that automount needs to know something about NFS servers
> specifically.  The less it knows, the better, in my opinion, so the
> design of NFS mount options can be separated from automount.

Agreed.

mount(8) may be the "right" place to do this.

The Solaris automounter did this before mount knew about server selection 
but yes, we may need to keep this in autofs for a while longer.

> 
> Your task is to make an ordered list of servers, best to worst, and to
> mount from the best one that answers.  To my mind a concentration on
> "groups" is confusing for the implementor and user, as well as requiring
> inside knowledge so you can classify the servers.  On the other hand,
> the sysop does want to be able to use the same automount map on a
> variety of machines (e.g. map served by NIS).  So what discriminations
> might be made?

I don't think the user need know anything about the selection internals. 

All that a user should need to know is that servers on a local network 
will be selected before those on networks farther away. Our challenge is 
to define proximity metric of "local" and "farther away" in a sensible 
way.

The reference to "group" is to identify the requirement that all servers 
at the same proximity need to be tried before moving onto the next closest 
list of servers.

> 
> Explicit preferences set by the sysop should be able to trump all other
> discriminations -- or it should be possible to make them small enough to
> be overridden by intrinsic differences.  Let's specify that intrinsic
> differences are 5 or 10 points, and the explicit preference could be set
> to 30 to override, or 1 to subtly influence.  For example, you could
> give preferences of 0, 1 and 30 to designate a "last choice" server, and
> two more preferred servers which would be picked on intrinsic grounds,
> the first one being most preferred if all else is equal.  (Low score
> wins -- say that explicitly in the documentation.)

This sounds like the weighting that may be attached to a server.

My original incorrect interpretation was what you describe and it leads to 
incorrect server selection.

To meet the minimum requirement network proximity needs to have a higher 
priority than weights given to servers.

Of course, by and large, NFS servers that people use this way are close so 
the trick then falls to our definition of "local" and "farther away".

I don't think we need to go as far as to allocate point values as they may 
be specified as weights, a muliplier of cost, where cost is an as yet 
undefined function of proximity. This is probably as simple as the nailing 
"local" and "farther away" definition.

> 
> As for intrinsic differences, let's say that being on a different subnet
> costs 10 points.  That distinction is important.  I'm not too sure what
> the "same net" discrimination might mean.  At my shop, if 128.97.4.x
> (x.math.ucla.edu) is picking servers, then 128.97.70.x (x.math.ucla.edu)
> is local, 128.97.12.x (x.pic.ucla.edu) is also local, but 128.97.31.x
> (x.ess.ucla.edu) is a different department in another building.  If we
> have to make this discrimination, let's define it like this: let the
> "length" be the number of bytes (including dots) in the client's (not
> server's) canonical name.  Starting from the end, count the number of
> bytes that are equal in the two names.  Then the penalty for the server
> is 10*(1 - common/length).  For example, if the client is
> simba.math.ucla.edu and the server is tupelo.math.ucla.edu, length is
> 19, common is 14, and the penalty is 3 points (rounding up 2.6).  It
> would be 6 points for a server in PIC or ESS, which would be considered
> equally bad.

Good idea but equally there are many examples where this would be really
bad.

Consider a company that has names like:

server.addom.company.com and server.nfsserv.company.com

where the addom contains their world-wide Active directory servers and 
the unix subdomain contains their world-wide NFS servers.

Don't get me wrong this exact same problem exists with network addresses 
as well, such as a company with a B class network with a bunch of VPN 
connections.

Sure it's a contrived example but I've seen similar nameing schemes.

The only thing we can really relly on is the subnet of the local 
interface(s) of the machine we are doing the calculation on.

> 
> I'd say to ignore server capabilities, e.g. NFSv4 versus NFSv2, because
> that takes too much inside information -- you actually have to talk to
> the server.  If the client and server can negotiate to make the mount
> happen, fine.  If not, automount has to go to the next server.  (And it
> should remember that the back-version server didn't work out, for a
> generous but non-infinite time like a few hours.)

Again this was my original approach which is probably contributing to the 
incorrect selection in autofs now.

Nevertheless I'm not sure how usefull this descrimination is and NFS v4 
probably needs to be considered seperatly.

I think we will have to connect to the server in some way to establish 
cost or even just to establish availability. We don't want to even 
attempt to mount from a server that is down but at the same time we 
can't remove it from our list as it may come back.

> 
> NFSv4 has a nice behavior: if the client doesn't use a NFSv4 mount for a
> configurable time (default 10 minutes), it will sync and give up its
> filehandle, although I believe the client still claims that the
> filesystem is mounted.  On subsequent use it will [attempt to]
> re-acquire the filehandle transparently.  This means that if the server
> crashes the filehandle will not be stale, although if the using program
> wakes up before the server comes back, it will get an I/O error.
> 
> There's a lot of good stuff about NFSv4 on http://wiki.linux-nfs.org/ I got 
> NFSv4 working on SuSE 10.0 (kernel 2.6.13, nfs-utils-1.0.7) as a demo; 
> notes from this project (which need to be finished) are at 
> http://www.math.ucla.edu/~jimc/documents/nfsv4-0601.html
> 
> You asked where various steps should be implemented.  Picking the server:
> that's the job of the userspace daemon, and I don't see too much help that
> the kernel might give.  Readonly failover is another matter -- which I
> think is important.
> 
> Here's a top of head kludge for failover:  Autofs furnishes a synthetic 
> directory, let's call it /net/warez.  The user daemon NFS mounts something 
> on it, example julia:/m1/warez.  The user daemon mounts another 
> inter-layer, maybe FUSE, on top of the NFS, and client I/O operations go to 
> that filesystem.  When the inter-layer starts getting I/O errors because 
> the NFS driver has decided that the server is dead, the inter-layer 
> notifies the automount daemon. It tells the kernel autofs driver to create 
> a temp name /net/xyz123, and it mounts a different server on it, let's say 
> sonia:/m2/warez.  Then the names are renamed to, respectively, /net/xyz124 
> and /net/warez (the new one).  Finally the automount daemon does a "bind" 
> or "move" mount to transfer the inter-layer to be mounted on the new 
> /net/warez.  Then the I/O operation has to be re-tried on the new server.
> Wrecked directories are cleaned up as circumstances allow.

This sounds a lot like it would require a stackable filesystem and that's 
probably the only way such an approach would be workable.

Getting a stackable filesystem to work well enough to live in the kernel 
is a huge task but is an option.

But there must be a simpler way.

Ian



-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
