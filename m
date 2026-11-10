Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302425;
	b=XJv75ARIlNdgk0M2nJtnvqtYw6+h/2qRS/vV9B8PcHqO5ob0eRfIgFjcHdOJ40pi6Sgu
	 su7oYsRP8cTwaSO/ZvVraJYrMQWSYsqqDtaPXJ4t5daL+PFK7FnBMjI8uLLJLyziO0prl
	 yXzcvXlMH6P1+BtTycVWP4OwtaBGxJ8GxGfj7UXIk8a18q0vkieu95jVZJotkdfsiKVAB
	 hcIRR+U0pbcWhmFNhMoZp5eFyt0F5N0jkGLE8nxuP3wistfmt7Al6KzqT0w2W2DcUmIbK
	 YRejg7HE/u8ir8DtxHobeZMt8yr6wFghlynemb5S2cReRIKv4oPKwQFAsKF+lkdM54g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302425;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=5v6oTkZQz6qlfBhdJSuXnvnO8rYqx/rzC+7+Nl5/OGM=;
	b=iD08AoSh0gQECC1jh9zW9fpnu19dtOX9V4wVeEXGCUSP4M4KOU8/4veQC3dVeDheeIsv
	 vEBdcqaTziZBI8BaXFq/IyKsX50H/wqjG7j15sN/joUkwTx9ZmlwQ1gdP+LxmGAgTUJ+Y
	 mwFaQa/jhnfdWmEEnzfAI1gSvqhcUb3yodGApQtex3jSUZsnLgj4D7EL0tWo2PDtNgJaW
	 5sfd2U1dAPtEcqjMVwHrWinI0rMtunSVKFE9TiPv5hQ0KO9dJpRqxcUhqBr6yClLcA2Ah
	 HepyCzCE1vmVOzFAnlljfHj/3qalIOJVJXzgOyUr672hZl+R1ApK2hEei4luKhKMGWQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eIJ0bZ6Y;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1124D606DABA;
	Tue, 10 Nov 2026 09:20:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eIJ0bZ6Y
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 515E81F0089F;
	Tue, 10 Nov 2026 09:20:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302424;
	bh=5v6oTkZQz6qlfBhdJSuXnvnO8rYqx/rzC+7+Nl5/OGM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eIJ0bZ6YykzyfYaq0uQnsLuPNj+m0vg4MOIRUUV7WyIHrzOWlMn5BpzKyvQO1xQnK
	 lIgHxLYXr0xM6gXAPduca8fCpGnrbXmRu3n7sX++lmrPokRdnMxOQCvAaieuNDey1/
	 rDMY2lnbcyTg88AQ5EnW+l0uOlH6KcCfGavMFZPvkrzrCwVDMo4o1H9usL4RbMeid9
	 8ju7v6AtrNpyzqVV8uy5DYhL2Vr+eLE/ymRsWc8pcaS97R4A8Z95dfIgLeSJCXVpWi
	 mDeT0clD8WfcFmQfLKdl3Rcurbo/W+eyqIPzNmzhefzjE4bnqF8y5kxjx80v9c4Gko
	 v/as+SN9c7AFA==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:55 +0100
Subject: [PATCH RFC 39/41] usb: gadget: f_mass_storage: refuse files on
 pseudo filesystems
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
Message-Id: <20261110-work-loop-pseudo-v1-39-4c998976c6c7@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1124; i=brauner@kernel.org;
 h=from:subject:message-id; bh=5CZmEVUvUM8phb7GCUC0PbdIONUtutPPh5jN88b8MUg=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9enDwpOymfbk/lix9c8OUO8H7nMDJjqNuYfXt8RN5b
 SZ7VM/p6yhlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZhIsgXDP81qmQUMxt7JIhtj
 H769H+D76yOfp7vrv8Uv+XNqFL+3cjL8szGK7szT6zNcPi0pgC3zv/C19XHNGld3L/vwMHyKxLW
 bjAA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

fsg_lun_open() takes any regular file as the backing file of a LUN. The
file-storage kthread then reads and writes it with kernel_read() and
kernel_write() on behalf of the USB host. With a procfs or sysfs file
behind a LUN the host gets to read and write kernel interfaces with
kernel credentials. Refuse files on pseudo filesystems just like loop
does.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/usb/gadget/function/storage_common.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/usb/gadget/function/storage_common.c b/drivers/usb/gadget/function/storage_common.c
index 75831f2c7abe..83683ade20c2 100644
--- a/drivers/usb/gadget/function/storage_common.c
+++ b/drivers/usb/gadget/function/storage_common.c
@@ -211,6 +211,11 @@ int fsg_lun_open(struct fsg_lun *curlun, const char *filename)
 		goto out;
 	}
 
+	if (file_is_pseudo(filp)) {
+		LINFO(curlun, "file on a pseudo filesystem: %s\n", filename);
+		goto out;
+	}
+
 	/*
 	 * If we can't read the file, it's no good.
 	 * If we can't write the file, use it read-only.

-- 
2.53.0

