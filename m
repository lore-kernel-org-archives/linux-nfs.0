Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:40540 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbcGIDNW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 23:13:22 -0400
Date: Sat, 9 Jul 2016 04:13:20 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: Make creates return EEXIST correctly instead of
 EPERM
Message-ID: <20160709031320.GT14480@ZenIV.linux.org.uk>
References: <1467942466-3081422-1-git-send-email-green@linuxhacker.ru>
 <1467975747.24149.16.camel@poochiereds.net>
 <05872587-E1A0-4714-AF43-7070D72D930C@linuxhacker.ru>
 <1467993208.27907.17.camel@poochiereds.net>
 <9F6401BF-9F1A-4D6C-BE36-BE2064EC9BF3@linuxhacker.ru>
 <20160709025230.GR14480@ZenIV.linux.org.uk>
 <BC2500DE-9763-4D97-9618-C7548D0807F7@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BC2500DE-9763-4D97-9618-C7548D0807F7@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 08, 2016 at 10:58:38PM -0400, Oleg Drokin wrote:

> > When more than one condition applies, we have every right to return any of
> > them.  POSIX does *NOT* specify the order of checks.  Never had.
> 
> Out of curiosity, why does filename_create() delay EROFS then?

QoI and historical behaviour...
