Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33039 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752135AbeBHRPQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Feb 2018 12:15:16 -0500
Received: by mail-it0-f67.google.com with SMTP id u12so231652ite.0
        for <linux-nfs@vger.kernel.org>; Thu, 08 Feb 2018 09:15:16 -0800 (PST)
Subject: [PATCH] git should ignore the generated nfsref executable
From: Chuck Lever <chuck.lever@oracle.com>
To: SteveD@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 08 Feb 2018 12:15:15 -0500
Message-ID: <20180208171515.13080.3776.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 .gitignore |    1 +
 1 file changed, 1 insertion(+)

diff --git a/.gitignore b/.gitignore
index f17db9c..692ab0e 100644
--- a/.gitignore
+++ b/.gitignore
@@ -72,6 +72,7 @@ tests/nsm_client/nlm_sm_inter_clnt.c
 tests/nsm_client/nlm_sm_inter_svc.c
 tests/nsm_client/nlm_sm_inter_xdr.c
 utils/nfsidmap/nfsidmap
+utils/nfsref/nfsref
 systemd/nfs-server-generator
 systemd/rpc-pipefs-generator
 systemd/nfs-config.service

