Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4166A1A5B8A;
	Sat, 26 Sep 2026 00:11:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790381466; cv=none; b=l3TyQZaEH1KPdCkDxuylL/pS3cj0MW5HlxOXGhA3LhH2wxhyhWzgJC1LBfmJWoAtifiU8F0XRjX9YEBUzLnUVFhrQh6Ceo3AfSXUTvQezydbo3CNtzpZEym1RBMKyfPNKozv0sZ8C+Vup8RrVSJmHWbGKCKaLp7A0lwfPbuZdkw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790381466; c=relaxed/simple;
	bh=Rj8mrG4OhoDtc/K0+ngf1ncfakHuLIQICnf7WPsuw6U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=i7rSsVzLy8f6Cz8useHwMan3QPsXzVfw2P0WJPMPlAVPkHMLmjoXhrcWL4B8t6BI2gdLe1SAGflV6t+h9VRG6BomvYrVE15uQvglW+eOvLhRlICkDPixM4XMA+cqx8NViRwxccDkcnXztoj61BDA8t+f887PN2NCX43rFVdu1w8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=e5hpCYWh; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=GWoCeecN; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="e5hpCYWh";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="GWoCeecN"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 2F1737A00D0;
	Fri, 25 Sep 2026 20:11:03 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-09.internal (MEProxy); Fri, 25 Sep 2026 20:11:03 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790381463;
	 x=1790467863; bh=MnDjfXQvhYCS9cbXLtzi/mnGhccb8pedJ31lXybm9f8=; b=
	e5hpCYWhpXTswsxe+Flocjrxgg1QIG33ZOkhT+81FkQUXACAMohoJlKyXdiTYdjo
	WK5L4tdFE+hvyyE3AoHqBK92gZvHyh0PUbZEqh6/t/VmSp71VVe/zacCXa59XTN2
	JihsJipgc3xz5OrBJVZF+jilNzw8KH+VqBSSWg+ZNnFwAowCvjMqVJsqmbeCxllx
	II94MjzXXfRrI9kohdKzSqu1tI+jj819IdTrHhPKgZHWZnOVQXS1iPhAyBJMGQID
	6Y4veNwPQftsObCwMWGXpH/9oYeRgmIaIGPqT74S4kJlYosj2Qn0Z+Mq4uY944sR
	ms25k/87zQthpqi+dTv4tQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790381463; x=1790467863; bh=M
	nDjfXQvhYCS9cbXLtzi/mnGhccb8pedJ31lXybm9f8=; b=GWoCeecNBeGB+QNc1
	L8czny8IY3B2bu394ZW7WPBD39biRx7ocq6BE/Gp6Sn12/2TDzJNrMMf5DIqQZo5
	6s7xQX96ivcJiShPP5X2pXqEboMitOu2K5DV03noEK5cl92cR6f1XV+jN7FCzRbE
	fjErc260vaA99CDkIRZXCLFMoTJXEjPc52kgo9VE4paLWCTSyAD+cv0KUbv6fu9j
	qSWhoZ8mcEXxtC3vHFJN4AEOqX01BtvlA7zXkpVTjv/LAa7HkZwu+JxZGWQn5RHA
	7eUoR+l7Lg5uVPdNl3e/t3bq68NoJ0dzIP+TuzADerl29nBpb1RhViaVycqi8fCE
	zar9g==
X-ME-Sender: <xms:lg23ajfTszdEEFGZE8DLftoQfiNuYVJE1MqcxsqyY5yKtst89UxihA>
    <xme:lg23arw4vOLyFCdLH9uRy13KD8blxIjMeRfe5t1U0KOKX4FVCyAPaPy3gt82EQz4Z
    NnxqiHYKDEjK_2tfznlrOyjm1g972kzx00Rgytr1B9DZir116k>
X-ME-Received: <xmr:lg23agLlioF6PlLuu9K__MTHj68r-_0TXuGNB40fntbSFy02XRgmOb9z6aqapFNazS8qWpTsTU9U9HbzS5X7OOgmMZeMWD8>
X-ME-Proxy-Cause: dmFkZTGRK8QWXe3nRadxtPbELLkvrDBk65jMMJlDbRQiJ3I+eAs/RrYr2334q3aeTtDUsI
    0yJSntmoLyr8KgVTJcuP/52kAG2EyKLVvKYyj+YdVJwI+dWCtt8dkqbOnPk6a2iewUGGb3
    5sQj5r9IclyDj0CAiqpm3vyd7jbFlQXpDU3euXydwz3xORujrGGX6LjLAjm1JKIOAkSHG0
    CGuV8YJ1pyazczarobqBmpnb5/CbkcyeHZR9PgXLYLIeLUcFAa/VxqXyPNB74WmhkHPaqt
    SLuuWaNBYf4+L6TSmt2yFibGnXA34bmiRTwWSSrtl8p44WF281+A3SXE5JbZjkpdVhTYaH
    Mo6q1w9kF3srxSgF7wechrj2hDwqHkuyZm9l1RsKvKMeqD7t/Z/qIy/DS6tmaSPLzozArO
    /74/Cdpyh/IMgXj8caBtlJhuIGWR4fui6lTRErnwSP0L15uJWIEdcv5RCsgE7MFf5BiSR7
    8I20Mh079yUSpmGcrJ3DP0YZSPG4p0lqW5gbSC6jpHS/6GBytRYMOEfQqv6/bbFa3XgYh9
    m3jtiIpDo8fXBCWf5HgfwZzhTnw6jWegs0nqeA4EhcyrLno6IQNPuzzW19e2p/83qU0RWA
    z8F/DcLBn/ZlY2TC8sCwFlueaEAV/4CWgZdk0nGuwe4BleNVcWeGdcr+P6bA
X-ME-Proxy: <xmx:lg23alEDSNnZRsqX4etVaSS-6foxSUzCdE-6kUgUHKCgqrHvpOr_pw>
    <xmx:lg23ak9f0ASukdfusewAgs_kDBGhSqEer1vyEFYDqvaA-oOOSbLM9A>
    <xmx:lg23atJEz7IWbJsLQ3FFG7J0l5sbPV84QgTSrNkG0LK8TjIqMHaYvg>
    <xmx:lg23aqv1s7D7Z5d0wZJcuH_S0kD0oiP0YoDEEuRuHdvfoWXadM4iPA>
    <xmx:lw23alX6gk9wH9_CSQmkK7_9UaX-Z98hScTvjCRWQHwiXbIyZyP0X54P>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 25 Sep 2026 20:11:00 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 2/9] nfs: fix nfs_call_unlink()
Date: Sat, 26 Sep 2026 10:01:19 +1000
Message-ID: <20260926001011.401824-3-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260926001011.401824-1-neilb@ownmail.net>
References: <20260926001011.401824-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

nfs_call_unlink() calls d_alloc_parallel() on a dentry which has not had
the d_hash calculated.  d_alloc_parallel() assume this is calculated and
doesn't calculate it itself.
So this will never find an existing dentry and so will not detect
the races it aims to detect.

This dentry ("alias") is never hashed so there is no lasting
inconsistency in the dcache.

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

