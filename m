Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 869A4ECDE46
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4A04F20820
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HJvlXEJL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A04F20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726563AbeKBBtV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 21:49:21 -0400
Received: from mail-ot1-f66.google.com ([209.85.210.66]:33320 "EHLO
        mail-ot1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726464AbeKBBtU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 21:49:20 -0400
Received: by mail-ot1-f66.google.com with SMTP id q1so8883022otk.0;
        Thu, 01 Nov 2018 09:45:36 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=HJvlXEJL0wyQxADnmUn/wBOr9CopicZ9Ch5qLBQ2vRPpVF/awGnSxu2Qd/TyVsZrjo
         il29p6hpDvz5TNUXiM0kSqQanHvdsAwS4+/+zcodJvNwSW9qBTwI71nHJGarLy8BuXEF
         /2zF+kotyS2OdOGoREeV5u8jRtSxDu2U6EGU5RZKd2ztPEqxzJebVnFrM4bMPfIWwhXk
         E8sgdHS/ZLEGL3HH/6JlMDZFr16qQZmPuS8XegBYmx182LcfhviCssYdTP8WzIcRhnVS
         9lHsl6KOmv7uZjQo29trioBRWt3egNUo6da6u27dWHJlCSoskylXvDhP/133k5M7F2D1
         6ofA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=JQ+qjF1GhUCz/sZXJtf2iHfoyzE5Qw8jtnezPlCPLoqDlQsFK8/QxUp6BRF9A+VrHX
         +5UqDFNrOld0nEZ/+fFMrlk7O5dSOIXd4iMEvoHkdf08qmiRHrARXDT5HyzKrI+YcThz
         Nkdhes72Z/JuZdd4hhTsaz9vUhvkx2mV0qvKXsr+HGlMc2eApUHF9m6v1cr5asapVMzO
         kat5T/WYRlKH7ag2gCtJ6o6fEIxtrGOrgfqsswmY/UqE1///VL1BEfAP8s2uBNtDyL3/
         a1iKv0v4SzRWAaVF4cp5dcp+VmHK4sQR58T5nUajEhj4T3HvBa8gHz0cSBKdD0o9wIY8
         PohQ==
X-Gm-Message-State: AGRZ1gLFuddlSEIUmEIAm6crqG0ZGSNmlWe5BNK5gycS9t/Uii2nsIsj
        xWMLMFgXH6hSRd+7jcVZpZg=
X-Google-Smtp-Source: AJdET5fAdMIM6pYUuJeLVzFZh5ySPXFV5LA0jIl/y8KgP2ZmIQFqzzzYYuy08Oh4KpPHTR3GHrYJXQ==
X-Received: by 2002:a9d:6511:: with SMTP id i17mr5272361otl.358.1541090735659;
        Thu, 01 Nov 2018 09:45:35 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r62-v6sm1834301oig.14.2018.11.01.09.45.34
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 09:45:34 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org
Subject: [PATCH v8 06/11] NFS: also send OFFLOAD_CANCEL to source server
Date:   Thu,  1 Nov 2018 12:45:18 -0400
Message-Id: <20181101164523.41812-7-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
References: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
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

