Return-Path: <SRS0=9F0h=R2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C43CC43381
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 13:46:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4D1D02183E
	for <linux-nfs@archiver.kernel.org>; Sat, 23 Mar 2019 13:46:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727267AbfCWNqu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 23 Mar 2019 09:46:50 -0400
Received: from out20-26.mail.aliyun.com ([115.124.20.26]:39168 "EHLO
        out20-26.mail.aliyun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726909AbfCWNqu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 23 Mar 2019 09:46:50 -0400
X-Alimail-AntiSpam: AC=CONTINUE;BC=0.0903197|-1;CH=green;DM=CONTINUE|CONTINUE|true|0.122321-0.0205179-0.857161;FP=0|0|0|0|0|-1|-1|-1;HT=e02c03267;MF=liupeifeng@horiscale.com;NM=1;PH=DS;RN=2;RT=2;SR=0;TI=SMTPD_---.EBmQpiQ_1553348797;
Received: from LIU.OPENFS.NET.OPENFS.NET(mailfrom:liupeifeng@horiscale.com fp:SMTPD_---.EBmQpiQ_1553348797)
          by smtp.aliyun-inc.com(10.194.99.21);
          Sat, 23 Mar 2019 21:46:44 +0800
From:   Pei-Feng liu <liupeifeng@horiscale.com>
To:     linux-nfs@vger.kernel.org
Cc:     Pei-Feng liu <liupeifeng@horiscale.com>
Subject: [PATCH] Using a larger memory to cache filename when decoding FH
Date:   Sat, 23 Mar 2019 21:46:33 +0800
Message-Id: <1553348794-4505-1-git-send-email-liupeifeng@horiscale.com>
X-Mailer: git-send-email 1.8.3.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The maximum length of filename string in 'fs/exportfs/expfs.c' is limited to be
'NAME_MAX'. But I have a special filesystem driver with longer filename. When
exporting it's namespace with NFS, 'exportfs_decode_fh()' can't holds the
filename if its length is larger than 'NAME_MAX'. And 'dentry' in VFS layer
doesn't contrain the length of filename within 'NAME_MAX'. I guess the correct
method is firstly probe the length of filename with 'vfs_statfs()'. With this
value to malloc a larger enough memory to cache the filename when decoding a FH.

Pei-Feng liu (1):
  fs/exportfs: Decoding FH with a larger memory to cache the filename.

 fs/exportfs/expfs.c | 30 +++++++++++++++++++++++++++++-
 1 file changed, 29 insertions(+), 1 deletion(-)

-- 
1.8.3.1

