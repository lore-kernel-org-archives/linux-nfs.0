Received: from va-1-112.ptr.blmpb.com (va-1-112.ptr.blmpb.com [209.127.230.112])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED92042E007
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2026 13:36:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.127.230.112
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783949815; cv=none; b=ivZMBJbVjDCq75m7kufEwpCyGYjSHgdA7Ha251OtZJ99LQkL7HASsndFOprHrYTp2rXOoPWPMk9DPRyDXS3D/dYdFbBTEhNLoJFyLe2l1ul4LKq+tNcsWkQwCrsFXZ+V5ga5SKvwbkBLJt09+9E14P64Gl8NfSuTfD6Kw/xm+JM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783949815; c=relaxed/simple;
	bh=W4I+tc2wn2F51YLrlBss1qWCPyTe3a4tGfNT0fOdc4M=;
	h=To:From:Message-Id:Content-Type:References:Cc:Subject:Date:
	 Mime-Version:In-Reply-To; b=CvuPOxXXhi62g5dSoKD0M5uMd7ax/FilRpUDRCtQuApskBKycw6RS1j6Fu3URO6MAEuZZENC2TOoVNRbk+UMQAkYZZptZvth+isvoWHTPBdG+CKkiHz0hK3M0YCaY8xV/jgyfqug1d405JyoGElh7s3g1OhU0CllJnOy7qzHcM0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=bytedance.com; spf=pass smtp.mailfrom=bytedance.com; dkim=pass (2048-bit key) header.d=bytedance.com header.i=@bytedance.com header.b=me5m4Z0l; arc=none smtp.client-ip=209.127.230.112
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=bytedance.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bytedance.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bytedance.com header.i=@bytedance.com header.b="me5m4Z0l"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 s=2212171451; d=bytedance.com; t=1783949807; h=from:subject:
 mime-version:from:date:message-id:subject:to:cc:reply-to:content-type:
 mime-version:in-reply-to:message-id;
 bh=mcFWwoR8HJHvqxrrzW8rX6MYuuJtu4ui77uwEmpQcjg=;
 b=me5m4Z0lX8nzxzWzHThb8Mnvs4iUriI3onGAg9/FZyVpXJKEShPtmqT/GiPRSQ4iTRmPch
 inIRNWJVEtB5qp2k9J+SFWkcfbxljh/r0N5Ervg0EjVYs7zGWzLE4H2JA6s+GwHkY3rD5b
 qBtGqzYb7NVFQMOqwTWDP2SEubEMIMUuXQTFFniNV2gv4aznN49z1tgHMJ70v3/WdS2qEO
 OPDuVIUvLEUy/Z6IWAN72IUriScwvNpaIR3I+wI5sTiirZnDMY7dieTzwW25l5DckBdX91
 f4B827qjZejZpJKOzBYepBeR5kv/R0hlDphBIfBwc6/9uMEPNqMRI0BRArTpuA==
To: "Anna Schumaker" <anna@kernel.org>
From: "Jia Zhu" <zhujia.zj@bytedance.com>
Message-Id: <20260713133057.23079-1-zhujia.zj@bytedance.com>
X-Original-From: Jia Zhu <zhujia.zj@bytedance.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
References: <20260710204715.621189-1-anna@kernel.org>
Cc: "Jia Zhu" <zhujia.zj@bytedance.com>, <linux-nfs@vger.kernel.org>
X-Mailer: git-send-email 2.39.5 (Apple Git-154)
X-Lms-Return-Path: <lba+26a54e9ed+7f42e4+vger.kernel.org+zhujia.zj@bytedance.com>
Subject: Re: [PATCH 1/2] NFS: Pin the 'struct nfs_server' during a FREE_STATEID call
Date: Mon, 13 Jul 2026 21:36:41 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
In-Reply-To: <20260710204715.621189-1-anna@kernel.org>

Hi Anna,

On Fri, Jul 10, 2026 at 08:47:14PM +0000, Anna Schumaker wrote:
> Dan Aloni reports that he was able to hit a use-after-free bug if a
> FREE_STATEID operation gets delayed for whatever reason. Fix this by
> bumping the refcount of the 'struct nfs_server' object for the duration
> of the FREE_STATEID so it doesn't get cleaned up from underneath us
> while operations are still in flight.

This patch reminded me of a similar nfs_server use-after-free that we
recently encountered in production. However, it appears to involve a
different race and root cause:

  NFSv4: pin the superblock for active state owners
  https://lore.kernel.org/all/20260707133623.23078-1-zhujia.zj@bytedance.com/

Would you mind taking a look at it and letting me know if the approach
looks reasonable?

Thanks,
Jia
