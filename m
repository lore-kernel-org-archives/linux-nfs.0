Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.171
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793299320;
	b=n1ZFVaC7yxc9B2UNHaPLiLfLwwk2D9fFJHDzGAQOQI1YA6VsPcvVk0fzYZMfYHeXt5fr
	 zAKQS5GRUwTlVM+I2Ckv+Lc9iAsoVsR8crff8kEyTpqPqG9IQ3Sb4Q/XxCRVGNF9sX9aB
	 g+ouk92c4mEpq5Eks96/kTuYd6WaOVqaZTNVEwKNRXBe9FAQorvOnQFDpoNEXuqk3WkZb
	 SzVUJjmzInfUBp7gYSZbgIaoUI910UFrIUZY1VL4tPCjwdZfhyRT3zGqgrK1VeMtdqi3Z
	 4v1lN7Ws35ZG0dVjPxwvWqp9sm4qxCHgHa6m47Aw4HtceFOzZ+YXCThOTh0XZKDfFfw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793299320;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=lGYrY710riRY7PYILjmn0q85yHcHHg02+ReDFP2Fo/0=;
	b=Rb8czzg/FHMTRSRE9P+KekctTHsnI4E2kUE2Nux645gLJhe4qxsgU9E/o6DZG36Xkzma
	 6GhgE3OeB/o5Tn1BI7KuDjF+owTr9JYbzIa97VRfc3gYYeg5LfcKqe8PRFOkMoClwAF2C
	 X0PfCpPndRDa54uuvX8dkM3OFvw0rkVvxpojmWGYNTKawW1Ozcs1h9IpS6UkbtBgGXdzg
	 dximTwg2GeIfj64vPlNut/cp0wBydMrZtuOzpwvbOCRRaE+Kl2Y7/Iu4gp8XK9mWSxWGe
	 wv8D8n5542LLHLwGaPWvc++HtfDQeGm3MT0vK24obrGBCHH+CnJDSBtiXEgKo7JfWgg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=djgHZWGz;
	arc=none smtp.remote-ip=209.85.167.171
Received: from mail-oi1-f171.google.com (mail-oi1-f171.google.com [209.85.167.171])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6564B606A322
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:42:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 6564B606A322
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=djgHZWGz
Received: by mail-oi1-f171.google.com with SMTP id 5614622812f47-5058b105df7so1003839b6e.1
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:42:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793299319; x=1793904119; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lGYrY710riRY7PYILjmn0q85yHcHHg02+ReDFP2Fo/0=;
        b=djgHZWGzDNEcXdZceneju3rwG5PMIvmA9GDXBHkse7gCVdh7epnPSIbDoANFm2I4SH
         swpQTjHbgqcaV3WiRmRJRilxTSYSDWc/cZ9R2DeCVVEMhqxp8osJE1LqfXw9BBftnDN2
         IPUj0DGPgbXG7Ouo3ARh64AQCcKz1bqjj3E6lJQwuDAGcvcsQ45DUneZfuuJavd9xNRQ
         yuqKHvw36Ny6xL7PSI7PT70yYJQK9VZ7yoADt4/iLShfGKNccEqEjz4Dk1+3AfhQfdLe
         LeuNFBb2r8WoR12EYo4kfCBxREL+k9R0pRa7HJMJeMeDwzEv5wD6tqxV+7SVSrk3PK6F
         njrQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793299319; x=1793904119;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=lGYrY710riRY7PYILjmn0q85yHcHHg02+ReDFP2Fo/0=;
        b=aNyKra3aYX8vJP68gcVjCkTiAhuNb+8C/xYZSzKA8MGY2T4rrZCbWA7BmpHOU+chR3
         yvcxszmCWWX9ov7OTt9+1iMw5DjEiYYp6rpdD/R4pjGEtK0AOLyMJvxykYiMdYrxnlZO
         PIbsfTBJYtqD8dUxn0+TnA6PKGrtZpjF9Uuh7Rgsx8WD9fSnKJS45nAnOuCkFNIirCHP
         TOqtkZ/8RXQB1QvLMQ8BHnDWqcPX6i9q3nJDjgckmQ/+PZAwn2rIdQ23PCwfsVVKZpZR
         S/9SSHAXUh3FjiHyzteTslhwHEX2AzxdJw1JndW3tuq/s5CMw+M26cfS0BsYMowptWh3
         O4Xw==
X-Gm-Message-State: AFq9FYIHqtUFeji0+dN/4IlPqHtJBYT0xxJG3g/q6ces9KLjy5hl4RxZ
	mHbwPz3xQzLXIRZxuVi34FjEDz3zYJSqXLvGi4V5Yymfr8Aaxd3YXvY3HovoO0o8ILVU8FfP2aT
	XBy6B
X-Gm-Gg: AYBFou2aiy9LSmMZm2iVWYmc+BwLLt1K/Dj3yanwdwOGhRiDfKEXnHYtnSFgAw4mOeP
	+t77Z3DEXA9wS5Xd3eva9BvDA9yExqrV+YywZvxHmwzq478hP4adxYYCiRH76eymbpHSphooK78
	8j/eZgAgPtlunVivhdX7P+lfJBH6tCvZPM5vDdniorBuJFhe7HkbkabPyh0GwwJQpsuLSLfwT4s
	rc17g1eI25Ww2G9pUsxFNR9SzXp2dRp6fnJ0u2QdM2kREo+sZMxEaX/3jjMDPv8ohDkvhctKJF1
	FpKBxpek2LTwjwtDQ+4WekQ9QpAwtm8xGj1yIrzVQZuc+p61QbXvYnJgYds3/Y0zFAqrf00EtB+
	/oD/5oTF7r4yN+iGqgmauQZ3ZqXX3JjKaUJWXQCqPDcSyytIzTkb8QUEja/vpgBF00Q1z6EEQ27
	IgdJsNH7mGpJyEf6FndAQgyjVeDCv/IRvSxPG1KxtnLcBiddmccafvB0WoN359mwFx76qDdotHK
	936Wttr/Yf5cc9qz6AxIjUYbZy2MeSsMZk1Jp7s8954Yz1IirEvKteyxgUM3ZiaOS2m74+NTdus
	Tkt1Fjku0J6brVlOO4qRexOVwhwA/ygFeTQwopyYXnpabPmeChcfGhLOM9sjJJh6ZAopwS2ZJcX
	t
X-Received: by 2002:a05:6808:2388:b0:4f4:4de8:9376 with SMTP id 5614622812f47-5640dddba4amr56007b6e.54.1793299319222;
        Thu, 29 Oct 2026 11:41:59 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640e23b76asm7161b6e.11.2026.10.29.11.41.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:41:58 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/6] pNFS: clear NFS_LAYOUT_BULK_RECALL when an invalid layout's last segment is freed
Date: Thu, 29 Oct 2026 14:41:50 -0400
Message-ID: <b740e426e4480d70f439abfca5ae82d0e12e9b95.1793298149.git.bcodding@hammerspace.com>
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

