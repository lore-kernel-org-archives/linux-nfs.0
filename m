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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 567BAC2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 22B5C2082B
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qgyhtu8P"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22B5C2082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728116AbeJ3Ca5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:30:57 -0400
Received: from mail-qk1-f195.google.com ([209.85.222.195]:41527 "EHLO
        mail-qk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727450AbeJ3Ca4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:30:56 -0400
Received: by mail-qk1-f195.google.com with SMTP id 189so4053880qkj.8;
        Mon, 29 Oct 2018 10:41:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=qgyhtu8PamjdUrG/T+0w1V0aWD12cqYtobDn8FkkEMikqKxA3RbXe9kqFiv57P+bXo
         dMjphsINCLaYGP33OpflPBJmOwRVrNT5CTBGq4ZGF72Eu+7F/iEtOwaHqbSw1XkjYc1F
         7a7jppLcp+wYwq0hfTyhNoXjkNlgqat/cdDPgY7eb0nablkWK6vpZ7YgspEbLGBvindo
         jZXTwwSrDIHpvwZMMAq69ZsrDXt0uk3rCWPbZ8Ui+tHCBESD6sC/htSe59P9869Oosqg
         2Ds9c5jEwTldWyvI8+bx/zjtV0NVq3iN3mFIWJAexlGRpQuDY9dkHPXYFyCW6RjsEP+I
         gfIw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=NgW2Yie+Iok1tt+0PjLAPRr983iIRO0tsdV2eGcaPpERCN1dHd+OyRfCxXyp+PCb7O
         MEVrLECdUFMJTmdmBVMtlJ+5fT00j18c5n9vDcp4V33bHiS2ArUKJ+5y2R1htBkmBwYE
         TF3Lvsj8uQHEfj6M8eloaoMxvk99b1pjqs1M+T0zwVzs65NFW9WplIvYFPLWYv5GJekf
         hFot5ULgRXmZuV05NcdqOsNJvTeoVKAgkAzelWqWhHuHl4ZzeG+eO3VG9Ia14LIpojnR
         Ki5rIQsNqJD8fdnOB5GbdEDhl9P+gVvngkEH2g5P6iNBajjC8/ljshDzMPH7eG1Oxw7t
         tnfw==
X-Gm-Message-State: AGRZ1gKOz7xzj904STmNszkJWCXQ4lAZ3VPKzoKrgfPBoqA6FTanBPd8
        DKoPz3c1kuVNoIqf25nQWOU=
X-Google-Smtp-Source: AJdET5fRS+HZGn+1AlOaY9tzlise3p8ou3TMS6YWuwYaQiF1ofBDBpi71sp+KOIdrL4qsn29DoB+DQ==
X-Received: by 2002:a37:ba42:: with SMTP id k63-v6mr13205954qkf.103.1540834878906;
        Mon, 29 Oct 2018 10:41:18 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n190-v6sm13148929qkb.29.2018.10.29.10.41.17
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 10:41:18 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v5 10/12] NFS: for "inter" copy treat ESTALE as ENOTSUPP
Date:   Mon, 29 Oct 2018 13:40:57 -0400
Message-Id: <20181029174059.38326-12-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

If the client sends an "inter" copy to the destination server but
it only supports "intra" copy, it can return ESTALE (since it
doesn't know anything about the file handle from the other server
and does not recognize the special case of "inter" copy). Translate
this error as ENOTSUPP and also send OFFLOAD_CANCEL to the source
server so that it can clean up state.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index 98fe00b..00809b3 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -395,6 +395,11 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 			args.sync = true;
 			dst_exception.retry = 1;
 			continue;
+		} else if (err == -ESTALE &&
+				!nfs42_files_from_same_server(src, dst)) {
+			nfs42_do_offload_cancel_async(src, &args.src_stateid);
+			err = -EOPNOTSUPP;
+			break;
 		}
 
 		err2 = nfs4_handle_exception(server, err, &src_exception);
-- 
1.8.3.1

