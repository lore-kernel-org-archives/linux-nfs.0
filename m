From: James Pearson <james-p@moving-picture.com>
Subject: Busy inodes after unmount followed by Oops
Date: Fri, 09 Jan 2004 11:06:16 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FFE8B28.1E645E4E@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AeuTB-0005v7-Tx
	for nfs@lists.sourceforge.net; Fri, 09 Jan 2004 03:06:25 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AeuTB-0005PI-FO
	for nfs@lists.sourceforge.net; Fri, 09 Jan 2004 03:06:25 -0800
To: nfs@lists.sourceforge.net, autofs@linux.kernel.org
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

There was a long thread a few months ago about this subject:

http://marc.theaimsgroup.com/?t=106332683300004&r=1&w=2

and

http://marc.theaimsgroup.com/?t=106340013500006&r=1&w=2

I've read the posts but as far as I can tell, I can't find a 'solution'
to the problem (but I may have missed it in all the posts!)

I have the same problem with a large number of dual CPU machines running
2.4.20 and above that make heavy use of autofs (v4.0.0pre10).

We get a:

VFS: Busy inodes after unmount. Self-destruct in 5 seconds.  Have a nice
day...

mesasage, followed some time later by Oops's from kswapd, umount or some
other user application.

Is there a 'fix' for this problem?

Thanks

James Pearson


-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
