From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: lustre + userspace nfs?
Date: Tue, 05 Oct 2004 09:20:43 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1096993243.4460.723.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CEs4E-0005IW-GP
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 09:21:34 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CEs3U-0007Oj-Ke
	for nfs@lists.sourceforge.net; Tue, 05 Oct 2004 09:21:34 -0700
To: nfs@lists.sourceforge.net
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


Is this an appropriate mailing list for discussion of the linux
userspace NFS implementation?

We've been trying to serve out, over NFS, a 30 terrabyte Lustre
filesystem.

Lustre and NFS (at least, the in-kernel implementation of NFS) have not
been playing nicely together.  The Lustre vendor, ClusterFS, indicates
that their app is sturdy with userspace applications, and that it's just
because NFS is in-kernel that we're having troubles.

I'm wondering if using the userspace NFS implementation might get us
around these problems, and if so, would it be stable, and would it be
appreciably slower?

Thanks.

-- 
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
