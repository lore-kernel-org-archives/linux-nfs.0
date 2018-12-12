Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B46EAC04EB8
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 13:52:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8103620839
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 13:52:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8103620839
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727578AbeLLNwC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 08:52:02 -0500
Received: from mx1.redhat.com ([209.132.183.28]:50630 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726232AbeLLNwC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 08:52:02 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7B9833082DDA;
        Wed, 12 Dec 2018 13:52:02 +0000 (UTC)
Received: from f27-node1.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 086AE1001F5B;
        Wed, 12 Dec 2018 13:52:01 +0000 (UTC)
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while handling TCP RST
Date:   Wed, 12 Dec 2018 08:51:57 -0500
Message-Id: <20181212135157.4489-2-dwysocha@redhat.com>
In-Reply-To: <20181212135157.4489-1-dwysocha@redhat.com>
References: <20181212135157.4489-1-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 12 Dec 2018 13:52:02 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Commit 9b30889c548a changed the handling of TCP_CLOSE inside
xs_tcp_state_change.  Prior to this change, the XPRT_CONNECTED bit
was cleared unconditionally inside xprt_disconnect_done, similar
to the handling of TCP_CLOSE_WAIT.  After the change the clearing
of XPRT_CONNECTED depends on successfully queueing a work based
xprt_autoclose which depends on XPRT_LOCKED and may not happen.
This is significant in the case of an unexpected RST from the
server, as the client will only see xs_tcp_state_change called with
sk_state == TCP_CLOSE.  Restore the unconditional clear_bit on
XPRT_CONNECTED while handling TCP_CLOSE and make it consistent
with handling TCP_CLOSE_WAIT.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 net/sunrpc/xprtsock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 8a5e823e0b33..b9789036051d 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1492,6 +1492,7 @@ static void xs_tcp_state_change(struct sock *sk)
 		if (sk->sk_err)
 			xprt_wake_pending_tasks(xprt, -sk->sk_err);
 		/* Trigger the socket release */
+		clear_bit(XPRT_CONNECTED, &xprt->state);
 		xs_tcp_force_close(xprt);
 	}
  out:
-- 
2.14.4

