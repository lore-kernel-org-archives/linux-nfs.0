Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629448;
	b=k7xDMT4IHfCIl/WNC5O7hpFrdWxZthTZLpcttKMpz2j1J2paF9RajExLqZ+DGOxNV5hg
	 Chj/V5C+PRejd5rra7c8gQ9Z/5pNEJj+74XeFqNjdnX/mCuTaMRhs+khsHE1Ce+wuGyNA
	 xmPGlNNXkcMKhyOuGQR80SwjDgTf9eB1C66zhRgoXjxf0tVPwkz5zrB4gJECvIrgdMkqE
	 XRk0bBAp0e/qt92q1pgqEKetoJBIhgJWMtRJL3G6JkFq2nBo3z1SrwK0euEnHur5Kwtb9
	 5z1d/F6PaQK3KMLPah6yE7UoQ1bmu28E8w5mzTbSOZlJtdg7wdhJV31wMabADi+ixVg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629448;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=bRUY7zR2xEebSKJvbp7QJxGSJz7lwz+abCfF6bzfIu4=;
	b=1LiA96sALKI56UE7l0M+Dm36KYnV3vjENP0bohq0+W3Vh/BL4aHWsCE7FjbbZeaHrInO
	 9yl3w8MpDHvdDjWWQ6RrBTOIqTesw+rVLgWUq2dPq11w1iw443PsPtEur51rfcyX93AvP
	 eTTuGc7Xe4ZwCplLBCeHSEpszNdSAO6BB1525+SeYmtYMb739GCe3hrSb29yivkh5Rp6G
	 AhDKAXDHVAuZoKQMIhUPYJMSujdCfwpz/0Rp0xt2MtMhNG0Q5lgTw0zpnDDr9Cxfu2Twx
	 WTaIgBAuIron6xqp3sZpVn8eSS3V7BPh0x9MbG6TfvslS4c43PBomqsw8kDrMdXCjEg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q4oHngSl;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1E9E606C543;
	Mon,  2 Nov 2026 14:24:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Q4oHngSl
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 710651F00A16;
	Mon,  2 Nov 2026 14:23:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629447;
	bh=bRUY7zR2xEebSKJvbp7QJxGSJz7lwz+abCfF6bzfIu4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Q4oHngSl6RR7XQvcJq+XaAp9wX4Uiv+CQ8sx4Tt2Tusi7rGELCsKtcuLcJJXnbo+b
	 mxlCgtfGksXTqY2Q/8i91T7AnVm4BEBRl137Etf0oGTFwe9D9oRBciQMWq+yTOnOO0
	 QGVsyH0LhCu7l3v2bfGJdLJnVjIV++s5b4XPu+DOSQdyfbHSB6gyfZ4k8lXOPByBBi
	 ThdJxOnufgvJDz0xi8ZTB5otDmy+J1lOLDGOMtm2aS31Wirxp4zSQl4+tL7bcGeXqo
	 dXa74lidvqboGZhY+2PrxAo9x6EY7nhYPMVAV1rpoMUok0p5Nh6BfTdJS6upH/7sTm
	 6tssOCEdNYPig==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:25 +0100
Subject: [PATCH RFC 10/38] scsi: BusLogic: don't return 0 from writes to
 the proc file
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
Message-Id: <20261102-work-procfs-bugfixes-v1-10-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=938; i=brauner@kernel.org;
 h=from:subject:message-id; bh=7Bhyn2ehZ0sKrsH+Wp9jL6/kN1Jv4nVldfkK6knOcds=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJN1a7Lx4sI0u4/XFnXO+KMXfnKfYejKtbH8CxZsO
 hF04AI3S0cpC4MYF4OsmCKLQ7tJuNxynorNRpkaMHNYmUCGMHBxCsBEpHIY/hfWrPRbNS/qY0/s
 /78ycW9e/DrR63iI826p6grLItn8JccY/in8u3XBeXvXw5LYlpjDslrr5YOmH3c4HBp3rv7Xg66
 gLawA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

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

