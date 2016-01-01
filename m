Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from m50-133.163.com ([123.125.50.133]:45119 "EHLO m50-133.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751746AbcAAOHb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Jan 2016 09:07:31 -0500
From: Geliang Tang <geliangtang@163.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: Geliang Tang <geliangtang@163.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] nfsd: use to_delayed_work
Date: Fri,  1 Jan 2016 22:06:28 +0800
Message-Id: <cbb79cde089ca9a40aca5d878607187d6f8e476d.1451656900.git.geliangtang@163.com>
In-Reply-To: <87ea17d237ec636e674f8be097a7e65cbce4d252.1451656900.git.geliangtang@163.com>
References: <87ea17d237ec636e674f8be097a7e65cbce4d252.1451656900.git.geliangtang@163.com>
In-Reply-To: <87ea17d237ec636e674f8be097a7e65cbce4d252.1451656900.git.geliangtang@163.com>
References: <87ea17d237ec636e674f8be097a7e65cbce4d252.1451656900.git.geliangtang@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use to_delayed_work() instead of open-coding it.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 fs/nfsd/nfs4state.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6ef240c..c484a2b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4571,8 +4571,7 @@ static void
 laundromat_main(struct work_struct *laundry)
 {
 	time_t t;
-	struct delayed_work *dwork = container_of(laundry, struct delayed_work,
-						  work);
+	struct delayed_work *dwork = to_delayed_work(laundry);
 	struct nfsd_net *nn = container_of(dwork, struct nfsd_net,
 					   laundromat_work);
 
-- 
2.5.0


