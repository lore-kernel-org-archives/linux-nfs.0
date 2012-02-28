Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34579 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965145Ab2B1Tzh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Feb 2012 14:55:37 -0500
Date: Tue, 28 Feb 2012 14:55:36 -0500
To: Jim Rees <rees@umich.edu>
Cc: Gregor Gruener <ggruner@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2.6.32-131.6.1.el6.x86_64] idmapd.c: deactivate the
 ASCII characters check
Message-ID: <20120228195535.GC2723@fieldses.org>
References: <4F4603EC.9030404@redhat.com>
 <20120223130245.GA4776@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20120223130245.GA4776@umich.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 23, 2012 at 08:02:45AM -0500, Jim Rees wrote:
> Gregor Gruener wrote:
> 
>   Customers are using Unicode characters umlauts (ö,ä,ü) in group names and this
>   creates problems with NFS ID Mapping. Groups with umlauts will be redirected to
>   the group NFS "nobody".
>   This patch deactivate the ASCII characters check. It's maybe more like a temporary fix and I think it would be nicer to
>   adjust the check to support Unicode characters instead to deactivate the
>   check.
> 
> Maybe the name of the routine should also be changed to something other than
> validateascii().  But I'm curious why that check was put in there.

Sounds totally wrong.

By the nfs rfc's of course, if we're going to check anything we should
be checking for utf8.

Though even then, it's hard to see how failing and mapping to nobody
really helps anyone here once they already have a non-utf8 name.

Best might be to allow a non-utf8 mapping and print a one-time warning.
And work on fixing any account-creation tools to enforce utf8.

> 
> I found this in rfc5661 section 22.1, which seems to be a bug in the spec:
> 
>    1.  A US-ASCII string name that is the actual name of the attribute.
>        This name must be unique.  This string name can be 1 to 128 UTF-8
>        characters long.

Oops.

--b.
