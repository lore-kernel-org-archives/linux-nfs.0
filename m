From: Sven Geggus <sven@gegg.us>
Subject: Performance tuning of diskless clients
Date: Fri, 31 Jan 2003 14:00:05 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <b1dvh5$n8p$1@benzin.geggus.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from benzin.geggus.net ([213.146.112.23] ident=foobar)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ebie-0006sY-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Jan 2003 06:00:37 -0800
Received: from news by benzin.geggus.net with local  (Exchange M$)
	id 18ebiA-0006CR-00
	for <nfs@lists.sourceforge.net>; Fri, 31 Jan 2003 15:00:06 +0100
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

Hi there,

I'm using a setup of a few dozen Diskless workstations.

The clients are connected using 100MBit switched Ethernet. The server is
connected to the backbone via Gigabit Ethernet.

Whe I do some tests of network trougoutput tests using dd the results are
quite good.

Using Gigabit Ethernet links instead of 100MBit I even get the expected
Performance enhancment by an Order of magnitude.

Anyway, comparing the startup times for Real World bloated^H^H^H^H^H^H^H
Applications like Openoffice. They are at least 3 times faster when started
on the local machine.

BTW, the NFS Directories I'm talking about are mostly mounted Readonly.

At the Moment Server and client are both running vanilla Kernel 2.4.20 on
Debian woody.

Sven

-- 
"and on the third day he rebooted into Linux-1.3.84"
                                (Linus Torvalds, Easter Kernel Release 1996)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
