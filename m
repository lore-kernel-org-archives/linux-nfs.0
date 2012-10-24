Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3670 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161028Ab2JXSLe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 14:11:34 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9OIBYG7005936
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:34 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q9OIBWSG020176
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:34 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/5] Fixed warnings in src/g_mit_krb5_mech.c
Date: Wed, 24 Oct 2012 14:08:43 -0400
Message-Id: <1351102124-24036-5-git-send-email-steved@redhat.com>
In-Reply-To: <1351102124-24036-1-git-send-email-steved@redhat.com>
References: <1351102124-24036-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

g_mit_krb5_mech.c:209:1: warning: label 'out' defined but not used [-Wunused-label]

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/g_mit_krb5_mech.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/src/g_mit_krb5_mech.c b/src/g_mit_krb5_mech.c
index b2ad784..aa7433a 100644
--- a/src/g_mit_krb5_mech.c
+++ b/src/g_mit_krb5_mech.c
@@ -206,6 +206,5 @@ internal_krb5_gss_initialize(void *dl)
 		krb5_mechanism.gss_free_lucid_sec_context = p;
 	}
 	krb5_mech_ptr = &krb5_mechanism;
-out:
 	return (krb5_mech_ptr);
 }
-- 
1.7.11.7

