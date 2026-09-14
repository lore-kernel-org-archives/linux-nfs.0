Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D74CA47606D;
	Mon, 14 Sep 2026 13:53:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789394019; cv=none; b=FFEX628M0ouo5tDzldg1b/tchSQnnUK38hgaVeAN/fiWWekNwpLdnYTXoT29aeMB4wGL2P/lWrc/c2jcr5FdGJGgHySWwt2hDjySncqbtqlLGLXn4oSfS62hiUh7ACEPcaVfGAIdyU652VXtv3Q5nUhJQVVv6cl0xPDNyTf/qkI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789394019; c=relaxed/simple;
	bh=zbPxyxy2b9yZbB01NvBErM59t21lMTAqf8Yh7Nfwtt8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=fyBd2/TS5AYf1p9oe3iUERRPC0ox/dzsDPqqO0I6HFPhhNwxrecc3LxlsQuqK8JSALVMGnxZqXYTQxlPDPadQBlywZBqILx20nkgn4dzGIZeFzC4zhLFO1JegmE1EtiCtqpxnd5nFfDj+ilUJBaAVI0OunbTBUSmZ/yWf61NKNc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OvArNlHe; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OvArNlHe"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D63AB1F000FF;
	Mon, 14 Sep 2026 13:53:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789394017;
	bh=wu65N1dXA+OvvO8uZvoNd+pErDlIjde4zdJjCR1HSl4=;
	h=From:To:Cc:Subject:Date;
	b=OvArNlHeDSOVRhhZRGrCBpdMzl8jo9dd9AdXyAQyNGIoEMbAU2fj6wgMMKz8QD0Z+
	 7zc45KW3ZavyOYj9hFA67nREunG+7ZZBMG6wC/fxqljl7yArjmLTDbo4ZGhPcKNTqB
	 durLGT11dbmp2+EtxyhM22nMU6eH0XsnJF8ZWqWUx5Mr9eDtypGPeoRpYDSDMBp4TF
	 IrM2w5+TegvI1buK8LNNPOtV/sISBhrI52K/v8NhwGSPVvCxxa+E/bbhxhyUW8q7Ba
	 IttHKvH8UfRxMOEfZ+p+s/rPF6pWXEfEsmXh0uJfYcN76+SxEPJcuYIllB1NCxLvMD
	 Y4sLjSiSPyuew==
From: Chuck Lever <cel@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: <linux-kernel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [GIT PULL] Fixes for NFSD in v7.3-rc
Date: Mon, 14 Sep 2026 09:53:36 -0400
Message-ID: <20260914135336.350043-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The following changes since commit 46db3c8a1be96a354758b44b1d4fbb4b70d09a20:

  nfsd: export NFSv4 callback op stats via netlink (2026-08-10 09:54:35 -0400)

are available in the Git repository at:

  https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git tags/nfsd-7.3-1

for you to fetch changes up to f76017a7663c4ce5e379f8a8d39f032bdb1fd865:

  nfsd: fix handling of NFSEXP_PNFS in the netlink codepath (2026-09-04 13:14:44 -0400)

----------------------------------------------------------------
nfsd-7.3 fixes:

Issues reported with v7.3-rc:
- Fix handling of NFSEXP_PNFS in the netlink codepath

----------------------------------------------------------------
Jeff Layton (1):
      nfsd: fix handling of NFSEXP_PNFS in the netlink codepath

 fs/nfsd/export.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)
