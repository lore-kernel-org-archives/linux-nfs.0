Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:59038 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728034AbeGVKXZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 22 Jul 2018 06:23:25 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 2/6] pynfs: python3 support plan: exec -> exec()
Date: Sun, 22 Jul 2018 17:27:06 +0800
Message-Id: <20180722092710.17521-2-jiyin@redhat.com>
In-Reply-To: <20180722092710.17521-1-jiyin@redhat.com>
References: <20180722092710.17521-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

'/exec / {:loop /[^\\]$/! {N; b loop}; s/exec /exec(/; s/$/)/; }'

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 nfs4.1/nfs4commoncode.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/nfs4.1/nfs4commoncode.py b/nfs4.1/nfs4commoncode.py
index cadd237..3c9c811 100644
--- a/nfs4.1/nfs4commoncode.py
+++ b/nfs4.1/nfs4commoncode.py
@@ -190,8 +190,8 @@ class %(CompoundState)s(object):
 '''
 
 # Create normal code
-exec code_str % _d
+exec(code_str % _d)
 
 # Create callback code
-exec code_str % _cb_d
+exec(code_str % _cb_d)
 
-- 
2.17.1

