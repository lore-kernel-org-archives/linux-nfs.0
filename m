Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46509 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751616Ab1KWUNr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Nov 2011 15:13:47 -0500
Date: Wed, 23 Nov 2011 15:13:45 -0500
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: nfs-utils and libnfsidmap
Message-ID: <20111123201345.GA1044@fieldses.org>
References: <CAGue13qasD7m+dj3PdA+p5jfJQU_Eq0r+Z9QqtvOSnadFmWJeg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAGue13qasD7m+dj3PdA+p5jfJQU_Eq0r+Z9QqtvOSnadFmWJeg@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 23, 2011 at 08:54:06PM +0100, Tigran Mkrtchyan wrote:
> Hi All,
> 
> today was tracing a bug in nfs-utils/libnfsidmap and after a log
> debugging located it and
> finally realized that it's already fixed by Steve Dickson (
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=commit;h=d22ef3f525d71b565fcc688557273a6cabeeb71a
> ). Nevertheless during
> this procedure it turned out that there is quite some code duplicated
> between nfs-utils and
> libnfsidmap.
> 
> Questions:
>    a) why nfs-utils duplicates some part of libnfsidmap and still depends o it
>    b) is there readon for code duplication? Licensing or so
>    c) what ww need to do to get rid of duplication
> 
> I expect the answer of 'c' will contain something like time and man power.
> I am volunteering to to pend some time on it.

I doubt there's any real reason for duplication.

Probably libnfsidmap should be part of nfs-utils, actually.

And maybe we don't need it at all--the original reason to split out
libnfsidmap was to share the code with libacl, so the posix getfacl
command could do v4->posix acl mapping, but those patches never made it
upstream.

--b.
