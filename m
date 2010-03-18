Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:58331 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab0CRVNH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Mar 2010 17:13:07 -0400
Date: Thu, 18 Mar 2010 17:13:06 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Subject: Re: [PATCH] nfsd: no need to open the file on a COMMIT call
Message-ID: <20100318211306.GA30287@infradead.org>
References: <1268940887-8556-1-git-send-email-jlayton@redhat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1268940887-8556-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 18, 2010 at 03:34:47PM -0400, Jeff Layton wrote:
> There's no need to call nfsd_open when a COMMIT call comes in over the
> wire. It doesn't really buy us anything to pass a filp into
> vfs_fsync_range.

Yes, it does.  Having the braindead calling convention with a possible
NULL file pointer is a real pain for all lower levels, and I have
patches ready to remove the last occurance of that, so please do not
introduce a new one.

