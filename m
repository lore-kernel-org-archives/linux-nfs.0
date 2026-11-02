Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793629379;
	b=0xfutx6q4t3lvwd3M9Sv7O05KQ7dz9U4LAfrwbY32Ie7Uh1v/mDLqisgUYOENHbEG3Tf
	 B2HCP6u5OlW1sp5NRlVWSPEDe5WIoGFTKtoVcQ35Mv1BmUComFXPbAxrRsmCNcabnbpp0
	 psC1Zrwhewd6qZgEArAWW9lKHuq3WGPwxo5VTH13DgGFh8KI2gACWhNW7viFBLYVYkhXX
	 dLN/wclFBLfg174xOYqTCtz71vEFWD2iGYdnsYJ7j0I6Eo60cu20qXBeFolrrJfFsC+UJ
	 Meklqwvm70EFQ/F4wmULRDeET13gUB1HEwB64LeBAFRnBxMZj+WdfDukjYnd84wSsdA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793629379;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=WXeWRtHDTvlcvQqGcGXKpHSOkC75TIYAS6cttW7V/+A=;
	b=bG3L3aC48Tl4aHu+n0ubOF7LUJQP4ZChUkYOlizrQcE+x2qrWK7CiEJ3W2jzieHIQ8dh
	 W/i7+WnuHympDmpGWIn0du/m0FCi88YOjLE7uHTqgjAE7M1bPe6rfoTIKBLtPhkMxZaL6
	 +XPybg6NEvPhk3NAwWDYALlxISu3EqIx14ciPYUUSWRijtjE4WkboGjqXbFursj9e/Myk
	 7beS4uJu9HAvnXEyb6f225eO9c1Wyf+Bd9E2WSTxInauSLa+6oheISGitBCYRC5orDziL
	 ecHwy0rlAQtdWaXpMcLp4wZ++sm+KWE2qaWaztFcOyYnp30ggD7NhfLnfTt52T4q39w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kvHRMzqf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A7A4606A32E;
	Mon,  2 Nov 2026 14:22:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kvHRMzqf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 66AA61F00A17;
	Mon,  2 Nov 2026 14:22:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793629378;
	bh=WXeWRtHDTvlcvQqGcGXKpHSOkC75TIYAS6cttW7V/+A=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kvHRMzqfiFxfaykdXJncqNCKytFOYdWEA6z2XKwrpx1cXAUWC/1f6IelPxZz69lt3
	 bZzGsPY7tAF+nhMSErY6rPc/3QL/4TA7hlVU8tM89mYfPX9Z6KS6p4IW1PsDrhG0OQ
	 bkcIKIyEY1GGRPu5UaBXvghHdY/CIfOPJbzAJZHTg7fVeaIOTOcs6v9yzyjdbAXIjO
	 eLo1eYZ4IN84HHP6CrAMeFl9oPgWiHXBV4hrBwe2eZenA/caTo8Hx2CSrazCqEHP19
	 DS3uVg+WucdQObp90U98MCzPe1bAhdyoN7eZZYLpOUglkgctnTto/e3gh/m1uyI5m1
	 KND/LIH3rUy8Q==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 02 Nov 2026 15:21:20 +0100
Subject: [PATCH RFC 05/38] platform/x86: toshiba_acpi: reject malformed
 brightness and fan writes
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
Message-Id: <20261102-work-procfs-bugfixes-v1-5-59422ed3e465@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1850; i=brauner@kernel.org;
 h=from:subject:message-id; bh=dBPyRrfA4AE5uU+SDwP01KQAXBYhly7L9ZsRpXHhzrM=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS9mJP1X33fLpsJXpWBaifTEsT2SLto6RSE/d33f+fli
 mfvjj3d3lHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRafMYGSYH7L886UKoRuDq
 G9c+FRp4acs2loQbL5Kbz/ZCoj25bhYjw/4HhzpE/VP23N4kdd2x9P4SBZmAjRbxpyfu2bkqlD9
 1GTMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

When lcd_proc_write() and fan_proc_write() were refactored their checks
were inverted but the && stayed. They only fail if sscanf() didn't
parse anything and the value is out of range at the same time, and for
the brightness value < 0 && value > levels can't be true at all. So an
out of range brightness or fan setting is passed on to the hardware,
and so is the uninitialized value if nothing could be parsed.

Restore the checks as they were before the refactoring.

Fixes: e1a949c1b988 ("toshiba_acpi: Refactor *{get, set} functions return value")
Fixes: 3e07e5baa2af ("toshiba_acpi: Add set_fan_status function")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/platform/x86/toshiba_acpi.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/platform/x86/toshiba_acpi.c b/drivers/platform/x86/toshiba_acpi.c
index a0b8060836d0..9eb8f1e5aeda 100644
--- a/drivers/platform/x86/toshiba_acpi.c
+++ b/drivers/platform/x86/toshiba_acpi.c
@@ -1498,8 +1498,8 @@ static ssize_t lcd_proc_write(struct file *file, const char __user *buf,
 	cmd[len] = '\0';
 
 	levels = dev->backlight_dev->props.max_brightness + 1;
-	if (sscanf(cmd, " brightness : %i", &value) != 1 &&
-	    value < 0 && value > levels)
+	if (sscanf(cmd, " brightness : %i", &value) != 1 ||
+	    value < 0 || value >= levels)
 		return -EINVAL;
 
 	if (set_lcd_brightness(dev, value))
@@ -1678,8 +1678,8 @@ static ssize_t fan_proc_write(struct file *file, const char __user *buf,
 		return -EFAULT;
 	cmd[len] = '\0';
 
-	if (sscanf(cmd, " force_on : %i", &value) != 1 &&
-	    value != 0 && value != 1)
+	if (sscanf(cmd, " force_on : %i", &value) != 1 ||
+	    value < 0 || value > 1)
 		return -EINVAL;
 
 	if (set_fan_status(dev, value))

-- 
2.53.0

