Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629722;
	b=E5LVmHkvEnnnUBYt92QHw/L/mJIbIZmPgUofqCer1XYM63cEVLvfWqb49neuYAjSb2ce
	 o9XdyijcS2iZc8KKGK70kGUyhxSRPZSOPg6oty6ZXXRjcUgITDOhyd2mmPtJDaGAigyuW
	 aQ5XGcTOt7XfgYbKyXr+bt/yDgE01yLP6lYV9SMaMIxW8ok8B3AjQmoxyY0mNGrJ+mWit
	 7Vmd66NW9hfbYuYQfB7CqyRBukBd7VzgIWbUvqGtvp0zCTK1BZdqMtOqs6oCMoCOjB8s9
	 yKNJxi5XHqy5TxYKVtAONB4BX2ndSjh4smKEuTa+IG18WVlxbyzthKg97IbqHXlaVFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629722;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=8QCucuYZDNmVJaqyrDFn0TUDlr5eGhlHKy/r+vN8wLA=;
	b=GJ1KeBayeogPRT6RIPuozTvR9PW91Tkuje1eJCMbmGBz3Jo6ot+6/MjCpuG5QsepjfPZ
	 zZPLyCaoHlynjnweMjCeLl87Jd03lcLEFlvje3RQbfbsaXDqGa+BBmcFxOhp8Xx3PYRaW
	 4UDZB5osclYNMmtpZ8lBRaicSSTRmqcsrxDX2BtI8XJ6HJJQ/vc9+wp0UNn+/XM/fmPpV
	 s2Nlq5Gp1e/MbbqaCLPxNozH28T9etLHgZA72gNW1cW1effy1IeQiirjH4GEBmACrfYE3
	 691XCF0iz4sPgpcOoq/0axEJKyONHyFq8fY1bcfJNwX3lPvXsvsjwodK3mB2c4HgmyQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eTKJcNWG;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9AA01606A5BD;
	Mon,  2 Nov 2026 14:28:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eTKJcNWG
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DDA321F00A18;
	Mon,  2 Nov 2026 14:28:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629722;
	bh=8QCucuYZDNmVJaqyrDFn0TUDlr5eGhlHKy/r+vN8wLA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eTKJcNWGC9V6irm/9DKKTQuZ13M+/P1en2BQ55yGY+lnmUDRqciw/Rf2PsHx9OoY0
	 buVb9lCjc5j1j+zVE00+8lE+7EIBrkA/7gY7pAiXO36HsFOR8TPuUiDrZTExwthr5Q
	 g2ntrsvA0FRDkX0DqkVI2R0zq637sI1kyS8+kikVTIf/hcY+oSRxJ/YR+1Xg+xR/Sp
	 aqNRXFGzdUJn5XBZWThM4MbuyB2ZEPnFIDc98ztB3FY2A2pzEfLhWTVFohA37ZdeKD
	 CBtYkQwAlSwOguLYUrqoxdDzbhzJby7zBKRKI64hRz0r7REL/5ePc9HqUQM4L5ULRF
	 akeGwQAgSlDqQ==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:45 +0100
Subject: [PATCH RFC 30/38] powerpc/pseries/lparcfg: return h_get_ppp()'s
 status as a long
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
Message-Id: <20261102-work-procfs-bugfixes-v1-30-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1639; i=brauner@kernel.org;
 h=from:subject:message-id; bh=KaAFx5Z9JEYFTwMkBWfFQWs2ORbRuBTJUi5MCRtyyf4=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJOTxjOPK/q1b2ZgvpS2omCxgaLdOpGttm2Lmc8Xv
 BU/7jG7o5SFQYyLQVZMkcWh3SRcbjlPxWajTA2YOaxMIEMYuDgFYCJJ7xgZGrU/qMj0nPKcWMLS
 d31xjeSx7XF/+lkE6y6zn7F2uXs3h5Hh2IQtWpWPJy1y5bu073hy0q9fd7PiLBl/7MisOXdm0pI
 kLgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

h_get_ppp() returns the status of the H_GET_PPP hcall as an unsigned
int. update_ppp() hands it on as its ssize_t result, and
lparcfg_write() turns the hcall statuses it knows into an errno and
returns anything else as it is. So when H_GET_PPP fails, say with
H_PARAMETER (-4), the status comes back as 4294967292 and a write to
/proc/powerpc/lparcfg reports that many bytes written.

Return the status as the long it is. lparcfg_write() then treats it
like the status of H_SET_PPP and an unknown one is at least negative.
Before commit 11529396ea31 ("powerpc/pseries: Split processor
entitlement retrieval and gathering to helper routines") a failed
H_GET_PPP turned into -EIO.

Reported-by: Chris Mason <mason@kernel.org>
Fixes: 11529396ea31 ("powerpc/pseries: Split processor entitlement retrieval and gathering to helper routines")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/platforms/pseries/lparcfg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/platforms/pseries/lparcfg.c b/arch/powerpc/platforms/pseries/lparcfg.c
index 3280b7968cab..aa9b5b141434 100644
--- a/arch/powerpc/platforms/pseries/lparcfg.c
+++ b/arch/powerpc/platforms/pseries/lparcfg.c
@@ -113,7 +113,7 @@ struct hvcall_ppp_data {
  *	          XXXXXX - Entitled procs capacity % available to the
  *			   partitions pool.
  */
-static unsigned int h_get_ppp(struct hvcall_ppp_data *ppp_data)
+static long h_get_ppp(struct hvcall_ppp_data *ppp_data)
 {
 	unsigned long retbuf[PLPAR_HCALL9_BUFSIZE] = {0};
 	long rc;

-- 
2.53.0

