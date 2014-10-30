Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33601 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579AbaJ3JDG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Oct 2014 05:03:06 -0400
Date: Thu, 30 Oct 2014 02:03:06 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Eryu Guan <eguan@redhat.com>
Cc: fstests@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: nfs atime semantics, was: Re: [PATCH 3/4] common: skip atime related
 tests on NFS
Message-ID: <20141030090306.GA23917@infradead.org>
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>
 <1414502171-10319-4-git-send-email-eguan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1414502171-10319-4-git-send-email-eguan@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 28, 2014 at 09:16:10PM +0800, Eryu Guan wrote:
> >From nfs(5) we can know that atime related mount options have no effect
> on NFS mounts, so add _require_atime() helper to skip atime tests on NFS

I' like to use this opportunity to start a discussion on NFS atime
handlign again, which I think is broken.  I think relatime is perfectly
fine default semantics for NFS, and not supporting it can cause all
kidns of application breakage.  Supporting normal atime semantics when
explicity requested is also something NFS shouldn't sneak out of.

> Also change the way how _require_relatime() mount $SCRATCH_DEV, use
> _scratch_mount helper so it's mounted with selinux context, to avoid
> "same superblock, different selinux context" failure.

Can you please split this part into a separate patch?

