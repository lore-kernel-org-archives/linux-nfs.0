From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Re: Unable to kill processes in D-state
Date: Sun, 6 Oct 2002 20:50:47 +0100 (BST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0210062045001.15836-100000@xpc1.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from plum.csi.cam.ac.uk ([131.111.8.3])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yHQR-0003OD-00
	for <nfs@lists.sourceforge.net>; Sun, 06 Oct 2002 12:50:51 -0700
To: nfs@lists.sourceforge.net,
   Thomas =?iso-8859-1?Q?Lang=E5s?= <tlan@stud.ntnu.no>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

This sounds a similar problem (well it has similar symptoms) to what we
had with RedHat's kernel for (null) and their rawhide kernel. I think this
turned out to be an ext3 interaction bug.

See https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=70561

(also try ctrl+scrolllock to get a trace of the nfsds on your system).
This will provide useful info over where it is stuck.

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
