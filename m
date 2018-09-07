Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58278 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726151AbeIGWoA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Sep 2018 18:44:00 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 04/13] clnt_vc.c: resource_leak
Date: Fri,  7 Sep 2018 14:01:42 -0400
Message-Id: <20180907180151.178872-5-steved@redhat.com>
In-Reply-To: <20180907180151.178872-1-steved@redhat.com>
References: <20180907180151.178872-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Variable "ct" going out of scope leaks the storage it points to.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/clnt_vc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/src/clnt_vc.c b/src/clnt_vc.c
index 3d775c7..10ee91a 100644
--- a/src/clnt_vc.c
+++ b/src/clnt_vc.c
@@ -325,6 +325,8 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 	recvsz = __rpc_get_t_size(si.si_af, si.si_proto, (int)recvsz);
 	xdrrec_create(&(ct->ct_xdrs), sendsz, recvsz,
 	    cl->cl_private, read_vc, write_vc);
+	mem_free(ct->ct_addr.buf, ct->ct_addr.len);
+	mem_free(ct, sizeof (struct ct_data));
 	return (cl);
 
 err:
-- 
2.17.1
