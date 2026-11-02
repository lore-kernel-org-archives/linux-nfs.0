Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627820;
	b=S6KcNk7QzW1UhXUsKSmmIunmuI9yElT7xxxZaiooxupq9dtZdQfyhlTXBI6tLIQnxCib
	 vi///Rky2fkFiwkM+toLucLhDrEr244xY9C7zKovnwpzkKx7g9dKWmQUv11Rkk5qjmxwo
	 f9s6O+45Npcw68ZmLRpP4tbwf3lgYz8MAR6Be1gtx0UbSS9PJ+tSULbVv2pJXffJcH14O
	 +VQiITtzTa4/bYsl5GWF5uJmA213bSQ3tdhjCD9juosHaH3Vbg5NFaPuJoMjocUJNjWgR
	 4qQhFLOvYSkn4/t+AWxRkUcThbaFyBWiECh0bj7zjVGB3o/DAd9igz5GbZP3Eo/amhw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627820;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=G7mOHHgwkkBRrimNNd3GlnHR8utPH2SmSkllkTreFH4=;
	b=ZNy4CUspPHInCg5B6olaFRoeoxOzqpsunfcg9S8C/Icsr82x78CT18hjkryClT14VHWF
	 bfI8s5iDXTSgwnFzSbo/xNPHu/Fva5FYTzT214fjlHEaV3Ks5X0Q2SLg/JozISXjDZw03
	 UqHRi+o87DUNRbTwJQ6IRv2USNjrEp18iJB9eUtf2azuL6wIFZ3J1o54scMp5ssK4tMY4
	 UDXF0rA4HZbhUaMAWCLDVd5iy5Xt/5dIiOkKRjB88Z1Tq+JueqXS8hNT4+pIIWg4rM3Tp
	 AVO/xWfQ66WXqS44xOvEm1MszQrHugVRXx4WIa2YzW/R+4J/0yr+tuymkzyBOhBPvmQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=RFUXXkT+;
	arc=none smtp.remote-ip=209.85.210.44
