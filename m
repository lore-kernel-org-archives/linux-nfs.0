From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: nfsd patches for 2.6.23
Date: Wed,  5 Sep 2007 17:22:11 -0400
Message-ID: <1189027333981-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IT2KF-0005yd-6Q
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 14:22:15 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IT2KF-0003GC-TQ
	for nfs@lists.sourceforge.net; Wed, 05 Sep 2007 14:22:17 -0700
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

We've got two nfsd patches that fix a regression and a possible oops, so
both should probably go in before the 2.6.23 release.

Patches will follow, but they're also available from "for-linus" at:

  ssh://linux-nfs.org/~bfields/exports/linux.git for-linus

--b.

Neil Brown (2):
      knfsd: Fixed problem with NFS exporting directories which are mounted on.
      knfsd: Validate filehandle type in fsid_source

 fs/nfsd/nfsfh.c |   20 +++++++++++++++-----
 fs/nfsd/vfs.c   |    3 ++-
 2 files changed, 17 insertions(+), 6 deletions(-)

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
