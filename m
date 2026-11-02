Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793656341;
	b=X6zUK0KwUtmcyIwvNKeVCADCa/tVndH4AFog1IYMiUcXzlkiz3DMNbwcccCdh1RYn4DN
	 Na+0n1NklXxa7bplUfj8fyty9pyqRynfTD7JMKYa4O6cxpRejxygwyJzwtBtTeewoYWBB
	 zUXvEdwnkQMetkDNBTEdDPi8VZ16QpJXKVlDEoKt2/3AfZcUF/8DeiB7y0pApxUCYmjk1
	 mhxQ7NuIKaYzpIs2la5TXuTaxoscWU00dT8uv96aZfugf3IwbCDNlHj79+FtvLyfmyI6P
	 hdbXGZeaA9P0i86NGLYBUYGEP6ZlcZrBEgfEHaZ/Hqz5nqf1gq+hdHeYVSI2RrSWg8Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793656341;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=k+dyEdy18r2kHry+PX7/SEWe+MrZgl1XINpYhTOIqQc=;
	b=1ip7P8C57r7+9iQoVtMsa6O02tcH3vqPY15Y+tWuf6ir/TCAEHvezVkMR1i69+M0Y/pS
	 Y6YVASxY27R42VQNLEf/JdM0wR0L1O8FdxU4aamzBb3C3anlhfsUJ60nJIQZLlii5f71a
	 tbyyLUWFVbt3/OljARqzh/VYfERwiwpSMKwwVLgBIiONwx56wga+qrOjehI2E5Y+Pw6uF
	 pa5SYLefczt2jvJKQOLcH+mWlPfSqpsq0jcJgFaez0q+Ix2BxP/Kab6FkAQ75+oHEzGwV
	 jnQeQ4x6PdkcnYaBtnvY9dnbpOrqaZaEYqN9QA8mH5nyvA4tyET2A70fXz0rRrL0p6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PIwWQ9Tk;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CA07606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 21:52:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PIwWQ9Tk
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 379AA1F00A16;
	Mon,  2 Nov 2026 21:52:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793656341;
	bh=k+dyEdy18r2kHry+PX7/SEWe+MrZgl1XINpYhTOIqQc=;
	h=From:To:Cc:Subject:Date;
	b=PIwWQ9TkS1WPr4x667txn7CoDrFWdbdXbfbqHO9PPHMDI1w2c2ugXEuBJ/iLGpuNa
	 Df1nj/jdg/7Iye/f+X/nVAiUewtJDY0kjqIzy1sd+WmgltCn4K7616JkcNVx0aZ6Kf
	 rWZuDZ46skytM3HSJQo+UrkKoZ4fDWy99yxUCUT1tkv6YK3YbkvCsSGJj/n680fZbU
	 jHwtJn7MkkyELZ8D0w8MaXansffifR59ArfUrBeOnfeKNFmJyf1USZ5UI3fF50fz2o
	 5yMxZQMz021pFzSbT63kke1oGuZzvB/RAO7PNtYadcUnkkw+7/dRd+Fij5HzAgJF2X
	 D2pZWT4yxnFFA==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] NFS/localio: make the LOCALIO probe safe, repeatable and bounded
Date: Mon,  2 Nov 2026 16:52:17 -0500
Message-ID: <20261102215220.16055-1-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
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

Hi,

Three fixes to the LOCALIO probe.

Patch 1 takes a reference on the client when nfs_local_probe_async()
queues cl_local_probe_work, and drops it once the work has run.  The work
was queued without one, so a client freed with a probe queued (e.g. at
umount after an NFSv3 I/O queued a throttled probe) left the work to run
on freed memory.

Patch 2 probes again when localio_enabled is set back to Y.  A client
that probed while localio_enabled was N was disabled by the probe, and
nothing probed it again, so it stayed on the network.  Setting
localio_enabled to Y now queues a probe for every ready client, in every
network namespace, that does not use LOCALIO.

Patch 3 gives the probe a short soft timeout of its own.  The probe's
NULL ping and UUID_IS_LOCAL used the mount's timeout, so with timeo=600 a
server that does not answer the LOCALIO program held each probe for about
170 s.  The new nfs module parameter localio_timeout (seconds, 10 by
default, at most 600; 0 keeps the mount's timeouts) bounds it: through a
proxy dropping every LOCALIO call the probe gave up after 10.6 s, and
logged nothing.

The series is based on Anna's linux-next (nfs-for-7.4-1).

Thanks,
Mike

Mike Snitzer (3):
  NFS/localio: hold the client across an asynchronous LOCALIO probe
  NFS/localio: probe again for LOCALIO when localio_enabled is set to Y
  NFS/localio: give the LOCALIO probe a short timeout of its own

 Documentation/filesystems/nfs/localio.rst |  12 +++
 fs/nfs/localio.c                          | 118 ++++++++++++++++++++--
 2 files changed, 123 insertions(+), 7 deletions(-)


base-commit: ef30b3efb7e8bae94d790a6503a595e1051323e7
-- 
2.52.0

