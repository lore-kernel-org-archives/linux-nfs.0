Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:40300 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932706AbcGICwh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 22:52:37 -0400
Date: Sat, 9 Jul 2016 03:52:30 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: Make creates return EEXIST correctly instead of
 EPERM
Message-ID: <20160709025230.GR14480@ZenIV.linux.org.uk>
References: <1467942466-3081422-1-git-send-email-green@linuxhacker.ru>
 <1467975747.24149.16.camel@poochiereds.net>
 <05872587-E1A0-4714-AF43-7070D72D930C@linuxhacker.ru>
 <1467993208.27907.17.camel@poochiereds.net>
 <9F6401BF-9F1A-4D6C-BE36-BE2064EC9BF3@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9F6401BF-9F1A-4D6C-BE36-BE2064EC9BF3@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 08, 2016 at 11:59:50AM -0400, Oleg Drokin wrote:

> "If path names a symbolic link, mkdir() shall fail and set errno to [EEXIST]."
> 
> This sounds pretty straightforward to me, no?
> Since it does not matter that we do not have write permissions here, because
> the name already exists.

When more than one condition applies, we have every right to return any of
them.  POSIX does *NOT* specify the order of checks.  Never had.
