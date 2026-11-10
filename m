Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302171;
	b=XBo0ztfDUDzzRBZnGPJTv3mVeNJav+NltBtqFPDKLxUmmkZ2KwQdgr5MEi6HsvKYfhdW
	 Lfep2b/0DDYjQEGynV9y/V50chfu1A/bmJKd6E/q8lQWaOgm49Z0KEHZk/dBIb5mVLjxD
	 MeAEO6dFt/a41Z55JVWcFuiy23xVtJQClq3u1WkFe4Tx54jngpTb2mNwDEb+gwTUdh+/v
	 z4Qmwi2OyFsmUp534LGZ9m/BW2x45ZUN+M/oJynLeLlsfcFVWob0WKVLS6Iuvz36DuNuW
	 iaKsyv2FFHfgGBeEPLjX5kGmg28wlp1c1iWbKj6Vh6FP//wB44mXYRBcSPBe90GjPjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302171;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=48wS641dZNlMgTbgKHYJJRZjCIIpBYSCk6vN7nPVst0=;
	b=DR+dwbHrptfZhTChU9EVE8BOBIF54/7M6fH5dqWSjfGkYUWpK5s/rzjy6iJd74c3+dv2
	 o4VXtAj9jziof5IoWK0n3LgOr7vX7cChgiwkj5osckXe6R/V6sio3GShjTlOcVEsUqHQJ
	 3cA0JYkMkAz+5gsvZK1vcdOH/lk+M8l7esCrhIeA4IxH0PMAvmlHXRTeAq8QHYxJO2bOX
	 wyt61hQQjHWekiCq1D+4CM+yvAucApRPOYRfTzLizJirt+Kcvv51T6xrBTxnY6J0c4AkX
	 551Y42Ab7LDAhwTRGRVmL+ddcV35eWxQOJLz3B8JHh20exlxApu5yIt4Ka8pNwrlaZA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B3k5bbEA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 93CFE606A325;
	Tue, 10 Nov 2026 09:16:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B3k5bbEA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EF7381F0089F;
	Tue, 10 Nov 2026 09:16:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302171;
	bh=48wS641dZNlMgTbgKHYJJRZjCIIpBYSCk6vN7nPVst0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=B3k5bbEAWfpJtZp1vzeXux0KzrY0ieZxwUJi/83P+f7eKHCKBYc9mkYVfNK2b/51Z
	 IE7odp0lQqQ7mwusK6pgB1WlHVkO/UlsckyLpTfE8Yp89sMOk+QjYT1he8sjTHJobl
	 zbSxv5PQZ8XY+Ts/6iaugpn66hCj3rJCosVRpDg0+EuqU7+TpcsCN1TcwITx1L6QCL
	 1C6NNljvCVnJ+dNekIZ/1LCG3UXVW6y81kv+eHD0umTjqyrBp3lV94BaeU5UIyHZKc
	 zDKybfsspnrP1qhiqd+dsnxznVfYXFvZSeoRYSBElTyxocH2QJC3b5d8zXbtpIhziF
	 ygU0pzxGVue5w==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:18 +0100
Subject: [PATCH RFC 02/41] nvmet: check that the file backend supports
 ->{read,write}_iter
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
Message-Id: <20261110-work-loop-pseudo-v1-2-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1206; i=brauner@kernel.org;
 h=from:subject:message-id; bh=9rTO3vQgbbKMLgtf9DhInii/7oHGTrugRkWUh4dwMMs=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9ejBtltmGmxnek3mf9QvZzp8xjWWx5Y+Awzls7lyHP
 /4+2Dk3oqOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAivzwZGU4478oq2RB1Nuut
 48Jj7Tu4n8+545UyJdpwumO4VdS2g7kM/9TW5p9ep3/AsD+mInRXw3I+rR/SC0xnPXVmN7wifGZ
 vBB8A
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The file backend calls ->read_iter() and ->write_iter() of the backing
file directly but never checks that they exist. Everything that isn't a
block device ends up in the file backend. So a namespace pointing to a
file without them calls a NULL pointer on its first I/O. Only
buffered_io=1 gets that far as the O_DIRECT open fails for such files.

Refuse them when the namespace is enabled the same way zloop does since
commit 0c10f8a1a7ae ("zloop: check that the zone backing file support
->{read,write}_iter").

Fixes: d5eff33ee6f8 ("nvmet: add simple file backed ns support")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/nvme/target/io-cmd-file.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/nvme/target/io-cmd-file.c b/drivers/nvme/target/io-cmd-file.c
index 695963dd932e..dfa8aa46188c 100644
--- a/drivers/nvme/target/io-cmd-file.c
+++ b/drivers/nvme/target/io-cmd-file.c
@@ -47,6 +47,11 @@ int nvmet_file_ns_enable(struct nvmet_ns *ns)
 		return ret;
 	}
 
+	if (!ns->file->f_op->read_iter || !ns->file->f_op->write_iter) {
+		ret = -EINVAL;
+		goto err;
+	}
+
 	nvmet_file_ns_revalidate(ns);
 
 	/*

-- 
2.53.0

