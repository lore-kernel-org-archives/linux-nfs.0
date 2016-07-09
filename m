Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:53904 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932844AbcGIC6r convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 22:58:47 -0400
Subject: Re: [PATCH] nfsd: Make creates return EEXIST correctly instead of EPERM
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20160709025230.GR14480@ZenIV.linux.org.uk>
Date: Fri, 8 Jul 2016 22:58:38 -0400
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Message-Id: <BC2500DE-9763-4D97-9618-C7548D0807F7@linuxhacker.ru>
References: <1467942466-3081422-1-git-send-email-green@linuxhacker.ru> <1467975747.24149.16.camel@poochiereds.net> <05872587-E1A0-4714-AF43-7070D72D930C@linuxhacker.ru> <1467993208.27907.17.camel@poochiereds.net> <9F6401BF-9F1A-4D6C-BE36-BE2064EC9BF3@linuxhacker.ru> <20160709025230.GR14480@ZenIV.linux.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 8, 2016, at 10:52 PM, Al Viro wrote:

> On Fri, Jul 08, 2016 at 11:59:50AM -0400, Oleg Drokin wrote:
> 
>> "If path names a symbolic link, mkdir() shall fail and set errno to [EEXIST]."
>> 
>> This sounds pretty straightforward to me, no?
>> Since it does not matter that we do not have write permissions here, because
>> the name already exists.
> 
> When more than one condition applies, we have every right to return any of
> them.  POSIX does *NOT* specify the order of checks.  Never had.

Out of curiosity, why does filename_create() delay EROFS then?

