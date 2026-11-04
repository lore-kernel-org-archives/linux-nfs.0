Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793814635;
	b=GU/OF33cUExOsYcueCPzmykV6UslS6nyE9yAxdD34ZF20fVZHHxvvtFxxD5EjzzI5Q8/
	 20BCcspMFgqenLeso3hqwgZU1MeXjZAlKxZnIjCTUcykQJi1DHFgRvossJtIizOHPgr09
	 Kw2FCrziQUwABTKrFUcjQcJ01uNyPW5LkR2B5u+9DBwElwfyx/hDeNJTCTat20szgUypy
	 HYvdGBWJYUYnQPMwuLZk1ENzkij1hk1I/cBtuJAtxef9OI735JLDVXNYO8nqpobt40MIL
	 EEoxvpNFnP9AB8YTAXFzUog9W3Ix8sPv314HyNDTt1v1Mfb+EWJSd6LHNXTG01klFPQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793814635;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:
	 In-Reply-To:References:MIME-Version:Content-Type:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:Content-Transfer-Encoding;
	bh=p9+kMzHwjVYuWJQ2+obB/IGMwn7xV7y09JcSQ7GHv6w=;
	b=rri9Jzz5ylrmjCHshjKsoyqWbTOpdiV9gGDdI/LrZxDY7eeQmuMCfIXUokuHWu0A2f8w
	 IzHT9A0uRtgq5Is3JWawM0V54IKvjkV+SzYi8l1h50TvXyPZvktPwpBXBX87SM4xstdvc
	 Dqe412gfJoyaJPXAqVk00HPvdHe2v7qr60jHKcbj29EBicprheEIub4RydyTUJWbsxJBW
	 fQdnXTcocIHBSZh1zsvT8+0hUB796YzIm9v1ctz7nHiFvt20LdHr3LLalVUg4hBgyq2BC
	 zlP/SIPP0Ycry6XoMeYYhbWRBqLh4q8TFQiUARLzEzt8JpEdxcJ98n2CVMtxVUjY/uA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="nuEE//0p";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5325560A263A;
	Wed,  4 Nov 2026 17:50:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nuEE//0p
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1105D1F000C1;
	Wed,  4 Nov 2026 17:50:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793814635;
	bh=p9+kMzHwjVYuWJQ2+obB/IGMwn7xV7y09JcSQ7GHv6w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nuEE//0pTMjiN4EAckF29THCaCp8OShYg92gOVf7lMyKvCn0dVCXPo4XEmIgwbvrF
	 mgNMx/eNkGPYY7G6H0/+5Z2vYWnryKoGvrqXmpNUIJXHh7VRJoCJ9vZOSJMA/OjJoT
	 8z6LvY6TdWjfMQKBqFRTF1g7G5I/em9dQz+ebu6Y4iFujPyG6kD5aM4cOhxD5zLdkS
	 0mLt2so9jaXkBdOELDLBFZJsYTghdzOgcrQCBh4fJ1VVmpw1xBKRg75vKt5bYd5IUj
	 +CjnJztBrPQd0ybc2en6qZmMR8GIuV6NMVYOONgqhfspT52PI5BFxqfGvNedHL80U/
	 rS6/W8sLjdi2Q==
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
Subject: [PATCH v2 21/51] powerpc/rtasd: zero the error log buffer
Date: Wed,  4 Nov 2026 18:47:07 +0100
Message-ID: <20261104-work-procfs-bugfixes-v2-21-bbf7d5546809@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1050; i=brauner@kernel.org; h=from:subject:message-id; bh=mkSbMC6ZDV5f4P2v+qDezcMlza9tkw/MXVPMWZSeje8=; b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9zrvxY+J+keMVs7edupnp1Ff4+Ah738HHuRv3nhU1l bJwbb3Q0VHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjARpRsM/8P+v+y8bZx29NuN hw/PunmnX07Un1++7juvb051byL7qQCG/6n83y77TZpU+sZ0i3q+d/jTxn/VP3mKFCceKbEpuaT 1nAEA
X-Developer-Key: i=brauner@kernel.org; a=openpgp; fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624
Content-Transfer-Encoding: 8bit

rtas_log_read() hands out a whole slot of the error log but
pSeries_log_error() only fills in the sequence number and the event,
which is usually a lot shorter. The rest of the slot is whatever
vmalloc() left there. Use vzalloc().

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 arch/powerpc/kernel/rtasd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/powerpc/kernel/rtasd.c b/arch/powerpc/kernel/rtasd.c
index fd40864bdb70..dd0df5e164a3 100644
--- a/arch/powerpc/kernel/rtasd.c
+++ b/arch/powerpc/kernel/rtasd.c
@@ -523,7 +523,7 @@ static int __init rtas_event_scan_init(void)
 	rtas_error_log_max = rtas_get_error_log_max();
 	rtas_error_log_buffer_max = rtas_error_log_max + sizeof(int);
 
-	rtas_log_buf = vmalloc(array_size(LOG_NUMBER,
+	rtas_log_buf = vzalloc(array_size(LOG_NUMBER,
 					  rtas_error_log_buffer_max));
 	if (!rtas_log_buf) {
 		printk(KERN_ERR "rtasd: no memory\n");

-- 
2.53.0

