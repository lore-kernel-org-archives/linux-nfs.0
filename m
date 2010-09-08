Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:37300 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753464Ab0IHUBM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Sep 2010 16:01:12 -0400
Subject: NFS writes broken in net-next-2.6
From: Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 08 Sep 2010 21:01:08 +0100
Message-ID: <1283976068.2237.8.camel@achroite.uk.solarflarecom.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

In net-next-2.6, close() of a file after writing tends to return 1.
This causes e.g. gcc to abort.

This appears to have been fixed in 2.6.36-rc2:

commit 0702099bd86c33c2dcdbd3963433a61f3f503901
Author: J. R. Okajima <hooanon05@yahoo.co.jp>
Date:   Wed Aug 11 13:10:16 2010 -0400

    NFS: fix the return value of nfs_file_fsync()

Please consider merging this fix in some way.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

