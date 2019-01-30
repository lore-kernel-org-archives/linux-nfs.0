Return-Path: <SRS0=/R4e=QG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E501EC282D7
	for <linux-nfs@archiver.kernel.org>; Wed, 30 Jan 2019 13:58:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BAE552184D
	for <linux-nfs@archiver.kernel.org>; Wed, 30 Jan 2019 13:58:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727740AbfA3N6u (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 30 Jan 2019 08:58:50 -0500
Received: from out03.mta.xmission.com ([166.70.13.233]:53361 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727149AbfA3N6t (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jan 2019 08:58:49 -0500
Received: from in01.mta.xmission.com ([166.70.13.51])
        by out03.mta.xmission.com with esmtps (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1goqO7-0007hG-Cg; Wed, 30 Jan 2019 06:58:47 -0700
Received: from ip68-227-174-240.om.om.cox.net ([68.227.174.240] helo=x220.xmission.com)
        by in01.mta.xmission.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
        (Exim 4.87)
        (envelope-from <ebiederm@xmission.com>)
        id 1goqO6-00056S-HH; Wed, 30 Jan 2019 06:58:47 -0700
From:   ebiederm@xmission.com (Eric W. Biederman)
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org, <linux-fsdevel@vger.kernel.org>
Date:   Wed, 30 Jan 2019 07:58:38 -0600
Message-ID: <87fttap7qp.fsf@xmission.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/25.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-XM-SPF: eid=1goqO6-00056S-HH;;;mid=<87fttap7qp.fsf@xmission.com>;;;hst=in01.mta.xmission.com;;;ip=68.227.174.240;;;frm=ebiederm@xmission.com;;;spf=neutral
X-XM-AID: U2FsdGVkX18Sc9JFECJKf8fZBQjsW06p99ksyApBqUo=
X-SA-Exim-Connect-IP: 68.227.174.240
X-SA-Exim-Mail-From: ebiederm@xmission.com
Subject: [PATCH] fs/nfs: Fix nfs_parse_devname to not modify it's argument
X-SA-Exim-Version: 4.2.1 (built Thu, 05 May 2016 13:38:54 -0600)
X-SA-Exim-Scanned: Yes (on in01.mta.xmission.com)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


In the rare and unsupported case of a hostname list nfs_parse_devname
will modify dev_name.  There is no need to modify dev_name as the all
that is being computed is the length of the hostname, so the computed
length can just be shorted.

Fixes: dc04589827f7 ("NFS: Use common device name parsing logic for NFSv4 and NFSv2/v3")
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 fs/nfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 22ce3c8a2f46..35af005af748 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1914,7 +1914,7 @@ static int nfs_parse_devname(const char *dev_name,
 		/* kill possible hostname list: not supported */
 		comma = strchr(dev_name, ',');
 		if (comma != NULL && comma < end)
-			*comma = 0;
+			len = comma - dev_name;
 	}
 
 	if (len > maxnamlen)
-- 
2.17.1

