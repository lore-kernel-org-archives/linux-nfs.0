Received: from mail-pz2-f39.google.com (mail-pz2-f39.google.com [74.125.228.39])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4D8E13815D5
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 08:31:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.228.39
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790584319; cv=none; b=EUl6GdI3OrYg26OrxUBeIueHasR0WeQLzNsr8ylp7dbLdqbXLT06qOAuo3Axzd6TzHER4rtqeGXwA8c4YUHGgPEMAzm1Xvhl4LygaJG4hlelnnVpeYXBU4Vuk7FIkoNPPmiQgcCIOis4m0R+0G+9iWtFPpXex2nwUAFD5TKAiaE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790584319; c=relaxed/simple;
	bh=tNE2SiNyV7dFCizcodgZKxqpGhdR985cZhktvzC0eiA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=rAZGCwLDJwmJoibmsErNwk7Yt1guzPii8T8eQMGbBuoElEJ9L4KVSde9nm2FbqpRmRYA051mgIBeagn1A6d031wv8WppQPq2sSOKB4Hg1rOO47/s2ZZjng4ily53NLu+L5DKtsK6qcmHo6wfEMRTuEuoez3KePNIwS5xKR1AKZc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ZhtXl1UN; arc=none smtp.client-ip=74.125.228.39
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZhtXl1UN"
Received: by mail-pz2-f39.google.com with SMTP id 41be03b00d2f7-cc7901f7971so770936a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 01:31:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790584316; x=1791189116; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=MQyzfAJLEkidGvzjgIIjeRW1owPxWg9f7opLdpOhToA=;
        b=ZhtXl1UNKfL6GaHn+/P6DG1/A4OudL6Vwn31brSh/3DSrnQslxogFBO9Ihv7fB3Og1
         WtTby9PIGNWHWPzB+ubrhHCPgzpxKpgLLiMiG25iMOQ4RZqmKPp6SAL5iQKFfgmQpn77
         T36xlLHlj6v/3L2HY/YFaq4BQ3NTEXTbLkjSnNoVTuhcU0tzA+9duP4zz58KAYZcgo8U
         N0sn76C8ZUWToPKVSzIb3NZvdRhlhMpDXThmyXPXJrgwVatgsEyUCfT0S7TTygvpU5bv
         jd3B0y0B5ULiEkLmodlnH2P/KRWevmEyFyGBjRmV5wPTdY/XtNszVGP2/RSagJSTYgo/
         WH/Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790584316; x=1791189116;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=MQyzfAJLEkidGvzjgIIjeRW1owPxWg9f7opLdpOhToA=;
        b=kmnCCUA3oTZMVVaIWBpGYHOXCrTnZ4KNYUG0uMIKCeqDSFJbuGSuIgggq4apU29vQs
         GCOgiosb2X9P4kPRIbgcCYMtd65onCGdGnnRnBJVx/rNN7LSLMaQRIpiSx6gLMFpgd6l
         Rm4oShRSNFcmZJIWHH1+LDzFUsR9HdOFfVXz/0StaCFIQTu5aUMySt7qHfpTXYGYD30L
         +EIsl7NSva83m/ovgvMySR1Ae5WwSg+JXbsDYqFsAOPuJtgMlRU/YX/25myP237EWwrl
         17bNGJ7mxC9LDWtAkV6nwy3PildqRGk6Gem55vNO8XOyH4N4VCi8h2y2XMEgobPxI1kY
         65Rg==
X-Gm-Message-State: AFq9FYLoKXW0Mor4boasxHhmByFv/sFLnshjbWcFYU295jaH/I4cos+u
	D2CfA6+DeOy99pf9Dl1bHNvXbUc+GHKOBaRSeiZni7FjJhnhnR2ee99+5BeKDgrAbno=
X-Gm-Gg: AYBFou2LtroIPcj6nzi6WDJC0dbU1ag8T6XrIWRGor4VjQ+XfGn1aBkjZUnLWpC+fv6
	IhZrgkJhtMpEb57oPkWdgvVqCjzgHoaoDM+vvjZl7G7k/hxARdR9Sv9toTUVqOjvkKmf13pUOwv
	r93rUjsX6jL1tsH1qvDsOFpkzprRnUkhpObW1wuJuNuM5vdNtqwIY7q5e6XoHAAirA2o33hBOv6
	5rHPFmM4z3bzeXZW7s0S61Q/bXYjtzH3+jKeFAhMG3X+QXvtBzo7NH6d7/nDi6g02t1IbGEziyT
	iD5NvqIZ3aDe6unRLf0D/eG3ZcZSoWB/PjDlHRzA7LnXL1uVRmDKSqBOGPaFeDtdzc4szYcVcZc
	8GbNDHUF1eOMIBNp2VH5IfY63JOBdfsoNsOs8vblAauVreuOAJk5Am3aXyXJ+1sUTIt+idl0ktI
	1KwRaYXLAYsgNK08i3uU7AdOrifNpPrmtFBgj9EJuqgBxt2UqB+2jUGS89QnIKM+33E3UDbzzDp
	uDluLM=
X-Received: by 2002:a17:90a:e7c4:b0:39e:6c6a:4b73 with SMTP id 98e67ed59e1d1-3a098e3eef6mr10713420a91.61.1790584316390;
        Mon, 28 Sep 2026 01:31:56 -0700 (PDT)
