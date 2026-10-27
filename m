Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793126722;
	b=ZEgT6bZxSQrG8MZ6yqaelb9Tgt3vPXdc/p/CcZPWjjP5UvEXbrojxMllRfihcWZNv/2u
	 5Pb8LxJaxrSPtpC9FP9NqnD8eNfsNjwvbi+GHXiY37I9ZUjW99Z3bSH+HVhi8bCJ2zsRw
	 49LmxaNMZu72aUCLyaKuelLDu523m7+H/RhBN1Z1UwB5lgTeRllIFFWET9APyatubQ6Kf
	 2YjvujxxfrDXp9pquk3wuLWTTOPnc4hOP9WrJG1ysntcRANSpBJY7DzAmID60io0Z3tZk
	 QVQnLmy06u04Zpe3Np3acpwP6smWZpXavhLUuOwM4gE/u3vvKV/W8EvTGoCl6OleNOA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793126722;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=HtfT7+TuQFdHDFrMCkt53JBSEmzI8YmVvsitEWAmS8Q=;
	b=OsullW58YbsbHlG4W/nHZUpu25lMHYsfcWM4SDPEAl+lZi5t3knYNlRDceCmD7hrhovQ
	 lV71b7Mc5O1q+t68NS7VX/RQ7ateNPamE65oCFhhU2sA073pw1bqhnhF5HA6tAvG7VZc3
	 aZhy+OfQPe7UG6/VC5rkLEnK2im+i3oLVLkm+l22qeOctGk2EaAFrN+LDo4lncF+10LQl
	 LObi3jV+wIxZpxBDPNG1L2rISyuPW8FbMT/49JggEwZdGv3Jt5cOpbHXLRsT0kaC8DCsz
	 O73wZ7KGv9w60ebjSrIFP0XqNFVZN9RvUjaktkPz++YouxGeXsbvMxK5l63tX+K8yng==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=fgntN1pP;
	arc=none smtp.remote-ip=209.85.161.41
Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3A98606A31D
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 18:45:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A3A98606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=fgntN1pP
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-702dedeb70dso198637eaf.1
        for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 11:45:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793126720; x=1793731520; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=HtfT7+TuQFdHDFrMCkt53JBSEmzI8YmVvsitEWAmS8Q=;
        b=fgntN1pPH61kmYMhcTYwfIvbSmIpC1brr70qrOb84xgC/WS4RhqxSvX0VkVQlq0N/6
         ZDWQAQr5N23WyIaOhTJSv6/xgXu3WwzSZ/SsWbUJb+z9phtNPApaOFWqnzdh8mtmRPDM
         8wIdWelLW2s4RxPaQCWDtPAh3cfj2yRHri8EAbdZ61wpyvZ5yKysDlcDOZjf7zVfO2XT
         lgNXqhm7DnHCVV987ir5zcIVdz5mkg6aqG3uzIt9W89q7+NBNGRNTZ6WX+zzRr6nCyQ9
         9UKYSPa3llYP9NhbkDA1xBJkeKAlUAXjJ1zyipbphL+IF81/xszXlrxhuyp8oclXzwLx
         51zQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793126720; x=1793731520;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=HtfT7+TuQFdHDFrMCkt53JBSEmzI8YmVvsitEWAmS8Q=;
        b=OLk4MrB+Fj5MAS0g2XzSWoEbkxnXcVTqHZwGG3qRW/g96RBWKX1X7h9CxNo14SHqbS
         hIRhAHgI3R4AAMyUJJqujfzDjgWLuy8wtdE5VIQHJiDhWnOTlgN0YR73cihN19VEdQ+y
         UrMuaBCMHBGASyabCkq/cAQv9VCvQ97aAyO3aB7wDU8pOb/Sp4C0BKAAk0K02rUVNMJP
         X8hH4mafSMdlG4b/DO/hYrKTTByUJr0pG/St1quBXjwWw+K2DbrX+uV4SEO7d/UJqYYR
         7q12oxtwEioWNlxuc4169cjjd/uPrJ991hfwAk+Ow7QrFHTnCiuLfwJJIbGxFKalhK0r
         0AYQ==
