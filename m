Return-Path: <SRS0=VC/3=BV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95BE6C433DF
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Aug 2020 02:18:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6FC4C206DC
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Aug 2020 02:18:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="RcR2sqZE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726831AbgHKCSn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Aug 2020 22:18:43 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51326 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726473AbgHKCSn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Aug 2020 22:18:43 -0400
Received: from casper.infradead.org (casper.infradead.org [IPv6:2001:8b0:10b:1236::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0E08FC06174A;
        Mon, 10 Aug 2020 19:18:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=casper.20170209; h=Content-Transfer-Encoding:MIME-Version:
        Message-Id:Date:Subject:Cc:To:From:Sender:Reply-To:Content-Type:Content-ID:
        Content-Description:In-Reply-To:References;
        bh=FDgWfRdb7sBPKRkD1CaN3MgEIO4tPkEjDVHYa1wkGMM=; b=RcR2sqZEQyUvV/LQhBmIXE8Bq1
        njBwGb+/Zowore43lmKN9TXwJKeWvotOMH70cQKwwzzHFkoWU0rocSdJVcvDtiaqGHaVyzoy6Hdfi
        r9dI7POHPQnfSZ3rPaNlOYUg/ieX+iHBA1Dv9XCj9s2fDMVRszki4p9FBnyjCWQ6Pst4mzDH/5INh
        zktwiRX98BD5DaWpaU1zPlVC4/3hJNLEHf4BVmx6d1L8QVdBeSDfccTtPJszX3g9z7oiyaFp+JkK6
        /Xb7/teKY0tNuTh1J8nqOXn2WIbPwH66lNYJHRWM4MWg0aIX4QtFc1+SQj4piVsUKumakqjzTphe9
        vOxbt5sw==;
Received: from [2601:1c0:6280:3f0::19c2] (helo=smtpauth.infradead.org)
        by casper.infradead.org with esmtpsa (Exim 4.92.3 #3 (Red Hat Linux))
        id 1k5Js6-0006pr-DE; Tue, 11 Aug 2020 02:18:39 +0000
From:   Randy Dunlap <rdunlap@infradead.org>
To:     linux-kernel@vger.kernel.org
Cc:     Randy Dunlap <rdunlap@infradead.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] fs: nfs: delete repeated words in comments
Date:   Mon, 10 Aug 2020 19:18:35 -0700
Message-Id: <20200811021835.25084-1-rdunlap@infradead.org>
X-Mailer: git-send-email 2.26.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Drop duplicated words {the, and} in comments.

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
---
 fs/nfs/fs_context.c |    2 +-
 fs/nfs/nfs4xdr.c    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--- linux-next-20200807.orig/fs/nfs/fs_context.c
+++ linux-next-20200807/fs/nfs/fs_context.c
@@ -982,7 +982,7 @@ static int nfs23_parse_monolithic(struct
 		/*
 		 * The legacy version 6 binary mount data from userspace has a
 		 * field used only to transport selinux information into the
-		 * the kernel.  To continue to support that functionality we
+		 * kernel.  To continue to support that functionality we
 		 * have a touch of selinux knowledge here in the NFS code. The
 		 * userspace code converted context=blah to just blah so we are
 		 * converting back to the full string selinux understands.
--- linux-next-20200807.orig/fs/nfs/nfs4xdr.c
+++ linux-next-20200807/fs/nfs/nfs4xdr.c
@@ -5252,7 +5252,7 @@ static int decode_readlink(struct xdr_st
 	 * The XDR encode routine has set things up so that
 	 * the link text will be copied directly into the
 	 * buffer.  We just have to do overflow-checking,
-	 * and and null-terminate the text (the VFS expects
+	 * and null-terminate the text (the VFS expects
 	 * null-termination).
 	 */
 	xdr_terminate_string(rcvbuf, len);
