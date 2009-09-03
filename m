Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:59469 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756135AbZICUFx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Sep 2009 16:05:53 -0400
Date: Thu, 3 Sep 2009 13:05:50 -0700
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Yohan <ytordjman@corp.free.fr>, Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Neil Brown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        mikevs@xs4all.net
Subject: Re: VM issue causing high CPU loads
Message-ID: <20090903200550.GB5257@hostway.ca>
References: <4A92A25A.4050608@yohan.staff.proxad.net> <20090824162155.ce323f08.akpm@linux-foundation.org> <4A96463E.5080002@corp.free.fr> <4A9C34F8.2010307@corp.free.fr> <20090902170642.f4381c1d.akpm@linux-foundation.org> <1251982884.18338.9.camel@heimdal.trondhjem.org> <4A9FC719.9020104@corp.free.fr> <1251986526.18338.29.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1251986526.18338.29.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 03, 2009 at 10:02:06AM -0400, Trond Myklebust wrote:

> OK, so 16 hash buckets are likely to be filled with ~10^6 entries each.
> I can see that might be a performance issue...

We have a similar setup with millions of UIDs over NFS (currently NFSv3).
I _wish_ there were a way to use NFSv4 without having to use name-mapped
UIDs and GIDs, since our user and group names come from MySQL anyway, and
are guaranteed to be consistent across machines.

Why on earth does NFSv4 force the use of names?

I was considering hacking the code to stick IDs in there anyway, but I
haven't looked at the feasibility of this.  I suspect this would break or
complicate other things, but the current NFSv4 design just seems like an
incredible waste for this case.

Simon-
