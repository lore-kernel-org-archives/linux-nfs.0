Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629462;
	b=qJ8XSeS7NVUPkUU7KpuYdrXPg/PKb4pq/9GWo+XUDFVFuAS1GiHL4KtgN2K4iwJER4Eo
	 a29fqeHzeJkQsmk/5knK1FhvO/0r64qI3+H1MPc+orNQFMWaWCvSsvAGmfdUSQTftfwYB
	 4PjacoliFTRWpVRiTJUhGGUgjLtXcm8lYcojd0DCfUcuGHYHCLU849zh89IWpJ657tZRH
	 TUZ7jMyWWOp8ltlg3MYKEg6I5QqTC/diFvS+4LkWaySPIMYpsPyDXthzqDacNb1dV50p7
	 x4njmwhv0R+QlPpph9LdsCpgTTdH79NRb2QdJhV46j2ur8hfUWLoorh/cimxLC7nZXQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629462;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=LrGvZ3iuNEQwh46pZ+Sey+hIl+TylMI6LnuDESRA+nc=;
	b=EASeVSyIGCaKLE0PlBuQsb342hzTNcP7t65sx9l81K8WfH7h6gob/GaTeNKB+Kl0Y11R
	 exeXI7PR1wUT+p7gpd+geuG2LlHlm8+pDhuVbl22Yt5dpruUHFXOXvWKCPT14ZdCDGjhf
	 0tYVuuaR1I8VEoQcegNuNeeCJuBM9yVSTuvPGRwaMkq0+NwDtJUgpRDK/PBqHF670nwYa
	 spSqhN7vwsEA8tnZzR9up5r4IDtHTfcnH9qwpsMvEzDImHzLwbCEBqWvj/GqAm5N2zXBm
	 MC2eCgLd4JanQRgXjT8zOa/QR+oFLRKuaRSNIV1O64URMeMlpJ73tq7bgMZP6uPmOew==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PPfyE6QJ;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1EBFB606C3FC;
	Mon,  2 Nov 2026 14:24:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PPfyE6QJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 527D01F00A17;
	Mon,  2 Nov 2026 14:24:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629461;
	bh=LrGvZ3iuNEQwh46pZ+Sey+hIl+TylMI6LnuDESRA+nc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PPfyE6QJfnkYegdNJOVyvRw2w0u6zk/zq1ATvwc/6eUWjFe4vJ1pRwfd7t9Ibhm29
	 IG8+/3Y2h9D6Ml0EqluGiF7ZzqNXzL3BnjR04OHSHQICnr6q/zg5AgXD6brOztOzhp
	 Tm5r+Xn3qFTr/0ct+giZygbQPAoKv9HR1rxcIMLZsGHigSCh3rld2MQkXvCo/Ahi3k
	 OPLhbcK1nwFtdEjV44unUVPhIPYHIiNsNsBvSGn2WZYWfU7Yx81G3k7ZcW6H6YJJZZ
	 iSvJgVc7lHHoAy7pZXSTctPPyJxiyAjwkTJ8kb6zg1ymJ6Dkna5fZS/L05pAfwaVCn
	 /p3edvhBr30yw==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:26 +0100
Subject: [PATCH RFC 11/38] scsi: ips: don't return 0 from writes to the
 proc file
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
Message-Id: <20261102-work-procfs-bugfixes-v1-11-59422ed3e465@kernel.org>
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
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=745; i=brauner@kernel.org;
 h=from:subject:message-id; bh=AdCDbLhnpBt+TcsQ0P6GBBq6Ub9shryNzqH+cUsZhBE=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJPdt/hGgM8qEaYIn9fiBlE/kqwu7y3d1vz/wn2JQ
 1nljmYxHaUsDGJcDLJiiiwO7Sbhcst5KjYbZWrAzGFlAhnCwMUpABNpYWNkuMNVfzzE8+fiU716
 eVvUz3BoagZsjeKTeFXs/sHF2WvyS4a/YldW32kR8Rf1s2fVtZ1uwyx92y2ElcvRtJJH6bK80SQ
 2AA==
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

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
index 45c5b9acb664..bf3a961834fb 100644
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

