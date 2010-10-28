From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] [bz 192] Fixed Regression in NFS Direct I/O path
Date: Thu, 28 Oct 2010 08:38:59 -0400
Message-ID: <20101028123859.GA28972@infradead.org>
References: <1288268274-9444-1-git-send-email-steved@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:35250 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758659Ab0J1Mi7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 08:38:59 -0400
In-Reply-To: <1288268274-9444-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 28, 2010 at 08:17:54AM -0400, Steve Dickson wrote:
> A typo, introduced by commit f11ac8db, in the nfs_direct_write()
> routine causes writes with O_DIRECT set to fail with a ENOMEM error.

I guess someone should run xfstests on nfs more regularly :)

