Received: from mxout5.mail.janestreet.com (mxout5.mail.janestreet.com [64.215.233.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 604C73DCDA7
	for <linux-nfs@vger.kernel.org>; Mon,  6 Jul 2026 21:34:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=64.215.233.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783373684; cv=none; b=YCNXryLtaqvAUZECrfmz2IdRh4QwuNcxTFh4tFvhsvPADWbqV86GQQ+/RPqi4cdsmtOXRhP/fevBundykxW5GGXxpxVwpMw9iN8nCHIt/azSyZDNnVehvhKJfVDhQ4cT5PSib5pvJIYD03FwTJqhopRZ8JfBlaJnmo6u6is9yk8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783373684; c=relaxed/simple;
	bh=ku/tCkJmgHTK/gVPKoZiukqbluLKMPYDczFXjMrlI34=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=FkRTEmh9cR3qUd0Kii3opY1gFTWZZ6m4xRDKugecy6hinqvgUNOGYpFqdBTHKcF8xY50Ixk6UHdhqj6BZXrtvQZgQ0WH9yi8aKGJ8x2LTWmo9ELk3qjmRO/tf65PQiKWIGZx9VnAsoDLC1glKUV7zAtt7DPricnbOVMlIC6tuzA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=janestreet.com; spf=pass smtp.mailfrom=janestreet.com; dkim=pass (2048-bit key) header.d=janestreet.com header.i=@janestreet.com header.b=m9egatQ7; arc=none smtp.client-ip=64.215.233.18
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=janestreet.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=janestreet.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=janestreet.com header.i=@janestreet.com header.b="m9egatQ7"
From: Tian Lan <tilan@janestreet.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>,
 	Anna Schumaker <anna@kernel.org>
Subject: nfs: opening a file with O_WRONLY|O_CREAT flags can result in permission denied error
Date: Mon,  6 Jul 2026 17:34:22 -0400
Message-ID: <20260706213435.659381-1-tilan@janestreet.com>
X-Mailer: git-send-email 2.43.7
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=janestreet.com;
  s=waixah; t=1783373676;
  bh=+IwGXdTBTPPtTq1VN+XfB3huDHiso0Tjv3DZ/Igins0=;
  h=From:To:Cc:Subject:Date;
  b=m9egatQ7vFBZQZqEd5+HAWshNe4tAil6PhI0Lvr0CsxNAYelmyPIfWks7WgVxbVTY
  MQUKCBbEJw9FXz16Oi7K4KJJeVeYrF1Z7TbOZwyGyU8XsLCyyEZ6WckHWHn70iraN1
  Np78xRkgjSrRziOZaB9HJKZ07YBE/jf+zHfWefUoDI4cZgpOvv/hDRwzegXcJ6nqPI
  Ztj54weH5dy1tgdRYXEpWTjw0ENR0eaRtIciIUFIJN2bvlXTKI0siqKZkEQKWNbbKb
  LSzAXGee51TSqZGim3ezsU3CX5Vlp7h4YXmyyKvu7qbQ2CvaGrMCaR2joBXAw246Mk
  H29+uB0jlo6eg==

Hello,

We recently noticed there is a behavior change w.r.t opening a file 
with the O_WRONLY|O_CREAT flags over the NFSv3 protocol after upgrading
the kernel from 6.1 LTS to 6.12 LTS. From the packets capturing, it seems
like the kernel would now issue an additional CREATE rpc call to the
remote NFS server regardless if the target file pre-exists or not.
The CREATE rpc request could return an EACCES error if the client only has 
the write permission to the pre-existing file but no write permission on 
the directory containing the pre-existing file. This causes the openat 
syscall to fail with permission denied error which is not expected.

After doing some code tracing, it seems like the new behavior was
introduced as part of 7c6c5249f061 ("NFS: add atomic_open for NFSv3 to
handle O_TRUNC correctly."). We would like to confirm if the current 
behavior that we are observing with the 6.12 kernel is expected given 
that the new behavior breaks existing user's application code. We 
currently have a workaround by explicitly remove the O_CREAT flag when 
opening a pre-existing file for write, but would still prefer not have
to apply this workaround when upgrading to the newer kernel.


Best,
Tian
