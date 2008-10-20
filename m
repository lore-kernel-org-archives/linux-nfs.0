From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 3/4] nfsd: Fix leaked memory in nfs4_make_rec_clidname
Date: Mon, 20 Oct 2008 11:47:09 +0530
Message-ID: <20081020061709.18370.85373.sendpatchset@localhost.localdomain>
Cc: Krishna Kumar <krkumar2@in.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:59866 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751156AbYJTGRN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 02:17:13 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9K6HCrP023438
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 02:17:12 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9K6HCjO096544
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 02:17:12 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9K6HBUL029565
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 02:17:12 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

cksum.data is not freed up in one error case. Compile tested.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 fs/nfsd/nfs4recover.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -ruNp linux-2.6.27.org/fs/nfsd/nfs4recover.c linux-2.6.27.new/fs/nfsd/nfs4recover.c
--- linux-2.6.27.org/fs/nfsd/nfs4recover.c	2008-10-20 10:47:15.000000000 +0530
+++ linux-2.6.27.new/fs/nfsd/nfs4recover.c	2008-10-20 10:48:38.000000000 +0530
@@ -110,9 +110,9 @@ nfs4_make_rec_clidname(char *dname, stru
 
 	md5_to_hex(dname, cksum.data);
 
-	kfree(cksum.data);
 	status = nfs_ok;
 out:
+	kfree(cksum.data);
 	crypto_free_hash(desc.tfm);
 out_no_tfm:
 	return status;
