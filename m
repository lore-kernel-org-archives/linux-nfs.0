Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814506;
	b=pm4xKwn3QUpfAceciU7WuvGFkI6T/b5qioYsOs6Z223B9sEjK+oObwVoKvaeqMpipkJg
	 6kyAYB1BYoQ0VvexMNRzovyIDbL+O3p3X4dVIs46HBcQ0yzpsyB//AzP7YtQRII0A1FPB
	 Y7+GrTMEGWml6+EMWdCIng28xqAeRKDXTkIcbROu2MMMJL/7kgHes4vySYgqhGtVcyQrf
	 H/I8XojQDd9PiiSVjTdmeJlf8y/rpZQKlaK15H/CzINn22HcRGqdIgYdY1hUJLwkJWdKX
	 jYMtTQLoLXu55/kC3LubFA3I6hgIipgdlbl/FV+hAmhVsz3Xq+aeCePHtVggvM5wspg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814506;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=3ZyIQLij17XFBIkY/FnNnjbp2RgAs/rkMBTgRuVD6WA=;
	b=jn1mKPcBhY79Jlk/ENvULyjTiunlzZ9P0u9IyXPmLjKakP4q6vyyYSgX2w4gZM9Ry2c+
	 3axsnJyEgIb++k8v5/NOeuyC+xofjtF5b/869Rz73j+ZrG7GKrCGBKIBarvr6m0OnatIG
	 y8MVgFBTNpC46Pfa7stZkpoGlUAdXJ7KMF57aV4iZCnEbf4HL17UGz9plJ1j99SgczAk3
	 watZInjoo5nx5qj02cy/uDRFoZIUmBkurDoK6DxSQZM5CUM7HmWshEocfWYogMcSq/TzE
	 awTScXrbynm7o4QmMq1G7qL1B7hPB2f4teqZHr81e8VOoNg8unV6gNguxBpZlObtryg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jRm+kuQX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D57D606D822;
	Wed,  4 Nov 2026 17:48:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jRm+kuQX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 512051F000C1;
	Wed,  4 Nov 2026 17:48:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814506;
	bh=3ZyIQLij17XFBIkY/FnNnjbp2RgAs/rkMBTgRuVD6WA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=jRm+kuQXLx3HxqJQ/pjoWlYGnOb5R2cVrI0BxZjs1H9Bw8isgylYtekF6fzwCYam0
	 GpULB5lXQbyTK/Edh9b2eC4kps+uu7bCEsyidT0bHm7H2HfmOVOP/JWR98p8XKggDV
	 gbR+sBOa4/o7t63orB3vACnwFADp+bNRfAOdtU2Yc/wWPiuGQBbek9DZxI+EgwmNgG
	 KWLc3uoF26LdC4oCj9qcMJD06sucvBwbhfn2X8BjLVTXyfWCytbRIvS8esUEF/ocEj
	 eFEobff+fM/wQhcYScZQ5sJRBVHN2AlsYRDXbqaRDoezJ+0bPS0RQxOsMA9AvIN8D2
	 a7u52gum9t5KQ==
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
	Chuck Lever <cel@kernel.org>,
	stable@vger.kernel.org
Subject: [PATCH v2 14/51] proc: sysctl: don't stop readdir at an entry that is being unregistered
Date: Wed,  4 Nov 2026 18:47:00 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-14-bbf7d5546809@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1722; i=brauner@kernel.org; h=from:subject:message-id; bh=6hLGzd3ohIjIvoG2NrLKRAR6DerSlran3UFG44ON0F0=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zrvAWu/kaD6x96PK3okTN85e99fjn1Pl3U3bGJtnN F1XMW6+3lHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRfk9GhqVlT3f9k3gTlZE2 2Sl7qnRP89Frq6PEfR/pxi6YuOo16wdGhrWT5lf5PEid/zYw+uqn/MXSBi/y5i736erf2r1Ls/F ABg8A
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

proc_sys_fill_cache() creates the inode of an entry that has no dentry
yet. Since ace0c791e6c3 ("proc/sysctl: Don't grab i_lock under
sysctl_lock.") proc_sys_make_inode() refuses to do that once the table
is being unregistered and fails with -ENOENT. readdir takes every table
it lists into use and unregister_sysctl_table() marks the table as
being unregistered before it waits for readdir to let go of it. So an
entry that is unregistered right then makes proc_sys_fill_cache() fail,
proc_sys_readdir() stops there and returns 0. If that getdents64() call
hadn't emitted anything before that entry userspace sees the end of the
directory and never gets the entries behind it. A listing of
/proc/sys/net/ipv6/conf can end early that way while a device goes
away.

So skip an entry whose table is being unregistered, like readdir
already skips a link it can't follow. Lookup treats such an entry as
gone too since ea5751ccd665 ("proc/sysctl: don't return ENOMEM on
lookup when a table is unregistering").

Fixes: ace0c791e6c3 ("proc/sysctl: Don't grab i_lock under sysctl_lock.")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/proc/proc_sysctl.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index 6c0859c66563..b4a309d49698 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -704,6 +704,9 @@ static bool proc_sys_fill_cache(struct file *file,
 			if (unlikely(res)) {
 				dput(child);
 
+				/* skip an entry whose table is being unregistered */
+				if (res == ERR_PTR(-ENOENT))
+					return true;
 				if (IS_ERR(res))
 					return false;
 

-- 
2.53.0

