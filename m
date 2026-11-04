Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793821436;
	b=bZHO1F/cIs5BhjVt0Zf0lL3SuyB9gv61UtSoKvueY3p5qbd1Oc1u2EbYFDFQ1NOtqW5I
	 rdar/X4daUScVge0Q/Mb8z0KS1W2c0xc29kL+r+cLXxEqJwizlnblmzHuoCY+xL31jsWI
	 KCnYp7n9xPKK9+tWqZnX3bc4DGqDbCv/SZ7eWt3dVegegG2z/OxFje0pCgyVj7BNLDG55
	 aJTWwvAgGUxPRFUvb6nPN0H+vRAD1qpIdzrUULWOIi0swWDsm83Xgk1suqTT/TQmLv0Ag
	 3BAkcSkxlPnBGvkGH3ti3eK/LNLXK7jbLnQl2T/TUWJYfQ1EquBqaNFPrGcdZlrlr0Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793821436;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=MXDP9fyzpcc9X8/ROQgrmtpQySITyZcOubu0QYlfW0Q=;
	b=A0dBn8KwWhr7WW3G7KSQwEoGYpqcJtDBWbcaQ9JnOxJ2nwbnSgOda/ceDdppGWGQE8RC
	 jPTsSwxKLj+d3V2sJC29/m5sJXo5yP4VrcyRVYgQHvjIMIhd5BSLznjBMu9lV179eG8oE
	 TuwvOQapTwkYgwb0y3mAepLlWDiKP2Z9lwejE00+fQ9OA9yiGKXv6CSQMYh5oUXnmmbP8
	 VQ8+PPtcu5v1itGkg621HE7re6xk/Tx9OmHNfSpmzkUv7n9IE92144dzgwFKi/oMdAUGX
	 DTdTLnCgB6Tj+X0sah+wbRbGLWhGcv6J26MYKn9XgBxyXqi8slud7EvGGERz1X6xq8A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HvxkwJrE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8068A607076C;
	Wed,  4 Nov 2026 19:43:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HvxkwJrE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EC5111F000C1;
	Wed,  4 Nov 2026 19:43:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793821435;
	bh=MXDP9fyzpcc9X8/ROQgrmtpQySITyZcOubu0QYlfW0Q=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=HvxkwJrE6yZiYOxFcQMcjejW88ZaW29hTOWaJR9YO5Tvs3/8Ku/knORgdhrkWEZnm
	 FqlvED7tkZyaWujkmmUucC82ygg0xRZPT8t1WYaFWGOQCbuZ5npn6/psp1WJsopeBc
	 /Ip4YEzyI9/mkYahhPxRdv4RqwBmNw3bGEqLSFKH7xSvANy2+6tMJK3oeMT/j06KPr
	 aV1SaTvwJyNaQmYfmPPmd7MRi8vEfKFW5IekI7JTcT9yV8aBpWOQ57VRcmy0cEhZAb
	 MM7IMfpEqYVYfJYvfiLY5AP2A/DDKBQ+DAROllTXi16lENKuE4ydpoDCGxpGPMHxZe
	 bfR3jntxCFu+g==
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
Subject: [PATCH RESEND v2 06/26] md: let procfs own the seq_file of /proc/mdstat
Date: Wed,  4 Nov 2026 20:43:40 +0100
Message-ID: <20261104-work-procfs-drivers-v2-6-245e54e87116@kernel.org>
In-Reply-To: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
References: <20261104-work-procfs-drivers-v2-0-245e54e87116@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1303; i=brauner@kernel.org; h=from:subject:message-id; bh=rdu1kmejfqc5NG4cwcsJAI4WSVobA0+Qk8YSn4PPNtc=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS97qq6MLvj4dWlPlW/Lu/K/95xU/V2xNJbCyWiD8o4T U+5uk0tsKOUhUGMi0FWTJHFod0kXG45T8Vmo0wNmDmsTCBDGLg4BWAim4wZGb7tvCDdyFbA2D3h xbQ1r407Cl4f1/C3fFQsYPDizr8HIumMDFP6U2beWjP1wmONNb84O1vnWbE1dPszPL6aGeZe9b+ wjBUA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

Declare the seq_operations and let procfs open and free the seq_file.
->proc_open() only records the event count for ->proc_poll() now.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/md/md.c | 15 ++++-----------
 1 file changed, 4 insertions(+), 11 deletions(-)

diff --git a/drivers/md/md.c b/drivers/md/md.c
index 03e35386a802..64abf1743e41 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -9167,18 +9167,13 @@ static const struct seq_operations md_seq_ops = {
 	.show   = md_seq_show,
 };
 
+/* procfs opens the seq_file */
 static int md_seq_open(struct inode *inode, struct file *file)
 {
-	struct seq_file *seq;
-	int error;
-
-	error = seq_open(file, &md_seq_ops);
-	if (error)
-		return error;
+	struct seq_file *seq = file->private_data;
 
-	seq = file->private_data;
 	seq->poll_event = atomic_read(&md_event_count);
-	return error;
+	return 0;
 }
 
 static int md_unloading;
@@ -9200,10 +9195,8 @@ static __poll_t mdstat_poll(struct file *filp, poll_table *wait)
 }
 
 static const struct proc_ops mdstat_proc_ops = {
+	.proc_seq_ops	= &md_seq_ops,
 	.proc_open	= md_seq_open,
-	.proc_read	= seq_read,
-	.proc_lseek	= seq_lseek,
-	.proc_release	= seq_release,
 	.proc_poll	= mdstat_poll,
 };
 

-- 
2.53.0

