Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78525C10F11
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:07:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 458D32087E
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:07:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731779AbfCZWHc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 18:07:32 -0400
Received: from mx1.redhat.com ([209.132.183.28]:46776 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731491AbfCZWHb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 18:07:31 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C968730FD84B;
        Tue, 26 Mar 2019 22:07:31 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-200.rdu2.redhat.com [10.10.122.200])
        by smtp.corp.redhat.com (Postfix) with ESMTP id A9CCC5D6A9;
        Tue, 26 Mar 2019 22:07:31 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id E496321349; Tue, 26 Mar 2019 18:07:30 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     bfields@fieldses.org, jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH RFC v3 7/8] systemd: add a unit file for nfsdcld
Date:   Tue, 26 Mar 2019 18:07:29 -0400
Message-Id: <20190326220730.3763-8-smayhew@redhat.com>
In-Reply-To: <20190326220730.3763-1-smayhew@redhat.com>
References: <20190326220730.3763-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Tue, 26 Mar 2019 22:07:31 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 systemd/nfs-server.service |  2 ++
 systemd/nfsdcld.service    | 10 ++++++++++
 2 files changed, 12 insertions(+)
 create mode 100644 systemd/nfsdcld.service

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 136552b..24118d6 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -6,10 +6,12 @@ Requires= nfs-mountd.service
 Wants=rpcbind.socket network-online.target
 Wants=rpc-statd.service nfs-idmapd.service
 Wants=rpc-statd-notify.service
+Wants=nfsdcld.service
 
 After= network-online.target local-fs.target
 After= proc-fs-nfsd.mount rpcbind.socket nfs-mountd.service
 After= nfs-idmapd.service rpc-statd.service
+After= nfsdcld.service
 Before= rpc-statd-notify.service
 
 # GSS services dependencies and ordering
diff --git a/systemd/nfsdcld.service b/systemd/nfsdcld.service
new file mode 100644
index 0000000..a32d243
--- /dev/null
+++ b/systemd/nfsdcld.service
@@ -0,0 +1,10 @@
+[Unit]
+Description=NFSv4 Client Tracking Daemon
+DefaultDependencies=no
+Conflicts=umount.target
+Requires=rpc_pipefs.target proc-fs-nfsd.mount
+After=rpc_pipefs.target proc-fs-nfsd.mount
+
+[Service]
+Type=forking
+ExecStart=/usr/sbin/nfsdcld
-- 
2.17.2

