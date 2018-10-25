Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96906C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:52:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5952D2082E
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:52:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MsaEVI3F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5952D2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727677AbeJZG03 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:26:29 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:42876 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727661AbeJZG03 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:26:29 -0400
Received: by mail-qt1-f194.google.com with SMTP id j46-v6so11779119qtc.9;
        Thu, 25 Oct 2018 14:52:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=MsaEVI3FL3l7hiykxZ85PNpyuwG6HST2FhnPbYG2PMr/IQtQ4gcLQjGsojlnqA0FV4
         W3FlgsPLfmjaX6u1xnpGqvCm4MHx30KmiDK/yJe5wvdEL0jI7+ryUWEMEUtQr5bHE1K8
         x9zs3tRP2Xi291GR6hok1Zq/RUp3Tj9jk6Vr2FR5C1qT+C+tDQL3k1mB6MJWg0Gt/Eaf
         b1WAfCVrcFahgHGfa2lh8U/SFE0bQj2l2vXEnPln4rtuuePqWQy1pVgPJlCzRMMCkozW
         gk5yqqOX7547BgX3fndcyoueP9Z8bJttIDcv4Ilv8GZwje61J5SfNV1XuSYJ01DP1e3G
         iRVA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=7UYm6KwHepkUcFRejYDPg8EOERI1MmALOURzx0oOqU8=;
        b=T23dGl7OR7Ar5h9j2vM7linkaidVbMBJMLALfFn5JGmA/9ZUpo+/RAhUd4Csg3zw7i
         j2Oua6Qhg/dBc3QCVEfA+00caP9e45GoUiIbjLwPxler4LACbucxTh4gJyxqz3ogiUIb
         itHVPETigHIV2Euj7WVztxRgGiUXPWQzjhEo56bUxtcjyeqw0WQLvqGzdrTRuXDmkbEW
         TEC6yWFWKa+SECPgOsknBgnGy7wPqsXHSt2Y3w6ixVpFD8wN9ZLvGTHNum1pCmuN1tVD
         yEJ4SUo00aY0Ge8+kBFwPz+zeb90lCC0M6cgb1pdHCbvGywON1fHo0d5aGgnhUJ+mWZP
         cYeQ==
X-Gm-Message-State: AGRZ1gJwVfz6dcENHYQ5kbovCdzpEoVpt4scmd3OuHo28tDVmEM0Cvkk
        zaalZgaqZAA1c6caVYlzZpo=
X-Google-Smtp-Source: AJdET5fc0/1oytY6sWilyM0Od7JugWjjewp4RFS7KJW+oLADRsfFSA3NPlNeIXZStTvbfNEmi0NpOw==
X-Received: by 2002:ac8:8f5:: with SMTP id y50-v6mr267876qth.3.1540504324605;
        Thu, 25 Oct 2018 14:52:04 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm5895927qkc.96.2018.10.25.14.52.03
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 14:52:03 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v3 09/11] NFS for "inter" copy treat ESTALE as ENOTSUPP
Date:   Thu, 25 Oct 2018 17:51:45 -0400
Message-Id: <20181025215147.36248-11-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
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

