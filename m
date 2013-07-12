Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f53.google.com ([209.85.213.53]:43582 "EHLO
	mail-yh0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964933Ab3GLQca (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jul 2013 12:32:30 -0400
Received: by mail-yh0-f53.google.com with SMTP id a41so3818775yho.12
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jul 2013 09:32:29 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe93:815b])
        by mx.google.com with ESMTPSA id 66sm68990344yhe.20.2013.07.12.09.32.29
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 12 Jul 2013 09:32:29 -0700 (PDT)
Subject: [PATCH v1 07/19] NFS: Fix compiler warning in nfs_setup_sequence()
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 12 Jul 2013 12:32:28 -0400
Message-ID: <20130712163228.1444.26489.stgit@seurat.1015granger.net>
In-Reply-To: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.  Squelch compiler warning:

linux/fs/nfs/nfs4proc.c: In function ‘nfs4_setup_sequence’:
linux/fs/nfs/nfs4proc.c:703:2: warning: signed and unsigned type in
	conditional expression [-Wsign-compare]

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/nfs4proc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7b2e008..5913e1d 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -655,7 +655,7 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
 
 	dprintk("--> %s clp %p session %p sr_slot %d\n",
 		__func__, session->clp, session, res->sr_slot ?
-			res->sr_slot->slot_nr : -1);
+			(int)res->sr_slot->slot_nr : -1);
 
 	ret = nfs41_setup_sequence(session, args, res, task);
 out:

