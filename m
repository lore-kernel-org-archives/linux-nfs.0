Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793820125;
	b=FhnwaPT6DwixzWazVQKYOvLnwPS0lF/Thui8xab6XFH7THKPtpDjDf0H/duNCSYkwL6w
	 WgjOUI+7lG1GoeSlDCxg8VWo7RtLgrdL63jbg/bBLSzWBRAXrclhOGwaLmuRZnFAgJPxl
	 csjMUvty69bpF05EjQBLWPtcM8yU4yn6k30hvwHkBiMIBEnQ8sl0GLH0c+JbxsEw7UU89
	 fIO5G8zGe7ZF6qSzO5T6wdNSw8xZK9Gp2Dkhddz+WYEXcIVO8HHTzvgZxN4qDUZkt1Hjt
	 tsUpiNVjKCy0jCun4CTwFMlGcJAwSE61ekyBBmZOQ7zHDSprrE0dwCfZgynZetXxFXQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793820125;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=E1vD3O9CKVYh6HjmlrAgiThE5xPMlSXjct4LkBIJ4ZU=;
	b=NxRf2jbhZs4PXacfu2t0DKd1mV+AHKt/CYFo0WtDDRMW0l5ugojwOqIbqqmMwGURqwPb
	 pPa+utCiKAalNnmuio6rx2q/GqBSMLNWqaueIiDwjU8gYctFdmOXxuRObtQCobVOjikIY
	 WSS2if+xD08wFrPNhixInJwq/5vSKIRdnfUcqLCLbJAjqhepfniKpaMiiAdoztpaY0RKA
	 zjOVz28An6YRjXxbPg5vgj1FsNx7vyQruKtY64RUVKrNj6/OcncfytRFxilFAxH8d17Fv
	 E8JIMQKzNS16GMhJwBjO0GceOX3y3g+kgLGTFFXwmh0UsJxA5RtlzQFAODL2EqWNy8w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NswRMcqB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5A01B606D82A;
	Wed,  4 Nov 2026 19:22:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NswRMcqB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D87571F000C1;
	Wed,  4 Nov 2026 19:21:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793820124;
	bh=E1vD3O9CKVYh6HjmlrAgiThE5xPMlSXjct4LkBIJ4ZU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NswRMcqBfCW7Yx+oHzm7X7x3Vx4jEKmXruK32+U47DYkhN6rM/lfoH6AjN/SxL36f
	 PgY3FjroHKYvb5ZucZtjjxfeMesHu2aiCu42BfFriOzz2a4zJcMYsY+q/uNY/jVlJJ
	 mQbA97oSkcIOHIdNHKCmo9rGnj+/+FM6G0eHvq02j3TpFo9jYjkaTorhB3ZPVCn8O/
	 KrKgum+HPtAyA1T4+n9pWNsjQ+Y0I7sn0Fwghzv5FJeoW2kBqDX6BHChClQ+D48khG
	 NOJNO5qh2fzt0fT/JulzaUiqzxtJvpPURLPvwRRXNWlyCu69pQW8Kq49mWs0Mw5ust
	 pZrAkn/r9fpNg==
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
Subject: [PATCH RESEND v2 24/51] scsi: ips: don't return 0 from writes to the proc file
Date: Wed,  4 Nov 2026 20:21:50 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-24-021c84d852e0@kernel.org>
In-Reply-To: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
References: <20261104-work-procfs-bugfixes-v2-0-021c84d852e0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=745; i=brauner@kernel.org; h=from:subject:message-id; bh=M56s+R4IzmhMvI79F+bEsnRzyAX8hD//ktSOts+7Usw=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9bnzxmUHw2l7pkLsqhYUfQu3abymsV/u8xrZmTWDq2 g3r1DVfdZSyMIhxMciKKbI4tJuEyy3nqdhslKkBM4eVCWQIAxenAEyko5aR4VlF9Y6Ezj35Scu2 1YjO/m7UtL24teDezKI9Ly4oZn88c5fhv8cv7zNNOrwr0iK6hZPXPQ1f+pT5o1tFzHcBAQ/F8yd /cAIA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

ips_write_info() ignores what is written to /proc/scsi/ips/<n> and
returns 0. Writers that use stdio, echo for example, take that as no
progress and retry forever. Return the number of bytes that were
written.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/scsi/ips.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/ips.c b/drivers/scsi/ips.c
index c7d6c5aae340..85c4fb164743 100644
--- a/drivers/scsi/ips.c
+++ b/drivers/scsi/ips.c
@@ -1428,7 +1428,7 @@ ips_write_info(struct Scsi_Host *host, char *buffer, int length)
 	if (!ha)
 		return (-EINVAL);
 
-	return 0;
+	return length;
 }
 
 static int

-- 
2.53.0

