Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.145
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793160654;
	b=t4rULafRawZafSi32Qe4G1wNyMeACgWU933q3IvogitSzekswVm8CleF50SrqKqeFBv4
	 tly1RIZ9sXoGvH1/h7S+9Q2l0exvrSWFHtP5FCMuO2S5ZDWb9zLAya8GaE+iQ8xhN8aDG
	 aajlKjoQv2Dhik8MbctqV2/DZYjgbJtBKSCB3Dhqc17ZopcPtc1q84UlbsZsyYwbMaAgP
	 NPrjt8vU+bxhxZtEkdVlYRaaH55n9cqJgS9OlsrG1C2jbDcbFJJfN+IjuXcHDNuk5Y+gB
	 Qk2xxd56W0OaGhOrM8JDlzbimEbF2BuJ/1fPsp6+qd9iKA15ki/D3Z5JVNiIk7xeDVg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793160654;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:
	 References:Reply-To:MIME-Version:Content-Transfer-Encoding;
	bh=hQZh8NhkxOMWWoDu9n1I0xZHgx2A7inY4Slk51nZ6WA=;
	b=JXPDFvdbZPBNNeaGKt5HSNg2wGv1it3fwsFHDB+ggopArHF8Ga/qJd6u3QpM21cONysu
	 oG1G9ecaQ2/cijpY/UjRQiJCU9A6oFYV2jNtLcaDPCMFUrZRhaovzGHcrfSLylY5UmPn3
	 Fi1p8OWmVNMdh5KtV4lgRgNVrlFSetoyCSHdnEQsBlyJHgIgAjUqZt1rmUi4NejR7DhIo
	 HtHBltRVNMsqcSuLEuJ1quD7bOCn1fc4Da/4ADXZzVLQuEXaY1Aby82KejyF4G/uj2rk1
	 oNc0il0aSBaGYkIGmjI/cEkXF/lfQcv/wmwj/5UtnHSk7+tbfK/Rrquxr69Qyr1eqew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=HAiSv9n+;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=EVztEjjM;
	arc=none smtp.remote-ip=202.12.124.145
Received: from fout-b2-smtp.messagingengine.com (fout-b2-smtp.messagingengine.com [202.12.124.145])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B24F606A31D
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 04:10:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2B24F606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=HAiSv9n+;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=EVztEjjM
Received: from phl-compute-07.internal (phl-compute-07.internal [10.202.2.47])
	by mailfout.stl.internal (Postfix) with ESMTP id 828161D001DE
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 00:10:52 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-07.internal (MEProxy); Wed, 28 Oct 2026 00:10:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm2; t=1793160652;
	 x=1793247052; bh=hQZh8NhkxOMWWoDu9n1I0xZHgx2A7inY4Slk51nZ6WA=; b=
	HAiSv9n+EeYtYbCTI9V9R0VW+hR5Q7Dv2xl5OEKJpnB2iWm94xhsrqOrWcuiY7EX
	sTaktqtLJkU8foAIDzK2sGlDGTSn0VwplD3hz7XLjvgch+aBGWmnyEfwZoT29Hmy
	BuXYa1amq4waJz06tnCx0HkMA4ozPTY9qhaI5W2Pr9TzVX7eJEy8hXVPlm+yolKY
	Y9hcv2edEqJ7+Q/fgybv8h7vmPo5xB19yc8/lpojCo4smy1IKA2OpY4txC4WI9G1
	2btRomtTFAatoN9pAIWSLOtesa/UUXxkGO4QXpFyMzPNQUu6ZApskBp5c/jXnRmq
	xizL+D9h1NcHzzCwWzOn8g==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm2; t=1793160652; x=1793247052; bh=h
	QZh8NhkxOMWWoDu9n1I0xZHgx2A7inY4Slk51nZ6WA=; b=EVztEjjM/Yc4sl2+O
	srmjDl9TvWOyLICQI8Supg1bx+FBCcO1ZjZgYSTwV1xKTuNJ7VfXbpsh87PRYhyD
	i4+UpCJkPGRSOkLH9FFxg2It5CZzOLZqj67ucgLtDFE7JOzosl3SxeQhK4q6PaM0
	jnf4w2oFa045XChpbsWkAXqPog6KHxswnAVnRqmHidO08Oy53jzId7HnarlTrws5
	L6s/U9wfVQ3XRarPuprc3UIoqOMlzm9RO5X+b4oeb8R2yXfCEBF9HhDdVTVdPeGR
	et2Bh3i86cwO0JZ7H9MAZwlX9NTpABhB5hmdRZOB879lgp/HXwFl/B4rTkWBytRd
	NtRKw==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793160652; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:II5k4BBEAELMvb2LhrQip33ZTl0cqDow5/KaeGqNU68fdZa
	eUVT2+wisKnh0XNpqyGo/atbZfPo+zy3G7zYYknPUwJkO6qrNBkheoVf9hv8txDI
	X8VYwEOCOgXaH73/eF3GRoR0NqYgu1wU06Ik6CED3XzOrYJdpNUwRKBQk9XHfYt+
	9WPeth7mATqXPhspvUxOxW3TvZ3lbQdaLjGRdhySfGATNDTM6D+xWOrhbr1rwMkI
	cB/7yEm+7lgobI/jxVTnFvv2JxbL2z4NAfG4cgc87h8vFCNO5t+4/KWq6mILS0Lh
	xqdyZCc1/BxHM8vDW9QYKnoZvDMbpjnL4Vn9rWw==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-07;
	repo=github.com/dkim2wg/interop; date=2026-10-18; sw=lmtpprox;
	action=mi-m=1; hc=12;
	hn=cc,content-transfer-encoding,date,feedback-id,from,
	in-reply-to,message-id,mime-version,references,reply-to,subject,
	to;
