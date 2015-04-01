Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:33819 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752223AbbDASIE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2015 14:08:04 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 7735120B2F
	for <linux-nfs@vger.kernel.org>; Wed,  1 Apr 2015 14:02:14 -0400 (EDT)
Message-Id: <1427911337.1794160.248190485.1F161545@webmail.messagingengine.com>
From: lyndat3@your-mail.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Content-Type: text/plain
In-Reply-To: <20150401175437.GD3040@fieldses.org>
References: <1427751843.1013981.247256753.2BA43388@webmail.messagingengine.com>
 <1427811676.1314276.247565589.4E14003B@webmail.messagingengine.com>
 <20150401175437.GD3040@fieldses.org>
Subject: Re: file xfer over NFSv4 with 'sync' ~300X slower than with 'async' ?
Date: Wed, 01 Apr 2015 11:02:17 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> There's no maximum sync/async ratio.  You could make that ratio lower or
> higher by varying dd's block size, for example.
> 
> The way I'd look at it, your dd of a 100MB file above is doing 3072
> writes, and taking about 8*60/3072 =~ .16 seconds per write.
> 
> That does sound high.  Things to look at to understand why might include
> the round-trip ping time to the server, and the time for the server's
> disk to do a synchronous write.
> 

After comments from one of the nfs client maintainers, it turns out the slowness issue is simply one of not-quite-MIS-configuration.

As helpfully commented here

  http://serverfault.com/questions/499174/etc-exports-mount-option/500553#500553

, IIUC there are two *separate* syncs to consider -- at the server, and at the client.

'sync' on the EXPORT, and 'async' on the MOUNT is the sane approach; That config also appears to return the performance.

The many recommendations online to use 'sync' for data integrity are IIUC for sync on the server.

With 'async' set on the moount, and 'sync' on the exports, It appears integrity of writes is properly assured and I've got rsync-over-NFSv4 performance back in the ~30-60 MB/s range.

LT 
