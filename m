Received: from mail-qk1-f177.google.com (mail-qk1-f177.google.com [209.85.222.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6E57250EBFC
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540821; cv=none; b=qwd1bx/7fxX64yw8A7ligt/AYQAeZOg0bZx/tmODoGR+foIN9n7d/wNYw1H5IRD77j6IKFCqCXOoDE/8mcDKimfS6Q6gdsdye8D/lyZD56G5Lizb9wwf/v6op7O++tsQkZ3MtmThp/po5QEqG3pcfpIIpeZU1k4KpuPYZ6diDTA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540821; c=relaxed/simple;
	bh=UuVNP4HW+miA5JkfQ+A5x4suf/kjiQeN8JVMW807C4Y=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=r7C8cpmDRbXO607rBoikt4/IkxffkP209pSqEaZ/SZMOvo9NHZUyc9uCQLYIN2J275UfAGQaNoCi1mrH8y4Qr4RN8XYYq5KaqE/JeoAK4eocMpBWPyTs8294F/NEhQkbQmceL9rhCLlCozFyrjB9NyuKHn8+9s+dz8XNmVIp5j4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=HLV4GfZR; arc=none smtp.client-ip=209.85.222.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="HLV4GfZR"
Received: by mail-qk1-f177.google.com with SMTP id af79cd13be357-936c02e58dfso123857185a.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540818; x=1789145618; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=JVUbSd0gXwK3bMzJ0b3lx8DJ6BMQoxZfiWMTLNw4tPc=;
        b=HLV4GfZR6XU3up8v9gdf6xYfpH+MIFMUuzoUUd4vQ5EUTAIOP3FY4p02Cmo/vkAhX1
         6L4Hjd3ot4hKGbAXYe8wVI3Y6i30VcXv4Z9lTra1nu6giS27bajMdKKlhTBobTdr/w3y
         byISBRc0D2wC8sdIP6QBUiJ8u1OUuXahk027EFWirEaDdIkNhRbzHk8ZGmIzFgjFK5Yk
         uU/o9guNxDJtwVmE6TTQhc0NiFxg+wcjxuVKUOrtNWWyiuVjUjTtKPMgGGWfL68JN/ov
         nbBE33Jbx7x1q2DtAvpMBUM6GBmVDs/0DtdINO0dWKavo/AeSBIil10X1LmBbIi9mW14
         IU3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540818; x=1789145618;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=JVUbSd0gXwK3bMzJ0b3lx8DJ6BMQoxZfiWMTLNw4tPc=;
        b=IBNnThD2TJFXNoV6QwCe6YMkv3xtEKOmRghNCSDA/6UrWPNfopa5tIX1/ePsWdD3iP
         DcxGSF2nZDqq+U/jfUTWJNtTZl64YBE48r7msA3BvSdQZLD6SLEzSOUaidwMwutv8CVw
         +FpGfZvYHzdrZUkIPiv0SW07RPIkwEvqpRnb+CzUOOgeYjSDEgioOaUI29dhH0jEJDG4
         vB6KbZ595uGvMdsZ/ry0zVVwdKfQZA4Ncx8HXq3YQNF6gm3p8IML5OlPwJONlhNISLoV
         stBcBiO2vOUhAUmrzHStozvUucp/HCz2SD1m7mJErYF6ndoa9JgJ+CUl4evDGUuDflHL
         idyw==
X-Gm-Message-State: AFuF++mv/Z59ibSd8+Xxc/ZHqAUfx8d+pjyEmjqeBCBGyxMDQGD9QXeV
	RVbKj7Ce9uNrVm6Uyd6TW5+mtm2zE3kgcV5Mpj0xzJmoZDJW49Yl3pxgi458t7Zqkos=
X-Gm-Gg: AYBFou3E6Ch+UO78hw2Ep8w99QIx4MvOmQsGsEAP/uSgKVPiw3ZRMqpQwuTfGW2sENJ
	zsIP851bHSm9995UIoJUL+3V24CkPJmHkOV2uThSdi0MNj5pm84I+7NQMYacNaGLalWzbHw3Dsn
	qxyX81yq8oN1M4BcM5GGHR++Og5bx9fNYo7sckiBgJzxXdvqPNZyBnYlZREa5BD1VKe3W8y83LN
	pl7yJ01INq6jinaF72xORhOPd0AqD2u6KDS+CjGYb4F5Pq4CG4M180x/3lTEvKNO5tQhKFJ76IG
	QKGfFUPjh47wFyu39mFk4YsBQaQWR42eDxitEGLYaZjUxR1Q6DyWZjPogBqgRSE3BOgmzuTvxG8
	jAcQ5O+rvOXinjW8Ak1zyVcf4UMw1NkMI9C5fsAJO/IMk/h8149cR3duQpXcyNM5/GS20Pnt19U
	UdMGaRk+YkPjJXTPCyXr5Z/ZB2BB/7E4iuhII01SDM6WVPhyAUxF9yYO5le3+QqmRc2PX9O+j5B
	UTyfCLP8HtNesfXrFfIVphE
X-Received: by 2002:a05:620a:618e:b0:939:1483:55c with SMTP id af79cd13be357-9398034757emr731426985a.19.1788540817868;
        Fri, 04 Sep 2026 09:53:37 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:37 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 15/24] NFSv4/flexfiles: Honor ndc_immediate on CB_NOTIFY_DEVICEID CHANGE
Date: Fri,  4 Sep 2026 12:53:14 -0400
Message-ID: <47cdf067fb0582ff5cbcd229f3781787095d9701.1788530385.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
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

