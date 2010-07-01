Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:36670 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491Ab0GABE0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jun 2010 21:04:26 -0400
Received: by iwn7 with SMTP id 7so1456420iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jun 2010 18:04:26 -0700 (PDT)
Message-ID: <4C2BE997.8090808@gmail.com>
Date: Wed, 30 Jun 2010 21:04:23 -0400
From: Doug Nazar <nazard.michi@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: Fix endtime issue
Content-Type: multipart/mixed;
 boundary="------------040403000103010309080206"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------040403000103010309080206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

  After finally tracking down an issue with rpc.gssd crashing which had 
been bugging me on and off for months, ran into another issue.

Commit 4c5ff6d4 removed the setting of endtime for a few contexts by 
accident.

Now to figure out why I get stale handles on submounts.

Doug



--------------040403000103010309080206
Content-Type: text/plain;
 name="nfs-utils-endtime.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="nfs-utils-endtime.diff"

commit 3e4355dd4a31ee8577620b8b93cd5a811cdcaa7c
Author: Doug Nazar <nazard.michi@gmail.com>
Date:   Wed Jun 30 15:49:39 2010 -0400

    Return correct context endtime for lucid rfc4121 and mit.

diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index b87bf76..2108487 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -202,6 +202,8 @@ prepare_krb5_rfc4121_buffer(gss_krb5_lucid_context_v1_t *lctx,
 
 	if (WRITE_BYTES(&p, end, v2_flags)) goto out_err;
 	if (WRITE_BYTES(&p, end, lctx->endtime)) goto out_err;
+	if (endtime)
+		*endtime = lctx->endtime;
 	if (WRITE_BYTES(&p, end, lctx->send_seq)) goto out_err;
 
 	/* Protocol 0 here implies DES3 or RC4 */
diff --git a/utils/gssd/context_mit.c b/utils/gssd/context_mit.c
index f9cbb02..e6db9cb 100644
--- a/utils/gssd/context_mit.c
+++ b/utils/gssd/context_mit.c
@@ -191,6 +191,8 @@ serialize_krb5_ctx(gss_ctx_id_t ctx, gss_buffer_desc *buf, int32_t *endtime)
 		if (WRITE_BYTES(&p, end, kctx->signalg)) goto out_err;
 		if (WRITE_BYTES(&p, end, kctx->sealalg)) goto out_err;
 		if (WRITE_BYTES(&p, end, kctx->endtime)) goto out_err;
+		if (endtime)
+			*endtime = kctx->endtime;
 		word_seq_send = kctx->seq_send;
 		if (WRITE_BYTES(&p, end, word_seq_send)) goto out_err;
 		if (write_oid(&p, end, kctx->mech_used)) goto out_err;

--------------040403000103010309080206--
