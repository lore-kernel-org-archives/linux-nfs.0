Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw1-f43.google.com ([209.85.161.43]:40845 "EHLO
        mail-yw1-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726513AbeJBFPc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Oct 2018 01:15:32 -0400
Subject: Re: [PATCH v1 3/4] svcrdma: Remove try_module_get from backchannel
From: Sagi Grimberg <sagi@grimberg.me>
To: Chuck Lever <chuck.lever@oracle.com>, bfields@fieldses.org
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
References: <20181001181414.2305.94635.stgit@klimt.1015granger.net>
 <20181001181606.2305.48044.stgit@klimt.1015granger.net>
 <8924d6fb-69fd-3101-c3bc-d8e8491a3133@grimberg.me>
Message-ID: <50b18707-f08e-6d5f-1305-7b3bc8a90c2b@grimberg.me>
Date: Mon, 1 Oct 2018 15:35:28 -0700
MIME-Version: 1.0
In-Reply-To: <8924d6fb-69fd-3101-c3bc-d8e8491a3133@grimberg.me>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Would it make sense to promote this to xprt.c and remove it
> from the transports altogether?

Never mind... got it confused...
