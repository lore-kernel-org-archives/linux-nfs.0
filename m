Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47747 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756222Ab3KFMQO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Nov 2013 07:16:14 -0500
Date: Wed, 6 Nov 2013 04:16:14 -0800
From: Christoph Hellwig <hch@infradead.org>
To: linux-nfs@vger.kernel.org
Cc: xfs@oss.sgi.com
Subject: atime reporting issues
Message-ID: <20131106121614.GA13530@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xfstest 193 fail on NFS because it can't find out that nfs has noatime
behavior.  Part of the bug is that xfstests check the mount flags it
explicitly passes, but even one that is fixed NFS seems to claim having
relatime behavior in /proc/self/mounts.
