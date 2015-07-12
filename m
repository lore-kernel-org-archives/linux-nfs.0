Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:33819 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbbGLOb0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jul 2015 10:31:26 -0400
Received: by wgkl9 with SMTP id l9so8731707wgk.1
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 07:31:25 -0700 (PDT)
Subject: Re: [PATCH v1 03/12] xprtrdma: Increase default credit limit
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204208.26247.52073.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55A27A3B.8000302@dev.mellanox.co.il>
Date: Sun, 12 Jul 2015 17:31:23 +0300
MIME-Version: 1.0
In-Reply-To: <20150709204208.26247.52073.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/9/2015 11:42 PM, Chuck Lever wrote:
> In preparation for similar increases on NFS/RDMA servers, bump the
> advertised credit limit for RPC/RDMA to 128. This allocates some
> extra resources, but the client will continue to allow only the
> number of RPCs in flight that the server requests via its advertised
> credit limit.
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Looks good,

Reviewed-By: Sagi Grimberg <sagig@mellanox.com>
