Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D484C4772B5
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 08:27:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.72
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789460880; cv=none; b=bAgEuhZAEFPFkSgnBvdDMnCUze+eGKQbOQ/h8eA0uD8Y+fsB2aT2tBZMVHQ7lc6WbJP7eD1310iGkuyilVlIoCEvwlMiBdfoI2bpeRF4391+O21KazcZinhnGwqnY9/OpAk1PC09THSuaDPRYhd/Bow43zTcxB9J7Xprsvhio9k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789460880; c=relaxed/simple;
	bh=Te8HD9YkwxCOhstie9EUJ32KLA4oNHtDIGXeNIM9YkI=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=kOKKgeHiO4KEBVsGLxYHBQdf7aH65thlLYvyQeIn8hphYW/6Avjy3VOdzifidKKG03LH3BfO4kEY8Xj0YJySHFnF9lG3ynIhiiU/jO5zyMlzvrCWBedN9et1P7yBlVQQP1MYYMqaTVqzDlsHbyz2PXBADBD1KGlcVL5Lue1pCb8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--morbo.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=qJA0PiAg; arc=none smtp.client-ip=209.85.210.72
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--morbo.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qJA0PiAg"
Received: by mail-ot1-f72.google.com with SMTP id 46e09a7af769-7f4e0b45e4bso5216850a34.2
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 01:27:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1789460878; x=1790065678; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=aUeRHnlHuLyd8Os/OfUYHyanuI/6gSGpcAdXKzgjG1A=;
        b=qJA0PiAgW3+IIHQTPKHJBcY3EQKuV0smgPG3Ws0ecQ6lgBWuhmcrD2kCT+l9sP6LX5
         o2Piiy2aBXPQmIVoWdsqpzTCWCyfEiLtjq7ygfWfwHh+NyWYzsqOyjAa3O01X+vgDsfD
         Y+awwizpJhPsDpTvndGFTaChlndQyw63wnvquwxaNSr57lUYSwH5SkIjjE20h9ElNzLa
         jVxwL1w2Udl2R8QZWsV67wgRR0/T7o+qmTZo097qbEVLM2nhgEfCCRB5G8M9sdseqy4V
         rTStB+d+qtszXBtrfcE4LScfDhvAuUg4itbMY9j62CyqlccoVqYq3/qXmfCdjKgWAqf4
         OSCQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789460878; x=1790065678;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=aUeRHnlHuLyd8Os/OfUYHyanuI/6gSGpcAdXKzgjG1A=;
        b=YgXdpMIcOOXfSow1I+1RaZx2lDVGvW2jK3N/UeOu93qcTMwyUs6WcuJMGUg7TObpa2
         Psp0P6fGyVaciysR7vnoxzJ3qeSyZKcJDQbsNOi57WVDuY8OE2HVVAwJfgsou5j5dCOe
         IvwW8uIp/X4BD7WFPfvnYFmvBcKQF+7MTkMYHoZEb4vEzQC6QQV9zEKi3PiNZDPpvctw
         rv+SoFIklZfOIuGq607kKXGudzulThZyWoKLf38I5zrLbfay3N7amKhrgdpoHJkK2GDT
         Oh8k6TiP5UhTqZIEsagVvJhf+UnOxAgP+cKuUkbnl/p7Z2QQ9bheOvytvrPM0oYfTxOI
         wlDw==
X-Forwarded-Encrypted: i=1; AKwUvBw/rJzOiZ13e3YIOuMjy4nXwppAZHst4Z6YuCPGYAn+bee7O1+cfxcyimk9StLqygK6wySbkww6LOI=@vger.kernel.org
X-Gm-Message-State: AFuF++m3C2rSP9OdckL8iidmEHSvooVuQgIWR/U6AF4WqXiXZoV5n8dU
	YKdNsYKsQ8hFRjOhSsNOUt7F9spcxiRwIcdPGNxuNc8OoP/auj9Z/FMD2Q77fep7Zyp55tHNato
	P
X-Received: from plbmz16.prod.google.com ([2002:a17:903:3510:b0:2dd:2adc:aa80])
 (user=morbo job=prod-delivery.src-stubby-dispatcher) by 2002:a17:903:a8b:b0:2d9:26b3:547
 with SMTP id d9443c01a7336-2dd83882243mr420135ad.20.1789460414438; Tue, 15
 Sep 2026 01:20:14 -0700 (PDT)
