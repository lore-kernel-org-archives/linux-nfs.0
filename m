Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3896FC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EC0A021738
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:04:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I1QoQQsB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729522AbfBTDEu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 22:04:50 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:36845 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727576AbfBTDEu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 22:04:50 -0500
Received: by mail-it1-f193.google.com with SMTP id h6so12136899itl.1
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 19:04:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=SHIy88zDE+3aRCcqGowgVrHgFFfcscEsO3caI+RiFnI=;
        b=I1QoQQsBO9muF2TZzev1c7R19eCE53MkfXEviYIXadqN7gZoziju23JAIMqSZBrbZ/
         3KW1Lk+idsHU9qw4XsUbWjwYy/tYociqVHCXDIrCmeSZTvkkS+OGzwKCIMtWpUqbJIhP
         DIRheOwg748voNcNUAWFDa77qfYZNMtupfBaMXBeOZ/XQXF09H+kAgD0emi+ZsRIzaay
         asA9muFGynTgIV9NwXOQb/UmgzSYpwcmJNMAtRPL172sXyW4j4Lxg7dfIC2nnev2hdqC
         Uu+yf1vv2G1Sl3hVbjmUmePK2KPflOPbVNGzKwktid7kiFp/4TG6njuPcgqj6Lyiaq7S
         XyOg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=SHIy88zDE+3aRCcqGowgVrHgFFfcscEsO3caI+RiFnI=;
        b=sSM9q6q09vPxyX1recDA0e+CdJtEeQD0sa2C52/Pkc+fCDp0/aT7eyFI7yyZn0Qe7r
         wfSeCyecAqC0+6+wqQQ2NXAaq7BN9ZbiQFoO7/jTu7X2gLFwHx187s4RoEg7kApbWGOI
         pPALFBJQL0OfwV93eQgquR8anH3ENMh85x+3SgmJuxCAsSokKKQPSCZA/9fpENBhaFVU
         K3SnMnHkfCA0cpTzCishoIyzE3fNH7DgOw58KPggWthrkUnhE10OtgD6o2LDYV2xdhDG
         9dqy8FTuk9i189Z3+qaHqQeNVFf1e+zmarH9WMkFwBZ2aTxG+bDt9S67Z5PSRUnra+PQ
         Ukyg==
X-Gm-Message-State: AHQUAuaPngoRrnag02nomdaJCqjiiUC6z7C75dJPE+EHsN2auHKztk9L
        obrVrsQ86utvJOUD2VEzbMRWFFw=
X-Google-Smtp-Source: AHgI3Iah8iuMsx3Ft6Re03yGwup9JPjNEAs5wd4MBWaxufxdJlwKUk75gLDi0BPz5eUP6/BxcvBL2Q==
X-Received: by 2002:a02:660e:: with SMTP id k14mr17994573jac.34.1550631889082;
        Tue, 19 Feb 2019 19:04:49 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id a192sm2036924ita.0.2019.02.19.19.04.48
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 19:04:48 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] Simplify the RPC client socket transmit code
Date:   Tue, 19 Feb 2019 22:03:37 -0500
Message-Id: <20190220030341.58766-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Simplify the RPC socket transmission code by switching to using the
iov_iter functionality. The main gain is that we avoid the need to
take the socket lock on each call to sendpage(): in the common case
of a 1MB WRITE rpc call using 4k page sizes, that means we go from
256 calls to sendpage(), each of which takes the socket lock and
releases it, to just 1 call to sock_sendmsg().

Trond Myklebust (4):
  SUNRPC: Convert xs_send_kvec() to use iov_iter_kvec()
  SUNRPC: Convert socket page send code to use iov_iter()
  SUNRPC: Further cleanups of xs_sendpages()
  SUNRPC: Remove the redundant 'zerocopy' argument to xs_sendpages()

 net/sunrpc/xprt.c     |   1 +
 net/sunrpc/xprtsock.c | 106 +++++++++++++++---------------------------
 2 files changed, 38 insertions(+), 69 deletions(-)

-- 
2.20.1

