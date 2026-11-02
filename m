Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627819;
	b=JhsgFdMp9jMkOhztL/VO9nqUaOEFcBfEic9DWJLGt9Iyf9+MeHxsOFAE4Sox/IMIH5IW
	 0RoaMtbZFrIoIy3WYzYtJRsXu5fYk8vdhyq9W97Xp3WD2nfKGQX8vqATJw/82lquca8vQ
	 EBGqCIoyteNXMOJvFn+bi5KU7RW60xjcPZADkk5cPfrISeDMZIgL/qkCZT/3gGapyVuXV
	 HTn5evvUtUo0FhzHNrhtTw3D8vfTS1+nsnL9Z9FaiAona3CpIMzcJdAM5EsRp6PWtxfUd
	 v2Lx4iZMUZkuvGeUQbvNuzR4wq/9/xcg8dzbliAjRIXzFhj4TzgdhmmIuOeZbGLi38A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627819;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=lGYrY710riRY7PYILjmn0q85yHcHHg02+ReDFP2Fo/0=;
	b=MAMTk+AtfI2k7tAPrmkukQZIY8WV8ga4dj0QJzw9AawMb7lFq7hcu822YZJT4lqO/5US
	 oeUYwmmlO5BLtvsedZ6HFpeOstsd7wax69MKliqxGGJ3eHgaFsvGk+6/XUzL3fFqgZSPe
	 FAWZlyGWFWZyNfJY2dTw/1Dr9Mn0NmBJnfKUM8TaS+LRNV98ykW73drVhe97BywpEdrYs
	 a+G4fQ3Brp0er5Y6cAav+durrESb4V/tUNOWAizFnr1JISJMKXXOoJDIJ0dJaMWD+Uw/L
	 QWR4rel0D42oo3BgWhpGCcWmt8fdzzbU0LfeNo7vhTr6tDf0yKRM5+HQmV77J5mnM/g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=HTy+9kaD;
	arc=none smtp.remote-ip=209.85.210.53
Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com [209.85.210.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EC8F3606A32F
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:56:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org EC8F3606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=HTy+9kaD
Received: by mail-ot1-f53.google.com with SMTP id 46e09a7af769-85d363fb73cso1751891a34.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 05:56:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793627818; x=1794232618; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lGYrY710riRY7PYILjmn0q85yHcHHg02+ReDFP2Fo/0=;
        b=HTy+9kaDrVOxJKdaG7QDAkO1pqd7IDOlRSegEqqS+44NETbzHyV7/6UHj7pxdHY5QN
         10F1C5ZOPSgFgnCYGVrvAPYs3RwLezyxewJEE83eg1oHmgEYlTx1/qq3nZjRYDJUvjoo
         5T/qJxYlH5/zIdyBW0owJJ0/mJqRQqc6PF2mYXiAML+YIDkm0Y5hYeaFQnRR65lXi5hh
         QUa0lrfQTMna0JR6f//Xxi6AYnW++h5cq1WcwgCYl915o5/I9RUndj7VhgpbIftT4SuW
         trOxWTrYyV4iGguanT6vM+hTHtS0hhUpXUeIUXbwPMyiOj48y+e2wUimcW0cRYKD8jgq
         FGyg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793627818; x=1794232618;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=lGYrY710riRY7PYILjmn0q85yHcHHg02+ReDFP2Fo/0=;
        b=U5PlKmkR/PWjU9iP2cZX96DDamcokSeKrc2cv0/CqF+H5037P2dFH2FwejWByLXIgM
         14sj7wEJIrw730+w2VL/oi1TEGF69PCYWIyNhUNnSB1TYMl9726xnckTTdTWQxzP3iX7
         xAUDcDZYNpBD36/CLDGATcZzieNrjocbojVMeVISei7peG0t6U35MqukCzmsYeJ8m50C
         32DlmU9DaaB6+LcDxOl5KRoRBTltTfFJ7cMmDxMDnz+FFg36QhSaBjU5zhiFyP/WfRnm
         ykXpcsHFGb5P+ssUexbcl8+y204AGocIUhgebe+sCnXQh0g1g15FpCs9l6CSp9twCx2O
         uWqw==
X-Gm-Message-State: AFq9FYIlrkvLzwvZyStXVcGFN5qh696PqvERlHpOjFB5jLLMeT4cfPbT
	7egy1H9zROTstS/7FaP2HOqvQNgV2f6bGFN9xCWhCCXbP64scpzFhjrllJs+D0MtXus=
X-Gm-Gg: AYBFou1ACVwZWXyek8LD/EOP0pgZLjDZ5ZdtLU1Piilia3w2BAkHeeAxW82ti/1lWuS
	8C+A2dFgn5wp1nga+6dLOdZtdvkxWNdfJvbsyAdPZHTVVdNkH0Oj3URMNWuN0dYxfCHJzmwwwK/
	cIZOzS4IxSHtJwwAYQQKeN0kK35M2gVaVp4shAYH5cJ1Ce1n2SaTXhbQlxqFEJ0COUZMiZEKPWB
	N2dDx53Ci18zNvb8eu1uULENfGdFxUPS0bBjw2TnV3VQsV7jdoD0vA/r7oxCZx+un+ncnOwRJVl
	iUUxj75gafHgLlCD0n3fJgLQ5AtxBiBiF7fFKRWAC067DaFrmvCZv7bxNkbRFgD/F9KeFspcHE2
	JNildKYq4WzhPtFg7iaA0uP7rwXAhfv40RlAd/84l5YHj9QUBIay/ilEqbQ8EFYOfYWmdgZqc4b
	B2BEM+GwkM8QkyT30TKKfH1xtsDAsvgAGciv0IkBoA7R2HFuYA0wb+x8P7qKnShJdbMd1q+aWl/
	q3j/NOpq+kl25TQX2n5S5G5aVjixc5uBkEhm0cd60gbbNIPWDVxWVwTLtcCUTW9UApOEpkqBp3e
	WxdLNBoUZFYHTN//vsmlnbyM8EyfN6+iS8jWsQiqHenpVgNwp3SsVAUEu0lElFDQmGLpXp/U
X-Received: by 2002:a05:6808:1a21:b0:4b9:e65b:8c2c with SMTP id 5614622812f47-5640dd69994mr7411157b6e.26.1793627817775;
        Mon, 02 Nov 2026 05:56:57 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fd95562sm7980806b6e.4.2026.11.02.05.56.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 05:56:57 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/6] pNFS: clear NFS_LAYOUT_BULK_RECALL when an invalid layout's last segment is freed
