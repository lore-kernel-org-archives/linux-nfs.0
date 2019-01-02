Return-Path: <SRS0=5e7g=PK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D0AAC43387
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 22:54:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 00B5A20879
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Jan 2019 22:54:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bLO0Muow"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729962AbfABWyW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Jan 2019 17:54:22 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:36404 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726769AbfABWyW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Jan 2019 17:54:22 -0500
Received: by mail-it1-f196.google.com with SMTP id c9so40663002itj.1
        for <linux-nfs@vger.kernel.org>; Wed, 02 Jan 2019 14:54:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=RWdcnNIyitEJMQvfn+hxFAOnAqAjACY+VGtdmLb9+pk=;
        b=bLO0MuowRYH8EuNUS2fsJ3V0l+6utY0o+WXIs4pxPfhwra0XTPSUhYyfifMrjqCeLw
         yRrhcJWKuILJb9RsyLbJuy1Bkj8cMrgHz1mLmtbkNA+qutSsVkmNca4ylnzLRG/36V1G
         YKwI99ym+tb7A0uU+DTL8M6IGhmWEeJNqTXxvXroNFPYs0Pm5kZ+WvOlA5BiJ1q79oFi
         IpAEHWy9jAElZgxH+7zA/gdYz3YU6jVq7nzdewy1anTy21peLK7VBUrvgl5lJINEpC43
         zblIHoo//mcPxjqHR+vyGQyPLawQ2N4auEOu61LbTQyKRKU0U0QpOkMZ80W+V5cMSCOu
         xyZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=RWdcnNIyitEJMQvfn+hxFAOnAqAjACY+VGtdmLb9+pk=;
        b=EtrgeaOg6JUnNVcxefcQo837rmqYkMv5/GNi6sEM6YOThYf8/RPFyFpee/Nvy23rAL
         2Q8Te/NokEACAKpV8reS0A1mQZh1OFRWEdH8yZPFwTPOz8Z4OYqGfhFi1dVc4EwdYKQO
         4bidHTXmy8L2z/2rVIRQoHOyO3esn1U1lQQ2PFRmkWQgX8K9WZzbW1O/8NO8CWPlO1+z
         1F5dUr9expMMNnKBjR3sNYP6uPiFyFZJxdHXdi16kMMPmMbqZAAJYcYjyqUfyPfPcY5z
         nai01ooB6xhtOOqztnKvx6vAq4dbGAyQg80feysMTkg6CYoDANvHS6MqaUdIpq+Xhj2u
         qF1A==
X-Gm-Message-State: AA+aEWbK5sQAxxlMjyzRXLrZIVlzN/9VmbW/VHPOFv7O125CcvNXaRXn
        aw7FVsX3vYvQtMs8Bm0Jam70DR9p/g==
X-Google-Smtp-Source: AFSGD/Wol+JKpFQ9lnDC2GSK+VU3vEuOCTmHS0RlRrk6ngWCPmvGH76YGGYh9G7+oRiE0j0YaGgGFQ==
X-Received: by 2002:a24:5989:: with SMTP id p131mr29673384itb.6.1546469661042;
        Wed, 02 Jan 2019 14:54:21 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id d3sm23036154itc.40.2019.01.02.14.54.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 02 Jan 2019 14:54:20 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/4] bugfixes for RPCSEC_GSS client support
Date:   Wed,  2 Jan 2019 17:53:09 -0500
Message-Id: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

These patches address a couple of issues that are mainly affecting our
RPCSEC_GSS client support.

Trond Myklebust (4):
  SUNRPC: Ensure rq_bytes_sent is reset before request transmission
  SUNRPC: Fix the RPCSEC_GSS sequence semantics after request
    re-encoding
  SUNRPC: Allow for some re-ordering of RPCSEC_GSS requests on the
    server
  SUNRPC: Ensure we respect the RPCSEC_GSS sequence number limit

 net/sunrpc/auth_gss/auth_gss.c | 22 +++++++++++++++-------
 net/sunrpc/clnt.c              | 20 ++++++++++++--------
 net/sunrpc/xprt.c              |  7 +++++++
 3 files changed, 34 insertions(+), 15 deletions(-)

-- 
2.20.1

