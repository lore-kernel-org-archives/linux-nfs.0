Return-Path: <SRS0=moqZ=QE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD527C282C8
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 16:29:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7112C20663
	for <linux-nfs@archiver.kernel.org>; Mon, 28 Jan 2019 16:29:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548692990;
	bh=sZBgL3leavroMWhZR9KkNWedrgWFMKS2TesS6xHC8Xg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=XyygXASGACJeBC1HlHlUAAxCjc7t1FgyGo56PYPiRcUZTU96+IQ02VW6xrNq70IcU
	 HSVyWRBq4FUsIfrqbXVfqciX7GHwe/NwJjH5d+fwMwmwnaQcn/mGbk+DaHSENxntJy
	 7dVuksOro5ZsoGOC9xU/HgmI+9sWIvcP3u+Qx/7k=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732364AbfA1Q3n (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 28 Jan 2019 11:29:43 -0500
Received: from mail.kernel.org ([198.145.29.99]:38050 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388171AbfA1Q1q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 28 Jan 2019 11:27:46 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 090D62147A;
        Mon, 28 Jan 2019 16:27:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1548692865;
        bh=sZBgL3leavroMWhZR9KkNWedrgWFMKS2TesS6xHC8Xg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=gE/olrHdLADSMAQBDG+rhQ8VgLqdi57vE8l0k39ihbU9vKkQQiJmuN5fPv/gnl2MQ
         txFV9WCXPVTE9BrgFMdCpYQzwxa5kgzcdVP8W7n/pC5gy5VjCmnDLfvo3E1vEbvzPl
         JXJEti7+FUQEP9YpOeVno9KcB6Oy7UkcYqty6N/0=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Chris Perl <cperl@janestreet.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 3.18 46/61] NFS: nfs_compare_mount_options always compare auth flavors.
Date:   Mon, 28 Jan 2019 11:26:08 -0500
Message-Id: <20190128162623.59854-46-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190128162623.59854-1-sashal@kernel.org>
References: <20190128162623.59854-1-sashal@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chris Perl <cperl@janestreet.com>

[ Upstream commit 594d1644cd59447f4fceb592448d5cd09eb09b5e ]

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
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/super.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index dbdc2d2f91cf..655ac3a196e4 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2376,8 +2376,7 @@ static int nfs_compare_mount_options(const struct super_block *s, const struct n
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
2.19.1

