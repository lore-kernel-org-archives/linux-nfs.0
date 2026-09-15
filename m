Received: from mail-oa1-f70.google.com (mail-oa1-f70.google.com [209.85.160.70])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EEA754825D6
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 08:26:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.70
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789460787; cv=none; b=Npu9ixvgv+LnEO0MdSNwWv85R52zfD23BIp1Id0/oN20SeD3/Anm1Z2KkXJt4uxJSBEw78CPFkIoBt+Q2p+8oTiMrndd9MrC3/wcrk5+LcHg0cPeJ7Xi5KBrgtK4x+0gHqfHAijyQcGSx9C4nu9bOBA+FCzX8q54aFjgtb7ZYIM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789460787; c=relaxed/simple;
	bh=s/FLNJ19YZGvt5oZ8eTe1yZo+b1FTWb/0ix0hrTXlNc=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=gnXy6uF/FHa2McPzgJSlv/Wqu4PAxtGi/vhwv8xyNJRZnSMVUwuV7iQyWUW/PPPKNcCd7Ibo3Yt0h4tYpUVasHlLrbjpnAq0WNdrPg86/hLeeDEAVtjOYbN7wagArH6+lqLrhDP+UXbtdeofTT32Wj8MnzbuRcUtd/YABZrRKrU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--morbo.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=P9ppMHFy; arc=none smtp.client-ip=209.85.160.70
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--morbo.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="P9ppMHFy"
Received: by mail-oa1-f70.google.com with SMTP id 586e51a60fabf-45eb9967696so1159187fac.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 01:26:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1789460784; x=1790065584; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=TmKdBXO38kbe6W228p+vBZ76A7D+nQJddOBfd0uRZ54=;
        b=P9ppMHFyCWR+a1WeUY8F1BW7i1dvf7hI+CJweQvDxKlkeen6UyS1MOONxTpeI+P2xd
         BcCSMkmpIwKqYI79DuhiQGUNBDBAmk9nETpgAGVR9GYylVvsntbPJOXDXzKQ55aWt1Vo
         ADAmRiamSZznfgaRSG+eKn8jo/5uneD1oGdiP6m0+8fwjTCcXgjHWNY0m3XbKCvynr/q
         fm+LBtCb0PmL+Xj/ho6ABYTRaClX5luZE55sUYIklda8rSU+9KE2YzJu/sr7/EjY8P1L
         5fNCJdsJWTBgDH1kEXr7bJGo/XbnQtDYs1YM6RMWAbE9Cq+kWNELoecxRSSkVJniciCS
         VDyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789460784; x=1790065584;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=TmKdBXO38kbe6W228p+vBZ76A7D+nQJddOBfd0uRZ54=;
        b=PX4q5vT3woR04SHrVX7xCfsAl2L+/3IQVUEjPAF+uf6WSuvpqu3+KNUPu2Ivta/lUt
         5eyzwDAQbgtK99GKYiGbDFIHNu8TYsaYyHhrS/0j2JxYsvJw0nMPgUiJDah1ha/67Jtt
         f3HG0OjHEhWZ0PHUCUtD6AQ6EprsrQ8OEKMvKHtHLzYJZdcWMvrAMrzznnt4wmMApf2z
         THjg+otMKqYYdMrFu9YhFdu7/Lb9bhsfg4kfI+26HMm0B00357vLbgQgl+2vKyAukFnO
         egvWXcy+/wosrwuTHWXZ1+zfjw1BUuLprI1Mdl6QVvx3amM6IXUcTkCoZEZfXqH1H73u
         muKQ==
X-Forwarded-Encrypted: i=1; AKwUvBzEvyks4aLDe9TfzkWUezrw/dbb8AbKXrK7J98Hc4j4KsDuh61z7gq+K12TL8kmzmAvUFlphOZ1YTs=@vger.kernel.org
X-Gm-Message-State: AFuF++kduDETigBjPb66SCrceB8AMX84daunY78qnkqjDg+9VI5q4dHm
	Ctgre8CywmbfhlBfqEqTBF9Yl2cIzEDFkznYmwHuA4ZGbIoLXUIJ3jwO8UUZbJcdptoy6ptp3du
	z
X-Received: from plw16.prod.google.com ([2002:a17:903:45d0:b0:2dd:203e:7d7f])
 (user=morbo job=prod-delivery.src-stubby-dispatcher) by 2002:a17:902:e544:b0:2d8:d4cf:fe49
 with SMTP id d9443c01a7336-2dd7654538dmr37587935ad.15.1789460410166; Tue, 15
 Sep 2026 01:20:10 -0700 (PDT)
