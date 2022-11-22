Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FE7AC433FE
	for <linux-nfs@archiver.kernel.org>; Tue, 22 Nov 2022 02:03:49 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232427AbiKVCDs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 21 Nov 2022 21:03:48 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33158 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231788AbiKVCDr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Nov 2022 21:03:47 -0500
Received: from mail-yb1-xb2f.google.com (mail-yb1-xb2f.google.com [IPv6:2607:f8b0:4864:20::b2f])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 55CB0DDF93;
        Mon, 21 Nov 2022 18:03:46 -0800 (PST)
Received: by mail-yb1-xb2f.google.com with SMTP id p81so8025694yba.4;
        Mon, 21 Nov 2022 18:03:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=1b8HPjIVanvIpx3mpSwXbKcufI9SFau4CSmq1BJRqyg=;
        b=ZSeuBNVyJ2rnz+faE/E2bxffcQP5dJVUl/DV0FbPI7pwyjwtiab2XX2ZLiEjZ/f9pV
         D9IqD5ZAG7yODHAxDC1xo2nVVqCtiMQJkFonw5VBzX1M3K1dE1LpuVApdRuAnHDshqXO
         IRLHyKUTLatTlKiXHCTuDu7Zyls3nSDOsql3hCsj0CS/1/Y42qyutcV2Gj44kdd5wX64
         fgmcmrm8j8exxUU/cqtXynSiot0wEDmXygia3P3TiDAGxLnuxrVcjgJS2hbVHs/1d6XG
         NIJRUEVON4847ka7NQ3A3E7iJTNoNS/eUy3kuUwfzwEK11QksWfQDFkp+XI39aq8C8wN
         bLtw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=1b8HPjIVanvIpx3mpSwXbKcufI9SFau4CSmq1BJRqyg=;
        b=evA8tPjqC9yNZVQYubZaZsPWUM6dh8e7geJUYtlAfBnq8+F9+59Sui+yJepvbU9/xO
         FQqLkytNIXpNaXTeyugO1qrpW1h7V/y3che/Tq+TmiAepTRyBOlG+DMEedeP1u9DV/nZ
         GkDVBj3ydy+uztfWoBC99sqzrj4cbR8ngQrke2avaVMDX+poGHVgEw3ZxlgrCnODxqtX
         uCV9sswSEL9aQksIFskhi57/iSWnYInegLsOrGh6F2SIMi4uKuLvtG6c+9jqx2cq0zg+
         621XU2MBJvy2Msnmei5mLgVPemwiOPtlBlTLPyd/RBFX5BBzL3XgCD1TzIP5QGpcNmfG
         zCWA==
X-Gm-Message-State: ANoB5pmDGKbALlnAKJeBAGFmzCBrVQw8KuD/mLlbPDv7Wyk+3oQkKFda
        jVg0WdYcWv7CXgfVFbhZivSI7Z7T9q3gHLzzDOgmOv2zbwZa1w==
X-Google-Smtp-Source: AA0mqf4M+JvX5tIp8DVHLRmVAkEFiriwAW+Ex9lSHaXG4z1lYU/E2yxUomjYbAre9IHK3TBIBs0yN8hqF8qYa/knN8M=
X-Received: by 2002:a25:a304:0:b0:6d3:2de2:af93 with SMTP id
 d4-20020a25a304000000b006d32de2af93mr2160213ybi.161.1669082625457; Mon, 21
 Nov 2022 18:03:45 -0800 (PST)
MIME-Version: 1.0
Received: by 2002:a25:9f88:0:0:0:0:0 with HTTP; Mon, 21 Nov 2022 18:03:45
 -0800 (PST)
From:   Felipe Bedetti <felipebedetticosta@gmail.com>
Date:   Mon, 21 Nov 2022 23:03:45 -0300
Message-ID: <CAFO8usxQ-j7YQTeho2f53_humwPgsR++6hs1mmFOocpmNArHyg@mail.gmail.com>
Subject: Norah Colly
To:     linux mmc <linux-mmc@vger.kernel.org>,
        linux mtd <linux-mtd@lists.infradead.org>,
        linux net drivers <linux-net-drivers@solarflare.com>,
        linux nfs <linux-nfs@vger.kernel.org>,
        linux nilfs <linux-nilfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

https://bit.ly/3EKzbum
