Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m50-135.163.com ([123.125.50.135]:55194 "EHLO m50-135.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751842AbcAAOIT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jan 2016 09:08:19 -0500
From: Geliang Tang <geliangtang@163.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: Geliang Tang <geliangtang@163.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 3/3] lockd: use to_delayed_work
Date: Fri,  1 Jan 2016 22:06:29 +0800
Message-Id: <741bd37af1f46a3713423e16138910f12a5c12b5.1451656900.git.geliangtang@163.com>
In-Reply-To: <87ea17d237ec636e674f8be097a7e65cbce4d252.1451656900.git.geliangtang@163.com>
References: <87ea17d237ec636e674f8be097a7e65cbce4d252.1451656900.git.geliangtang@163.com>
In-Reply-To: <87ea17d237ec636e674f8be097a7e65cbce4d252.1451656900.git.geliangtang@163.com>
References: <87ea17d237ec636e674f8be097a7e65cbce4d252.1451656900.git.geliangtang@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use to_delayed_work() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 fs/lockd/svc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 44d18ad..b4006c72 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -94,8 +94,7 @@ static unsigned long get_lockd_grace_period(void)
 
 static void grace_ender(struct work_struct *grace)
 {
-	struct delayed_work *dwork = container_of(grace, struct delayed_work,
-						  work);
+	struct delayed_work *dwork = to_delayed_work(grace);
 	struct lockd_net *ln = container_of(dwork, struct lockd_net,
 					    grace_period_end);
 
-- 
2.5.0