Date: Tue, 15 Sep 2026 08:18:35 +0000
In-Reply-To: <20260915081910.4142719-1-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260915081910.4142719-1-morbo@google.com>
X-Mailer: git-send-email 2.55.0.1032.g73a4cd73de-goog
Message-ID: <20260915081910.4142719-19-morbo@google.com>
Subject: [PATCH 18/28] LoongArch: Refactor bootcmdline_init() to use seq_buf
 instead of strlcat()
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

bootcmdline_init() uses multiple strlcat() calls to append
init_command_line or CONFIG_CMDLINE to boot_command_line.

In preparation for removing the deprecated strlcat() API[1], initialize a
struct seq_buf with the existing contents of boot_command_line and use
seq_buf_puts() to append the command line fragments.

Link: https://github.com/KSPP/linux/issues/370 [1]
Cc: codemender-patching+linux@google.com
Assisted-by: CoPilot:1.0 [shell_command_run, editor_update_file, make_kerne=
l_build_single_file]
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
 arch/loongarch/kernel/setup.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/arch/loongarch/kernel/setup.c b/arch/loongarch/kernel/setup.c
index 6fa4a22a58fd..826396f141b9 100644
--- a/arch/loongarch/kernel/setup.c
+++ b/arch/loongarch/kernel/setup.c
@@ -33,6 +33,7 @@
 #include <linux/of_address.h>
 #include <linux/suspend.h>
 #include <linux/swiotlb.h>
+#include <linux/seq_buf.h>
=20
 #include <asm/addrspace.h>
 #include <asm/alternative.h>
@@ -305,6 +306,8 @@ static void __init fdt_setup(void)
=20
 static void __init bootcmdline_init(char **cmdline_p)
 {
+	struct seq_buf s;
+
 	/*
 	 * If CONFIG_CMDLINE_FORCE is enabled then initializing the command line
 	 * is trivial - we simply use the built-in command line unconditionally &
@@ -315,6 +318,11 @@ static void __init bootcmdline_init(char **cmdline_p)
 		goto out;
 	}
=20
+	/* Initialize seq_buf pointing to boot_command_line */
+	s.buffer =3D boot_command_line;
+	s.size =3D COMMAND_LINE_SIZE;
+	s.len =3D strlen(boot_command_line);
+
 #ifdef CONFIG_OF_FLATTREE
 	/*
 	 * If CONFIG_CMDLINE_BOOTLOADER is enabled and we are in FDT-based system=
,
@@ -323,11 +331,11 @@ static void __init bootcmdline_init(char **cmdline_p)
 	 * to boot_command_line.
 	 */
 	if (initial_boot_params) {
-		if (boot_command_line[0])
-			strlcat(boot_command_line, " ", COMMAND_LINE_SIZE);
+		if (s.len)
+			seq_buf_puts(&s, " ");
=20
-		if (!strstr(boot_command_line, init_command_line))
-			strlcat(boot_command_line, init_command_line, COMMAND_LINE_SIZE);
+		if (!strstr(s.buffer, init_command_line))
+			seq_buf_puts(&s, init_command_line);
=20
 		goto out;
 	}
@@ -338,14 +346,14 @@ static void __init bootcmdline_init(char **cmdline_p)
 	 * CONFIG_CMDLINE_EXTEND is enabled.
 	 */
 	if (IS_ENABLED(CONFIG_CMDLINE_EXTEND) && CONFIG_CMDLINE[0]) {
-		strlcat(boot_command_line, " ", COMMAND_LINE_SIZE);
-		strlcat(boot_command_line, CONFIG_CMDLINE, COMMAND_LINE_SIZE);
+		seq_buf_puts(&s, " ");
+		seq_buf_puts(&s, CONFIG_CMDLINE);
 	}
=20
 	/*
 	 * Use built-in command line if the bootloader command line is empty.
 	 */
-	if (IS_ENABLED(CONFIG_CMDLINE_BOOTLOADER) && !boot_command_line[0])
+	if (IS_ENABLED(CONFIG_CMDLINE_BOOTLOADER) && !s.len)
 		strscpy(boot_command_line, CONFIG_CMDLINE, COMMAND_LINE_SIZE);
=20
 out:
--=20
2.55.0.1032.g73a4cd73de-goog

