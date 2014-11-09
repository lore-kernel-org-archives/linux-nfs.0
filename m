Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f175.google.com ([209.85.212.175]:62357 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312AbaKIKNb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Nov 2014 05:13:31 -0500
Received: by mail-wi0-f175.google.com with SMTP id ex7so8010172wid.14
        for <linux-nfs@vger.kernel.org>; Sun, 09 Nov 2014 02:13:29 -0800 (PST)
Message-ID: <545F3E46.9040703@dev.mellanox.co.il>
Date: Sun, 09 Nov 2014 12:13:26 +0200
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 02/10] xprtrdma: Cap req_cqinit
References: <20141109010328.8806.5861.stgit@manet.1015granger.net> <20141109011420.8806.1849.stgit@manet.1015granger.net>
In-Reply-To: <20141109011420.8806.1849.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/9/2014 3:14 AM, Chuck Lever wrote:
> Recent work made FRMR registration and invalidation completions
> unsignaled. This greatly reduces the adapter interrupt rate.
>
> Every so often, however, a posted send Work Request is allowed to
> signal. Otherwise, the provider's Work Queue will wrap and the
> workload will hang.
>
> The number of Work Requests that are allowed to remain unsignaled is
> determined by the value of req_cqinit. Currently, this is set to the
> size of the send Work Queue divided by two, minus 1.
>
> For FRMR, the send Work Queue is the maximum number of concurrent
> RPCs (currently 32) times the maximum number of Work Requests an
> RPC might use (currently 7, though some adapters may need more).
>
> For mlx4, this is 224 entries. This leaves completion signaling
> disabled for 111 send Work Requests.
>
> Some providers hold back dispatching Work Requests until a CQE is
> generated.  If completions are disabled, then no CQEs are generated
> for quite some time, and that can stall the Work Queue.
>
> I've seen this occur running xfstests generic/113 over NFSv4, where
> eventually, posting a FAST_REG_MR Work Request fails with -ENOMEM
> because the Work Queue has overflowed. The connection is dropped
> and re-established.

Hey Chuck,

As you know, I've seen this issue too...
Looking into this is definitely on my todo list.

Does this happen if you run a simple dd (single request-response inflight)?

Sagi.