X-Gm-Message-State: AFq9FYL/dbSQ2CjcVvsLZXxHo4xmbYeIbzrioWBS8IoBGLRL8R1dwiKq
	G0bqopTUXrQTsXkqTDHN9imIGJSFpzk6DNOafZnItliBRNbgnP9ZAuzWnnHRrhaLmfh51UWIElO
	UhnZQ
X-Gm-Gg: AYBFou3F5AUHx/CGVrRXyZokOk/L2DRn/24nL4Hl+1o6d2RUMK2yC2gZShuHeM5VhlY
	QZDJfYBL5qCrsU6zYUecrR24bH7kvDfmvSjtAxIMSj6hWrSR2GvBut23H3E6Mxl1hz1c7dlVGus
	KdC6w8bfJJED8oVD8w4/KWVQmbw5utgLNVJAc/hWEpXKBJCjqARf6oFw1T0ZUX/zCVhnQ6Mwxna
	CDbcyBMU3J9YZat3A1dPnVUz9Ga+r1QdNa40vTzwMgKQ57Zwak4/kN2Z3oErUKnnQe/wgfVgC+X
	NTntW1cHOVe+YPpBhNlj2cR23JHRSMuruz4hqImXjIkZ4dIBV9p5/HKA3TIn3RCWarIMCXYFItb
	nuXg//i1so0dg339ABfwy1LJ4zMt+IZMJiV0vF5kS8QPPEejQj6WrYvZLHXstdYKbvWd9hXl3To
	zlieapNqMyVSwc7dnzGjI09rD9iJVnKIw8iXsgl2pPF7dJ/sxWf12CV+ay8AJQwzKgv9OZIGtdz
	bz49UYoR8c0ylmPLnZRdJ3W3ZMNz5P0wAxMowYqdbaFUw8KdZ40WTSIdHBHM3/AwreGFo5vVnVT
	r10yAxafQgNGC2jOcYysSvUg8qzIrROHRFnYqE5Pqcm99PE/
X-Received: by 2002:a05:6820:a093:b0:6f8:124f:d4eb with SMTP id 006d021491bc7-70ba0f58951mr5475386eaf.69.1793126720441;
        Tue, 27 Oct 2026 11:45:20 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-70b9df06ef8sm10254326eaf.4.2026.10.27.11.45.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 27 Oct 2026 11:45:20 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pNFS: don't send _NOMATCHING_LAYOUT if still doing IO on a layout
Date: Tue, 27 Oct 2026 14:45:18 -0400
Message-ID: <490422e102050d938d9aca83b4e00b6687978e32.1793126664.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
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

From: Benjamin Coddington <bcodding@hammerspace.com>

When a bulk CB_LAYOUTRECALL finds layout segments still referenced by
outstanding I/O, pnfs_layout_free_bulk_destroy_list() invalidates the
layout stateid, sets NFS_LAYOUT_BULK_RECALL, and the client replies
NFS4ERR_DELAY.  If the server resends the recall,  then
pnfs_layout_bulk_destroy_byserver_locked() can skip layouts with an invalid
stateid, so the resend finds nothing and the client replies
NFS4ERR_NOMATCHING_LAYOUT with the I/O still in flight.  The server then
treats the layout as gone, and that I/O can reach the storage device after
the recall has completed.

Don't skip an invalid layout that still has NFS_LAYOUT_BULK_RECALL set.
pnfs_mark_layout_stateid_invalid() reports its remaining segments, and
the recall is answered with NFS4ERR_DELAY until the last segment is freed
and the flag is cleared.

Fixes: b85f562049cc ("pNFS: Skip invalid stateids when doing a bulk destroy")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4f9c0f639014..20794defdc1e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -853,7 +853,8 @@ pnfs_layout_bulk_destroy_byserver_locked(struct nfs_client *clp,
 	struct inode *inode;
 
 	list_for_each_entry_safe(lo, next, &server->layouts, plh_layouts) {
-		if (test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) ||
+		if ((test_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags) &&
+		     !test_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags)) ||
 		    test_bit(NFS_LAYOUT_INODE_FREEING, &lo->plh_flags) ||
 		    !list_empty(&lo->plh_bulk_destroy))
 			continue;
-- 
2.53.0

