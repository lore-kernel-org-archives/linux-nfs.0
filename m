Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35317 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755185AbbITKMb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Sep 2015 06:12:31 -0400
Received: by wicge5 with SMTP id ge5so80703856wic.0
        for <linux-nfs@vger.kernel.org>; Sun, 20 Sep 2015 03:12:30 -0700 (PDT)
Subject: Re: [PATCH rdma-rc 1/4] xprtrdma: Remove ib_get_dma_mr calls
References: <1442742767-8755-1-git-send-email-sagig@mellanox.com>
 <1442742767-8755-2-git-send-email-sagig@mellanox.com>
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        Eli Cohen <eli@mellanox.com>, linux-nfs <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55FE86A2.4010604@dev.mellanox.co.il>
Date: Sun, 20 Sep 2015 13:12:50 +0300
MIME-Version: 1.0
In-Reply-To: <1442742767-8755-2-git-send-email-sagig@mellanox.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/20/2015 12:52 PM, Sagi Grimberg wrote:
> since commit 96249d70dd70 ("IB/core:
> Guarantee that a local_dma_lkey is available") The PD now
> has a local_dma_lkey member which completely replaces
> ib_get_dma_mr, use it instead.
>
> In FRWR memreg mode, we assumed that the device local_dma_lkey
> is available.

Chuck,

I just noticed that this is (almost) identical to your 02/18 RFC patch.
Would you mind if I send v1 with your patch to 4.3-rc (given xprtrdma
would break over mlx5 without it)?

Sagi.
