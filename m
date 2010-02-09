From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH pynfs] Allow server to reject maximum commit offsets
Date: Tue, 9 Feb 2010 15:13:31 -0500
Message-ID: <20100209201331.GD30951@fieldses.org>
References: <20100209201231.GC30951@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: iisaman@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59150 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751198Ab0BIUNF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Feb 2010 15:13:05 -0500
In-Reply-To: <20100209201231.GC30951@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 09, 2010 at 03:12:31PM -0500, bfields wrote:
> From: J. Bruce Fields <bfields@citi.umich.edu>
> 
> These two tests insist that a server must accept commits with offset
> 2^64-1 and 2^64-2.  I can find no justification in the spec for this
> requirement.

You can also get this and another old patch by:

	git pull git://linux-nfs.org/~bfields/pynfs.git master

--b.
