Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:56096 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751952AbbC0Klg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Mar 2015 06:41:36 -0400
Date: Fri, 27 Mar 2015 11:41:35 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150327104135.GA15651@lst.de>
References: <20150303221033.GB19439@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150303221033.GB19439@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI, I small update on tracking down the recall issue:  this seems to
be very much something in the callback channel on the server.  When tracing
the client all the recalls it gets they are handled fine, but we do get
error back in the layout recall ->done handler, which most of the time
but not always are local Linux errnos and not nfs error numbers, indicating
something went wrong, probably in the RPC code.