Message-Instance: m=1; h=sha256:CLFz3lbEDFthX2ksPfadozk0m6+FyDl+t3bbInZB6Fw=:XeUvSGmrsuRVKscYb0EA0v5s84mC7gqlJKX0NEX6XvM=;
X-ME-Sender: <xms:zHXhatJ53Lw69PnrWG5rLyJZrrHSJ_9ifi7f1Hz0P-_K0ldlUDVU_A>
    <xme:zHXhanYQY0s2o1UOJZY3p0xDNSNqKL8QBLwcLqAwwkSYHY7DpKJEvv5uoee4qwV38
    GA_gHecNt4wqmFPhLeCpRAHw9FiQnWCEDgaML6cc2ZmJqBEVUQ>
X-ME-Received: <xmr:zHXhavBJDpKUZDNbNX6s-7LrY8MugPk571FqWVMjqTw8tYpEODL6Fr05KHbM0hviLg>
X-ME-Proxy-Cause: dmFkZTEtaaJo3zhk6q8YHjcrAGFhzjZGx7kav9mjn36dhiCDz1sQNUcnPXqPMC3VqBUdUM
    QC/BqNrn6VDtoNvGfXsPC6PtPC8Yf5vcT7dSqr4OQVWjbDjoqPju2ao8WKvEVWn6qwQJpD
    4CN6jGUHDBUbMwADgY1eHpCxVa8gj9W+FVkilH/Bf9wmvEra1caZDRUZmQcG/Ro3xW8rsx
    nbEpGLXA1HN5mBuF45EijzjRcn/0zOhqfoHROonBfk2oQm2kGy7PxZcAZk+GCvIPn4bVTg
    3udSvT9vlUjceFzrt+IHSgKFct3qykKWsSJoK8kyGUhtj7khaHZlaj5tXb3YwgPRJ+b+mY
    z73jxXjVEEj+d8hVQY/pU4b2x5pQncNcyFqpsb4/Wo4hEu5nDSAsgaLQyL/JcO5f4qLLQv
    q6ggWO5k8tsz8+vGFW+xTdbv7irePtTq1xbgnkhSdqkMjipWfSfHuCXqbjiaq8MnonBfiM
    b6Nitv9oC3UaqOlkwhLa0t3qz20qFFxVoJUKp7X7RWOQ1WxlQPY07K3zTFjt+mPR2Zvn+c
    +FertsR1sVeACiaj6125oXE08TsMahOqkQyegDcss/w0BIwelmVBRpQSchuyVZSiLGQ/wo
    leRRB3JFxnTSLLR4FX7ssTFL/FdGSlCtDNhqMROtBC4lwZHDYF6SqcDIUpDQ
X-ME-Proxy: <xmx:zHXhahbup0aGqldVZCeH2Mwe6Q8G2ci1N9JXiJN9WjhI7k24GOL1_w>
    <xmx:zHXhank-e1WEwZTPSDAtXIejniYlzs6p1q8GkzIsk3KvARG6GWEPmA>
    <xmx:zHXhamq6V2Iyt3tXVzrCInPQT9ceXMDpUtOW1AtGi_eIlVw225x93g>
    <xmx:zHXhapDU3j4cISb3H6WXkqgGdgtl-_15ag3PWSq0BtEzxVopUxIcbQ>
    <xmx:zHXhamqSa1-R_R5n2vYD_oaIUTdhjs4MAXarIsM02mkiFoE5--37FIEU>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 28 Oct 2026 00:10:48 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v4 2/9] nfs: fix nfs_call_unlink()
Date: Wed, 28 Oct 2026 15:06:30 +1100
Message-ID: <20261028041023.3738553-3-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20261028041023.3738553-1-neilb@ownmail.net>
References: <20261028041023.3738553-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
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

From: NeilBrown <neil@brown.name>

nfs_call_unlink() calls d_alloc_parallel() on a dentry which has not had
the d_hash calculated.  d_alloc_parallel() assumes this is calculated and
doesn't calculate it itself.
So this will never find an existing dentry and so will not detect
the races it aims to detect.

(This dentry ("alias") is never hashed so there is no lasting
inconsistency in the dcache.)

Fix this by calling full_name_hash()

Acked-by: Anna Schumaker <anna.schumaker@hammerspace.com>
Fixes: 565277f63c61 ("NFS: Fix a race in sillyrename")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/unlink.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index c8d712204e64..11a46a993e11 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -125,6 +125,9 @@ static int nfs_call_unlink(struct dentry *dentry, struct inode *inode, struct nf
 	struct dentry *alias;
 
 	down_read_non_owner(&NFS_I(dir)->rmdir_sem);
+	data->args.name.hash = full_name_hash(dentry->d_parent,
+					      data->args.name.name,
+					      data->args.name.len);
 	alias = d_alloc_parallel(dentry->d_parent, &data->args.name);
 	if (IS_ERR(alias)) {
 		up_read_non_owner(&NFS_I(dir)->rmdir_sem);
-- 
2.50.0.107.gf914562f5916.dirty

