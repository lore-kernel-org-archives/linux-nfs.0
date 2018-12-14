Return-Path: <SRS0=hAdq=OX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 425B6C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 18:29:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 92233206C2
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 18:29:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729707AbeLNS35 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Dec 2018 13:29:57 -0500
Received: from mx1.redhat.com ([209.132.183.28]:45130 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728388AbeLNS35 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Dec 2018 13:29:57 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6EAD47D0F8;
        Fri, 14 Dec 2018 18:29:57 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 4AFD36312F;
        Fri, 14 Dec 2018 18:29:57 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id F00E320688; Fri, 14 Dec 2018 13:29:56 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] sunrpc: Be sure to clear XPRT_WRITE_SPACE when resetting the transport
Date:   Fri, 14 Dec 2018 13:29:56 -0500
Message-Id: <20181214182956.14643-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Fri, 14 Dec 2018 18:29:57 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Otherwise no RPC tasks will be able to lock the transport and will
therefore be unable to connect it either.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 net/sunrpc/xprtsock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8a5e823e0b33..bbe06e3cc853 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1157,6 +1157,7 @@ static void xs_sock_reset_connection_flags(struct rpc_xprt *xprt)
 	smp_mb__before_atomic();
 	clear_bit(XPRT_CLOSE_WAIT, &xprt->state);
 	clear_bit(XPRT_CLOSING, &xprt->state);
+	clear_bit(XPRT_WRITE_SPACE, &xprt->state);
 	xs_sock_reset_state_flags(xprt);
 	smp_mb__after_atomic();
 }
-- 
2.17.1

