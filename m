From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/5] 2.6.21-rc7 NFS writes: fix a series of issues
Date: Fri, 20 Apr 2007 16:03:58 -0400
Message-ID: <20070420200358.7897.75870.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, Florin Iucha <florin@iucha.net>,
	Adrian Bunk <bunk@stusta.de>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HezT4-0002nZ-Qj
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:30 -0700
Received: from dh166.citi.umich.edu ([141.211.133.166]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HezT5-0003wI-5n
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 13:12:33 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I've split the issues introduced by the 2.6.21-rcX write code up into 4
subproblems.

The first patch is just a cleanup in order to ease review.

Patch number 2 ensures that we never release the PG_writeback flag until
_after_ we've either discarded the unstable request altogether, or put it
on the nfs_inode's commit or dirty lists.

Patch number 3 fixes the 'desynchronized value of nfs_i.ncommit' error. It
uses the PG_NEED_COMMIT flag as an indicator for whether or not the request
may be redirtied.

Patch number 4 protects the NFS '.set_page_dirty' address_space operation
against races with nfs_inode_add_request.

Finally, patch number 5 fixes an issue with the RPC code that is supposed
ensure that NFSv4 disconnects before resending a request. The current code
will disconnect for every request it resends (and has a bunch of false
positive cases), instead of just ensuring that it disconnects once every
time a timeout or a garbage reply occurs.

My thanks to the various patient victim^Wpeople who helped with extensive
testing.

Cheers
  Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
