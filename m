Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D8F33B95FA
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474971; cv=none; b=GqNb2rSX3cvBR9wB8Nx5eYGk1Ekjk36UNqqnQm5FuZx9f3wPw6pCcG93vZ8OmYqrSQl7eWYOJmkNZLwC79eK3JHK4JZbazEi0RlgYy4lCuHxmRJeD2zsJBdZyQXtxwyRbtxcjODdkIx9AyC0nz2s0w7RjWSlAjHyMEElLlKc524=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474971; c=relaxed/simple;
	bh=UuVNP4HW+miA5JkfQ+A5x4suf/kjiQeN8JVMW807C4Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fbUgWOEYGeJcoEnx4c58jQ0RxVPhkCjzQuZIyHwsexeZh5Vd6b1xyFvGvV5gpD3b6a378qgbJgnqvDpzzO2KQKqoDE5Clh+x/sNbjINlJ5WpdA5UCNBxMJINdo/Ja61fRbHOdNmdoVwECelLAR7m57kQyTJ9vYBU6eCe8syiniU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=XcoZ6qSe; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="XcoZ6qSe"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4b37a3a9768so116147b6e.0
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474968; x=1790079768; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=JVUbSd0gXwK3bMzJ0b3lx8DJ6BMQoxZfiWMTLNw4tPc=;
        b=XcoZ6qSek0BOWqjUYaaKnGSe7VRHGmNHS+qHDprz2vyJMOP5cesi7z61YG+PkN6r0m
         IJ3FOnZjJUncr4KAE4Gu1307fZ9Kr+zvL+MEPp5iKlIoPhpUJGJpaWJONxcf+K3XOybx
         bC+ia6HpRWTl3S11xa/on6pXsJ5mEOEhgA9W05lVZPAgOa0am89sYlV7Ph9+fn30kLCZ
         mJRagvQMrnw6Rsc6vqC37eRnWomi4QZ0aB/PdMMKYNljRR4bFXIPRIM0zilmST5UUPo+
         RYXAboP2Fpwo9CpSkrJHapTUgkIvGoPtebZR8OXyWVnyDxcXHOxGkHFNqkxC1aYoVrDR
         MQPQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474968; x=1790079768;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=JVUbSd0gXwK3bMzJ0b3lx8DJ6BMQoxZfiWMTLNw4tPc=;
        b=uN5ZiuMVUyb/lPfO5qfes5dEiylgRbEUgY4oDA7UF5m8yovDPWm0Nt5mOnuk+TnmpH
         1nbj1eNSArtNPvTATBEIKcydRAeIGgm9BUqHmQT7h3dXUUE44WkqahAAtDTaYtLXY9jS
         otQTejRAdQ/wy9Ph7Y9TbolW3+Q6Xq7+o4IYXBelUo7Ehk3mqa85h90knwwnmDjYBmLw
         XPBfSBJe/FQrXs6WXHqUzrR+bp6rfZUuPHLSEGTaqZBSNn0+zRCwzaMGFO87+GLShIvp
         6Jcrfv+4TnxA9HW8lWiE5jOyENqRBDwZOaCshNc9xZO4A8pyE9jy+R5TpitTQuGbQEQS
         xl7g==
X-Gm-Message-State: AFuF++mtf/9ED4HrBRRj5zJ77EQhKKQGcgU9SSGDFRH7F7D3WNja2gvD
	NlZCRbGZACYIctfP0Fru3Yw7EyXmFdhrs1lAN4F+LJaw73oMxnsMsXi25o0QbP8M96k=
