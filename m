Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821145;
	b=qvqySqfbcuGxlzSsIT8J/K0LThqknAAKXDPTzf6KcJXT4wl1TVZZQHBJLer7bfXoWf0C
	 6rg77lqVlXdy5OZ6rXv/C6EnVjMS18/79zlc9boI/lDUeEq5DEvQW0QNumX2VsEAxU5WY
	 a3SPq+nOZ0WBsuO9DpymIYS8ajm99MPpzUdYa8F8h9kYVgYH3Zbb4D9/9wgZmAMgN6qyg
	 T5i7Izi4UNQKv4mpmveeWmuYnNN/DSzanPHArov7ERx1ag5qp6M/EvbAmhWp64E/cWrQs
	 ZhwmaK3jcVaOnYTli7ksqd6NDgOJbhVf7j3JNYb8X8HODG8l5HFaMSPSmHunntp93pA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821145;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=2GaZul5nsAkiA2gFzaNhtmiz6cl7FK3FoYt1S3NMwg0=;
	b=dpdq8+VwiiGZkJtoYM07xW2qMQHFmyr00QG2SU0hZ3MbO039xmgEo/x3M7fdjqc1LjQ2
	 L5ywXHyHux9a3vXS/UPipqFELzGfzCG/QEyBqdANSup2ZDST0+QVi8qJBYAj6j0iJZxGN
	 Kbj6Ycf/L2yaEtv8nsxikVP2OVjDOlVnE6QgTn4Q9QXWr+mOq8b+NEYfOXYEIHlKIRav9
	 vzmo7SymvdkgFJz/tOe1DXUnWbDGi+mAI4ILuC5n8nBaJJh3So2BgIga+l5OFmrn4JbDA
	 MKQaDJmvqd2ZWzgj3Ud4Go6IqLMQ3iMTfQRKOvr+ezJh0N0i+WXXYWCMuRDy2c7IAEQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EkijSZeV;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AF74D606D81F;
	Wed,  4 Nov 2026 19:39:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EkijSZeV
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EB9AA1F00919;
	Wed,  4 Nov 2026 19:38:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821144;
	bh=2GaZul5nsAkiA2gFzaNhtmiz6cl7FK3FoYt1S3NMwg0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=EkijSZeVjK/rxqWkFZ0OqjZPZ2MuDjt77EIGi3oeRCPyvddqFu9s+uEMPbZyav6JU
	 wR/usgrscOo+Xc/2BlwsQalbhrpqMfSzzRqIgv3T6yJ6Su3/KnDPj8UujUmSRlInc2
	 OA+qa1pxZU+tpV0mOirJD8BdIgxcL9++M7vpMuIqy3oTTRQjm4+QyaGOZOJJljVRFM
	 978mJ2y34/rrUxqJu2rf6osm9UbeqCNqVT1ww1vX9zJuceB82ZbPSNli3Pn90tp1pC
	 vGmWMHMmL/iqTgm2FqrZJJMi0EDtSQb0qpfJ2D2g7q68SgWPBjHVtue51SAG0k/VAQ
	 m6xHCkuZygl4A==
From: Christian Brauner <brauner@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	Josef Bacik <josef@toxicpanda.com>,
	Chris Mason <mason@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Eric Dumazet <edumazet@kernel.org>,
	Thomas Gleixner <tglx@kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Christoph Hellwig <hch@lst.de>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Joel Granados <joel.granados@kernel.org>,
	Kees Cook <kees@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jan Kara <jack@suse.com>,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-kselftest@vger.kernel.org,
	linux-s390@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	linux-um@lists.infradead.org,
	linux-wireless@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org,
	ntfs3@lists.linux.dev,
	platform-driver-x86@vger.kernel.org,
	coreteam@netfilter.org,
	kexec@lists.infradead.org,
	linux-pci@vger.kernel.org,
	linux-sound@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	ibm-acpi-devel@lists.sourceforge.net,
	jfs-discussion@lists.sourceforge.net,
	linux-alpha@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-hwmon@vger.kernel.org,
	linux-mm@kvack.org,
	linux-sh@vger.kernel.org,
	linux-usb@vger.kernel.org,
	samba-technical@lists.samba.org,
	sparclinux@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	linux-doc@vger.kernel.org,
	linux-serial@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net,
	Takashi Iwai <tiwai@suse.de>,
	linux-input@vger.kernel.org,
	linux-raid@vger.kernel.org,
	linux-ext4@vger.kernel.org,
	linux-modules@vger.kernel.org,
	linux-debuggers@vger.kernel.org,
	"Christian Brauner (Amutable)" <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>
Subject: [PATCH RESEND v2 13/23] x86/mtrr: let procfs own the seq_file of /proc/mtrr
Date: Wed,  4 Nov 2026 20:38:49 +0100
Message-ID: <20261104-work-procfs-arch-v2-13-2aeb952c9597@kernel.org>
In-Reply-To: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
References: <20261104-work-procfs-arch-v2-0-2aeb952c9597@kernel.org>
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
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1271; i=brauner@kernel.org; h=from:subject:message-id; bh=JKCg0Vsec4l/XR03sLy8l8PQ6sAjtJH7fHwWHPLe1EE=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97vjDc7H1uCrz7Lca1inL3TMkhJlv3fnENrvceu2S/ ReZTC3Od5SyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEzk+F6G/2VugSv8pq08ZPfu Tmr9gR2hu+24ZwgWX2kN2zjp1ecfLS8YGa7UCoX+OCF32/XDAz/vezHLIq7fqM/cGxRkcUSq91z LXx4A
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the show function and let procfs open and free the seq_file.
->proc_open() only does the checks now and ->proc_release() only drops
the MTRRs the file added.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/x86/kernel/cpu/mtrr/if.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/arch/x86/kernel/cpu/mtrr/if.c b/arch/x86/kernel/cpu/mtrr/if.c
index 4049235b1bfe..9510e01d5103 100644
--- a/arch/x86/kernel/cpu/mtrr/if.c
+++ b/arch/x86/kernel/cpu/mtrr/if.c
@@ -349,7 +349,7 @@ static int mtrr_close(struct inode *ino, struct file *file)
 		kfree(fcount);
 		FILE_FCOUNT(file) = NULL;
 	}
-	return single_release(ino, file);
+	return 0;
 }
 
 static int mtrr_seq_show(struct seq_file *seq, void *offset)
@@ -391,13 +391,12 @@ static int mtrr_open(struct inode *inode, struct file *file)
 		return -ENXIO;
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
-	return single_open(file, mtrr_seq_show, NULL);
+	return 0;
 }
 
 static const struct proc_ops mtrr_proc_ops = {
+	.proc_show		= mtrr_seq_show,
 	.proc_open		= mtrr_open,
-	.proc_read		= seq_read,
-	.proc_lseek		= seq_lseek,
 	.proc_write		= mtrr_write,
 	.proc_ioctl		= mtrr_ioctl,
 #ifdef CONFIG_COMPAT

-- 
2.53.0

