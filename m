From: Dumas Patrice <dumas@centre-cired.fr>
Subject: standard and lockd
Date: Wed, 10 Apr 2002 16:50:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020410165023.D23279@zeus.centre-cired.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16vJUL-0001x0-00
	for <nfs@lists.sourceforge.net>; Wed, 10 Apr 2002 07:54:21 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id QAA07729
          for <nfs@lists.sourceforge.net>; Wed, 10 Apr 2002 16:53:14 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g3AEoNi23520
	for nfs@lists.sourceforge.net; Wed, 10 Apr 2002 16:50:23 +0200
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
If the standard for lockd is described in
http://www.opengroup.org/onlinepubs/009629799/chap9.htm#tagcjh_10,
then the linux lockd breaks the standard in numerous parts, mainly

- the protocole structures aren't the same (because on linux the structure used
is file_lock)

- lockd doesn't responds with the right message type for granted locks (more
precisely it uses a GRANTED_MSG in cases it should use GRANTED).

I have no problem with breaking the standard per se, and I fully understand the
reasons behind that, however it seems to me that it should lead to
interoperability issues. Does it ? According to the nfs howto (but it is an old
one there isn't such issues. Does it means that other nfs implementation also
use the file_lock structure ?

Pat

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
