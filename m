From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] sunrpc svc: be quieter
Date: Sun,  5 Mar 2006 00:55:32 +0000 (GMT)
Message-ID: <20060305005532.5E7A0870504@zog.reactivated.net>
Cc: nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932314AbWCEAz1@vger.kernel.org>
To: neilb@cse.unsw.edu.au
Cc: linux-kernel@vger.kernel.org
Cc: okir@monad.swb.de
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

A Gentoo user at http://bugs.gentoo.org/124884 reports that the following
message appears in the logs over 650 times every day:

	svc: unknown version (0)

The system is a NFS server with many active clients.

Given that this #define only controls printk output, does it make sense to
disable it by default?

Signed-off-by: Daniel Drake <dsd@gentoo.org>

--- linux/net/sunrpc/svc.c.orig	2006-03-05 00:51:10.000000000 +0000
+++ linux/net/sunrpc/svc.c	2006-03-05 00:52:40.000000000 +0000
@@ -20,7 +20,7 @@
 #include <linux/sunrpc/clnt.h>
 
 #define RPCDBG_FACILITY	RPCDBG_SVCDSP
-#define RPC_PARANOIA 1
+#undef RPC_PARANOIA
 
 /*
  * Create an RPC service
