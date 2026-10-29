Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793299322;
	b=1dAiklNgEBYmE2uZr66rhsjk1Dv7ZzJVp6hAh6Gy+HkZFXMqFbEsfptFGGJhi1KFOEoR
	 DgkROWOrt8OfBRzYyOTnqDRjdwfhPiebhajOKb5KGn5RVZeURDVDO6W6n9gih3d4pd3Or
	 CjQoMx8sNklmrAN6bdNZ/CeaLE8N58ffTLpZqmdF5BFUlep7HrYAkAZWHVVpf2E9LPKQm
	 u1PdohL/EnTgwGWAF7uncJbnDwT8PwZiH6eZGka6j/HhItcnttmwi16FN08QGo0Z4DIrd
	 lNmZ1k+5698c89GNiKm1IOi6mUtACDTvd6SsK/KwA1d9CNOmQ//mQCl5CVo1b94iK/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793299322;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=FDwY9FtGOHDe7jNvikwgfiiT+rgUAbOhwVOZRJEx4ds=;
	b=wNmpkSKRwEwbwn9HmTojwy1TvinU0xFqlsmOQIRoSnnosFK0/0Nhu0SUuYUSNIHa5X4S
	 nKsN6fqg4vpNERQtTgxSqIJmF1tFMLt5koiHMEE0hgtu2LUfVZGqLm0Vja6TxYArpkzll
	 061+VUQ6B6bzH6FVezz7QBVtnpt317s1TpZ3BgZvfbw0SQJnsJMIEGmQ228ZWieu8YEkd
	 ye8LxHyWgeOb63urN0Ln3WCgFYxWwLCXjieWJ2RcHi5vdJoiC8SQnjGNtHy9F4aQJpBu7
	 +PeYWf/XzyD1BmOlB51IwryxDhg1oDtz3XDsnEtWQa7VvqcVZfZNDD6G8KHH5H2Wc2g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ashTaVuV;
	arc=none smtp.remote-ip=209.85.160.54
