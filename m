From: Beschorner Daniel <Daniel.Beschorner@facton.com>
Subject: Can't callback server
Date: Fri, 8 Apr 2005 17:36:34 +0200
Message-ID: <BB1F4EFD574E9F409035BDA71C961250023B38@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJvWv-0005Ud-AD
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 08:36:21 -0700
Received: from loewe.unit-netz.de ([212.202.148.42])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DJvWt-00008o-Jj
	for nfs@lists.sourceforge.net; Fri, 08 Apr 2005 08:36:21 -0700
Received: from exchange.i-bn (exchange.catsgroup [192.168.100.120])
	by loewe.unit-netz.de (8.12.3/8.12.3/Unit) with ESMTP id j38FaBPE015041
	for <nfs@lists.sourceforge.net>; Fri, 8 Apr 2005 17:36:11 +0200
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

After some tests it seems to be 2.6.11 related (when clients reboot), with
2.6.10 the message doesn't appear.
Has anyone an idea?
Are there a any NFS patches from .10 to .11 causing this I can revert for
testing purposes?

Thank you
Daniel

Apr  8 03:05:46 server rpc.statd[3203]: recv_rply: [127.0.0.1] RPC status 1
Apr  8 03:06:04 server last message repeated 3 times
Apr  8 03:06:10 server rpc.statd[3203]: Can't callback server (100021,4),
giving up.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
