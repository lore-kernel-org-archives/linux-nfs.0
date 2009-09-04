From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: VM issue causing high CPU loads
Date: Fri, 04 Sep 2009 08:31:37 -0400
Message-ID: <1252067497.13204.3.camel@heimdal.trondhjem.org>
References: <4A92A25A.4050608@yohan.staff.proxad.net>
	 <20090824162155.ce323f08.akpm@linux-foundation.org>
	 <4A96463E.5080002@corp.free.fr> <4A9C34F8.2010307@corp.free.fr>
	 <20090902170642.f4381c1d.akpm@linux-foundation.org>
	 <1251982884.18338.9.camel@heimdal.trondhjem.org>
	 <4A9FC719.9020104@corp.free.fr>
	 <1251986526.18338.29.camel@heimdal.trondhjem.org>
	 <20090903200550.GB5257@hostway.ca>
	 <1252010965.18338.63.camel@heimdal.trondhjem.org>
	 <20090903222253.GA8405@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yohan <ytordjman-CZvJ5kAzflf985uAA1p3mw@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, mikevs@xs4all.net
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:50488 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753612AbZIDMbm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2009 08:31:42 -0400
In-Reply-To: <20090903222253.GA8405@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-09-03 at 15:22 -0700, Simon Kirby wrote:
> So, for environments with all POSIX systems, what do you think about
> perhaps a mount or export flag that violates the spec on purpose to allow
> numeric IDs to be used?

No! I'm not interested in starting a LinuxPrivateNFSv4 protocol on top
of everything else we've got...

Trond

