Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59830 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbcB2NYL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Feb 2016 08:24:11 -0500
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: pNFS SCSI layout support
Date: Mon, 29 Feb 2016 14:24:04 +0100
Message-Id: <1456752247-6549-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series adds support the pNFS SCSI layout to both the NFS server
and client.  It's a fairly simple extension to the existing block
layout drivers, which relies on the Persistent Reservation API in
the block layer merged a while ago.

On the server side we will now always export SCSI devices a SCSI
layout.  I though about allowing exports of multiple layour types
for the same file system, but both the not really production ready
nature of block layout fencing, and the horrors of passing options
to NFS exports made me go with the simple way for now.

