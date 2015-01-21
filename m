Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f48.google.com ([74.125.82.48]:55071 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754650AbbAUPxg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2015 10:53:36 -0500
Received: by mail-wg0-f48.google.com with SMTP id x12so12123521wgg.7
        for <linux-nfs@vger.kernel.org>; Wed, 21 Jan 2015 07:53:34 -0800 (PST)
Received: from [192.168.1.1] ([212.159.35.30])
        by mx.google.com with ESMTPSA id gf9sm326924wjc.0.2015.01.21.07.53.33
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jan 2015 07:53:33 -0800 (PST)
Message-ID: <54BFCB7C.5020902@gmail.com>
Date: Wed, 21 Jan 2015 15:53:32 +0000
From: Chris Mayo <aklhfex@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [PATCH] systemd: Ensure RPC pipefs is mounted before rpc.idmapd starts
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rpc.idmapd aborts on start-up if RPC pipefs is not present.

Needed if GSS services are not used.

Signed-off-by: Chris Mayo <aklhfex@gmail.com>
---
 systemd/nfs-idmapd.service | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/systemd/nfs-idmapd.service b/systemd/nfs-idmapd.service
index 726038d..e84f8c8 100644
--- a/systemd/nfs-idmapd.service
+++ b/systemd/nfs-idmapd.service
@@ -1,5 +1,7 @@
 [Unit]
 Description=NFSv4 ID-name mapping service
+Requires=var-lib-nfs-rpc_pipefs.mount
+After=var-lib-nfs-rpc_pipefs.mount
 
 BindsTo=nfs-server.service
 
-- 
2.0.5


