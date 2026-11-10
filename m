Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302411;
	b=gRhd+L/0kpcOtABgnt2TM6dP8AhGqQt+NmKwlnYcfG0BG+UrJK6c2Szsiklfl8e5cEE+
	 FlFC2bM9amI5z5OxNBtnCx0xnObJPS8JUJHdafdqMR1gj8YPNu8pq8a2HPrQ0HanQDYC3
	 yFJQMDUD4SrVlza8y9q0u9y9aJGI6EU9hitvxtm+jCWI0/eWjuukVhT62AlsKuPhTkPNA
	 dbyqVT4BnHJygq05KBWHkz2FjG0fpO5NIX5KAuadlzmlQ8dmss3rs/BQyiAzxWcoLZ6j/
	 zLCd+iriti4i59EPgAxN5kjZZkwzaO9J0KZQ/GsEb1sFtZuOb1pdezlsopCiDYbQ2TQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302411;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=wvcrRKkVitwBIHc8bsc86Ap1TkghVmPhKT6D7YPBbwY=;
	b=micBf6BzPCTfrdTIuI5m5QfLqV2O7AkAdg5WO2sSBZTTqyYKuoUxb1uEJHyGbXX3vzql
	 K3YgEFs1Dq25y/qAkMtggPxy+RhOodLntj2SuVQOVNDsUccUvCJ78F877TsRDpq5Y46Ev
	 wBCsmQ8ZJ0KO2JMg/s6HMWSMSLPS6s8s1xfLbv6EKWFTI1QSuG6wzO9wfYiXsS+GBDP91
	 WeiC/Hsf+0Z4WmYgE2B/uVDEjTSsNCjD20ucH3+1DhlovXQDVjB3bFT91WMCdqYqM1OF9
	 VwW88kS2UIKa/LA0fueHlIs+nTLnFhsWNJLk2parNT8bZKY2wTmNc49TnBEsvAitcWQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lugfFYds;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F1D6607C095;
	Tue, 10 Nov 2026 09:20:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lugfFYds
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 61E501F008A1;
	Tue, 10 Nov 2026 09:20:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302410;
	bh=wvcrRKkVitwBIHc8bsc86Ap1TkghVmPhKT6D7YPBbwY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lugfFYdsp+5acpRZ62DrLNSRpPTqwD6ALObkR4htZDZ7jJ4CwxnL+J31LlzQBLdHg
	 S3Q6wKQ8rLKVDvOjaO/7i9LdpOAAGQkJVKTTZnDkbfMZ0mXM3yVItsw5AH/x4JgMCS
	 r17kh6jTusP0FcEnEBzFzqzJtQ746vPtMKO+E1iLTHLZ7PgzOBIB9SrMppxD4aMf6g
	 ++c6vcWP0wgZ4rHVjr+6Av5KOdeAceVogEGD1LonYdJsm5MlecXYdFkPg3OEFOR0DA
	 l4vCIncvJpwPXykOZGsC4m66wbdnnjiMUoL8mSoluVAzhYGK1Oc9EGsTAAgpOcHIVj
	 fpmwuommLUy7A==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:53 +0100
Subject: [PATCH RFC 37/41] target: fileio: refuse files on pseudo
 filesystems as backing files
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
Message-Id: <20261110-work-loop-pseudo-v1-37-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
In-Reply-To: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=995; i=brauner@kernel.org;
 h=from:subject:message-id; bh=BDYGZBkzpJOf0luK2Iqx3jSxHLpIeW6e4aOnDtryI1I=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDf6mtMEqNwmyJbTeSGX/PXP05KecQy9ejD6kOb9
 /3cf9Hkd0cpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBETl9m+F99+X7Ky605zSv7
 GErvWk1zaPix/Pxk04Q9+p1/0oTy/pgx/JXbprm34uPtr4v2Ll0y0cL+SOu1/dVOakafmv0qqj/
 fj+YCAA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

fd_dev_name can name any file including files on procfs or sysfs. The
initiator then gets to read and write kernel interfaces through the LUN
with kernel credentials. Refuse files on pseudo filesystems just like
loop does.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/target/target_core_file.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index a5391e57e9aa..7a3cf63dc979 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -152,6 +152,13 @@ static int fd_configure_device(struct se_device *dev)
 		goto fail;
 	}
 
+	if (file_is_pseudo(file)) {
+		pr_err("FILEIO: %s is on a pseudo filesystem\n",
+		       fd_dev->fd_dev_name);
+		ret = -EINVAL;
+		goto fail;
+	}
+
 	/*
 	 * If using a block backend with this struct file, we extract
 	 * fd_dev->fd_[block,dev]_size from struct block_device.

-- 
2.53.0

