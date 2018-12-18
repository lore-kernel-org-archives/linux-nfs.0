Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A355C43444
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EDD9C21873
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726751AbeLROaU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:30:20 -0500
Received: from mx1.redhat.com ([209.132.183.28]:53872 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726426AbeLROaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:30:19 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B60AAD56F5;
        Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 952FB17B57;
        Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id A0833229E3; Tue, 18 Dec 2018 09:30:18 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 7/7] systemd: add a unit file for nfsdcld
Date:   Tue, 18 Dec 2018 09:30:18 -0500
Message-Id: <20181218143018.28575-8-smayhew@redhat.com>
In-Reply-To: <20181218143018.28575-1-smayhew@redhat.com>
References: <20181218143018.28575-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 systemd/nfs-server.service |  2 ++
 systemd/nfsdcld.service    | 11 +++++++++++
 2 files changed, 13 insertions(+)
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
index 0000000..0ed6921
--- /dev/null
+++ b/systemd/nfsdcld.service
@@ -0,0 +1,11 @@
+[Unit]
+Description=NFSv4 Client Tracking Daemon
+DefaultDependencies=no
+Conflicts=umount.target
+Requires=rpc_pipefs.target proc-fs-nfsd.mount
+After=rpc_pipefs.target proc-fs-nfsd.mount
+ConditionPathExists=|!/var/lib/nfs/v4recovery
+
+[Service]
+Type=forking
+ExecStart=/usr/sbin/nfsdcld
-- 
2.17.1

