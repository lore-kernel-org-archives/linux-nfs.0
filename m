From: William Lee Irwin III <wli@holomorphy.com>
Subject: performance much improved
Date: Sat, 6 Apr 2002 23:29:45 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020407072945.GN30807@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from holomorphy.com ([66.224.33.161] helo=holomorphy)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16u77w-0001pJ-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Apr 2002 23:30:16 -0800
Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 16u77R-0004ss-00
	for <nfs@lists.sourceforge.net>; Sat, 06 Apr 2002 23:29:45 -0800
To: nfs@lists.sourceforge.net
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

Earlier in the 2.4.x series I noted a strange anomaly:

NetBSD nfsroot clients were able to drive up the load on a 2.4.x NFS
server to 10 or 20. This was doubly surprising as the clients were
machines of far lesser power than the NFS server (e.g. sun3/60 vs. a
600MHz Athlon running Linux ~2.4.8).

A pleasant surprise occurred today while doing make build simultaneously
on all 3 of my NetBSD toasters (sun3/60, ss1, and decstation 5000/200):

The load average on my main machine (the NFS server, 2.4.18-pre7-ac3)
remained quite low, and the machine quite responsive.

I confess I haven't been following the developments closely, but I can
say thank you, and congratulations on the performance improvement.


Cheers,
Bill

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
