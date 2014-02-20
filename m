Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43469 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751213AbaBTG4S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:56:18 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:55:30 +1100
Subject: [PATCH 1/6] systemd units: remove reference to nfs-server.target
 from nfs-server.service.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220065530.7320.39915.stgit@notabene.brown>
In-Reply-To: <20140220065345.7320.49992.stgit@notabene.brown>
References: <20140220065345.7320.49992.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This  line was somehow missed in a recent patch.  nfs-server.target
doesn't exists, so nothing can be part of it.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 systemd/nfs-server.service |    1 -
 1 file changed, 1 deletion(-)

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 26df65662428..5779fd39ed34 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -1,7 +1,6 @@
 [Unit]
 Description=NFS server and services
 Requires= network.target proc-fs-nfsd.mount rpcbind.target
-PartOf=nfs-server.target
 Requires= nfs-mountd.service
 Wants=rpc-statd.service nfs-idmapd.service rpc-gssd.service rpc-svcgssd.service
 Wants=rpc-statd-notify.service


