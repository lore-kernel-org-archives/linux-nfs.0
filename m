From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: userspace NFS daemon
Date: Sun, 5 Sep 2004 23:09:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040905210902.GA29182@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C44G4-0004Mr-9i
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 14:09:08 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C44G2-0003VH-4u
	for nfs@lists.sourceforge.net; Sun, 05 Sep 2004 14:09:07 -0700
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
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

Isn't this one completely obsolete?

So maybe we could drop sys_setfsuid() and sys_setfsgid() if those calls
have no other use then for running unfsd as root?

-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
