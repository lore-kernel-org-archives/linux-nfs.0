Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33415 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432AbcDZUMt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 16:12:49 -0400
Subject: Re: [PATCH v2 11/18] xprtrdma: Save I/O direction in struct
 rpcrdma_frwr
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192218.3566.13233.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <571FCBBD.9070200@grimberg.me>
Date: Tue, 26 Apr 2016 23:12:45 +0300
MIME-Version: 1.0
In-Reply-To: <20160425192218.3566.13233.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> Move the the I/O direction field from rpcrdma_mr_seg into the
> rpcrdma_frmr. This makes it possible to perform the DMA unmapping
> long after the rpcrdma_mr_seg has been released and re-used.

A little explanation on why this is desired/useful would help understand
this patch.
