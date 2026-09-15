Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C98E45D90A
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 08:20:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.215.200
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789460438; cv=none; b=n4bI5zc+bkzQxy6xzE9q9ZUbBceN+rTC8i4uDmLqmcL5W9cKfvxeGHppiPwzEE5e5iI9G5ThRoV/oP8R8hm6F9mwpyJX4QoKSN0rI35GAxUBpdZ0SIGBiDN0oLykzlUb4cKvK1SolRkAW2OcTX8tLwyI/EPLE6MmK8ZBlcO1gLw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789460438; c=relaxed/simple;
	bh=r5g1LIk48i14U2vfSIgapr+8j4d1ay+VHM72YHjOSgk=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=VqIRpEnVGWw5+ETn9S80SjpCU00lFAKbzH5DrV9Q7PJ0z1ybkF/IKevfw/m+7sOnWiB1oXNRRfYexqLtkBVejziqQRBgoUstx/+RzT5r0A/dbKaJVspNAdNXRoEqwdh9yUSP39dirBK0LHPHZxRmPaB5zSUBR5LOhIS6ITm0fMs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--morbo.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=IlizX6tn; arc=none smtp.client-ip=209.85.215.200
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--morbo.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IlizX6tn"
Received: by mail-pg1-f200.google.com with SMTP id 41be03b00d2f7-cc1bbd7d6e6so3348269a12.3
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 01:19:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1789460394; x=1790065194; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=eIty82Ymjj64Fl6mn4Z3/QHhmY1e0QRFUR4BQSE5AwY=;
        b=IlizX6tnKtgYFaGIKggOEAU2LQqycnAmmrVln7UMgoNkc+T3fXFyfxtrWR9Ftg7E6u
         NlqIBdMVkiA44X97gEFiNhQASx0UkfsXPVQ+FsqT24P1pREp+Xm2LDPK/+zfzIMc7zqj
         LoyncqWo6VVJYN/TV9c2xaxXd5yvg298+BfthtSxZjpkjJF/wWHG0JuB/4ijrS0f/Qn0
         HyUa1kqS3stgXr3i0ePOnkDm5p5Vy8IMWICFQyyVHLGKUaOBx/awlv+b3wEcKtCTZYTS
         E89xOGGbSQvl96lOxBnGGWkdXKUsBxmd/wSJzfDtH1vcxlblp5XwWwOG4RXKnIhq5HfM
         S7ZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789460394; x=1790065194;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=eIty82Ymjj64Fl6mn4Z3/QHhmY1e0QRFUR4BQSE5AwY=;
        b=AKKQ72D8vlRl9vAzpI4n4VokcEyW1xI6GB6Ex/KfN3PZFV2kRk5tVMBneDMDpJFcJj
         PmfZ6UHVKtdmXDMi+NU4h1vErTDpq0oLUBqyUqRoGQ6JxOknpL647vus+yNpgtr1DQs8
         uCStdpzgD8CCHb4g0IdlhGLXG1erQFHWmWb78jsVHzQkP2QRBxZ3RBVE6iiL9GSWWNa/
         W2slhF3HGgGRAIib46wN6Snz3o6oTQeOb7u6eIw9K0vTmmYPc1ePrQaKuqkCpU3jxAAY
         BhsdjeGUwY/l0TJxxdnoau54BeTKxHbkiZQ8mdI4A8tokaFgSHwXLtPl+RdHV7eETOmk
         OZCQ==
X-Forwarded-Encrypted: i=1; AKwUvBySAJV9meXWnc76UfMbvJcRrQpLehEOJRDIoaSn/a85NxGsrN2jNqz/FgKDN6F43wexqdrbCtnjrGA=@vger.kernel.org
X-Gm-Message-State: AFuF++kCKQgjYJT1Hd6yhiDKZzx4nmp8YZB3/OIsgjpzlwW60n3+Odij
	LHbxRMgrnDRWmeFefg7e7FYY0IK+85cPMrKMma3utLwxGjGjTJ4BksAApJDtJ7aWRRSsQWACB+i
	N
