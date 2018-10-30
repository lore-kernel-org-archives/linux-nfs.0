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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A968C2BC61
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D44D52080A
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cgkKa0Q3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D44D52080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728030AbeJaFvt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:49 -0400
Received: from mail-qt1-f182.google.com ([209.85.160.182]:36704 "EHLO
        mail-qt1-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728071AbeJaFvs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:48 -0400
Received: by mail-qt1-f182.google.com with SMTP id u34-v6so15269715qth.3;
        Tue, 30 Oct 2018 13:56:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=vBxFiCMdm9zwB+fNOLFFTK+4s/3BLVSMs2/+B1oAwOg=;
        b=cgkKa0Q3i+KlnjGiuVy79GFf4RjqUdspiwev4l0bkgi6ZpXbPJWsA1DJcDZzqI82vG
         8SvOqklJqWfblfQUq5DhGJAnyuS+VOCvR8oiohe62DGrbVivuQBgnDaAM2eSwdiSOfnC
         liKDGrhI/MCnS8CqPvz34BwYapnVM2+F4UIPImBJFTFjBNWrudpHH+lGuEb0pYFh+5oP
         WNyn8DaiquGNJKLj/f/E25Z9BaPloZ1WsqnDNxahzQI/exZiz2QXjHlqa+46aeUemRfN
         JH/z9Os1wUttFNsdjrPnKVxxjxozXrSl6uRowQWoAcFtuItz6lnlEZR8pqXF2IWJJbkD
         cvRQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=vBxFiCMdm9zwB+fNOLFFTK+4s/3BLVSMs2/+B1oAwOg=;
        b=UsTPQczXENjRoKnc4hi1KevTA4MVX+LV3tFmiOoX1Mlz08GtCoRTozIK4/O/M5y7H2
         6nyZAxf+Ogprkn7R7AuefuObLHhkI8UeaOAcBSk2xL6ni2/4cQz82ulNlGY4tlYPgJRx
         YWKm0x2WDzvX1j3WFGDR0Hd2cWJ1HOHxrNs0PS5bXVwpJ+c9YhOfFJ9z0XR+WTspKCjQ
         l8EcCHomgA95tD4fT7xRanCML8uw3W+PQ+nPMnjfffUoyvyuMsOS45Jh6EH3qL7FySDm
         iH+0rwsfFjzoQy0Ros14b/yR1LTJNIJAMP5BehICwM6B4mHIAFQE0655ILMpfotBOvi0
         08EQ==
X-Gm-Message-State: AGRZ1gKVkKDHDhhsSBeJFVjXDMdKQJVjADmq7/Pz7bktQu5mP2pEGl6d
        4OO+om/95MJmWNI/YS2RdDIVCTF7
X-Google-Smtp-Source: AJdET5fUpkjHaVVPXUjqzIjTXdnOE/xbHvR4j7xM0d6R8B1xsYh/OgWGwBdkC3ygiedanWCDR4yv/w==
X-Received: by 2002:a0c:ec92:: with SMTP id u18mr298903qvo.168.1540933003937;
        Tue, 30 Oct 2018 13:56:43 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.41
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:43 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v7 11/11] NFS: replace cross device check in copy_file_range
Date:   Tue, 30 Oct 2018 16:56:14 -0400
Message-Id: <20181030205614.40754-13-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Add a check to disallow cross file systems copy offload, both
files are expected to be of NFS4.2+ type.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 989f174..69e2705 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -142,7 +142,10 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (pos_in >= i_size_read(file_inode(file_in)))
 		return -EINVAL;
 
-	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
+	if (file_in->f_op != &nfs4_file_operations)
+		return -EXDEV;
+
+	if ((NFS_SERVER(file_inode(file_in)))->nfs_client->cl_minorversion < 2)
 		return -EXDEV;
 
 	if (file_inode(file_in) == file_inode(file_out))
-- 
1.8.3.1

