Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.178
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792951412;
	b=0wUpt64N8x1qeHLfnj5jOUAvWhB9L7gXo2v9wAxO/ns5cNxELc57omC6zi3sUU3Cst1C
	 PqGQPOM+37WNqU/y/3REUmwYG1ezI/wldHIeY1Mr4fhnevEhvj2nUWjV/tYX6UL5M/00k
	 gHr8m/ESLG1ztQQXvXNEl7X+8VYQNjY38pDydh0/zG6lrGRvr/9RxnEH5ucEoBzTJAe2V
	 mcoOXAc+4Qv4FWQOs9mHaxpuVBM8ssuFOIwTAfHQy8wmyNUxwi0ToNwBG49EKrblTCcK8
	 j44H/UD0GS7vq6xAu8z4HSJBLLhsdGVQQxQ+yzR7axrCd4KQgJG7kSrYeBfuCyxtvNQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792951412;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=ibB05X29AOxiO6eN+tzSsFBh2h9+iozgZjegt4o/0I4=;
	b=LZi873BnDbfE5w9b19s7MxI3ikP9FmFWl5zeD4oJB+3lpVklLHZHpGqmGsFElPZEUbAB
	 6t2DFz6NSPjMJogvmNXlaVPrFKVQ4hQBebYUOVTzZJR0eqOX0c31spF0rELaJ6Yuj67ZJ
	 tpqXt7YGsHZXA/kkkTk+MAHP/bhHrq+i+zRDms7/lBPwzVh46FuBGsFh8pVQ6ZEgMNbXm
	 +Df2O+E4uHpvteBASjkgy6lZ1Gertsv6KYa7eXB3NwPm4Z+Br1PzRCl0zslAiRyXnya9i
	 3gGJRjggPFzVNena5FEaCIMDtxAIGD9WpV9KjekXuTimQujYyY/+k6USQeoyNbYOXow==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b="rczi1//C";
	arc=none smtp.remote-ip=74.125.82.178
Received: from mail-dy1-f178.google.com (mail-dy1-f178.google.com [74.125.82.178])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D8F8E606A32A
	for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 18:03:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D8F8E606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=rczi1//C
Received: by mail-dy1-f178.google.com with SMTP id 5a478bee46e88-33bf40b0c8bso6707571eec.0
        for <linux-nfs@vger.kernel.org>; Sun, 25 Oct 2026 11:03:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792951411; x=1793556211; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ibB05X29AOxiO6eN+tzSsFBh2h9+iozgZjegt4o/0I4=;
        b=rczi1//Cve/pm0JBj7VD8mvoblYohSSibn7m358EW4h2aQF2zXOmWfmZMnB5x1kSHe
         ND1fcRr1wa0ggqkVGzwLcuRmq39Vw3OQYrQAzm8DZlD0C/TRfSeoODVJiGGmuQf3hKTi
         0lD+zG08VwdSoDIERsYjecq21QDZXJymzOjZU0eULxue5rL47fbXnS5nk1GTcerJDPxC
         R1OvlyA7MKX9Pdbv7/V8fR5i5iWir7RtGEi0aaG3mSVR1ysrGMs987G9xHyQge+U5Ptd
         6CmED/1WAqwnRdnW5SXeK1J+aQ2cc7aNIlYubeO79GjIogmjD9dbagO0ggKZqWteYwkU
         5YKw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792951411; x=1793556211;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ibB05X29AOxiO6eN+tzSsFBh2h9+iozgZjegt4o/0I4=;
        b=p4mjETTl4vrYR2h5oAI8ke5ReyulW7qlnLK4kVUc89brh3EyzcVtHXsgQy3PWq3Pp2
         BquxGj+9UqglwzT+P6rPMi53xfHAVnL+1cMvPXUXAm5J/fZ12JdgTqCmapQDyj3wRuaK
         valxUa5T6NA0nEzLeO6oLGkp7Eg+7065qnmFCSmi8rFpuxLIX1fEIbW7oChs9WUDajJi
         0iNQNtg8bKVzzZom6cfFiqnXcBGhUuWCP298VjliRQRBzS7Cl3zcqiQxAB581YmW67EY
         WPfnZHk6xoZAm6yqyFb9IidSzhdbx71TJeNCnP5Ct01wIlbyWhZtFrnEeNkY1UgvgJaQ
         SSYw==
X-Gm-Message-State: AFq9FYJQuptWzljUEtpQ0hzTUYMk2KEHzVDRbWUX8V4g90FipAEbg/O9
	vVJvDXP0V/lZpiXpGH/84iC4OjydqRepH1jRvB651ApERQSEA2K3nkDQ
