Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3D48C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 15:45:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 62F7920851
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 15:45:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Y3wAr7qD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62F7920851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729848AbeKTCJq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Nov 2018 21:09:46 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:38113 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729795AbeKTCJq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2018 21:09:46 -0500
Received: by mail-it1-f195.google.com with SMTP id h65so4792251ith.3;
        Mon, 19 Nov 2018 07:45:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=sHeXdeYDJfmJMxdq0DOSADhAUlv2l8y7xBalNmKFRJk=;
        b=Y3wAr7qDFBZEKgzTubuCzl9wTcnS6zA+iMCFBaauQ6i/31RFYno4/VepFAMRcbzGzG
         k7um6oM4IPZtOppvxaei6LipKKD2as4GXlEQ5ufGaaxq1JN2NsJD7FjunBaJ1T24MSk5
         NvtH86EQVNAKQLi2ydwerBPNoFhHYP2tFINKYxkdqm5fNJnp+KvCshxYjZ3VonSrZEex
         1AUEZXz6MO8SUf9woVlfjE5XdFBLOH1hECnYki/3QZAvShHZUmXFh8Y6nXH4zlfuw9t7
         iT6f66IViATwMyghyW+15SXDfbOB5rHeWWxEkSezXHJpMvfem0lFz+9C7SbT11/Oiccm
         vnIA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=sHeXdeYDJfmJMxdq0DOSADhAUlv2l8y7xBalNmKFRJk=;
        b=aW9m0/Ih1VnDsdOCk+Qn0vZirzt7Csn5DNl/ri+oBpVqb0vCiVgCcPDO5xr7uDoTVR
         Wqa7nar1eXeIrDQn5xqnFQtQ9V5J6G2eEwrz/T/uogne9wSmegp9shQRXcNuw8vbbvlf
         yhI1JfV+VZ0Zcrh9FXkCmhyaVQyBowrUEwfD98t8r0xIOG7t61jLQIWXHVYam9iJYssa
         C6RHTzKryrpenh7Ex6AnSO5PN1T03byxq4bRgMZamoPCL6qYPZ3XgABjMOjYZkxUQJrg
         p1SqXgTZXd0B+GMd8OC1Lq0XVcY8EmQHvjSrBtEb8OT8Taz+ldZHD6niVV12mwcRrS/k
         YFaw==
X-Gm-Message-State: AGRZ1gIQzIPUaZSdJ5+yYV2IE4uN6c2dgiHLM3cIrkh3jgOAxmDiO89L
        ltFuzrlASUysXl6WZUCvJwjZNApS
X-Google-Smtp-Source: AJdET5eD0XX1B36pThXPvYWc0xKJ2CUjK1QR/lGdJUxKIMlo8iqfFAbZCQDpNPSQnDolk/VthD3yAA==
X-Received: by 2002:a02:a906:: with SMTP id n6mr19554068jam.123.1542642347687;
        Mon, 19 Nov 2018 07:45:47 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id f133-v6sm14499206itf.10.2018.11.19.07.45.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 07:45:46 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAJFjjaa022996;
        Mon, 19 Nov 2018 15:45:45 GMT
Subject: [PATCH v1 0/4] NFS/RDMA client for v4.21 (part 1)
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org
Date:   Mon, 19 Nov 2018 10:45:45 -0500
Message-ID: <20181119153707.10832.42881.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi-

These four patches changes details of how the Linux RPC-over-RDMA
client implementation uses RDMA, thus I'd like some scrutiny by the
good people on linux-rdma.

I've got a dozen or so additional patches for v4.21 dealing with the
higher layers which I will post next week. I will aim those at
linux-nfs.

---

Chuck Lever (4):
      xprtrdma: Remove support for FMR memory registration
      xprtrdma: mrs_create off-by-one
      xprtrdma: Reduce max_frwr_depth
      xprtrdma: Plant XID in on-the-wire RDMA offset (FRWR)


 net/sunrpc/xprtrdma/Makefile    |    3 
 net/sunrpc/xprtrdma/fmr_ops.c   |  337 ---------------------------------------
 net/sunrpc/xprtrdma/frwr_ops.c  |   20 ++
 net/sunrpc/xprtrdma/rpc_rdma.c  |    6 -
 net/sunrpc/xprtrdma/verbs.c     |    6 -
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 
 6 files changed, 19 insertions(+), 355 deletions(-)
 delete mode 100644 net/sunrpc/xprtrdma/fmr_ops.c

--
Chuck Lever
