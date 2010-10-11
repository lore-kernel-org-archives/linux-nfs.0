Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44840 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752387Ab0JKXby (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 19:31:54 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1P5RqT-0004xl-Ik
	for linux-nfs@vger.kernel.org; Mon, 11 Oct 2010 19:31:53 -0400
Date: Mon, 11 Oct 2010 19:31:53 -0400
To: linux-nfs@vger.kernel.org
Subject: expire clients more promptly
Message-ID: <20101011233153.GA16442@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm planning on queuing this up for 2.6.37.

Honestly, this is mainly just to make a few pynfs tests pass more
reliably, which isn't a good enough reason on its own.

But I also can't see any problem with letting the laundromat thread run
as much as once a second.

--b.

commit 76b409f70568ef011e476ce60eab6770572f4839
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Oct 11 16:49:44 2010 -0400

    nfsd4: expire clients more promptly
    
    Expire clients more promptly, at the expense of possibly running the
    laundromat thread more frequently.
    
    Though it's not the default, I'd like it to be feasible to run with a
    lease time of just a few seconds, at which point a minimum 10 second
    wait between laundromat runs seems a little much.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index b76ac3a..6b641cf 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -249,7 +249,7 @@ extern time_t nfsd4_grace;
 #define	COMPOUND_SLACK_SPACE		140    /* OP_GETFH */
 #define COMPOUND_ERR_SLACK_SPACE	12     /* OP_SETATTR */
 
-#define NFSD_LAUNDROMAT_MINTIMEOUT      10   /* seconds */
+#define NFSD_LAUNDROMAT_MINTIMEOUT      1   /* seconds */
 
 /*
  * The following attributes are currently not supported by the NFSv4 server:
