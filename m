Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33229 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608AbbDPMvZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Apr 2015 08:51:25 -0400
Received: by paboj16 with SMTP id oj16so88883390pab.0
        for <linux-nfs@vger.kernel.org>; Thu, 16 Apr 2015 05:51:24 -0700 (PDT)
Message-ID: <552FB045.80604@gmail.com>
Date: Thu, 16 Apr 2015 20:51:17 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        smayhew@redhat.com, kinglongmee@gmail.com
Subject: [PATCH] rpc.mountd: Remove duplicate and invalid secinfo setting
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSD return reply of client's SECINFO_NO_NAME request with four
security information number as, 1 1 0 0

It's caused by commit 4a1ad4aa30,
"mountd: Enable all auth flavors on pseudofs exports"

This patch removes duplicate secinfo and invalid secinfo (zero).

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 support/nfs/exports.c | 2 +-
 utils/mountd/v4root.c | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 761a046..0aea6f1 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -408,7 +408,7 @@ int secinfo_addflavor(struct flav_info *flav, struct exportent *ep)
 	struct sec_entry *p;
 
 	for (p=ep->e_secinfo; p->flav; p++) {
-		if (p->flav == flav)
+		if (p->flav == flav || p->flav->fnum == flav->fnum)
 			return p - ep->e_secinfo;
 	}
 	if (p - ep->e_secinfo >= SECFLAVOR_COUNT) {
diff --git a/utils/mountd/v4root.c b/utils/mountd/v4root.c
index 429ebb8..d521725 100644
--- a/utils/mountd/v4root.c
+++ b/utils/mountd/v4root.c
@@ -69,6 +69,9 @@ set_pseudofs_security(struct exportent *pseudo, int flags)
 	for (flav = flav_map; flav < flav_map + flav_map_size; flav++) {
 		struct sec_entry *new;
 
+		if (!flav->fnum)
+			continue;
+
 		i = secinfo_addflavor(flav, pseudo);
 		new = &pseudo->e_secinfo[i];
 
-- 
2.3.5

