Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-vbr13.xs4all.nl ([194.109.24.33]:4190 "EHLO
	smtp-vbr13.xs4all.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485Ab0HVSbc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Aug 2010 14:31:32 -0400
Date: Sun, 22 Aug 2010 20:31:09 +0200
From: Miquel van Smoorenburg <mikevs@xs4all.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/03]: sunrpc: make auth_hashtable_size param mode 0444
Message-ID: <20100822183109.GB26607@xs4all.net>
References: <20100822182848.GA26590@xs4all.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100822182848.GA26590@xs4all.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The auth_hashtable_size parameter shows up in
/sys/module/sunrpc/parameters with mode 0644. However the hashtables
are allocated when the module is loaded, and changing the parameter
afterwards doesn't do much. So make it read-only.

Signed-off-by: Miquel van Smoorenburg <mikevs@xs4all.net>

diff -ruN linux-2.6.36-rc1.orig/net/sunrpc/auth.c linux-2.6.36-rc1/net/sunrpc/auth.c
--- linux-2.6.36-rc1.orig/net/sunrpc/auth.c	2010-08-16 02:41:37.000000000 +0200
+++ linux-2.6.36-rc1/net/sunrpc/auth.c	2010-08-22 17:02:27.896009116 +0200
@@ -76,7 +77,7 @@
 	.get = param_get_hashtbl_sz,
 };
 
-module_param_named(auth_hashtable_size, auth_hashbits, hashtbl_sz, 0644);
+module_param_named(auth_hashtable_size, auth_hashbits, hashtbl_sz, 0444);
 MODULE_PARM_DESC(auth_hashtable_size, "RPC credential cache hashtable size");
 
 static u32
