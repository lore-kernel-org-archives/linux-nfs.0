Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43759 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752118AbaBTG5A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:57:00 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:55:30 +1100
Subject: [PATCH 6/6] systemd: add PIDFile directives where appropriate.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220065530.7320.50532.stgit@notabene.brown>
In-Reply-To: <20140220065345.7320.49992.stgit@notabene.brown>
References: <20140220065345.7320.49992.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Only two of our daemons write out pid files.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 systemd/nfs-blkmap.service |    1 +
 systemd/rpc-statd.service  |    1 +
 2 files changed, 2 insertions(+)

diff --git a/systemd/nfs-blkmap.service b/systemd/nfs-blkmap.service
index 4b74e9f61454..68cc9e968e65 100644
--- a/systemd/nfs-blkmap.service
+++ b/systemd/nfs-blkmap.service
@@ -12,4 +12,5 @@ PartOf=nfs-utils.service
 
 [Service]
 Type=forking
+PIDFile=/var/run/blkmapd.pid
 ExecStart=/usr/sbin/blkmapd
diff --git a/systemd/rpc-statd.service b/systemd/rpc-statd.service
index c5795fd68f96..14604d783ddf 100644
--- a/systemd/rpc-statd.service
+++ b/systemd/rpc-statd.service
@@ -13,4 +13,5 @@ After=nfs-config.service
 [Service]
 EnvironmentFile=-/run/sysconfig/nfs-utils
 Type=forking
+PIDFile=/var/run/rpc.statd.pid
 ExecStart=/usr/sbin/rpc.statd --no-notify $STATDARGS


