Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.7 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C19CC43461
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Apr 2021 03:52:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id EBB0361153
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Apr 2021 03:52:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236724AbhDPDxJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 15 Apr 2021 23:53:09 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43952 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S238330AbhDPDxI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Apr 2021 23:53:08 -0400
Received: from mail-qk1-x733.google.com (mail-qk1-x733.google.com [IPv6:2607:f8b0:4864:20::733])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9AE2DC061574
        for <linux-nfs@vger.kernel.org>; Thu, 15 Apr 2021 20:52:43 -0700 (PDT)
Received: by mail-qk1-x733.google.com with SMTP id 130so13399715qkm.4
        for <linux-nfs@vger.kernel.org>; Thu, 15 Apr 2021 20:52:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=IvIGbq9ssctXnwv6tZgOI2Y2lz7KazuLx7B7Qa8Jcx8=;
        b=tBNVBFaE+FZQpcjDaDkTNayUw9w0xrTrN12wq+zSLl+jwg0Dfmyw69xoZRfAapqJAa
         ddaOFbPhqO8ZMrqplSXRfIgwNpNR7gZEH08s0l+86fSgloPC3PcMj3C6kDwD+wzUtcyg
         cd7Tzw+GGWa4CzTqAt/ma7e/EtR8QMVjozfIlF3iDjwot4nfgPXx5tckWG6GQ1lbQyzX
         2ukWMghxb4e5skCUzoS9UKSzb7xXvqkp4ViqbCKL5fYZVTN81jw3q7Vn7hfCxcmXbEVe
         VSiHI8TYFQDDRpeDu+Yo7IDSUgX+4x3hVNpxJN8vONNx1Rc4myoEx9iqanFIev43lDgQ
         qFcA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=IvIGbq9ssctXnwv6tZgOI2Y2lz7KazuLx7B7Qa8Jcx8=;
        b=oCD8FeAsh4VSd7AIAr7DpQJ8AyFuYVeDxa9OjZlD9qUqa2+SY5cAmEsbKRvqUkFZux
         cmPvtU/fcSsykAr3FQds2fZMFr8HTqfGJXP4b8pEPpe4Jb9ksPmWDfc0RQgnTgC/amfT
         NIgDA3Ck8ccwuMXfGoxr3kNhxCVyZCvHv+nnlYUT3JJluy2hX6rAgJOUvJhKSnXF/0UE
         b3KzUU977TKx0flZVDsfI93wR3Ad6+WG+Z7a+rvvy3bIt7DEi/1PsPSfq42pIS4mWEds
         bh2S+8NirvDva2HIVNzvWIVPA7h9nTKpofXfqrmOmqCNMifwZIHlO8ShDfUpExeGPpgM
         RjbA==
X-Gm-Message-State: AOAM533ZAuE86O30T6GHpMTFHnfVkldrpWffWXoFKGNXYmu1O1ROQJxB
        8N8W+FnsruLkzkUfAYCTaOob/v/2ur8=
X-Google-Smtp-Source: ABdhPJwYaWls7/00rwhtUFTxI1jFGxjP0CQB4d9phjRXnbT1OQU3RAN+6lYYSOPU9g8ztIwgbXrPIQ==
X-Received: by 2002:a37:6756:: with SMTP id b83mr6868145qkc.385.1618545162883;
        Thu, 15 Apr 2021 20:52:42 -0700 (PDT)
Received: from kolga-mac-1.vpn.netapp.com (nat-216-240-30-25.netapp.com. [216.240.30.25])
        by smtp.gmail.com with ESMTPSA id x82sm3500913qkb.0.2021.04.15.20.52.41
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Apr 2021 20:52:42 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 12/13] sunrpc: provide transport info in the sysfs directory
Date:   Thu, 15 Apr 2021 23:52:25 -0400
Message-Id: <20210416035226.53588-13-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.24.3 (Apple Git-128)
In-Reply-To: <20210416035226.53588-1-olga.kornievskaia@gmail.com>
References: <20210416035226.53588-1-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Allow to query transport's attributes. Currently showing following
fields of the rpc_xprt structure: state, last_used, cong, cwnd,
max_reqs, min_reqs, num_reqs, sizes of queues binding, sending,
pending, backlog.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 net/sunrpc/sysfs.c | 54 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

