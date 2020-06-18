Return-Path: <SRS0=2npy=77=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A1C5C433DF
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Jun 2020 02:34:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4FB1221D7B
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Jun 2020 02:34:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1592447690;
	bh=I7lrDgX+/dYihaZrCBL/HRmqYsW2j58TD+WKc2+agI4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=CzbH2IDZMwGqmdylYYoCzVUsIPuNazNfyL9JtwaE2ohxea0vvNU9zkzHTWJV+fF1u
	 HuW2Tq+F84InbtQilcxxq9RnEAepStqqLA11TXMjCGkxoz5q97+XPJIV4eBlQPF6OK
	 CRFVEyc8dGeym20KLWIFYjXVtoNbSCICCvdI+2JE=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729443AbgFRCek (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 17 Jun 2020 22:34:40 -0400
Received: from mail.kernel.org ([198.145.29.99]:44086 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729310AbgFRBO3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Jun 2020 21:14:29 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D16CB221F0;
        Thu, 18 Jun 2020 01:14:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1592442868;
        bh=I7lrDgX+/dYihaZrCBL/HRmqYsW2j58TD+WKc2+agI4=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=e41xJZkDr9ZqS5zup7tmir7HM5NCxGevsBudx8LkHniWfmJvsCe+SC1S2U5qvpTLV
         CgnYs8l3hC8mZhnNnO8YKKhU6SXocmDIxM1gJojdNRmrlVX7xRJufgs66c/p8+OLO0
         Ly/NRmcHTqDfY/NqKYFZpMVNM6SxGp10e1gZw2nE=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Fedor Tokarev <ftokarev@gmail.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH AUTOSEL 5.7 295/388] net: sunrpc: Fix off-by-one issues in 'rpc_ntop6'
Date:   Wed, 17 Jun 2020 21:06:32 -0400
Message-Id: <20200618010805.600873-295-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200618010805.600873-1-sashal@kernel.org>
References: <20200618010805.600873-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Fedor Tokarev <ftokarev@gmail.com>

[ Upstream commit 118917d696dc59fd3e1741012c2f9db2294bed6f ]

Fix off-by-one issues in 'rpc_ntop6':
 - 'snprintf' returns the number of characters which would have been
   written if enough space had been available, excluding the terminating
   null byte. Thus, a return value of 'sizeof(scopebuf)' means that the
   last character was dropped.
 - 'strcat' adds a terminating null byte to the string, thus if len ==
   buflen, the null byte is written past the end of the buffer.

Signed-off-by: Fedor Tokarev <ftokarev@gmail.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/addr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 8b4d72b1a066..010dcb876f9d 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -82,11 +82,11 @@ static size_t rpc_ntop6(const struct sockaddr *sap,
 
 	rc = snprintf(scopebuf, sizeof(scopebuf), "%c%u",
 			IPV6_SCOPE_DELIMITER, sin6->sin6_scope_id);
-	if (unlikely((size_t)rc > sizeof(scopebuf)))
+	if (unlikely((size_t)rc >= sizeof(scopebuf)))
 		return 0;
 
 	len += rc;
-	if (unlikely(len > buflen))
+	if (unlikely(len >= buflen))
 		return 0;
 
 	strcat(buf, scopebuf);
-- 
2.25.1

