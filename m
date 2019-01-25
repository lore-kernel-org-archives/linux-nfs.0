Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C61DC282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 08:33:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7051B21915
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 08:33:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726402AbfAYIdM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 03:33:12 -0500
Received: from mx1.redhat.com ([209.132.183.28]:35284 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726200AbfAYIdM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Jan 2019 03:33:12 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4DE2F806A6;
        Fri, 25 Jan 2019 08:33:12 +0000 (UTC)
Received: from localhost (dhcp-12-206.nay.redhat.com [10.66.12.206])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AFA5B5D787;
        Fri, 25 Jan 2019 08:33:11 +0000 (UTC)
From:   Yongcheng Yang <yongcheng.yang@gmail.com>
To:     Steve Dickson <steved@redhat.com>
Cc:     linux-nfs@vger.kernel.org,
        Yongcheng Yang <yongcheng.yang@gmail.com>
Subject: [PATCH] systemd: rpc_pipefs.target use BindsTo= instead of Requires=
Date:   Fri, 25 Jan 2019 16:33:02 +0800
Message-Id: <20190125083302.3346-1-yongcheng.yang@gmail.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 25 Jan 2019 08:33:12 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The rpc_pipefs.target should enter inactive state if
var-lib-nfs-rpc_pipefs.mount is stopped. Otherwise,
services depending rpc_pipefs.target (e.g. nfs-idmapd)
fail to start after /var/lib/nfs/rpc_pipefs unmounted

Signed-off-by: Yongcheng Yang <yongcheng.yang@gmail.com>
---

Reproducing steps:
$ systemctl stop nfs-idmapd
$ umount /var/lib/nfs/rpc_pipefs
$ systemctl start nfs-idmapd

Thanks,
Yongcheng

 systemd/rpc_pipefs.target | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/systemd/rpc_pipefs.target b/systemd/rpc_pipefs.target
index 01d4d27..5ce3981 100644
--- a/systemd/rpc_pipefs.target
+++ b/systemd/rpc_pipefs.target
@@ -1,3 +1,3 @@
 [Unit]
-Requires=var-lib-nfs-rpc_pipefs.mount
+BindsTo=var-lib-nfs-rpc_pipefs.mount
 After=var-lib-nfs-rpc_pipefs.mount
-- 
2.17.2

