Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:43547 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752030AbbGXWin (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Jul 2015 18:38:43 -0400
Date: Fri, 24 Jul 2015 16:38:35 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Steve Wise <swise@opengridcomputing.com>
Cc: dledford@redhat.com, infinipath@intel.com, sagig@mellanox.com,
        ogerlitz@mellanox.com, roid@mellanox.com, linux-rdma@vger.kernel.org,
        eli@mellanox.com, target-devel@vger.kernel.org,
        linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH V6 9/9] isert: Support iWARP transports using FRMRs
Message-ID: <20150724223835.GA29064@obsidianresearch.com>
References: <20150724161331.25617.8475.stgit@build2.ogc.int>
 <20150724161904.25617.85015.stgit@build2.ogc.int>
 <20150724165721.GC25480@obsidianresearch.com>
 <00ce01d0c641$493ea300$dbbbe900$@opengridcomputing.com>
 <20150724192411.GC26225@obsidianresearch.com>
 <00db01d0c64b$01f40300$05dc0900$@opengridcomputing.com>
 <00ee01d0c65d$a1e03cf0$e5a0b6d0$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <00ee01d0c65d$a1e03cf0$e5a0b6d0$@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 24, 2015 at 05:11:04PM -0500, Steve Wise wrote:

> By the way, just to be clear: If you use a FRWR, you by definition
> only have one SGE entry as the result of the registration.  So
> regardless of what a device/protocol can do with the destination SGE
> of an RDMA READ operation, if you use FRWR to register the
> destination region, you need only 1 SGE in the RDMA READ WR.

FRWR's have horrible restrictions on the scatterlist. To realize
arbitrary scatterlists requires multiple MRs, and thus multiple SGE
entries.

The warning is for a reader who might be familiar with IB and think
iWarp simply needs to have a MR wrapped around the memory and assume
gaps/etc can be supported through a s/g list, like IB can.

Jason
