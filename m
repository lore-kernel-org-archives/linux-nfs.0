Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.179
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792951399;
	b=T6K9Ksjb3faQlhsoTSBrJlEDLExSHwr4S21yV+TG77o/sMmD1UTUYrn7hSAdUblxMAJv
	 2bdEuwrY14XmtP3ZRVbkjLih+H9P+6LrQvFyEcxs1FBaKGIQaHikF50PW8U3xMGXJjAyp
	 06hl8J43ej//xB762tN5s6vOWaX1xPHCUjFv0ioGXiiRHsubcAGwPakXwQ7q6zQpOUl6e
	 ddQGLirGMiWoAkk8VhFIZoJsDL/ysGuSIY2PXweFwCOiPKpzAkfUBFUXSTLSVpzey1zFV
	 cp6QYinCmsjn31sYVLUTmZqnAHrpFjqJ14uyQt66q4uzZv8ZF49hvzvhx5sYaa9hgxg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792951399;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=ndd2z9h6FBXADx73BjEu3vuxAgpxEryIlqHxJjGkw6o=;
	b=Yj2EnfwoHP7HVWRF8YjcTkA0L3noeZWjZxW6lS69iVQKZekb8fAZoqIbU/bCQW3Bcq6f
	 SsinnoUFhbtSeyqqWoMfKGm7tGodpuHflzX5y//rPMlv4mTXRJ3Xnyp+K6KJw3DhI19jb
	 zLnWIf4dhRVzM19aZ/XYqNhFcRQNQ0sWMv7Y5gMEHkWajOeakn1djgaIAW4XeSClBmUKQ
	 JaUULOKJ5iqaJrrrwDjvAVY7G7QsN5BDS72/vHKbNaJiwACpSEuCSUQz6pkt9xcMJWp+H
	 IT6RI3hVcyiz2Q70BXJYhlj+nPDiFPTgwoHtU0HeRknTHb/5mOZVNR8Z34aWhX41ocA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=XwDrlpVe;
	arc=none smtp.remote-ip=74.125.82.179
Received: from mail-dy1-f179.google.com (mail-dy1-f179.google.com [74.125.82.179])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0FA96606A31A
	for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 18:03:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0FA96606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=XwDrlpVe
Received: by mail-dy1-f179.google.com with SMTP id 5a478bee46e88-35f1f76ea84so3944313eec.1
        for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 11:03:18 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792951398; x=1793556198; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ndd2z9h6FBXADx73BjEu3vuxAgpxEryIlqHxJjGkw6o=;
        b=XwDrlpVeB43MY9fAf4aYqMQWLkZAmA+PBgH/t+S8ZRIGESaJdG5o7xaC7O4YKu/I2a
         HRH5VzRKv8op4AgOmKRJwkN5P6Q6Omd6C1/ThXaOSuX3OHw7VJ0n96FxeZ57u1CEICnX
         fTV5osF6Njwd6PEDPHAZbodprXYdlOfrW+poIllW2DspZZDJzPl8LBmlA9n1ewX1NU1h
         DhqCF7tBZMJLE3pPyDcWD4G8TrEyx/qkqZl/YGGrjA8FvjetXouW6yGryelZWOGiM9He
         Q73uYa3Oak4IiJhZSAL2hZSDpaCncRT8PecOI3oJfeFg18mf2/Z9tGTZuSvUCdRax0fH
         3JOw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792951398; x=1793556198;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ndd2z9h6FBXADx73BjEu3vuxAgpxEryIlqHxJjGkw6o=;
        b=pZ/z/wrkVKNbSMcuYUlIKMvZoxqkTk77qbFSuCx3L64rwHf6tjeZC2cCthU9o6oSso
         pmaz1RmfHXOchTozQ8nBgTc1E5NsVECqrW/oQ2YoKDain99Mb9alWSFgm9l8u0Dps2Ji
         ym1dydLk+QX5F3mKopvkFQL9rW3r8BOrZf11Rd7DpbGHtT+NjEzm4kDBz4BNk2mR9Xk7
         /EDIg5clJfpVjkvLHf9b/xAMYKqc+h/PsIqe/wxaToM3ND3005ks5xS0eczZucjTz6KP
         QKrD6+PUBzGQ4VuwPRJUbA2L8lzMEjcfDV2KNtfq3tfqNsqFbZxEEEwldMEKBoeGmLZJ
         BVyQ==
