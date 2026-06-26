Received: from smtp-o-1.desy.de (smtp-o-1.desy.de [131.169.56.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E256B3E1694
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2026 12:52:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=131.169.56.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782478352; cv=none; b=MNrweVgVqbX0qisipVSULVEUOrbMvUwWsS++l9thzaJoidDGfnpCXh7wHs9rOmIV10yXImSsgzyXPsMz2Y2eEK3lLpC6PM+oOUlxSIV/N88ib3BjR+z+pNR4qa+hbAvH4djT6IGR5iHhl+AcJScfzYm7UZCjT63w/ilAoLF6LII=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782478352; c=relaxed/simple;
	bh=60QbsJQvLJzwYFuBuToSJ5vxfjs10InjLc4GNdz4u+Q=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=YLKAcCmj5EG6QBPhJrus+GXycjHwPudQ79TBYN+85fBqYAZ6qp0KgoEbG2M+96u7fsmZC6kkrjsCg8Qzf99Wlreob33BxE5kLcU89SzT9D4Fqfd3TvdFN40vzzL+nP03Hydokp4MqtdCn0ZSuzkd2TCBd+WJEnKznOmwbDoWI4M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de; spf=pass smtp.mailfrom=desy.de; dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b=uBzCQPIB; arc=none smtp.client-ip=131.169.56.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=desy.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=desy.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="uBzCQPIB"
Received: from smtp-buf-1.desy.de (smtp-buf-1.desy.de [131.169.56.164])
	by smtp-o-1.desy.de (Postfix) with ESMTP id 92DC511F746
	for <linux-nfs@vger.kernel.org>; Fri, 26 Jun 2026 14:52:22 +0200 (CEST)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-1.desy.de 92DC511F746
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
	t=1782478342; bh=yAhYqrjcG665zrHIFaGSXI4yPE1X4v00SwCCl338Xpw=;
	h=From:To:Cc:Subject:Date:From;
	b=uBzCQPIBc+zJHwQsIdj2LX8ZF+OEShcBcs5rCIfDLLgACZLDQot9TW5Eh1G/0iyPq
	 rOB4T3JyLRs7RR6R9tgObECwMA18HHYvX/WNq8I4QVg2vmo7KhRL3oQI7PbISM3sj4
	 IJsrOCrOFXXjMnXiudRbgYeIiCxTXDpZWn3igYR4=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [131.169.56.130])
	by smtp-buf-1.desy.de (Postfix) with ESMTP id 8578D20056;
	Fri, 26 Jun 2026 14:52:22 +0200 (CEST)
Received: from b1722.mx.srv.dfn.de (b1722.mx.srv.dfn.de [IPv6:2001:638:d:c302:acdc:1979:2:e7])
	by smtp-m-2.desy.de (Postfix) with ESMTP id 790DB160043;
	Fri, 26 Jun 2026 14:52:22 +0200 (CEST)
Received: from smtp-intra-2.desy.de (smtp-intra-2.desy.de [IPv6:2001:638:700:1038::1:53])
	by b1722.mx.srv.dfn.de (Postfix) with ESMTP id 03C3C160059;
	Fri, 26 Jun 2026 14:52:21 +0200 (CEST)
Received: from z-prx-3.desy.de (z-prx-3.desy.de [131.169.10.30])
	by smtp-intra-2.desy.de (Postfix) with ESMTP id DF06C20044;
	Fri, 26 Jun 2026 14:52:20 +0200 (CEST)
Received: from localhost (localhost [IPv6:::1])
	by z-prx-3.desy.de (Postfix) with ESMTP id D095014052E;
	Fri, 26 Jun 2026 14:52:20 +0200 (CEST)
Received: from z-prx-3.desy.de ([IPv6:::1])
 by localhost (z-prx-3.desy.de [IPv6:::1]) (amavis, port 10026) with ESMTP
 id eRWnWSk9PfSw; Fri, 26 Jun 2026 14:52:20 +0200 (CEST)
Received: from nairi.fritz.box (unknown [IPv6:2001:638:700:e064::1b])
	by z-prx-3.desy.de (Postfix) with ESMTPSA id C12D3140478;
	Fri, 26 Jun 2026 14:52:18 +0200 (CEST)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: trondmy@kernel.org,
	chuck.lever@oracle.com,
	jlayton@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 0/1] inject process namespace into machinename field
Date: Fri, 26 Jun 2026 14:52:15 +0200
Message-ID: <20260626125216.1467845-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This path don't intended to land into the kernel, but more trigger a
discussion and collect some ideas.

On large shared machines often multiple jobs of a same user run in
parallel. For debugging, it's usually impossible to identify requests
coming from different processes.

The batch systems like HTCondor or SLURM start every job in it's own
namespace, thus passing namespace info to the server will help by
debugging.


Tigran Mkrtchyan (1):
  [RFC] sunrpc: inject process namespace into machinename field

 net/sunrpc/auth_unix.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

-- 
2.54.0

