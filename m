Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FCFAC04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 19:25:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F39D8206B7
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 19:25:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n9JuMM04"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F39D8206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725867AbeLDTZt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 14:25:49 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:35081 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725831AbeLDTZt (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 14:25:49 -0500
Received: by mail-it1-f196.google.com with SMTP id p197so16299277itp.0
        for <linux-nfs@vger.kernel.org>; Tue, 04 Dec 2018 11:25:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=+5Uiy4NkcA08AbutZm4qywC5YVuauCiKk57abbWBmRg=;
        b=n9JuMM04865dzmFhiJ3yl+dImgP4zn755tNCQfVnZPDHpwen0xVIY9YfDfn+peH72M
         rpPF09Lu50fNXKhIZWhYOcIppLZzPrOW6sZyjsuio+yZl5I5kTJ1SqqeKelyLBcpjt0I
         rqCP8v+1NCyQTW5ZpTNQyCmttsVTOqhJ5JlgybghIJAPJnWGrk//RFT2xgs4tFuLDZB0
         PR0k6cLQY3loEO0kkT9T3b0oPzAAomVdUtncmy5e1KIXJko2uIDpGDWWl/IrJjUiSWUS
         3NVQvSraZW6k0/ELZUtLm7mtnHPDTdWFWQ+mFpGGQSBhSTydp2usfscryccTpuonM9bM
         XoXg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=+5Uiy4NkcA08AbutZm4qywC5YVuauCiKk57abbWBmRg=;
        b=FK0K0oscULKPpOefZyeW05iicbqz/LnxjAM6TmP/FzkrBvi/zjKSy2AfEu7n8A0LSl
         MRu5adA9UuR98Ct3jkRzBkY5OzTEdvLglC4jIbXSZRs5Z78VToQ/G2xxwCBIoVDDvLHa
         Echtdfy822R/43vMlVNvuRiTostzQIumhZvnJH+lFONl4LmBGDmO162Y9cmpjGTPMTGZ
         j+2JaZ22aSB53JRnIM/fudOSP9XS25yF3x/sezMIHzjAcLo2zTM/6OaQQhuomS6KiS/y
         ePBHUQIvvxaLeCeiDVG2C7mxbvToXkkDdByLSXxWuuOAmYcLAkIQtMpc2NriWHG8+Dlm
         G5xQ==
X-Gm-Message-State: AA+aEWYacgGsYSdah+QxyMqYXhUzfxI2PasDwsKCpeDDGS6zV1WiiEQV
        /u8+xUVdNTeMlxdk8ZVDCg==
X-Google-Smtp-Source: AFSGD/VTxa3Rw9DecG64e3ArCj8X+ERK/DW38SafCMS8eRMZVApqVjSvRzS/Lr1q5ARO6uRCmQ/ABw==
X-Received: by 2002:a24:6e14:: with SMTP id w20mr12370491itc.69.1543951547576;
        Tue, 04 Dec 2018 11:25:47 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id o18sm2781694ioh.31.2018.12.04.11.25.46
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 11:25:47 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>,
        Catalin Marinas <catalin.marinas@arm.com>,
        Cristian Marussi <cristian.marussi@arm.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: Fix RPC receive hangs
Date:   Tue,  4 Dec 2018 14:24:39 -0500
Message-Id: <20181204192439.39259-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.2
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The RPC code is occasionally hanging when the receive code fails to
empty the socket buffer due to a partial read of the data. When we
convert that to an EAGAIN, it appears we occasionally leave data in the
socket. The fix is to just keep reading until the socket returns
EAGAIN/EWOULDBLOCK.

Reported-by: Catalin Marinas <catalin.marinas@arm.com>
Reported-by: Cristian Marussi <cristian.marussi@arm.com>
Reported-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xprtsock.c | 39 +++++++++++++++++++--------------------
 1 file changed, 19 insertions(+), 20 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index ae77c71c1f64..1c0560dc5557 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -398,7 +398,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
 			goto out;
 		if (ret != want)
