Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:20352 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751504AbcG1TgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2016 15:36:22 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: xfstests generic/285 fails reliably on Trond's linux-next branch
To: Christoph Hellwig <hch@infradead.org>, <trond.myklebust@primarydata.com>
References: <20160721081802.GA14413@infradead.org>
 <20160728144641.GA28753@infradead.org>
CC: <linux-nfs@vger.kernel.org>
Message-ID: <d67d77f3-9df9-4f02-354b-85cc46a5f9c5@Netapp.com>
Date: Thu, 28 Jul 2016 15:36:04 -0400
MIME-Version: 1.0
In-Reply-To: <20160728144641.GA28753@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

On 07/28/2016 10:46 AM, Christoph Hellwig wrote:
> On Thu, Jul 21, 2016 at 01:18:02AM -0700, Christoph Hellwig wrote:
>> Now that 207 is fixed the next test starts failing..  285 is
>> the SEEK_HOLE/DATA sanity check, which might help with figuring out
>> which of the recent changes introduced it.
> 
> A week later this still fails with the linux-next branch. Plain NFSv4.2
> against a Linux/XFS server.  The 285.full file documenting the failures
> is attached below:
> 

What mount options are you using?  The test passes for me on xfs, btrfs, and ext4.

Thanks,
Anna
