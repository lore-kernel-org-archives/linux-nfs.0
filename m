Return-Path: <SRS0=vPHX=PY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08C72C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 18:22:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CF5D1206C2
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 18:22:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SdE/EQ9A"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728450AbfAPSWD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Jan 2019 13:22:03 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:34014 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728405AbfAPSWC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2019 13:22:02 -0500
Received: by mail-it1-f193.google.com with SMTP id x124so1652725itd.1;
        Wed, 16 Jan 2019 10:22:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=jAPZcKM2uj+5oS3LOOM+tXAdQscEybU7SOVFacMTHJk=;
        b=SdE/EQ9A+cXZzeYo34Ow3hXqsxiCxAAoTlHhWeauD5GBP0uKNJ1xkNMu1sjucAn7gE
         Tt7wrhqQa2HfNrz+PrHiuvdyKqt41nrwwm4j5vnMujdTJCY9mXt7dBkl6QSQ4rf7h5cP
         nM37gC4XecTeYUYQ4lsh/Jy1Ep6swn0qq7Gkn3f0xa0e++7vdLh9T+dN1/r3abVxDGSz
         iUcjUMoPi2rszk36/bOT5TFde9a2Is8ZcrWD3qifqZnAROeKyI2abb9n5CQwkmrNsh19
         Le8G4nkHpwGq+NhfWMHz0uxN6ICobYeBo1sWxq28Dg4DeUYmqt7LSQ1Y0/aA+WrDm6qN
         YVSg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=jAPZcKM2uj+5oS3LOOM+tXAdQscEybU7SOVFacMTHJk=;
        b=eiypynE8pL6Y4zMfFslENtifOThB2mUXKr7zAAucKWkqrrKgXTWdKgHcK8jsj//8Z5
         FPFT+H2aTUt6ta9iBEuUTBclnRzY1bU5zuSmSzS/LzthEd+yVrWSNxJn3UbAnOln4aP8
         p5BzTVMlH8hzFcj1wtljmn0jZK9s2m7rPwBjHxqotaCMzvVy+37tiybo16Ezqpjgls3x
         HLgqT4yupIS/qcVBDo9BsAQEyIRgbo2IkohWta73bngLIdxwLTcXsialLAWjApn3qGJj
         UfwAcBwsqSe9TXi9RZpspQtvPefDOWBGdC9so47UyxYGVsz772cTeFsKDk2nkMLOdSJP
         jwmw==
X-Gm-Message-State: AJcUukcJKt08Y/ZepbhzvcRamtFb2QCdftTSdsoz31FsESMtlIWmkuML
        jY4WeENeGh+J7mWn5BWvGV+QqYDr
X-Google-Smtp-Source: ALg8bN5a2r3bz8xMAYB9v4Ufc4+K2xHiBKrKiLEgZoGeED0DgQGU9165QwjMof9BxUJ0xcYo1Wy4zQ==
X-Received: by 2002:a24:2f08:: with SMTP id j8mr6936588itj.42.1547662921911;
        Wed, 16 Jan 2019 10:22:01 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w24sm2458470ioc.11.2019.01.16.10.22.01
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 10:22:01 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x0GIM0cC013767;
        Wed, 16 Jan 2019 18:22:00 GMT
Subject: [PATCH RFC 0/2] NFS/RDMA changes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 16 Jan 2019 13:22:00 -0500
Message-ID: <20190116181954.4345.87842.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Here are two NFS-RDMA-related patches I'd like to see in kernel
v5.1. Thanks in advance for review and comments.

---

Chuck Lever (2):
      xprtrdma: Check inline size before providing a Write chunk
      xprtrdma: Reduce the doorbell rate (Receive)


 net/sunrpc/xprtrdma/rpc_rdma.c  |   18 +++++++++++++++++-
 net/sunrpc/xprtrdma/verbs.c     |    2 ++
 net/sunrpc/xprtrdma/xprt_rdma.h |   11 +++++++++++
 3 files changed, 30 insertions(+), 1 deletion(-)

--
Chuck Lever
