Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw1-f47.google.com ([209.85.161.47]:42860 "EHLO
        mail-yw1-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726321AbeJBFNc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Oct 2018 01:13:32 -0400
Subject: Re: [PATCH v1 4/4] svcrdma: Increase the default connection credit
 limit
To: Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
References: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
 <20181001181611.2305.48362.stgit@klimt.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <a31d401b-bf12-fd44-5e0c-540b0cd4a9ba@grimberg.me>
Date: Mon, 1 Oct 2018 15:33:29 -0700
MIME-Version: 1.0
In-Reply-To: <20181001181611.2305.48362.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Reduce queuing on clients by allowing more credits by default.
> 
> 64 is the default NFSv4.1 slot table size on Linux clients. This
> size prevents the credit limit from putting RPC requests to sleep
> again after they have already slept waiting for a session slot.

Would it make sense to have it in a shared header with the client?

Otherwise,
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
