From: Anders Andersson <molntapp@yahoo.se>
Subject: NFS server restarted, clients hang forever. Why?
Date: Mon, 4 Apr 2005 21:51:56 +0200 (CEST)
Message-ID: <20050404195156.31610.qmail@web25607.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIXcC-0005eH-B9
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 12:52:04 -0700
Received: from web25607.mail.ukl.yahoo.com ([217.12.10.166])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DIXcA-0002W2-Kn
	for nfs@lists.sourceforge.net; Mon, 04 Apr 2005 12:52:04 -0700
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

Hi all,

Recently nfsd was stopped on one of our servers due to
some maintenance issues on the underlying filesystem.
The clients hung, wating for it to come back. But when
nfsd et al. (portmapper, statd etc.) was back up
again, the clients never recovered. In fact, nothing
we could do would let us recover. Eventually, we
resorted to reboot -f on some 100 clients.

I'd greatly appreciate any input on

- why non-recoverable NFS client hangs happens
- how to avoid them, even if the server reboots

I'm under the belief that when NFS clients hang, they
wait for their server and resumes operation when it is
back. Or am I wrong about that?

The server is running RedHat 8.0 with its included
kernel 2.4.20. The clients are also running RedHat 8.0
but with kernel 2.4.26 from kernel.org (compiled
locally). No mount options. No updates to nfs-utils.

Kindly yours,
Anders Andersson
molntapp@yahoo.se


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=3D6595&alloc_id=3D14396&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
