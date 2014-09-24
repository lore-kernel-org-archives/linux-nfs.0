Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:59485 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688AbaIXL4D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 07:56:03 -0400
Received: by mail-wg0-f44.google.com with SMTP id z12so2229127wgg.15
        for <linux-nfs@vger.kernel.org>; Wed, 24 Sep 2014 04:56:01 -0700 (PDT)
Message-ID: <5422B14C.3040502@dev.mellanox.co.il>
Date: Wed, 24 Sep 2014 14:55:56 +0300
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
MIME-Version: 1.0
To: Steve Wise <swise@opengridcomputing.com>, fields@fieldses.org
CC: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH V3] svcrdma: advertise the correct max payload
References: <20140923221122.24227.91718.stgit@build.ogc.int>
In-Reply-To: <20140923221122.24227.91718.stgit@build.ogc.int>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 9/24/2014 1:11 AM, Steve Wise wrote:
> Svcrdma currently advertises 1MB, which is too large.  The correct value
> is the minimum of RPCSVC_MAXPAYLOAD and the max scatter-gather allowed
> in an NFSRDMA IO chunk * the host page size. This bug is usually benign
> because the Linux X64 NFSRDMA client correctly limits the payload size to
> the correct value (64*4096 = 256KB).  But if the Linux client is PPC64
> with a 64KB page size, then the client will indeed use a payload size
> that will overflow the server.
>

Maybe I'm a bit late with this, but can you explain why SG table is
limited to 64 (fastreg MR and page_list probably bound it). Where is it
coming from? Naturally it needs to be bound by some figure, but why 64?

Sorry if I'm nit-picking on this pretty straight-forward bug fix...

Sagi.
