Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:60404 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbaFDVCW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2014 17:02:22 -0400
Received: by mail-ie0-f175.google.com with SMTP id y20so68439ier.6
        for <linux-nfs@vger.kernel.org>; Wed, 04 Jun 2014 14:02:21 -0700 (PDT)
From: Weston Andros Adamson <dros@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Weston Andros Adamson <dros@primarydata.com>
Subject: [PATCH pynfs 06/17] 4.1 client: remove unused imports
Date: Wed,  4 Jun 2014 17:01:54 -0400
Message-Id: <1401915726-29092-7-git-send-email-dros@primarydata.com>
In-Reply-To: <1401915726-29092-1-git-send-email-dros@primarydata.com>
References: <1401915726-29092-1-git-send-email-dros@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
---
 nfs4.1/nfs4client.py | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/nfs4.1/nfs4client.py b/nfs4.1/nfs4client.py
index 91c698d..0904577 100644
--- a/nfs4.1/nfs4client.py
+++ b/nfs4.1/nfs4client.py
@@ -8,15 +8,13 @@ from xdrdef.sctrl_pack import SCTRLPacker, SCTRLUnpacker
 import nfs4_ops as op
 import time, struct
 import threading
-import collections
 import hmac
-from locking import Lock
 from nfs4commoncode import CBCompoundState as CompoundState, \
      cb_encode_status as encode_status, \
      cb_encode_status_by_name as encode_status_by_name
 
 
-import sys, traceback
+import traceback
 import logging
 logging.basicConfig(level=logging.INFO,
                     format="%(levelname)-7s:%(name)s:%(message)s")
-- 
1.8.5.2 (Apple Git-48)

