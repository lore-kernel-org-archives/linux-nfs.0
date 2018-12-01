Return-Path: <SRS0=P3M0=OK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22258C65BAE
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 18:16:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E74D32081C
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Dec 2018 18:16:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gdF6pVJ1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E74D32081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725734AbeLBF3i (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 00:29:38 -0500
Received: from mail-pf1-f174.google.com ([209.85.210.174]:45826 "EHLO
        mail-pf1-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725726AbeLBF3h (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 2 Dec 2018 00:29:37 -0500
Received: by mail-pf1-f174.google.com with SMTP id g62so4367425pfd.12
        for <linux-nfs@vger.kernel.org>; Sat, 01 Dec 2018 10:16:32 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=IyzGTR0agtyyRRB47j7KtfeGElpS67Y9ylKIbFA+5h4=;
        b=gdF6pVJ1RuackfBYgwl5TM4a2/YEyp16RSrK98XWuZu6M6elODhe2jgOf6U4ZLXDea
         qtoNQLHKBvDM5eIaroGvZ/FNW10npp3mNIjPnaJTwa1uoX/Dsv0IdeyPB/gNpRxLvfdW
         4b96o6+iBc0iG6bmiBBar/6TBSis8gVu2kvYHeNLtsy9oKq9GLfGm/DV3iKiLMSqz/a/
         w0llBn9qIC711YAfkvbiM4attHuBmYSqJaugdQN3+WwtvZrJyCJm49a91UkD1QoLkems
         m6DHBOedeNmuiXrU+kYZXresHWCiyVoRQ6LbRSrUpLy7TZF5AezbBIVk/tcgncq/QTNO
         HLvg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=IyzGTR0agtyyRRB47j7KtfeGElpS67Y9ylKIbFA+5h4=;
        b=Izi5QPlR/ffl92uBNB/57fTDM1ctTuCPT4jlNlhHSy+vYhjd9ETd+kRp7TKw4YuRHy
         kHDQE4JitFxklomyzEFcOtVX7vddCTFyHaerNOsIXp7/HQE9ctJbL0lXQnpGpHk4DleJ
         5QHXLFuG4lOUE+4FVudyxjWCnuxR7DXqx9PKnVjFyLfUE+DrK8MX6Ymo9yzgiAZnAFY9
         pYuCWgJ66mcjQfgN2Z15Wgbeceo4Szqt/Qc0blOg7skYF6uDkuSI1yQZHl/xbyaDwPhF
         z4t1e07JeqU5GSGPOEKia5RzOJCsyK+Tz+u9sxM7NtEL9xlbn350AemRaWniAKacSgrk
         kh7Q==
X-Gm-Message-State: AA+aEWZHpEnzTYCH166XfUFtsedDg1ZlbWzvvmbNxYOIx+ZW8GJknChR
        KLftHYbtKeLdIdSRlwpJnaYyHgf9DkY=
X-Google-Smtp-Source: AFSGD/UQ1AHi4bNa0gyXyDxRRXXi2R49fCMBG2rOcnUknbdQ4LmUFe6X5YzbmGDKrYlOK0qDPddEZA==
X-Received: by 2002:a62:1709:: with SMTP id 9mr9943369pfx.249.1543688191873;
        Sat, 01 Dec 2018 10:16:31 -0800 (PST)
Received: from localhost.localdomain ([2601:646:877f:9499::26ab])
        by smtp.gmail.com with ESMTPSA id s190sm11570042pfb.103.2018.12.01.10.16.31
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Dec 2018 10:16:31 -0800 (PST)
From:   Khem Raj <raj.khem@gmail.com>
To:     linux-nfs@vger.kernel.org
Cc:     Khem Raj <raj.khem@gmail.com>
Subject: [PATCH] Do not pass null pointer to freeaddrinfo()
Date:   Sat,  1 Dec 2018 10:16:21 -0800
Message-Id: <20181201181621.7268-2-raj.khem@gmail.com>
X-Mailer: git-send-email 2.19.2
In-Reply-To: <20181201181621.7268-1-raj.khem@gmail.com>
References: <20181201181621.7268-1-raj.khem@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Passing null pointer as input parameter to freeaddrinfo() is undefined
behaviour, some libcs e.g. glibc might just call free() which does
accept null pointer but other libcs e.g. musl might not and instead
cause the program to segfault. Therefore do not rely on undefined
behaviour instead make it deterministic

Signed-off-by: Khem Raj <raj.khem@gmail.com>
---
 support/export/client.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: nfs-utils-2.3.2/support/export/client.c
===================================================================
--- nfs-utils-2.3.2.orig/support/export/client.c
+++ nfs-utils-2.3.2/support/export/client.c
@@ -309,7 +309,8 @@ client_lookup(char *hname, int canonical
 		init_addrlist(clp, ai);
 
 out:
-	freeaddrinfo(ai);
+	if (ai)
+		freeaddrinfo(ai);
 	return clp;
 }
 
