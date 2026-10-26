Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.173
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793011945;
	b=Bl+5Otr2K2NcrcSrxLHwvyuAzpY4JQXa6PDW+FPc64WJAz2LONiD2ng9dmp5YNldbiyi
	 Fygn5ywW1MjohMT3gISiWXrYqs50CIxK1+Dv7r6LE9wKyUzZ9c1B8mnmN3kRCY0ggIqP9
	 glCwrokL2b0gxbo5xyF2cn6KGGjPuqIdl3Lhi3DJGT4NfLRtOJDFKHlQeQ7bHnjE+ooFH
	 vpzKH/vGbMGjCeeM3G2NcEm6yKuawBLJ+wbktCVdPmbirnyCrF3I9dlh+HaLRKy1zECVg
	 MDcFb6+eMbrcqC/+FO1BhRgnYjGY8ISa5hNavAJ9WKfDZsLiVBAp6CsB3VoMIEBVf/w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793011945;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=gOYmoGPbwEQdywGQ/41fb29WcNoZgPqM/BtBzm9km6Q=;
	b=2R0XJ1LeEbl/wuE9q7coOz345AWmgWr19bIq6TKqAMokDurMnoUayU00gHOFTx6un9mj
	 7+e/dvHNJwY5GTdd64d4gdk/SRRLKPgQe9fmvOA/bfLaWk9Dsau1y4t70hXGDO2RR57Du
	 aJlszQwQKNxSAUGP+pV+6w9vUJrqXQ+pOedOeXIwki1Ersbqe24YE7K+yXEd2aIIqczzt
	 Wp4ChlANugLUIWFgTfXh6rHCyskqXJBOFVw2l8iSwb+iNTm4anl74D2YN5Xyn4Md1JzoT
	 Rkg/e52HYPCy7kmAlUcu0Dpu0NuE5LZaOcc8wdIVGocAZ2gvbl7c3UZCoq0hckqqGcA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=rZJnMpRb;
	arc=none smtp.remote-ip=74.125.82.173
Received: from mail-dy1-f173.google.com (mail-dy1-f173.google.com [74.125.82.173])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3D705606A31A
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 10:52:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3D705606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=rZJnMpRb
Received: by mail-dy1-f173.google.com with SMTP id 5a478bee46e88-33bf40b0c8bso8416076eec.0
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 03:52:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1793011943; x=1793616743; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gOYmoGPbwEQdywGQ/41fb29WcNoZgPqM/BtBzm9km6Q=;
        b=rZJnMpRbX2Ia4RYK1vuImjnGX7O9nlYmr0ED4gNrciX9tqntGQHWBXF+tllAiRKdw/
         cNC9F1iHLzHnXaAaSt03J7J9Z/3q+pna6nS30Dw926Hgq7JVsKqPZvSsn6iRqHK4gfwd
         +GbA/d1aDtPHhTm1q21W+SvCYECQxyN5aXke6p2nCQZ0XJ/LmcpOxBb970n9nY+ELLKm
         ZMB9eBYm89irFnKqpx1GVazc1aGTiANvrvpojt45R+pX/PasowWASWzNw5XdOheYWklk
         et0nqII1PLjXIU8OMRBmNe2EBcxxJbIzdBYMDOTJnPiWjTlzUcyumeQgjlfiY+0v4wPJ
         cuTA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793011943; x=1793616743;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=gOYmoGPbwEQdywGQ/41fb29WcNoZgPqM/BtBzm9km6Q=;
        b=Q7ulNUcVtL75Q1LiDJfVHa5gujDxN7O0y2B7EjWAa7gpqjVaKOTdCCDkUT2hRO7t5k
         /i/ndBGVHx+bgpNJJ2auhONt7epBCdMSG/oaC+A5mL+7FtwrPcfHDq25N0laea9gnTI2
         uOe0E97fFymkMBFn+It2muHBcH8Vu9+zS3eURWcgFqz6MkSDhlTuRwdxWN2QGvoJ3DS7
         skTmy0SKkpDDIxOfN5CjGJ+qzpAFLj4Qc11jsv6wQH5a/eGTg1MVwSpY5JKdQPLoNyek
         30n5O+hKCdMG1TMJAr//rN77XWKPVQXelgFOlEqWMHQwqaTNi0ekapwSnwPHI1clcrYT
         zAtg==
X-Gm-Message-State: AFq9FYJcUTcalh9mJOjMjOBPe5Op5Xpfkylfs0ZEzfo1NeuNLY/kmBCK
	I5ea5T6guyT4NgDE6hKKhxL1Q68NuaIOoam47eaxDpPBZLPAhrTuA8NH
