Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792951405;
	b=ZjMkbxNNiFaX7ETrd/UEsuwfoPjRyXaxZdz/x3QUupFtAuOqjtUzgZ32AmVF4GGLfV71
	 Z1IR1Z96onpiMWp4QxCQFOdnKHC+Y0a0eF8SdPQ1FFWeyNYmqQUAkXmhJVUfV4cpyTNWa
	 AGg6UJPXOS/FZeYQYJdNXzk5x8dKZnmtYyZeNCqhvQOVZRmbppw//17O9O4JDgcYW7yAW
	 Zr3LLyqG+egDQPt2hr/skWq8jdx3N+X4hlyqcshnIljU8acwAIqoaJ4hPOvvBPW2fTvYd
	 BDJgKG1kLJoT+SpCTu07CvAgw5eLSLb1LeSj9ZNxnQkqXRObOU5ZtZncr0jKdXnujGg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792951405;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=alY1sQTtn421IOLdBUDG1916B/g2vsPk0ZHvzfJmA3w=;
	b=1ulrg6kMBCY0l9p9olhwoGlaXoWPkUJN47PXlGWwU+sE10RvCjXko7DcwbwBT+8dBJoX
	 0i9gwLkgigbaUtRadFvNK5QOUVhFwpeOEnDnqMqed8uCrAQCC67bYYSYHgXBgC5IMqX1P
	 TkJJEG3MHb8mSXKZonTez+z+P8A1NjxMmxnO0X06cM04DyToODize4JTesjwvONilonBh
	 IIz0gNI9ynqaCVYs4kGRIfrLHbHrjWDuKQgXZ4mTmL0H59IyPAKSUXG1FDsyMOqIIFDEM
	 4Mk1lvc/Y4J+cm/LBiV0LyGrGGpOHLcl8CZ/OWvxG6YVIcnv0orFstN3A+w4oGdj3ng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=HmuNUftk;
	arc=none smtp.remote-ip=74.125.82.48
Received: from mail-dl1-f48.google.com (mail-dl1-f48.google.com [74.125.82.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8FBAD606A31E
	for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 18:03:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8FBAD606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=HmuNUftk
Received: by mail-dl1-f48.google.com with SMTP id a92af1059eb24-15dd124bbe7so1336543c88.1
        for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 11:03:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792951405; x=1793556205; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=alY1sQTtn421IOLdBUDG1916B/g2vsPk0ZHvzfJmA3w=;
        b=HmuNUftkqguY42QEtPQYxfub2xUmD4KxNusz8g9vGE/57vWyBR7WO3ElEPmnvc5XTm
         YOWUZSQvmev5jk8me+oGckL2tIRGQUXJ54ezpSQ4oYUM7OfdX3WwpbH7kTmTxq1BGHMr
         biSuDr/RhP6O7E7vtPHvyMPL+qMC3iFCNTv1sIXp/UzMdATbgBHInEjH5nMCcK5fqW35
         VbVvKSBnr8T76aFhPFxHujHDcvHFi8PN/B0C3LdqS5OEtQt1dBV6579V9/csALsLT9+l
         81xvAy0UzO24xKBrbcBrVVOIHhk4B7d1AMBIkvpHfjtL+appeOyDwOQQmBmyLS4d53Iq
         MQfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792951405; x=1793556205;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=alY1sQTtn421IOLdBUDG1916B/g2vsPk0ZHvzfJmA3w=;
        b=lP+fAawwEmF4vOBrqb7nKbJ5UrBkFzX2/gMHAo2j7FM5iwi9cnqHI8QRTX2yJWfH7O
         JN4rOZ93eqpUweys9Ol0RIT4VSKrns2L13VfeOs5HlcUCJmb1mbuJo42XGIuNN3rx0Ne
         umexh11QyLwiE5Nk9AJ9Q26HeP5Z4mR23EdambLvhyCbUWCQ5xXRUt0AiKHQNHj2Bsv0
         /ntnenU3r2vrTNoSXbJjon0Aybxma26QlRN4HvlvW/Z35b8VdeDFnWjD0AUEfy+F8dVn
         lhtqKtNXwrR5NSRixZbOz5bbhc3s5f7jriNjuj0qdl81n6cDmfGnvjRIfL44KXTjNtS3
         MqRw==
X-Gm-Message-State: AFq9FYL54tWkMCpq5TjVP6Cp+Qyi0optNJV0OS84WR+Qy9iStyD28+K2
	G24YstznDt46C3IAti2OygQi0SWa2GGbyYTZQCeNSmb6iUA2boYIdTk3
X-Gm-Gg: AYBFou1tpW1Af1O/cuPUg1fndoPAfAbai4y8ZzVe0REH3OVFEc4VUUBOVMVBcqYm1VB
	Pv2NWoIF6/ankPMDuU4mOQ0uqDk5q3APzH1rH7qIkR9V9O3/f0Jn4MKG5sPVDSiGGz0h/lCs5ZY
	PD5gU7+nihV9n0dSKJ8Xz51Ig084H0ciHF6n21kssELrx9X3z1ViXL38kfT4WhKS9OS0g7k4BgI
	IVTVLxQCvPoI3YG9u6DPpXdgWJcKhzIogGio9Nkhvxgi//YWZObQOwVEocWpork6THgmNidjVE6
	uglcOM0mGt7dCKHvF4D0Df/0YmDzyjp3Zd/CUVy/D7B7wXQiP3oP04IpUXPB4NgggZtwaWMAqvk
	aokl4i9/rZyPByL8Zs0rDXpa52lGnYkNXKjSdgiCk2fDwo+C7tBoV+izsIHRt7JvfCdHiPMR7nW
	s0ttQeKjvvS1voVNYiDksfeIwmPLRlpsw4m2OKGbkCztKW/0UQ26gz9tcoTqPipxbtnq7l1f/rp
	NOZ/9RxiixbktSaFTm9iw9t0abbEg0ssb+QNYJv5Nyq7zCPRXvBuugRyI/gPm7EniPSSXL8ZHSY
	cOikriEm/b5lKU9vqxI=
X-Received: by 2002:a05:7022:b883:b0:166:af48:a2ba with SMTP id a92af1059eb24-1991b9e5d21mr6638588c88.0.1792951404502;
        Sun, 25 Oct 2026 11:03:24 -0700 (PDT)
Received: from youngkk-vm.localdomain (67.216.200.102.16clouds.com. [67.216.200.102])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-198a2e32479sm16268355c88.21.2026.10.25.11.03.22
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 25 Oct 2026 11:03:23 -0700 (PDT)
From: Cheng Yongkang <teel4res@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Cheng Yongkang <teel4res@gmail.com>
Subject: [PATCH] NFS: keep in-flight slots when shrinking the session slot table
Date: Sun, 25 Oct 2026 11:03:17 -0700
Message-Id: <20261025180317.349421-1-teel4res@gmail.com>
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

Assisted-by: LLM
Signed-off-by: Cheng Yongkang <teel4res@gmail.com>
---
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
