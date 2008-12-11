From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] send actual expiration for svcgssd gss contexts
Date: Thu, 11 Dec 2008 12:41:57 -0500
Message-ID: <494150E5.30704@RedHat.com>
References: <20081204233341.5951.62162.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:32926 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756753AbYLKRoN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 11 Dec 2008 12:44:13 -0500
In-Reply-To: <20081204233341.5951.62162.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Kevin Coffman wrote:
> These patches allow svcgssd to supply the correct timeout value for the cache
> entries associated with gss contexts.  The init cache values are changed from
> "never" to 60 seconds.

Both patches have been tested and committed...

steved.

