Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46431 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933088AbaEGPCt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 May 2014 11:02:49 -0400
Date: Wed, 7 May 2014 08:02:46 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Ben Greear <greearb@candelatech.com>,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Crash in 3.14.0+ (plus hacks)
Message-ID: <20140507150246.GA19702@infradead.org>
References: <5346D22A.10102@candelatech.com>
 <20140425104803.GD22295@fieldses.org>
 <20140425110409.GA27561@infradead.org>
 <2191C93E-A3D0-493B-8459-931CE9C59B53@oracle.com>
 <536A386E.4070202@candelatech.com>
 <0D281678-A961-45B0-B1D7-49BDE6B3FC5C@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0D281678-A961-45B0-B1D7-49BDE6B3FC5C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 07, 2014 at 10:31:10AM -0400, Chuck Lever wrote:
> > Probably it should be submitted to stable??
> 
> Christoph has a broader fix for this issue, which affects more than
> just tmpfs. Stay tuned.

The fix has just made it into Linus' tree.  I added a Cc: stable
tag, so it should get picked up soon.

