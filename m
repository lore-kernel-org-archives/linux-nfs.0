Return-Path: <SRS0=azWf=RW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4E19C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 16:12:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 67DCD2085A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Mar 2019 16:12:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="se1MTk8l"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727674AbfCSQMV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Mar 2019 12:12:21 -0400
Received: from mail-yw1-f68.google.com ([209.85.161.68]:41011 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727663AbfCSQMV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Mar 2019 12:12:21 -0400
Received: by mail-yw1-f68.google.com with SMTP id q128so16325804ywg.8
        for <linux-nfs@vger.kernel.org>; Tue, 19 Mar 2019 09:12:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=k8pyYLtHSCB7Ez4Y76HrFK0cEWyaoqMlS80tYH7iWUI=;
        b=se1MTk8lDJbRjCSpMLBlh9X+L59aA1G+ABKHelKnaVJUHucVxgnZGSmhVJxgMhHgdE
         5gJsrJXQI+R8WV1rmXup7SIL8EpBCBEIUgshQgK9QGGyPw6PpCRLTfluDgcKbhej78QC
         Ka6Y5AvoVRp8botn8FUBQlkvD/Afddze3v/m3wxMkPlbUyvH+ufQtVkW/o/VFzQZ/mt4
         A+xDRBVoeK3Zmr6nsbcuBhkLfsIC/s5BUs7B99zDwy800fwSeFHTF5LTuclt+URpVBSd
         4i56Ck8nSNMv9EWhXB487Z7pgE8Se5Uy2BcWHTxfV0P4Q3LpWenMYa+9fCrklkOc7wmR
         DNWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=k8pyYLtHSCB7Ez4Y76HrFK0cEWyaoqMlS80tYH7iWUI=;
        b=mch+8URD8ssWLt05439mlrt3xhAA04qAe81R+gmQjvnr2GR0wVLaA7WBvxIdnwkcWb
         jpAFszBtCS1GJDWSkHGPT5x4Hg74yXKqdFS1I+JHRd6zphgdxSk+wIROE6nF6QOk5/Hn
         W7al5+ea52002o4YMp2goNV7weIxEByAOZtR6wuZ3tyZho/1Ab7v/3P2Mwu+htEX+FVc
         iBRHBcDUaEF85ejvjcKJGQXJSeGzE1yfWsUGgVbUXDI5wPcfVabobx9iDTgZVB5F8BEf
         ebIvkYlL/HTd7G06MbWIhUfAoCfkYiiH8prKDgmTFxT/LqLzXeWRkNg1ZXzmRqNUHHzQ
         nTwA==
X-Gm-Message-State: APjAAAXjxG7MfY+yIjud4JdHbqEG/TRimnUwt6pWkpSd+TQcRmyt1Ont
        KyHptZ4E5Uz/sHO1TAnoe+Y=
X-Google-Smtp-Source: APXvYqxVzmKewGuAQVhI8ozrN/Bu5ebSvVjHWq5lYenn1vO5TCJhWqrnlrehilXRrmRkFAXXU56APg==
X-Received: by 2002:a25:646:: with SMTP id 67mr2701764ybg.76.1553011940948;
        Tue, 19 Mar 2019 09:12:20 -0700 (PDT)
Received: from localhost.localdomain ([97.101.44.244])
        by smtp.gmail.com with ESMTPSA id n11sm752015ywb.69.2019.03.19.09.12.19
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Mar 2019 09:12:20 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFSv4.1 don't free interrupted slot on open
Date:   Tue, 19 Mar 2019 12:12:13 -0400
Message-Id: <20190319161213.11691-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Allow the async rpc task for finish and update the open state if needed,
then free the slot. Otherwise, the async rpc unable to decode the reply.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4dbb0ee..96c2499 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2933,7 +2933,8 @@ static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
 	}
 
 out:
-	nfs4_sequence_free_slot(&opendata->o_res.seq_res);
+	if (!opendata->cancelled)
+		nfs4_sequence_free_slot(&opendata->o_res.seq_res);
 	return ret;
 }
 
-- 
1.8.3.1

