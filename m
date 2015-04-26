Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:60942 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751086AbbDZQTf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 26 Apr 2015 12:19:35 -0400
Date: Sun, 26 Apr 2015 18:19:33 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150426161933.GA13865@lst.de>
References: <20150303221033.GB19439@fieldses.org> <20150327104135.GA15651@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150327104135.GA15651@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 27, 2015 at 11:41:35AM +0100, Christoph Hellwig wrote:
> FYI, I small update on tracking down the recall issue:  this seems to
> be very much something in the callback channel on the server.  When tracing
> the client all the recalls it gets they are handled fine, but we do get
> error back in the layout recall ->done handler, which most of the time
> but not always are local Linux errnos and not nfs error numbers, indicating
> something went wrong, probably in the RPC code.

I think I've tracked down the major issue here (I think there are some more
hidding in the backchannel error handling as well):

 - the Linux NFS server completely ignores the limits the client specifies
   for the backchannel in CREATE_SESSION, most importantly the ca_maxrequests
   value.  Thus it will happily send lots of callback requests that can
   overflow the clients callback slot table.
 - even worse the Linux client has a callback slot table with just a single
   entry, so this is pretty easy to trigger.

I can try to dive into this, but it might make sense if someone more familar
with the sessions implementation could look into this issue.
