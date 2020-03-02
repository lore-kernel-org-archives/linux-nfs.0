Return-Path: <SRS0=kaop=4T=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 554E8C3F2D2
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Mar 2020 14:09:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3278E21556
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Mar 2020 14:09:07 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726884AbgCBOJG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 2 Mar 2020 09:09:06 -0500
Received: from mx2.suse.de ([195.135.220.15]:34888 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726878AbgCBOJG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Mar 2020 09:09:06 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 054FFB011;
        Mon,  2 Mar 2020 14:09:05 +0000 (UTC)
From:   Petr Vorel <pvorel@suse.cz>
To:     linux-nfs@vger.kernel.org
Cc:     Petr Vorel <pvorel@suse.cz>, Steve Dickson <steved@redhat.com>
Subject: [nfs-utils PATCH 1/1] error.c: Put string for EOPNOTSUPP on single line
Date:   Mon,  2 Mar 2020 15:08:55 +0100
Message-Id: <20200302140855.19453-1-pvorel@suse.cz>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

to help people find it when search for common NFS error:
mount.nfs: requested NFS version or transport protocol is not supported

Signed-off-by: Petr Vorel <pvorel@suse.cz>
---
 utils/mount/error.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/utils/mount/error.c b/utils/mount/error.c
index 986f0660..73295bf0 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -210,8 +210,7 @@ void mount_error(const char *spec, const char *mount_point, int error)
 		nfs_error(_("%s: an incorrect mount option was specified"), progname);
 		break;
 	case EOPNOTSUPP:
-		nfs_error(_("%s: requested NFS version or transport"
-				" protocol is not supported"),
+		nfs_error(_("%s: requested NFS version or transport protocol is not supported"),
 				progname);
 		break;
 	case ENOTDIR:
-- 
2.25.1

