Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10BDFC04EB8
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D2D9320834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2D9320834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725907AbeLCAcP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:32:15 -0500
Received: from mx2.suse.de ([195.135.220.15]:40824 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCAcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:32:14 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id E2EDFADBF;
        Mon,  3 Dec 2018 00:32:08 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:30 +1100
Subject: [PATCH 02/23] cred: add get_cred_rcu()
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703011.28598.13362863726888068035.stgit@noble>
In-Reply-To: <154379689752.28598.6750646657534626618.stgit@noble>
References: <154379689752.28598.6750646657534626618.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Sometimes we want to opportunistically get a
ref to a cred in an rcu_read_lock protected section.
get_task_cred() does this, and NFS does as similar thing
with its own credential structures.
To prepare for NFS converting to use 'struct cred' more
uniformly, define get_cred_rcu(), and use it in
get_task_cred().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/cred.h |   11 +++++++++++
 kernel/cred.c        |    2 +-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index f1085767e1b3..48979fcb95cf 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -252,6 +252,17 @@ static inline const struct cred *get_cred(const struct cred *cred)
 	return get_new_cred(nonconst_cred);
 }
 
+static inline const struct cred *get_cred_rcu(const struct cred *cred)
+{
+	struct cred *nonconst_cred = (struct cred *) cred;
+	if (!cred)
+		return NULL;
+	if (!atomic_inc_not_zero(&nonconst_cred->usage))
+		return NULL;
+	validate_creds(cred);
+	return cred;
+}
+
 /**
  * put_cred - Release a reference to a set of credentials
  * @cred: The credentials to release
diff --git a/kernel/cred.c b/kernel/cred.c
index 0b3ac72bd717..ba60162249e8 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -195,7 +195,7 @@ const struct cred *get_task_cred(struct task_struct *task)
 	do {
 		cred = __task_cred((task));
 		BUG_ON(!cred);
-	} while (!atomic_inc_not_zero(&((struct cred *)cred)->usage));
+	} while (!get_cred_rcu(cred));
 
 	rcu_read_unlock();
 	return cred;


