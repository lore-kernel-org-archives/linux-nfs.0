Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF28AC0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AD27D2082B
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iO16EAq2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD27D2082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728077AbeJ3Cav (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:30:51 -0400
Received: from mail-qk1-f196.google.com ([209.85.222.196]:44777 "EHLO
        mail-qk1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726330AbeJ3Cav (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:30:51 -0400
Received: by mail-qk1-f196.google.com with SMTP id n12so5450868qkh.11;
        Mon, 29 Oct 2018 10:41:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=iO16EAq2S7E91Xfvz1LSANX2tqNBqF8MoSzDlFFR35GPdq/Mvc3O79TnChN8wbpA3G
         FV7um+XuaFsp5oXe++8xBsfnegv7JlN5HRSpu4flZ4aSHikLS0aEWZBd/C1iLJdeOgw7
         hgmNjnSkzG4P9JyJ8eTGgXypf+MRWDHXwHH2OCYVbLcW0DE9rZmjR6opzQZ8BGqtuRXz
         /9A6qVqfv3lZlmAADwLezzwjjObS+l1lH2R1LUh03ArA/Jtw8jI9Rp4lZKYbt9UBPf/R
         gSnq8CklBX0A+kvZLYX20Gf0e45dZrE6/m0LRfGdOSrQT1YiJKpFegRl/KcPhzUmSIl5
         S4og==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=sXF1LmrhFuUuIz1ZL0AB5f8JOL6bBLa66Bgut2FOllKUGnVd0gGyWB3s7hOhrqnHCf
         o7U0su7Hin7ePYQEHRV43Xah0AmFC8gePU0T2Md+JlWpWy0FSCPycTgksviBTdyKVu2j
         F41olLBGTnOuJnG6nKYApYmpg2kQCb1HGlbLI7TxC/qqWdX4iNcNHifcXZsA5RCd73Zh
         Q0Pa0Zdcgj2ZnKs2tk9UuoP/NlYCBypSqyfl12xJYB/LbeGGilxJ5CXekUyQZWx1ROhC
         2EcZONn8WzyoA7MOBTY0Rd0xHX6URK/y5GYtXu6tRBlJkaPvgbfIQ+3I2WYF37puQkHc
         eEnQ==
X-Gm-Message-State: AGRZ1gKcBgTqxy4X6kYT/N1C2hThtQJsEns2zW1bC9ce3J++6UwebxFT
        KD9Tkcka5P58/1BSCkN7ucg=
X-Google-Smtp-Source: AJdET5fLJjUJmGOLPCRByX/hJz2+Y4l5MrziZgizEnsBxSPnJmLlIG71509QUz2ksx3bEc21MoSBug==
X-Received: by 2002:a37:c68c:: with SMTP id s12mr13295318qkl.66.1540834873886;
        Mon, 29 Oct 2018 10:41:13 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n190-v6sm13148929qkb.29.2018.10.29.10.41.12
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 10:41:13 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v5 07/12] NFS: also send OFFLOAD_CANCEL to source server
Date:   Mon, 29 Oct 2018 13:40:54 -0400
Message-Id: <20181029174059.38326-9-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

In case of copy is cancelled, also send OFFLOAD_CANCEL to the source
server.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index bb9e799..98fe00b 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -205,12 +205,14 @@ static int handle_async_copy(struct nfs42_copy_res *res,
 	memcpy(&res->write_res.verifier, &copy->verf, sizeof(copy->verf));
 	status = -copy->error;
 
+out_free:
 	kfree(copy);
 	return status;
 out_cancel:
 	nfs42_do_offload_cancel_async(dst, &copy->stateid);
-	kfree(copy);
-	return status;
+	if (!nfs42_files_from_same_server(src, dst))
+		nfs42_do_offload_cancel_async(src, src_stateid);
+	goto out_free;
 }
 
 static int process_copy_commit(struct file *dst, loff_t pos_dst,
-- 
1.8.3.1

