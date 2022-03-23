Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F949C433EF
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Mar 2022 08:04:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S241235AbiCWIFa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Mar 2022 04:05:30 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:32772 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232115AbiCWIF3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2022 04:05:29 -0400
X-Greylist: delayed 196 seconds by postgrey-1.37 at lindbergh.monkeyblade.net; Wed, 23 Mar 2022 01:04:00 PDT
Received: from out203-205-221-205.mail.qq.com (out203-205-221-205.mail.qq.com [203.205.221.205])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 07C1370F78
        for <linux-nfs@vger.kernel.org>; Wed, 23 Mar 2022 01:03:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=foxmail.com;
        s=s201512; t=1648022633;
        bh=lwMLg/Yews7tW/5fe8TNLpkLv34pD5PLMY7UOC6qBW4=;
        h=From:To:Cc:Subject:Date;
        b=SPIp5GkaXtKaowg0RJA0WfauNRcp1qCD8DCGyHxlt7Lwfg554hEhujNoKECMQi/UI
         Yk9p1/Xk4QqHUGXRx3WFl9LfPgIi+asHSASeSo6xmBcuz2ywdEVeJCTlkc9u1VsBcK
         XVtk06jvHjLnOog7EzyWABHviZjOUBxPk0rr7MWQ=
Received: from localhost.localdomain ([43.227.138.48])
        by newxmesmtplogicsvrszc9.qq.com (NewEsmtp) with SMTP
        id 23A188F; Wed, 23 Mar 2022 16:00:35 +0800
X-QQ-mid: xmsmtpt1648022435tca9ugqwi
Message-ID: <tencent_61C566F88A52C1BF198826737AAE0E471806@qq.com>
X-QQ-XMAILINFO: ONLymQk6scaO9GJ/nMNoeUSLwUq3BvP5iTFihRf6aDI5gVJH5Jgd/kyaCnjkgy
         tpXZu0pMbNV1taHd1Tfho/FwM5qpNI/vmvr1LWWc3v3VBIg0h0RHPdSzXJkPInToClh9HMG6Cj42
         SL/1v02nd0d16vEDVqz5/9GSxfaZzMllyR9lDESE6Fp5AW0sisjCiY4WmhAeNHeJ/czFd0hxPXpq
         ryC9PQREFqOkeex+qh7xBQkU9nX/1+tq+vSzEhS6Ic2qlv7gmBnRi7SRiVkhTZYfmrVldjs7JgcS
         8XBksnSB62XLpzpGsUeKijSHpJyHUvJbb4D4YEwVC+YwNWSlWd/MWuaB/QieXqGXqin+xXxWDYM1
         NNq5itTOBQLyiDj/RmfPKIB/AiJZT+aSdAvOpdQKbTLEXTbFyA0kujcanBOjj7h/ai3+6GEN6AYL
         44j/HNa6Gh9aNCnp622fjvDlApSyg/NS9u2cIecHPAVhvZtn1Wg3vkclAOUxKSJoOOuuLU1vmVaA
         HEDzkbubQgM9f8ksUpF/tP9fzV+RRUgvlh25gS73pP6N4xwQAGZoNpXTQxWOSxrVOlIiLipTbBMN
         FCMiiIzQ+kWYR6eKrjlrfq9xhBaD63vj+CT5ckwQrn41hStdx+LFh6Z6tVhmaFzZFLutzTt1vZGL
         HC4LwInyRycVR9JWsj4HlProl7bsUX3YLNBfmgEFhIHqmbrP4tIZ6p+taTdPkJHm5UdBi/u+wm8c
         HpgPyGw+zz4SG8SWN7uj4CmA7Q+TD092d7KsM7kNctV8EeVol6GmR9Wkrhb5yvZv0LNZ0uaVsDr1
         SzqvIysmbm6fTRusEmXTpwe9KKlBK5LvNKCf28UhdElSfALo3w3mPok7qGsxYZkv3bn3CFFfoMD+
         byxIdVhOAswoFH6cojh0M2bvQ6Qc1C2zqLSXOft6n8pjAcjkw6fPhZ7A5MEL+Ynz/iGsG3WseYpK
         f7fV6OHUs=
From:   xkernel.wang@foxmail.com
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Xiaoke Wang <xkernel.wang@foxmail.com>
Subject: [PATCH] NFS: check the return value of mempool_alloc()
Date:   Wed, 23 Mar 2022 16:00:03 +0800
X-OQ-MSGID: <20220323080003.2151-1-xkernel.wang@foxmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Xiaoke Wang <xkernel.wang@foxmail.com>

The check was first removed in 518662e ("NFS: fix usage of mempools.")
as the passed GFP flags is `GFP_NOIO`.
While now the flag is changed to `GFP_KERNEL` by 2b17d72 ("NFS: Clean
up writeback code"), so it is better to check it.

Signed-off-by: Xiaoke Wang <xkernel.wang@foxmail.com>
---
 fs/nfs/write.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index eae9bf1..831fad9 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -106,8 +106,10 @@ static struct nfs_pgio_header *nfs_writehdr_alloc(void)
 {
 	struct nfs_pgio_header *p = mempool_alloc(nfs_wdata_mempool, GFP_KERNEL);
 
-	memset(p, 0, sizeof(*p));
-	p->rw_mode = FMODE_WRITE;
+	if (p) {
+		memset(p, 0, sizeof(*p));
+		p->rw_mode = FMODE_WRITE;
+	}
 	return p;
 }
 
-- 
