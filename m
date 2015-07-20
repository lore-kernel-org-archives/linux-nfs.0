Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from p3plsmtpa06-08.prod.phx3.secureserver.net ([173.201.192.109]:45183
	"EHLO p3plsmtpa06-08.prod.phx3.secureserver.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754058AbbGTWZw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 18:25:52 -0400
Subject: Re: [PATCH v3 05/15] xprtrdma: Remove last ib_reg_phys_mr() call site
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
References: <20150720185624.10997.51574.stgit@manet.1015granger.net>
 <20150720190311.10997.12636.stgit@manet.1015granger.net>
 <55AD5B48.3010906@talpey.com> <20150720210544.GA9655@obsidianresearch.com>
 <015101d0c331$69e31d10$3da95730$@opengridcomputing.com>
 <55AD7065.8040809@talpey.com> <20150720221703.GB11356@obsidianresearch.com>
Cc: Steve Wise <swise@opengridcomputing.com>,
        "'Chuck Lever'" <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
From: Tom Talpey <tom@talpey.com>
Message-ID: <55AD758D.1080000@talpey.com>
Date: Mon, 20 Jul 2015 15:26:21 -0700
MIME-Version: 1.0
In-Reply-To: <20150720221703.GB11356@obsidianresearch.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/20/2015 3:17 PM, Jason Gunthorpe wrote:
> On Mon, Jul 20, 2015 at 03:04:21PM -0700, Tom Talpey wrote:
>> B) why bother to check? Are machines with <4GB interesting, and worth
>> supporting a special optimization?
>
> mainline drivers shouldn't silently malfunction.

I meant why bother to check, just always return failure. It's more
honest, and robust. Someone might test with 2GB, conclude it worked,
then deploy with 8GB and boom.

Also, what about hotplug RAM? Same situation.