-			goto eagain;
+			goto out;
 		seek = 0;
 	} else {
 		seek -= buf->head[0].iov_len;
@@ -418,7 +418,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
 			goto out;
 		if (ret != want)
-			goto eagain;
+			goto out;
 		seek = 0;
 	} else {
 		seek -= buf->page_len;
@@ -433,7 +433,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
 			goto out;
 		if (ret != want)
-			goto eagain;
+			goto out;
 	} else
 		offset += buf->tail[0].iov_len;
 	ret = -EMSGSIZE;
@@ -441,9 +441,6 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 out:
 	*read = offset - seek_init;
 	return ret;
-eagain:
-	ret = -EAGAIN;
-	goto out;
 sock_err:
 	offset += seek;
 	goto out;
@@ -486,19 +483,18 @@ xs_read_stream_request(struct sock_xprt *transport, struct msghdr *msg,
 	if (transport->recv.offset == transport->recv.len) {
 		if (xs_read_stream_request_done(transport))
 			msg->msg_flags |= MSG_EOR;
-		return transport->recv.copied;
+		return read;
 	}
 
 	switch (ret) {
+	default:
+		break;
 	case -EMSGSIZE:
-		return transport->recv.copied;
+		return read;
 	case 0:
 		return -ESHUTDOWN;
-	default:
-		if (ret < 0)
-			return ret;
 	}
-	return -EAGAIN;
+	return ret;
 }
 
 static size_t
@@ -537,7 +533,7 @@ xs_read_stream_call(struct sock_xprt *transport, struct msghdr *msg, int flags)
 
 	ret = xs_read_stream_request(transport, msg, flags, req);
 	if (msg->msg_flags & (MSG_EOR|MSG_TRUNC))
-		xprt_complete_bc_request(req, ret);
+		xprt_complete_bc_request(req, transport->recv.copied);
 
 	return ret;
 }
@@ -570,7 +566,7 @@ xs_read_stream_reply(struct sock_xprt *transport, struct msghdr *msg, int flags)
 
 	spin_lock(&xprt->queue_lock);
 	if (msg->msg_flags & (MSG_EOR|MSG_TRUNC))
-		xprt_complete_rqst(req->rq_task, ret);
+		xprt_complete_rqst(req->rq_task, transport->recv.copied);
 	xprt_unpin_rqst(req);
 out:
 	spin_unlock(&xprt->queue_lock);
@@ -591,10 +587,8 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 		if (ret <= 0)
 			goto out_err;
 		transport->recv.offset = ret;
-		if (ret != want) {
-			ret = -EAGAIN;
-			goto out_err;
-		}
+		if (transport->recv.offset != want)
+			return transport->recv.offset;
 		transport->recv.len = be32_to_cpu(transport->recv.fraghdr) &
 			RPC_FRAGMENT_SIZE_MASK;
 		transport->recv.offset -= sizeof(transport->recv.fraghdr);
@@ -602,6 +596,9 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 	}
 
 	switch (be32_to_cpu(transport->recv.calldir)) {
+	default:
+		msg.msg_flags |= MSG_TRUNC;
+		break;
 	case RPC_CALL:
 		ret = xs_read_stream_call(transport, &msg, flags);
 		break;
@@ -616,6 +613,8 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 		goto out_err;
 	read += ret;
 	if (transport->recv.offset < transport->recv.len) {
+		if (!(msg.msg_flags & MSG_TRUNC))
+			return read;
 		ret = xs_read_discard(transport->sock, &msg, flags,
 				transport->recv.len - transport->recv.offset);
 		if (ret <= 0)
@@ -623,7 +622,7 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 		transport->recv.offset += ret;
 		read += ret;
 		if (transport->recv.offset != transport->recv.len)
-			return -EAGAIN;
+			return read;
 	}
 	if (xs_read_stream_request_done(transport)) {
 		trace_xs_stream_read_request(transport);
@@ -653,7 +652,7 @@ static void xs_stream_data_receive(struct sock_xprt *transport)
 	clear_bit(XPRT_SOCK_DATA_READY, &transport->sock_state);
 	for (;;) {
 		ret = xs_read_stream(transport, MSG_DONTWAIT);
-		if (ret <= 0)
+		if (ret < 0)
 			break;
 		read += ret;
 		cond_resched();
-- 
2.19.2

