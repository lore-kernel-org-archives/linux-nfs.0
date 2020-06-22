Return-Path: <SRS0=w9+f=AD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6882AC433E0
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Jun 2020 21:01:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 3DEAB2073E
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Jun 2020 21:01:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BTi8eZRO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730228AbgFVVBC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Jun 2020 17:01:02 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33482 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728545AbgFVVBC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jun 2020 17:01:02 -0400
Received: from mail-qv1-xf44.google.com (mail-qv1-xf44.google.com [IPv6:2607:f8b0:4864:20::f44])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 10119C061573;
        Mon, 22 Jun 2020 14:01:02 -0700 (PDT)
Received: by mail-qv1-xf44.google.com with SMTP id a14so2352911qvq.6;
        Mon, 22 Jun 2020 14:01:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=oZhUO+ZAaIMz3+KVR/ZsD5Vnn8OCWHlT+c5p4J2GXmo=;
        b=BTi8eZROL1LcDkJ4uLRlZdAIoXl8jcYZf7bnV8iBInVhZtQLd3dXEAxJcm3tv0qsGO
         yuYLshN7DwhGzBHZIU3OV7L5InV/AauvqFAEkv5UVBam2tS5lrHSTNkiGHxYsGxmlgRQ
         Mt3XQ/ul84gJdFlRt3vgS6CxgetYO0Ov3bvZ+jeB7eV0RRgMFI3bdfOoPblOq77fJ4ey
         LiOyEJlt0gbmaDXk9TtrNtpJunOi8UivkvRhoY2WLmE0riqPRSYfos0wGhTPfUWn3UoZ
         3QDqkjwmk3UfWOV2us72TocdVoHA8iHceRg3Xj37+MGHAdngYws1tDYlTq7uNuHJV/na
         8emQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=oZhUO+ZAaIMz3+KVR/ZsD5Vnn8OCWHlT+c5p4J2GXmo=;
        b=ZaaWWEonhELQiGDeHc1xZcnXFR+8+vVLbe4drTD4pfiEvxsWyPZfkrvlcjfdyNhiyx
         4+fefGYk4oVso+ZIAevuc1QWUzjA1alLjOzLCvsWoxCs6S9F6ObAWTw9y2SNl7P3JUgM
         /9nEddNt1M85CiCG90UWSYeqqWIzYkuMvX1Sx7M9QxSJG2qtpBe3GWjptTeUrTCoeNXN
         i/2iuDQ0NH2gsje861v0ekrD1IqtYQ6lZ2WrYm5vKw/shTk3CoERjGDfmkiQ3c5rx+IV
         4gTB2VjF+XUXHTXnLE1xFsD4vb/Gx/AdSDuVTfSc6aGjbIqRf3/VHjZpCdVf+3XedKGq
         OOwQ==
X-Gm-Message-State: AOAM533YNLWj7E9FB7D6OvZ9JrTMcVccK1BupTS+MJ5+N73ubfEWokCc
        WNtb2bAzPW2ygbcPL5Jhy1Y9n/mq
X-Google-Smtp-Source: ABdhPJyk0C+T/nli67Z/9FBnFa0CIWcvptUBcfPJ9nEHxasA2SsnI/Y/XV8eJTVEShIIFolyNJiH/w==
X-Received: by 2002:a05:6214:313:: with SMTP id i19mr23536569qvu.183.1592859661195;
        Mon, 22 Jun 2020 14:01:01 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id o8sm3151298qkh.100.2020.06.22.14.01.00
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jun 2020 14:01:00 -0700 (PDT)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id 05ML0xEr018803;
        Mon, 22 Jun 2020 21:00:59 GMT
Subject: [PATCH v1 0/6] Refactor path that sends error responses
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date:   Mon, 22 Jun 2020 17:00:59 -0400
Message-ID: <20200622205906.2144.43930.stgit@klimt.1015granger.net>
User-Agent: StGit/0.22-31-g4b47
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

There are currently two paths in the server's RPC/RDMA implementation
for sending error responses. De-duplicate these two into one set of
helpers.

---

Chuck Lever (6):
      svcrdma: Fix page leak in svc_rdma_recv_read_chunk()
      svcrdma: Remove save_io_pages() call from send_error_msg()
      svcrdma: Add @rctxt parameter to svc_rdma_send_error() functions
      svcrdma: Add a @status parameter to svc_rdma_send_error_msg()
      svcrdma: Eliminate return value for svc_rdma_send_error_msg()
      svcrdma: Make svc_rdma_send_error_msg() a global function


 include/linux/sunrpc/svc_rdma.h         |  4 ++
 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c |  9 +--
 net/sunrpc/xprtrdma/svc_rdma_sendto.c   | 85 +++++++++++++++++--------
 3 files changed, 68 insertions(+), 30 deletions(-)

--
Chuck Lever
