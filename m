From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Re: Slow performance with 2.4.19pre1
Date: Thu, 4 Jul 2002 16:25:43 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0207041624120.30131-100000@xpc1.ast.cam.ac.uk>
References: <Pine.LNX.4.44.0207021355580.22749-100000@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from maroon.csi.cam.ac.uk ([131.111.8.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Q8UP-0006YC-00
	for <nfs@lists.sourceforge.net>; Thu, 04 Jul 2002 08:25:49 -0700
Received: from cass41.ast.cam.ac.uk ([131.111.69.186])
	by maroon.csi.cam.ac.uk with esmtp (Exim 4.05)
	id 17Q8UJ-0003XU-00
	for nfs@lists.sourceforge.net; Thu, 04 Jul 2002 16:25:43 +0100
Received: from xalph6.ast.cam.ac.uk (xalph6 [131.111.68.34])
	by cass41.ast.cam.ac.uk (8.11.6+Sun/8.11.6) with ESMTP id g64FPh204717
	for <nfs@lists.sourceforge.net>; Thu, 4 Jul 2002 16:25:43 +0100 (BST)
Received: from xpc1.ast.cam.ac.uk (IDENT:4sCONcn0CMHOAfvM4swrH/9JlZQPo+DP@xpc1.ast.cam.ac.uk [131.111.68.219])
	by xalph6.ast.cam.ac.uk (8.10.0/8.10.0) with ESMTP id g64FPhp05061
	for <nfs@lists.sourceforge.net>; Thu, 4 Jul 2002 16:25:43 +0100 (BST)
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.LNX.4.44.0207021355580.22749-100000@xpc1.ast.cam.ac.uk>
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

Sorry - I know it's bad form to reply to one's own emails. It seems that
the stock 2.4.19rc1 kernel doesn't have the problem as a client, and so
it's the RedHat patched 2.4.18 kernel which is a very slow client. This
looks like a RedHat bug.

Also the title of this mail is rather confusing!

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Caffeinated soap. No kidding.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
