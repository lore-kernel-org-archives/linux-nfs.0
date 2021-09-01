Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.8 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2088C432BE
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Sep 2021 23:30:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9B1926102A
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Sep 2021 23:30:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233654AbhIAXbm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 1 Sep 2021 19:31:42 -0400
Received: from smtp-out2.suse.de ([195.135.220.29]:50968 "EHLO
        smtp-out2.suse.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230061AbhIAXbm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Sep 2021 19:31:42 -0400
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id 22ABB1FF46;
        Wed,  1 Sep 2021 23:30:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1630539044; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding;
        bh=D1zCUw/WwOnRTS+qsSk3F8pp29G5w0IrcvyeqCJc1+g=;
        b=FvGjD0i0yybs6AnZEitcDrIhrrU9L58KJcQva+LuWnIRakbNm1Pxuw28ctqvum5VzOMWRI
        AWTdJrU60KWLxOiiU0tddamLG+9JiJg/o3pSIy/ncmjLBR1IJrPoFLkgfxEnDD2REKtX+1
        CD0wkhwmP48Rqs2LxQvbYR3hQHG2vP0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1630539044;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding;
        bh=D1zCUw/WwOnRTS+qsSk3F8pp29G5w0IrcvyeqCJc1+g=;
        b=zWJxhDQYtaQ3yNcjf+7P9gIqTE9tdEI2uRSvf1Rqa5sTP1cq6cMjK4C4LdW/+74HD7f2N8
        voFmOM0UpdMqb6Cw==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 7629C13B2A;
        Wed,  1 Sep 2021 23:30:41 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id AYYBDSENMGGDNAAAMHmgww
        (envelope-from <neilb@suse.de>); Wed, 01 Sep 2021 23:30:41 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "J.  Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS list <linux-nfs@vger.kernel.org>,
        "Steinar H. Gunderson" <steinar+kernel@gunderson.no>
Subject: [PATCH] SUNRPC: improve error response to over-size gss credential
Date:   Thu, 02 Sep 2021 09:30:37 +1000
Message-id: <163053903731.24419.4079441567942239288@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


When the NFS server receives a large gss (kerberos) credential and tries
to pass it up to rpc.svcgssd (which is deprecated), it triggers an
infinite loop in cache_read().

cache_request() always returns -EAGAIN, and this causes a "goto again".

This patch:
 - changes the error to -E2BIG to avoid the infinite loop, and
 - generates a WARN_ONCE when rsi_request first sees an over-sized
   credential.  The warning suggests switching to gssproxy.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=3D196583
Signed-off-by: NeilBrown <neilb@suse.de>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 2 ++
 net/sunrpc/cache.c                | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_=
gss.c
index a81be45f40d9..e738c0182f09 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -194,6 +194,8 @@ static void rsi_request(struct cache_detail *cd,
 	qword_addhex(bpp, blen, rsii->in_handle.data, rsii->in_handle.len);
 	qword_addhex(bpp, blen, rsii->in_token.data, rsii->in_token.len);
 	(*bpp)[-1] =3D '\n';
+	WARN_ONCE(*blen < 0,
+		  "RPCSEC/GSS credential too large - please use gssproxy\n");
 }
=20
 static int rsi_parse(struct cache_detail *cd,
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 1a2c1c44bb00..59641803472c 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -803,7 +803,7 @@ static int cache_request(struct cache_detail *detail,
=20
 	detail->cache_request(detail, crq->item, &bp, &len);
 	if (len < 0)
-		return -EAGAIN;
+		return -E2BIG;
 	return PAGE_SIZE - len;
 }
=20
--=20
2.32.0

