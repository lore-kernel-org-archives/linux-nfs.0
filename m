Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:40638 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753283AbcHAN3d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Aug 2016 09:29:33 -0400
Date: Mon, 1 Aug 2016 06:28:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: xfstests generic/285 fails reliably on Trond's linux-next branch
Message-ID: <20160801132856.GA26191@infradead.org>
References: <20160721081802.GA14413@infradead.org>
 <20160728144641.GA28753@infradead.org>
 <d67d77f3-9df9-4f02-354b-85cc46a5f9c5@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <d67d77f3-9df9-4f02-354b-85cc46a5f9c5@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 28, 2016 at 03:36:04PM -0400, Anna Schumaker wrote:
> What mount options are you using?  The test passes for me on xfs, btrfs, and ext4.

No mount options at all - just forcing 4.2 with a small patch to
super.c.

I've tried to bisect the issue, but I now see it with Linux 4.7-rc2 as
well.  I did upgrade xfstests in the meantime, so I'll see if that
caused the issue, or if it's something that's new in Linux 4.7-rc2 and
Tronds earlier tree was using an older baseline.
