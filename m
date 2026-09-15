Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 06B6447532F
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 08:20:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.200
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789460479; cv=none; b=SQMiueLzUy8Ds6/KeQi/u1D5vzsI1QcR+iorKJs9jIaBr2wqUKMono0LNX0U0ptgp+I63HR2i66RIbX8J9F2nR1t4Zy5hTXZ5Ou9AbmnFjG4tHZ0XtK2Z2scwHuzlo5HGeU8WaWOSauCsfOdlhTOs686xJKmndGwDrsdvNPXOSU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789460479; c=relaxed/simple;
	bh=F9i32u7X67i3rjTFL62V2TeKyR+ixZjqL6I2EccGRRA=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=Fnn1syqx2NOfV/L2Z2wLQOEB5Q47Bnt/A4nE/lD8fTHw8YEbUB3ziNGFJlvozrcZdIWpFD34FfPtoKjSQ0+Z8xM0Au85RB3Jap6rAaupHcYKU03oagPLrWh3+oIotmmZnFYksw/BguYGGzTz1gSrGzd+wFV8KSIdE5hSYAY1zUk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--morbo.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=UbJ1cATg; arc=none smtp.client-ip=209.85.214.200
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--morbo.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UbJ1cATg"
Received: by mail-pl1-f200.google.com with SMTP id d9443c01a7336-2d55d8cd938so73491125ad.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 01:20:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1789460417; x=1790065217; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=CSHzy5Fr+v+g78gtgBhpLtU/5VBe17dtS9vTkuvViHg=;
        b=UbJ1cATgtClWEITC/K2FRs0yA+J6QuOAQNYBjRfMOKcvsi26Iw0YJycYGDVgXnZrWu
         OkknVjnQ8i5cwzTKofsD1XegSELSlQQWyGmBy+oTi8Rz6f+TqDoZ2wOvaqx1nNxaQq9T
         6d32McB/8xVv6H+WPMKqesWTkJJ4jN9Fxthcfq0/8FuWBuJYGJGQCi+wKu5lEWR7zV/t
         fOaj7SjaCurcjs6XXGANs8d147zli1iFTHrIgyTVvMzA0OEHm9Rj0L5A6lzd+IclErro
         a5b9aL/MDPF57KGC99VttDBSXAU1ClN53SqyK+T3AFsds6CbkR0S7OKYOgJcb3XnGCg8
         AMRw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789460417; x=1790065217;
        h=content-transfer-encoding:content-type:cc:to:from:subject
         :message-id:references:mime-version:in-reply-to:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=CSHzy5Fr+v+g78gtgBhpLtU/5VBe17dtS9vTkuvViHg=;
        b=NNFclq/VAuPlbcRNJYY579MldioB/QoFXqWWbLITnrxrEh1JfvU5amHfgIBmfhgTMG
         GPq2k1KtChhW2I6cNUSfCr+PnGPlnILNVeitF+7x5AR6MQ9OJB8HZVsW8tFvt36FIGxq
         pqg4oFa7MaKVUXZ6hdJF5K4fLqykwS23t3y3jw14xgLVBAL+XcuOIqbjk1fICcKbEs2k
         T41YdwNYNI09OUqZVC7tmsRo9eE9ZNgaMrJZ16bSLOm2NMuuPA5iz7RLe7FqfF1zYFkG
         43yYW0Eah3mlB9KsEDE0g3X32xvgbt39R7Oah4NvCAWaAwIt2Chx80duKSA22C3CaJMs
         kndw==
X-Forwarded-Encrypted: i=1; AKwUvBzAdthHmZGWSMA2S3nIy4pl1Q/LC3tq5yK/ggFArpCzlCXKQAAgJoVVO8Y7lo0zr5NkhHJE3gHt9hw=@vger.kernel.org
X-Gm-Message-State: AFuF++n7H0ibDXiInPLhPigeWjN23Rw1yPAvI0HZ1EPboeWWNERxbvgu
	ur7HJrV4L20MNArqIGvYjb1nqeaGxdgz3pj6y/DllQeqK78j2hFaevo/nEgpL3criGKJtImGYY7
	e
X-Received: from plky9.prod.google.com ([2002:a17:902:7009:b0:2dd:3c92:b0a2])
 (user=morbo job=prod-delivery.src-stubby-dispatcher) by 2002:a17:903:8c5:b0:2c6:90ec:f601
 with SMTP id d9443c01a7336-2dd6c5f3422mr125997365ad.8.1789460416594; Tue, 15
 Sep 2026 01:20:16 -0700 (PDT)
