Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.8 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBCADC433E0
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Feb 2021 19:42:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9600D64E45
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Feb 2021 19:42:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233410AbhBQTmj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Feb 2021 14:42:39 -0500
Received: from us-smtp-delivery-124.mimecast.com ([216.205.24.124]:41499 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S233086AbhBQTmi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Feb 2021 14:42:38 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1613590871;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=UW/mjyg9P3m9+N4g1ui63JbUez1D3GPttvIOY14nEUM=;
        b=boTzNjsl7DVCU3tUENPEGuSlFnoARvXa/MBZjU/smNe2mwJ5iNmgJWH/MiU6elwXaJf4/f
        1WffKXx/yJMXxXGhtGYGVltAGMqc5RbTzKKHknWRUVIZ5WFb2QmxsgJ14qAKkawZ/ZuUDZ
        7ucH+ecmplP+OdY7FCImM0D/fnEtoJs=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-409-uEpmc-V8MZKqax5SWD4Raw-1; Wed, 17 Feb 2021 14:41:07 -0500
X-MC-Unique: uEpmc-V8MZKqax5SWD4Raw-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 6A986107ACE6
        for <linux-nfs@vger.kernel.org>; Wed, 17 Feb 2021 19:41:06 +0000 (UTC)
Received: from madhat.home.dicksonnet.net (ovpn-112-108.phx2.redhat.com [10.3.112.108])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 2AC8918B5E
        for <linux-nfs@vger.kernel.org>; Wed, 17 Feb 2021 19:41:06 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 6/6] exportd: systemd unit files
Date:   Wed, 17 Feb 2021 14:42:40 -0500
Message-Id: <20210217194240.79915-7-steved@redhat.com>
In-Reply-To: <20210217194240.79915-1-steved@redhat.com>
References: <20210217194240.79915-1-steved@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Created two new systemd unit services
based on nfs-mountd and nfs-service

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 systemd/nfsv4-exportd.service | 12 ++++++++++++
 systemd/nfsv4-server.service  | 31 +++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)
 create mode 100644 systemd/nfsv4-exportd.service
 create mode 100644 systemd/nfsv4-server.service

diff --git a/systemd/nfsv4-exportd.service b/systemd/nfsv4-exportd.service
new file mode 100644
index 0000000..abf2f42
--- /dev/null
+++ b/systemd/nfsv4-exportd.service
@@ -0,0 +1,12 @@
+[Unit]
+Description=NFSv4 Mount Daemon
+DefaultDependencies=no
+Requires=proc-fs-nfsd.mount
+Wants=network-online.target
+After=proc-fs-nfsd.mount
+After=network-online.target local-fs.target
+BindsTo=nfsv4-server.service
+
+[Service]
+Type=forking
+ExecStart=/usr/sbin/exportd
diff --git a/systemd/nfsv4-server.service b/systemd/nfsv4-server.service
new file mode 100644
index 0000000..6497568
--- /dev/null
+++ b/systemd/nfsv4-server.service
@@ -0,0 +1,31 @@
+[Unit]
+Description=NFSv4 server and services
+DefaultDependencies=no
+Requires=network.target proc-fs-nfsd.mount
+Requires=nfsv4-exportd.service
+Wants=network-online.target
+Wants=nfs-idmapd.service
+Wants=nfsdcld.service
+
+After=network-online.target local-fs.target
+After=proc-fs-nfsd.mount nfsv4-exportd.service
+After=nfs-idmapd.service
+After=nfsdcld.service
+
+# GSS services dependencies and ordering
+Wants=auth-rpcgss-module.service
+After=rpc-gssd.service gssproxy.service rpc-svcgssd.service
+
+[Service]
+Type=oneshot
+RemainAfterExit=yes
+ExecStartPre=-/usr/sbin/exportfs -r
+ExecStart=/usr/sbin/rpc.nfsd -N 3
+ExecStop=/usr/sbin/rpc.nfsd 0
+ExecStopPost=/usr/sbin/exportfs -au
+ExecStopPost=/usr/sbin/exportfs -f
+
+ExecReload=-/usr/sbin/exportfs -r
+
+[Install]
+WantedBy=multi-user.target
-- 
2.29.2

