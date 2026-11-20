Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191002;
	b=QC20ltKPeD+hQdPuAGe5LKG5M0XnMYXfqnO5Ss4zo7FSqg/ZTvBuYtIGlQ1+5GkhjjT6
	 CUwCK7xHRL7Jm3Jbhj44x+wPZGDT2pERhc9O4U8IltfotvoVRWZ+zA6VphnuWSYxyCctO
	 S2NK8796Fqh/8L4aM+vWVD+bfxcBFlC4vgZgeLdCVQuUYjU3sE/2TAqNDW4MHyi5u+htE
	 e9wjUpGXQm4OLrEWHrIkC32tosOV9urYjgECYtoNa/3+mlKWkxxwrYRdb89VWeONv7ljz
	 Pl/tZMZRZG98X5qotL5x8rgQHjWwnFd7Mm2SRq7MBvgtLbisj2bD8kksyLf2IE+fp4w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191002;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=ujNgoMLnJDtDzMYO/y2w/XnCWUTJsdcV468X64++wWc=;
	b=OQadU1SG/CZBbYl6LM0q/H8mbFBGugAt7FZbMvtz0Rrs0ddNfedusgdggVgAOrIbWcoo
	 egEoh5g1iNQN/9PYNpgSp0BqezstJPfxtxHcNaaYRJzPRUR9fgxuxfEkN5NPI/2Y6Osro
	 xA3b3t4cZrnIEHo2AdDnR16EtVgifRYjc7z0RyeVTMwy3onp96rW3nAMLf3Z5aASn2bbL
	 x3lymFd/W3oWjm23E52yQxWH2lK/zF98vZEH99BOaTsCgvLjJnehrf4yGbRQhpkaXd5pr
	 qjQ7vZmxhKVSyXv8L2Lku/ZlqqIx3c0aF0tuvA50neV9Q4EJfoA9O8+SxpB8JNNiqEg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b="hi/Pf/YT";
	arc=none smtp.remote-ip=209.85.161.42
