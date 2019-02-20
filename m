Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A24B8C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 09:37:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7E2702089F
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 09:37:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726556AbfBTJhk convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 04:37:40 -0500
Received: from smtpbgeu1.qq.com ([52.59.177.22]:50550 "EHLO smtpbgeu1.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725816AbfBTJhj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 04:37:39 -0500
X-Greylist: delayed 637 seconds by postgrey-1.27 at vger.kernel.org; Wed, 20 Feb 2019 04:37:38 EST
X-QQ-mid: bizesmtp17t1550655454ty6n2a85
Received: from [127.0.0.1] (unknown [54.242.114.255])
        by esmtp6.qq.com (ESMTP) with SMTP id 0
        for <linux-nfs@vger.kernel.org>; Wed, 20 Feb 2019 17:37:24 +0800 (CST)
X-QQ-SSF: 0110000000200070Z0K0000A0000000
X-QQ-FEAT: sHG46Uoe4MzUWNTKQmPT2UgF3k4Y8/H2OU5DI/3oDiH1vGWYRUoJZMLptCZAM
        wla/T66qL4Wd7S+f/Bct6hIZLQXQodfvffyrIipD5uPHDs5KYay/wHvCgYoWoEvFzxRWjkg
        o1eKCMpekuE75Foj3KqpPNBffFIbcP/pg8g8nCDAQX21qFhSSy6IE75DzooOJeeUXt9Nmsk
        dTYimxw5o6s3esXhqniwWM5J8VfhYQgT82J35lfp8NiLINIIzTXgvkppswrrUjH9LKD6g3K
        2X91TpJUiCpNFD
X-QQ-GoodBg: 0
From:   Pan <pan@wondercv.com>
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: 8BIT
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: File Corruption When Using Multiple Clients
Message-Id: <1AA4D3EA-0D7A-415F-B89D-40649D57FCDE@wondercv.com>
Date:   Wed, 20 Feb 2019 17:37:20 +0800
To:     linux-nfs@vger.kernel.org
X-Mailer: Apple Mail (2.3445.102.3)
X-QQ-SENDSIZE: 520
Feedback-ID: bizesmtp:wondercv.com:qybgforeign:qybgforeign4
X-QQ-Bgrelay: 1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In my NFS v4 setup using Ubuntu v18.04 I saw file corruption issue when using multiple clients.

The doc from here http://nfs.sourceforge.net/nfs-howto/ar01s07.html#file_corruption_multi_clients says that it is a 2.5 item.


What does this mean? is it still a problem and not fixed yet?

