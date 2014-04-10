Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:60627 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933236AbaDJHyg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 03:54:36 -0400
Message-ID: <53464DEA.2080902@mellanox.com>
Date: Thu, 10 Apr 2014 10:53:14 +0300
From: Or Gerlitz <ogerlitz@mellanox.com>
MIME-Version: 1.0
To: Devesh Sharma <devesh.sharma@emulex.com>, <linux-nfs@vger.kernel.org>
CC: <trond.myklebust@primarydata.com>
Subject: Re: [PATCH V2] NFS-RDMA: fix qp pointer validation checks
References: <1f4ed8ef-41f5-437e-9809-be52fec00df0@CMEXHTCAS2.ad.emulex.com>
In-Reply-To: <1f4ed8ef-41f5-437e-9809-be52fec00df0@CMEXHTCAS2.ad.emulex.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/04/2014 02:56, Devesh Sharma wrote:
> If the rdma_create_qp fails to create qp due to device firmware being in invalid state
> xprtrdma still tries to destroy the non-existant qp and ends up in a NULL pointer reference
> crash.
> Adding proper checks for vaidating QP pointer avoids this to happen.
>
> V0: Using IS_ERR() to check validity of qp pointer.
> V1: Use of IS_ERR() will not be able to catch NULL QP pointers as rdma_create_qp() returnes NULL in case
>      ib_create_qp verb is failed. Therefore, changed from usage of IS_ERR to null pointer check.
> V2: ib_post_send() should not abort after DECR_CQCOUNT() checking for NULL pointer was causing exit from functions
>      after decrementing CQCOUNT(). Fixed this in V2.
>
> Signed-off-by: Devesh Sharma<devesh.sharma@emulex.com>
> ---
>   net/sunrpc/xprtrdma/verbs.c |   92 ++++++++++++++++++++++++++-----------------
>   1 files changed, 56 insertions(+), 36 deletions(-)
The V0/V1/V2/etc history should be below the "---" such that it's 
stripped out by git am when the maintain picks the patch
