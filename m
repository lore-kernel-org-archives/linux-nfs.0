Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793374228;
	b=eizZnItp9yuq+yHDhprcfbrtg3Gajo0QJH8R0p2x9jBMvjaQ3E7tMIJyqFJwMeTK6YMG
	 ocd7lxOxG7CZCU+DHmEw1sX84ma6tNtY5zFF1l26uT1yMrJzrTiS7saHmRlTmCPMaYSBh
	 /6vAZt/2ATu9HUtrWJFqDzks49z7IUEEteG2MgKixAeBfkSvc0zdIpr92Q0sOSUftcWWS
	 MC4tQExFumR4tEisPTXcbDWn712Krck1K5jfRm60/TWEWfKXOXhRfYoHD2ovT4IeRZOcB
	 q7Ib99heO6JHQxDe+1YDE7f7iD+95p9ctJPinHD42DBcTtlvBR7HvDe5ww3gxvFSwPg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793374228;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=lGYrY710riRY7PYILjmn0q85yHcHHg02+ReDFP2Fo/0=;
	b=r/bu8zWPwMyEEEhR2J3eUOxUUr/pjMNdMR869CB7y2pwTInQnHkGX1JaWSPaZD/As6zL
	 qerhis8tnsvSdgSVnSRJk5O8gTJRcRh5sFMYYkVrnjtyy1VcFskFMrv3Q9CR4KQgLLi4q
	 gFNk1DO+cUOdeJbzRavVD0bAwXJ6kHWcQNmRYlrfWxx4uRB4u9D9lqliMJFh5qztKybEZ
	 23MhDridhAbQXlGnuXP7TsTrx0KC7x32lOBDCUqpBAEOR2GKmXu3LajGHj6GAudeSKhW9
	 M1JZWGYXKvxNJi3UVd5bC/HOTsHnqAPRA7qIDqDJOnOAETkCmaT/07ANS7pZvRtMXow==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=fQMO7Sx8;
	arc=none smtp.remote-ip=209.85.160.50
Received: from mail-oa1-f50.google.com (mail-oa1-f50.google.com [209.85.160.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7F2B0606A31C
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:30:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7F2B0606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=fQMO7Sx8
Received: by mail-oa1-f50.google.com with SMTP id 586e51a60fabf-486f013db83so291277fac.0
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 08:30:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793374227; x=1793979027; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lGYrY710riRY7PYILjmn0q85yHcHHg02+ReDFP2Fo/0=;
        b=fQMO7Sx8Gfr10nmobNONvpm9GTzLLtGZuLWqG/xOyc8ratRmkJH27ugPmjoFRVBoP0
         MfavlbeT+rmGYq1RMTZwZoZqqYoo7dJi7XN/+RbRD8/m7Hmot+6XjzLCUcYJyJ5P6V9U
         8A+XfWjUxS0WsLmUloLgKANDXTVl/UUWd/3HuCsPReTR+4h0GXZMATMC42uSQgecJf64
         4El7CV5kg2qyUlmMbEtdyJftpL+kWJYdBNP8uQcYG6Jx8VlKPEx5XgxbRocIhbj0rnUY
         Kzd2himppQD3/XD9296wbtFPkKaW1OmmuWgPG6TRAcX2EfXMbk03tQvZwf5Yio8rXpkK
         4ybg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793374227; x=1793979027;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=lGYrY710riRY7PYILjmn0q85yHcHHg02+ReDFP2Fo/0=;
        b=I0ngwewNgvqQZkpi3/B4t8bSXy+fD7n0mbWuEARH2ftixdKip7xQytfhELiXoWXaDu
         rkHk1oVvf64jK+wg/80ZLEyZZwPUimQM3vv0R/uw451rsMD4qBRjZIBQhFoz6CW72GBG
         w7KL3wq3ah1ucClbD1agzLaJ98xvhjhlegl5r89UZvgoIlLVwJJOONcIfOqXFd9ed2Ap
         h8igCGG5W3myxC9YzELBcS/Tiz9c8XbccLQh3Np7YeqnNoRsa9d+Ee8GUmZr3lOrfmr0
         WrIwbJmvtDkgCnxtTBICh4I6bGAfZ7MCC2HX/J2SjVNShS7bcdXu3h5NxGhkQDg5lYPT
         /xtA==
X-Gm-Message-State: AFq9FYKHmoIj4GyN9ZxQa+YM0+OoB8Lftvs4owaMKzJGjgZbAm5BQBhw
	ieIduLaNppY40MlJd5Hl+nN+XKiyFfeEp5QuHHSTZULRRx8rqgX7FULqVaMqIg84kDk=
X-Gm-Gg: AYBFou0RJspRgdJ71lkmyr7ZCqrEER+x8Sn9itKkYlHjvdaEsukdl2RDR5QB9DTkmL0
	EZHolulhHVZxk6hGEFnLMN2vKo6OdxWeRuu4w73NlNndcsOjPVFqImFXPvU1xR86+ytxyfalCPQ
	sjt6KEU8Q4RywLbx1oz0b4nH61eF3nccybuteTjsw5VxcKOzFZ2g0wCouLtLlIwVv28YGYngkYd
	JX6OfoY+pF0SVevSBQPEO21KoT8HMx8riw1/sNsHC+b5bUe2Ye5Td1Y32G8wkP4MYfYSlYuE/uG
	XFIUTiwBjhOOPvKmJI4TR12kKtqOSsNaYJXCXZo4W0QxLSg8wtkDUMD0aYJ+dHhQSa3TJcTdxjR
	ckyrZNGShIcRWR9GiJ5uOYB57WCxmw+Vn65gbIhdzbfWUMnAbLNDfmRYNBY4/AaSlDhfMysvy0n
	aLV1bQcL2Gf+kqYzwzBaNRSWbW//YjxIHQkuhFlS6W5zrPWyebEwp4tzv9jy2K/tv52j/9eqRi+
	+oIs/HIGncSEDZ00x0yekCmlZKDq5KHgoKCcMRMtlQE9TT0JMoh7wb1G6O+iAhqKfqUXOt06EpD
	MAfd4lVOBpoXDmK4egQ/ZD0jY7c0voOvpq/k2mSZi+zy7YD43VpS4/2uTPwopnil1KPa1wye015
	7Y+gV9iTaVSGJwjoA0eJBhuc/c9bH7t0=
X-Received: by 2002:a05:6808:6508:b0:53e:3b0b:fc1f with SMTP id 5614622812f47-5640dc2a803mr1963717b6e.22.1793374227342;
        Fri, 30 Oct 2026 08:30:27 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com (219.sub-174-201-19.myvzw.com. [174.201.19.219])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fe0fda0sm1840376b6e.13.2026.10.30.08.30.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Oct 2026 08:30:26 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/6] pNFS: clear NFS_LAYOUT_BULK_RECALL when an invalid layout's last segment is freed
Date: Fri, 30 Oct 2026 11:30:18 -0400
Message-ID: <b740e426e4480d70f439abfca5ae82d0e12e9b95.1793373378.git.bcodding@hammerspace.com>
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