Date: Mon,  2 Nov 2026 08:56:49 -0500
Message-ID: <b740e426e4480d70f439abfca5ae82d0e12e9b95.1793627813.git.bcodding@hammerspace.com>
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

pnfs_layout_remove_lseg() clears NFS_LAYOUT_BULK_RECALL when the last
segment is removed, but not if that segment is marked for return or the
layout has a return requested or in progress.  I/O errors in any layout
driver can mark segments for return, and flexfiles marks a segment for
return on every I/O completion, so after a bulk recall that had to
wait for outstanding I/O the flag usually stays set until the layout
header is freed.  While it is set, pnfs_update_layout() sends I/O through
the MDS without checking whether the fail bits have expired, so if a fail
bit holds the layout header, I/O goes through the MDS until the layout is
destroyed.

NFS_LAYOUT_BULK_RECALL is only set on a layout with an invalid stateid,
and the stateid can't become valid again while the flag is set.  Clear the
flag whenever the last segment of an invalid layout is removed, ahead of
the checks that guard setting NFS_LAYOUT_INVALID_STID.

Fixes: abb3e1c8777e ("pNFS: Don't mark the layout as freed if the last lseg is marked for return")
Fixes: 7b650994ab07 ("pNFS: Don't clear the layout stateid if a layout return is outstanding")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index a057a06318c7..6d391985fb21 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -582,15 +582,15 @@ pnfs_layout_remove_lseg(struct pnfs_layout_hdr *lo,
 	list_del_init(&lseg->pls_list);
 	/* Matched by pnfs_get_layout_hdr in pnfs_layout_insert_lseg */
 	refcount_dec(&lo->plh_refcount);
+	if (list_empty(&lo->plh_segs) && !pnfs_layout_is_valid(lo))
+		clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
 	if (test_bit(NFS_LSEG_LAYOUTRETURN, &lseg->pls_flags))
 		return;
 	if (list_empty(&lo->plh_segs) &&
 	    !test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags) &&
-	    !test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags)) {
-		if (atomic_read(&lo->plh_outstanding) == 0)
-			set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
-		clear_bit(NFS_LAYOUT_BULK_RECALL, &lo->plh_flags);
-	}
+	    !test_bit(NFS_LAYOUT_RETURN, &lo->plh_flags) &&
+	    atomic_read(&lo->plh_outstanding) == 0)
+		set_bit(NFS_LAYOUT_INVALID_STID, &lo->plh_flags);
 }
 
 static bool
-- 
2.53.0