X-Gm-Gg: AYBFou2yeMKKC60I0kdEPRUo8TQbMY+qNZu1KnrPQ+MHVJOzJq7f8Z6f2LLnFyWZR6G
	zCFR+kFHgQMfVGHS35ie87LCs4oBufzemZ0B1f1OM4upsRIJkbbA2d33SdYQU57OOyfOa+uX99e
	gXBxVjK8fFaXsCblndAvhgD0t51K/LJJMG0SimYj00PvyntCZ3Ya3CWWN9akMlopT/0EiK+HcXf
	zAmtrWClnPODnJLXwCEBmcM7ZJh+SxPhgTvZ1fH8Mp48HKHWieLkCcjShwNuBTcY1WLOniXEMwW
	ann7/r3v5EtEsnkohdNlkxOMGLtm+fmpR0GSoFTpfqV4Q9W77gIgewxrc6McPajkzYhWdbm05ZV
	upc5rV9GlsfDmycWJKc20EhUAB/9t13A5UBzQud8RbholwcLM4sNE492fgFJJX8DwHPKtm0SCS+
	o3vJ+FRtq/Xxp6gUdPEBLSuVf5+9qpDMhM+6mJ6E6+r7ONwZ3dcjenBdXf1J4T2D+RZxwk9tfI5
	p59UG0QMfBJlsxNoa6IGg24t8iHjLk8M80=
X-Received: by 2002:a05:6808:144a:b0:4b9:e5fa:8907 with SMTP id 5614622812f47-4c9acc9ff55mr470566b6e.26.1789474968224;
        Tue, 15 Sep 2026 05:22:48 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:47 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 15/24] NFSv4/flexfiles: Honor ndc_immediate on CB_NOTIFY_DEVICEID CHANGE
Date: Tue, 15 Sep 2026 08:22:17 -0400
Message-ID: <4c557a10dd5a54747fc13036478af1ca9652090f.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When a CHANGE notification carries ndc_immediate, RFC 8881 Section
20.12 says the change is enforced immediately and the client might not
be able to complete pending I/O.  In addition to un-pinning the stripe's
device node, mark the old node unavailable.

Marking does not recall the references already handed out.  A write
whose DS connection is already up keeps using the old node until that
I/O errors: nfs4_ff_layout_prepare_ds() returns early on a live
ds_clp, and the unavailable flag is only consulted when a connection
is being established.  What the mark does change is that a read skips
the node while another mirror is usable, and that an IOMODE_RW segment
still pinning it stops counting as fully available -- so I/O the
server rejects falls back to the MDS rather than being retried against
a mapping the server has already withdrawn.

The walk can also exchange out a node that already carries the new
mapping: a re-resolve that completed between the unhash and the walk
reaching the stripe, raced by this walk or by the walk of a later
CHANGE for the same deviceid.  Ripping such a node out is harmless (it
is still hashed, so the next I/O re-pins it from the cache), but it
must not be marked unavailable.  A superseded node is distinguishable
by hashed-ness: it was unhashed before its walk began and is never
re-inserted, while a fresh node is inserted before it is installed.
Only mark nodes that are no longer hashed.

That test is hlist_unhashed_lockless(): the hook runs under the layout
inode's i_lock and rcu_read_lock(), but not under nfs4_deviceid_lock,
which is what serializes the writers of node.pprev -- and __hlist_del()
stores a neighbour's pprev with WRITE_ONCE(), so removing any other
entry in the same bucket can write the field this test reads.

Without ndc_immediate, pending I/O drains on the old mapping and only
new I/O re-resolves, as before.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index a7fda4422c5f..9caf4b3b45ae 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2560,6 +2560,13 @@ static void ff_layout_reresolve_deviceid(struct pnfs_layout_hdr *lo,
 				kfree(put);
 				continue;
 			}
+			/* A node still hashed was fetched after the unhash
+			 * and carries the new mapping; mark only the
+			 * superseded ones.
+			 */
+			if (immediate &&
+			    hlist_unhashed_lockless(&old->id_node.node))
+				nfs4_mark_deviceid_unavailable(&old->id_node);
 			put->dev = &old->id_node;
 			list_add(&put->node, head);
 		}
-- 
2.53.0

