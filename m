Return-Path: <SRS0=W40c=ZM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71EF0C432C0
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Nov 2019 21:25:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 41F202084D
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Nov 2019 21:25:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="n7uxqYPN"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725904AbfKTVZo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Nov 2019 16:25:44 -0500
Received: from mail-yb1-f174.google.com ([209.85.219.174]:46960 "EHLO
        mail-yb1-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725878AbfKTVZo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Nov 2019 16:25:44 -0500
Received: by mail-yb1-f174.google.com with SMTP id v15so570031ybp.13
        for <linux-nfs@vger.kernel.org>; Wed, 20 Nov 2019 13:25:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=WVi4oSWe7+SpxsHStDNbF3mMxy2lRIz4cgivGbYQsVM=;
        b=n7uxqYPN5dSCWlipaRWx+1bxQOWPcBsf+eX9g/w4jwws1cUAqbMdUSzPBAG6Ha56Qw
         jlCgVdrOFhV3b57GZKOtmtNQcbily2KjY1AQEz30lbc/9OOADMLhhzZjDsW2qXp+PUpC
         Yyp0UJLnVBYqiduJh8T172QFby9bZYcEkFC2bdLfZyeDxc19ri4qDjtXKzr6rADgltXF
         5b2K87RhWd/TQg7YODaLyueR6Ohm64/MJZ2GUZCvc77WuUTEzggoIUZJ1kUX6H2moSl2
         /QRW5WdBOne2Q0CrxTmbYzc4SyOhFeFurlORu4WpPgrW+Mjwg3nO0teY0NUwwwUjucx5
         ELpA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :user-agent:mime-version:content-transfer-encoding;
        bh=WVi4oSWe7+SpxsHStDNbF3mMxy2lRIz4cgivGbYQsVM=;
        b=HsmccuCdE1nKrnEXbOiD7gcy4fKmbO2h4Y/4/rO7JPuirLsUR6jJ23OkbEq9I5kdQZ
         xJGBrH/1Kl24b3nSh+TIfQSigQkfnqcjEu/XzaDIWLlSAp4C+PDrYICQ2ecjFLZjAfuu
         XJznth1E0PQvoW1+5+X9fyMzF5NakjxKx0Sg9iWRd1xiRvTtiNmhfy2Mj9XvjtradhP1
         WeimzzPwb3RVS3TXVJIU7bPFbvzmfg4KV0VSmnb2YI+IpzhrmfLIFHdkHrE51hWUAdlr
         FURQQn+4PT7I88VBMpV2j6MK6LO6sN1x1tTfqGt2ufjaBSGJErc6GW/RLZjhXiy9vA+D
         Nu9w==
X-Gm-Message-State: APjAAAU2ymzYWZSxr1YUIwOFpQ2cY7vvsQQnuwGuyDLwov/3/IjBZch1
        A1PtbTQotfDEGk1wE2MfVNc=
X-Google-Smtp-Source: APXvYqzO5Pz5szs+mVnNQUSp+7APU6qTW2natdpIDdHVS/8jZ4z7qKr6xl/qLQ3rmdQm8gANOkWDYQ==
X-Received: by 2002:a25:da45:: with SMTP id n66mr3553461ybf.61.1574285143646;
        Wed, 20 Nov 2019 13:25:43 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id y204sm277276ywg.67.2019.11.20.13.25.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Nov 2019 13:25:43 -0800 (PST)
Received: from klimt.1015granger.net (klimt.1015granger.net [192.168.1.55])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id xAKLPeg0016814;
        Wed, 20 Nov 2019 21:25:40 GMT
Subject: [PATCH v1 0/2] Two more trace point fixes
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org, trond.myklebust@primarydata.com,
        anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Date:   Wed, 20 Nov 2019 16:25:40 -0500
Message-ID: <20191120212443.2140.88674.stgit@klimt.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Found these today while testing NFS/RDMA patches.

---

Chuck Lever (2):
      SUNRPC: Fix backchannel latency metrics
      SUNRPC: Capture completion of all RPC tasks


 include/trace/events/sunrpc.h              |    1 +
 net/sunrpc/sched.c                         |    1 +
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c |    1 +
 net/sunrpc/xprtsock.c                      |    3 ++-
 4 files changed, 5 insertions(+), 1 deletion(-)

--
Chuck Lever
