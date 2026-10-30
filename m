Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793374230;
	b=xfQHXTtWSVyl9yDuXrz8g04nU1J0w3rsHcy5WfJ9fN3skvDVMfUxF+kdRFezaxnlmNo1
	 3Nh1rDJAwkMB0nrVo0ciVXV5icvjF+MRh5sj82nTBRqqw2WjOXk1O9wpn0HqUI98ILGgd
	 Kk1vIotm5Wfg7UXfJ5J7SUTM+PuwjsRezUdSL6ZJ7+r7c02d6Vm58+Xatn5+2f31rh5mj
	 oleezPT12LojM9aowRWG91M5QI1jsxc4b+V+5KI5dOAPkRuWZQ2yOptF3Oag14Azslzsa
	 mCfELOy7Ep/3FTC1f8DCfHBxVgDFTTfMA/PKAeWWjk8iSK1R5wH1bO7iBgnJM3br6Nw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793374230;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=/omAXtebXLsQPYp+F+9Gs5gnGcMFUYe3485ppcTwyIw=;
	b=Z+PdSPPKKSHSGCpmqL/rhhtQQemrqlGt7A0adQYFjusEE5UX9dnULujpZrPc8Xb7/upR
	 PyiCajheggfJlu/RFLy3HBUlu6sP7a9LDAAcervob+YMdLxOawOYrOlEreCGqRgzC3vys
	 O71MgPyL7tgbtFPRh9AT4xr1hv8fLZsrmS1Z/DhWJzstN2sF94v4x9CBtt1jjK7TILo41
	 JFmLElawRhbpMgxhBFNlawr+rioUs72Zck5jQ4UPHTGRAsqJ18/C7LDY2N3ze1Ed3/E1b
	 C45xIDDPJ8AJd+vn37o4jvT8cgT42dXP/r6drJ3y0KFoRX+wMW/jWJV5wseebFCZdRw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=iHYev3In;
	arc=none smtp.remote-ip=209.85.210.41
