Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D6F2363C6A
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 20:43:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789159422; cv=none; b=CfeeSrv/Q6dOjN049choKxjzCD3S3XBj/rkgY7SYvnoB9v1ZK/TWjrjAEb1lPXPuBlC3J+GB0zgtS7HdNFit4MHMVOBiNsIY75dt4KkmErCe4BnlcadNsTkVkLvbsVEAnF7ktV6uUyUCcMkSpZAnIg6L9YJAJBCwM0avmZwI9mM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789159422; c=relaxed/simple;
	bh=0QVIwTFNLwMHwDXHPYfG547vB9c4pc3jxBBdB0yNXaA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=hDTK0ev2nvGMvYvCPicIeib6ULmMPh1yKXP0a02Ivu6Z6Jl6dmpvqYMuE6t66ehjvH7Zg/u6CNP8tYX4wi5hlFldj8akREIOPZIlH6wBOKCsaRg22PwjZae+D4REs3i/Xi/QDrsxwKBoK0lZx2j2wHmdMAp49dogotUc86XA0/k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=m97MH+kO; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="m97MH+kO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2E37B1F000FF;
	Fri, 11 Sep 2026 20:43:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789159420;
	bh=LrhGUuIkKacZxKKfCqFsOoB+UhCfSQBVouk2H1SMDsk=;
	h=From:To:Cc:Subject:Date;
	b=m97MH+kOIs1Le8b3MAuvtJ4SuBCwR+L9H1+3w5M/aEW7ZnmrrOTDXATVqgH4bjSTw
	 SuSwKiwdOPi0l27PbvzKBMvB6TVuKtfJ8oFnwi4qfeKZiNZAkntovLyENJhCHmhaCt
	 I58GC3alhqk4leeNAPRk5uZGvDLuvc7spPUqWJy0NLCDqNXbFJWlIt9uk9TBy6YwFG
	 spUFryJaG577bltBf1/7JHJy9fQbIV50sew3md+F9xKqjr6PnCm8Ub4BPeep2l5MBU
	 ViEFe5JCPlVxardxggQ80AoAXlAWq5q1POzXDbNsUjsaKyR7a0iSu+/3JfDVKBpkg1
	 DLB5vzrflgZkg==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v3 0/4] NFS: Add client side support for CB_NOTIFY
Date: Fri, 11 Sep 2026 16:43:35 -0400
Message-ID: <20260911204339.1183500-1-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@hammerspace.com>

These patches add support for the CB_NOTIFY callback operation from NFS
servers. Editing directory order or placement in our caches isn't easy
or practical the way things are structured now. Instead, I use CB_NOTIFY
as an indication that the client needs to refresh its view of the
directory.

Changed in v3:
 * Change NOTIFY4_REMOVE to create a negative dentry

Changes in v2:
 * Fix signed / unsigned type mixups
 * Don't try to share lookup code between NOTIFY4_REMOVE and NOTIFY4_ADD
 * Add handling for the NOTIFY4_ADD 'na_have_old_entry' case

Thoughts?
Anna



*** SUBJECT HERE ***

*** BLURB HERE ***

Anna Schumaker (4):
  NFS: Add an outline for the CB_NOTIFY operation
  NFS: Add support for CB_NOTIFY4_REMOVE_ENTRY
  NFS: Add support for CB_NOTIFY4_ADD_ENTRY
  NFS: Add support for CB_NOTIFY4_RENAME_ENTRY

 fs/nfs/callback.h      |  51 ++++++++++++
 fs/nfs/callback_proc.c | 147 ++++++++++++++++++++++++++++++++++
 fs/nfs/callback_xdr.c  | 175 ++++++++++++++++++++++++++++++++++++++++-
 fs/nfs/nfs4_fs.h       |   2 +
 fs/nfs/nfs4xdr.c       |  33 +++++++-
 include/linux/nfs4.h   |   6 ++
 6 files changed, 409 insertions(+), 5 deletions(-)

-- 
2.55.0

