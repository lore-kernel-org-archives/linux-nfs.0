Received: from mail-qk2-f40.google.com (mail-qk2-f40.google.com [74.125.230.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5E4B1370AC7
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 17:34:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790703268; cv=none; b=DR08oTrDbpX0kjII3tiAh2CRmYcpNFw38SrW/OPv9cF65JAGpS1UpqCmCaWB7DmHivNslaLL02c0Sc6KsjIEyzmffOzzNa1VrGTjqfc7Mzb/rQ1R3ZlkvNnsG55O6zvEjiuVAsd1yoGy4bOngkPe/j8aoyZTXD1iDOMDQtsEZn4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790703268; c=relaxed/simple;
	bh=r0C5PJhIauslblcMFAerOdYJ5BfSgnBOihzGMFCUiRY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HUiiEQh76M4BGJ7wc8vrhcCqTWEUPCGs7qVYGIW3esy1ZVtYIpEHt5X0IfY/78Mai7WX9mW215kyxvv+YSYWEvhp3E0KAI4gqG9sSLQunPmIa7L8c9qtYqtOpvB8IK3XYK87I86BK9ICoz9Io08ML+mXn3XnXqeQOxjGB8RZpvI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=T6epI19b; arc=none smtp.client-ip=74.125.230.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="T6epI19b"
Received: by mail-qk2-f40.google.com with SMTP id af79cd13be357-93c5f7af3e1so307674585a.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:34:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790703266; x=1791308066; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ChN8nAHnCBxy3VH4uQfMzqBufbHnYEadeEtNatgNERs=;
        b=T6epI19bL1lkkJ2v6/tD/EFVz7wmIZgS2L2TSVY0tQe06EmyPihNIQaVT2wNoE/GZ+
         UaGvznVSltvA40XNv/t9lhLUCV/Th1oIs8sEHJ2PFWma82Y6gbutV+TTMXB29fvYzbFB
         lpjMIk8DI6j9lXTYFbpQg1EPzr3bMgTcy9uWwX+8l6TsaEGSqtlnMxqolz7P8JxrKEhP
         VA2p8HDstFSvtHjjFGJl9xPXEAQsEWLeZf/KTww4e5imV+bxj7NNW3PCee88P3GXiaoc
         yjWyjz03jNsX1FD+MvlhT+KW7pnhk0HuVhzgBChAYUHCPtWXFk2OowqH0r9Qc2DAYkZq
         D7OA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790703266; x=1791308066;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ChN8nAHnCBxy3VH4uQfMzqBufbHnYEadeEtNatgNERs=;
        b=wUZ5eskhW3JxH/UoYmKlp6jKYJVC+Qi0XRfCHI1cUxCzGUuzBCHaHR7QXauK/pNB59
         SiGz0HTa3KEbad/PpI/3sE8ePQyIx6OzSOicxzE21nwHetVXQSWD43PgQm7wtl2Ch7r5
         7fthdfQg5SUIm+yfZfLVQg2M3REp8jybRuk4SGM1fc+JXIryNXOAKR0pWlRHXF3YhnzQ
         q+VLEzppcFabNvsfNeRlJQ+oHttc2qmfTfbKaeLiokmHEVPmLtyp3IlVZ9y62jF6v4qZ
         nCQLXEcBbXT0WaxnzP6FDFQLUTuexBUIy6/QY/Q7Poc/+ydUElj6SK2tOBQKMLKLg6Kv
         uOPg==
X-Gm-Message-State: AFuF++lSiFix4/K+EDJXfG2llOKyU8+2Diu9TlOrWydjYgjOlQ7K7fhm
	OsAq8m2kpQlkyBaSLvwGDRTr3F0uBRsybQDnZBDzQwuCZQIDnn9j0Q0OOML7CmBbhvQ=
X-Gm-Gg: AYBFou0Kdxfkwej24yPbjFnbL4E77rHUtnHhwbFL3s4k4Z9oakkvWk7H1GyO+KCbzie
	qzW+8DWUVwG0vGfdOBxaZg5T2UIGsQaI22cLvnZVyDuxGaznlkd+oQEe2pyEfPKuN2BZUEyJC90
	0L+wlxsWHpsD8ao2ciehfiOxWd+V7DV0B1Yq1p3kWtl2z+WOV37PcwYGpFxpcECsNTJzLZTk84J
	ks8s0/aVvymVmJHGcK3t8G/dKZXg7SG8UKUqM/7386wGzlWBuXkeeUrMIQnAtNg0p++8aHX9aWk
	o4z6wxh2+j92hurGStj2K+uf0dC36SjCpleDyC7RqWO1Ho8d4saUIyDAJxC/IT26cZAroAD86FY
	kX/uzvjHgE0SAZDyM4869A3HbScDN1ECcmnInLJv6P+TY4ckGPZ0VO44uoDwqWpG8QuJxg24O6r
	TlJPIpRVHKtYbWaaXw5L5dwqiu0A9DCbmp/wZ4Tsqbprt9dKFbku/9kG1kz+kP7471qZBK1oEuE
	DTR5VtkFzlIvRvV/yhk/5/Lgt1oCCz9DIf6Me7lmGxhILSn+WYuL+3tLUxWxJTIXzfvL3FWrA==
X-Received: by 2002:a05:620a:470f:b0:93b:d7a2:dd2c with SMTP id af79cd13be357-93c9fc657b3mr38164185a.60.1790703265894;
        Tue, 29 Sep 2026 10:34:25 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93c9f4bfdd4sm21681985a.23.2026.09.29.10.34.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 10:34:25 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 01/10] NFSD: interlock the use of NFSD_IO_DIRECT for NFS READ and WRITE
Date: Tue, 29 Sep 2026 13:34:14 -0400
Message-ID: <20260929173423.16149-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260929173423.16149-1-snitzer@kernel.org>
References: <20260929173423.16149-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Now that NFSD supports NFSD_IO_DIRECT for both READ and WRITE it is
much safer to avoid needless buffered vs direct contention if/when
only one of them has been configured to use NFSD_IO_DIRECT.

Mixing direct and buffered I/O to the same file causes needless page
cache invalidation and writeback, so although io_cache_read and
io_cache_write remain separate interfaces, writing either one adjusts
the other so that READ and WRITE are never left on opposite sides of
the buffered/direct divide:

 - Setting io_cache_read to NFSD_IO_DIRECT elevates a BUFFERED or
   DONTCACHE io_cache_write to NFSD_IO_DIRECT.  A WRITE mode that is
   already direct is left as it is.

 - Setting io_cache_write to any direct mode elevates a BUFFERED or
   DONTCACHE io_cache_read to NFSD_IO_DIRECT.

 - Setting io_cache_read to NFSD_IO_BUFFERED or NFSD_IO_DONTCACHE
   demotes a direct io_cache_write to that same mode.

 - Setting io_cache_write to NFSD_IO_BUFFERED or NFSD_IO_DONTCACHE
   demotes a direct io_cache_read to that same mode.

 - Enabling splice for READ, by writing 0 to disable-splice-read,
   forces io_cache_read to NFSD_IO_BUFFERED and demotes a direct
   io_cache_write along with it.

The demotion is factored into nfsd_io_cache_write_demote() so that its
three callers stay in sync.

Both DONTCACHE and DIRECT READ must copy into the RPC reply buffer, so
splice for READ is disabled whenever either interface leaves
nfsd_io_cache_read above NFSD_IO_BUFFERED, regardless of which one was
written.

Document the complete interlock in
Documentation/filesystems/nfs/nfsd-io-modes.rst.

Fixes: 06c5c97293e3 ("NFSD: Implement NFSD_IO_DIRECT for NFS WRITE")
Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         | 35 ++++++++++++
 fs/nfsd/debugfs.c                             | 54 ++++++++++++++++---
 2 files changed, 83 insertions(+), 6 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 0fd6e82478fe6..a8e277bcb08b1 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -41,6 +41,41 @@ corresponding IO operation's debugfs interface, e.g.::
 If you experiment with NFSD's IO modes on a recent kernel and have
 interesting results, please report them to linux-nfs@vger.kernel.org
 
+READ and WRITE IO mode interlock
+================================
+
+Although io_cache_read and io_cache_write are separate interfaces, NFSD
+keeps them from being configured such that one of READ or WRITE uses
+DIRECT IO while the other uses the page cache. Mixing DIRECT and
+buffered IO to the same file causes needless page cache invalidation and
+writeback (see the DIRECT IO discussion in the Linux open(2) manpage),
+so writing one interface may adjust the other:
+
+- Setting io_cache_read to NFSD_IO_DIRECT (2) elevates io_cache_write
+  to NFSD_IO_DIRECT (2) if it was BUFFERED or DONTCACHE. A WRITE mode
+  that is already DIRECT (2, 3 or 4) is left unchanged.
+- Setting io_cache_write to any DIRECT mode (2, 3 or 4) elevates
+  io_cache_read to NFSD_IO_DIRECT (2) if it was BUFFERED or DONTCACHE.
+- Setting io_cache_read to NFSD_IO_BUFFERED (0) or NFSD_IO_DONTCACHE (1)
+  while io_cache_write is a DIRECT mode demotes io_cache_write to that
+  same value (0 or 1). A WRITE mode that is already BUFFERED or
+  DONTCACHE is left unchanged.
+- Setting io_cache_write to NFSD_IO_BUFFERED (0) or NFSD_IO_DONTCACHE
+  (1) while io_cache_read is NFSD_IO_DIRECT demotes io_cache_read to
+  that same value (0 or 1).
+
+Setting either interface to a value other than NFSD_IO_BUFFERED also
+disables NFSD's use of splice for READ, because both DONTCACHE and
+DIRECT READ must copy into the RPC reply buffer. This is reflected in
+/sys/kernel/debug/nfsd/disable-splice-read reading as 1. Writing 0 to
+disable-splice-read re-enables splice, which requires buffered READ, so
+it forces io_cache_read back to NFSD_IO_BUFFERED (0) and, if
+io_cache_write was a DIRECT mode, demotes it to NFSD_IO_BUFFERED (0) as
+well.
+
+Always read both interfaces back after writing either of them to
+confirm the resulting configuration.
+
 NFSD DONTCACHE
 ==============
 
diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 386fd1c54f527..995872a1a7f87 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -24,6 +24,17 @@ static int nfsd_dsr_get(void *data, u64 *val)
 	return 0;
 }
 
