Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44369 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965514Ab0GSV0o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Jul 2010 17:26:44 -0400
Date: Mon, 19 Jul 2010 17:26:05 -0400
To: "Smets, Jan (Jan)" <jan.smets@alcatel-lucent.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS Server cache
Message-ID: <20100719212604.GA29058@fieldses.org>
References: <14C7F4F06DB5814AB0DE29716C4F6D670B7030B4@FRMRSSXCHMBSB1.dc-m.alcatel-lucent.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <14C7F4F06DB5814AB0DE29716C4F6D670B7030B4@FRMRSSXCHMBSB1.dc-m.alcatel-lucent.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jun 25, 2010 at 12:57:05AM +0200, Smets, Jan (Jan) wrote:
> Hi list
> 
> If I understood correctly, the main memory is used for caching NFS server data. Can I get more information on this? Statistics?

It uses the same caching as any other user of the exported filesystem.
What question exactly are you trying to answer?

> Is it possible to use a sort of fs-cache on the server? Thus using a SSD drive as cache for example. (at first sight fs-cache can only be used on the client side..)

If the nfs server code itself kept its own cache, that would cause
consistency problems between nfs clients and local users of the exported
filesystem.

So you want to solve the problem below the nfs level, in the vfs and/or
filesystem.

Making a filesystem use fs-cache requires modifying code of the
filesystem.  I don't know whether it would make sense to do that for a
disk filesystem.

There might be some benefit to putting the journal on an ssd; see e.g.:

	http://insights.oetiker.ch/linux/external-journal-on-ssd.html

> And maybe not so related: can I do data de-duplication? (within te
> cache? .. But I guess the FS should do that, but I could not find any
> capable of doing this on Linux.)

I believe people want btrfs to do deduplication some day.

--b.
