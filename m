From: petter.knutsen@cgi.no
Subject: File lock with multiple clients
Date: Fri, 21 Oct 2005 01:01:40 +0200
Message-ID: <E1ESjPp-0004BW-Qv@mail.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ESjPr-0008JJ-ON
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 16:01:43 -0700
Received: from mail09.webhuset.no ([81.27.32.116] helo=mx.webhuset.no)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ESjPp-0004BW-Qv
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 16:01:43 -0700
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

Hello,

I have a question about NFS and file locking on multiple clients.

Let's say I have a NFS server and two clients; "client a" and "client b". Is
it possible to flock() a file on "client a", and make "client b" respect a's
lock?

I've managed to lock files on "client a" and let other processes on "client
a" honour the locks, but "client b" doesn't seem to be able to see the lock=
s.


Before I research any further, does anyone know if this is possible?

Thanks in advance,

Petter=


-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
