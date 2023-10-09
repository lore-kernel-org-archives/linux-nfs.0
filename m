Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E801DCD611D
	for <linux-nfs@archiver.kernel.org>; Mon,  9 Oct 2023 18:30:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1377444AbjJISaH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 9 Oct 2023 14:30:07 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60822 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1377428AbjJISaG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Oct 2023 14:30:06 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 02C92A3
        for <linux-nfs@vger.kernel.org>; Mon,  9 Oct 2023 11:30:05 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 663D1C433C8;
        Mon,  9 Oct 2023 18:30:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1696876204;
        bh=YOYaHInkqCa3F12GrFj7uIvV0c1cGEFasUsD5JMguhc=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=QcT8+q35vWJJI1qeUqWQwvBvqtRhmzqTxq1w9QXRAkuxvRKHvdefwmVOzjDMMds1X
         pgqFItJjDPFBPGNlq++MvaCknsKpKAW64JG8+pHQmCHRrm7BKoHAtqz/7KcPfeN5qk
         055Q058vUk3edZMPVcNPFU3kT8dmbx6wxHVTW1/T+Lc7Q4iQuCsWjuqw0U1dIEREMU
         ep4ERm0So2pYpDuJi+dk4JR7VzzX+tVbXYILmQF0a4ptjaoQRD/QUUWYeKeUvfOtE6
         2g0Ogjl0IBPKAPnixNAcZA8CGeXG3fVKqomv+hg3Pl/STkf3jhqErOZHz97qPTk3B0
         oA0AX4NWVu36w==
Subject: [PATCH v1 4/8] NFSD: Clean up nfsd4_encode_test_stateid()
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Mon, 09 Oct 2023 14:30:03 -0400
Message-ID: <169687620314.41382.724364262613906063.stgit@oracle-102.nfsv4bat.org>
In-Reply-To: <169687606447.41382.568611605570999245.stgit@oracle-102.nfsv4bat.org>
References: <169687606447.41382.568611605570999245.stgit@oracle-102.nfsv4bat.org>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

Use conventional XDR utilities.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |   18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 85044cdcf2a7..859ee70e076f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4928,20 +4928,18 @@ nfsd4_encode_test_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
 			  union nfsd4_op_u *u)
 {
 	struct nfsd4_test_stateid *test_stateid = &u->test_stateid;
-	struct xdr_stream *xdr = resp->xdr;
 	struct nfsd4_test_stateid_id *stateid, *next;
-	__be32 *p;
+	struct xdr_stream *xdr = resp->xdr;
 
-	p = xdr_reserve_space(xdr, 4 + (4 * test_stateid->ts_num_ids));
-	if (!p)
+	/* tsr_status_codes<> */
+	if (xdr_stream_encode_u32(xdr, test_stateid->ts_num_ids) != XDR_UNIT)
 		return nfserr_resource;
-	*p++ = htonl(test_stateid->ts_num_ids);
-
-	list_for_each_entry_safe(stateid, next, &test_stateid->ts_stateid_list, ts_id_list) {
-		*p++ = stateid->ts_id_status;
+	list_for_each_entry_safe(stateid, next,
+				 &test_stateid->ts_stateid_list, ts_id_list) {
+		if (xdr_stream_encode_be32(xdr, stateid->ts_id_status) != XDR_UNIT)
+			return nfserr_resource;
 	}
-
-	return 0;
+	return nfs_ok;
 }
 
 #ifdef CONFIG_NFSD_PNFS