Received: from bintable.localdomain ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a0e0ec367csm4853973a91.4.2026.09.28.01.31.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Sep 2026 01:31:56 -0700 (PDT)
From: Jinpyo Lee <bint4b13@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Greg KH <gregkh@linuxfoundation.org>,
	bobtobabz@gmail.com,
	Jinpyo Lee <bint4b13@gmail.com>
Subject: [PATCH v2] nfsd: hold client reference while reaping async copies
Date: Mon, 28 Sep 2026 17:30:50 +0900
Message-ID: <20260928083050.642664-1-bint4b13@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd4_async_copy_reaper() moves expired COPY state from the client list
to a private reap list while holding nn->client_lock, then releases the
lock before destroying the stateid. The detached COPY state retains a
raw sc_client pointer, but does not hold a reference on the associated
nfs4_client.

Client teardown can therefore release the final client reference after
the COPY state is detached and before cleanup_async_copy() releases its
stateid. nfs4_put_stid() then follows sc_client and accesses state in the
freed client. Generic KASAN reported a four-byte use-after-free write in
_raw_spin_lock() through nfs4_put_stid() and
nfsd4_async_copy_reaper().

Add nfsd4_get_client() as the counterpart to nfsd4_put_client(). Take a
client reference while nn->client_lock still protects the detached COPY
state, and release it after cleanup_async_copy() completes. This makes
the client lifetime required by the unlocked cleanup phase explicit and
avoids open-coding the client's internal kref operation at the call site.

On a KASAN- and lockdep-enabled kernel based on nfsd-testing at
cab95e6be3ba, with only this patch applied, the reproducer retained 512
completed NFSv4.2 asynchronous COPY operations. A cleanup kprobe on
nfs4_put_copy() recorded 509 cleanup events, and client expiry completed
without the original KASAN report, an oops, or a panic.

The reproducer uses the administrator client-expiry interface to place
expiry at the affected cleanup boundary. It demonstrates the lifetime
error, but does not establish a reliable remote-only trigger. A source
reproducer and the complete KASAN log are available privately on
request.

Basic NFSv4.2 and NFSv3 read, write, and unmount smoke tests also passed
on a patched KASAN kernel. An x86-64 allmodconfig vmlinux and modules
build completed with CONFIG_WERROR=y, including fs/nfsd/nfsd.ko, without
new warnings.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: ac0514f4d198 ("NFSD: Add a laundromat reaper for async copy state")
Assisted-by: LLM
Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
---
Changes in v2:

- Add nfsd4_get_client() instead of manipulating the client kref directly.
- Expand the description of the lifetime bug and runtime validation.

 fs/nfsd/nfs4proc.c  | 10 ++++++++++
 fs/nfsd/nfs4state.c |  9 +++++++++
 fs/nfsd/state.h     |  1 +
 3 files changed, 20 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 7df60abfb..2593038fa 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1608,6 +1608,12 @@ void nfsd4_async_copy_reaper(struct nfsd_net *nn)
 			if (test_bit(NFSD4_COPY_F_OFFLOAD_DONE,
 				     &copy->cp_copy.cp_flags)) {
 				if (!--copy->cp_ttl) {
+					/*
+					 * cleanup_async_copy() drops the stateid's
+					 * final reference after client_lock is
+					 * released. Keep sc_client alive until then.
+					 */
+					nfsd4_get_client(clp);
 					list_del_init(&copy->copies);
 					list_add(&copy->copies, &reaplist);
 				}
@@ -1618,10 +1624,14 @@ void nfsd4_async_copy_reaper(struct nfsd_net *nn)
 	spin_unlock(&nn->client_lock);
 
 	while (!list_empty(&reaplist)) {
+		struct nfs4_client *clp;
+
 		copy = list_first_entry(&reaplist, struct nfsd4_async_copy,
 					copies);
+		clp = copy->cp_stid.sc_client;
 		list_del_init(&copy->copies);
 		cleanup_async_copy(copy);
+		nfsd4_put_client(clp);
 	}
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 0f9340eb2..05937a504 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2805,6 +2805,15 @@ static void __free_client(struct kref *k)
 	kmem_cache_free(client_slab, clp);
 }
 
+/**
+ * nfsd4_get_client - acquire a reference on an nfs4_client
+ * @clp: the client to be acquired
+ */
+void nfsd4_get_client(struct nfs4_client *clp)
+{
+	kref_get(&clp->cl_nfsdfs.cl_ref);
+}
+
 /**
  * nfsd4_put_client - release a reference on an nfs4_client
  * @clp: the client to be released
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index cd9294f02..2a44ad503 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -952,6 +952,7 @@ static inline void nfsd4_try_run_cb(struct nfsd4_callback *cb)
 
 extern void nfsd4_shutdown_callback(struct nfs4_client *);
 extern void nfsd4_shutdown_copy(struct nfs4_client *clp);
+void nfsd4_get_client(struct nfs4_client *clp);
 void nfsd4_put_client(struct nfs4_client *clp);
 void nfsd4_async_copy_reaper(struct nfsd_net *nn);
 bool nfsd4_has_active_async_copies(struct nfs4_client *clp);
-- 
2.50.1 (Apple Git-155)
