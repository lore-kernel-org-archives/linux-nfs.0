From: Beschorner Daniel <Daniel.Beschorner@facton.com>
Subject: Statd problem
Date: Tue, 29 Mar 2005 13:46:51 +0200
Message-ID: <BB1F4EFD574E9F409035BDA71C961250023B03@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DGFBG-0003TW-RR
	for nfs@lists.sourceforge.net; Tue, 29 Mar 2005 03:46:46 -0800
Received: from loewe.unit-netz.de ([212.202.148.42])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DGFBF-00056V-5K
	for nfs@lists.sourceforge.net; Tue, 29 Mar 2005 03:46:46 -0800
Received: from exchange.i-bn (exchange.catsgroup [192.168.100.120])
	by loewe.unit-netz.de (8.12.3/8.12.3/Unit) with ESMTP id j2TBkaVw006281
	for <nfs@lists.sourceforge.net>; Tue, 29 Mar 2005 13:46:36 +0200
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

Since the first reboot of our clients (mainly AIX) after we updated our NFS
server from 2.6.10 to 2.6.11 we get sporadically these server log entries, I
think after each client reboot:

Mar 29 12:44:31 server rpc.statd[3201]: recv_rply: [127.0.0.1] RPC status 1
Mar 29 12:44:49 server last message repeated 3 times
Mar 29 12:44:55 server rpc.statd[3201]: Can't callback server (100021,4),
giving up.

What do they mean? No further problems are seen.
Mounts are TCP/V3.

Thanks
Daniel


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
