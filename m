From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: 3 bugs with UDP mounts
Date: Tue, 23 Apr 2002 07:55:32 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50CEBF@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1701hq-00072e-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 07:55:46 -0700
To: "'Andrew Ryan'" <andrewr@nam-shub.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

> > > 1. UDP read performance (v2 and v3) on large files is really
> > > poor. [....]
> > > I can get excellent read performance, as long as the files
> > > are relatively small.
> >
> >you are probably hitting the network speed step down between
> >the GbE filer and the 100Mb client.  the first packet loss
> >will cause your read throughput to drop.  i'll bet your
> >small file knee occurs right about at the size of your switch's
> >memory buffer.
> 
> I'm not seeing any packet loss on client or server acc. to interface 
> statistics. How would I find this out?

the interface statistics reflect errors right at the client's NIC.
the switch may also drop packets, for example, to match link speed,
because it has exhausted buffer space, because of QOS or packet
scheduling, and so on.  IOW the client can get a packet to the switch
perfectly (so no Tx error occurs) but the switch may drop the packet
before getting it to the server.  and also in the reverse direction.

the client may also lose replies because of lack of socket buffer space.
packets are received perfectly (thus no Rx error occurs) but the
driver/network layer fails to copy the data to the RPC layer because
there is not enough socket buffer space.  the network layer drops
the packet.

take a look at "nfsstat -c" -- there's a retransmission number
at the top that indicates how often the client was not able to
get a request to the server (and a reply from the server) the first
time.  you can also look at "netstat -s" to see if there are
reassembly failures (see other thread: "nfs performance: read
only/gigE/nolock/1Tb per day").

> >have you tried this test with TCP?
> 
> Yeah, TCP performance is fine. It's the hangs under 2.4.17+NFS-ALL 
> (described in an earlier mail) that are killing me. The hangs 
> seem to have 
> gone away in 2.4.19pre7+NFS-ALL, but I need more time to test all of 
> 2.4.19pre7 in my environment to make sure it holds up OK.

that's good news.

> Would it be possible -- via a kernel option or mount option 
> -- to control 
> the behavior in the Linux client as well so that high 
> performance can be 
> achieved on a Linux NFS client with high block sizes and UDP? Mixed 
> 100/1000 networks are becoming more of a reality and NFS/TCP, 
> while having 
> gotten tremendously better in the last year or so, is still a work in 
> progress, and it's nice to have another acceptable option for 
> mounting.

my 2 cents:

IMHO the right answer is to get TCP fixed properly as soon as possible.
UDP is always subject to the quality of your network, and thus is
a greater risk to data integrity.  also, the application and O/S on
the client should have some ability to control the flow of network
data, even on single speed networks -- UDP doesn't provide that.
though TCP has greater network and CPU overhead, it is a better choice
if NFS is to be taken seriously as a robust enterprise-quality file
system.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
