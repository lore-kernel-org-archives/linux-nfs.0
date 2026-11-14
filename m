Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794661781;
	b=BFDOwXz0XNT6LdhaJosI93qbcR3aHjOYZNUg+DqrJvrz7XM+WfG5tVMPq8AxX8wi4RGR
	 e7u4lhAcqcD6vqTfD9AHWUCicSxv4eWD3xPCl/onE+fuzT+OK2xaXn8n5WmPU70cUhZ7z
	 0mqohWyjIQPVAWiJxcyzARC+8zeh/dWuY/9eXysx3MEX45DtBPGIwOmpva7FXyu+Vm3F+
	 wlehTm/bZSR5Z9CYgrBjsttqdaPRZomLACDVeaX8DGoE5ZpMed1JzVGQBnEMxBhCrX9MB
	 QLyoW1spymXoRmaKKt0SdgglgCPcMa04YvGbvWWHxSYLiKCI8gjUtc7Nx5EPqLqz4Jw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794661781;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=NDK6iLGoU71raS2SgqQLHOQWV8qCulebQnSVWkxP4N8=;
	b=MzK2Bpzv1Us8EhqSa75xcR6OvgrAYuZl/1ygBla/nBzXK5ORGCYbpy69Lnea7LrlRsjh
	 SMtPjoO0+Xwb5I+/znZ0XflLAUNf25oonlZHCkwCBfw8mp5J00dDSeW+CdkRRE96OHUZ9
	 GduD1aS9kflj8VfkNuY8wo9Knl4uX+myyalqjTiTBYSVW0qNcHuI770U7wUDNkscTH2x1
	 hhYqiExsCRD20o2zoO95Wv6mX4xH6esA7UH2aAJ+XDUJQ9zR+W55nE/5ePVHfCrxb1B1Q
	 /xA1/8zAlHLI0RNmGWGSHNc7aWhr/i5h4XOvWcd5WSrKrcfcbspGmGpYRxtUzb2Xb8Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hoFWaj8p;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63D2260A260B;
	Sat, 14 Nov 2026 13:09:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hoFWaj8p
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3A26C1F000C5;
	Sat, 14 Nov 2026 13:09:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794661781;
	bh=NDK6iLGoU71raS2SgqQLHOQWV8qCulebQnSVWkxP4N8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=hoFWaj8pvuO5W4IMFMMHBQHXMNLjNH8JHfJrDEmFAYaD9asZ5QMfu4dOUECaNFmWb
	 f5k0eyP7Kyys7O1qt1H853aLKDmH4CIdCdqekph1EhrZbDKl0mxNkgwIVT9HDOt3XC
	 O3bGQDa7op33lAEoqksi8s58BT8ulOMAO60OcbJMkq0yL+u5csuTYRPB7smWs86ksl
	 ospRai6EuGNd+GhCYkKlfBdmljxPJpsYewArnoRX5o2L7xJTjyoZG5c+NVbvTvPVPv
	 JUbdkCHF4KynQMxadnOeQj/61m6YmnVQxmfl/9pKanW0zQl5nFhfpaBX+TBYt4fp5N
	 X2KWpck2qoGkQ==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 14:02:16 +0100
Subject: [PATCH RFC v2 35/42] zloop: refuse zone files on pseudo
 filesystems
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261114-work-loop-pseudo-v2-35-98639a2286fb@kernel.org>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
In-Reply-To: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1408; i=brauner@kernel.org;
 h=from:subject:message-id; bh=FWktvag3hP7CxJ2aHsFycQWntpQ2NlX5K0UkpLEDOgs=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9iOmTbNEV636a62R6kHG9SdDEX8xMuUodXbnngjbwb
 l/iW72lo5SFQYyLQVZMkcWh3SRcbjlPxWajTA2YOaxMIEMYuDgFYCJWJgz/E+5wxiw8Ms/ho0RZ
 slhBp+vsmI/Z9zf941dJmu0vfvbnSoa/svdmna/i63v7pKntle3q1EqNfZxyTU7nC55fEOXNvXy
 KEQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

zloop opens its zone files by name below the base directory but a bind
mount can put any file there, including a procfs or sysfs file. Refuse
files on pseudo filesystems as zone files just like loop does by
switching to file_check_backing().

Note that the helper only accepts regular files. So far zloop took
anything with ->read_iter() and ->write_iter() as a zone file. That
includes character devices, FIFOs and block devices if someone put them
where zloop expects a zone file. Zone files are created by zloop itself
and zloop truncates them to size and to reset and finish zones which
only works for regular files. So refuse everything else.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/zloop.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/block/zloop.c b/drivers/block/zloop.c
index 65634a39b0bfc..6f79b9ddbbe00 100644
--- a/drivers/block/zloop.c
+++ b/drivers/block/zloop.c
@@ -1132,10 +1132,9 @@ static int zloop_init_zone(struct zloop_device *zlo, struct zloop_options *opts,
 		return PTR_ERR(zone->file);
 	}
 
-	if (!zone->file->f_op->read_iter || !zone->file->f_op->write_iter) {
-		ret = -EINVAL;
+	ret = file_check_backing(zone->file, FMODE_READ | FMODE_WRITE, 0);
+	if (ret)
 		goto out_fput;
-	}
 
 	if (zlo->block_size) {
 		ret = zloop_get_block_size(zlo, zone);

-- 
2.53.0

