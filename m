Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37304 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753396AbbKXOoh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 09:44:37 -0500
Received: by wmww144 with SMTP id w144so29437693wmw.0
        for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2015 06:44:35 -0800 (PST)
Subject: Re: [PATCH v1 3/9] xprtrdma: Introduce ro_unmap_sync method
To: Chuck Lever <chuck.lever@oracle.com>
References: <20151123220627.32702.62667.stgit@manet.1015granger.net>
 <20151123221414.32702.87638.stgit@manet.1015granger.net>
 <20151124064556.GA29141@infradead.org> <565442F5.7080400@dev.mellanox.co.il>
 <4B2D7C66-31AC-44F3-A8CC-22CC7136015C@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Sagi Grimberg <sagig@mellanox.com>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <565477CC.5070309@dev.mellanox.co.il>
Date: Tue, 24 Nov 2015 16:44:28 +0200
MIME-Version: 1.0
In-Reply-To: <4B2D7C66-31AC-44F3-A8CC-22CC7136015C@oracle.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

>
>> It is painful, too painful. The entire value proposition of RDMA is
>> low-latency and waiting for the extra HW round-trip for a local
>> invalidation to complete is unacceptable, moreover it adds a huge loads
>> of extra interrupts and cache-line pollutions.
>
> The killer is the extra context switches, I’ve found.

That too...

> I’ve noticed only a marginal loss of performance on modern
> hardware.

Would you mind sharing your observations?
