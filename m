Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50570 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754440AbZICOCK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 10:02:10 -0400
Subject: Re: VM issue causing high CPU loads
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Yohan <ytordjman@corp.free.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@fieldses.org>, mikevs@xs4all.net
In-Reply-To: <4A9FC719.9020104@corp.free.fr>
References: <4A92A25A.4050608@yohan.staff.proxad.net>
	 <20090824162155.ce323f08.akpm@linux-foundation.org>
	 <4A96463E.5080002@corp.free.fr> <4A9C34F8.2010307@corp.free.fr>
	 <20090902170642.f4381c1d.akpm@linux-foundation.org>
	 <1251982884.18338.9.camel@heimdal.trondhjem.org>
	 <4A9FC719.9020104@corp.free.fr>
Content-Type: text/plain
Date: Thu, 03 Sep 2009 10:02:06 -0400
Message-Id: <1251986526.18338.29.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2009-09-03 at 15:39 +0200, Yohan wrote:
> > As far as I can see, there is no RPCSEC_GSS involved, so credentials
> > should never expire. They will be reused as long as processes aren't
> > switching between thousands and thousands of different combinations of
> > uid, gid and groups.
> My servers are imap servers.
> Foreach user (~15 million) it have a specific uid over ~10 nfs netapp 
> storage.

OK, so 16 hash buckets are likely to be filled with ~10^6 entries each.
I can see that might be a performance issue...

So afaics, you did try adjusting the hashtable size. How much larger
does it have to be before you start to get acceptable performance? If it
solves your problem we could make hash table sizes adjustable via a
module parameter, for instance.

Cheers
  Trond

