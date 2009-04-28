Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4995 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009AbZD1Q4S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2009 12:56:18 -0400
From: andros@netapp.com
To: bfields@fieldses.org
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] pynfs: set cache_this to false for readdir
Date: Tue, 28 Apr 2009 12:56:15 -0400
Message-Id: <1240937775-23746-2-git-send-email-andros@netapp.com>
In-Reply-To: <1240937775-23746-1-git-send-email-andros@netapp.com>
References: <>
 <1240937775-23746-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

testserver.py was failing initialization against the new Linux server DRC
which has a lower max resonse size cached value than the initializaion
readdir response.

Set cache_this to False

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 nfs4.1/server41tests/environment.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/nfs4.1/server41tests/environment.py b/nfs4.1/server41tests/environment.py
index fb0e7ed..8623158 100644
--- a/nfs4.1/server41tests/environment.py
+++ b/nfs4.1/server41tests/environment.py
@@ -415,7 +415,7 @@ def do_readdir(sess, file, cookie=0, cookieverf='', attrs=0L,
     baseops = use_obj(file)
     while True:
         readdir_op = op.readdir(cookie, cookieverf, dircount, maxcount, attrs)
-        res = sess.compound(baseops + [readdir_op])
+        res = sess.compound(baseops + [readdir_op], cache_this=False)
         check(res, msg="READDIR with cookie=%i, maxcount=%i" % (cookie, maxcount))
         reply = res.resarray[-1].reply
         if not reply.entries and not reply.eof:
-- 
1.5.4.3

