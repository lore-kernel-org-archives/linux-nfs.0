Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 643ECC2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2A8D020827
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RHckd8RO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A8D020827
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726005AbeJaFvd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:33 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:34487 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726420AbeJaFvd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:33 -0400
Received: by mail-qt1-f196.google.com with SMTP id z2-v6so15313320qts.1;
        Tue, 30 Oct 2018 13:56:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=nArMGW/INjteRrujdLkp69gM/ZmeUcX82tVQQvtlFnc=;
        b=RHckd8ROwPWhc3lU4r24zhA1uDj0gmlh5Obpm62kyhO4kFKW6Lcoy6NE1w7fAtlDQS
         ABnF6VRhn2uQf3ptAYdKdl7HQeum7wa9UAqKRIRoYL/8gH9SUM116UnMxbfpgSivlmna
         GaXQWGulUMQ+Z/lUVJ8gzhYgrmZM6tScl+UYfMQD/W7q4t05gu5RiM7KYJQ/QPrCX4Ek
         2pqVcrs9huckeky1AEVnKpTd5MgXPQji5i16RsT1pdQr0e+0rOcEy5Uu7cIKdc0iHxTz
         y2g7kQUDYIX39NqeVfvdeg96vIO6ddfMYTSJU/ZUztLJAzO0oOYxYsuYLlm5HFzCs6ky
         eYcg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=nArMGW/INjteRrujdLkp69gM/ZmeUcX82tVQQvtlFnc=;
        b=QodRhYsWd2QEShAZEXJiTSb/nLs/25eoPfMCPZPVwaAAXw3oZFB9/1QC6OyrSyHLRn
         qu7IF5eQHRvfLUi/AxCNRyj0FZ4Yp6iRY+cyBZdY13TACRnyiSwkPhUlwwllbE4JJ9Ti
         TKRNIKn3tzUhtZ0AUfcdHGwHaDochRWeeAF110HUCH9Y8bbpOn+XheCNbTj+AY4OYdA6
         S+OC7FPlQBL6PGilgflkDTfocHexZoPOPWHvNRpMyES/z4Sgzs/0m2EnNCi7iB9hkWO8
         mZ3snJtkslBO2Kmnh+Fs9UpXaVKLr5RwBcmov4fwZEdIGXPH+PtIGnNjsYEeFb488EGI
         JOug==
X-Gm-Message-State: AGRZ1gLHf4Uf12rA32HUXmHEAqxrZFFc56jSEB+KMMzWGPxqYIg78ADx
        g5aqx5UwEnVHrp35mlUAx7g=
X-Google-Smtp-Source: AJdET5d+i+5we0gVFReH2wFo28seYFUStCjY2KpG7SbefgK5gtzxEF3SeTaetrLufvt5UM5WLzJ6Sg==
X-Received: by 2002:a0c:bd15:: with SMTP id m21mr285050qvg.77.1540932988721;
        Tue, 30 Oct 2018 13:56:28 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.27
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:28 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v7 02/11] NFS: validity check for source offset in copy_file_range
Date:   Tue, 30 Oct 2018 16:56:05 -0400
Message-Id: <20181030205614.40754-4-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Input source offset can not be beyond the end of the file.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 5a73c90..7838bdf 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 {
 	ssize_t ret;
 
+	if (pos_in >= i_size_read(file_inode(file_in)))
+		return -EINVAL;
+
 	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
 		return -EXDEV;
 
-- 
1.8.3.1

