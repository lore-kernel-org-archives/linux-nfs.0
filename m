Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:42370 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751267AbdAMWE7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 17:04:59 -0500
Subject: Re: [PATCH v1 00/22] convert NFS server to new rdma_rw API
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <768367c2-77b5-edfb-a787-658dd7d5084f@grimberg.me>
Date: Sat, 14 Jan 2017 00:04:52 +0200
MIME-Version: 1.0
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

> This series converts the Linux NFS server RPC-over-RDMA
> implementation to use the new core rdma_rw API and to poll its CQs
> in workqueue mode.

Great to see this happening!

I'll try and have a look early next week.
Hope to see a simpler code with the new API.
