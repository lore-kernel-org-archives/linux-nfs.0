Return-Path: <SRS0=4cvb=NS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3476EC0044C
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:13:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0736A2081D
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Nov 2018 04:13:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0736A2081D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388240AbeKGNmZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Nov 2018 08:42:25 -0500
Received: from mx2.suse.de ([195.135.220.15]:56440 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388183AbeKGNmZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Nov 2018 08:42:25 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id A4F39B11C;
        Wed,  7 Nov 2018 04:13:48 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Wed, 07 Nov 2018 15:12:30 +1100
Subject: [PATCH 03/23] cred: export get_task_cred().
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154156395082.24086.18382449925817679834.stgit@noble>
In-Reply-To: <154156285766.24086.14262073575778354276.stgit@noble>
References: <154156285766.24086.14262073575778354276.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

There is no reason that modules should not be able
to use this, and NFS will need it when converted to
use 'struct cred'.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 kernel/cred.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/cred.c b/kernel/cred.c
index ba60162249e8..21f4a97085b4 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -200,6 +200,7 @@ const struct cred *get_task_cred(struct task_struct *task)
 	rcu_read_unlock();
 	return cred;
 }
+EXPORT_SYMBOL(get_task_cred);
 
 /*
  * Allocate blank credentials, such that the credentials can be filled in at a


