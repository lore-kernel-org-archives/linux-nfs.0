Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820630;
	b=a1Hsf5c7twM8c1QskfQ2156rjEzDgc5QBpmoSfq07DuNLwbjuGZB8pmHNS9SUqtkgu+4
	 IFpeaWijY6rrQNySFcoTLiDiurOute0i8Wg1vDPSsOP+cUiNzdFJ1LqPExJEghLCF6lYM
	 r1CxIQWLrF4+7MEkYovHDgQcxRVTSJmzTJ5QqAeEXpQ8GBSHRBPkcGjdx75bCuevs3YfE
	 LiqfPDIA++de0FppZ84oylITksoiapo/Uzj28cHqj6AfSl3lR6pDfS0mXpEHehc5vFjG0
	 i0wcvBGlAz9beOZ4wuIG2WESi6MlStT8uOXyVwCjrnu50Ba/lsebA4ol6rWkfRA00Ww==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820630;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=8PrbyLDFAjoLX2WIUniAe1t4rzdjlrNCOM5s/iYEHW4=;
	b=h5IlA+Evy04XMlLkYH+IAUImm7EG6N5KCGPDJX18RjVa+xrhcmVQaf1SmoALJGMi+wd+
	 R5D5ZxTccp1xEX5jIwQsuEXSEIpS4qdVIFGQ5kqWrRY8c5vl/bF3Ixk9isOsSaGukz/xU
	 NHVj6gQdERsF4vFLHNK+cC772R/gWJD81eFBZNTXbUb+7XyOWjuCCOHFiDtloeKjG7Gw5
	 Xbb+ojHPUP3Fi4Z8Fb94ZpSkV4qg9Gg+dLLgux/AtGo3YGnWCHl1n2CiNZ7adUCQgh4IU
	 otR4NjhPR/rH9CyIGGNoZxSD5tKZDYaCucXKTkrgLBfSmShXrssvUvmee+Q0kcyR2XQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gJgUQqFP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A40F606BA26;
	Wed,  4 Nov 2026 19:30:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=gJgUQqFP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 11E151F000C1;
	Wed,  4 Nov 2026 19:30:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820629;
	bh=8PrbyLDFAjoLX2WIUniAe1t4rzdjlrNCOM5s/iYEHW4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gJgUQqFPUdfHqbzO0yydZhimAxOsTiy3j7Gg5403vTetiLd8TkhBazxxcEfGmzx5W
	 rVciL31qjq1dJ+7plUgL+tdmo2E2SJQ7PTYtqCx2yA5ZQXmFwpTZ/BfdBiLoaoCUxG
	 lL06dxOJ7GUHhT6w/GTxKhllfZZxjGQKGJLvM2FgsjQySeffSyuwGPa5N1ogUjy23k
	 pyZhFAReGbPqZK/rsbfRogg889zRCaP4JZXtWySOnvmSw9BhOsw3KUl59GOvqooX4d
	 kXIZOW4f1sN3bBLyMvSBrt7Ky8oqzKQD4BdDN9Z0S+Gea/SE9ghcz9qcFKMYoNacQt
	 L85SUfBFwN3lg==
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
Subject: [PATCH RESEND v2 04/23] proc: wait for the last user of an entry with wait_var_event()
Date: Wed,  4 Nov 2026 20:30:15 +0100
Message-ID: <20261104-work-procfs-core-v2-4-76ace653a773@kernel.org>
In-Reply-To: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
References: <20261104-work-procfs-core-v2-0-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=2591; i=brauner@kernel.org; h=from:subject:message-id; bh=fMKtT8cQ8gIJJgjvKUq4bmwIClHWmBxP0YQIj81mIGk=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bi+tjeLVK3NRu/3AwmDiBg69+Yv9Pl1qUCpOO/S4p eB88dITHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABPp+s7wP+3hike1RRfnnrx8 7ZbO37kO/mV/VGsDH0zbcnLeweWXS50Z/ucLe5/PfHaXt52J1YN/QouDsniPCP+rzsMti01ecAp LcAIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_entry_rundown() waits for the last user of an entry with a
completion on its stack that it points the entry at while it waits.
That's a pointer in every struct proc_dir_entry for something that
happens once in the life of an entry, if at all.

Wait on the count itself with wait_var_event() instead and let
unuse_pde() wake the waiter with wake_up_var() when the count hits the
bias. The waiters sleep on the hashed wait queues behind that, so
procfs doesn't need a wait queue of its own for this, neither in the
entry nor a global one. kernfs keeps one per root for the same thing,
deactivate_waitq. Note that atomic_dec_return() is fully ordered, so
the count is visible before wake_up_var() looks for waiters.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/inode.c    | 7 +++----
 fs/proc/internal.h | 1 -
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index 66a3688757dd..8795add1898d 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -25,6 +25,7 @@
 #include <linux/slab.h>
 #include <linux/mount.h>
 #include <linux/bug.h>
+#include <linux/wait_bit.h>
 
 #include "internal.h"
 
@@ -203,7 +204,7 @@ static inline int use_pde(struct proc_dir_entry *pde)
 static void unuse_pde(struct proc_dir_entry *pde)
 {
 	if (unlikely(atomic_dec_return(&pde->in_use) == BIAS))
-		complete(pde->pde_unload_completion);
+		wake_up_var(&pde->in_use);
 }
 
 /* Pin an entry that can go away around a call into it, see use_pde(). */
@@ -266,11 +267,9 @@ static void close_pdeo(struct proc_dir_entry *pde, struct pde_opener *pdeo)
 
 void proc_entry_rundown(struct proc_dir_entry *de)
 {
-	DECLARE_COMPLETION_ONSTACK(c);
 	/* Wait until all existing callers into module are done. */
-	de->pde_unload_completion = &c;
 	if (atomic_add_return(BIAS, &de->in_use) != BIAS)
-		wait_for_completion(&c);
+		wait_var_event(&de->in_use, atomic_read(&de->in_use) == BIAS);
 
 	/* ->pde_openers list can't grow from now on. */
 
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 6b61d09ac5e5..ab4d7bd1fb75 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -38,7 +38,6 @@ struct proc_dir_entry {
 	struct list_head pde_openers;	/* who did ->open, but not ->release */
 	/* protects ->pde_openers and all struct pde_opener instances */
 	spinlock_t pde_unload_lock;
-	struct completion *pde_unload_completion;
 	const struct inode_operations *proc_iops;
 	union {
 		const struct proc_ops *proc_ops;

-- 
2.53.0

