Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3175AC07E99
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Jul 2021 18:57:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1597C611AD
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Jul 2021 18:57:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233344AbhGLTAf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Jul 2021 15:00:35 -0400
Received: from mail.kernel.org ([198.145.29.99]:54244 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230409AbhGLTAf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Jul 2021 15:00:35 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id E2D656120A;
        Mon, 12 Jul 2021 18:57:46 +0000 (UTC)
Subject: [PATCH v4 0/3] Bulk-release pages during NFSD read splice
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-mm@kvack.org
Cc:     neilb@suse.de
Date:   Mon, 12 Jul 2021 14:57:46 -0400
Message-ID: <162611520339.1416.14646909890289253420.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

As with the page allocation side, I'm trying to reduce the average
number of times NFSD invokes the page allocation and release APIs
because they can be expensive, and because it is a resource that is
shared amongst all nfsd threads and thus access to it is at least
partially serialized. This small series tackles a code path that is
frequently invoked when NFSD handles READ operations on local
filesystems that support splice (i.e., most of the popular ones).

Changes since v3:
- Mark patches 1 and 3 as Reviewed-by: Neil Brown
- Convert bare release_pages() calls to pagevec_release()
- Release accrued free pages after every RPC retires

---

Chuck Lever (3):
      NFSD: Clean up splice actor
      SUNRPC: Add svc_rqst_replace_page() API
      NFSD: Batch release pages during splice read


 fs/nfsd/vfs.c              | 20 +++++---------------
 include/linux/sunrpc/svc.h |  4 ++++
 net/sunrpc/svc.c           | 21 +++++++++++++++++++++
 net/sunrpc/svc_xprt.c      |  3 +++
 4 files changed, 33 insertions(+), 15 deletions(-)

--
Chuck Lever

