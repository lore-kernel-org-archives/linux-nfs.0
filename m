Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814672;
	b=to6tFDhFCkeoq7F2fFRR6R7QashsU5TWJFcl4GkU4V+7fF0in5xKvx1cxyr/7C5dVwcp
	 PyMt/M7gN5HGKoRzIQdnKZ1UQ19IuW8FE9Tu8nOSaz0EOPkpofiYuRN7J+Ydv+Olzwzpf
	 +qY8TtKmohwI85g3u6g7V1dBjpjQnkP69rZB2V5ozV4A2Cn0aFKbkX0sTdCwpqxJeH2r+
	 Mv31QKURC12wZjvZdY5x2Q/OdN5PfWrH8euoi8M1kOMofIgdvc/RArplH8YD/yXfvJsLo
	 sgJGiufUeTTYHg0NJmsfFomNc2TMJpvxbvWiiqs4HRHGwrrkuyGQdCkINqckcc3YbaQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814672;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=bRUY7zR2xEebSKJvbp7QJxGSJz7lwz+abCfF6bzfIu4=;
	b=JpQQwAXBXctqzeIgLL1Etsdx+2H3IH2tMV/jAmjGzBrHvak7A11DrzClllRnjJmnSZIz
	 /NNVhSQ0y4ucUzKKGSNcE5a/u41MAntXwWVMSaFC2cBf8IUuMjDG8fI/531tIRBw/i+cy
	 9PCkujrgrEyU8kdGPRuAbK40MlOaT1YRUx4PeITc8hX08g9K9bZfaC2TUSx4NHP7qZB5J
	 02IbY0AP8mcF7kMWZBElKzivMk0/Og944lyEYPmCZd8oK3hyyLgJ96xtZKMBsDa0fLe2X
	 lEVp5oH0OEYEWcqDUTYoKtTIsx/URF0ZkYK/rtltG8ylh9xF7TUls0AdcWjih5sH+pA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dl7dlqCu;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81A44606A32F;
	Wed,  4 Nov 2026 17:51:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dl7dlqCu
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A87C21F0093A;
	Wed,  4 Nov 2026 17:50:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814672;
	bh=bRUY7zR2xEebSKJvbp7QJxGSJz7lwz+abCfF6bzfIu4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=dl7dlqCuigVtArFtm/v13PbvgoN21cEiJmv94TSdAfPYArcKB6G/oXjD8zdO24lnJ
	 ybF4ni0+zMxMXq66lTdyJm83mF5fI6TixB6jE4f2N9R1sc2LzqOgYA/CX08BrmhHiq
	 h5hWq+Guf6DVaBgNQPt0j0kZIA0xF83tJU/turfMgN1hOL3RG5geYK5UPa02oN+gzo
	 v+gW0NlE7T5ApRB2hs2V3O3dpHprLN/Sb2l6PJxOJgwtefZgJFn/HTsU9hDAnwxif0
	 uHwP71grr1P14LWO0dSiwyCEi1kPf44CFdlCPvbOI6cPhToAbeUH93m6qN8VxQJfEn
	 Hp/uLwaFySsTw==
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
Subject: [PATCH v2 23/51] scsi: BusLogic: don't return 0 from writes to the proc file
Date: Wed,  4 Nov 2026 18:47:09 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-23-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=938; i=brauner@kernel.org; h=from:subject:message-id; bh=7Bhyn2ehZ0sKrsH+Wp9jL6/kN1Jv4nVldfkK6knOcds=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zrudfHff/e+eJxMXl8yZKxXjd1JJhqM6dufPj3/OX 2dK7+SU7ChlYRDjYpAVU2RxaDcJl1vOU7HZKFMDZg4rE8gQBi5OAZjILROG/zVzphx+JGd7gfnE OQVeVkvb3OYYjch7EkWC4pcW3gmxTWJkmP47ztIzec7OKQ5aW8Xzd+v6Z97cqbrJUdNk4eHpdlN mMgAA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

A write to /proc/scsi/BusLogic/<n> resets the statistics and returns 0.
Writers that use stdio, echo for example, take that as no progress and
retry forever. Return the number of bytes that were written.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/scsi/BusLogic.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/scsi/BusLogic.c b/drivers/scsi/BusLogic.c
index 27b446c0c5d0..7ad814f549ae 100644
--- a/drivers/scsi/BusLogic.c
+++ b/drivers/scsi/BusLogic.c
@@ -3328,7 +3328,7 @@ static int blogic_write_info(struct Scsi_Host *shost, char *procbuf,
 	adapter->ext_resets = 0;
 	adapter->adapter_intern_errors = 0;
 	memset(tgt_stats, 0, BLOGIC_MAXDEV * sizeof(struct blogic_tgt_stats));
-	return 0;
+	return bytes_avail;
 }
 
 static int blogic_show_info(struct seq_file *m, struct Scsi_Host *shost)

-- 
2.53.0

