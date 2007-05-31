From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: cluster-coherent leases
Date: Thu, 31 May 2007 17:40:21 -0400
Message-ID: <1180647624483-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Teigland <teigland@redhat.com>, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HtsOp-0000bE-EQ
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 14:41:39 -0700
Received: from pear.citi.umich.edu ([141.211.133.128])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HtsOr-00030d-A2
	for nfs@lists.sourceforge.net; Thu, 31 May 2007 14:41:42 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

NFSv4 uses leases to offer clients better caching.  Unfortunately that
doesn't work well on a cluster filesystem, since leases are acquired
only locally.

So, add the following patches add new lease and break methods, and a
simple lease implementation for GFS2 that just refuses to grant any
leases for now.

Opinions?

--b.



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
