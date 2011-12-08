Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62821 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab1LHTTN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Dec 2011 14:19:13 -0500
Received: by eekc4 with SMTP id c4so21245eek.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Dec 2011 11:19:11 -0800 (PST)
From: Tom Gundersen <teg@jklm.no>
To: linux-nfs@vger.kernel.org
Cc: Tom Gundersen <teg@jklm.no>, Kay Sievers <kay.sievers@vrfy.org>
Subject: [RFC][PATCH] libtirpc,rpcbind: move socket from /var/run to /run
Date: Thu,  8 Dec 2011 20:19:00 +0100
Message-Id: <1323371940-9140-1-git-send-email-teg@jklm.no>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

/run is guaranteed to be available and writeable at any time, whereas
/var might be on a separate partition and hence not available during
early boot. By moving the socket from /var to /run we are able to use
rpcbind earlier, which would in particular make a difference in case
/var is on an nfs mount, something I am currently seeing bug reports
about.

This change should not make a difference to software that currently
works as intended, as /var/run should be a symlink or bindmounted
to /run, so anyone relying on the socket being in /var/run will
still find it there.

The /run directory is supported by all the major distributions
(at least Debian, Fedora, Suse, Ubuntu and Arch from what I can gather).
See http://wiki.debian.org/ReleaseGoals/RunDirectory and
http://thread.gmane.org/gmane.linux.redhat.fedora.devel/146976 for some
more details.

Cc: Kay Sievers <kay.sievers@vrfy.org>
Signed-off-by: Tom Gundersen <teg@jklm.no>
---
 tirpc/rpc/rpcb_prot.h |    2 +-
 tirpc/rpc/rpcb_prot.x |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tirpc/rpc/rpcb_prot.h b/tirpc/rpc/rpcb_prot.h
index 7ae48b8..63b4a2c 100644
--- a/tirpc/rpc/rpcb_prot.h
+++ b/tirpc/rpc/rpcb_prot.h
@@ -476,7 +476,7 @@ extern bool_t xdr_netbuf(XDR *, struct netbuf *);
 #define RPCBVERS_3 RPCBVERS
 #define RPCBVERS_4 RPCBVERS4
 
-#define _PATH_RPCBINDSOCK "/var/run/rpcbind.sock"
+#define _PATH_RPCBINDSOCK "/run/rpcbind.sock"
 
 #else /* ndef _KERNEL */
 #ifdef __cplusplus
diff --git a/tirpc/rpc/rpcb_prot.x b/tirpc/rpc/rpcb_prot.x
index b21ac3d..ebe1e60 100644
--- a/tirpc/rpc/rpcb_prot.x
+++ b/tirpc/rpc/rpcb_prot.x
@@ -410,7 +410,7 @@ program RPCBPROG {
 %#define	RPCBVERS_3		RPCBVERS
 %#define	RPCBVERS_4		RPCBVERS4
 %
-%#define	_PATH_RPCBINDSOCK	"/var/run/rpcbind.sock"
+%#define	_PATH_RPCBINDSOCK	"/run/rpcbind.sock"
 %
 %#else		/* ndef _KERNEL */
 %#ifdef __cplusplus
-- 
1.7.8

