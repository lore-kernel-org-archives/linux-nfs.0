Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:57649 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932332AbbCCWKe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 17:10:34 -0500
Date: Tue, 3 Mar 2015 17:10:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>, linux-nfs@vger.kernel.org,
        xfs@oss.sgi.com
Subject: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150303221033.GB19439@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm getting mysterious crashes on a server exporting an xfs filesystem.

Strangely, I've reproduced this on

	93aaa830fc17 "Merge tag 'xfs-pnfs-for-linus-3.20-rc1' of git://git.kernel.org/pub/scm/linux/kernel/git/dgc/linux-xfs

but haven't yet managed to reproduce on either of its parents
(24a52e412ef2 or 781355c6e5ae).  That might just be chance, I'll try
again.

I can also try a serial console or something, but for now I'm not
getting a lot of information about the crashes.

The filesystem in question isn't on a block device available to the
client, but I'm still seeing occasional GETLAYOUT and GETDEVICEINFO
calls; I suppose the client's getting that far, finding no devices it
can use, and giving up?

Sorry for the incomplete report, I'll pass along more when I have it.

--b.
