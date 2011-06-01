Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:21050 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758809Ab1FALzM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Jun 2011 07:55:12 -0400
Message-ID: <4DE62899.5070008@panasas.com>
Date: Wed, 01 Jun 2011 14:55:05 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCHSET final 00/32] pnfs-obj: pnfs-objects layout driver submission
References: <4DE28CFB.4060608@panasas.com> <4DE48380.4050209@panasas.com> <20110531233200.GA9935@merit.edu>
In-Reply-To: <20110531233200.GA9935@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-01 02:32, Jim Rees wrote:
> Benny Halevy wrote:
> 
>   Jim, what's the status of the blocks back-end and layout driver?
>   I'd like to add it back to the tree before the bakeathon if possible...
> 
> Sorry I've been out of touch.  Other matters have interrupted the block
> layout work, but I fully expect to have something that works by Bakeathon.
> I'm currently basing on top of Boaz's tree but will rebase as needed.

Thanks, just please use git://linux-nfs.org/~bhalevy/linux-pnfs.git
pnfs-all-latest
as your base so we maintain one place for integrating the out-of-kernel
pnfs code.

Benny

