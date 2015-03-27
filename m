Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46132 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753599AbbC0PNt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 11:13:49 -0400
Date: Fri, 27 Mar 2015 11:13:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150327151348.GB27889@fieldses.org>
References: <20150303221033.GB19439@fieldses.org>
 <20150327104135.GA15651@lst.de>
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

Do you have a patch to switch the default, as well?

Were you just planning to replace NFSEXP_NOPNFS by a NFSEXP_PNFS?  As
long as we're still in -rc and nfs-utils doesn't know about the new
flag, I can't see why that would be a problem.

--b.
