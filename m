Return-Path: <SRS0=OKGc=TX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CA5DC282DD
	for <linux-nfs@archiver.kernel.org>; Thu, 23 May 2019 23:32:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 020052133D
	for <linux-nfs@archiver.kernel.org>; Thu, 23 May 2019 23:32:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388195AbfEWXce (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 23 May 2019 19:32:34 -0400
Received: from shards.monkeyblade.net ([23.128.96.9]:55056 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2387693AbfEWXcd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 May 2019 19:32:33 -0400
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::3d8])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 4E5F4149CD336;
        Thu, 23 May 2019 16:32:32 -0700 (PDT)
Date:   Thu, 23 May 2019 16:32:29 -0700 (PDT)
Message-Id: <20190523.163229.1499181553844972278.davem@davemloft.net>
To:     gustavo@embeddedor.com
Cc:     chuck.lever@oracle.com, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@kernel.org, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH net-next] xprtrdma: Use struct_size() in kzalloc()
From:   David Miller <davem@davemloft.net>
In-Reply-To: <70ca0dea-6f1f-922c-7c5d-e79c6cf6ecb5@embeddedor.com>
References: <07CB966E-A946-4956-8480-C0FC13E13E4E@oracle.com>
        <ad9eccc7-afd2-3419-b886-6210eeabd5b5@embeddedor.com>
        <70ca0dea-6f1f-922c-7c5d-e79c6cf6ecb5@embeddedor.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Thu, 23 May 2019 16:32:32 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Date: Thu, 23 May 2019 17:36:00 -0500

> Hi Dave,
> 
> I wonder if you can take this patch.

The sunrpc/nfs maintainer should take this.  I never take patches in that
area.
