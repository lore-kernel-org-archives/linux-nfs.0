Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0677ECDE46
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:49 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8584120832
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="aFxrcAIX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8584120832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727383AbeJYE2M (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:12 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:43892 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726221AbeJYE2M (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:12 -0400
Received: by mail-qt1-f195.google.com with SMTP id q41-v6so7084597qtq.10;
        Wed, 24 Oct 2018 12:58:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=hvO97r38odejQD2UfpD/KDSrWr7Es3ZRdoL6dlpHDTY=;
        b=aFxrcAIXBS51Bj+q9TQcW8dj9mo2rrJjRWQXewjiRr0pJF7s6j4jkxEuQCAk0OQhOc
         ER+6gI3kjTmw+XdK8pFgp3OGgaFNOi6X8dMX2469hpONwENS0X12Ig5o9oDORTj1hhiX
         XReEwM58MpncFcWKGw5XBO5zRuY13I6kL+/0CnjsUvYIZ/Cl5754hoi9gF/bxvl7XAfH
         rd08KTg/PrVOxHR6zGEX9ZVlUjY+oddzNgh5lJSgfs4ztPwuq78pC6kOVodpH+lZ/r5A
         m2gEx9mBokMLbRJBiv9rM+H78h7ibikf/jM9VCPu8A3XhScjHC7ZzrQgGFEV4BS/akOf
         Ieyw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=hvO97r38odejQD2UfpD/KDSrWr7Es3ZRdoL6dlpHDTY=;
        b=ptk/+sSYhrL6eSy1F55IgnMRhe35qjIuGi/y34iL07wG6R5bs3Vj/fQG5PeO0YEyoT
         LGxp8K/xTXzHyMXN58cyduFwv7U9OPaVU3NIeYaQ7oK3T1/8b+H2QdonQVhABGWdXnYH
         zUFuAzvU3kdFQcYxUYx+Nut4Nzbg5Y6nmkp5CM/2Ii57h04UyjhHmOErQZVr0czmw5/n
         xGLyAxAfKdyGOAmqrq6sXR8TIgKW8MxH9d6nrImyzbBT9ioXlkDDNCwVm6kKeKrkpXiI
         Y0pXx6iE/D0v6OmNQg7iPIQ5Ijc9wr6sdOkoF66M5Ro3n8Oe78wNbn/2LMCnXF8khl4B
         leRg==
X-Gm-Message-State: AGRZ1gJilqqrP6qKUftYNRFhtAu6FLj9kZvDSmPEDyOjqLeHz3TMgWVF
        jUJgaCESVPqBwxYELrqegbc=
X-Google-Smtp-Source: AJdET5dbTi5HYhRU2qJEDRaB8vr13zxgOKCgdIoY0lf9m5ntYBC41ytTdxtn6jR97Xeb7hyIifvHYA==
X-Received: by 2002:ac8:33ad:: with SMTP id c42-v6mr3849722qtb.190.1540411125567;
        Wed, 24 Oct 2018 12:58:45 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.44
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:45 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v2 03/13] OverlayFS: add cross-device check for copy_file_range
Date:   Wed, 24 Oct 2018 15:58:27 -0400
Message-Id: <20181024195837.35532-5-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

VFS copy_file_range was relaxed to allow for cross-device copy.
Add a check for now, to disallow cross-device copy offload until
appropriate support is added.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
`
---
 fs/overlayfs/file.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
index aeaefd2..5282853 100644
--- a/fs/overlayfs/file.c
+++ b/fs/overlayfs/file.c
@@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
 				   struct file *file_out, loff_t pos_out,
 				   size_t len, unsigned int flags)
 {
+	if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
+		return -EXDEV;
+
 	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
 			    OVL_COPY);
 }
-- 
1.8.3.1

