Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:58962 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752359AbaINQq6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 14 Sep 2014 12:46:58 -0400
Date: Sun, 14 Sep 2014 18:46:55 +0200
From: Christoph Hellwig <hch@lst.de>
To: Boaz Harrosh <boaz@plexistor.com>, Benny Halevy <bhalevy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: layoutcommit space reservation for the objlayout driver
Message-ID: <20140914164655.GB13467@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the NFS client does not reserved any space for the layoutupdate
field when encoding a layoutcommit.  For the file layout driver which doesn't
have a layoutupdate that's obviously fine, and for the block layoutdriver
I just fixed the issue in my series by allowing to split in a set of
preallocated pages.  The objlayout driver still needs this fixed, either
by convincing Trond to increase the reservatation for the few objlayout
fields, or by splicing in the pages like the block layout driver does.

Can someone with an objlayout setup take care of this?
