Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D00DC169C4
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 17:00:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4989420823
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 17:00:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X+nJ1IEG"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730403AbfBFRAu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 12:00:50 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:38786 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730087AbfBFRAu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2019 12:00:50 -0500
Received: by mail-it1-f196.google.com with SMTP id z20so7859010itc.3;
        Wed, 06 Feb 2019 09:00:49 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=zNJmyC1g3bD3VsuZWiXx4gUoO05oNGcXdKlfvATnNrQ=;
        b=X+nJ1IEGpQdKGsJkfkuaGC0avjMk6HQts+RsNLWYZzA8a9AG1u3FxMwGKZ31W0rlu1
         Z6mgNlyJ3D3paUonKnxj1BSdLU/VaaJEZfHuV0kGL5gCzZNLW1oRHZ6GbJX704f5/7v+
         QeRFBLjym9sgnrpMFAJbscc73SrWI0ScZmQ7XB8IQaZ+iEXejUuwt9DvdhsGjX9iDqea
         C8eH41hzyHxRGYcxe63Ult7qNUDNFG3T1HazYCq4M7Vdut+6dMPHhHMCzn7SnZ9JKHne
         3aB5nLcEJMjvDa1eE4AQnzOdlGyXDXzqi59zAaolN7RmW5Q6YC4V0+3MyuyVFHwm0eYh
         mJ7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=zNJmyC1g3bD3VsuZWiXx4gUoO05oNGcXdKlfvATnNrQ=;
        b=SsUIWKe8oA/xkjk/U29lfXs61b9qfGJegsFJj6BkJ5ZOV9wOcS7YdGVvpnCvGhrBYU
         2FLh1kFpHZxuy2w4LZeackQ1A9u37kWUkhQUr4u2h/y3EclRnuCMRB3cM5T1Ce4gZ813
         l9KIITiqjKtaQpUnn8wKPorDNWWKfk4lZK3/xVM/VTa/nEW+QrgXgKIpSpdvnWYpDwRI
         mKVaUS7DXLNFL3fqw8kr0DGpWdfqY1NreI6IftvKJJ6dGQxGCy22RevZ7xxFfePGOhPc
         J9mGBld5jtkzn9egAAY1/nxiGEtaAcNo8cdFuTuq1cC1jnoAJOqQ+BRS0POK0d15mTns
         diJw==
X-Gm-Message-State: AHQUAubqsCmUmb/G+tLeRt9I4UHKjJZorKnlvzUgego4YD8EW6R4PpB1
        dnZvzF3MJaW79ZKUZnyJylDMckCQ
X-Google-Smtp-Source: AHgI3IYTqGx6JekZ5IKuYhGXFX+nmwxEgYG5kPI1u8tRGd3LS7TVAvfrTHskvKHhdJo7gup5ilIqlw==
X-Received: by 2002:a24:5946:: with SMTP id p67mr2962465itb.46.1549472448629;
        Wed, 06 Feb 2019 09:00:48 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 18sm3926953itk.28.2019.02.06.09.00.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 09:00:47 -0800 (PST)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x16H0kNq016039;
        Wed, 6 Feb 2019 17:00:46 GMT
Subject: [PATCH 1 0/2] Two small clean-ups for v5.1
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Wed, 06 Feb 2019 12:00:46 -0500
Message-ID: <20190206170018.27481.32275.stgit@klimt.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Bruce-

Please consider these two commits for the v5.1 merge window.

---

Chuck Lever (2):
      svcrdma: Squelch compiler warning when SUNRPC_DEBUG is disabled
      svcrdma: Remove syslog warnings in work completion handlers


 net/sunrpc/xprtrdma/svc_rdma_recvfrom.c  |    9 +--------
 net/sunrpc/xprtrdma/svc_rdma_rw.c        |   11 +----------
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    |    4 ----
 net/sunrpc/xprtrdma/svc_rdma_transport.c |    9 +++------
 4 files changed, 5 insertions(+), 28 deletions(-)

--
Chuck Lever
