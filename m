From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: specify a create mode with
 open(...O_CREAT) call in xflock
Date: Mon, 6 Aug 2007 15:15:48 -0400
Message-ID: <20070806151548.d3808295.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II83P-0005MK-H3
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 12:15:49 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1II83T-0003V7-3q
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 12:15:51 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l76JFocd012885
	for <nfs@lists.sourceforge.net>; Mon, 6 Aug 2007 15:15:50 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l76JFnXn008726
	for <nfs@lists.sourceforge.net>; Mon, 6 Aug 2007 15:15:49 -0400
Received: from tleilax.poochiereds.net (vpn-14-58.rdu.redhat.com [10.11.14.58])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l76JFm4Z025560
	for <nfs@lists.sourceforge.net>; Mon, 6 Aug 2007 15:15:49 -0400
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

The xflock function can create a file via open() with O_CREAT, but does
not specify the create mode when it does so. I think 0644 should be
appropriate given the current usage of this function.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/support/nfs/xio.c b/support/nfs/xio.c
index 221cce6..0453ca7 100644
--- a/support/nfs/xio.c
+++ b/support/nfs/xio.c
@@ -57,7 +57,7 @@ xflock(char *fname, char *type)
 	struct flock	fl = { readonly? F_RDLCK : F_WRLCK, SEEK_SET, 0, 0, 0 };
 	int		fd;
 
-	if ((fd = open(fname, readonly? O_RDONLY : (O_RDWR|O_CREAT))) < 0) {
+	if ((fd = open(fname, readonly? O_RDONLY : (O_RDWR|O_CREAT), 0644)) < 0) {
 		xlog(L_WARNING, "could not open %s for locking", fname);
 		return -1;
 	}

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
