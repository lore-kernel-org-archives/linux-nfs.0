Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:45555 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab1ADGHY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Jan 2011 01:07:24 -0500
Date: Tue, 4 Jan 2011 01:07:23 -0500
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3/4] locks: eliminate fl_mylease callback
Message-ID: <20110104060723.GA15158@infradead.org>
References: <1294110419-3105-1-git-send-email-bfields@redhat.com>
 <1294110419-3105-4-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1294110419-3105-4-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 03, 2011 at 10:06:58PM -0500, J. Bruce Fields wrote:
> The nfs server only supports read delegations for now, so we don't care
> how conflicts are determined.  All we care is that unlocks are
> recognized as matching the leases they are meant to remove.  After the
> last patch, a comparison of struct files will work for that purpose.  So
> we no longer need this callback.

Please also update Documentation/filesystems/Locking for method
removals.

