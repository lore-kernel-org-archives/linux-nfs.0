Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98895C352A1
	for <linux-nfs@archiver.kernel.org>; Wed,  7 Dec 2022 08:43:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229589AbiLGInb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 7 Dec 2022 03:43:31 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39072 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229486AbiLGIna (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2022 03:43:30 -0500
Received: from lithops.sigma-star.at (lithops.sigma-star.at [195.201.40.130])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 99751AE6C;
        Wed,  7 Dec 2022 00:43:27 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
        by lithops.sigma-star.at (Postfix) with ESMTP id C919064BA9DB;
        Wed,  7 Dec 2022 09:43:24 +0100 (CET)
Received: from lithops.sigma-star.at ([127.0.0.1])
        by localhost (lithops.sigma-star.at [127.0.0.1]) (amavisd-new, port 10032)
        with ESMTP id eZ5PZuGXfVPK; Wed,  7 Dec 2022 09:43:24 +0100 (CET)
Received: from localhost (localhost [127.0.0.1])
        by lithops.sigma-star.at (Postfix) with ESMTP id 7098F64BA9DA;
        Wed,  7 Dec 2022 09:43:24 +0100 (CET)
Received: from lithops.sigma-star.at ([127.0.0.1])
        by localhost (lithops.sigma-star.at [127.0.0.1]) (amavisd-new, port 10026)
        with ESMTP id qyypJqZOdzsx; Wed,  7 Dec 2022 09:43:24 +0100 (CET)
Received: from blindfold.corp.sigma-star.at (unknown [82.150.214.1])
        by lithops.sigma-star.at (Postfix) with ESMTPSA id E3AA064BA9B1;
        Wed,  7 Dec 2022 09:43:23 +0100 (CET)
From:   Richard Weinberger <richard@nod.at>
To:     linux-nfs@vger.kernel.org
Cc:     linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@kernel.org, chuck.lever@oracle.com, anna@kernel.org,
        trond.myklebust@hammerspace.com, viro@zeniv.linux.org.uk,
        raven@themaw.net, chris.chilvers@appsbroker.com,
        david.young@appsbroker.com, luis.turcitu@appsbroker.com,
        david@sigma-star.at, benmaynard@google.com,
        Richard Weinberger <richard@nod.at>
Subject: [PATCH 1/3] NFSD: Teach nfsd_mountpoint() auto mounts
Date:   Wed,  7 Dec 2022 09:43:07 +0100
Message-Id: <20221207084309.8499-2-richard@nod.at>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <20221207084309.8499-1-richard@nod.at>
References: <20221207084309.8499-1-richard@nod.at>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Currently nfsd_mountpoint() tests for mount points using d_mountpoint(),
this works only when a mount point is already uncovered.
In our case the mount point is of type auto mount and can be coverted.
i.e. ->d_automount() was not called.

Using d_managed() nfsd_mountpoint() can test whether a mount point is
either already uncovered or can be uncovered later.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 fs/nfsd/vfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f650afedd67f..157f0df0e93a 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -160,7 +160,7 @@ int nfsd_mountpoint(struct dentry *dentry, struct svc=
_export *exp)
 		return 1;
 	if (nfsd4_is_junction(dentry))
 		return 1;
-	if (d_mountpoint(dentry))
+	if (d_managed(dentry))
 		/*
 		 * Might only be a mountpoint in a different namespace,
 		 * but we need to check.
--=20
2.26.2

