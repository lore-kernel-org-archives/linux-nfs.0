Received: from eu-smtp-delivery-195.mimecast.com (eu-smtp-delivery-195.mimecast.com [185.58.86.195])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 968DD47604B
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 14:48:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.58.86.195
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791816494; cv=none; b=alonr9F+2RNVZSr1ApbIaHMRhdpAYCas8IcvaxG/5LoA1Qukh6FUdXfzWlKHLkDn8Gy+sFNbDYUzFQuvY75UQoQwCt5Wv+PCDPa09yKunjfV2Tl37zCa4o0Q+pIuyv2YeornEDIqyirIO4QYeAS3FfyucNOb1hRhnvvUob7vRCE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791816494; c=relaxed/simple;
	bh=SFWnOeGR0HR3+Q0lgYeCbUrh4xEfAG0q/YYXAqo82kA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=PuvUO556/YbaMNdcoVs9aNXy1dqpKdd5CVWRB1RDLkYdUVTcIcGy1hl4J67U/dfntqI/ZMzA+F4HbG6+1XGkOY6SF+9zxKYr2S2Jf9gcgcpXioU4XG3rh96bZBYULpcFsWJ9MfU5BRWjGoolHXDDcY44tmbQ8zyCCAcAAtk2kHI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com; spf=pass smtp.mailfrom=gsacapital.com; dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b=ehHFB0n6; arc=none smtp.client-ip=185.58.86.195
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gsacapital.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=gsacapital.com header.i=@gsacapital.com header.b="ehHFB0n6"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gsacapital.com;
	s=mimecast20170115; t=1791816484;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=/g+VRsfCsU90OiosNTp4FbrOr+gRe3sW/oqURtgMt1o=;
	b=ehHFB0n6Ow8srquuTIJWmOiZRh3T8paz654vrIMyRNEFWg2ntbp6synycIDC8hiBxsvovG
	wy2Pb3uAVNFkVAguskCdKhYkNmZCpLfasT2zb0aaEB8RPr6vdpPdCXBuIU5e2Bso3q9Rwt
	by5xk54SHDBxwj4cL3Cz+Z5rDuxoccE=
Received: from mailrelay.gsacapital.com (185.137.2.10 [185.137.2.10]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id uk-mta-277-yZe98EwvPtOggdWAWTxcVA-1; Mon,
 12 Oct 2026 14:48:02 +0000
X-MC-Unique: yZe98EwvPtOggdWAWTxcVA-1
X-Mimecast-MFC-AGG-ID: yZe98EwvPtOggdWAWTxcVA_1791816481
From: Rushil Patel <rushil.patel@gsacapital.com>
To: Anna Schumaker <anna@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>,
	Jorge Mora <Jorge.Mora@netapp.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Scott Mayhew <smayhew@redhat.com>,
	Benjamin Coddington <ben.coddington@hammerspace.com>,
	Tim Saunders <tim.saunders@gsacapital.com>,
	Mark Brading <mark.brading@gsacapital.com>,
	Ben Roberts <ben.roberts@gsacapital.com>,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
Subject: [RFC PATCH v2 1/3] fs: export wakeup_flusher_threads_bdi()
Date: Mon, 12 Oct 2026 15:47:51 +0100
Message-ID: <20261012144753.3400341-2-rushil.patel@gsacapital.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20261012144753.3400341-1-rushil.patel@gsacapital.com>
References: <d39afd89-0543-410c-8c3a-c8869ba643bb@app.fastmail.com>
 <20261012144753.3400341-1-rushil.patel@gsacapital.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: an7gpXjC3nnQxnO4lG5B70BkpEX2ejTP7RPnj58fb1I_1791816481
X-Mimecast-Originator: gsacapital.com
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset=UTF-8

NFS wants to ask for writeback of a file without waiting for it, from a
task that is being killed and can't safely block. The existing exported
helpers don't fit. filemap_fdatawrite() and filemap_flush() both do the
submission in the caller and can sleep there, and the writeback_inodes_sb()
family waits for the queued work to finish.

wakeup_flusher_threads_bdi() just queues writeback of everything dirty on
the bdi to its flusher threads and returns, so export it for that.

Signed-off-by: Rushil Patel <rushil.patel@gsacapital.com>
---
 fs/fs-writeback.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
index ea3eb40bf828..9036ebe0c7ea 100644
--- a/fs/fs-writeback.c
+++ b/fs/fs-writeback.c
@@ -2551,6 +2551,7 @@ void wakeup_flusher_threads_bdi(struct backing_dev_in=
fo *bdi,
 =09__wakeup_flusher_threads_bdi(bdi, reason);
 =09rcu_read_unlock();
 }
+EXPORT_SYMBOL_GPL(wakeup_flusher_threads_bdi);
=20
 /**
  * filemap_dontcache_kick_writeback - kick flusher for IOCB_DONTCACHE writ=
es
--=20
2.47.3

For details of how GSA uses your personal information, please see our Priva=
cy Notice here: https://www.gsacapital.com/privacy-notice=20

This email and any files transmitted with it contain confidential and propr=
ietary information and is solely for the use of the intended recipient.
If you are not the intended recipient please return the email to the sender=
 and delete it from your computer and you must not use, disclose, distribut=
e, copy, print or rely on this email or its contents.
This communication is for informational purposes only.
It is not intended as an offer or solicitation for the purchase or sale of =
any financial instrument or as an official confirmation of any transaction.
Any comments or statements made herein do not necessarily reflect those of =
GSA Capital.
GSA Capital Partners LLP is authorised and regulated by the Financial Condu=
ct Authority and is registered in England and Wales at Stratton House, 5 St=
ratton Street, London W1J 8LA, number OC309261.
GSA Capital Services Limited is registered in England and Wales at the same=
 address, number 5320529.

