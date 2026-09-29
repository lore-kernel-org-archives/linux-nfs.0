Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E6F693246E8;
	Tue, 29 Sep 2026 02:26:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790648790; cv=none; b=qq+DfKNZCzTv+hLrSHvaCyhSTRpL9kaX1InMZv3o8UPo2UAymbHMs8MP2NWPEBtIlvxc/XKvxdgW5aFUSmRR2SXjewz6AsKOnz3ZvKI+fTRMQGNi3sv44An3RbFS6BPts9oaMAJxonOvbD10XFG1A0I9z0Sqoep9PTCnOLrQczA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790648790; c=relaxed/simple;
	bh=i/lKgAsH/C/AV7pVWtaiq1i4qrbxjN2LinNdz1jk+jk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=QvnDgkxJplqFicG5ToP59+OwK1I0buRX2ZpukxCL2xVOvgnWbYuddsKmbtjdrK2uGwOeE+R5gy7Tfqe+/kmfxqrb1PEm5+czYu15BeDGo6jQWw9rg01ntdjImfVtHyrl6xj6InKF/BJMEQvCU0S4CdJ6aukCd1idokpAf9eneXs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=dzD8g4gv; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=F8N95+iB; arc=none smtp.client-ip=202.12.124.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="dzD8g4gv";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="F8N95+iB"
Received: from phl-compute-09.internal (phl-compute-09.internal [10.202.2.49])
	by mailfout.stl.internal (Postfix) with ESMTP id 1337D1D0010E;
	Mon, 28 Sep 2026 22:26:27 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-09.internal (MEProxy); Mon, 28 Sep 2026 22:26:27 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to; s=fm1; t=1790648786; x=1790735186; bh=fQfipOJolE
	kHsmqImv36lHB5+tqfbMddkfK+T0q8pyo=; b=dzD8g4gvk6ccjhyrboNoDbYvzc
	rY0jbbZAR4Y74bafRixxZFxVOFIzVJjsIVj5bPwkhigw18S/Th0YxAjaY5b2QaWu
	caFCV53k3gH5ZkpmUvTsi7LYIndAXoQ+HFPEtlzypvxrnU1h5qdIwFsjyjOQe+P+
	rZlaeheHRIubb5boFzMQ2lmM7+MjEYJqzh/xmgLQ+K1uE+JLACVhclrH1I+3q0BS
	xQLyewPtwQGRVv3IMNPTrTxyLWfVwbMzj4lrD8CgmiDee+agy4GHtgR5u+GGS6Xz
	E9sUvNC58JKuYn0ByItVCgRYMa5+SomyHawQPVyg5ZNLAZpxCyzxIC/kusjg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:message-id:mime-version:reply-to:reply-to:subject
	:subject:to:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=
	fm1; t=1790648786; x=1790735186; bh=fQfipOJolEkHsmqImv36lHB5+tqf
	bMddkfK+T0q8pyo=; b=F8N95+iBaQqvKrFMwCmZxu+LhSHCZmSv6wlBhPZG+ZE8
	Ajx/+jxn7jeTEkB9kcKwCZAt0Pnvfuw8yxTVn9Ha3w6STLmykWEKfPpYkiBmghvN
	yC4bpequntXs9Xv6fCAzi6s7Vx/aLlp1uFORn5fCyIrbw7ZtRY4OKorIA+XUow4W
	NJ7p63OzMMsP/2ylgnAEr7GVsInn3w61mzEfATep0B0T7eKwRMpzSL67QHJV68qL
	IL6ZCfAMW0EBphcPRgptEUmZ94Qs7Dav7lVFuwIw8oYqXGwPp9g8kmVi6OteS18H
	T2J3Zo5yjnRzYctp4hbT52asFbGSjzqHFSLaOEBSjg==
X-ME-Sender: <xms:0iG7atMavhIjwEhlH66k8-NOCHf1brSrQ9ZhO9NiID-50ERjw6b8OQ>
    <xme:0iG7ajD_A6zFrmD7WnLdaaO_bu8ODZntkbkTVf1-j6YAJ9wQK_qp6erls63Rv4dPA
    X8g0By8MPAL_-UiQciMM_0D1pGCet4DFAFSa9w8dmMehZNX>