Received: from mail-oo1-f42.google.com (mail-oo1-f42.google.com [209.85.161.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03E71606A32A
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:10:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 03E71606A32A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=hi/Pf/YT
Received: by mail-oo1-f42.google.com with SMTP id 006d021491bc7-71aed54d4c5so759883eaf.0
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:10:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795191001; x=1795795801; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ujNgoMLnJDtDzMYO/y2w/XnCWUTJsdcV468X64++wWc=;
        b=hi/Pf/YTvnsFPYJKzRK3WMQ7ZlrnCjr2JIdJRaYOBEVuxBuYUlGYF+QNOcKUZ1SKvo
         DiwaVH0MmGl9Avs3yKVJsNMNEf/jHKm/oPsFjAEpITjM6mBQc405V03qlRvyiWsXzWOv
         lXAyWFRzU1O73KA8L5VFsu3lFn2rEky7e07yu7bYNKEQDCEupSyD0eyOgMS3YVjNRxdq
         HnZuKbhFduKjnWcMDscHUuHiFaV6YMWrdEX1LUgUTJO14BJhwzVIBBHyjTvYqpIzdo9b
         gRHvFrHfKEMTfxMKiSDbL8Poyi6XtZbm8wJno4gx4GEk1oYdRc+L4SrrwO1t1p/ByOkU
         CadQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795191001; x=1795795801;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=ujNgoMLnJDtDzMYO/y2w/XnCWUTJsdcV468X64++wWc=;
        b=1NFT98SEqahlAOrpRVL5pR0z0BJIzUEU+c0Ejk5p2MSSlJbkNvARZ2ir9dr+jtBbxE
         5SfXTBTDvYIWhPCCWGQftYWQT9fkTAXBwMTLuYnmyMmGRCMdkT7YdwkhA2Bo4k6tmeC/
         MZ6mHdBL0WnIqNSeuBEPas8fZsau9Yeg07YRv0DAWXC1HI3tLeiyd9PBHr9F+1r7Ql/5
         d6o2IckYD2BK7k/sxSoEduaD0I07CcXwgCfSK1CzY4hJHn8LaU97OpPcrhZePK0XIDly
         RSVicp3IYTeOPILBxGGKJvHJ8yS16p+eGjE5xgNPr0+qbQIFBgRq4x0xA8WNUe0m25uI
         Rx8Q==
X-Gm-Message-State: APuU4Z/bGi0uros2rNlbHsQKHjpfSFOrWuZe/HSrRwVJQBS5SkvPDRfR
	2LU2LGUGqrKhxDnQ2JY0C3ihl43m8AcXG9mOvnH9nJsd92V772K0EWH/aP08/2zDNJ4=
X-Gm-Gg: AYBFou2JEvjz1Q09ajk3qqZi1f/XD9Zj1RjCpywpiM0CPzuOjs8PyZWV+rX27HcVSXP
	gGHqerWsgP6lvpVlnLWrfJ0WOEKCRNaqcaGNcu/KhSozxFAwPDp2w9yCSsC77oSbkHALU6HlViA
	v8MpwD52XuGhn2zAZX1E+u5cKYT5kjXzDpvYYsi8BBcllVmy8AttYc0k5XAcBor5BI7gxc8AiR3
	Tsce6a0Hs27ZJqrCUSOksWwi6uj6QFrjJoQrqzR1R+LdzeXKeyhqA4SsY2jMwJSrdaSb13Jt6Qn
	zGkMc3Lv5F0gy0KBmkCEkdtcMJHWLdb5Dh7LfM9pQVobp0Kqsu9ZgGoRK29gjwmrEM36B9lyDsu
	nbLmKqR0e0t7jSqGxZrh3NymY5oaEJq70BATd8Y5Dzs042FKE771U2wljukJ5jdznrFMqksAjc7
	8V3xgzNEPMy7wcXYOUyzhcDa6aG04ax07eyDKHw/Zzf+qUo3vmhnyJTZDlQx8QpcIoLFEGD83rC
	Sww9p4CGSbvI9TYcTlqZDS5NSNj0seAHTAyXiXsj2yxBRUF/tMd9o3J03f/53k9PipHNU0ZsotM
	NCvDOIQfLODQSVo5JMFcbKfidGY2EIt25C3ttuaTG4tLGrqUlJZSMfILZ/M44lD9fhvXLQFnoAu
	z68xSQJmUzNSvakeoRKoEwE/Gex62P+E=
X-Received: by 2002:a05:6820:3514:10b0:71a:fdf5:1bfb with SMTP id 006d021491bc7-71b39598717mr1955775eaf.43.1795191000701;
        Fri, 20 Nov 2026 08:10:00 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b37ea8472sm2147928eaf.2.2026.11.20.08.09.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:10:00 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 2/5] NFS: make the O_DIRECT write work a delayed_work
Date: Fri, 20 Nov 2026 11:09:53 -0500
Message-ID: <f3decfbd07b417383b170eb2bafc1000cd849578.1795122900.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795122899.git.bcodding@hammerspace.com>
References: <cover.1795122899.git.bcodding@hammerspace.com>
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

nfs_direct_write_complete() queues dreq->work on nfsiod_workqueue to
commit, reschedule or complete an O_DIRECT write.  Make it a
delayed_work, queued with no delay, so that a reschedule can be paced
without sleeping in the worker.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/direct.c   | 8 +++++---
 fs/nfs/internal.h | 2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index a3c6e8f4ea06..9ef8031a68ad 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -219,7 +219,7 @@ static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
 	init_completion(&dreq->completion);
 	INIT_LIST_HEAD(&dreq->mds_cinfo.list);
 	pnfs_init_ds_commit_info(&dreq->ds_cinfo);
-	INIT_WORK(&dreq->work, nfs_direct_write_schedule_work);
+	INIT_DELAYED_WORK(&dreq->work, nfs_direct_write_schedule_work);
 	spin_lock_init(&dreq->lock);
 
 	return dreq;
@@ -739,7 +739,8 @@ static void nfs_direct_write_clear_reqs(struct nfs_direct_req *dreq)
 
 static void nfs_direct_write_schedule_work(struct work_struct *work)
 {
-	struct nfs_direct_req *dreq = container_of(work, struct nfs_direct_req, work);
+	struct nfs_direct_req *dreq = container_of(to_delayed_work(work),
+						   struct nfs_direct_req, work);
 	int flags = dreq->flags;
 
 	dreq->flags = 0;
@@ -760,7 +761,8 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq)
 {
 	trace_nfs_direct_write_complete(dreq);
-	queue_work(nfsiod_workqueue, &dreq->work); /* Calls nfs_direct_write_schedule_work */
+	/* Calls nfs_direct_write_schedule_work */
+	queue_delayed_work(nfsiod_workqueue, &dreq->work, 0);
 }
 
 static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5af6a032f145..8f1361397f8f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -1035,7 +1035,7 @@ struct nfs_direct_req {
 	/* commit state */
 	struct nfs_mds_commit_info mds_cinfo;	/* Storage for cinfo */
 	struct pnfs_ds_commit_info ds_cinfo;	/* Storage for cinfo */
-	struct work_struct	work;
+	struct delayed_work	work;
 	int			flags;
 	/* for write */
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
-- 
2.53.0

