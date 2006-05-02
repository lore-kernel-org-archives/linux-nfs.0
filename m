From: Jim Carter <jimc@math.ucla.edu>
Subject: Re: [autofs] [RFC] Multiple server selection and replicated mount
 failover
Date: Tue, 2 May 2006 11:14:09 -0700 (PDT)
Message-ID: <Pine.LNX.4.63.0605021028330.17078@simba.math.ucla.edu>
References: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net,
	autofs mailing list <autofs@linux.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FazO4-0002v5-LL
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 11:14:16 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FazO4-0003tY-H9
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 11:14:16 -0700
Received: from simba.math.ucla.edu ([128.97.4.125])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FazO3-0002VB-36
	for nfs@lists.sourceforge.net; Tue, 02 May 2006 11:14:16 -0700
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.64.0605021257500.3868@raven.themaw.net>
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

On Tue, 2 May 2006, Ian Kent wrote:

> For some time now I have had code in autofs that attempts to select an 
> appropriate server from a weighted list to satisfy server priority 
> selection and Replicated Server requirements. The code has been 
> problematic from the beginning and is still incorrect largely due to me 
> not merging the original patch well and also not fixing it correctly 
> afterward.
> 
> So I'd like to have this work properly and to do that I also need to 
> consider read-only NFS mount fail over.

I'm glad to hear that there may be progress in server selection. But I'm
not sure if you're looking at the problem from the direction that I am.

First, I don't think it's necessary to replicate the original Sun
behavior exactly, although it would be helpful but not mandatory to
allow something in the automount maps that resembles Solaris syntax, to
ease user (sysop) training.  

The current version of mount on Linux (util-linux-2.12) does not know
about picking servers from a list; at least the man page doesn't know.
This means that the whole job of server selection falls to automount.  I
think that's the right way to design the system.  However, that also
means that automount needs to know something about NFS servers
specifically.  The less it knows, the better, in my opinion, so the
design of NFS mount options can be separated from automount.

Your task is to make an ordered list of servers, best to worst, and to
mount from the best one that answers.  To my mind a concentration on
"groups" is confusing for the implementor and user, as well as requiring
inside knowledge so you can classify the servers.  On the other hand,
the sysop does want to be able to use the same automount map on a
variety of machines (e.g. map served by NIS).  So what discriminations
might be made?

Explicit preferences set by the sysop should be able to trump all other
discriminations -- or it should be possible to make them small enough to
be overridden by intrinsic differences.  Let's specify that intrinsic
differences are 5 or 10 points, and the explicit preference could be set
to 30 to override, or 1 to subtly influence.  For example, you could
give preferences of 0, 1 and 30 to designate a "last choice" server, and
two more preferred servers which would be picked on intrinsic grounds,
the first one being most preferred if all else is equal.  (Low score
wins -- say that explicitly in the documentation.)

As for intrinsic differences, let's say that being on a different subnet
costs 10 points.  That distinction is important.  I'm not too sure what
the "same net" discrimination might mean.  At my shop, if 128.97.4.x
(x.math.ucla.edu) is picking servers, then 128.97.70.x (x.math.ucla.edu)
is local, 128.97.12.x (x.pic.ucla.edu) is also local, but 128.97.31.x
(x.ess.ucla.edu) is a different department in another building.  If we
have to make this discrimination, let's define it like this: let the
"length" be the number of bytes (including dots) in the client's (not
server's) canonical name.  Starting from the end, count the number of
bytes that are equal in the two names.  Then the penalty for the server
is 10*(1 - common/length).  For example, if the client is
simba.math.ucla.edu and the server is tupelo.math.ucla.edu, length is
19, common is 14, and the penalty is 3 points (rounding up 2.6).  It
would be 6 points for a server in PIC or ESS, which would be considered
equally bad.

I'd say to ignore server capabilities, e.g. NFSv4 versus NFSv2, because
that takes too much inside information -- you actually have to talk to
the server.  If the client and server can negotiate to make the mount
happen, fine.  If not, automount has to go to the next server.  (And it
should remember that the back-version server didn't work out, for a
generous but non-infinite time like a few hours.)

NFSv4 has a nice behavior: if the client doesn't use a NFSv4 mount for a
configurable time (default 10 minutes), it will sync and give up its
filehandle, although I believe the client still claims that the
filesystem is mounted.  On subsequent use it will [attempt to]
re-acquire the filehandle transparently.  This means that if the server
crashes the filehandle will not be stale, although if the using program
wakes up before the server comes back, it will get an I/O error.

There's a lot of good stuff about NFSv4 on http://wiki.linux-nfs.org/ I got 
NFSv4 working on SuSE 10.0 (kernel 2.6.13, nfs-utils-1.0.7) as a demo; 
notes from this project (which need to be finished) are at 
http://www.math.ucla.edu/~jimc/documents/nfsv4-0601.html

You asked where various steps should be implemented.  Picking the server:
that's the job of the userspace daemon, and I don't see too much help that
the kernel might give.  Readonly failover is another matter -- which I
think is important.

Here's a top of head kludge for failover:  Autofs furnishes a synthetic 
directory, let's call it /net/warez.  The user daemon NFS mounts something 
on it, example julia:/m1/warez.  The user daemon mounts another 
inter-layer, maybe FUSE, on top of the NFS, and client I/O operations go to 
that filesystem.  When the inter-layer starts getting I/O errors because 
the NFS driver has decided that the server is dead, the inter-layer 
notifies the automount daemon. It tells the kernel autofs driver to create 
a temp name /net/xyz123, and it mounts a different server on it, let's say 
sonia:/m2/warez.  Then the names are renamed to, respectively, /net/xyz124 
and /net/warez (the new one).  Finally the automount daemon does a "bind" 
or "move" mount to transfer the inter-layer to be mounted on the new 
/net/warez.  Then the I/O operation has to be re-tried on the new server.
Wrecked directories are cleaned up as circumstances allow.

I like the idea of minimal special case code in the kernel to support 
failover.  If it's even possible to do the "move" mount like I suggested.

James F. Carter          Voice 310 825 2897    FAX 310 206 6673
UCLA-Mathnet;  6115 MSA; 405 Hilgard Ave.; Los Angeles, CA, USA  90095-1555
Email: jimc@math.ucla.edu    http://www.math.ucla.edu/~jimc (q.v. for PGP key)


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
