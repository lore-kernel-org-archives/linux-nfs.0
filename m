From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] rpc.gssd: Don't supply the KDC with unsupported encryption
 types
Date: Tue, 11 Nov 2008 11:40:28 -0500
Message-ID: <4919B57C.6050104@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35763 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751463AbYKKQmX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2008 11:42:23 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mABGgMxA026767
	for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2008 11:42:22 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mABGgMfU017855
	for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2008 11:42:22 -0500
Received: from [10.16.10.81] (vpn-10-81.bos.redhat.com [10.16.10.81])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mABGgLrf032479
	for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2008 11:42:21 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

It seems when rpc.gssd initially registers with the KDC, it sends 
a long list of encryption types that are not supported:

      Encryption Types: aes256-cts-hmac-sha1-96 aes128-cts-hmac-sha1-96 des3-cbc-sha1 
                        rc4-hmac des-cbc-crc des-cbc-md5 des-cbc-md4 rsa-sha1-cms 
                        rsa-md5-cms des-ede3-cbc-env rc2-cbc-env rsa-env

Now the theory is mounts will hang if the KDC (like a Solaris KDC) returns an unsupported 
encryption type since the client will not know what to do with it. I'm currently
trying to test this theory with people that actually have a working Solaris KDC,
unfortunately I'm not one of those people... 

But to me, it just makes sense that rpc.gssd should only talk about encryption types
it supports. It seems like it would cuts out any and all confusion.The following 
patch does just that. 

comments?

steved.


Author: Steve Dickson <steved@redhat.com>
Date:   Tue Nov 11 11:08:13 EST 2008
	
	When rpc.gssd registers with the KDC, only talk
	about the supported encryption types during the
	initial registration so the KDC will only 
	return supported encryption types.

	Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 77814bc..7f131c9 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -125,6 +125,10 @@
 
 /* Global list of principals/cache file names for machine credentials */
 struct gssd_k5_kt_princ *gssd_k5_kt_princ_list = NULL;
+static krb5_enctype enctypes[] = { ENCTYPE_DES_CBC_CRC,
+				    ENCTYPE_DES_CBC_MD5,
+				    ENCTYPE_DES_CBC_MD4 };
+static int num_enctypes = sizeof(enctypes) / sizeof(enctypes[0]);
 
 /*==========================*/
 /*===  Internal routines ===*/
@@ -309,10 +313,6 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid)
 	u_int maj_stat, min_stat;
 	gss_cred_id_t credh;
 	gss_OID_set_desc  desired_mechs;
-	krb5_enctype enctypes[] = { ENCTYPE_DES_CBC_CRC,
-				    ENCTYPE_DES_CBC_MD5,
-				    ENCTYPE_DES_CBC_MD4 };
-	int num_enctypes = sizeof(enctypes) / sizeof(enctypes[0]);
 
 	/* We only care about getting a krb5 cred */
 	desired_mechs.count = 1;
@@ -412,6 +412,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 
 	krb5_get_init_creds_opt_init(&options);
 	krb5_get_init_creds_opt_set_address_list(&options, NULL);
+	krb5_get_init_creds_opt_set_etype_list(&options, enctypes, num_enctypes);
 #ifdef TEST_SHORT_LIFETIME
 	/* set a short lifetime (for debugging only!) */
 	printerr(0, "WARNING: Using (debug) short machine cred lifetime!\n");