Date: Tue, 15 Sep 2026 08:18:42 +0000
In-Reply-To: <20260915081910.4142719-1-morbo@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260915081910.4142719-1-morbo@google.com>
X-Mailer: git-send-email 2.55.0.1032.g73a4cd73de-goog
Message-ID: <20260915081910.4142719-26-morbo@google.com>
Subject: [PATCH 25/28] EDAC/thunderx: Replace strlcat() with seq_buf
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

The threaded ISR handlers (thunderx_ocx_com_threaded_isr(),
thunderx_ocx_lnk_threaded_isr(), and thunderx_l2c_threaded_isr()) build
multi-line error reports by formatting register details into a scratch
buffer and appending them to "msg" with strlcat().

In preparation for removing the deprecated strlcat() API[1], refactor the
ISR handlers to construct error messages using struct seq_buf.

Additionally, fix two bugs in decode_register(): initialize "str[0] =3D '\0=
'"
so callers do not append stale buffer contents when no error bits match,
and stop iterating if snprintf() truncates the buffer to avoid
underflowing the remaining "size" counter.

Link: https://github.com/KSPP/linux/issues/370 [1]
Cc: codemender-patching+linux@google.com
Assisted-by: AI:Claude-3-5-Sonnet [editor_update_file, shell_command_run]
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
 drivers/edac/thunderx_edac.c | 64 ++++++++++++++++++++++--------------
 1 file changed, 39 insertions(+), 25 deletions(-)

diff --git a/drivers/edac/thunderx_edac.c b/drivers/edac/thunderx_edac.c
index e7c335ca0c36..4e3781815b6d 100644
--- a/drivers/edac/thunderx_edac.c
+++ b/drivers/edac/thunderx_edac.c
@@ -20,6 +20,7 @@
 #include <linux/atomic.h>
 #include <linux/bitfield.h>
 #include <linux/circ_buf.h>
+#include <linux/seq_buf.h>
=20
 #include <asm/page.h>
