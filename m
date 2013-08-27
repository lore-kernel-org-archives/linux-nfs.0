Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51046 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753893Ab3H0Pdw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Aug 2013 11:33:52 -0400
Date: Tue, 27 Aug 2013 11:33:51 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [3.6-rc3] rdirplus broken? (EBUSY)
Message-ID: <20130827153351.GD14809@fieldses.org>
References: <20120827215510.GL24761@hostway.ca>
 <20120911192523.GA11160@hostway.ca>
 <20120912121613.GC3009@fieldses.org>
 <20120912212035.GB28555@hostway.ca>
 <20120920001303.GC8249@hostway.ca>
 <20121003011753.GA17905@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121003011753.GA17905@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 02, 2012 at 06:17:53PM -0700, Simon Kirby wrote:
> I'm also getting file data corruption when mounted TCP, for some stupid
> reason, even with all TSO/GSO/GRO disabled, and this goes away with UDP.
> Reproducible on different client hardware, and on client kernels back to
> 2.6.32. Probably related to the 3.4.1 server. More debugging to do...

Is this still happening?

--b.