X-ME-Received: <xmr:0iG7am6fVhF8dfc_oKKkmkSfP7XiOoV4AH0nbUdq7AsVs-lgg_zfBAnv5PUC9pP6_n-nuu_HPOr9HKfnrauL0En_IaNi6gg>
X-ME-Proxy-Cause: dmFkZTGLLDYQTXj5BdO/E4j628mUGGgHEeIjGN+IUdKDHlUNcmhGbvXTpGYZ82xelyoMp9
    iOCQhEshaVrLMKBvzE+CUFCf+V8K1VongVdcTlpT4gEzHejYMJIFVB9tcLkRIljcA5ciZM
    t8opHSyP6q79YHQoxDtGcUuwyUkR+uR3ygjcgDgayZWqTH7FwHCHCQHlWOmQbWGjoosDV8
    vR9i96supiDiNaOWnZinNrk18ZzNVmL1G28s5sNi0HTDi4aTTToHTYtXrp3LQMqAg5Ahfw
    2caUVqZxm7SgyJ1VEEJsKM98R4KTRyMcZq8FA5cbGPqpmC9HvA+aIoMnm0g/iwQbicGupS
    1cOehSSF+SRWNuDa+ib07N9iztfZkzEdNrQdidQHOzT0DSAUJGlKYeeaoRU+RtKp+Ml/5q
    vuaz7kkmQmZoGHFdNlqiepRuia9DGAiOvi7We6wNRzHhNdTnjogs69K7ymCi3/aRq2HdcN
    zPXFmWKxGcwXccgywc9j5+dRwHIBEqJUVJEG54keEzsr6m/x7a29JeUiq1kXO4KTTEj56+
    BlJsgoMEH2jOJvz6sjjPidxSQpKQZdF7yN05lkvCpANiWsZWPDfmtoTDUgMHmsuchIUfWR
    DZtnKx3urJS6whpsVH+PdJjplw+YSVOtB81oGXgbCokXQoGPBrmXQqSXIe3A
X-ME-Proxy: <xmx:0iG7al4tiWsIdtxI5FAlxvw2MvN5IAytb-9dInev8f4O-JTHrklGFg>
    <xmx:0iG7agQuk_KCuteTRnzfMuXw8Yl3H_wrKX17V63LoIPPVwZfaJ-RVA>
    <xmx:0iG7al9AJCpPEEi2NwYQcTyOaTvAlPVOJiyteFHRtkZrrLlNAcv5ew>
    <xmx:0iG7apaEU8Y0YeKxqqbKPpFV1dY1aWRtQgHRgy7IGhOXE7DS4j6ZNg>
    <xmx:0iG7ap1P3kNBgW5Qht5UXOZH0mjErFedG7uMOWz8K18UwbEyv5yctnjD>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 28 Sep 2026 22:26:23 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 0/9] nfs: prepare for VFS locking changes.
Date: Tue, 29 Sep 2026 12:21:10 +1000
Message-ID: <20260929022547.1428036-1-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

sashiko reported some problem with the previous posting.  A lot
were false positives as it used the wrong base.  However:
3/9 had inverted the return code from nfs_neg_need_reval() - it returns
    1 for "must revalidate" unlike d_revalidate which returns 0.
8/9 didn't handle and error from nfs_lookup() correctly - it
    should be fatal rather than triggering a retry.

Original intro below.
Thanks,
NeilBrown

I am working on changes to directory locking.  The medium term goal is
to lift d_alloc_parallel() locking above i_rwsem, so d_alloc_paralle()
can be run unlocked, and consequently cannot be called when ->i_rwsem is
held.

The requires:
 1/ the d_alloc_parallel() not be called while i_rwsem is held.  NFS does
    this in a few places. New interfaces d_alloc_trylock() and d_duplicate()
    are now available and can be used instead.

 2/ a dentry must not be d_drop()ed while an operation is ongoing, as an
    unlocked d_alloc_parallel() would then be able to create a new
    dentry with the same name.  In particular d_rehash() must be phased
    out as it won't be safe.  Various techiniques are used to avoid the
    need for d_drop(), particularly that d_splice_alias() is now able to
    splice a hashed alias.

Further, the first two patches here fixes bugs that I found while
developing and reviewing these changes.

The patches depend on patches recently added to the vfs tree.  I would
prefer these land in that tree too with an Acked-by or similar from NFS
maintainers.

Thanks,
NeilBrown

 [PATCH v2 1/9] nfs: fix open-blocking with d_fsdata
 [PATCH v2 2/9] nfs: fix nfs_call_unlink()
 [PATCH v2 3/9] nfs: remove d_drop()/d_alloc_parallel() from
 [PATCH v2 4/9] nfs: use d_splice_alias() in nfs_link()
 [PATCH v2 5/9] nfs: don't d_drop() before d_splice_alias()
 [PATCH v2 6/9] nfs: don't d_drop() before d_splice_alias() in
 [PATCH v2 7/9] nfs: Use d_alloc_trylock() in nfs_prime_dcache()
 [PATCH v2 8/9] nfs: use d_alloc_trylock() in silly-rename
 [PATCH v2 9/9] nfs: use d_duplicate()