X-Gm-Gg: AYBFou2P8SVKnXU1qX4OVu7VdoYeFLfAAofSWINYqxqoo+gyzf046wf8JCSfEK2VAve
	49pNCVEbjWyWMAUl7Kt+8ThzN2D7XiCYWGSpQs0YDithp7L/i7MwzxlVAKiaKNwn/feP0U3MdDA
	Zqfv8r7nkPv8JaaXGx08FfISkoYfaQZMsr0Hvv4u7riHWT/HLfc6+WWyl2ok0VxB5Lpr9//QbpY
	RPAGuTwaSa74oPR6ILI0IVxALj9rwcHNkUWzwPLrY0Zh5xanV+FwF2aAejJs4wYGFmX9EISzgYZ
	py7MxLXoW7bRoqKYQilCBq0tA9YQAjeRkr4wDXnz6VLlVp8lZKIHH5oTTnbyFfOtnIDqbx8TIfL
	Dgl0WPFWjWyBs7VDrHsFNV3Arv+Lw0ea1DR9YXFUgCoJSIuIWB97MUmQlab6bgenOFmFZcRecCC
	U1d+7+Teev7U5AYV2dcdSwhJKJS9ku5H74a/J90/Hm8tTBsz+5iRIZVo6ymvVjfPJh2hUovY5uh
	vOBtia84JciECfJazUNPle7EuBkNoS56V1eyto+PhYLs2srPWzUn9OwVC+mff780SVOTF7jVXd7
	osynSBBH349qxf6+NOo=
X-Received: by 2002:a05:693c:88c4:20b0:369:c6d8:5799 with SMTP id 5a478bee46e88-369e86444b5mr9500581eec.41.1793011942963;
        Mon, 26 Oct 2026 03:52:22 -0700 (PDT)
Received: from youngkk-vm.localdomain (67.216.200.102.16clouds.com. [67.216.200.102])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-369e8ee72c0sm37475633eec.29.2026.10.26.03.52.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 03:52:22 -0700 (PDT)
From: Cheng Yongkang <teel4res@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: [PATCH v2] NFS: keep in-flight slots when shrinking the session slot table
Date: Mon, 26 Oct 2026 03:52:15 -0700
Message-Id: <20261026105215.1149970-1-teel4res@gmail.com>
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
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

nfs4_reset_slot_table() shrinks the forechannel slot table to the new
session's max_reqs without checking whether any of the slots being
freed are still in use.  The session drain it follows only snapshots
highest_used_slotid once, while nfs4_setup_sequence() and
nfs41_assign_slot() deliberately let privileged RPCs (sa_privileged,
e.g. the DELEGRETURN sent while an inode is being evicted) allocate a
slot after that snapshot.  If such an RPC owns a slot with
slot_nr >= max_reqs, nfs4_shrink_slot_table() kfree()s it and the
reply path (decode_sequence(), nfs41_release_slot(), nfs4_free_slot())
later dereferences the freed slot: a slab-use-after-free.

Clamp the shrink target to highest_used_slotid + 1 when the table is
not empty, so only slots above the highest used slot are freed, and
stop resetting highest_used_slotid: the high-water mark is still needed
to release those slots and to complete a later drain.  max_slotid is
still set to the server's new highest slotid, so new RPCs cannot use
the preserved slots above the new max_reqs.  A server advertising
max_reqs == 0 arrives with server_highest_slotid == NFS4_NO_SLOT; make
that wrap explicit.

Link: https://lore.kernel.org/all/20261025180317.349421-1-teel4res@gmail.com/
Fixes: 87dda67e7386 ("NFSv4.1: Allow SEQUENCE to resize the slot table on the fly")
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Cheng Yongkang <teel4res@gmail.com>
---
v2: add Link, Fixes and stable tags, and remove local validation details from the
commit message.

 fs/nfs/nfs4session.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4session.c b/fs/nfs/nfs4session.c
index 175390e..869451c 100644
@@ -274,8 +274,25 @@
 		u32 ivalue)
 {
 	struct nfs4_slot **p;
+	u32 newsize = server_highest_slotid + 1;
+	u32 highest_used = tbl->highest_used_slotid;
 
-	nfs4_shrink_slot_table(tbl, server_highest_slotid + 1);
+	/*
+	 * Privileged RPCs are allowed to allocate slots after the session
+	 * drain has taken its snapshot, so slots above the server's new
+	 * highest slotid may still be owned by in-flight RPCs.  Shrink
+	 * only up to the highest slot that is still in use: every slot
+	 * above it is known to be free.
+	 *
+	 * A server advertising max_reqs == 0 arrives here with
+	 * server_highest_slotid == NFS4_NO_SLOT, for which the addition
+	 * above wraps to 0.
+	 */
+	if (server_highest_slotid == NFS4_NO_SLOT)
+		newsize = 0;
+	if (highest_used != NFS4_NO_SLOT && newsize <= highest_used)
+		newsize = highest_used + 1;
+	nfs4_shrink_slot_table(tbl, newsize);
 	p = &tbl->slots;
 	while (*p) {
 		(*p)->seq_nr = ivalue;
@@ -283,7 +300,12 @@
 		(*p)->seq_nr_last_acked = ivalue - 1;
 		p = &(*p)->next;
 	}
-	tbl->highest_used_slotid = NFS4_NO_SLOT;
+	/*
+	 * Leave highest_used_slotid untouched: when it is not
+	 * NFS4_NO_SLOT, the high-water mark belongs to an in-flight
+	 * privileged RPC whose slot survives the shrink, and
+	 * nfs4_free_slot() lowers it once that RPC completes.
+	 */
 	tbl->target_highest_slotid = server_highest_slotid;
 	tbl->server_highest_slotid = server_highest_slotid;
 	tbl->d_target_highest_slotid = 0;
