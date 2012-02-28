Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37690 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757290Ab2B1UAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Feb 2012 15:00:20 -0500
Date: Tue, 28 Feb 2012 15:00:15 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: steve <steve@steve-ss.com>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org
Subject: Re: POSIX acls over nfs4
Message-ID: <20120228200015.GD2723@fieldses.org>
References: <4F40053A.3090301@steve-ss.com>
 <4F412E2F.9070200@steve-ss.com>
 <4F45E78E.8050501@steve-ss.com>
 <20120223063913.5736a5b1@tlielax.poochiereds.net>
 <4F4628B8.90401@steve-ss.com>
 <20120223144053.GA25010@fieldses.org>
 <4F465C3A.9080802@steve-ss.com>
 <20120223154215.GA26706@fieldses.org>
 <4F466467.3030506@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F466467.3030506@steve-ss.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 23, 2012 at 05:08:07PM +0100, steve wrote:
> OK. I see what you mean. umask 0022
> So I can have a group rw with posix but not with nfs4_setfacl:-(
> 
> That's on openSUSE who default to 0022. The default on Ubuntu is
> 0002 so presumably we could have group rw over nfs4 there out of the
> box?
> 
> Is it a lot of work to implement umask override for nfs4? Or make it
> an option perhaps?

Two fulltime-kernel-hacker-week-equivalents?

I'm not sure, I just made that up.

It does appear that it's necessary to make v4 ACLs usable in a lot of
cases.

--b.

> At the moment I'm using a big hammer and scanning the share every 4
> seconds to change the permissions of any files created there. My
> other thought was to have the share on a different partition, umask
> it to 0002 and export that. But these are workarounds. It would be
> really good to have the nfs4 acls do it.
