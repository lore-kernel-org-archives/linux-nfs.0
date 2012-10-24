Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161045Ab2JXSLe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 14:11:34 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9OIBXj0005439
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:34 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q9OIBWSF020176
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:33 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 3/5] Fixed warnings in src/g_inq_cred.c
Date: Wed, 24 Oct 2012 14:08:42 -0400
Message-Id: <1351102124-24036-4-git-send-email-steved@redhat.com>
In-Reply-To: <1351102124-24036-1-git-send-email-steved@redhat.com>
References: <1351102124-24036-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Yao Zhao <yao.zhao@windriver.com>

g_inq_cred.c:161:8: warning: passing argument 3 of
'generic_gss_copy_oid' from incompatible pointer type [enabled by default]

Signed-off-by: Yao Zhao <yao.zhao@windriver.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/g_inq_cred.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/src/g_inq_cred.c b/src/g_inq_cred.c
index 9f531d8..8367a56 100644
--- a/src/g_inq_cred.c
+++ b/src/g_inq_cred.c
@@ -152,13 +152,15 @@ gss_OID_set *		mechanisms;
 			     union_cred->count);
 	if ((*mechanisms)->elements == NULL) {
 	    *minor_status = ENOMEM;
+	    free(*mechanisms);
+	    *mechanisms = GSS_C_NO_OID_SET;
 	    return (GSS_S_FAILURE);
 	}
 
 	for (i=0; i < union_cred->count; i++) {
-	    status = generic_gss_copy_oid(minor_status,
+	    status = generic_gss_add_oid_set_member(minor_status,
 	    				  &union_cred->mechs_array[i],
-					  &((*mechanisms)->elements[i]));
+					  mechanisms);
 	    if (status != GSS_S_COMPLETE)
 	        break;
 	}
-- 
1.7.11.7

