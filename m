Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:53644 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751665AbeFEPag (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Jun 2018 11:30:36 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2B6A810D44C
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jun 2018 15:30:36 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 0466C10FFE73
        for <linux-nfs@vger.kernel.org>; Tue,  5 Jun 2018 15:30:35 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] Remove a number of stringop-overflow warnings
Date: Tue,  5 Jun 2018 11:30:34 -0400
Message-Id: <20180605153034.49074-2-steved@redhat.com>
In-Reply-To: <20180605153034.49074-1-steved@redhat.com>
References: <20180605153034.49074-1-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

umich_ldap.c:1128:3: warning: ‘strncat’ specified bound 128
	equals destination size [-Wstringop-overflow=]

umich_ldap.c:1130:3: warning: ‘strncat’ specified bound 128
	equals destination size [-Wstringop-overflow=]

idmapd.c:313:2: warning: ‘strncat’ specified bound 4096
	equals destination size [-Wstringop-overflow=]

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfsidmap/umich_ldap.c | 4 ++--
 utils/idmapd/idmapd.c         | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/support/nfsidmap/umich_ldap.c b/support/nfsidmap/umich_ldap.c
index 0e31b1c..b661110 100644
--- a/support/nfsidmap/umich_ldap.c
+++ b/support/nfsidmap/umich_ldap.c
@@ -1125,9 +1125,9 @@ umichldap_init(void)
 
 	/* Verify required information is supplied */
 	if (server_in == NULL || strlen(server_in) == 0)
-		strncat(missing_msg, "LDAP_server ", sizeof(missing_msg));
+		strncat(missing_msg, "LDAP_server ", sizeof(missing_msg)-1);
 	if (ldap_info.base == NULL || strlen(ldap_info.base) == 0)
-		strncat(missing_msg, "LDAP_base ", sizeof(missing_msg));
+		strncat(missing_msg, "LDAP_base ", sizeof(missing_msg)-1);
 	if (strlen(missing_msg) != 0) {
 		IDMAP_LOG(0, ("umichldap_init: Missing required information: "
 			  "%s", missing_msg));
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 2585fb2..4811e0f 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -310,7 +310,7 @@ main(int argc, char **argv)
 	if (!serverstart && !clientstart)
 		errx(1, "it is illegal to specify both -C and -S");
 
-	strncat(pipefsdir, "/nfs", sizeof(pipefsdir));
+	strncat(pipefsdir, "/nfs", sizeof(pipefsdir)-1);
 
 	daemon_init(fg);
 
-- 
2.17.1

