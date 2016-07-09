Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:40496 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932844AbcGIDKE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2016 23:10:04 -0400
Date: Sat, 9 Jul 2016 04:10:01 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: Make creates return EEXIST correctly instead of
 EPERM
Message-ID: <20160709031001.GS14480@ZenIV.linux.org.uk>
References: <1467942466-3081422-1-git-send-email-green@linuxhacker.ru>
 <1467975747.24149.16.camel@poochiereds.net>
 <05872587-E1A0-4714-AF43-7070D72D930C@linuxhacker.ru>
 <1467993208.27907.17.camel@poochiereds.net>
 <20160708160426.GB7395@fieldses.org>
 <8FC42FC1-AB95-4AF7-8493-EF0A34138B4A@linuxhacker.ru>
 <20160708204925.GB11269@fieldses.org>
 <71EA6CA5-3451-4A0F-BAA0-59843BA2D153@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <71EA6CA5-3451-4A0F-BAA0-59843BA2D153@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 08, 2016 at 05:47:22PM -0400, Oleg Drokin wrote:

> I wonder if people just accept that "NFS is just weird" and code in workarounds,
> where as with Lustre we promise (almost) full POSIX compliance, and also came much later
> so people are just seeing that "this does not work" and complain more loudly?

To quote POSIX: "If more than one error occurs in processing a function call,
any one of the possible errors may be returned, as the order of detection is
undefined." (from System Interfaces: General Information: 2.3 Error Numbers)

And regarding mkdir(2) it has
[EACCES]
    Search permission is denied on a component of the path prefix, or write
permission is denied on the parent directory of the directory to be created.
[EEXIST]
    The named file exists.
among the error conditions.  In situations when both apply, the implementation
is bloody well allowed to return either.  It might be nicer to return EEXIST
in such cases, for consistency sake (if another thread does stat() on the
pathname in question just as you are about to call mkdir(2), you will get
EEXIST without ever reaching permission(9), let alone ->mkdir() method), but
please do not bring POSIX compliance as an argument.  It's a QoI argument and
nothing beyond that.
