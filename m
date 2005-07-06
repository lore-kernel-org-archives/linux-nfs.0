From: Anthony Howe <ahowe_ca@yahoo.ca>
Subject: RE: slow file opens on nfs mount across high-latency network
Date: Wed, 06 Jul 2005 12:16:34 -0700
Message-ID: <000301c5825f$39f92360$7101a8c0@orthanc>
References: <42C2950C.2070705@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DqFOC-0005R0-7t
	for nfs@lists.sourceforge.net; Wed, 06 Jul 2005 12:16:56 -0700
Received: from shawidc-mo1.cg.shawcable.net ([24.71.223.10] helo=pd4mo3so.prod.shaw.ca)
	by sc8-sf-mx1-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DqFOB-0004AY-Qb
	for nfs@lists.sourceforge.net; Wed, 06 Jul 2005 12:16:56 -0700
Received: from pd2mr8so.prod.shaw.ca (pd2mr8so-qfe3.prod.shaw.ca [10.0.141.11])
 by l-daemon (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar 15 2004))
 with ESMTP id <0IJ8006RZ07PUQ00@l-daemon> for nfs@lists.sourceforge.net; Wed,
 06 Jul 2005 13:16:37 -0600 (MDT)
Received: from pn2ml2so.prod.shaw.ca ([10.0.121.146])
 by pd2mr8so.prod.shaw.ca (Sun ONE Messaging Server 6.0 HotFix 1.01 (built Mar
 15 2004)) with ESMTP id <0IJ800LBO07PRH50@pd2mr8so.prod.shaw.ca> for
 nfs@lists.sourceforge.net; Wed, 06 Jul 2005 13:16:37 -0600 (MDT)
Received: from orthanc (S010600055dfdd2ca.gv.shawcable.net [24.69.124.240])
 by l-daemon (iPlanet Messaging Server 5.2 HotFix 1.18 (built Jul 28 2003))
 with ESMTP id <0IJ8000Z007OJP@l-daemon> for nfs@lists.sourceforge.net; Wed,
 06 Jul 2005 13:16:37 -0600 (MDT)
In-reply-to: <42C2950C.2070705@redhat.com>
To: nfs@lists.sourceforge.net
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

> Neil Horman wrote:
>=20
> >On Tue, Jun 28, 2005 at 11:30:17AM -0400, Anthony Howe wrote:
> > =20
> >
> >>I have searched through the mail lists and google and
> >>have not found material describing the nfs file open=20
> threshold effect=20
> >>that I am experiencing.
> >>
> >>I have been experimenting with opening files on NFS
> >>mounts over varying network latencies.  I notice that
> >>there seems to be a threshold on the number of
> >>concurrent nfs file opens as network latency
> >>increases.  Up to and including the threshold, nfs
> >>file open performance is fine.  After the threshold of concurrent=20
> >>opens, performance degrades at a linear rate.
> >>
> >>For example, the graph in the attached files shows
> >>this threshold effect for various network latencies:
> >>- 0ms network latency - no max limit
> >>- 20ms network latency - 40 maximum concurrent opens
> >>- 40ms network latency - 20 maximum concurrent opens
> >>- 80ms network latency - 15 maximum concurrent opens
> >>- 120ms network latency - 5 maximum concurrent opens
> >>
> >>What would cause this "hockey stick" threshold effect
> >>shown in the attached file?
> >>Are there any settings that would change this effect?
> >>
> >>Here are the stats of my experiment:
> >>- testing using Redhat Enterprise AS servers V3
> >>connected via a 100Mbps switch
> >>- inserting latency with nist net
> >>- experiment process spawns X number of threads set to
> >>each open a file on an NFS mount, the time taken for
> >>each file open is recorded
> >>- adjusting rsize, wsize does not affect "hockey
> >>stick" threshold effect
> >>- adjusting /proc/sys/net/core/rmem* does not affect
> >>"hockey stick" threshold effect
> >>- adjusting number of nfsd processes does not affect
> >>"hockey stick" threshold effect
> >>
> >>Thanks in advance for any tips or directions where I
> >>can look for more information on this topic.
> >>
> >>Regards,
> >>
> >>Anthony Howe
> >>
> >>__________________________________________________
> >>Do You Yahoo!?
> >>Tired of spam?  Yahoo! Mail has the best spam protection around
> >>http://mail.yahoo.com=20
> >>   =20
> >>
> >
> >
> >do you have tcpdumps taken at all these data points?  It=20
> kind of sounds=20
> >to me like your getting a geared slowdown from additional congestion=20
> >caused by rpc retransmits (i.e., on a high latency link,=20
> you'll wind up=20
> >with more rpc retransmits, resulting in more congestion,=20
> resulting in=20
> >more lost packets, resulting in more retransmits, etc.).
> >
> Some questions --
>=20
> These are mounts done using the NFSv3 protocol?  Over TCP or over UDP?
>=20
> Each thread is opening an independent file?  In independent=20
> directories or in a common directory?
>=20
>     Thanx...
>=20
>        ps
>=20

I have found a solution (work around) to the latency problem that I
described in the above posting.  The solution seems to be to add more =
mounts
to the same nfs share and spread the threads evenly among the mounts. =20

This solution is highlighted by the graph:
http://ahowe_ca.tripod.com/nfsperformance2.pdf.  The graph shows the
performance of 40 threads each performing file opens across an nfs =
share.
Each thread repeats 10 times opening a file for write and closing it 10
times.  The x-axis is various roundtrip network latencies.  The y-axis =
is
the mean time to open a file across the nfs mount.  Each line represents =
a
different number of mount points.  The top line is one mount point, and =
40
threads concurrently calling file opens on this mount.  The bottom line
represents 40 mounts to the same share, each thread with its own line.  =
From
this graph I can come to the following conclusions:

1. Evenly distributing file access threads across many NFS mounts to the
same share reduces the effects of latency.

2. There seems to be resource limit per mount point.  The higher the =
network
latency the faster this limit is reached.  This explains the hockey =
stick
effect shown in graph: http://ahowe_ca.tripod.com/nfsperformance.pdf.

3. This resource limit is not related to the hard limit of 256 read or =
write
operations per mount point since we are only using 40 threads.

4. Removing all network latency eliminates this resource problem and 1 =
mount
or 40 mounts display the same performance.

Does anyone know what would be causing this resource limit? And is there =
any
way to improve it so that I don't have to add more mounts to reduce the
effects of latency?

Anthony





-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
