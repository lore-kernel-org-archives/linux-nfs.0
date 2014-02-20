Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:43723 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940AbaBTG4v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Feb 2014 01:56:51 -0500
From: Neil Brown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 20 Feb 2014 17:55:30 +1100
Subject: [PATCH 5/6] systemd: nfs-client needs rpc-svcgssd too.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20140220065530.7320.83541.stgit@notabene.brown>
In-Reply-To: <20140220065345.7320.49992.stgit@notabene.brown>
References: <20140220065345.7320.49992.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For NFSv4.0 callbacks, the server needs the client code and
the client needs the server code.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 systemd/nfs-client.target |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/systemd/nfs-client.target b/systemd/nfs-client.target
index fa591354abf3..f3c09e76a0f7 100644
--- a/systemd/nfs-client.target
+++ b/systemd/nfs-client.target
@@ -5,8 +5,9 @@ Wants=remote-fs-pre.target
 
 # Note: we don't "Wants=rpc-statd.service" as "mount.nfs" will arrange to
 # start that on demand if needed.
-Wants=rpc-gssd.service nfs-blkmap.service rpc-statd-notify.service
-Before=rpc-gssd.service nfs-blkmap.service
+Wants=rpc-gssd.service rpc-svcgssd.service
+Wants=nfs-blkmap.service rpc-statd-notify.service
+Before=rpc-gssd.service rpc-svcgssd.service nfs-blkmap.service
 
 [Install]
 WantedBy=multi-user.target


