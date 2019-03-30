Return-Path: <SRS0=ux7S=SB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1F5BC43381
	for <linux-nfs@archiver.kernel.org>; Sat, 30 Mar 2019 01:21:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7E25420811
	for <linux-nfs@archiver.kernel.org>; Sat, 30 Mar 2019 01:21:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730403AbfC3BV2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 21:21:28 -0400
Received: from www262.sakura.ne.jp ([202.181.97.72]:26741 "EHLO
        www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730343AbfC3BV2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 21:21:28 -0400
Received: from fsav401.sakura.ne.jp (fsav401.sakura.ne.jp [133.242.250.100])
        by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2U1L8te076553;
        Sat, 30 Mar 2019 10:21:08 +0900 (JST)
        (envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav401.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp);
 Sat, 30 Mar 2019 10:21:08 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav401.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126072090247.bbtec.net [126.72.90.247])
        (authenticated bits=0)
        by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2U1L6qF076537
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
        Sat, 30 Mar 2019 10:21:08 +0900 (JST)
        (envelope-from penguin-kernel@I-love.SAKURA.ne.jp)
Subject: [PATCH] NFS: Forbid setting AF_INET6 to "struct
 sockaddr_in"->sin_family.
To:     anna.schumaker@netapp.com, trond.myklebust@hammerspace.com
References: <00000000000062ece6057bbd0e4a@google.com>
Cc:     syzbot <syzbot+047a11c361b872896a4f@syzkaller.appspotmail.com>,
        bfields@fieldses.org, davem@davemloft.net, jlayton@kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, syzkaller-bugs@googlegroups.com
From:   Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <d2215ca3-8561-9e10-2c27-b7657cb8a49d@I-love.SAKURA.ne.jp>
Date:   Sat, 30 Mar 2019 10:21:07 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <00000000000062ece6057bbd0e4a@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

syzbot is reporting uninitialized value at rpc_sockaddr2uaddr() [1]. This
is because syzbot is setting AF_INET6 to "struct sockaddr_in"->sin_family
(which is embedded into user-visible "struct nfs_mount_data" structure)
despite nfs23_validate_mount_data() cannot pass sizeof(struct sockaddr_in6)
bytes of AF_INET6 address to rpc_sockaddr2uaddr().

Since "struct nfs_mount_data" structure is user-visible, we can't change
"struct nfs_mount_data" to use "struct sockaddr_storage". Therefore,
assuming that everybody is using AF_INET family when passing address via
"struct nfs_mount_data"->addr, reject if its sin_family is not AF_INET.

[1] https://syzkaller.appspot.com/bug?id=599993614e7cbbf66bc2656a919ab2a95fb5d75c

Reported-by: syzbot <syzbot+047a11c361b872896a4f@syzkaller.appspotmail.com>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 fs/nfs/super.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 23790c7..c27ac96 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2041,7 +2041,8 @@ static int nfs23_validate_mount_data(void *options,
 		memcpy(sap, &data->addr, sizeof(data->addr));
 		args->nfs_server.addrlen = sizeof(data->addr);
 		args->nfs_server.port = ntohs(data->addr.sin_port);
-		if (!nfs_verify_server_address(sap))
+		if (sap->sa_family != AF_INET ||
+		    !nfs_verify_server_address(sap))
 			goto out_no_address;
 
 		if (!(data->flags & NFS_MOUNT_TCP))
-- 
1.8.3.1

