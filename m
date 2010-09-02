Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36666 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757949Ab0IBVNn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Sep 2010 17:13:43 -0400
Received: from bfields by fieldses.org with local (Exim 4.71)
	(envelope-from <bfields@fieldses.org>)
	id 1OrH5r-00007n-88
	for linux-nfs@vger.kernel.org; Thu, 02 Sep 2010 17:13:11 -0400
Date: Thu, 2 Sep 2010 17:13:11 -0400
To: linux-nfs@vger.kernel.org
Subject: 2.6.36 access-bits bugfix
Message-ID: <20100902211311.GF24608@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I intend to pass this along to Linus as a 2.6.36 bugfix.

This is one of several bugs that have been due to ignoring the existance
of higher bits in the access mask.  I wonder what we could change to
eliminate the whole class of problems?  Maybe store these bits into
separate fields right away in the xdr decoding?

--b.

commit 8f34a430ac16d5fbd9d6b383184d35e152f5a963
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Sep 2 15:23:16 2010 -0400

    nfsd4: mask out non-access bits in nfs4_access_to_omode
    
    This fixes an unnecessary BUG().
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3dfef06..cf0d2ff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -440,7 +440,7 @@ test_share(struct nfs4_stateid *stp, struct nfsd4_open *open) {
 
 static int nfs4_access_to_omode(u32 access)
 {
-	switch (access) {
+	switch (access & NFS4_SHARE_ACCESS_BOTH) {
 	case NFS4_SHARE_ACCESS_READ:
 		return O_RDONLY;
 	case NFS4_SHARE_ACCESS_WRITE:
