Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:30509 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965699AbcHBM52 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:28 -0400
From: Baole Ni <baolex.ni@intel.com>
To: bfields@fieldses.org, jlayton@poochiereds.net,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        davem@davemloft.net, kadlec@blackhole.kfki.hu,
        m.szyprowski@samsung.com, kyungmin.park@samsung.com,
        k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
        baolex.ni@intel.com, arnd@arndb.de, aryabinin@virtuozzo.com
Subject: [PATCH 1139/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:46 +0800
Message-Id: <20160802121946.26050-1-baolex.ni@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/sunrpc/xprtsock.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7e2b2fa..51dec63 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -3166,8 +3166,8 @@ static const struct kernel_param_ops param_ops_portnr = {
 #define param_check_portnr(name, p) \
 	__param_check(name, p, unsigned int);
 
-module_param_named(min_resvport, xprt_min_resvport, portnr, 0644);
-module_param_named(max_resvport, xprt_max_resvport, portnr, 0644);
+module_param_named(min_resvport, xprt_min_resvport, portnr, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param_named(max_resvport, xprt_max_resvport, portnr, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
 static int param_set_slot_table_size(const char *val,
 				     const struct kernel_param *kp)
@@ -3202,9 +3202,9 @@ static const struct kernel_param_ops param_ops_max_slot_table_size = {
 	__param_check(name, p, unsigned int);
 
 module_param_named(tcp_slot_table_entries, xprt_tcp_slot_table_entries,
-		   slot_table_size, 0644);
+		   slot_table_size, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 module_param_named(tcp_max_slot_table_entries, xprt_max_tcp_slot_table_entries,
-		   max_slot_table_size, 0644);
+		   max_slot_table_size, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 module_param_named(udp_slot_table_entries, xprt_udp_slot_table_entries,
-		   slot_table_size, 0644);
+		   slot_table_size, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
-- 
2.9.2

