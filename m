From: Hirotaka Sasaki <sasaki@valinux.co.jp>
Subject: Linux NFS client hangs when it read a large file
Date: Fri, 19 Apr 2002 20:12:05 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020419111618.19A3770023@sv1.valinux.co.jp>
Mime-Version: 1.0
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16yWNK-0005h0-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Apr 2002 04:16:22 -0700
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
I'm having trouble with the Linux NFS client.

NFS Server is Redhat 7.2 with Linux-2.4.17+XFS-1.0.2.
NFS Client is Redhat 7.2 with Linux-2.4.17.

On the NFS Server, I'm exporting a XFS file system under
an arbitrary directory name.

Next, I mount that file system using the NFS client via
NFSv3/UDP.

For Linux 2.4, the maximum accessible file offset of XFS 
is 16TB(0xffffffff000) on 4K page size.

I can read a file with an offset of 0xfffffff8000,
but the client hangs when I read a file with an offset of 
0xfffffff9000 from the server on the client.

SunOS(5.8) NFS client can read it.

Regards,
Hirotaka Sasaki
--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
