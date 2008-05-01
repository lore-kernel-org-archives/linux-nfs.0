From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 2/4] gssd: add other des encryption types to default list
Date: Thu, 01 May 2008 09:35:05 -0400
Message-ID: <20080501133505.28884.30497.stgit@jazz.citi.umich.edu>
References: <20080501133455.28884.4768.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:42952 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754055AbYEANfG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2008 09:35:06 -0400
In-Reply-To: <20080501133455.28884.4768.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

