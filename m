Return-Path: <SRS0=zNNA=XL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A161AC4CECD
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Sep 2019 21:14:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7625D2067B
	for <linux-nfs@archiver.kernel.org>; Mon, 16 Sep 2019 21:14:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dxGtWr82"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727941AbfIPVOB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 16 Sep 2019 17:14:01 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:33271 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2391483AbfIPVOB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Sep 2019 17:14:01 -0400
Received: by mail-io1-f68.google.com with SMTP id m11so2570495ioo.0
        for <linux-nfs@vger.kernel.org>; Mon, 16 Sep 2019 14:14:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=qbMlSBpf06q9f17aggELxyyLLTxlNI3h6Qh/Z4qZNW4=;
        b=dxGtWr82ZO9cHrDcGx77NwbtjyHT56xC84BFTBT69bVsOUPl1zCwG+pI+HgGFdejio
         z2noynA5OzVrSFvcfx/SnQRLpgqM9oK1TYZ9GGzlmDWhi/pqbHeNwEcR/QGzRFZRBfrq
         lY5bxQI/sN3kr+QZ7V7sltSr9LdS4QfWtjzbFxD+E9jD9F8WRfp+9iGGuh/l3/rxcqK4
         vnRHRRKX4jEk82JQBBb5XRm+ALX0GMAy8Aq/2jAHO7I6Pb2EwMGe5yBTkSUj3cSN0g6+
         8d2k32dgiBrbnjw34NyD6dkbToDCGs9Hltb4z3YJSg2Wm1LYqH5pqZJLajgXGDFmggcj
         AtKA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=qbMlSBpf06q9f17aggELxyyLLTxlNI3h6Qh/Z4qZNW4=;
        b=pntJQ7MxO9BCX3nEYza+UPHeFkZL35pQomgpHgQVtbX4LaYIPr7/UwJenzC4s8TOTr
         0kc/dxXxX3Mb5B/9dkIfBeRiN0/7bDpXr4HlEppSxRA9TOLyvrUVn5dd9sJUo7BRPJtH
         3ah9ca7jNL6yXTNFvDL4eFmKjOFWaWV/2dd9TDJHUUAoFBO8mxmhBo3vb12OEaHU3rx+
         snPjwnHA/af6FQX0xz4EMOgYYmQJ03FsaA9Tyr6Py1dy88BL+pjsI61Ud/3/Z6q6kh3m
         z7hAsMxIZTOEc9s/BzKCEYh9jGdOY/BbpjDeryPLoKDGrlU7pgmObC0U+/JU6pe9Z1Yn
         ciyg==
X-Gm-Message-State: APjAAAWonIHLD/hiG2ySXe0JFGgfEgT3CK8C9CtKz7DU8iqxnmJ5HRA9
        h/eeEPRcn/qzFnaKhE0RrZsItFJY
X-Google-Smtp-Source: APXvYqw33LhG0yhYMdQQcpRT/gjZp/+IBi/rB8fCoZATwfX2Ep4Qv8UPivzFzyGiOnePXbICpuhF+A==
X-Received: by 2002:a5d:8e0e:: with SMTP id e14mr291760iod.211.1568668439709;
        Mon, 16 Sep 2019 14:13:59 -0700 (PDT)
Received: from Olgas-MBP-201.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id l186sm71853ioa.54.2019.09.16.14.13.58
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Sep 2019 14:13:59 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v7 04/19] NFS: also send OFFLOAD_CANCEL to source server
Date:   Mon, 16 Sep 2019 17:13:38 -0400
Message-Id: <20190916211353.18802-5-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20190916211353.18802-1-olga.kornievskaia@gmail.com>
References: <20190916211353.18802-1-olga.kornievskaia@gmail.com>
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
index e34ade8..bbf7c1e 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -206,12 +206,14 @@ static int handle_async_copy(struct nfs42_copy_res *res,
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

