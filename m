From: "Patrice Seyed" <apseyed@bu.edu>
Subject: RE: ReasmFails increases / NFS performance on Linux Cluster
Date: Sun, 15 Aug 2004 17:52:13 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <003701c48312$1f61a740$6701a8c0@psyche1>
References: <20040814092339.GB28329@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: "'Patrice Seyed'" <apseyed@bu.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BwSvL-0002r9-Sm
	for nfs@lists.sourceforge.net; Sun, 15 Aug 2004 14:52:19 -0700
Received: from acsn03.bu.edu ([128.197.159.63])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BwSvL-0002Dw-Dk
	for nfs@lists.sourceforge.net; Sun, 15 Aug 2004 14:52:19 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <20040814092339.GB28329@suse.de>
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

Thanks Olaf, when I tried nfs over tcp on the clients the ReasmFails =
value
increased much significantly slower. At this time of testing the value =
is
not increasing at all.

Still, slowness on logging in (or running ls on that mount) continues, =
which
is not good since many users will be logging into the headnode during
production.

In addition, I have enabled jumbo packets on the cisco, and set all =
nodes on
the cluster network to mtu 9000. Also I have set read and write size to =
32k
as a document suggested with tcp and mtu at 9000 for better thoroughput.
Still I see the slowness when logging in.

 I am not sure if there is now any performance improvement as I am not
currently using any intelligent benchmark or mbit/sec analysis. Any
recommendation on doing these measurements and benchmarking is =
appreciated
greatly. Also I think I should consider the setup and the feasibility of
putting this type of load on this cluster (I/O intensive usually calls =
for
pvfs or multiple nfs servers, or both). E.g. one of my tests uses dd to
write 256mb files to nfs from 28 nodes at once (all going to the storage
node), and also running 2 jobs from each node (134 total node) that use =
dd
to write 4MB files and also run nbench. I.e. Should an nfs server be =
able to
handle this amount of load anyway?

Like I said I'm now running 64 nfs daemons, and the th line looks like =
this
now:

th 64 2380739 168.120 128.860 68.350 261.730 184.990 121.680 145.930 =
122.090
178.390 1749.090


Thanks Olaf for your suggestions on tcp and jumbo packets. Now I'm =
wondering
what I can use to determine if actually speed performance was improved, =
and
if the "bottleneck" I'm seeing now should be expected for my setup. Any
comments, further suggestions, appreciated.

Cheers,
-Patrice

-----Original Message-----
From: Olaf Kirch [mailto:okir@suse.de]=20
Sent: Saturday, August 14, 2004 5:24 AM
To: Patrice Seyed
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] ReasmFails increases / NFS performance on Linux =
Cluster

On Sat, Aug 14, 2004 at 03:46:44AM -0400, Patrice Seyed wrote:
> I welcome any suggestions or recommendations.

Try using NFS over TCP, or, if all your NICs support it, use jumbograms
to avoid fragmentation.

Olaf
--=20
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+=20



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
