Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63EDA3BED6A
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 08:00:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786953626; cv=none; b=g1XxP7pMKkOAn2GwXwCgjDpD47SIABISKjEysQIVAHmrY+DdDwgjfNMSSNJa5rqA/PDLSq4Cc+YfGFE82EnLUKN/I/wOq8yYgn75Dw21dhUbOOTeRAVk4jsgMfMFV8wIrWOxT74jWKvVgNaPFUow2Lze+r2up5QY0X57SwDiEHw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786953626; c=relaxed/simple;
	bh=nEbPJirofNZR8YP113Zh20revId+ONhKdsLyIjSEW/Y=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=FHyiI2VR0U/sxvbCDzh+Itb8BG36YEVeCXphJzcdV0dV8RpsDyVS434EduUfZIhAIoVR6uO6W0ci46d9OBgwMAVN0lozfUSN35CaGnK/E4McmX2i5GWDLlczBeMru1/ziwZYA0g3gyfiQktPevbq/KnnewfJWoeEusGYNfV48AA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=ADAdNXds; dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b=EImnwTna; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ADAdNXds";
	dkim=pass (2048-bit key) header.d=redhat.com header.i=@redhat.com header.b="EImnwTna"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1786953623;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=DwTYrOnwpgdP2owyQAuLgoS9oPtit+Bxu8ttOzaSjxA=;
	b=ADAdNXdsXxnWUmN0BGGJ/6Y1CMHuP8QypRQUkdDOvP0Pr3afSaUv39xKsiAqgzXdB8yFHY
	4hA96GxUDxxO0XoGCuspYyOirOPnZdR6JfI/wRyrdYnfdNBAfdq6Vo096+N+bVvoaJoDT8
	xdeHyVWM6wJFYGGLM5YirAdBg3i6CX0=
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com
 [209.85.210.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-683-uSyfyc-MMq6T77uXPONPCQ-1; Mon, 17 Aug 2026 04:00:21 -0400
X-MC-Unique: uSyfyc-MMq6T77uXPONPCQ-1
X-Mimecast-MFC-AGG-ID: uSyfyc-MMq6T77uXPONPCQ_1786953621
Received: by mail-pf1-f197.google.com with SMTP id d2e1a72fcca58-84eee2147ffso4011527b3a.0
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 01:00:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=redhat.com; s=google; t=1786953621; x=1787558421; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=DwTYrOnwpgdP2owyQAuLgoS9oPtit+Bxu8ttOzaSjxA=;
        b=EImnwTnadRQUhicZ7DPFs5igEE2iopWozE8ksbjRnWyCrGLmjPFwHqYTYo6Yg9Ru66
         +XQeQLbcLtVYNS+dntfdNsRMBYNY0SOHiislPtAl4ZDHaa+TAt5Zai7yF5cmkR+4uQrZ
         3MCo5G9VtN0Tj+pH2MZjAZHoheVRnASbg3MyxBhRHUmNiRjZEUZJ5KDTRvW6cM5+KM2v
         Bf/FGXi93ESAVNuv9BElzENwuN/+1JXFrfLEFZJX/BQ+U6z04Ho5klLidFO4VLmQq4zW
         AkLJwUWI3VU0M7AAIb356b4zIQ2pYU6twz6SU9lAo1VWnzsBRjEH7o5sCMe8mTIrX24P
         ooWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786953621; x=1787558421;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=DwTYrOnwpgdP2owyQAuLgoS9oPtit+Bxu8ttOzaSjxA=;
        b=Dh45FUy67NvkUfVrmU7i0lSboYiJCEhNScCsnPLQ7Y2mz7VxqDqcQFatqP/2S8ZMVd
         Q/0EbkupntOafpbewx5x8wbjFfHZNSN4kISqqE3nwBiEM7s5J1EOk3uHC60DvUZzlD0d
         lyypd8K1NO7i7HQv460sU6O5U4fzgBHGUL73Cmfpc334M2Xqv1RYpx2gWLjhRXf3dFkS
         rz4ifzhgEV+IX9VkG4iRY9gW9UOcBQh7sOKpoQA1YvGPfAZtjx5HRdZ1EdogHDHXzW3/
         zyOw4tAX74VddkIJt0iNjdbbenS3j6E6ted3hkEgRXKbk1qIo/cDI2JJAAw8WS9XKHeP
         M+Og==
X-Forwarded-Encrypted: i=1; AHgh+RpsBiZCDiTgnin6n+pMQlZWJNSplRV/GQ4sc2//bGsxwGhkV4llPWnOXNUDbp5rAy03GxbYeB7OU6g=@vger.kernel.org
X-Gm-Message-State: AOJu0YzGtpU6Q3+8XQ2aGo9cjDaFPAMFLqfhzpMq9HuKaEWPixTeGFoz
	bqmgVYv3Ly/JQm2xhhyGKU+ULXfeau5zqZNM9ZlxeLeqziAaFPvGDEEMZQLNPgUqynGppsUqMyE
	CdiiRSiUV1tTQHNSFf7WFDfyiFxQvpHuqC6pjcel52cAV+OdWy47TAdqpOWOlfF9nEJp8Z3Ma
X-Gm-Gg: AR+sD13Ut3vE2aSDJiLXb/moN1cPGbuILjYNmoE+JocM7eB7YqISwV+AUXHRCLCkiHJ
	5VZia13WZT1maMfXQdZU1OA2OagL6YCLz4tQIWyeFpKfcPfiCcVES3rpCqKYSGRptEWKysUbodw
	GJODRFR2HKGER6jWegIu4pQUUoxSRePqPpDHC/090td475Po1tvTYLk1cSH8nZcuoe0OdIOU5hE
	98yV6rdfvNffJCK94QsfpLf1DtXWx7ZCUCnekh7uGDxnXuFW8j1wzpJTre+HT7LbzFLElEY2j3B
	o+Kiqe2jZv43UMDCwx6YzeuyIjjxPpJuZX+h6S/OSzH09drcRnhlqbNLi7BOCezxGgsDalashMw
	lX/rxpu7F9TlUPCwhu4MnwodU
X-Received: by 2002:a05:6a00:4ac1:b0:847:9aa8:d3bb with SMTP id d2e1a72fcca58-84fde15f1a9mr21594358b3a.12.1786953620459;
        Mon, 17 Aug 2026 01:00:20 -0700 (PDT)
X-Received: by 2002:a05:6a00:4ac1:b0:847:9aa8:d3bb with SMTP id d2e1a72fcca58-84fde15f1a9mr21594266b3a.12.1786953619846;
        Mon, 17 Aug 2026 01:00:19 -0700 (PDT)
Received: from kernel-devel.tail62cea.ts.net ([240d:1a:c0d:9f00:be24:11ff:fe35:71b3])
        by smtp.gmail.com with ESMTPSA id d2e1a72fcca58-8517d249b39sm2310673b3a.47.2026.08.17.01.00.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 Aug 2026 01:00:18 -0700 (PDT)
From: Shigeru Yoshida <syoshida@redhat.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	felix <fuzhen5@huawei.com>
Cc: Shigeru Yoshida <syoshida@redhat.com>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] SUNRPC: update clnt->pipefs_sb on pipefs MOUNT/UMOUNT events
Date: Mon, 17 Aug 2026 17:00:12 +0900
Message-ID: <20260817080013.564939-1-syoshida@redhat.com>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Commit bfca5fb4e97c ("SUNRPC: Fix RPC client cleaned up the freed
pipefs dentries") added a clnt->pipefs_sb field and a consistency
check in rpc_clnt_remove_pipedir() so that pipedir cleanup is skipped
when the current superblock does not match the one recorded in the
client.

However, __rpc_clnt_handle_event() never updates clnt->pipefs_sb when
it creates or removes pipedirs in response to RPC_PIPEFS_MOUNT and
RPC_PIPEFS_UMOUNT notifications.

This causes a problem for RPC clients that are registered before
rpc_pipefs is mounted (e.g., before rpc_pipefs is mounted during boot,
or after it has been unmounted). Such clients have clnt->pipefs_sb set
to NULL at registration time because rpc_get_sb_net() returns NULL.
When rpc_pipefs is mounted later, __rpc_clnt_handle_event(MOUNT)
creates the pipedir but leaves clnt->pipefs_sb as NULL. When the
client is later destroyed, rpc_clnt_remove_pipedir() sees that the
current superblock does not match clnt->pipefs_sb and skips cleanup,
leaving orphaned dentries whose RPC_I(inode)->private pointers
reference freed rpc_clnt memory. Any subsequent access to these
orphaned info files triggers a use-after-free [1].

Fix this by setting clnt->pipefs_sb in __rpc_clnt_handle_event() on
MOUNT and clearing it on UMOUNT, mirroring what rpc_setup_pipedir()
already does at client registration time.

[1]
BUG: KASAN: slab-use-after-free in rpc_info_open (net/sunrpc/rpc_pipe.c:426)
Read of size 4 at addr ffff88802ebe0800 by task cat/5079

Call Trace:
 <TASK>
 ...
 rpc_info_open (net/sunrpc/rpc_pipe.c:426)
 do_dentry_open (fs/open.c:947)
 vfs_open (fs/open.c:1052)
 path_openat (fs/namei.c:4700 fs/namei.c:4863)
 do_file_open (fs/namei.c:4892)
 do_sys_openat2 (fs/open.c:1368)
 __x64_sys_openat (fs/open.c:1385)
 do_syscall_64 (arch/x86/entry/syscall_64.c:94)
 entry_SYSCALL_64_after_hwframe (arch/x86/entry/entry_64.S:121)
 </TASK>

Allocated by task 5048:
 ...
 rpc_new_client (net/sunrpc/clnt.c:377)
 __rpc_clone_client (net/sunrpc/clnt.c:645)
 rpc_clone_client_set_auth (net/sunrpc/clnt.c:706)
 nfs_init_server_rpcclient (fs/nfs/client.c:640)
 nfs_clone_server (fs/nfs/client.c:1247)
 nfs4_clone_server (fs/nfs/nfs4proc.c:10683)
 nfs_do_submount (fs/nfs/namespace.c:288)
 ...

Freed by task 24:
 ...
 kfree (mm/slub.c:6692)
 rpc_free_client_work (net/sunrpc/clnt.c:987)
 process_scheduled_works (kernel/workqueue.c:3405)
 worker_thread (kernel/workqueue.c:3486)
 ...

Fixes: bfca5fb4e97c ("SUNRPC: Fix RPC client cleaned up the freed pipefs dentries")
Assisted-by: Claude:claude-opus-4-6
Signed-off-by: Shigeru Yoshida <syoshida@redhat.com>
---
 net/sunrpc/clnt.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index efa26899bc7d..55617d263d2f 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -179,11 +179,17 @@ static int rpc_clnt_skip_event(struct rpc_clnt *clnt, unsigned long event)
 static int __rpc_clnt_handle_event(struct rpc_clnt *clnt, unsigned long event,
 				   struct super_block *sb)
 {
+	int err;
+
 	switch (event) {
 	case RPC_PIPEFS_MOUNT:
-		return rpc_setup_pipedir_sb(sb, clnt);
+		err = rpc_setup_pipedir_sb(sb, clnt);
+		if (!err)
+			clnt->pipefs_sb = sb;
+		return err;
 	case RPC_PIPEFS_UMOUNT:
 		__rpc_clnt_remove_pipedir(clnt);
+		clnt->pipefs_sb = NULL;
 		break;
 	default:
 		printk(KERN_ERR "%s: unknown event: %ld\n", __func__, event);
-- 
2.55.0

