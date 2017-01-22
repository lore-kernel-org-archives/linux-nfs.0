Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50240 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750741AbdAVQy3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 22 Jan 2017 11:54:29 -0500
From: Christoph Hellwig <hch@lst.de>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: setattr ATTR_SIZE vs the rest
Date: Sun, 22 Jan 2017 17:54:19 +0100
Message-Id: <1485104060-15209-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

I've got a report that there NFS clients that send SETATTR requests that
mix size changes with uid/gid changes (see the recent pynfs patch for an
artifical reproducer).  At least XFS and GFS2 are very unhappy with this,
and other file systems also don't seem to handle the case correctly.

This patch splits the truncate processing in NFS out into a separate
->setattr call and uses the vfs_truncate helper for it, which also happens
to shrink the NFSD code size by reusing more VFS boiler plate code.

I suspect in the mid-term we really should add a ->truncate method (different
from the previous callback of the same name) to separate the two concepts
clearly at the VFS level.