X-Gm-Gg: AYBFou0262p6TJT7r7PpI/+xc+ABET1pMgOjzcllmASccqx3PhLxuRXTL5zxIpTMz2+
	dMUYTKlbqlsHLL7ZrU6KjlVitrjOHap52nQUrQAiSeDwxVgsh+hW+lARDEnVsuKMd6q92wQLMWm
	OwlVA+bLBHz7LVcO2VwDpSW2dn5FijQHAj6st5jBK98FYoKCGTQklL8QEr5O2QoEq8JN2smKySq
	tre/ALj2T5rXqUoXdYYEm9yUhBZzkphpsz5T9MG70MTYmiZ/xEpE67rcl2qiAfbFJQ7sXougquV
	t0GQEfQMztmDvBRIeyxSMLV2DLTzwQtZWyKGhOSsHLuGrpr+mZhki2ip2SHJ05yjmwJvD3GAXKA
	g6wCnTh7FP4VK1zHB/J5NLKK3Tt6YgZwydiDb68SzHqyndZBNT+G+tATG1CrtKv4e7UAHY4ZvNl
	dxxDLeuzQBjDLQdQoPiM/wi7jaEu7k4N4SXWDF93rxtJcU6DZ8PoagmAu/JsCIYBANTH5VOJTe8
	b+U/jNQmi5nEM8D4MgyouV5rte8OAEp4i5lAiEEX4lj1RVPqgBb0tqLTo1zHcHbAKmLf3CWcJr2
	sVo1cTosyux7bKW308t1
X-Received: by 2002:a05:693c:62d0:b0:369:9af5:7bc7 with SMTP id 5a478bee46e88-369e848143amr6347728eec.12.1792951410877;
        Sun, 25 Oct 2026 11:03:30 -0700 (PDT)
Received: from youngkk-vm.localdomain (67.216.200.102.16clouds.com. [67.216.200.102])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-369e8db450bsm17323338eec.17.2026.10.25.11.03.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 25 Oct 2026 11:03:30 -0700 (PDT)
From: Cheng Yongkang <teel4res@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Cheng Yongkang <teel4res@gmail.com>
Subject: [PATCH] NFS: pin the superblock across migration recovery
Date: Sun, 25 Oct 2026 11:03:23 -0700
Message-Id: <20261025180323.349533-1-teel4res@gmail.com>
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

The NFSv4 state manager walks clp->cl_superblocks under RCU in
nfs4_handle_migration() and nfs4_handle_lease_moved(), then drops the
lock and calls nfs4_try_migration() without holding a reference on the
nfs_server or its superblock.  A concurrent umount can therefore run
nfs_kill_super() -> nfs_free_server() while migration recovery is still
inside nfs4_update_server(): the server is removed from cl_superblocks a
second time (DEBUG_LIST BUG), and once freed by call_rcu() the migration
path still writes server->mig_status and touches server->super->s_root.

Pin the superblock with nfs_sb_active() before dropping RCU, as
nfs_client_for_each_server() already does, and drop it again with
nfs_sb_deactive() on every path: umount then detaches the superblock but
cannot reach nfs_kill_super()/nfs_free_server() until migration recovery
has finished and restored the server's list membership.
nfs4_handle_migration() releases the pin after nfs4_try_migration();
nfs4_handle_lease_moved() releases it on both restart paths and before
its final return.

Umount may now wait for the migration attempt to finish, bounded by the
mount's RPC timeouts, the same trade-off as the other nfs_sb_active()
users.

Assisted-by: LLM
Signed-off-by: Cheng Yongkang <teel4res@gmail.com>
---
 fs/nfs/nfs4state.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index a5dec04..ff866f6 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2169,8 +2169,12 @@ restart:
 						&server->mig_status))
 			continue;

+		if (!server->super || !nfs_sb_active(server->super))
+			continue;
+
 		rcu_read_unlock();
 		status = nfs4_try_migration(server, cred);
+		nfs_sb_deactive(server->super);
 		if (status < 0) {
 			put_cred(cred);
 			return status;
@@ -2212,13 +2216,20 @@ restart:
 			continue;
 		server->mig_gen = clp->cl_mig_gen;

+		if (!server->super || !nfs_sb_active(server->super))
+			continue;
+
 		rcu_read_unlock();

 		inode = d_inode(server->super->s_root);
 		status = nfs4_proc_fsid_present(inode, cred);
-		if (status != -NFS4ERR_MOVED)
+		if (status != -NFS4ERR_MOVED) {
+			nfs_sb_deactive(server->super);
 			goto restart;	/* wasn't this one */
-		if (nfs4_try_migration(server, cred) == -NFS4ERR_LEASE_MOVED)
+		}
+		status = nfs4_try_migration(server, cred);
+		nfs_sb_deactive(server->super);
+		if (status == -NFS4ERR_LEASE_MOVED)
 			goto restart;	/* there are more */
 		goto out;
 	}
