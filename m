From: Dumas Patrice <dumas@centre-cired.fr>
Subject: error when insmod nfsd: unresolved symbol nfsd_linkage
Date: Fri, 12 Apr 2002 13:55:51 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020412135551.D26281@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vziX-0007iX-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Apr 2002 04:59:49 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id NAA03524
          for <nfs@lists.sourceforge.net>; Fri, 12 Apr 2002 13:58:52 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g3CBtpe26638
	for nfs@lists.sourceforge.net; Fri, 12 Apr 2002 13:55:51 +0200
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

Hi,
I have just compiled linux-2.4.18 with linux-2.4.18-NFS_ALL.dif applied. All
the nfs stuff was compiled as modules (without over TCP support). I made
some changes in lockd/svcproc.c, but I touched nothing anywhere else. I am on a
redhat 7.2, but the kernel is a normal kernel.

Now, when I try to insmod the nfsd module (after sunrpc and lockd), I get

./nfsd.o: unresolved symbol nfsd_linkage

gcc -v gives
Reading specs from /usr/lib/gcc-lib/i386-redhat-linux/2.96/specs
gcc version 2.96 20000731 (Red Hat Linux 7.1 2.96-98)


Pat

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
