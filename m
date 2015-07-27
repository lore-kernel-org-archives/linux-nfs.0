Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:37892 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbbG0RH6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jul 2015 13:07:58 -0400
Date: Mon, 27 Jul 2015 11:07:46 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Sagi Grimberg <sagig@dev.mellanox.co.il>
Cc: Steve Wise <swise@opengridcomputing.com>, dledford@redhat.com,
        infinipath@intel.com, sagig@mellanox.com, ogerlitz@mellanox.com,
        roid@mellanox.com, linux-rdma@vger.kernel.org, eli@mellanox.com,
        target-devel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bfields@fieldses.org
Subject: Re: [PATCH V6 9/9] isert: Support iWARP transports using FRMRs
Message-ID: <20150727170746.GB18348@obsidianresearch.com>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161904.25617.85015.stgit@build2.ogc.int>
 <20150724165721.GC25480@obsidianresearch.com>
 <00ce01d0c641$493ea300$dbbbe900$@opengridcomputing.com>
 <20150724192411.GC26225@obsidianresearch.com>
 <55B4B510.8050106@dev.mellanox.co.il>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55B4B510.8050106@dev.mellanox.co.il>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 26, 2015 at 01:23:12PM +0300, Sagi Grimberg wrote:

> Question though, wouldn't it be better to do a single RDMA_READ to say
> 4 registered keys rather than RDMA_READ_WITH_INV for each?

RDMA READ is limted to 1 sg in iWarp.

RDMA_READ_WITH_INV and 1 sg is really the only correct way to drive
iWarp.

Jason
