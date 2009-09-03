Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:37311 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123AbZICUta (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 16:49:30 -0400
Subject: Re: VM issue causing high CPU loads
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Simon Kirby <sim@hostway.ca>
Cc: Yohan <ytordjman@corp.free.fr>, Andrew Morton <akpm@linux-foundation.org>,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Neil Brown <neilb@suse.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        mikevs@xs4all.net
In-Reply-To: <20090903200550.GB5257@hostway.ca>
References: <4A92A25A.4050608@yohan.staff.proxad.net>
	 <20090824162155.ce323f08.akpm@linux-foundation.org>
	 <4A96463E.5080002@corp.free.fr> <4A9C34F8.2010307@corp.free.fr>
	 <20090902170642.f4381c1d.akpm@linux-foundation.org>
	 <1251982884.18338.9.camel@heimdal.trondhjem.org>
	 <4A9FC719.9020104@corp.free.fr>
	 <1251986526.18338.29.camel@heimdal.trondhjem.org>
	 <20090903200550.GB5257@hostway.ca>
Content-Type: text/plain
Date: Thu, 03 Sep 2009 16:49:25 -0400
Message-Id: <1252010965.18338.63.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2009-09-03 at 13:05 -0700, Simon Kirby wrote:
> On Thu, Sep 03, 2009 at 10:02:06AM -0400, Trond Myklebust wrote:
> 
> > OK, so 16 hash buckets are likely to be filled with ~10^6 entries each.
> > I can see that might be a performance issue...
> 
> We have a similar setup with millions of UIDs over NFS (currently NFSv3).
> I _wish_ there were a way to use NFSv4 without having to use name-mapped
> UIDs and GIDs, since our user and group names come from MySQL anyway, and
> are guaranteed to be consistent across machines.

That's a separate issue.

I'm working on increasing the idmapper scalability, however another
project is currently taking up most of my time. I can't guarantee that
the revised idmapper code will be finished in time to allow for
inclusion in 2.6.32.

> Why on earth does NFSv4 force the use of names?

NFSv4 aspires to be an internet-wide protocol, and so you cannot use
uids/gids: they just aren't guaranteed to represent a unique user
outside your local LDAP/NIS or /etc/passwd domain. Furthermore, uids and
gids are a posix construct. They simply don't work in environments where
you may have lots of non-posix systems.

Trond

