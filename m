From: "David B. Ritch" <dritch@hpti.com>
Subject: Re: NFS as a Cluster File System.
Date: 12 Jan 2003 23:20:09 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1042431609.2692.80.camel@localhost>
References: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS mailing list <nfs@lists.sourceforge.net>, linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pcp234914pcs.elictc01.md.comcast.net ([68.55.182.99] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Xw8E-0007nx-00
	for <nfs@lists.sourceforge.net>; Sun, 12 Jan 2003 20:23:26 -0800
To: Lorn Kay <lorn_kay@hotmail.com>
In-Reply-To: <F112Sbh29cM3oryKFRJ0001248d@hotmail.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

As has been discussed, there are various meanings for the expression
CFS.  So, I'll assume that you are looking for a filesystem to serve
files to a cluster.

You're right - NFS has a bad reputation.  However, I believe that there
are 3 additional reasons that I have not seen in this thread.  First,
until very recently, NFS has not been stable under Linux.  Before the
2.4.18 (or possibly 2.4.14) kernel, it had frequent hangs, at least on
SMP systems.  Even under 2.4.18 and 2.4.19, we have seen peculiar
results occasionally, such as "ls -l" displaying the wrong owners for
most of the files in a directory.  2.4.20 looks pretty good.  This is
not an NFS problem as such, but a Linux problem.  I've used NFS
extensively with many commercial versions of Unix without such
problems.  Thanks to Trond, Neil, and others for solving this for Linux!

Second, NFS does not provide much security.  It doesn't provide for
strong authentication, and it doesn't provide for encryption in
transit.  It's vulnerable to lots of DOS attacks.  It's really only
suited to a local, controlled network.

Finally, NFS is very sensitive to latency.  I'm not sure whether this is
an issue inherent to the protocol, or just to all implementations that I
have used.  However, I have seen a few millisecond latency reduce NFS
throughput from 10-12MB/sec over 100BaseT to 3MB/sec or less.

In addition, for a cluster, nfs has an additional weakness over some
newer filesystems.  It typically depends on a single server, or
sometimes a cluster of servers.  Either way, when a parallel job starts
up on a fairly large cluster, typically many nodes suddenly attempt to
access the same filesystem on a single server.  This may be just to load
an executable, or it may be to access a data file.  Either way, the
server is suddenly subject to a very high load, and its performance
plummets, as a result of many nodes simultaneously trying to access the
same thing.

There are various workarounds to avoid this problem.  For example, many
clusters (such as Cplant, at Sandia National Lab) use special software
to replicate an executable across the active set of nodes before running
it.  There are several shared filesystems, which allow multiple servers
to access the same shared disks, and simultaneously serve the same files
and filesystems to multiple servers.  Typically, these have very good
performance, but less stability than is required in a production
environment.

A variant of a cluster filesystem is ENFS, which is also used at
Sandia.  The old user-space nfs daemon from Linux has been modified to
be used as a forwarder.  For every 32 (or so) compute nodes, there is a
leader node.  The compute nodes NFS-mount filesystems from the leader
nodes.  The leader nodes nfs-mount filesystems from servers, and then
use the nfs daemon to re-export them to the compute nodes.  This system
actually works quite well.  A 1500-node system is booted diskless, from
a single admin node, in just a few minutes (I don't recall the exact
speed, but I believe it's in the 5-20 minute range).

ENFS has some weaknesses.  First, it does not support NFS-V4 or -V4, so
it is limited to files of no more than 2GB.  Second, it has never been
productized and released.  I would *love* to see the kernel NFS
implementation able to provide the same sort of forwarding.  Last
summer, I tested the kernel as a forwarder.  With the filesystem ID
patch, I thought that it would be possible.  Unfortunately, although it
was able to forward filesystems enough for a few listings to succeed, it
soon hung.  Perhaps a newer version would actually work, but I don't
believe that this has been a priority for any of the developers.

There are many other "solutions", GFS, CVFS, PVS, etc., each with its
own issues.  There are some characteristics that I believe any real
solution will have, most of which are shared by the existing
"solutions".

1) There must be a single image available to all the compute nodes. 
This means thousands of nodes, not just 10s of nodes.  This may be
achievable, though, by a combination of methods.  One example may be a
shared filesystem, mounted by 10s of nodes, which is then NFS-exported
to the rest of the nodes.

2)  There must be a fan-out effect.  That is, in order to be scalable,
the same file/filesystem must be able to be cached on multiple servers. 
Ideally, a hierarchy of servers should be possible.  That is, a leader
may cache for 32 sub-leaders, each of which cache for 32 compute nodes. 
32 is an arbitrary number - replace it with your favorite.

3) It must be stable.

4) It must provide high performance.  Ideally, an individual node in a
high performance cluster should be able to read or write 100MB/sec at
least.

5) It should be able to function over a variety of networks, including,
for example, Ethernet, Myrinet, and Quadrics.

6) It should not have a single point of failure.  Many shared
filesystems, for example, depend on a singe metadata server.

7) It must support the full normal filesystem semantics.  PVFS, for
example, meets most of these requirements, but doesn't support symbolic
links.

There are probably other requirements, too, but these are the
requirements that immediately come to mind.  Unfortunately, I don't know
of a solution that meets all of these.  Is there one?

Thanks,

dbr

On Thu, 2003-01-09 at 14:39, Lorn Kay wrote:
> Is NFS a viable CFS? (I'm cross posting this due to a discussion on the the 
> linux-ha list recently.)

-- 
David B. Ritch
High Performance Technologies, Inc.


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