X-Received: from pghd13.prod.google.com ([2002:a63:fd0d:0:b0:cc4:37f6:e897])
 (user=morbo job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6a20:12c7:b0:3d3:ae1f:d7f4
 with SMTP id adf61e73a8af0-3dd528bd7dbmr272615637.20.1789460393063; Tue, 15
 Sep 2026 01:19:53 -0700 (PDT)
Date: Tue, 15 Sep 2026 08:18:22 +0000
In-Reply-To: <20260915081910.4142719-1-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260915081910.4142719-1-morbo@google.com>
X-Mailer: git-send-email 2.55.0.1032.g73a4cd73de-goog
Message-ID: <20260915081910.4142719-6-morbo@google.com>
Subject: [PATCH 05/28] ALSA: usb-audio: Refactor usb_audio_make_longname() to
 use seq_buf
From: Bill Wendling <morbo@google.com>
To: linux-kernel@vger.kernel.org
Cc: Bill Wendling <morbo@google.com>, codemender-patching+linux@google.com, 
	Russell King <linux@armlinux.org.uk>, Huacai Chen <chenhuacai@kernel.org>, 
	WANG Xuerui <kernel@xen0n.name>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, 
	"James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>, Helge Deller <deller@gmx.de>, 
	Thomas Gleixner <tglx@kernel.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	Dave Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, 
	"H. Peter Anvin" <hpa@zytor.com>, Ian Abbott <abbotti@mev.co.uk>, 
	H Hartley Sweeten <hsweeten@visionengravers.com>, Tony Luck <tony.luck@intel.com>, 
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, Maxime Ripard <mripard@kernel.org>, 
	Thomas Zimmermann <tzimmermann@suse.de>, David Airlie <airlied@gmail.com>, Simona Vetter <simona@ffwll.ch>, 
	Matthew Brost <matthew.brost@intel.com>, 
	"=?UTF-8?q?Thomas=20Hellstr=C3=B6m?=" <thomas.hellstrom@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, 
	Dmitry Torokhov <dmitry.torokhov@gmail.com>, Matthias Schwarzott <zzam@gentoo.org>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Tony Nguyen <anthony.l.nguyen@intel.com>, 
	Przemek Kitszel <przemyslaw.kitszel@intel.com>, Andrew Lunn <andrew+netdev@lunn.ch>, 
	"David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
	Arend van Spriel <arend.vanspriel@broadcom.com>, Rob Herring <robh@kernel.org>, 
	Saravana Kannan <saravanak@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, 
	Sylwester Nawrocki <s.nawrocki@samsung.com>, Peter Griffin <peter.griffin@linaro.org>, 
	Alim Akhtar <alim.akhtar@samsung.com>, Linus Walleij <linusw@kernel.org>, 
	Anil Gurumurthy <anil.gurumurthy@qlogic.com>, 
	Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>, "Martin K. Petersen" <mkp@kernel.org>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg <martin@omnibond.com>, Kees Cook <kees@kernel.org>, 
	Jiri Pirko <jiri@resnulli.us>, Simon Horman <horms@kernel.org>, Chuck Lever <cel@kernel.org>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, "Mike Rapoport (Microsoft)" <rppt@kernel.org>, 
	Kanglong Wang <wangkanglong@loongson.cn>, Tiezhu Yang <yangtiezhu@loongson.cn>, 
	Qiang Ma <maqianga@uniontech.com>, Randy Dunlap <rdunlap@infradead.org>, 
	Pengpeng Hou <pengpeng@iscas.ac.cn>, Ard Biesheuvel <ardb@kernel.org>, Breno Leitao <leitao@debian.org>, 
	Thorsten Blum <blum@kernel.org>, Harshit Mogalapalli <harshit.m.mogalapalli@oracle.com>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Lyude Paul <lyude@redhat.com>, 
	Ashutosh Desai <ashutoshdesai993@gmail.com>, Imre Deak <imre.deak@intel.com>, 
	Dmitry Baryshkov <dmitry.baryshkov@oss.qualcomm.com>, Johan Hovold <johan@kernel.org>, 
	Johannes Berg <johannes.berg@intel.com>, 
	Miri Korenblit <miriam.rachel.korenblit@intel.com>, 
	Alexander Stein <alexander.stein@ew.tq-group.com>, 
	Cryolitia PukNgae <cryolitia@uniontech.com>, Jiaming Zhang <r772577952@gmail.com>, 
	Will Porter <mrwillporter@gmail.com>, Cen Zhang <zzzccc427@gmail.com>, 
	"=?UTF-8?q?C=C3=A1ssio=20Gabriel?=" <cassiogabrielcontato@gmail.com>, Rong Zhang <i@rong.moe>, 
	Arun Raghavan <arunr@valvesoftware.com>, linux-arm-kernel@lists.infradead.org, 
	loongarch@lists.linux.dev, linux-mips@vger.kernel.org, 
	linux-parisc@vger.kernel.org, linux-edac@vger.kernel.org, 
	dri-devel@lists.freedesktop.org, intel-xe@lists.freedesktop.org, 
	linux-input@vger.kernel.org, linux-media@vger.kernel.org, 
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org, 
	linux-wireless@vger.kernel.org, brcm80211@lists.linux.dev, 
	brcm80211-dev-list.pdl@broadcom.com, devicetree@vger.kernel.org, 
	linux-samsung-soc@vger.kernel.org, linux-gpio@vger.kernel.org, 
	linux-scsi@vger.kernel.org, linux-nfs@vger.kernel.org, 
	devel@lists.orangefs.org, linux-hardening@vger.kernel.org, 
	linux-sound@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

usb_audio_make_longname() builds card->longname incrementally from the
vendor/manufacturer name, shortname, USB device path, and USB speed using
strscpy(), strlcat(), and manual buffer offset calculations for
usb_make_path().

In preparation for removing the deprecated strlcat() API[1], refactor
usb_audio_make_longname() to use struct seq_buf to track the buffer
position and remaining space across these operations.

Link: https://github.com/KSPP/linux/issues/370 [1]
Cc: codemender-patching+linux@google.com
Assisted-by: Gemini:3.5-pro [git, make, checkpatch]
Signed-off-by: Bill Wendling <morbo@google.com>
---
Cc: Russell King <linux@armlinux.org.uk>
Cc: Huacai Chen <chenhuacai@kernel.org>
Cc: WANG Xuerui <kernel@xen0n.name>
Cc: Thomas Bogendoerfer <tsbogend@alpha.franken.de>
Cc: "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>
Cc: Helge Deller <deller@gmx.de>
Cc: Thomas Gleixner <tglx@kernel.org>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: x86@kernel.org
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ian Abbott <abbotti@mev.co.uk>
Cc: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Maarten Lankhorst <maarten.lankhorst@linux.intel.com>
Cc: Maxime Ripard <mripard@kernel.org>
Cc: Thomas Zimmermann <tzimmermann@suse.de>
Cc: David Airlie <airlied@gmail.com>
Cc: Simona Vetter <simona@ffwll.ch>
Cc: Matthew Brost <matthew.brost@intel.com>
Cc: "Thomas Hellstr=C3=B6m" <thomas.hellstrom@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
Cc: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Cc: Matthias Schwarzott <zzam@gentoo.org>
Cc: Mauro Carvalho Chehab <mchehab@kernel.org>
Cc: Tony Nguyen <anthony.l.nguyen@intel.com>
Cc: Przemek Kitszel <przemyslaw.kitszel@intel.com>
Cc: Andrew Lunn <andrew+netdev@lunn.ch>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Jakub Kicinski <kuba@kernel.org>
Cc: Paolo Abeni <pabeni@redhat.com>
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>
Cc: Rob Herring <robh@kernel.org>
Cc: Saravana Kannan <saravanak@kernel.org>
Cc: Krzysztof Kozlowski <krzk@kernel.org>
Cc: Sylwester Nawrocki <s.nawrocki@samsung.com>
Cc: Peter Griffin <peter.griffin@linaro.org>
Cc: Alim Akhtar <alim.akhtar@samsung.com>
Cc: Linus Walleij <linusw@kernel.org>
Cc: Anil Gurumurthy <anil.gurumurthy@qlogic.com>
Cc: Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>
Cc: "Martin K. Petersen" <mkp@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>
Cc: Anna Schumaker <anna@kernel.org>
Cc: Mike Marshall <hubcap@omnibond.com>
Cc: Martin Brandenburg <martin@omnibond.com>
Cc: Kees Cook <kees@kernel.org>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Simon Horman <horms@kernel.org>
Cc: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>
Cc: Olga Kornievskaia <okorniev@redhat.com>
Cc: Dai Ngo <Dai.Ngo@oracle.com>
Cc: Tom Talpey <tom@talpey.com>
Cc: Jaroslav Kysela <perex@perex.cz>
Cc: Takashi Iwai <tiwai@suse.com>
Cc: Bill Wendling <morbo@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Mike Rapoport (Microsoft)" <rppt@kernel.org>
Cc: Kanglong Wang <wangkanglong@loongson.cn>
Cc: Tiezhu Yang <yangtiezhu@loongson.cn>
Cc: Qiang Ma <maqianga@uniontech.com>
Cc: Randy Dunlap <rdunlap@infradead.org>
Cc: Pengpeng Hou <pengpeng@iscas.ac.cn>
Cc: Ard Biesheuvel <ardb@kernel.org>
Cc: Breno Leitao <leitao@debian.org>
Cc: Thorsten Blum <blum@kernel.org>
Cc: Harshit Mogalapalli <harshit.m.mogalapalli@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Lyude Paul <lyude@redhat.com>
Cc: Ashutosh Desai <ashutoshdesai993@gmail.com>
Cc: Imre Deak <imre.deak@intel.com>
Cc: Dmitry Baryshkov <dmitry.baryshkov@oss.qualcomm.com>
Cc: Johan Hovold <johan@kernel.org>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: Miri Korenblit <miriam.rachel.korenblit@intel.com>
Cc: Alexander Stein <alexander.stein@ew.tq-group.com>
Cc: Cryolitia PukNgae <cryolitia@uniontech.com>
Cc: Jiaming Zhang <r772577952@gmail.com>
Cc: Will Porter <mrwillporter@gmail.com>
Cc: Cen Zhang <zzzccc427@gmail.com>
Cc: "C=C3=A1ssio Gabriel" <cassiogabrielcontato@gmail.com>
Cc: Rong Zhang <i@rong.moe>
Cc: Arun Raghavan <arunr@valvesoftware.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
Cc: loongarch@lists.linux.dev
Cc: linux-mips@vger.kernel.org
Cc: linux-parisc@vger.kernel.org
Cc: linux-edac@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: intel-xe@lists.freedesktop.org
Cc: linux-input@vger.kernel.org
Cc: linux-media@vger.kernel.org
Cc: intel-wired-lan@lists.osuosl.org
Cc: netdev@vger.kernel.org
Cc: linux-wireless@vger.kernel.org
Cc: brcm80211@lists.linux.dev
Cc: brcm80211-dev-list.pdl@broadcom.com
Cc: devicetree@vger.kernel.org
Cc: linux-samsung-soc@vger.kernel.org
Cc: linux-gpio@vger.kernel.org
Cc: linux-scsi@vger.kernel.org
Cc: linux-nfs@vger.kernel.org
Cc: devel@lists.orangefs.org
Cc: linux-hardening@vger.kernel.org
Cc: linux-sound@vger.kernel.org
---
 sound/usb/card.c | 58 ++++++++++++++++++++++++++++++++----------------
 1 file changed, 39 insertions(+), 19 deletions(-)

diff --git a/sound/usb/card.c b/sound/usb/card.c
index 9307da95efbe..bdca8085fca6 100644
--- a/sound/usb/card.c
+++ b/sound/usb/card.c
@@ -25,6 +25,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/string.h>
+#include <linux/seq_buf.h>
 #include <linux/ctype.h>
 #include <linux/usb.h>
 #include <linux/moduleparam.h>
@@ -651,7 +652,9 @@ static void usb_audio_make_longname(struct usb_device *=
dev,
 	struct snd_card *card =3D chip->card;
 	const struct usb_audio_device_name *preset;
 	const char *s =3D NULL;
-	int len;
+	struct seq_buf sb;
+	char *buf;
+	size_t size;
=20
 	preset =3D lookup_device_name(chip->usb_id);
=20
@@ -667,44 +670,61 @@ static void usb_audio_make_longname(struct usb_device=
 *dev,
 		s =3D preset->vendor_name;
 	else if (quirk && quirk->vendor_name)
 		s =3D quirk->vendor_name;
-	*card->longname =3D 0;
-	if (s && *s)
-		strscpy(card->longname, s);
-	else if (dev->manufacturer && *dev->manufacturer)
-		strscpy(card->longname, dev->manufacturer);
=20
-	if (*card->longname) {
-		strim(card->longname);
-		if (*card->longname)
-			strlcat(card->longname, " ", sizeof(card->longname));
+	seq_buf_init(&sb, card->longname, sizeof(card->longname));
+
+	if (s && *s)
+		seq_buf_puts(&sb, s);
+	else if (dev->manufacturer && *dev->manufacturer)
+		seq_buf_puts(&sb, dev->manufacturer);
+
+	if (seq_buf_used(&sb)) {
+		char *trimmed;
+
+		seq_buf_str(&sb);
+		trimmed =3D strim(card->longname);
+		if (trimmed !=3D card->longname)
+			memmove(card->longname, trimmed, strlen(trimmed) + 1);
+		sb.len =3D strlen(card->longname);
+		if (sb.len)
+			seq_buf_putc(&sb, ' ');
 	}
=20
-	strlcat(card->longname, card->shortname, sizeof(card->longname));
+	seq_buf_puts(&sb, card->shortname);
=20
-	len =3D strlcat(card->longname, " at ", sizeof(card->longname));
+	seq_buf_puts(&sb, " at ");
=20
-	if (len < sizeof(card->longname))
-		usb_make_path(dev, card->longname + len, sizeof(card->longname) - len);
+	size =3D seq_buf_get_buf(&sb, &buf);
+	if (size > 0) {
+		int path_len =3D usb_make_path(dev, buf, size);
+
+		if (path_len >=3D 0)
+			seq_buf_commit(&sb, path_len);
+		else
+			seq_buf_set_overflow(&sb);
+	}
=20
 	switch (snd_usb_get_speed(dev)) {
 	case USB_SPEED_LOW:
-		strlcat(card->longname, ", low speed", sizeof(card->longname));
+		seq_buf_puts(&sb, ", low speed");
 		break;
 	case USB_SPEED_FULL:
-		strlcat(card->longname, ", full speed", sizeof(card->longname));
+		seq_buf_puts(&sb, ", full speed");
 		break;
 	case USB_SPEED_HIGH:
-		strlcat(card->longname, ", high speed", sizeof(card->longname));
+		seq_buf_puts(&sb, ", high speed");
 		break;
 	case USB_SPEED_SUPER:
-		strlcat(card->longname, ", super speed", sizeof(card->longname));
+		seq_buf_puts(&sb, ", super speed");
 		break;
 	case USB_SPEED_SUPER_PLUS:
-		strlcat(card->longname, ", super speed plus", sizeof(card->longname));
+		seq_buf_puts(&sb, ", super speed plus");
 		break;
 	default:
 		break;
 	}
+
+	seq_buf_str(&sb);
 }
=20
 static void snd_usb_init_quirk_flags(int idx, struct snd_usb_audio *chip)
--=20
2.55.0.1032.g73a4cd73de-goog

