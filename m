From: Phil Garcia <apgarcia@gravity.phys.uwm.edu>
Subject: slow create/delete performance
Date: Wed, 29 Oct 2003 15:24:33 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031029152433.A1917@oppie.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AExnu-0002p9-00
	for <nfs@lists.sourceforge.net>; Wed, 29 Oct 2003 13:24:34 -0800
Received: from oppie.phys.uwm.edu ([129.89.57.60])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AExnu-0005tX-GY
	for nfs@lists.sourceforge.net; Wed, 29 Oct 2003 13:24:34 -0800
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

Hi,

We've been running some benchmarks on both local and nfs mounts.  The
read and write speeds are comparable, but creating and deleting small
files is much slower over nfs than it is locally.  Is there a patch to
fix this problem?


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
