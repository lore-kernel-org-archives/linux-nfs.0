From: OMestre <omestre@freeshell.org>
Subject: mknbi-linux
Date: 12 Jun 2002 17:48:26 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <ae8c5l$jbf$2@main.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: debian-user@lists.debian.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from omega.procergs.com.br ([200.198.128.38])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17IF2p-0002vT-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Jun 2002 13:48:43 -0700
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

  I'm trying mount one linux diskless machine.
  i'm receiving the error 101, then i want put some parameters in tagged
image cration.
  How can i put this nfs options for example (the nfs root are not
recognized)

nfsroot=10.124.66.21:/<rootfsdir>/,rsize=8192,wsize=8192, \
port=2049,mountport=1234,mountprog=100005,mountvers=3,nfsprog=100003, \
nfsvers=3,nolock,hard,intr,udp"

  Thanks
  
-- 
------------------------------------------------------------------------
FreeShell's master                           http://omestre.freeshel.org
------------------------------------------------------------------------


_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