Date: Tue, 15 Sep 2026 08:18:40 +0000
In-Reply-To: <20260915081910.4142719-1-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260915081910.4142719-1-morbo@google.com>
X-Mailer: git-send-email 2.55.0.1032.g73a4cd73de-goog
Message-ID: <20260915081910.4142719-24-morbo@google.com>
Subject: [PATCH 23/28] Input: synaptics_usb - use seq_buf and snprintf() for
 name and phys
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

synusb_probe() constructs the device name and physical path using a mix of
strscpy(), strlcat(), and snprintf().

In preparation for removing the deprecated strlcat() API[1], use struct
seq_buf to incrementally build synusb->name, and format synusb->phys with
snprintf() after generating the USB path.

Link: https://github.com/KSPP/linux/issues/370 [1]
Cc: codemender-patching+linux@google.com
Assisted-by: Gemini:1.5-Pro-002 [editor_update_file, make_kernel_build_sing=
le_file, test_runner_run_kunit_test]
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
 drivers/input/mouse/synaptics_usb.c | 29 +++++++++++++++++------------
 1 file changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/input/mouse/synaptics_usb.c b/drivers/input/mouse/syna=
ptics_usb.c
index 880a0c79148c..d13d2d6202ee 100644
--- a/drivers/input/mouse/synaptics_usb.c
+++ b/drivers/input/mouse/synaptics_usb.c
@@ -41,6 +41,7 @@
 #include <linux/usb.h>
 #include <linux/input.h>
 #include <linux/usb/input.h>
+#include <linux/seq_buf.h>
=20
 #define USB_VENDOR_ID_SYNAPTICS	0x06cb
 #define USB_DEVICE_ID_SYNAPTICS_TP	0x0001	/* Synaptics USB TouchPad */
@@ -278,6 +279,8 @@ static int synusb_probe(struct usb_interface *intf,
 	struct input_dev *input_dev;
 	unsigned int intf_num =3D intf->cur_altsetting->desc.bInterfaceNumber;
 	unsigned int altsetting =3D min(intf->num_altsetting, 1U);
+	struct seq_buf s;
+	char path[64];
 	int error;
=20
 	error =3D usb_set_interface(udev, intf_num, altsetting);
@@ -334,27 +337,29 @@ static int synusb_probe(struct usb_interface *intf,
 			 ep->bInterval);
 	synusb->urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MAP;
=20
+	seq_buf_init(&s, synusb->name, sizeof(synusb->name));
+
 	if (udev->manufacturer)
-		strscpy(synusb->name, udev->manufacturer,
-			sizeof(synusb->name));
+		seq_buf_puts(&s, udev->manufacturer);
=20
 	if (udev->product) {
 		if (udev->manufacturer)
-			strlcat(synusb->name, " ", sizeof(synusb->name));
-		strlcat(synusb->name, udev->product, sizeof(synusb->name));
+			seq_buf_puts(&s, " ");
+		seq_buf_puts(&s, udev->product);
 	}
=20
-	if (!strlen(synusb->name))
-		snprintf(synusb->name, sizeof(synusb->name),
-			 "USB Synaptics Device %04x:%04x",
-			 le16_to_cpu(udev->descriptor.idVendor),
-			 le16_to_cpu(udev->descriptor.idProduct));
+	if (!seq_buf_used(&s))
+		seq_buf_printf(&s, "USB Synaptics Device %04x:%04x",
+			       le16_to_cpu(udev->descriptor.idVendor),
+			       le16_to_cpu(udev->descriptor.idProduct));
=20
 	if (synusb->flags & SYNUSB_STICK)
-		strlcat(synusb->name, " (Stick)", sizeof(synusb->name));
+		seq_buf_puts(&s, " (Stick)");
=20
-	usb_make_path(udev, synusb->phys, sizeof(synusb->phys));
-	strlcat(synusb->phys, "/input0", sizeof(synusb->phys));
+	seq_buf_str(&s);
+
+	usb_make_path(udev, path, sizeof(path));
+	snprintf(synusb->phys, sizeof(synusb->phys), "%s/input0", path);
=20
 	input_dev->name =3D synusb->name;
 	input_dev->phys =3D synusb->phys;
--=20
2.55.0.1032.g73a4cd73de-goog

