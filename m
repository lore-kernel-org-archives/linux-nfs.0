Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 124F0C64EB4
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CEC5020834
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:32:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEC5020834
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725926AbeLCAcV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:32:21 -0500
Received: from mx2.suse.de ([195.135.220.15]:40898 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCAcV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:32:21 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 54831ADC0;
        Mon,  3 Dec 2018 00:32:15 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date:   Mon, 03 Dec 2018 11:30:30 +1100
Subject: [PATCH 03/23] cred: export get_task_cred().
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Message-ID: <154379703016.28598.13147808379270234369.stgit@noble>
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


