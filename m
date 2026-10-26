Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793011951;
	b=FbcGKXg88nOd2TTIzxIToUdWujfNlgr11MZbJVsYX/iP1u3k1L/i0+fW/NaJ8peWKmWE
	 PeHHlbTsY5SxAGrYuS25FXwvX9Ca0NC7QwPiuef+hHn+UdVfVAf4DEVLTcltrnJujm00+
	 hzbdD78K4a/j1PRusVQeseybPr7lp2W35YtwfqcMaHJ7uO/tFEcQaLDk86mvDRqPtiljF
	 q6lZEnvZh3yaj8R4evMtBLy1V9WIRhcu5/UPAI0PGz9U0K0gGurTFTxiZUgADNcQTwFAi
	 pAXH9lKxSZrqycVCGsxh0ivw79dhcWFwRU2ylBxR5nUfmdZjoBD+VDfJ/LGli3AWsfQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793011951;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=owqMREQTLT+Zo8QWHeU7T7LGj9Otntmb2TJUoLFPRXc=;
	b=Ot/Jb3TMgH7mfqMCxbmdS+LL3MFw0xm2mewZP7HICUK2VZ+LIG6c9nwCfetqaN3/pVk3
	 ELdI/kAIvKA+pWivb/eapTK1EbGVqJ8UaH+7BuhfCfrPx+U6p4eYzcZIl1Laq9ED4mdDL
	 JiW7UQlp8IKMfYBvOSJB54nSEDdHwon+FfYEqn2KMIDc+uC03UhB5z21vUqqnG7wKONJK
	 79gW7SQH/DY7daSoeQippU/52pIvJMiSK3mCjslmafbOEFRKeCofACKWsR6l7Lhx7nbRf
	 nV1nErmBLfbdS6krXKoG9S8t3AzoYpBny5LcsMYyJC+U+u9P6WY7DEuJp8BxqV+qAew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=r5er5cJS;
	arc=none smtp.remote-ip=74.125.82.44
Received: from mail-dl1-f44.google.com (mail-dl1-f44.google.com [74.125.82.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 09FD2606A322
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 10:52:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 09FD2606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=r5er5cJS
Received: by mail-dl1-f44.google.com with SMTP id a92af1059eb24-19305bcb72cso1892842c88.1
        for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 03:52:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1793011950; x=1793616750; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=owqMREQTLT+Zo8QWHeU7T7LGj9Otntmb2TJUoLFPRXc=;
        b=r5er5cJSvzXwn7jDrT11oN01E/bRxlwHFle/7BGfEoBV8tSk6Mw3V+nk81Dhd3GQcT
         MCb/IWLYqiCEnymZ4eyPewC5XV4shu2wdobqXW5U0EjqcNw3rmrStXNvSd+cIsJvMF8b
         xn8E2S3A48PMPAJiBrLWHScTUHV0+joxI8xRgKSwF3bwzE2cYwDh96mt6JE4hO3jbaRR
         +wN0dXxYi42CtRUROnKsQaT2w5NK2RCLZrAM+dNkkXhXCgWMkMFxrCAK2rgz2K2cMG7R
         WEV0IdW+MdsFj+95Mf/lrGhYZlFcC6qv4+L5c1aE2TnUHbZr9BzlhYSZ6/cBXKhAdfX7
         lYTw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793011950; x=1793616750;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=owqMREQTLT+Zo8QWHeU7T7LGj9Otntmb2TJUoLFPRXc=;
        b=d/XNLMCCOD6uqfLc4jA64u09Gvgdcx7RO4+3oiUvX+LtZ/lQhyK/hTs2T5MU1l+ezX
         a8JoITH4LAecTkn/YWLdLB+bPHItxDcnsghHMVKRHVGo5ohm8YNTjxPZscZk6uOYwGO5
         qqay4r+iqvXfj5YYxX09UxpIEV288WWRzq8zVFjcx2od/O//Svjzqs74eG/2jkSnCWXo
         WEKb9sImkX6Mh8PThK53Nqmh6uTIy2pMOCnXESVg6yWJ95z04NY4OHdVQov5xPpI3KtU
         Xz6L03Vg4xZ9N9REGMmF1LYpSIaWBZ/uBpbb1AbNAsYxipknMixjkGiQjw2nn6Ugnb9o
         px3g==
X-Gm-Message-State: AFq9FYKcuR29DDhafa4sM6br4azhM0Sx6HDM58Lkiou7k8q50JE+rQ4F
	0AZLpC/KmrYmY/y1/cACYqkldj5EDQmYaJlm+TFx+oESf+1QroU41/zWwGMH1IatlZk=
X-Gm-Gg: AYBFou1mxgetFbspvla3asUcaE5UDDxwUxvdKScbWY/wiMEYJTQ7eECzF2BijDWuRKg
	DtQ4xPnUowcLQWzzcMBuDTWInRSd1uPnnjfidfFRYdHpDkILGujNdfbswtYKNTSPw+3S9t310ZC
	1+QiKjXe8mJtEBTJCQF9SXhSRUMrMNh1+lgmGSoRdUkhADScvclYbY7o+zYTr+9AcOJar2iO17i
	GKFxcmsdVC8UGjGsnXmL1gYgpo31Rx30w2ctgyeBQr7uTwx10h4OudLM6aHYT7vqYSc1KNPTTO7
	aifiFH/Z2e70tBAt1jGWxyd46Z/J2qB85Sy/xO6n3IbPlOoKhFCu/MD9oUHmgwrkrbge38YLBYf
	TdcsHS4UUGZL7JXJPuu+I4i5LCPuLC5QNSJEiZFUxNAInyPb+Gt9U1MUaHOzHQ1D6l4lMJIhWV3
	lsCOr5yehbLHfrfCOmzauXms9CiHndRIc/e+2wqfCjwxP3DVdt/EN0srwZxJc2m4wf5YGnw3lwm
	d6cTPD2j9jf12VdHpRUaxPiRDxm0Twdp3a5tfsNLPwTg14uDkTgMU5V8DHBMPDeixrhhnD4vM2I
	qCRsQYvC2JUUKwggNLckNPrsr7/KRaGhzij+zcDY
X-Received: by 2002:a05:701b:420d:10b0:169:bef5:f445 with SMTP id a92af1059eb24-19928f14c3emr10337456c88.4.1793011950077;
        Mon, 26 Oct 2026 03:52:30 -0700 (PDT)
Received: from youngkk-vm.localdomain (67.216.200.102.16clouds.com. [67.216.200.102])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-1989ff2ee69sm32439171c88.4.2026.10.26.03.52.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 26 Oct 2026 03:52:29 -0700 (PDT)
From: Cheng Yongkang <teel4res@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: [PATCH v2] NFS: pin the superblock across migration recovery
Date: Mon, 26 Oct 2026 03:52:22 -0700
Message-Id: <20261026105222.1150121-1-teel4res@gmail.com>
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

Link: https://lore.kernel.org/all/20261025180323.349533-1-teel4res@gmail.com/
Fixes: c9fdeb280b8c ("NFS: Add basic migration support to state manager thread")
Cc: stable@vger.kernel.org
Assisted-by: LLM
Signed-off-by: Cheng Yongkang <teel4res@gmail.com>
---
v2: add Link, Fixes and stable tags, and remove local validation details from the
commit message.

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
