Return-Path: <SRS0=ZVvz=NR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37FD0C32789
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 07:53:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F28D22085B
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 07:53:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gonf+HP1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F28D22085B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729272AbeKFRRj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Nov 2018 12:17:39 -0500
Received: from mail-vs1-f66.google.com ([209.85.217.66]:43221 "EHLO
        mail-vs1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729241AbeKFRRi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Nov 2018 12:17:38 -0500
Received: by mail-vs1-f66.google.com with SMTP id x1so401290vsc.10
        for <linux-nfs@vger.kernel.org>; Mon, 05 Nov 2018 23:53:41 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:date:from:to:subject:mime-version:content-disposition;
        bh=Ks/qF2bhU0LX3N10K5y/ZtuZQbOsyfs3YEL8uHVRrSU=;
        b=gonf+HP1B8UM7s6Vlk+8sunMPFCirPL5046x0hIk/jmznNGUucdKxlmHiYZlAA23BV
         vK7MIJKFQtE+w+t031xO/YG+HvW4RnDgBjAjiQII02UlyrA2ici0j6grayfirynpAHlF
         ATprcHRMbQ+lJq/oKXKQD8gg++XKQdbYbycjVtBw5RAcEKd5JhLnThXSTSZTw9d1vzhJ
         WBGrbEBi6VDCEimNCOvfYTpenTThHbZuqvs5us31RdI/hk12cUjyKfxI78odj60xowl8
         Xn94RJxgfTo4kjn9WAV80fupd41XpRAeXyly+sNnrQkAs1qm4GSt5NWDN5SwAG9EhYUA
         pX7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:date:from:to:subject:mime-version
         :content-disposition;
        bh=Ks/qF2bhU0LX3N10K5y/ZtuZQbOsyfs3YEL8uHVRrSU=;
        b=GRbz1UDQOx8cPUA0mAlxZctTzg4XFB6kDnN4U0tuU8cO32PNgtjl9c9+rlQIeAPq0o
         +9bA2kRvoz9zDjkMdJRYhsa94YQe2alwHSxh1Y1k0f+DP2/WEtjxbaSaYUA9G8N/7Qr3
         wGVe7CmbzSefZhb97H1u5S06BPI3V69p7+/hnryS42PKL65s0eLBKwJhF3H40FZjWyig
         jQgkzgD3jKbthpyAz8Z1AT0djE/+OpPgBI7vgLyAXrcKziIaIg5bRudO2aA04+1RJySp
         PBX1me2HKhhfrbFD4HFnfZtyePRU7gxYlaoh8f08SpTbN/dxHWeuTZSJuuFUAGIjTlaA
         8dLg==
X-Gm-Message-State: AGRZ1gKStc6gMIH55X3dOQ+9RnQiIyuDGzg18ZGSalsGBJCxnJLIKKLi
        Q/JxSVCITqErGo3DUfi0nABNh3cs
X-Google-Smtp-Source: AJdET5eb/UESB8tnoWAS7qIOdFzOWNvh5IBWKuzGNkQTWxbXVb+ctUxnB/Xtpzi2tvOYHWVrmxER9g==
X-Received: by 2002:a67:1383:: with SMTP id 125mr9339939vst.31.1541490820845;
        Mon, 05 Nov 2018 23:53:40 -0800 (PST)
Received: from localhost ([207.246.116.136])
        by smtp.gmail.com with ESMTPSA id l21sm8087193vke.9.2018.11.05.23.53.37
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 23:53:40 -0800 (PST)
Message-ID: <5be14884.1c69fb81.a6fae.51d4@mx.google.com>
Date:   Mon, 05 Nov 2018 23:53:40 -0800 (PST)
From:   Yang Bo <phoooyb@gmail.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs-utils: configure.ac: Do not fatalize
 -Wstrict-prototypes with internal rpcgen.
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The internal rpcgen is not able to generate -Wstrict-prototypes free code,
the problematic files are:

./tests/nsm_client/nlm_sm_inter_svc.c
./support/nsm/sm_inter_svc.c

Signed-off-by: Yang Bo <rslovers@yandex.com>
---
 configure.ac | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/configure.ac b/configure.ac
index 3caeebc..ad2985c 100644
--- a/configure.ac
+++ b/configure.ac
@@ -149,6 +149,7 @@ AC_ARG_WITH(rpcgen,
 	[AC_HELP_STRING([--with-rpcgen=internal], [use internal rpcgen instead of system one])],
 	rpcgen_path=$withval,
 	rpcgen_path=yes )
+	rpcgen_cflags=-Werror=strict-prototypes
 	RPCGEN_PATH=
 	if test "$rpcgen_path" = "yes"; then
 	    for p in /usr/local/bin/rpcgen /usr/bin/rpcgen /bin/rpcgen
@@ -157,6 +158,7 @@ AC_ARG_WITH(rpcgen,
 	    RPCGEN_PATH=$rpcgen_path
 	else
 	    RPCGEN_PATH=internal
+	    rpcgen_cflags=-Wstrict-prototypes
 	fi
 	AC_SUBST(RPCGEN_PATH)
 	AM_CONDITIONAL(CONFIG_RPCGEN, [test "$RPCGEN_PATH" = "internal"])
@@ -542,7 +544,7 @@ my_am_cflags="\
  -pipe \
  -Wall \
  -Wextra \
- -Werror=strict-prototypes \
+ $rpcgen_cflags \
  -Werror=missing-prototypes \
  -Werror=missing-declarations \
  -Werror=format=2 \
-- 
2.16.3