Received: from mail-oa1-f54.google.com (mail-oa1-f54.google.com [209.85.160.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 28661606A31E
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:42:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 28661606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ashTaVuV
Received: by mail-oa1-f54.google.com with SMTP id 586e51a60fabf-4877837890fso1429766fac.2
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:42:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793299321; x=1793904121; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=FDwY9FtGOHDe7jNvikwgfiiT+rgUAbOhwVOZRJEx4ds=;
        b=ashTaVuV6XteB3eKbXZOHVnU6DzKDivWXKDIQE7D8s8KoenmJYxphGK7YScOecKOys
         GkzMFsLP6s3dUPMU/02Oij7/e7i4wCl9KMS9SNIw1CII/3rtUudHB9kVN0YheeNdX62H
         xe3oaRdj5vFqfgq5EK6/3C3ITBEMUwH8jGjbvpQGdFKqoeuHj/6kNsyPDzNM3lILNs5R
         JWxznGV/rOiQ8YdsO+b0webgbickZaAqNcEW/Zfr361TLh1QVjfUgtTy1kwdBFRmSabI
         d+uoOegi78geOV+hA9vkIbk+HpCfXE5BV6Gg/GwEmpLuarxIRUiyGzuPVs00EUqf0m1t
         XJAA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793299321; x=1793904121;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=FDwY9FtGOHDe7jNvikwgfiiT+rgUAbOhwVOZRJEx4ds=;
        b=ll/+yERyYoZ1bvAg/omyOGejB/20cr3c7AA+aTV5fWPrBH7Ndmw491EtQbQcX1rxcd
         hq9fYeEYEHRoSoyThYf6AxFPpp9niPl9wDW2SWIWOyvduCOy9NinLyrqAbK80KMaEtxZ
         aRCGClZHBX0Z2pVVOGdqhHIeWz41WI8xUEm6Q2650IcIk0UgjBcttmxweTlqsTYntw3P
         qHnZEFlvhSOx7oRr+Y6rrAQwhXGWiOHETxUxF4TPRqhpEskxKrd/3tMyOB8gGrDVllip
         zO6ZroGtfjvIToBzUdvIW6/GQwwd1/1TDoHDPnW7GnH0fzACIhKNJPEUzP70zKOfFoFg
         jshg==
X-Gm-Message-State: AFq9FYIDNQpX6EhycLHSod0hXbdheQODs8Nusv5YdTeGDQ5TxDSfqWTP
	TvaZcx41W31d27FGgV0eX2J4IqoNzr/in18VAJKVR9L+lNfg+L2vpHrrEt7csY0XgPo=
X-Gm-Gg: AYBFou2U+4IuWv94rC//BX2HNHZQ4LIMD4i7X+3EWR9loIX2sLq1MM+93jU6v2MK8vp
	gVU0sFIScZnsCpA/pLVwoJDFrBc8mKGWSqjxw4nSlGavxzUEWPdQfB/jF9dzoaKIrBxWbX4UcmU
	u+mYSQVk65LIbr5n0I/jWi43DzP1+vh5WtqKFhvI80J/a0Zs2UnYnG6pjEjDPamRXFYqeqw1kKv
	mxgS+eAee7HzYi1iD1awYu7z5BYTFP+PzU3r69/o1nW6XDx8Av4KOnFUeM7bThspGsgQbte08mf
	OCoyYVXG4eToA61mEXfOxUmNlKri4IjMeERHdYUSX07yaXSfgxJKqKKc6lpS/R7dn8Zr6PtfrTr
	ztgyKH1KCaXsMVH88FXy1atpICqm5UXW4FBYDRqHvK28LlZejr2ldJvEtm7jsv08IypFJZ4zD98
	f7QQWFzjxvkwkwg75pezkbfX7DWwSPz5aWmxk2xtfsofPAhNzDJl5L49SJ7ewfTuTODTKm/igSg
	Vov9HsQsJeIb8YVxbyZqkYep2LC1aQaQBlWCIQjP2ZQdlzbNuFgwAzkbMdST0fDI2pdLHaQ9XP0
	lM1TXhKSFavdeaYJOmjdeLJ/3wiTijygj1mSVa6XLhRs1hDXfbia3Y54nbeKfgJdm08QICoWH4+
	rG68ZD5hvMTHWp8lgWNF3iQ==
X-Received: by 2002:a05:6808:1a1f:b0:4f5:eaac:517a with SMTP id 5614622812f47-5640d9293a1mr120707b6e.1.1793299320669;
        Thu, 29 Oct 2026 11:42:00 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640e23b76asm7161b6e.11.2026.10.29.11.41.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:42:00 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/6] pNFS: don't leak layout segments when prepare_layoutcommit fails
Date: Thu, 29 Oct 2026 14:41:51 -0400
Message-ID: <1e9d777dde94463e57b323a960a572fab89a61ae.1793298149.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793298149.git.bcodding@hammerspace.com>
References: <cover.1793298149.git.bcodding@hammerspace.com>
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

pnfs_list_write_lseg() clears NFS_LSEG_LAYOUTCOMMIT on each segment that
needs a LAYOUTCOMMIT and moves the reference that flag held onto
data->lseg_list, to be put when the LAYOUTCOMMIT completes.  If
->prepare_layoutcommit() fails with anything but -ENOSPC, no LAYOUTCOMMIT
is sent and data is freed with the segments still on that list, so their
references are never put.  The segments and their layout header are then
never freed.

Before freeing data, give each segment's reference back to
NFS_LSEG_LAYOUTCOMMIT if the layout stateid is still valid and the flag
hasn't been set again, so that the next LAYOUTCOMMIT, which the error path
has already rescheduled, takes it.  That keeps a segment invalidated
meanwhile pinned until its LAYOUTCOMMIT is sent, as it would have been.
Otherwise put the reference with pnfs_list_write_lseg_done(): if the
layout stateid was invalidated, every other LAYOUTCOMMIT reference has
already been dropped, and if the flag was set again, it holds a reference
of its own.

Fixes: 5f919c9f10c1 ("pnfs: allow splicing pre-encoded pages into the layoutcommit args")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6d391985fb21..5ba3ea23354d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -3634,6 +3634,17 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
 	}
 }
 
+static void pnfs_list_write_lseg_undo(struct list_head *listp)
+{
+	struct pnfs_layout_segment *lseg, *tmp;
+
+	list_for_each_entry_safe(lseg, tmp, listp, pls_lc_list) {
+		if (pnfs_layout_is_valid(lseg->pls_layout) &&
+		    !test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
+			list_del_init(&lseg->pls_lc_list);
+	}
+}
+
 static void pnfs_list_write_lseg_done(struct inode *inode, struct list_head *listp)
 {
 	struct pnfs_layout_segment *lseg, *tmp;
@@ -3766,8 +3777,13 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 			set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
 			if (end_pos > nfsi->layout->plh_lwb)
 				nfsi->layout->plh_lwb = end_pos;
-			if (status != -ENOSPC)
-				goto out_unlock;
+			if (status != -ENOSPC) {
+				pnfs_list_write_lseg_undo(&data->lseg_list);
+				spin_unlock(&inode->i_lock);
+				pnfs_list_write_lseg_done(inode, &data->lseg_list);
+				kfree(data);
+				goto out;
+			}
 			spin_unlock(&inode->i_lock);
 			mark_as_dirty = true;
 		}
-- 
2.53.0

