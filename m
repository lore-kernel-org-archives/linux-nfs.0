From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: RedHat Rawhide Kernels
Date: Thu, 8 Aug 2002 20:21:27 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208082017590.23326-100000@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from maroon.csi.cam.ac.uk ([131.111.8.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17csqh-0005OR-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 12:21:31 -0700
Received: from cass41.ast.cam.ac.uk ([131.111.69.186])
	by maroon.csi.cam.ac.uk with esmtp (Exim 4.10)
	id 17csqe-000075-00
	for nfs@lists.sourceforge.net; Thu, 08 Aug 2002 20:21:28 +0100
Received: from xalph6.ast.cam.ac.uk (xalph6 [131.111.68.34])
	by cass41.ast.cam.ac.uk (8.11.6+Sun/8.11.6) with ESMTP id g78JLS224726
	for <nfs@lists.sourceforge.net>; Thu, 8 Aug 2002 20:21:28 +0100 (BST)
Received: from xpc1.ast.cam.ac.uk (IDENT:/SSmzlwt8ocl/yCyKIo7JhSMJx0KSG+S@xpc1.ast.cam.ac.uk [131.111.68.219])
	by xalph6.ast.cam.ac.uk (8.10.0/8.10.0) with ESMTP id g78JLRp04556
	for <nfs@lists.sourceforge.net>; Thu, 8 Aug 2002 20:21:27 +0100 (BST)
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

Just to let you guys know (as it's close to the current thread), I'm
getting very bad lock-ups using the current rawhide kernel (2.4.18-7.94).
When I connet with a machine running 2.4.18-5 (standard 7.3 errata
kernel), both the client and the server get processes stuck in a "D" state
- the nfsd processes on the server and the user command on the client.
This means you can't shut the server down as the nfsd processes can't get
killed. Strangely 2.4.19 kernels can talk to the server fine!

See
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=70561

I'm going to try a stack trace on the nfsd processes as the RH guys
suggested tomorrow.

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
