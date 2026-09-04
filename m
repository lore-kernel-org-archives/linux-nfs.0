Received: from mail-ot1-f49.google.com (mail-ot1-f49.google.com [209.85.210.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C536246C84F
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 11:32:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788521534; cv=none; b=IeVQc2Xbczd5a5AiORTfXmPhjky0S+IE4NyfmVn8gC9sqn5ndXqGzHaH2ElXeUGUPSIcltPRb8mp4O7XYcbweKCWmZ3YznOWjAcKjjY4Z1P5Y8ap55EpNz7gPM6jZ1zWi+xtkBNFnYM7c29g5c7hSCIN35BGKYJtoob1BJ1NXjo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788521534; c=relaxed/simple;
	bh=38UgEEZiyW/NBOETLSrjwKZcVSZSRYGLnoLukZ2KR8E=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=MyPfYw6kuervNu+4QiwVMyLzbY7bH3Sd89jwmGE7No4LJHsLJEPUN3isNADOY1s3n9F+6HgVzBPfkAXS0fpLan0GCDPibELeblDqimH/X6jRis1fvZctXxqyIoJkP3v+4V8oWzmr6AiwAWjMUf2dnTVtyII6PGPqZ17skBNQfpw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=iFR76VWV; arc=none smtp.client-ip=209.85.210.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iFR76VWV"
Received: by mail-ot1-f49.google.com with SMTP id 46e09a7af769-7e9ecd7216cso763802a34.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 04:32:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788521530; x=1789126330; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ASwWm2X7Nj827Al3HxyPXm6hFchFaQIpjPDkuNerF0o=;
        b=iFR76VWVeK6eDFqcM9+ZbVfWnTHUiaWnAFveh/7sISmFSxVnppg5fjDFxJwVDeSqLw
         QHsN78YpocBGTaQZZtEQImBQwmaFbXSMJmxkkQ31CT9FbNci4G9rKASOcL81PToceVe3
         ZT6qo0qpo0wcvv6OXlEfevjcQknCeA7vUZl1d+y5fUnvrr823OXAdbBd2FKmocNIQVRD
         vrTn/KhBT2rmRPM6msXPLZ65wFOxC+Cxr0OLET4lbjLHg/BAQlfJYhR6y6gOnGi1DBVq
         Lb2rTJnU6XL4SNQHgDIj5dxzYUwlNqaxnGpPq5X4nz5Ei8slUpRkQndRzMp1xPfOc8D8
         DGeA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788521530; x=1789126330;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ASwWm2X7Nj827Al3HxyPXm6hFchFaQIpjPDkuNerF0o=;
        b=qJe8FI8oCGZUEP+BWHBxiQEcdjbqYZfQbeXxTR6x0sFMoxzxo5hva/3elWlLJdZQhO
         3p2Fv2ItRoP8PC44a90HLfdCRqMkZaQuAnF9KVSIhs8AeopX+6pICMNpsYEI3+orwhjC
         tIRTWWZsPoAYFjW6A9+JMinBN6LNu3RTS9TQdp/LLcCBA1uSGdpMDhHYu0mz4msPA9ZO
         LgmTSZjG2zMBil9KhPtcJvlQdqJ/rSpl1iqxk5VmJcuhZymV9XFyNOdomyUcnmH3V+bd
         vkgOZV/jKa68dnv6OowzbaD7XF/mqxzw+PmEPGudHO8Dd5V5VD71VJMHsZxiiaSt8VWM
         YGgw==
X-Forwarded-Encrypted: i=1; AKwUvBy6dj4yw0ivNAqt6JZMs5G/CPfA6Vk5FO3gvZFxWvuQU7k7ryo9ZQ1nTuBUZNvaURCVvwapBOYy5gI=@vger.kernel.org
X-Gm-Message-State: AFuF++n4g8CjtCOkEWOPWZcXujyjHKkFpN6oha85brXkFGiYZhRyqCyu
	fTLWYPvtMVzMJeZZe8AEx4IYKrr8n4XxHUghJ1g3n2LeSFDMYQ/LRpzH
X-Gm-Gg: AYBFou1kJ1JVjq1LUUCPZPaPjxfmHndTn5Sfj4XmXnbUZxeHfIdxTRlUPCM8xFbFKtY
	oneGLzqOOrab5ByVt+5UKKbR/QQLeefROHogFVOUn7v8LeNAkarFiF1ixjEQI6xbJnqmYD6yOty
	WSU0HISj0Xok0biq67lxwhVLlYvkQA62eajoAyo0psFGKP0aUkWAM6jxbLuje1XY9xrZPycbpQf
	4Qv1EJYqCZLPeYgLxmE2htz3Q6HsB20Rb3o0tDKXUQUryEbTfO3H36VCneayszekFPkIdroN8k+
	u/rVc+dkB5vo2cdUsjEsol/xiaePlwi1ROq9FAvy0lxQI40NwjW3qbqwi1R4oIwqF/zkXhSsSVi
	KafcXLNYIW/ychf+TDJ8jL7fZyQGBRl/aGZ0H++dSddqQWTWR7pYZhH4qBbr6vP5Q1uz8nTJ3TP
	HDwViJdfWFegmwd6dfL1jEnNoILjLSZ9SoTBGrSWD9KZYVKHflFHTpUO4++bPz2XsN86cYMdpw6
	DIX1X2Rc7Tlons=
X-Received: by 2002:a05:6820:4d09:b0:6b1:a667:f0f5 with SMTP id 006d021491bc7-6b6fcedc374mr3749263eaf.20.1788521530465;
        Fri, 04 Sep 2026 04:32:10 -0700 (PDT)
Received: from volcano9f6e-hostos.amd.com ([165.204.217.251])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-3339befdefcsm5259443eec.29.2026.09.04.04.32.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 04:32:10 -0700 (PDT)
From: Hemanth Selam <hemanth.selam@gmail.com>
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
	Simon Horman <horms@kernel.org>
Cc: linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH] nfs: fix typos in comments
Date: Fri,  4 Sep 2026 17:01:59 +0530
Message-ID: <20260904113203.12137-1-hemanth.selam@gmail.com>
X-Mailer: git-send-email 2.48.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Fix typos in comments, reported by scripts/checkpatch.pl using the
misspelling list in scripts/spelling.txt.  Only touches comments, no code
changes.

Assisted-by: Cursor:claude-opus-5
Signed-off-by: Hemanth Selam <hemanth.selam@gmail.com>
---
 fs/nfs/export.c                        | 2 +-
 fs/nfs/flexfilelayout/flexfilelayout.c | 2 +-
 fs/nfs/nfs4_fs.h                       | 2 +-
 fs/nfs/nfs4proc.c                      | 4 ++--
 fs/nfs/pnfs.c                          | 2 +-
 net/sunrpc/svcsock.c                   | 2 +-
 6 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/export.c b/fs/nfs/export.c
index 8fb08bce0623..ccc0a8a95af2 100644
--- a/fs/nfs/export.c
+++ b/fs/nfs/export.c
@@ -18,7 +18,7 @@ enum {
 	FILEID_HIGH_OFF = 0,	/* inode fileid high */
 	FILEID_LOW_OFF,		/* inode fileid low */
 	FILE_I_TYPE_OFF,	/* inode type */
-	EMBED_FH_OFF		/* embeded server fh */
+	EMBED_FH_OFF		/* embedded server fh */
 };
 
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fe8b91fa47c..5f25b881b9b9 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -133,7 +133,7 @@ static int decode_nfs_fh(struct xdr_stream *xdr, struct nfs_fh *fh)
  * I.e., kerberos is not supported to the DSes, so no pricipals.
  *
  * That means that one common function will suffice, but when
- * principals are added, this should be split to accomodate
+ * principals are added, this should be split to accommodate
  * calls to both nfs_map_name_to_uid() and nfs_map_group_to_gid().
  */
 static int
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b48e5b87cb2a..3acc9f90c0e3 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -411,7 +411,7 @@ _nfs4_state_protect(struct nfs_client *clp, unsigned long sp4_mode,
 	if (sp4_mode == NFS_SP4_MACH_CRED_CLEANUP ||
 	    sp4_mode == NFS_SP4_MACH_CRED_PNFS_CLEANUP) {
 		/* Using machine creds for cleanup operations
-		 * is only relevent if the client credentials
+		 * is only relevant if the client credentials
 		 * might expire. So don't bother for
 		 * RPC_AUTH_UNIX.  If file was only exported to
 		 * sec=sys, the PUTFH would fail anyway.
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 04b1987115d5..917306055f5c 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8358,7 +8358,7 @@ int nfs4_proc_fsid_present(struct inode *inode, const struct cred *cred)
 }
 
 /*
- * If 'use_integrity' is true and the state managment nfs_client
+ * If 'use_integrity' is true and the state management nfs_client
  * cl_rpcclient is using krb5i/p, use the integrity protected cl_rpcclient
  * and the machine credential as per RFC3530bis and RFC5661 Security
  * Considerations sections. Otherwise, just use the user cred with the
@@ -10154,7 +10154,7 @@ nfs4_proc_layoutcommit(struct nfs4_layoutcommit_data *data, bool sync)
 }
 
 /*
- * Use the state managment nfs_client cl_rpcclient, which uses krb5i (if
+ * Use the state management nfs_client cl_rpcclient, which uses krb5i (if
  * possible) as per RFC3530bis and RFC5661 Security Considerations sections
  */
 static int _nfs41_proc_secinfo_no_name(struct nfs_server *server,
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4f9c0f639014..992e8b01b4d1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -2117,7 +2117,7 @@ static void _add_to_server_list(struct pnfs_layout_hdr *lo,
 }
 
 /*
- * Layout segment is retreived from the server if not cached.
+ * Layout segment is retrieved from the server if not cached.
  * The appropriate layout segment is referenced and returned to the caller.
  */
 struct pnfs_layout_segment *
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 50e5e7f5b762..0966d5cbcaa2 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1111,7 +1111,7 @@ static int receive_cb_reply(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	/*
 	 * XXX!: cheating for now!  Only copying HEAD.
 	 * But we know this is good enough for now (in fact, for any
-	 * callback reply in the forseeable future).
+	 * callback reply in the foreseeable future).
 	 */
 	dst = &req->rq_private_buf.head[0];
 	src = &rqstp->rq_arg.head[0];
-- 
2.48.1

