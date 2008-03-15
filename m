From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.24: RPC: bad TCP reclen 0x00020090 (large)
Date: Fri, 14 Mar 2008 20:10:14 -0400
Message-ID: <20080315001014.GT2119@fieldses.org>
References: <20080314190645.GJ2119@fieldses.org> <C4003B51.3BE6A%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tokarev <mjt@tls.msk.ru>, linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54249 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291AbYCOAKR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Mar 2008 20:10:17 -0400
In-Reply-To: <C4003B51.3BE6A%tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 14, 2008 at 02:25:21PM -0500, Tom Tucker wrote:
> 
> Michael:
> 
> Thanks for the update. BTW, the perfect "positive fix indication" would be
> seeing a single "...bad TCP reclen..." message in the log for the
> reconnecting/confused client.

Hm.  This may be entirely unrelated (and not at all your responsibility)
but

	 ./testserver.py server:/ --rundeps -v WRT5

with newpynfs:

	http://www.citi.umich.edu/projects/nfsv4/pynfs/

gets me a "RPC: bad TCP reclen 0x00000800 (non-terminal)" and a test
failure.  Hm.  It may be that newpynfs is doing something intolerably
weird and the server's just dropping the request instead of returning an
error.  OK, probably totally unrelated.  I haven't looked hard enough
yet.

--b.