+/*
+ * NFS READ is no longer using direct I/O: demote NFS WRITE from direct
+ * I/O to the same buffered mode, to avoid needless buffered vs direct
+ * contention.
+ */
+static void nfsd_io_cache_write_demote(u64 io_mode)
+{
+	if (nfsd_io_cache_write >= NFSD_IO_DIRECT)
+		nfsd_io_cache_write = io_mode;
+}
+
 static int nfsd_dsr_set(void *data, u64 val)
 {
 	nfsd_disable_splice_read = (val > 0);
@@ -32,6 +43,7 @@ static int nfsd_dsr_set(void *data, u64 val)
 		 * Must use buffered I/O if splice_read is enabled.
 		 */
 		nfsd_io_cache_read = NFSD_IO_BUFFERED;
+		nfsd_io_cache_write_demote(NFSD_IO_BUFFERED);
 	}
 	return 0;
 }
@@ -62,22 +74,33 @@ static int nfsd_io_cache_read_set(void *data, u64 val)
 
 	switch (val) {
 	case NFSD_IO_BUFFERED:
-		nfsd_io_cache_read = NFSD_IO_BUFFERED;
-		break;
 	case NFSD_IO_DONTCACHE:
+		nfsd_io_cache_read = val;
+		nfsd_io_cache_write_demote(val);
+		break;
 	case NFSD_IO_DIRECT:
+		nfsd_io_cache_read = val;
 		/*
-		 * Must disable splice_read when enabling
-		 * NFSD_IO_DONTCACHE.
+		 * Elevate nfsd_io_cache_write if not already
+		 * configured to use NFSD_IO_DIRECT.
 		 */
-		nfsd_disable_splice_read = true;
-		nfsd_io_cache_read = val;
+		if (nfsd_io_cache_write < NFSD_IO_DIRECT)
+			nfsd_io_cache_write = NFSD_IO_DIRECT;
 		break;
 	default:
 		ret = -EINVAL;
 		break;
 	}
 
