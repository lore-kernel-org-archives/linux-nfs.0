Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4831 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104Ab0KJAf1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Nov 2010 19:35:27 -0500
From: Joe Perches <joe@perches.com>
To: linux-kernel@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org, cluster-devel@redhat.com,
        linux-nilfs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: [PATCH 0/9] treewide: convert vprintk uses to %pV
Date: Tue,  9 Nov 2010 16:35:14 -0800
Message-Id: <cover.1289348757.git.joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Multiple secessive calls to printk can be interleaved.
Avoid this possible interleaving by using %pV

Joe Perches (9):
  drivers/gpu/drm/drm_stub.c: Use printf extension %pV
  drivers/isdn/mISDN: Use printf extension %pV
  drivers/net/wireless/ath/debug.c: Use printf extension %pV
  drivers/net/wireless/b43/main.c: Use printf extension %pV
  drivers/net/wireless/b43legacy/main.c: Use printf extension %pV
  fs/gfs2/glock.c: Use printf extension %pV
  fs/nilfs2/super.c: Use printf extension %pV
  fs/quota/dquot.c: Use printf extension %pV
  net/sunrpc/svc.c: Use printf extension %pV

 drivers/gpu/drm/drm_stub.c            |   14 +++++++--
 drivers/isdn/mISDN/layer1.c           |   10 +++++--
 drivers/isdn/mISDN/layer2.c           |   12 ++++++--
 drivers/isdn/mISDN/tei.c              |   23 +++++++++++----
 drivers/net/wireless/ath/debug.c      |    9 +++++-
 drivers/net/wireless/b43/main.c       |   48 ++++++++++++++++++++++++--------
 drivers/net/wireless/b43legacy/main.c |   47 ++++++++++++++++++++++++--------
 fs/gfs2/glock.c                       |    9 +++++-
 fs/nilfs2/super.c                     |   23 +++++++++++-----
 fs/quota/dquot.c                      |   12 +++++---
 net/sunrpc/svc.c                      |   12 +++++---
 11 files changed, 161 insertions(+), 58 deletions(-)

-- 
1.7.3.1.g432b3.dirty

