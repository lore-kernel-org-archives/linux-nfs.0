Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46863 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759267AbcCDTqW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2016 14:46:22 -0500
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: pNFS SCSI layout support V2
Date: Fri,  4 Mar 2016 20:46:13 +0100
Message-Id: <1457120777-30687-1-git-send-email-hch@lst.de>
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
 

Chances since V1:
 - removed __exit annotation from bl_cleanup_pipefs
 - introduced separate config options for each layout driver in nfsd
 - added a file documentation the SCSI layout support

