Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:52744 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2388453AbeGXIjp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Jul 2018 04:39:45 -0400
From: jiyin@redhat.com
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH 23/24] pynfs: python3 support plan: fix except multi exceptions in one line
Date: Tue, 24 Jul 2018 15:33:41 +0800
Message-Id: <20180724073342.5738-23-jiyin@redhat.com>
In-Reply-To: <20180724073342.5738-1-jiyin@redhat.com>
References: <20180724073342.5738-1-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 rpc/rpc.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/rpc/rpc.py b/rpc/rpc.py
index 46c59bf..18ff9fd 100644
--- a/rpc/rpc.py
+++ b/rpc/rpc.py
@@ -613,7 +613,7 @@ class ConnectionHandler(object):
             msg_data = record[p.get_position():] # RPC payload
             # Remember length of the header
             msg.length = p.get_position()
-        except (rpc_pack.XDRError, EOFError), e:
+        except (rpc_pack.XDRError, EOFError) as e:
             log_t.warn("XDRError: %s, dropping packet" % e)
             log_t.debug("unpacking raised the following error", exc_info=True)
             self._notify_drop()
-- 
2.17.1

