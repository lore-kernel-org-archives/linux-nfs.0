Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4E3FC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 20:33:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BD71B222D0
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 20:33:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731691AbfBOUdv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 15:33:51 -0500
Received: from mx1.math.uh.edu ([129.7.128.32]:55054 "EHLO mx1.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729292AbfBOUdv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 15:33:51 -0500
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx1.math.uh.edu with esmtp (Exim 4.91)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gukB6-0002oM-4T; Fri, 15 Feb 2019 14:33:45 -0600
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 108418014D1; Fri, 15 Feb 2019 14:33:44 -0600 (CST)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     "Benjamin Coddington" <bcodding@redhat.com>
Cc:     "Trond Myklebust" <trondmy@hammerspace.com>,
        Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org,
        Chuck.Lever@oracle.com
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
        <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
        <ufak1isms71.fsf@epithumia.math.uh.edu>
        <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
        <FC712F54-5A7A-436D-B076-936B29C013F4@redhat.com>
        <87imxwab12.fsf@hippogriff.math.uh.edu>
        <662CE7B3-235E-4E2D-9C8C-0F6233F3085F@redhat.com>
        <87d0o3aadg.fsf@hippogriff.math.uh.edu>
        <B730E8AE-AFA3-4CE7-9103-FCCC35C37EDD@redhat.com>
Date:   Fri, 15 Feb 2019 14:33:44 -0600
In-Reply-To: <B730E8AE-AFA3-4CE7-9103-FCCC35C37EDD@redhat.com> (Benjamin
        Coddington's message of "Fri, 08 Feb 2019 07:01:11 -0500")
Message-ID: <ufa4l943i6v.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

>>>>> "BC" == Benjamin Coddington <bcodding@redhat.com> writes:

BC> Hmm.. commit c443305529d1d3d3bee0d68fdd14ae89835e091f changed
BC> xs_read_stream_reply() to return recv.copied instead of "ret" to
BC> xprt_complete_rqst()..

BC> You could try reverting that commit and see if the problem goes
BC> away..

So patching a revert of that into 4.20.7 was beyond me, but I received
some help from Jeremy Cline on IRC (in #fedora-kernel) and ended up with
a patch I'll include at the end.  So far it does seem to be better, but
because of secure boot annoyances I haven't been able to roll it out
more generally.  However, it has been stable for a week on a few hosts
which have been problematic with stock 4.20.6.

I will continue to test, but hopefully this helps folks to understand
what's happening.

 - J<

From 322f581f514ffedb8884656f136bd6a812a53714 Mon Sep 17 00:00:00 2001
From: Jeremy Cline <jcline@redhat.com>
Date: Fri, 8 Feb 2019 13:09:41 -0500
Subject: [PATCH] Revert "SUNRPC: Fix RPC receive hangs"

This reverts commit c443305529d1d3d3bee0d68fdd14ae89835e091f.

Signed-off-by: Jeremy Cline <jcline@redhat.com>
---
 net/sunrpc/xprtsock.c | 39 ++++++++++++++++++++-------------------
 1 file changed, 20 insertions(+), 19 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9cdbb6d6e7f5..2d9f0326d55b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -417,7 +417,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
 			goto out;
 		if (ret != want)
-			goto out;
+			goto eagain;
 		seek = 0;
 	} else {
 		seek -= buf->head[0].iov_len;
@@ -439,7 +439,7 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
 			goto out;
 		if (ret != want)
-			goto out;
+			goto eagain;
 		seek = 0;
 	} else {
 		seek -= want;
@@ -455,13 +455,16 @@ xs_read_xdr_buf(struct socket *sock, struct msghdr *msg, int flags,
 		if (offset == count || msg->msg_flags & (MSG_EOR|MSG_TRUNC))
 			goto out;
 		if (ret != want)
-			goto out;
+			goto eagain;
 	} else
 		offset += buf->tail[0].iov_len;
 	ret = -EMSGSIZE;
 out:
 	*read = offset - seek_init;
 	return ret;
+eagain:
+	ret = -EAGAIN;
+	goto out;
 sock_err:
 	offset += seek;
 	goto out;
@@ -504,20 +507,21 @@ xs_read_stream_request(struct sock_xprt *transport, struct msghdr *msg,
 	if (transport->recv.offset == transport->recv.len) {
 		if (xs_read_stream_request_done(transport))
 			msg->msg_flags |= MSG_EOR;
-		return read;
+		return transport->recv.copied;
 	}
 
 	switch (ret) {
-	default:
-		break;
 	case -EFAULT:
 	case -EMSGSIZE:
 		msg->msg_flags |= MSG_TRUNC;
-		return read;
+		return transport->recv.copied;
 	case 0:
 		return -ESHUTDOWN;
+	default:
+		if (ret < 0)
+			return ret;
 	}
-	return ret < 0 ? ret : read;
+	return -EAGAIN;
 }
 
 static size_t
@@ -556,7 +560,7 @@ xs_read_stream_call(struct sock_xprt *transport, struct msghdr *msg, int flags)
 
 	ret = xs_read_stream_request(transport, msg, flags, req);
 	if (msg->msg_flags & (MSG_EOR|MSG_TRUNC))
-		xprt_complete_bc_request(req, transport->recv.copied);
+		xprt_complete_bc_request(req, ret);
 
 	return ret;
 }
@@ -589,7 +593,7 @@ xs_read_stream_reply(struct sock_xprt *transport, struct msghdr *msg, int flags)
 
 	spin_lock(&xprt->queue_lock);
 	if (msg->msg_flags & (MSG_EOR|MSG_TRUNC))
-		xprt_complete_rqst(req->rq_task, transport->recv.copied);
+		xprt_complete_rqst(req->rq_task, ret);
 	xprt_unpin_rqst(req);
 out:
 	spin_unlock(&xprt->queue_lock);
@@ -610,8 +614,10 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 		if (ret <= 0)
 			goto out_err;
 		transport->recv.offset = ret;
-		if (transport->recv.offset != want)
-			return transport->recv.offset;
+		if (ret != want) {
+			ret = -EAGAIN;
+			goto out_err;
+		}
 		transport->recv.len = be32_to_cpu(transport->recv.fraghdr) &
 			RPC_FRAGMENT_SIZE_MASK;
 		transport->recv.offset -= sizeof(transport->recv.fraghdr);
@@ -619,9 +625,6 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 	}
 
 	switch (be32_to_cpu(transport->recv.calldir)) {
-	default:
-		msg.msg_flags |= MSG_TRUNC;
-		break;
 	case RPC_CALL:
 		ret = xs_read_stream_call(transport, &msg, flags);
 		break;
@@ -636,8 +639,6 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 		goto out_err;
 	read += ret;
 	if (transport->recv.offset < transport->recv.len) {
-		if (!(msg.msg_flags & MSG_TRUNC))
-			return read;
 		msg.msg_flags = 0;
 		ret = xs_read_discard(transport->sock, &msg, flags,
 				transport->recv.len - transport->recv.offset);
@@ -646,7 +647,7 @@ xs_read_stream(struct sock_xprt *transport, int flags)
 		transport->recv.offset += ret;
 		read += ret;
 		if (transport->recv.offset != transport->recv.len)
-			return read;
+			return -EAGAIN;
 	}
 	if (xs_read_stream_request_done(transport)) {
 		trace_xs_stream_read_request(transport);
@@ -670,7 +671,7 @@ static void xs_stream_data_receive(struct sock_xprt *transport)
 		goto out;
 	for (;;) {
 		ret = xs_read_stream(transport, MSG_DONTWAIT);
-		if (ret < 0)
+		if (ret <= 0)
 			break;
 		read += ret;
 		cond_resched();
-- 
2.20.1

