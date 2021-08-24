Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.7 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 891BCC4338F
	for <linux-nfs@archiver.kernel.org>; Tue, 24 Aug 2021 18:02:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 732E8610D0
	for <linux-nfs@archiver.kernel.org>; Tue, 24 Aug 2021 18:02:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233519AbhHXSCx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 24 Aug 2021 14:02:53 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42016 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S239305AbhHXSCq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Aug 2021 14:02:46 -0400
Received: from mail-qv1-xf2d.google.com (mail-qv1-xf2d.google.com [IPv6:2607:f8b0:4864:20::f2d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id EB6A8C053411
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2021 10:51:23 -0700 (PDT)
Received: by mail-qv1-xf2d.google.com with SMTP id gf5so590450qvb.9
        for <linux-nfs@vger.kernel.org>; Tue, 24 Aug 2021 10:51:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=vIOWLAR5baQ4wudUHjXS8yJqf6XzOgQ0+NlfjuEdhJQ=;
        b=dku16MS4/sllkhLxUNb36DEZTfAIlkAoLodRFDWoGGvbwR713LqEHdZJeIbKY4q2Ka
         dNl+T+Z/3Vt7LBMyYPUv3CXlk+0iaRQBYOTvtpX/RBg8/SsXwhCl1jwv3+ZaC88xGol5
         70QV6ks1o0vfLXtsDNZXMhUFz47904B5WkuKXJs1dZqOkVNcym2hHnBL5YLB0VqklS/e
         l6rsi1O73bYHdDCW/06RKpYly33QHvNzfeGg8IudPDhQCFj21om7sgWUegscH34EXECS
         HfAPCyDQXTuJYrmmXFhBX9M7jcu/KEIi/5XWIwACNoTmh+Tlb2nY4B0GzGerGyg/pjSt
         vUVw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=vIOWLAR5baQ4wudUHjXS8yJqf6XzOgQ0+NlfjuEdhJQ=;
        b=AQILzCgjLkaYD5w2pDK1bTZeiQ9Ec9XbR3dpLmVL7iO8W/RF4ZCt0V8SgncxCl5dqK
         LanIlG9qycEGr/ZkGXdxfQikxkri0HuYfPkn97twqZSuiU9aiLhhp9+UFH4ETRXnAN+K
         QplcQQdjFGKAb3X8pPJ9U4/ZlvDlbFiKKbC38ekoBm6xzHAebMpjrqYgmQgbI5nMNJOi
         UPAge8Mg/t7l+ovc8p9689bh7BrLHd5A0Sjh7qXPQJGlfNotfjRf5EuXs1uUZct7GAhB
         lfT3UPu22o6pdUo+mGD7FhbT/hrXY9nFEcY8eArqSYLCqDn5NIjNnZiDtk5LXn73WY05
         GUAQ==
X-Gm-Message-State: AOAM533FrVs4edKDbNpJBQV1GgJuPuwcJ1DCtTIGxNh/QqpqVKPiweGc
        ypP4YeGz4TGv1MDsc0e0s2s=
X-Google-Smtp-Source: ABdhPJyeGhufCGfcoaENIFp0VcriYtNX4xHbFr1jhnx+/nxWpWJeSgDNw5RCDWiURMDimRlK001+SA==
X-Received: by 2002:a0c:aac3:: with SMTP id g3mr23116438qvb.14.1629827483138;
        Tue, 24 Aug 2021 10:51:23 -0700 (PDT)
Received: from kolga-mac-1.vpn.netapp.com ([2600:1700:6a10:2e90:549b:da99:adb5:676c])
        by smtp.gmail.com with ESMTPSA id n18sm11519658qkn.63.2021.08.24.10.51.22
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Aug 2021 10:51:22 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        steved@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v4 5/5] NFSv4.1 add network transport when session trunking is detected
Date:   Tue, 24 Aug 2021 13:51:08 -0400
Message-Id: <20210824175108.19746-7-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.30.1 (Apple Git-130)
In-Reply-To: <20210824175108.19746-1-olga.kornievskaia@gmail.com>
References: <20210824175108.19746-1-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

After trunking is discovered in nfs4_discover_server_trunking(),
add the transport to the old client structure if the allowed limit
of transports has not been reached.

An example: there exists a multi-homed server and client mounts
one server address and some volume and then doest another mount to
a different address of the same server and perhaps a different
volume. Previously, the client checks that this is a session
trunkable servers (same server), and removes the newly created
client structure along with its transport. Now, the client
adds the connection from the 2nd mount into the xprt switch of
the existing client (it leads to having 2 available connections).

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4client.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 270caa1805a2..af57332503be 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -402,6 +402,33 @@ static int nfs4_init_client_minor_version(struct nfs_client *clp)
 	return nfs4_init_callback(clp);
 }
 
+static void nfs4_add_trunk(struct nfs_client *clp, struct nfs_client *old)
+{
+	struct sockaddr_storage clp_addr, old_addr;
+	struct sockaddr *clp_sap = (struct sockaddr *)&clp_addr;
+	struct sockaddr *old_sap = (struct sockaddr *)&old_addr;
+	size_t clp_salen;
+	struct xprt_create xprt_args = {
+		.ident = old->cl_proto,
+		.net = old->cl_net,
+		.servername = old->cl_hostname,
+	};
+
+	if (clp->cl_proto != old->cl_proto)
+		return;
+	clp_salen = rpc_peeraddr(clp->cl_rpcclient, clp_sap, sizeof(clp_addr));
+	rpc_peeraddr(old->cl_rpcclient, old_sap, sizeof(old_addr));
+
+	if (clp_addr.ss_family != old_addr.ss_family)
+		return;
+
+	xprt_args.dstaddr = clp_sap;
+	xprt_args.addrlen = clp_salen;
+
+	rpc_clnt_add_xprt(old->cl_rpcclient, &xprt_args,
+			  rpc_clnt_test_and_add_xprt, NULL);
+}
+
 /**
  * nfs4_init_client - Initialise an NFS4 client record
  *
@@ -436,6 +463,8 @@ struct nfs_client *nfs4_init_client(struct nfs_client *clp,
 		 * won't try to use it.
 		 */
 		nfs_mark_client_ready(clp, -EPERM);
+		if (old->cl_mvops->session_trunk)
+			nfs4_add_trunk(clp, old);
 	}
 	clear_bit(NFS_CS_TSM_POSSIBLE, &clp->cl_flags);
 	nfs_put_client(clp);
-- 
2.27.0

