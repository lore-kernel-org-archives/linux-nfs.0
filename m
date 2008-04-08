From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH] gssd: add other des encryption types to default list
Date: Tue, 08 Apr 2008 11:31:33 -0400
Message-ID: <20080408153133.17749.60365.stgit@RoCK.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: SteveD@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:24090 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751318AbYDHPbd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Apr 2008 11:31:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kevin Coffman <kwc@citi.umich.edu>

Add the other two DES encryption types to the default list of
Kerberos encryption types that may be negotiated.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/krb5_util.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)


diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 3cf27ca..0589cd8 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -277,7 +277,9 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
 	u_int maj_stat, min_stat;
 	gss_cred_id_t credh;
 	gss_OID_set_desc  desired_mechs;
-	krb5_enctype enctypes[] = { ENCTYPE_DES_CBC_CRC };
+	krb5_enctype enctypes[] = { ENCTYPE_DES_CBC_CRC,
+				    ENCTYPE_DES_CBC_MD5,
+				    ENCTYPE_DES_CBC_MD4 };
 	int num_enctypes = sizeof(enctypes) / sizeof(enctypes[0]);
 
 	/* We only care about getting a krb5 cred */

