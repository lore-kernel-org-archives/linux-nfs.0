Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629518;
	b=QAmVDpBVyJIf+HnPeMGF6YrhiH76veIgnPRwVM3B7Pi/GYzpt5VB8sxowlDeE+te2Kfh
	 7/tYDbaS5iVKbKz8tC4GiJLfWmDWd09efvCt30RQQlCE4YgCavCEwOQYAKNBuniIUwujG
	 UWctq0fBYN8Nlxar3jVDcjeQq7zasM8K6G+4pA773nr7fK6E409Yk836tBC9nVtFzqucf
	 Nq/Uj3R2fGdmxw0wyX3FxBEPer6m3fOZ0H92ou+EVeJ8zUm9XORwlia2wtbymwFX+VtTz
	 /YjagexCbDkU89wilpWVQp/R/wEAqtmMZ9QIAZt5tJibSpV3ODqzGQVHJs5knsab9ug==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629518;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=JNpsr2x/IJiEDPfvFWvunpncxqTaLkfXU09AZqKel44=;
	b=e2GiQnSJQsYMczxC8IXyz9HgxLeVc+oHvk4sQFbi2jfmo0tEvDp0wqujKXozM/UcxDc8
	 OylrzDVNSWE1dVKOuKbKa9qzl47OLqKogTyRsqK0iLvPv0mQpGxwB20F7kDV+vPHECUI0
	 7B5mM315oxTa79a6gGyqb+lccQI7VTz1cXJCuWjbiRnngs7/7wSfwKGz3rq3toqYz6WO1
	 UPbxgDh92xtOPNQZc+zjMiWk9Gixcx3Spy1UUY4eXH9L2LjRtlejOvma+OTLCLPak7/By
	 ROP3tF/Ebu0+oq3cAmE/yDk366sQ/yUxyotEVV+rdtNtFfNq5Ag0q/4xJceQD0VUZfg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="JDsGn/hF";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 610DA606A91F;
	Mon,  2 Nov 2026 14:25:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JDsGn/hF
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0C3D51F00A1B;
	Mon,  2 Nov 2026 14:25:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629518;
	bh=JNpsr2x/IJiEDPfvFWvunpncxqTaLkfXU09AZqKel44=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JDsGn/hFVn3jJgZZN+vxWeK27seUWBPs1wVOE+JNEu0HLhYAOJ2nqrTO6haz/TYj6
	 YNU6ClCHb69/Mwz3VGSMP1SqtEUNb1kZQxwlphv0C3QTgmSWa3hvL0K6Nkv8/dDbQg
	 lIAyZ/SG/ZBazLbZqMfdobAk/no6q8xju7R/ZEgKZSmu4XDjIlEdZse+5kbC/M3ZOb
	 YtyZc+thQ9HPKnmDmp1ArUqwC6t6Rtew7taSAiLHDbNBCUSXLpeUtxzb4vHo6JVhmo
	 9ttgQP7T/cJcSArxgsr9Ra6D/o7FD6CAOwSHHtHKTQ6QSDDqKkrHmSX0e7L0CksocJ
	 AnCPlWoxZKPDA==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:30 +0100
Subject: [PATCH RFC 15/38] ntfs3: don't warn when a huge label is written
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
Message-Id: <20261102-work-procfs-bugfixes-v1-15-59422ed3e465@kernel.org>
References: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
In-Reply-To: <20261102-work-procfs-bugfixes-v1-0-59422ed3e465@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, 
 Jann Horn <jannh@google.com>, Josef Bacik <josef@toxicpanda.com>, 
 Chris Mason <mason@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Eric Dumazet <edumazet@kernel.org>, 
 Thomas Gleixner <tglx@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, 
 Jonathan Corbet <corbet@lwn.net>, Christoph Hellwig <hch@lst.de>, 
 Greg Kroah-Hartman <gregkh@suse.de>, 
 Joel Granados <joel.granados@kernel.org>, Kees Cook <kees@kernel.org>, 
 Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org, 
 linux-um@lists.infradead.org, linux-wireless@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, 
 ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org, 
 coreteam@netfilter.org, kexec@lists.infradead.org, 
 linux-pci@vger.kernel.org, linux-sound@vger.kernel.org, 
 netfilter-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, 
 ibm-acpi-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, 
 linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, 
 linux-cifs@vger.kernel.org, linux-fbdev@vger.kernel.org, 
 linux-hwmon@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, 
 linux-usb@vger.kernel.org, samba-technical@lists.samba.org, 
 sparclinux@vger.kernel.org, linux-m68k@lists.linux-m68k.org, 
 linux-doc@vger.kernel.org, linux-serial@vger.kernel.org, 
 linux-atm-general@lists.sourceforge.net, Takashi Iwai <tiwai@suse.de>, 
 linux-input@vger.kernel.org, linux-raid@vger.kernel.org, 
 linux-ext4@vger.kernel.org, linux-modules@vger.kernel.org, 
 linux-debuggers@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, 
 Chuck Lever <cel@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1211; i=brauner@kernel.org;
 h=from:subject:message-id; bh=hEYNyHmJEt75byF8qjmUEc5I4mCCp/IJRi5GCVbZqjw=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJO9tzXzBHuGhvXirewzzGdVv+3VvLvcMMAstP/LI
 s3O1W3PO0pZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACZit4nhv0u6nc6mlExVhhyr
 oJCt899GB1UJL32g2bLt+sHUcj+ddob/CXvLet7P7ZCO8VCLPuikff9GTLZ8i9e6xds2/Ct79T6
 KFQA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

ntfs3_label_write() allocates as many bytes as are written with plain
kmalloc(). A write that is larger than what kmalloc() can hand out then
trips the page allocator's warning, which panics a panic_on_warn kernel.
Use memdup_user(), which fails such an allocation quietly with -ENOMEM
like before.

Fixes: 7832e123490a ("fs/ntfs3: Add support /proc/fs/ntfs3/<dev>/volinfo and /proc/fs/ntfs3/<dev>/label")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/ntfs3/super.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/ntfs3/super.c b/fs/ntfs3/super.c
index 58ef6be3286b..b4479cd6bd65 100644
--- a/fs/ntfs3/super.c
+++ b/fs/ntfs3/super.c
@@ -552,15 +552,10 @@ static ssize_t ntfs3_label_write(struct file *file, const char __user *buffer,
 	if (sb_rdonly(sb))
 		return -EROFS;
 
-	label = kmalloc(count, GFP_NOFS);
+	label = memdup_user(buffer, count);
+	if (IS_ERR(label))
+		return PTR_ERR(label);
 
-	if (!label)
-		return -ENOMEM;
-
-	if (copy_from_user(label, buffer, ret)) {
-		ret = -EFAULT;
-		goto out;
-	}
 	while (ret > 0 && label[ret - 1] == '\n')
 		ret -= 1;
 

-- 
2.53.0

