Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820702;
	b=kxjaxNcezOMRTvu0LCAmDZlqeMz8TLII14Xae5GnPyGlVWJwr//Cx8IKXJvRnTlMUrFE
	 ei5IDS2Pzwe3Ni6PyrQFxLxggW/o8TSrfBphpBkUsXBECRoXAFQ/O0BCo0WqPQKuqj+rU
	 3oqE9Dl+OiScFJxLMYUykxjeEUUZech9hrdST+LHr69UGsLB1ynyIj+YsdBoc+rlM3JXg
	 AWxiTOkvo3vWoBx0iBIuYsaxvtVk2iCJq+e1dDsQovz8I4W0/9uTGlgAvecqMNWq34pEH
	 f1FrRp95/bCxF1Aa7g3gTdbvM1I3BcTfpfAJTsavA1zwGNWteKBAKYjNpnGeP3LAzlQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820702;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=iNga88T+PVpZfmycjurDSPkD9sK5xR0SX7kfbe+Tx54=;
	b=GHibkxIXESM2/FpyY1yLpDCgNGbH3UdcARgRNg468C89sk+IHLeOy2dFuiDE3uZDjYyS
	 FmPGXhfQ6B+Vg3o0/93rUuLF4r8AievCU4AB5OPnixPx7WuM2TLOXBqkQ2d8J1/upd/GB
	 jZwKptdPcIZnSZXzgy89arbPRjVGZRyerGOZ8a3vYkSGsj/UqWBAkef4VfjsTIbX1jYMz
	 wB7s/2ukJ8tWU+oXIX9nqwzAlhoCTYwLzerPIDwLVZF1Dh3cIxPEPhMtABjBWdmWD3nbC
	 1h9QqM3QlxBq0iXkTqhi0h2kIbpRWu2v5KCWyps/gVXUo8PX/7d4BdVTFD+u1jxhfSQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QTUtfoyG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A250C6078176;
	Wed,  4 Nov 2026 19:31:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=QTUtfoyG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9C04D1F00A15;
	Wed,  4 Nov 2026 19:31:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820701;
	bh=iNga88T+PVpZfmycjurDSPkD9sK5xR0SX7kfbe+Tx54=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=QTUtfoyG9KimBN6AkuRRVKxf3yuHufM2Wi/2H06w/quFXdhMDoJ9b0J6ZGIpIGDK5
	 z976qLZrwGZZUEOM/2QIyKDbUKj8FDXwDBDduM9rT2JEpxfbS5W9S6Mm8PwwlXubYy
	 Byfx1vCeM6TyCBhpgKK3txGGQOhUx2gc7WMApbzBGlSMkxBhA0OSCSFLxKPNEU7q0h
	 FqpNY0wnGJwPDfBnXRKv+pXROQVVMWRvXSvePhYyYWGDW0C1FBZKM6snqSFwxIPGpL
	 n/TNrzyLKLnTrYCGsUsu1BjbO8fvjf0609ggkLleGQJeqlMRkm/wkvB/Y3xMoP4jHN
	 3X4C+LMwgRt5Q==
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
Subject: [PATCH RESEND v2 09/23] proc: let procfs own the seq_file of DEFINE_PROC_SHOW_ATTRIBUTE() files
Date: Wed,  4 Nov 2026 20:31:27 +0100
Message-ID: <20261104-work-procfs-core-v2-9-76ace653a773@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1051; i=brauner@kernel.org; h=from:subject:message-id; bh=asSZ4ovZjSippDtL33YbhRRNyZXb/VmTI9lzg7rupAw=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bq/5nqVqXtG267Wf70TxqQELt9YvquFOrjuo9Dzyi bzbsaDujlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIm8Wc7IMPEii96mWaJZ+q4z Be1mv1zvuTjM8YLV/BfT77Nf3z5H/zQjw1zRTpZdUeKsERs+f18mIsCt+iZRS73q0Q+xwL2+7nb POQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the show function and let procfs open the seq_file.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 include/linux/seq_file.h | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index dc0e8c62d9e0..b813b7e63d89 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -233,16 +233,8 @@ static const struct file_operations __name ## _fops = {			\
 }
 
 #define DEFINE_PROC_SHOW_ATTRIBUTE(__name)				\
-static int __name ## _open(struct inode *inode, struct file *file)	\
-{									\
-	return single_open(file, __name ## _show, pde_data(inode));	\
-}									\
-									\
 static const struct proc_ops __name ## _proc_ops = {			\
-	.proc_open	= __name ## _open,				\
-	.proc_read	= seq_read,					\
-	.proc_lseek	= seq_lseek,					\
-	.proc_release	= single_release,				\
+	.proc_show	= __name ## _show,				\
 }
 
 static inline struct user_namespace *seq_user_ns(struct seq_file *seq)

-- 
2.53.0

