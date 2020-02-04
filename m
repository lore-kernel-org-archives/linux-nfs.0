Return-Path: <SRS0=C+as=3Y=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5D93C2D0B1
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Feb 2020 10:33:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B1C8D20674
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Feb 2020 10:33:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="DePJKMfg"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726864AbgBDKdE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Feb 2020 05:33:04 -0500
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:43729 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1726631AbgBDKdE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Feb 2020 05:33:04 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1580812383;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=w81XveLRIk07zYgCspgiGg6WMrOtuh9MOpXguHaH4po=;
        b=DePJKMfgVS5+p+8oCG7LhNTLIxwPAa4t6fwr1vLGRafT3F/+3NtumiKvfyaz74It+LRIah
        hNteX3nZ6BhU2r04BKb6vAkK/zzXfcpygpH7rnLcTtlPVe7wMCdz2MmnoE4FuUI3Hu9iNt
        YiFxshIarOAaYT6ZLu+CuifO7Eng6DU=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-283-GiT5QarXPL-pHKIcdz25VA-1; Tue, 04 Feb 2020 05:33:01 -0500
X-MC-Unique: GiT5QarXPL-pHKIcdz25VA-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 04CCB1083E80;
        Tue,  4 Feb 2020 10:32:59 +0000 (UTC)
Received: from idlethread.redhat.com (ovpn-116-72.ams2.redhat.com [10.36.116.72])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E5992171EB;
        Tue,  4 Feb 2020 10:32:57 +0000 (UTC)
From:   Roberto Bergantinos Corpas <rbergant@redhat.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org, arnd@arndb.de
Subject: [PATCH] sunrpc: expiry_time should be seconds not timeval
Date:   Tue,  4 Feb 2020 11:32:56 +0100
Message-Id: <20200204103256.16131-1-rbergant@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When upcalling gssproxy, cache_head.expiry_time is set as a
timeval, not seconds since boot. As such, RPC cache expiry
logic will not clean expired objects created under
auth.rpcsec.context cache.

This has proven to cause kernel memory leaks on field. Using
64 bit variants of getboottime/timespec

Signed-off-by: Roberto Bergantinos Corpas <rbergant@redhat.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svca=
uth_gss.c
index 7511a68aadf0..65b67b257302 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1248,6 +1248,7 @@ static int gss_proxy_save_rsc(struct cache_detail *=
cd,
 		dprintk("RPC:       No creds found!\n");
 		goto out;
 	} else {
+		struct timespec64 boot;
=20
 		/* steal creds */
 		rsci.cred =3D ud->creds;
@@ -1268,6 +1269,9 @@ static int gss_proxy_save_rsc(struct cache_detail *=
cd,
 						&expiry, GFP_KERNEL);
 		if (status)
 			goto out;
+
+		getboottime64(&boot);
+		expiry -=3D boot.tv_sec;
 	}
=20
 	rsci.h.expiry_time =3D expiry;
--=20
2.21.0

