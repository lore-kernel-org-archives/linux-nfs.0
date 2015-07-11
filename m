Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:36578 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbbGKSvE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Jul 2015 14:51:04 -0400
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2102\))
Subject: Re: [PATCH v1 04/12] xprtrdma: Remove last ib_reg_phys_mr() call site
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20150711103428.GD14741@infradead.org>
Date: Sat, 11 Jul 2015 14:50:58 -0400
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <682604AF-955A-44F8-86F9-EB7D403CABFF@gmail.com>
References: <20150709203242.26247.4848.stgit@manet.1015granger.net> <20150709204218.26247.67243.stgit@manet.1015granger.net> <20150711103428.GD14741@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 11, 2015, at 6:34 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Thu, Jul 09, 2015 at 04:42:18PM -0400, Chuck Lever wrote:
>> All HCA providers have an ib_get_dma_mr() verb. Thus
>> rpcrdma_ia_open() will either grab the device's local_dma_key if one
>> is available, or it will call ib_get_dma_mr() which is a 100%
>> guaranteed fallback. There is never any need to use the
>> ib_reg_phys_mr() code path in rpcrdma_register_internal(), so it can
>> be removed.
> 
> Can you also send a follow-on to remove ib_reg_phys_mr entirely from
> all core (= non-staging) code?

I would prefer to run this by Doug Oucharek first, as a courtesy.
Unless I’m mistaken, the Lustre client is supposed to be on its
way into the kernel, not on its way out.

Anyone have Doug’s e-mail address?


--
Chuck Lever
chucklever@gmail.com



