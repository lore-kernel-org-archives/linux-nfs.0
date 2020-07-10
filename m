Return-Path: <SRS0=vVyH=AV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E0E0C433E1
	for <linux-nfs@archiver.kernel.org>; Fri, 10 Jul 2020 20:33:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 7097320748
	for <linux-nfs@archiver.kernel.org>; Fri, 10 Jul 2020 20:33:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ZOoikZz7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727046AbgGJUdR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 10 Jul 2020 16:33:17 -0400
Received: from us-smtp-2.mimecast.com ([205.139.110.61]:49320 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726725AbgGJUdR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2020 16:33:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1594413195;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=BWw96zSVz+b95VAZtQY7m4gtcyHzZrz7o/WGSBnrVdk=;
        b=ZOoikZz7qXVMjJw9e3LoOXLN0HWvULob6gVW3cEaV708d7NSf4/5j1dysI4dJCmP9ukVog
        ag8+fuH154efIiNZQZu1rNpgg8SWjmjUR5LV56uHJhfvo+ZsTg6kE7sYKLF4hH5izGz047
        UuAX7UKS+Fa8FVspvwlDD3BNG+LhWZ4=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-180-Zpw2oft9ObarsdkwG3oLQw-1; Fri, 10 Jul 2020 16:33:09 -0400
X-MC-Unique: Zpw2oft9ObarsdkwG3oLQw-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id D614C100A61D;
        Fri, 10 Jul 2020 20:33:08 +0000 (UTC)
Received: from aion.usersys.redhat.com (ovpn-113-242.rdu2.redhat.com [10.10.113.242])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id B300B7880F;
        Fri, 10 Jul 2020 20:33:08 +0000 (UTC)
Received: by aion.usersys.redhat.com (Postfix, from userid 1000)
        id B183E1A0245; Fri, 10 Jul 2020 16:33:07 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, chuck.lever@oracle.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: avoid a NULL dereference in __cld_pipe_upcall()
Date:   Fri, 10 Jul 2020 16:33:07 -0400
Message-Id: <20200710203307.2545412-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the rpc_pipefs is unmounted, then the rpc_pipe->dentry becomes NULL
and dereferencing the dentry->d_sb will trigger an oops.  The only
reason we're doing that is to determine the nfsd_net, which could
instead be passed in by the caller.  So do that instead.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfs4recover.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 9e40dfecf1b1..186fa2c2c6ba 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -747,13 +747,11 @@ struct cld_upcall {
 };
 
 static int
-__cld_pipe_upcall(struct rpc_pipe *pipe, void *cmsg)
+__cld_pipe_upcall(struct rpc_pipe *pipe, void *cmsg, struct nfsd_net *nn)
 {
 	int ret;
 	struct rpc_pipe_msg msg;
 	struct cld_upcall *cup = container_of(cmsg, struct cld_upcall, cu_u);
-	struct nfsd_net *nn = net_generic(pipe->dentry->d_sb->s_fs_info,
-					  nfsd_net_id);
 
 	memset(&msg, 0, sizeof(msg));
 	msg.data = cmsg;
@@ -773,7 +771,7 @@ __cld_pipe_upcall(struct rpc_pipe *pipe, void *cmsg)
 }
 
 static int
-cld_pipe_upcall(struct rpc_pipe *pipe, void *cmsg)
+cld_pipe_upcall(struct rpc_pipe *pipe, void *cmsg, struct nfsd_net *nn)
 {
 	int ret;
 
@@ -782,7 +780,7 @@ cld_pipe_upcall(struct rpc_pipe *pipe, void *cmsg)
 	 *  upcalls queued.
 	 */
 	do {
-		ret = __cld_pipe_upcall(pipe, cmsg);
+		ret = __cld_pipe_upcall(pipe, cmsg, nn);
 	} while (ret == -EAGAIN);
 
 	return ret;
@@ -1115,7 +1113,7 @@ nfsd4_cld_create(struct nfs4_client *clp)
 	memcpy(cup->cu_u.cu_msg.cm_u.cm_name.cn_id, clp->cl_name.data,
 			clp->cl_name.len);
 
-	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg);
+	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg, nn);
 	if (!ret) {
 		ret = cup->cu_u.cu_msg.cm_status;
 		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
@@ -1180,7 +1178,7 @@ nfsd4_cld_create_v2(struct nfs4_client *clp)
 	} else
 		cmsg->cm_u.cm_clntinfo.cc_princhash.cp_len = 0;
 
-	ret = cld_pipe_upcall(cn->cn_pipe, cmsg);
+	ret = cld_pipe_upcall(cn->cn_pipe, cmsg, nn);
 	if (!ret) {
 		ret = cmsg->cm_status;
 		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
@@ -1218,7 +1216,7 @@ nfsd4_cld_remove(struct nfs4_client *clp)
 	memcpy(cup->cu_u.cu_msg.cm_u.cm_name.cn_id, clp->cl_name.data,
 			clp->cl_name.len);
 
-	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg);
+	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg, nn);
 	if (!ret) {
 		ret = cup->cu_u.cu_msg.cm_status;
 		clear_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
@@ -1261,7 +1259,7 @@ nfsd4_cld_check_v0(struct nfs4_client *clp)
 	memcpy(cup->cu_u.cu_msg.cm_u.cm_name.cn_id, clp->cl_name.data,
 			clp->cl_name.len);
 
-	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg);
+	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg, nn);
 	if (!ret) {
 		ret = cup->cu_u.cu_msg.cm_status;
 		set_bit(NFSD4_CLIENT_STABLE, &clp->cl_flags);
@@ -1404,7 +1402,7 @@ nfsd4_cld_grace_start(struct nfsd_net *nn)
 	}
 
 	cup->cu_u.cu_msg.cm_cmd = Cld_GraceStart;
-	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg);
+	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg, nn);
 	if (!ret)
 		ret = cup->cu_u.cu_msg.cm_status;
 
@@ -1432,7 +1430,7 @@ nfsd4_cld_grace_done_v0(struct nfsd_net *nn)
 
 	cup->cu_u.cu_msg.cm_cmd = Cld_GraceDone;
 	cup->cu_u.cu_msg.cm_u.cm_gracetime = nn->boot_time;
-	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg);
+	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg, nn);
 	if (!ret)
 		ret = cup->cu_u.cu_msg.cm_status;
 
@@ -1460,7 +1458,7 @@ nfsd4_cld_grace_done(struct nfsd_net *nn)
 	}
 
 	cup->cu_u.cu_msg.cm_cmd = Cld_GraceDone;
-	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg);
+	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg, nn);
 	if (!ret)
 		ret = cup->cu_u.cu_msg.cm_status;
 
@@ -1524,7 +1522,7 @@ nfsd4_cld_get_version(struct nfsd_net *nn)
 		goto out_err;
 	}
 	cup->cu_u.cu_msg.cm_cmd = Cld_GetVersion;
-	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg);
+	ret = cld_pipe_upcall(cn->cn_pipe, &cup->cu_u.cu_msg, nn);
 	if (!ret) {
 		ret = cup->cu_u.cu_msg.cm_status;
 		if (ret)
-- 
2.25.4

