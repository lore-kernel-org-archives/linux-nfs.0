Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76B5FC43444
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 15:56:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 445DA2145D
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 15:56:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727833AbeLQP4s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 10:56:48 -0500
Received: from mxout3.mail.janestreet.com ([38.105.200.229]:41086 "EHLO
        mxout3.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S2387635AbeLQP4s (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 10:56:48 -0500
X-JS-Received: from [30.40.81.8] (helo=tot-qpr-mailcore1)
        by mxout3.mail.janestreet.com with esmtps (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
        (Exim 4.90_1)
        (envelope-from <cperl@janestreet.com>)
        id 1gYvGB-0008Rn-O0
        for linux-nfs@vger.kernel.org; Mon, 17 Dec 2018 10:56:47 -0500
X-JS-Flow: external
X-JS-Scanner-attachment: No attachments
X-JS-Scanner-esets: Not scanned (internal mail)
X-JS-Received: by tot-qpr-mailcore1 with ocaml/mailcore/main_production (71f307ccacc9)
        (envelope-from <cperl@janestreet.com>)
        id BcF8c_-M6jmcA-WM; 2018-12-17 10:56:47.723774-05:00
X-JS-Received: by igm-qpr-mailgw1 with ocaml/mailcore/main_gateway (4c95f7dcd125)
        (envelope-from <cperl@janestreet.com>)
        id BcF8c_-M9XcgA-V3; 2018-12-17 10:56:47.702532-05:00
X-JS-Received: from cperl by igm-qws-u12114b.delacy.com with local (Exim 4.91)
        (envelope-from <cperl@janestreet.com>)
        id 1gYvGB-00084m-LV; Mon, 17 Dec 2018 10:56:47 -0500
From:   Chris Perl <cperl@janestreet.com>
To:     linux-nfs@vger.kernel.org
Cc:     Chris Perl <cperl@janestreet.com>
Subject: [PATCH V2 1/1] NFS: nfs_compare_mount_options always compare auth flavors.
Date:   Mon, 17 Dec 2018 10:56:38 -0500
Message-Id: <20181217155638.30975-2-cperl@janestreet.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20181217155638.30975-1-cperl@janestreet.com>
References: <20181217155638.30975-1-cperl@janestreet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-JS-Region: Americas
X-JS-Processed-by: mailcore
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This patch removes the check from nfs_compare_mount_options to see if a
`sec' option was passed for the current mount before comparing auth
flavors and instead just always compares auth flavors.

Consider the following scenario:

You have a server with the address 192.168.1.1 and two exports /export/a
and /export/b.  The first export supports `sys' and `krb5' security, the
second just `sys'.

Assume you start with no mounts from the server.

The following results in EIOs being returned as the kernel nfs client
incorrectly thinks it can share the underlying `struct nfs_server's:

$ mkdir /tmp/{a,b}
$ sudo mount -t nfs -o vers=3,sec=krb5 192.168.1.1:/export/a /tmp/a
$ sudo mount -t nfs -o vers=3          192.168.1.1:/export/b /tmp/b
$ df >/dev/null
df: ‘/tmp/b’: Input/output error

Signed-off-by: Chris Perl <cperl@janestreet.com>
---
 fs/nfs/super.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index ac4b2f005778..5ef2c71348bd 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2409,8 +2409,7 @@ static int nfs_compare_mount_options(const struct super_block *s, const struct n
 		goto Ebusy;
 	if (a->acdirmax != b->acdirmax)
 		goto Ebusy;
-	if (b->auth_info.flavor_len > 0 &&
-	   clnt_a->cl_auth->au_flavor != clnt_b->cl_auth->au_flavor)
+	if (clnt_a->cl_auth->au_flavor != clnt_b->cl_auth->au_flavor)
 		goto Ebusy;
 	return 1;
 Ebusy:
-- 
2.17.1

