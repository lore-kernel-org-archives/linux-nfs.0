From: Philippe Troin <phil@fifi.org>
Subject: silly-deleting symlinks?
Date: 24 Mar 2002 13:56:55 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87hen5wrx4.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from tantale.fifi.org ([216.27.190.146])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16pFz3-0006Se-00
	for <nfs@lists.sourceforge.net>; Sun, 24 Mar 2002 13:57:01 -0800
Received: from ceramic.fifi.org (root@ceramic.fifi.org [216.27.190.147])
	by tantale.fifi.org (8.9.3/8.9.3/Debian 8.9.3-21) with ESMTP id NAA31268
	for <nfs@lists.sourceforge.net>; Sun, 24 Mar 2002 13:56:58 -0800
Received: from ceramic.fifi.org (phil@localhost [127.0.0.1])
	by ceramic.fifi.org (8.12.1/8.12.1/Debian -5) with ESMTP id g2OLuvti005697
	for <nfs@lists.sourceforge.net>; Sun, 24 Mar 2002 13:56:57 -0800
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

I've just noticed that nfsd tries to silly-delete symlinks.

Server: vanilla 2.2.20 SMP
Client: vanilla 2.4.18 SMP
Mount options: rw,nodev,v2,rsize=8192,wsize=8192,hard,intr,udp,lock

Sometimes I see some .nfs<XXXX> files which are symlinks. How can
symlinks be "in use" and be subject to silly-deletion?

Phil.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