+	if (ret == 0) {
+		/*
+		 * Must disable splice_read when enabling
+		 * NFSD_IO_DONTCACHE and NFSD_IO_DIRECT.
+		 */
+		if (nfsd_io_cache_read > NFSD_IO_BUFFERED)
+			nfsd_disable_splice_read = true;
+	}
+
 	return ret;
 }
 
@@ -110,12 +133,31 @@ static int nfsd_io_cache_write_set(void *data, u64 val)
 	case NFSD_IO_DONTCACHE:
 	case NFSD_IO_DIRECT:
 		nfsd_io_cache_write = val;
+		/*
+		 * Adjust nfsd_io_cache_{read,write} to avoid
+		 * needless buffered vs direct contention.
+		 */
+		if (nfsd_io_cache_write >= NFSD_IO_DIRECT &&
+		    nfsd_io_cache_read < NFSD_IO_DIRECT)
+			nfsd_io_cache_read = NFSD_IO_DIRECT;
+		else if (nfsd_io_cache_write < NFSD_IO_DIRECT &&
+			 nfsd_io_cache_read == NFSD_IO_DIRECT)
+			nfsd_io_cache_read = nfsd_io_cache_write;
 		break;
 	default:
 		ret = -EINVAL;
 		break;
 	}
 
+	if (ret == 0) {
+		/*
+		 * Must disable splice_read when enabling
+		 * NFSD_IO_DONTCACHE and NFSD_IO_DIRECT.
+		 */
+		if (nfsd_io_cache_read > NFSD_IO_BUFFERED)
+			nfsd_disable_splice_read = true;
+	}
+
 	return ret;
 }
 
-- 
2.52.0

