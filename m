Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.111
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794224021;
	b=bwtsA80xbV5yEGu0sBM48lHbECz1ljLKysyHqx9ceSYiH2qToXLqmdPoZ5uLW8IuhOop
	 817KIu412llMeH/HsngyLlgABPO+MkJGyLCjaBj+DOPo3+d7WPGvzjuBOtkBvLbRMRRk3
	 iE8qx5GBYW6mIoL8lu/9bHVQPk+bDO4S3apYZSygKTH8t3dpOCkQb656PQH4fQvd5jEmg
	 hBMLqaWz5Tq81Uknednqqf20fZuZWjxVSP2jsQmZ1121Y46AuSLyQqaVX1fX/KPBRmg/0
	 kLdAoWKlk7Ye2b8m0P7ce6u2rw3Sx4qX/OpDrFxUq+puPalLmshHjyg9K6fpK4lJUiw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794224021;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-Id:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=C/IN6KS61ksc0rGNEp6x77vvpUWHuUzbVSpcmOuc7/4=;
	b=cNEb4p5/KmSkMy6/w7HM4da300XjEYWYf+JgADG4tiB0MyZwDlxI+rEd28CBTrgb86EC
	 P7WX+vAakjX+/RzgOBbENTPxmuWYek1eF/h0Vuo/C0vBZ37AzPrfCTnrv/VGeMMZq/M6C
	 hOHeGvBdtaOojNqeuCY8s+xTkAwwCZ+cwRRumg/mKXQIObgX3AYYUqGFAQ+Sf8Yll0nW1
	 Ky5uVM+doKiMjhhWR0XGXGGPjGZlw4348EeUdGZ+F81F398262ok17nY4CYPlFVXgqCCd
	 oIIehQGUIDRrGCT9Z5oPejqz82Ziw352ZzM/bMsKVdHinh23NBESz6ZMg9X+FGAp03A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=FoeZkdSx;
	arc=none smtp.remote-ip=115.124.30.111
Received: from out30-111.freemail.mail.aliyun.com (out30-111.freemail.mail.aliyun.com [115.124.30.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14FB2606A31C;
	Mon,  9 Nov 2026 11:33:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 14FB2606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=FoeZkdSx
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1794224015; h=From:To:Subject:Date:Message-Id:MIME-Version;
	bh=C/IN6KS61ksc0rGNEp6x77vvpUWHuUzbVSpcmOuc7/4=;
	b=FoeZkdSxuojiMi+sfjdVesGX1MNr25gzlNeATNT2W+2J5qdKy8/iUm0+A74P93/U/Bv0ylepkcNau9bmInyG4BphZa8qxu4kvAo7ijYhw94v6Vnk5qHIwMDjcQ6cjZqtNm2s+f5KDOd5AV7cgC2uzQF8hbzMrdU8wEi623f5fMQ=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033045098064;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0XEO4pLh_1794224013;
Received: from localhost(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0XEO4pLh_1794224013 cluster:ay36)
          by smtp.aliyun-inc.com;
          Mon, 09 Nov 2026 19:33:33 +0800
From: Joseph Qi <joseph.qi@linux.alibaba.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	stable@vger.kernel.org
Subject: [PATCH v2] NFS: don't raise i_size for DEALLOCATE in _nfs42_proc_fallocate()
Date: Mon,  9 Nov 2026 19:32:44 +0800
Message-Id: <20261109113244.4136089-1-joseph.qi@linux.alibaba.com>
X-Mailer: git-send-email 2.39.3
In-Reply-To: <20261103061654.2036827-1-joseph.qi@linux.alibaba.com>
References: <20261103061654.2036827-1-joseph.qi@linux.alibaba.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

_nfs42_proc_fallocate() raises i_size to offset + len on success, so
that the cached size is not left stale when a delegation blocks the
post-op attribute refresh.  The helper is shared by all three
fallocate modes, but DEALLOCATE always carries FALLOC_FL_KEEP_SIZE
and never extends the file on the server, so punching a hole that
reaches past EOF now wrongly enlarges the cached i_size.

The post-op update would normally restore the size from the returned
attributes, but nfs_update_inode() applies a differing size only when
no delegation is held, and then only when no write is in flight or the
new size is larger:

	if (new_isize != cur_isize && !have_delegation) {
		if (!nfs_have_writebacks(inode) || new_isize > cur_isize)
			i_size_write(inode, new_isize);
	}

With a concurrent mmap writer (nrequests != 0) or any outstanding
delegation, the shrinking server size is therefore ignored and the
client keeps reporting a file larger than the server has, in violation
of KEEP_SIZE, until some later revalidation without writebacks happens
to fix it up.

Skip the i_size bump for the DEALLOCATE procedure.  ALLOCATE (mode 0)
and ZERO_RANGE (which nfs42_fallocate() accepts only without
FALLOC_FL_KEEP_SIZE) do extend the file when the range reaches past
EOF, so they keep the update.

Fixes: 35168eb947f2 ("NFS: fix eof updates after NFSv4.2 fallocate/zero-range")
Cc: stable@vger.kernel.org
Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
---
 fs/nfs/nfs42proc.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ab86246fc364f..d76bface87f74 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -84,7 +84,9 @@ static int _nfs42_proc_fallocate(struct rpc_message *msg, struct file *filep,
 		loff_t newsize = offset + len;
 
 		spin_lock(&inode->i_lock);
-		if (newsize > i_size_read(inode))
+		/* DEALLOCATE implies KEEP_SIZE, so don't extend i_size */
+		if (msg->rpc_proc != &nfs4_procedures[NFSPROC4_CLNT_DEALLOCATE] &&
+		    newsize > i_size_read(inode))
 			i_size_write(inode, newsize);
 		nfs_set_cache_invalid(inode, NFS_INO_INVALID_BLOCKS);
 		if (nfs_should_remove_suid(inode))
-- 
2.39.3

