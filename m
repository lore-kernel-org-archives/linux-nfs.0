Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:45566 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbaJ1NYH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Oct 2014 09:24:07 -0400
Date: Tue, 28 Oct 2014 06:24:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eryu Guan <eguan@redhat.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/4] common: add _require_block_device() helper
Message-ID: <20141028132406.GC26453@infradead.org>
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>
 <1414502171-10319-3-git-send-email-eguan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414502171-10319-3-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 28, 2014 at 09:16:09PM +0800, Eryu Guan wrote:
> Add _require_block_device() helper and use it in _require_dm_flakey()
> and generic/076.
> 
> _require_dm_flakey() assumes $SCRATCH_DEV is a block device, now it can
> also be a NFS export.
> 
> generic/076 does "cat $SCRATCH_DEV" which will fail when testing on NFS.

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
