From: "Bowman, John" <John.Bowman@Williams.com>
Subject: Strange sporadic delay with NFS
Date: Fri, 26 Sep 2003 15:39:02 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CC7E9749B61C8346B1D0AF308E5D40A61845F7@wmstutem02.williams.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2zQ4-0003Ak-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 13:42:28 -0700
Received: from securit-v1.twc.com ([151.142.239.11] helo=wmstutem02.WILLIAMS.COM)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2zQ2-0001nK-UI
	for nfs@lists.sourceforge.net; Fri, 26 Sep 2003 13:42:27 -0700
To: <nfs@lists.sourceforge.net>
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


Greetings!

	I'm noticing a weird issue with my application (Matlab) and nfs.
I'm currently running nfs-utils-1.0.1-2.9 on a Red Hat 9 with kernel
2.4.20 kernel.  What I'm trying to determine if this is strictly an
application issue or something with nfs itself (either version or
patch).

	Here's the basic details.  I have a server exporting a directory
with *(rw) in /etc/exports and and filesystem mounted with
noatime,nodiratime.  The clients mount that directory with
noatime,nodiratime.  Client1 runs the application and writes a file to
the nfs share, Client2 polls that directory by doing a test to see if
that file is there and if it is update it while Client1 checks it and if
its updated deletes it.

	This whole thing normally takes a matter of seconds but at
irregular intervals Client2 will never see that the new file is there
and it will time out, BUT it may never time out if there is any kind of
activity on that nfs mount such as doing a while loop and ls -la.

	Has anyone seen this or is this just something that is most
likely specific to the application?


Thanks for any help!
John Bowman


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
