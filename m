From: Anthony Howe <ahowe_ca@yahoo.ca>
Subject: RE: slow file opens on nfs mount across high-latency network
Date: Tue, 28 Jun 2005 12:53:30 -0400 (EDT)
Message-ID: <20050628165330.44157.qmail@web21323.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DnJL4-0004LM-2p
	for nfs@lists.sourceforge.net; Tue, 28 Jun 2005 09:53:34 -0700
Received: from web21323.mail.yahoo.com ([216.136.175.209])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DnJL2-0002Zp-JS
	for nfs@lists.sourceforge.net; Tue, 28 Jun 2005 09:53:33 -0700
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

I probably should have provided this link to the pdf
document instead of the attachment:

http://ahowe_ca.tripod.com/nfsperformance.pdf

This graph show the hockey stick effect that I
described in the below post.

Anthony

> I have searched through the mail lists and google
and
> have not found material describing the nfs file open
> threshold effect that I am experiencing. =20
>
> I have been experimenting with opening files on NFS
> mounts over varying network latencies.  I notice
that
> there seems to be a threshold on the number of
> concurrent nfs file opens as network latency
> increases.  Up to and including the threshold, nfs
> file open performance is fine.  After the threshold
of
> concurrent opens, performance degrades at a linear
> rate.
>=20
> For example, the graph in the attached files shows
> this threshold effect for various network latencies:
> - 0ms network latency - no max limit
> - 20ms network latency - 40 maximum concurrent opens
> - 40ms network latency - 20 maximum concurrent opens
> - 80ms network latency - 15 maximum concurrent opens
> - 120ms network latency - 5 maximum concurrent opens
>=20
> What would cause this "hockey stick" threshold
effect
> shown in the attached file?
> Are there any settings that would change this
effect?
>=20
> Here are the stats of my experiment:
> - testing using Redhat Enterprise AS servers V3
> connected via a 100Mbps switch
> - inserting latency with nist net
> - experiment process spawns X number of threads set
to
> each open a file on an NFS mount, the time taken for
> each file open is recorded
> - adjusting rsize, wsize does not affect "hockey
> stick" threshold effect
> - adjusting /proc/sys/net/core/rmem* does not affect
> "hockey stick" threshold effect
> - adjusting number of nfsd processes does not affect

> "hockey stick" threshold effect
>=20
> Thanks in advance for any tips or directions where I
> can look for more information on this topic.
>=20
> Regards,
>=20
> Anthony Howe

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