Received: from mail-ot1-f44.google.com (mail-ot1-f44.google.com [209.85.210.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D526606A339
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:56:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1D526606A339
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=RFUXXkT+
Received: by mail-ot1-f44.google.com with SMTP id 46e09a7af769-854b6e2e41fso1939096a34.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 05:56:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793627819; x=1794232619; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=G7mOHHgwkkBRrimNNd3GlnHR8utPH2SmSkllkTreFH4=;
        b=RFUXXkT+oSdb+zANf+b0/rSR2XUldYjnYHPyvgsfN3DnbT7xM/QJvzppu4F6T6wfXo
         zRU5ljngEXHmhZGX6xllKBqB3sm6OLviPpITo4lS3gbVvKvnRaLz9K83qzIWhXnmllLb
         wSIpW9xHrZPNjOa/PBH3VZ1KBVTGxwOfqUdOEK4m/7jE49PrwMQ5T7vlZdn1HXrLTwzM
         86hk0/KZMo+8I1E+9dZgf3emmRpOSiE5OilgcDA9d0OXKKhy/cGS92/rXTKdVVbqN+1R
         kd85nUZskOvPxFSKDUvEqjOwHHg0nrl7Kj9baHnDq3L32qyfox3QENvx6wWZ9BQBZikD
         MI0w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793627819; x=1794232619;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=G7mOHHgwkkBRrimNNd3GlnHR8utPH2SmSkllkTreFH4=;
        b=GcZAi/s9LHb0UiZGpN+sKccNEkB+jLrch/vJmkfLBvRTEH+wvq278vX0AUU+lSLCdv
         P/3i9rCADu+qqljk7cBpuUg+C6W3iA4+jj2/9TEYmaLggD1wVWz66kNM5c9TOm53bTp7
         BB+JrLHTdvSJmmZAvMmOhEA+Cw/QfbSMmaDMdHnBy4KeTZ7GOspP82FQpwCaFPuqRZIl
         Dqy4cRZ9VF1QlCQm1LOKgiY7+RKK8dEphJhWXqbyZv7BDZX2n4SsX+QXmFY406p3h+GM
         Ta9juiyTZdf8fNy53tRlPWwfqsbOzjNh0jdn4/hBc9nqrVZUp9Y/SnVhQKVdvovpaXYR
         cOjg==
X-Gm-Message-State: AFq9FYKp7pa92MFUD2lJ/2XxkooIdAje2v5rh+21jLkRjSiDDcwJ2VvZ
	otxTMqw51dJr+xOsnNOi5hwgSBEIQYkLvIPIqAB64Vcye/fU2P/i4vrUawlAlY8tjLQ=
X-Gm-Gg: AYBFou1r33DHpDFJDmu7vG2X0lUW0u96KpuVxRrS1uwNDN+lVk3pVCm/xSOIvVHlwfY
	0LSBup+iw2CRw0dZKcgSBB8vlnyFTF7lmmA79IWYFhS+35e+CQ+rhVtjITaMQDy16DQSzKSA4d6
	64bcNV0ZDPSuOpYe25s5Ib/uRc3GKPPvKfO1jluvqsEb1OgIUptdLjI9QmSKZ0E4Y0W9LEVnFd8
	VJKbP73tP0SA6OV4z53Vx61fc2oxzD+3atCrcLiljOcYpF4kb3zLFr2L/G+xJObs3MgsGnrna8t
	ufiiLUhw6BmMqo9PoFo3MZuGAA83n1PP2dr0jDMeAtvLAZ8l8IixJi4Q60fujQygK35MJOHi4f9
	VchvzDh3FwFxEmJ9WfEKt16k2l3RjIkU4PAoNq8oUAI09nf372h+IU3bKRFd/5EaRd/rDY+M/74
	q2OAWFoNybcUPnfEBSCzLQ0A4MiLe/dZj8tNHtKxSCuzihnkZJ+mbyCtDiL9WcxtmGkN4atiG29
	C/uzxlr2nfje7a8hBmM/lqzOxHGUYDjX64/i1sW5NOof9L7EjZLUwuQ1Hh8CwmvSOLGsK0W4Nbt
	Frn57WSXMFby0oh/trmFsPqV6yyIfM9vLzarZPZmw741GYjupuluwTeH/Gp35RpiiQb5ys6y
X-Received: by 2002:a05:6808:2512:b0:4ea:18f:64b0 with SMTP id 5614622812f47-5640decc459mr7593804b6e.67.1793627818818;
        Mon, 02 Nov 2026 05:56:58 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fd95562sm7980806b6e.4.2026.11.02.05.56.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 05:56:58 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 3/6] pNFS: don't leak layout segments when prepare_layoutcommit fails
Date: Mon,  2 Nov 2026 08:56:50 -0500
Message-ID: <47d694f1703cc3002ef40dcab88e1ccc9d7153b6.1793627813.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1793627813.git.bcodding@hammerspace.com>
References: <cover.1793627813.git.bcodding@hammerspace.com>
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
NFS_LSEG_LAYOUTCOMMIT, unless the flag has been set again, so that the
next LAYOUTCOMMIT, which the error path has already rescheduled, takes
it.  Put the remaining references with pnfs_list_write_lseg_done(); a flag
that was set again holds a reference of its own.

Only reschedule the LAYOUTCOMMIT and give the references back if the
layout stateid the LAYOUTCOMMIT was built with is still valid.  While
->prepare_layoutcommit() runs, the stateid can be invalidated and a
LAYOUTGET can install a new one on the same layout header.  An invalidated
stateid has no LAYOUTCOMMIT pending: pnfs_mark_layout_stateid_invalid()
clears NFS_INO_LAYOUTCOMMIT and drops the segments' LAYOUTCOMMIT
references.  Putting our references can then free the layout header, and
setting NFS_INO_LAYOUTCOMMIT again would leave the next
pnfs_layoutcommit_inode() to dereference a NULL nfsi->layout.

Fixes: 5f919c9f10c1 ("pnfs: allow splicing pre-encoded pages into the layoutcommit args")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs.c | 33 ++++++++++++++++++++++++++++-----
 1 file changed, 28 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6d391985fb21..08deb4d811e4 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -3634,6 +3634,16 @@ static void pnfs_list_write_lseg(struct inode *inode, struct list_head *listp)
 	}
 }
 
+static void pnfs_list_write_lseg_undo(struct list_head *listp)
+{
+	struct pnfs_layout_segment *lseg, *tmp;
+
+	list_for_each_entry_safe(lseg, tmp, listp, pls_lc_list) {
+		if (!test_and_set_bit(NFS_LSEG_LAYOUTCOMMIT, &lseg->pls_flags))
+			list_del_init(&lseg->pls_lc_list);
+	}
+}
+
 static void pnfs_list_write_lseg_done(struct inode *inode, struct list_head *listp)
 {
 	struct pnfs_layout_segment *lseg, *tmp;
@@ -3760,14 +3770,27 @@ pnfs_layoutcommit_inode(struct inode *inode, bool sync)
 	if (ld->prepare_layoutcommit) {
 		status = ld->prepare_layoutcommit(&data->args);
 		if (status) {
+			bool valid;
+
 			if (status != -ENOSPC)
 				put_cred(data->cred);
 			spin_lock(&inode->i_lock);
-			set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
-			if (end_pos > nfsi->layout->plh_lwb)
-				nfsi->layout->plh_lwb = end_pos;
-			if (status != -ENOSPC)
-				goto out_unlock;
+			valid = pnfs_layout_is_valid(nfsi->layout) &&
+				nfs4_stateid_match_other(&nfsi->layout->plh_stateid,
+							 &data->args.stateid);
+			if (valid) {
+				set_bit(NFS_INO_LAYOUTCOMMIT, &nfsi->flags);
+				if (end_pos > nfsi->layout->plh_lwb)
+					nfsi->layout->plh_lwb = end_pos;
+			}
+			if (status != -ENOSPC) {
+				if (valid)
+					pnfs_list_write_lseg_undo(&data->lseg_list);
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

