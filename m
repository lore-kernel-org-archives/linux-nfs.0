Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6BE713822A1
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 22:57:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787093849; cv=none; b=ri9uN5OXt8EDFUoB4sOy8dtHpsw5BCVBhZV4DADZOHlDNxJydSJSFKgksm4UWUX/18WWnjS5snWIeEZqFLHdZ1KbxggGU6/MHDoS8dSrqZT9fs5AFh4+/fFoA4M/2yhMKFEi1BTMPUGwg9V5caSF/ej+hGObEEima0w+7dsdnUQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787093849; c=relaxed/simple;
	bh=4yqtNfi/fYBjQwSuqMa3CVq0J9dlgvGFOgN32ellYD0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=qvSqtUgaGOWMvaaAgbhdWXWL5i1Uw/g6P7liNYnEqiq1wM7iCHKBc8eGwaCszPTvTPctblM763/f3j0l79J6WLKu/0njJ9l20uArWgHyOco1QfQ+004V/N0rukP9y58AE/QYwE+4CbXzaXFKxHsZukEUIx2n5WS63yBEqppItn8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=FB/nSPyK; arc=none smtp.client-ip=209.85.128.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="FB/nSPyK"
Received: by mail-wm1-f41.google.com with SMTP id 5b1f17b1804b1-4957eefd361so2774545e9.1
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 15:57:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1787093845; x=1787698645; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=e+zxtlZCZV0FZ0F54ec9MsjwqafxLqyL4TeKljBaAqM=;
        b=FB/nSPyK181vzEcHJPH8yTqR3FEIVupz1y63NNOCR3zMEMqhJ28jjT06FaRx5KAC60
         Yu7PKrURgECK6zQelEvS++So+u/t6r5MBd/7Aak8buykskEKcYzoIU2164XRxyJ2DwyV
         jqpNsgwDsh19nIzJvR87KxqbHaQb5NozI2mIfXhW2fU7p5vDZYvRizbxQZoWN0HYx6Kq
         meNtbRbHGirwkv5YBf2cgXkJh2lqEKzi1e7z+JqjtU3SYnERZWbwjhDqFhEtr5tEQQrB
         3boLiMFD0sfac1acE3TJt4DG/SNlioAPT0bhWnw/lHcU9QIV23R7GOxYeTkd4w3I3Zxb
         7jaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787093845; x=1787698645;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=e+zxtlZCZV0FZ0F54ec9MsjwqafxLqyL4TeKljBaAqM=;
        b=iYVJF7NPdqPVaCNEjYPqXIuoNMBoG4WnRT61J3G4VbL+ePbSrlM896xeTDnBZaqHHc
         wGoKfwrt5oNic6BpQMNempEUeaLE7bxHFLRi5CcoP/RroCTnRqgBHj/3hoJ8QzNSRI9a
         1JLgcsxgmTgeyggoFhqXrFkd9lZAwLqhOnovZYaNX1Zs3IlH4ltwD4WFlIcd8ede8rte
         zGmFYXKTeSVXJQ9hfVl8H2fa2uUGpF6c0pvs9imB1rXb4McA9GlLl8YCyEcHxNk1Mrpa
         gVkmvyOHZMNKFPVQ4XIC/XgZ5JlGzekBP0qVxdLnpEo5BDnKaN34NEp3vBeT+0JLNLWU
         8RXg==
X-Gm-Message-State: AOJu0YzAt1eOWbRxJQODXJRC90ERfL0pkxpNsRxRGwl764EKO+NpL6Pg
	j6Dhr6cyy2/gB/UdRouJ2pjq5/rbh1AaHUSTTayHbw2orXMEURQcq0O5woRGnpHCXQ==
X-Gm-Gg: AR+sD11IaD4ZxPgm1yTpXXjsI1h4g8u0cGwr+fgFerMfKCWtVjBEacA3vBcr9hx0F2e
	nSQ5J3oU9ACwvnt5G2Kni+c8C749yhy+37SKvIlL9N1raZZeVOpybaYnvPN9LqFNbtjDVY4OsaR
	i0ePzRJmbDPCwy3+hc1jDwvWkWFq3NZqhTgHcPeuyyZ/nUw99obZvX8XWrW3J/TOIGWdQKXmGF+
	LQ3j7Chvz/cYsAc67ipfbTgw0GwDqJ3pyQk6TQtsMIF2wgXhDunKkTjEPYykvyTmukqOg9En0jR
	LzuajZKjGOqX6YcKDXIgZuKbeF6FwL1YMehAK5e8Sb2h8G8C0xh9et8DUsUqTCUz6GYpdEamgA1
	d4SOau99tlFz6yPH8LJCTvNNRsbco69PFswUa8CE5Gvu4tXcW4ngHVVj8gtayCAc2HdwaKV/Bc7
	hMJWVN2wyDCs68rbW5zlZVffWqNb591wZhYZM9J5XL
X-Received: by 2002:a05:600c:8715:b0:499:90f3:13b8 with SMTP id 5b1f17b1804b1-499aa1c4410mr6608165e9.12.1787093845476;
        Tue, 18 Aug 2026 15:57:25 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700::1])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-482b14b8038sm508137f8f.20.2026.08.18.15.57.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 18 Aug 2026 15:57:24 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	ameer.hamza@truenas.com,
	stable@vger.kernel.org
Subject: [PATCH 2/2] NFSD: Update the atime for iterator READs
Date: Wed, 19 Aug 2026 03:57:15 +0500
Message-ID: <20260818225715.572140-2-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260818225715.572140-1-ameer.hamza@truenas.com>
References: <20260818225715.572140-1-ameer.hamza@truenas.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A READ served by nfsd_iter_read() or nfsd_direct_read() leaves the
atime update to the filesystem's ->read_iter, and not every
implementation does it: fuse_dax_read_iter() carries a TODO for
it, and kernfs_fop_read_iter() does not touch the atime at all. On
a fuse DAX export, READs never advance the atime, no matter how
often clients read the file. Spliced READs are not affected, since
splice_direct_to_actor() ends with file_accessed(). nfsd serves
whatever filesystem is exported, so it cannot rely on every
->read_iter keeping the convention.

Call file_accessed() after each successful vfs_iocb_iter_read().

Reported-by: Chuck Lever <cel@kernel.org>
Closes: https://lore.kernel.org/linux-nfs/2ed0ee16-c20e-44bd-9e7a-f5b71764f14f@app.fastmail.com/
Fixes: 507df40ebf316 ("NFSD: Hoist rq_vec preparation into nfsd_read()")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-fable-5
Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
---
 fs/nfsd/vfs.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f45d4ad70b964..f017729cc1be0 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1144,6 +1144,9 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (host_err >= 0) {
 		unsigned int pad = offset - dio_start;
 
+		/* Not every ->read_iter implementation updates the atime */
+		file_accessed(nf->nf_file);
+
 		/* The returned payload starts after the pad */
 		rqstp->rq_res.page_base = pad;
 
@@ -1229,6 +1232,9 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	trace_nfsd_read_vector(rqstp, fhp, offset, *count - total);
 	iov_iter_bvec(&iter, ITER_DEST, rqstp->rq_bvec, v, *count - total);
 	host_err = vfs_iocb_iter_read(file, &kiocb, &iter);
+	/* Not every ->read_iter implementation updates the atime */
+	if (host_err >= 0)
+		file_accessed(file);
 	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
 }
 
-- 
2.53.0

