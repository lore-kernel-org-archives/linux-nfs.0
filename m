Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08BBCECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C459020824
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DfHUtPzL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C459020824
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727864AbeJ0Ete (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:49:34 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:41034 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727865AbeJ0Etd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 00:49:33 -0400
Received: by mail-qt1-f194.google.com with SMTP id l41-v6so2673078qtl.8;
        Fri, 26 Oct 2018 13:11:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=DfHUtPzLFgw/yxp4E91kL+2CWdUP1Cg0QGYMyZTHr91moUNzxRyNXvAam3Qj5K4WGP
         AR/vRO/RPod1xhJZzzEm2SCB4WWneJX6OCqH+dwZZbB3BUW3wOpdUu0fn+FCFzEncFyX
         HF1YH4vk6+e28OsCaFGGZj2v4oFfurM+eWXDsRiuuvoOOomHboAWxvjAm9gibeXt3v6G
         2rIyJM2LDqOznA5h+JDfih2unwhMzpxd/Qc6im591onRea2ne1K8sxVRrTnlPT5kj87X
         FcjGAKy99MrLdpkQ+8I0XmVxRgqisAdMuYwxFeNCnEaI1JYSM5Zhq/4IFBtFcA+pNdVc
         TW7A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=DqnHnZrMSvA0or48b6pnWzyYDz4iWYc8+TMTuA2+K94=;
        b=lMnSfCPUwHKmEoEddKJIfgXGPY74lzZcMZfU/F0XyQx4gveIcZTPmG+9nmkMb7dJ1E
         bAMAFktV06ZmiOMmvqjUAkt+Vmy1RJA78tMOBh+TZOCXJ30fDYqji/vI2PVbRi7FcyhN
         ONgvcTYw+XQGs1QyJwlWyAOtoU3B9v9BG2cdm7QeoiJgxdGtMQgSkrXJMkLi2Lau1AuM
         b2PoMlOuWw2fSiYWBXmJ+Fzw3ijN062KfjZdELAFlmb+8JcaS8mZBv/Dn4LZae+QhVXs
         HIcXBh03/LceYBWJju5S8y/pNuIjS0WZysbBjfi7+CM8QthtLA90N5ILxEdRAjQDL1f8
         3t/A==
X-Gm-Message-State: AGRZ1gLdZ4AfOJkio9XRLwRSecCh3W4gEbiYnHZQj7oyaR7YpvUaEApV
        elazmPRrqTAAmJ8qdBn/y3w=
X-Google-Smtp-Source: AJdET5e7DlcXktet+8UpqoC5J5YUuJnzVWCOU5HypZZQ6tTBzitrKUWM2yDVW2e77zwTuGFlwV0ZkQ==
X-Received: by 2002:ac8:19a7:: with SMTP id u36-v6mr4325289qtj.86.1540584669841;
        Fri, 26 Oct 2018 13:11:09 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm8037667qkc.96.2018.10.26.13.11.08
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 13:11:09 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v4 06/11] NFS: also send OFFLOAD_CANCEL to source server
Date:   Fri, 26 Oct 2018 16:10:52 -0400
Message-Id: <20181026201057.36899-8-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
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

