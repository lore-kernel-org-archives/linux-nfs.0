Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb1-f178.google.com ([209.85.219.178]:37593 "EHLO
        mail-yb1-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725936AbeJBFL6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Oct 2018 01:11:58 -0400
Subject: Re: [PATCH v1 3/4] svcrdma: Remove try_module_get from backchannel
To: Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
References: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
 <20181001181606.2305.48044.stgit@klimt.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <8924d6fb-69fd-3101-c3bc-d8e8491a3133@grimberg.me>
Date: Mon, 1 Oct 2018 15:31:54 -0700
MIME-Version: 1.0
In-Reply-To: <20181001181606.2305.48044.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Since commit ffe1f0df5862 ("rpcrdma: Merge svcrdma and xprtrdma
> modules into one"), the forward and backchannel components are part
> of the same kernel module. A separate try_module_get() call in the
> backchannel code is no longer necessary.

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>

Would it make sense to promote this to xprt.c and remove it
from the transports altogether?
