From: Carlos Carvalho <carlos@fisica.ufpr.br>
Subject: excessive nfsd cpu consumption - almost a DOS...
Date: Sun, 28 Sep 2003 17:45:50 -0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16247.18558.175684.189042@fisica.ufpr.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A3jN1-00082n-00
	for <nfs@lists.sourceforge.net>; Sun, 28 Sep 2003 14:46:23 -0700
Received: from www.fisica.ufpr.br ([200.17.209.129] helo=fisica.ufpr.br)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A3jMy-0006qP-FI
	for nfs@lists.sourceforge.net; Sun, 28 Sep 2003 14:46:20 -0700
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

A user here did something like

    <start loop>
       open file (on the nfs server)
       write something small
       close file
    <end loop>

This made the 8 threads of nfsd eat almost all cpu on the server. I
changed the nice of the threads to 19 and this improved matters
somewhat but not enough.

Is there a way to limit nfsd cpu?


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
