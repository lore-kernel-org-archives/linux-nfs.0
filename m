From: James Pearson <james-p@moving-picture.com>
Subject: df and "Value too large for defined data type"
Date: Tue, 24 Feb 2004 13:27:08 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403B512C.66BF37BB@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvcbP-00037p-G4
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 05:27:59 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Avcaj-0007d5-B1
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 05:27:17 -0800
Received: from darke.mpc.local ([172.16.11.6] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.24)
	id 1Avcab-0006e5-1M
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 13:27:09 +0000
To: nfs@lists.sourceforge.net
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

Using a (vanilla) 2.6.3 NFS client and using df on a on a particular NFS
mounted file system gives:

df: `/mnt/tmp': Value too large for defined data type

/mnt/tmp is mounted from a server running 2.4.21 that has a 3.5TB RAID
split into 4 partitions of less than 1TB each. The file system on the
server is XFS.

/proc/mounts on the client shows:

lead:/disk1 /mnt/tmp nfs
rw,v3,rsize=8192,wsize=8192,hard,udp,lock,addr=lead 0 0

When I use NFSv2, df (or actually statfs()) works as expected - as do
mounts to other NFS servers (it appears to be just this one server).

Also, clients running 2.4.X, have no problems with this server.

Any ideas?

James Pearson


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
