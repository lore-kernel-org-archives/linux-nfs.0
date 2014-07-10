Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:57431 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752172AbaGJTAo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 15:00:44 -0400
Message-ID: <53BEE2E0.2080908@opengridcomputing.com>
Date: Thu, 10 Jul 2014 14:00:48 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, swise@ogc.net
CC: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH 0/2] NFS/RDMA server patches for 3.17
References: <20140710174225.3734.44692.stgit@klimt.1015granger.net>
In-Reply-To: <20140710174225.3734.44692.stgit@klimt.1015granger.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Done!

(my email is swise@opengridcomputing.com)

Steve.

On 7/10/2014 12:44 PM, Chuck Lever wrote:
> Hi Steve-
>
> Can you include these two potential 3.17 candidate patches in
> your testing branch?
>
> ---
>
> Chuck Lever (2):
>        svcrdma: Remove extra writeargs sanity check for NFSv2/3
>        svcrdma: Increase credit limit to 32
>
>
>   fs/nfsd/nfs3xdr.c               |   15 +--------------
>   fs/nfsd/nfsxdr.c                |   16 +---------------
>   include/linux/sunrpc/svc_rdma.h |    3 +--
>   3 files changed, 3 insertions(+), 31 deletions(-)
>

