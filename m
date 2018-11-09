Return-Path: <SRS0=AoDj=NU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AE08C43441
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 09:08:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 584E920855
	for <linux-nfs@archiver.kernel.org>; Fri,  9 Nov 2018 09:08:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 584E920855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=janestreet.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727863AbeKISsW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 9 Nov 2018 13:48:22 -0500
Received: from mxout3.mail.janestreet.com ([38.105.200.229]:49181 "EHLO
        mxout3.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1727603AbeKISsW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Nov 2018 13:48:22 -0500
X-Greylist: delayed 343 seconds by postgrey-1.27 at vger.kernel.org; Fri, 09 Nov 2018 13:48:21 EST
X-JS-Received: from [30.40.81.8] (helo=tot-qpr-mailcore1)
        by mxout3.mail.janestreet.com with esmtps (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
        (Exim 4.90_1)
        (envelope-from <cperl@janestreet.com>)
        id 1gL2gw-0001JO-MT
        for linux-nfs@vger.kernel.org; Fri, 09 Nov 2018 04:03:02 -0500
X-JS-Flow: external
X-JS-Scanner-attachment: No attachments
X-JS-Scanner-esets: Not scanned (internal mail)
X-JS-Received: by tot-qpr-mailcore1 with ocaml/mailcore/main_production (0b106697a407)
        (envelope-from <cperl@janestreet.com>)
        id Bb5U1G-bIN7YA-Ux; 2018-11-09 04:03:02.673946-05:00
X-JS-Received: by igm-qpr-mailgw2 with ocaml/mailcore/main_gateway (1e9cb192eda3)
        (envelope-from <cperl@janestreet.com>)
        id Bb5U1G-g9e20A-Um; 2018-11-09 04:03:02.660920-05:00
X-JS-Received: from cperl by igm-qws-u12114b.delacy.com with local (Exim 4.90_1)
        (envelope-from <cperl@janestreet.com>)
        id 1gL2gw-0003hO-Jh; Fri, 09 Nov 2018 04:03:02 -0500
From:   Chris Perl <cperl@janestreet.com>
To:     linux-nfs@vger.kernel.org
Cc:     Chris Perl <cperl@janestreet.com>
Subject: [PATCH 1/1] NFS: nfs_compare_mount_options always compare auth flavors.
Date:   Fri,  9 Nov 2018 04:02:51 -0500
Message-Id: <20181109090251.14145-2-cperl@janestreet.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20181109090251.14145-1-cperl@janestreet.com>
References: <20181109090251.14145-1-cperl@janestreet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-JS-Region: Americas
X-JS-Processed-by: mailcore
X-Sender-Copy: hkg-copy
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

