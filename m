Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from newpeace.netnation.com ([204.174.223.7]:45762 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751708AbZE2WEL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 18:04:11 -0400
Date: Fri, 29 May 2009 15:04:12 -0700
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: linux-nfs@vger.kernel.org
Subject: Re: New file doesn't show up if cached as missing
Message-ID: <20090529220412.GJ1719@hostway.ca>
References: <20090529175243.GA30961@hostway.ca> <1243622206.7155.103.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1243622206.7155.103.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, May 29, 2009 at 02:36:46PM -0400, Trond Myklebust wrote:

> That is most likely to be a consequence of poor mtime resolution on the
> server (i.e. the directory mtime failing to change because the file
> creation occurred within < 1 second of the 'rm'), combined with negative
> lookup caching.

As in "ls --full-time" shows 0 for the fractional second part?

Hrm, I thought newer ext3 had nanosecond mtime, but it seems not...

> Try using the '-olookupcache=positive' or '-olookupcache=none' mount
> options (requires a relatively recent version of nfs-utils).

After backporting nfs-utils, either of those options seem to this
particular case work as desired.  Excellent!

I guess all of the attribute-caching-related options are unrelated to
this case.  Is this consistent with older operation and that of other
OSes?  It might be a little surprising for some (me) when "noac" still
ends up doing some caching.

Thanks,

Simon-