Received: from mail-ot1-f41.google.com (mail-ot1-f41.google.com [209.85.210.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 01840606A31E
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:30:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 01840606A31E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=iHYev3In
Received: by mail-ot1-f41.google.com with SMTP id 46e09a7af769-847ac7ccd85so619478a34.3
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 08:30:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793374229; x=1793979029; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=/omAXtebXLsQPYp+F+9Gs5gnGcMFUYe3485ppcTwyIw=;
        b=iHYev3IndULIyFemVLV+hWMVbAGfba+35vPqkMLEbKkjD7V2AnbxSMSgppARU1e1kx
         vapENEBglBrorXYu45MwqKMmmNzt7vcx7ynReTQ9xquIywv5bqb0hp4IvAWIbGsgkWwZ
         H2Y9NQkZxVJaDVJkDskM6W0Kz3fu7h2iCWE9c8JYEsboOUoLcT3k7sL8BEM4G3jJzigG
         s+QznmLi3XfsWtBy5qypXja0HUPkZcjKZr7CGi+cMZhpYnF4kRvV+eltDGYqsH4XsWn7
         nG73EjcTMc5cuNAd9xbksT1bXVJQsRqVuGyIOti2ScyOkBt7lJC35VOrRr9aBf2sMIz0
         OY9g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793374229; x=1793979029;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=/omAXtebXLsQPYp+F+9Gs5gnGcMFUYe3485ppcTwyIw=;
        b=kLJ05AhXMiPdTUD/VfE9ElNjO/AU2VNn4N0u0giakkKMlDPDL0m8FtEw+EBV2DJDI8
         18AQRoHTlSSKvzSe0k/X3SS8VsxwNrq3fPaw5khLXMmuEkPAtoS4v0upW4GtflIUU1SJ
         bWQ0frLs7bXGUdaGOX/s1I5UffMyHrP5KZ4hr/33pm1q8qy7biPsba4w2ZG/+pG2zEuj
         8DD4fawe9b/I/P+GK3H1vItFoH37mwL2y8KFmz9k74UinklC/rqZFDE6QJexBabLgJuM
         MEOhxipp/h/yQB1ej75WbLhS02Nfxo9tk6dHFOVFOdkNqL/DZBh53u54mirAE4kiSWq/
         uibA==
X-Gm-Message-State: AFq9FYJXM36SVl1DOFJ6OXymZ9eELHv4wxwY9DRECR3HGt4tcmDyjvX4
	7h8SfuTOZ5IeRM9cQwBQ7SmkwV6KG7H+NsdJ1N8OLgrm96JnPeq+DHHMqO85SGpDATPmMZnG47f
	ilERo
X-Gm-Gg: AYBFou08T4nszHxepg3rqSpTSC+0KX/l+viRFB2FIdcTzi5kmTJyOiu6R8p0ll/oVGh
	wcSEba7oHZGYxexDUy/wy/5GRn0kPJWIGDDJqUmIArtdyYerXM/1WEA52ye8z+smw3F+FPTTyR1
	MzFR/y+12iC1Ig10I0AbDxun/xwcD7D2WCMutoglO5n2U/BSnAYP13VIzVX7BftGxlny+yTCoxf
	YwMNzAPAuHiRy37DY7/4/X2MhCc7sDR8/pAU0USLV0Y/+Yeb3KMMi0E6T4DbQdEwjEALERVWFyZ
	gFCVlLv9YcJyG7PXcl2waLWh8FevFKxMKnCZ7mUmqUeUg3rcK0OeBcTtcYiuyuO1VN1KJs7/CW9
	eZP35wFtEucOOJp+lDIZr5f9QY0rCxUMfF3YFDQyZgc45eF3NhgGO/N6cFd9Fgm7gfgP4jSXSWN
	oFY+u71lcpVrsUbH5U2MdDKK8hgrKMCWnn1pK8TestHnyd9ju43S6wtJyRU0eH1vC3eHh87I3rv
	S2JHCJQ5tq1SpEmvsQbH7CwoSFFAIE9mjU47IM90R0VisAyoYHl7o9oMMjvtiHDhgHbOA2007Pq
	3ejt0OBOdJzLwTB+IW5gnWsHvzIoy14GiYWe7j4s/DNF2rZq1dbXwIluH+4lhTVDj4GxqrVBDGf
	isEt1GC+Y+Qkbo/A5IHOTunNnAxbKEieALb7VcM987/p/knHCt9FQ
X-Received: by 2002:a05:6808:14cf:b0:4cb:818f:d56e with SMTP id 5614622812f47-5640deea4e7mr1727570b6e.22.1793374228762;
        Fri, 30 Oct 2026 08:30:28 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com (219.sub-174-201-19.myvzw.com. [174.201.19.219])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fe0fda0sm1840376b6e.13.2026.10.30.08.30.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Oct 2026 08:30:28 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 3/6] pNFS: don't leak layout segments when prepare_layoutcommit fails
Date: Fri, 30 Oct 2026 11:30:19 -0400
Message-ID: <352ff35c2e51bf8fb025ebd88bbec3c4cb7152ea.1793373378.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793373378.git.bcodding@hammerspace.com>
References: <cover.1793373378.git.bcodding@hammerspace.com>
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

Once the segments can be freed, the layout header can be too, so only
reschedule the LAYOUTCOMMIT if the layout stateid is still valid.
pnfs_mark_layout_stateid_invalid() clears NFS_INO_LAYOUTCOMMIT, and
setting it again would leave the next pnfs_layoutcommit_inode() to
dereference a NULL nfsi->layout.

Fixes: 5f919c9f10c1 ("pnfs: allow splicing pre-encoded pages into the layoutcommit args")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs.c | 28 +++++++++++++++++++++++-----
 1 file changed, 23 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6d391985fb21..393de479da3b 100644
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
@@ -3763,11 +3774,18 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 			if (status != -ENOSPC)
 				put_cred(data->cred);
 			spin_lock(&inode->i_lock);
-			set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
-			if (end_pos > nfsi->layout->plh_lwb)
-				nfsi->layout->plh_lwb = end_pos;
-			if (status != -ENOSPC)
-				goto out_unlock;
+			if (pnfs_layout_is_valid(nfsi->layout)) {
+				set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
+				if (end_pos > nfsi->layout->plh_lwb)
+					nfsi->layout->plh_lwb = end_pos;
+			}
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