=20
@@ -47,12 +48,17 @@ static void decode_register(char *str, size_t size,
 {
 	int ret =3D 0;
=20
+	if (size > 0)
+		str[0] =3D '\0';
+
 	while (descr->type && descr->mask && descr->descr) {
 		if (reg & descr->mask) {
 			ret =3D snprintf(str, size, "\n\t%s, %s",
 				       descr->type =3D=3D ERR_CORRECTED ?
 					 "Corrected" : "Uncorrected",
 				       descr->descr);
+			if (ret < 0 || ret >=3D size)
+				break;
 			str +=3D ret;
 			size -=3D ret;
 		}
@@ -1115,35 +1121,37 @@ static irqreturn_t thunderx_ocx_com_threaded_isr(in=
t irq, void *irq_id)
=20
 	while (CIRC_CNT(ocx->com_ring_head, ocx->com_ring_tail,
 			ARRAY_SIZE(ocx->com_err_ctx))) {
+		struct seq_buf s;
+
 		tail =3D ring_pos(ocx->com_ring_tail,
 				ARRAY_SIZE(ocx->com_err_ctx));
 		ctx =3D &ocx->com_err_ctx[tail];
=20
-		snprintf(msg, OCX_MESSAGE_SIZE, "%s: OCX_COM_INT: %016llx",
-			ocx->edac_dev->ctl_name, ctx->reg_com_int);
+		seq_buf_init(&s, msg, OCX_MESSAGE_SIZE);
+
+		seq_buf_printf(&s, "%s: OCX_COM_INT: %016llx",
+			       ocx->edac_dev->ctl_name, ctx->reg_com_int);
=20
 		decode_register(other, OCX_OTHER_SIZE,
 				ocx_com_errors, ctx->reg_com_int);
=20
-		strlcat(msg, other, OCX_MESSAGE_SIZE);
+		seq_buf_puts(&s, other);
=20
 		for (lane =3D 0; lane < OCX_RX_LANES; lane++)
 			if (ctx->reg_com_int & BIT(lane)) {
-				snprintf(other, OCX_OTHER_SIZE,
-					 "\n\tOCX_LNE_INT[%02d]: %016llx OCX_LNE_STAT11[%02d]: %016llx",
-					 lane, ctx->reg_lane_int[lane],
-					 lane, ctx->reg_lane_stat11[lane]);
-
-				strlcat(msg, other, OCX_MESSAGE_SIZE);
+				seq_buf_printf(&s,
+					       "\n\tOCX_LNE_INT[%02d]: %016llx OCX_LNE_STAT11[%02d]: %016llx"=
,
+					       lane, ctx->reg_lane_int[lane],
+					       lane, ctx->reg_lane_stat11[lane]);
=20
 				decode_register(other, OCX_OTHER_SIZE,
 						ocx_lane_errors,
 						ctx->reg_lane_int[lane]);
-				strlcat(msg, other, OCX_MESSAGE_SIZE);
+				seq_buf_puts(&s, other);
 			}
=20
 		if (ctx->reg_com_int & OCX_COM_INT_CE)
-			edac_device_handle_ce(ocx->edac_dev, 0, 0, msg);
+			edac_device_handle_ce(ocx->edac_dev, 0, 0, seq_buf_str(&s));
=20
 		ocx->com_ring_tail++;
 	}
@@ -1196,25 +1204,28 @@ static irqreturn_t thunderx_ocx_lnk_threaded_isr(in=
t irq, void *irq_id)
=20
 	while (CIRC_CNT(ocx->link_ring_head, ocx->link_ring_tail,
 			ARRAY_SIZE(ocx->link_err_ctx))) {
+		struct seq_buf s;
+
 		tail =3D ring_pos(ocx->link_ring_head,
 				ARRAY_SIZE(ocx->link_err_ctx));
=20
 		ctx =3D &ocx->link_err_ctx[tail];
=20
-		snprintf(msg, OCX_MESSAGE_SIZE,
-			 "%s: OCX_COM_LINK_INT[%d]: %016llx",
-			 ocx->edac_dev->ctl_name,
-			 ctx->link, ctx->reg_com_link_int);
+		seq_buf_init(&s, msg, OCX_MESSAGE_SIZE);
+
+		seq_buf_printf(&s, "%s: OCX_COM_LINK_INT[%d]: %016llx",
+			       ocx->edac_dev->ctl_name,
+			       ctx->link, ctx->reg_com_link_int);
=20
 		decode_register(other, OCX_OTHER_SIZE,
 				ocx_com_link_errors, ctx->reg_com_link_int);
=20
-		strlcat(msg, other, OCX_MESSAGE_SIZE);
+		seq_buf_puts(&s, other);
=20
 		if (ctx->reg_com_link_int & OCX_COM_LINK_INT_UE)
-			edac_device_handle_ue(ocx->edac_dev, 0, 0, msg);
+			edac_device_handle_ue(ocx->edac_dev, 0, 0, seq_buf_str(&s));
 		else if (ctx->reg_com_link_int & OCX_COM_LINK_INT_CE)
-			edac_device_handle_ce(ocx->edac_dev, 0, 0, msg);
+			edac_device_handle_ce(ocx->edac_dev, 0, 0, seq_buf_str(&s));
=20
 		ocx->link_ring_tail++;
 	}
@@ -1880,22 +1891,25 @@ static irqreturn_t thunderx_l2c_threaded_isr(int ir=
q, void *irq_id)
=20
 	while (CIRC_CNT(l2c->ring_head, l2c->ring_tail,
 			ARRAY_SIZE(l2c->err_ctx))) {
+		struct seq_buf s;
+
 		tail =3D ring_pos(l2c->ring_tail, ARRAY_SIZE(l2c->err_ctx));
 		ctx =3D &l2c->err_ctx[tail];
=20
-		snprintf(msg, L2C_MESSAGE_SIZE,
-			 "%s: %s: %016llx, %s: %016llx",
-			 l2c->edac_dev->ctl_name, reg_int_name, ctx->reg_int,
-			 ctx->reg_ext_name, ctx->reg_ext);
+		seq_buf_init(&s, msg, L2C_MESSAGE_SIZE);
+
+		seq_buf_printf(&s, "%s: %s: %016llx, %s: %016llx",
+			       l2c->edac_dev->ctl_name, reg_int_name, ctx->reg_int,
+			       ctx->reg_ext_name, ctx->reg_ext);
=20
 		decode_register(other, L2C_OTHER_SIZE, l2_errors, ctx->reg_int);
=20
-		strlcat(msg, other, L2C_MESSAGE_SIZE);
+		seq_buf_puts(&s, other);
=20
 		if (ctx->reg_int & mask_ue)
-			edac_device_handle_ue(l2c->edac_dev, 0, 0, msg);
+			edac_device_handle_ue(l2c->edac_dev, 0, 0, seq_buf_str(&s));
 		else if (ctx->reg_int & mask_ce)
-			edac_device_handle_ce(l2c->edac_dev, 0, 0, msg);
+			edac_device_handle_ce(l2c->edac_dev, 0, 0, seq_buf_str(&s));
=20
 		l2c->ring_tail++;
 	}
--=20
2.55.0.1032.g73a4cd73de-goog

