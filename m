From: Juan Gomez <juang@us.ibm.com>
Subject: Disallowing unlock operations during the NFSv3 grace period
Date: Thu, 31 Oct 2002 09:46:33 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF9E97B7B9.73264A1D-ON87256C63.00610AF7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux-Kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e5.ny.us.ibm.com ([32.97.182.105])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 187JP0-0002De-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 09:46:42 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


I was wondering if any of the developers can explain why we disallow unlock
operations during the grace period of a NFSv3 server?
(fs/lockd/*)

I think we should allow unlock operations during the grace period and only
filter lock operations. This becomes specially important in
clustered NAS heads where some of the nodes may enter the grace period
during cluster recovery in addition to node reboots.

The side effect of rejecting unlock during the grace period in clustered
NAS heads is that unlocks are unfairly delayed when they happen
to hit the NAS head cluster nodes when they are recovering from a node
failure.


Juan



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