X-Gm-Message-State: AFq9FYIPISHRxJjThMLL4D8fl6SDMDWOxK1T0vAyk+bEidEA1aXlLv4y
	iWZEIC452G9RE6rvScjY8xclo9Kg1NmNB3IAfPBvrGF/QfwTrj55GXeQ3G470ax2HKQ=
X-Gm-Gg: AYBFou3JRqL6RITIQd9aA7JItDODO20H4MlECEw+PUhv92f3tWnMrpilU8qAMIu3exD
	b44RGhc5qdvk8lRjXpCGHhRFmwq4z35XP29RE2YiVlbVDaPjL1MXLBMvcglPLp5pNt/RCHIFTF2
	luEbqWoB0Ig1w0XO+t/5ArFokEGclvMQLdMTStcSsXVLQi7Wb9R6eJIUGMvFBPuwlMmSQz4hu88
	TCPqayLTos+4M17oxQsTa9XsBden/uQbXO3TWLMvm3iJubmpoSx+TacU02gV0gw0FEML7Cj/KN4
	sbr0fPhAJ3v3crjOZzIvq2mWUYzjYpeHPFr0+QlZogJk1CRkoYP7VQhfAZ+3vFsuXxytsJXEqxB
	bH9PX8jHCscgUOPcFVdFuVF3xVapT8nwltRi1lLLMfMIfZEKS7jEjC6gFeRor5MMQ6n5sOK7VPL
	8R9VFNpe35BDH3ggzQNcwYSITsHO9QVthFj9hAqyMlwiE2LCKXON7V8irPLTTWswMonUlzJO9Sb
	B+4mky9hQWTGNkoKfI2VfdNuft4oyh0yT2on9rwgWFAd1wr0mJWOVd7EAIhI4b5Z7Fm8wy27NvS
	xvh181uHw2buid8YU6I=
X-Received: by 2002:a05:693c:881b:20b0:36a:10d:afab with SMTP id 5a478bee46e88-36a010db09fmr715356eec.25.1792951398190;
        Sun, 25 Oct 2026 11:03:18 -0700 (PDT)
Received: from youngkk-vm.localdomain (67.216.200.102.16clouds.com. [67.216.200.102])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-369e8db7e73sm18543367eec.20.2026.10.25.11.03.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 25 Oct 2026 11:03:17 -0700 (PDT)
From: Cheng Yongkang <teel4res@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Cheng Yongkang <teel4res@gmail.com>
Subject: [PATCH] NFS: clamp WRITE reply count to the requested count
Date: Sun, 25 Oct 2026 11:03:11 -0700
Message-Id: <20261025180311.349348-1-teel4res@gmail.com>
X-Mailer: git-send-email 2.34.1
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

nfs_writeback_update_inode() uses the server's WRITE reply count for the
size update before nfs_writeback_result() compares it with the request.
That comparison only rejects a smaller count, so a server can return a
count larger than the request, make nfs_writeback_check_extend() set
fattr->size beyond the requested extent, and grow the client inode's
i_size.

Clamp the reply count to args.count before the size update.  This keeps
the attribute barrier and completion accounting within the write the
client actually issued.

The inflation was reproduced 3/3 times with a fake NFSv4.0 server that
answered a 1-byte WRITE with count 0x40000000; with this clamp the
client keeps i_size at 1.  A reply with the requested count still gives
i_size=1.

Assisted-by: LLM
Signed-off-by: Cheng Yongkang <teel4res@gmail.com>
---
 fs/nfs/write.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 623e7ef..0dbcaeb 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1467,6 +1467,13 @@ void nfs_writeback_update_inode(struct nfs_pgio_header *hdr)
 	struct nfs_fattr *fattr = &hdr->fattr;
 	struct inode *inode = hdr->inode;
 
+	/*
+	 * A server may report more bytes than the request asked for.  Do not
+	 * let that count extend the inode size or the attribute barrier.
+	 */
+	if (hdr->res.count > hdr->args.count)
+		hdr->res.count = hdr->args.count;
+
 	if (nfs_have_delegated_mtime(inode)) {
 		spin_lock(&inode->i_lock);
 		nfs_set_cache_invalid(inode, NFS_INO_INVALID_BLOCKS);
-- 
2.34.1