diff --git a/net/sunrpc/sysfs.c b/net/sunrpc/sysfs.c
index 20c622c3330e..e7a728da8e9c 100644
--- a/net/sunrpc/sysfs.c
+++ b/net/sunrpc/sysfs.c
@@ -72,6 +72,56 @@ static ssize_t rpc_sysfs_xprt_dstaddr_show(struct kobject *kobj,
 	return ret + 1;
 }
 
+static ssize_t rpc_sysfs_xprt_info_show(struct kobject *kobj,
+					struct kobj_attribute *attr,
+					char *buf)
+{
+	struct rpc_xprt *xprt = rpc_sysfs_xprt_kobj_get_xprt(kobj);
+	ssize_t ret;
+	int locked, connected, connecting, close_wait, bound, binding,
+	    closing, congested, cwnd_wait, write_space;
+
+	if (!xprt)
+		return 0;
+
+	if (!xprt->state) {
+		ret = sprintf(buf, "state=CLOSED\n");
+	} else {
+		locked = test_bit(XPRT_LOCKED, &xprt->state);
+		connected = test_bit(XPRT_CONNECTED, &xprt->state);
+		connecting = test_bit(XPRT_CONNECTING, &xprt->state);
+		close_wait = test_bit(XPRT_CLOSE_WAIT, &xprt->state);
+		bound = test_bit(XPRT_BOUND, &xprt->state);
+		binding = test_bit(XPRT_BINDING, &xprt->state);
+		closing = test_bit(XPRT_CLOSING, &xprt->state);
+		congested = test_bit(XPRT_CONGESTED, &xprt->state);
+		cwnd_wait = test_bit(XPRT_CWND_WAIT, &xprt->state);
+		write_space = test_bit(XPRT_WRITE_SPACE, &xprt->state);
+
+		ret = sprintf(buf, "state=%s %s %s %s %s %s %s %s %s %s\n",
+			      locked ? "LOCKED" : "",
+			      connected ? "CONNECTED" : "",
+			      connecting ? "CONNECTING" : "",
+			      close_wait ? "CLOSE_WAIT" : "",
+			      bound ? "BOUND" : "",
+			      binding ? "BOUNDING" : "",
+			      closing ? "CLOSING" : "",
+			      congested ? "CONGESTED" : "",
+			      cwnd_wait ? "CWND_WAIT" : "",
+			      write_space ? "WRITE_SPACE" : "");
+	}
+	ret += sprintf(buf + ret, "last_used=%lu\ncur_cong=%lu\ncong_win=%lu\n"
+		       "max_num_slots=%u\nmin_num_slots=%u\nnum_reqs=%u\n"
+		       "binding_q_len=%u\nsending_q_len=%u\npending_q_len=%u\n"
+		       "backlog_q_len=%u", xprt->last_used, xprt->cong,
+		       xprt->cwnd, xprt->max_reqs, xprt->min_reqs,
+		       xprt->num_reqs, xprt->binding.qlen, xprt->sending.qlen,
+		       xprt->pending.qlen, xprt->backlog.qlen);
+	buf[ret] = '\n';
+	xprt_put(xprt);
+	return ret + 1;
+}
+
 static ssize_t rpc_sysfs_xprt_dstaddr_store(struct kobject *kobj,
 					    struct kobj_attribute *attr,
 					    const char *buf, size_t count)
@@ -171,8 +221,12 @@ static const void *rpc_sysfs_xprt_switch_xprt_namespace(struct kobject *kobj)
 static struct kobj_attribute rpc_sysfs_xprt_dstaddr = __ATTR(dstaddr,
 	0644, rpc_sysfs_xprt_dstaddr_show, rpc_sysfs_xprt_dstaddr_store);
 
+static struct kobj_attribute rpc_sysfs_xprt_info = __ATTR(xprt_info,
+	0444, rpc_sysfs_xprt_info_show, NULL);
+
 static struct attribute *rpc_sysfs_xprt_attrs[] = {
 	&rpc_sysfs_xprt_dstaddr.attr,
+	&rpc_sysfs_xprt_info.attr,
 	NULL,
 };
 
-- 
2.27.0

