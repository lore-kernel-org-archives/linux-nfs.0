Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9501C04EB8
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:58:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6911F20881
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 00:58:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6911F20881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725851AbeLCA67 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 19:58:59 -0500
Received: from mx2.suse.de ([195.135.220.15]:43092 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725785AbeLCA67 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 19:58:59 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 4F7C1AD3B;
        Mon,  3 Dec 2018 00:58:53 +0000 (UTC)
From:   NeilBrown <neilb@suse.com>
To:     Steve Dickson <SteveD@RedHat.com>
Date:   Mon, 03 Dec 2018 11:58:25 +1100
Subject: [PATCH 2/3] Let systemd know when rpc.statd is needed.
Cc:     Justin Mitchell <jumitche@rehat.com>, linux-nfs@vger.kernel.org
Message-ID: <154379870498.3215.1051796458035422926.stgit@noble>
In-Reply-To: <154379862296.3215.11174339731963464375.stgit@noble>
References: <154379862296.3215.11174339731963464375.stgit@noble>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A recent change to set IgnoreOnIsolate for rpc-statd
isn't quite sufficient (though it doesn't hurt).
While rpc-statd does remain when
  systemctl isolate multi-user
is run, its dependencies don't remain, so rpcbind might
get killed, which makes rpc.statd rather useless.

The reason this is all an issue is that systemd doesn't know that
rpc-statd is needed - mount.nfs explicitly starts it rather than
having a dependency start it.
This can be rectified by explicitly telling systemd about the
dependency using "systemctl add-wants".  This can be done in the
start-statd script, at the same time that rpc-statd is started.

As --runtime dependency is used so that it doesn't persist across
reboots.  A new dependency will be created on next boot if an NFSv3
filesystem is mounted.

With this in place, both rpc.statd and rpcbind remain.
Actually, rpcbind.service is stopped, but rpcbind.socket remains,
and when anything tries to contact rpcbind, rpcbind.service
is automatically started and it re-reads its saved state.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/statd/start-statd |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/utils/statd/start-statd b/utils/statd/start-statd
index 82715b40c1af..54ced822016a 100755
--- a/utils/statd/start-statd
+++ b/utils/statd/start-statd
@@ -20,7 +20,12 @@ fi
 # First try systemd if it's installed.
 if [ -d /run/systemd/system ]; then
     # Quit only if the call worked.
-    systemctl start rpc-statd.service && exit
+    if systemctl start rpc-statd.service; then
+        # Ensure systemd knows not to stop rpc.statd or its dependencies
+        # on 'systemctl isolate ..'
+        systemctl add-wants --runtime remote-fs.target rpc-statd.service
+        exit 0
+    fi
 fi
 
 cd /


