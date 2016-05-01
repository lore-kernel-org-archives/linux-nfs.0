Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35287 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbcEAAC5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 20:02:57 -0400
Date: Sun, 1 May 2016 01:02:55 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: parallel lookups on NFS
Message-ID: <20160501000254.GG25498@ZenIV.linux.org.uk>
References: <1462022142.10011.19.camel@poochiereds.net>
 <1462022576.10011.22.camel@poochiereds.net>
 <20160430142232.GA25498@ZenIV.linux.org.uk>
 <1462027414.10011.31.camel@poochiereds.net>
 <20160430185836.GC25498@ZenIV.linux.org.uk>
 <20160430192931.GD25498@ZenIV.linux.org.uk>
 <1462048765.10011.44.camel@poochiereds.net>
 <20160430205705.GE25498@ZenIV.linux.org.uk>
 <1462055616.10011.62.camel@poochiereds.net>
 <20160430233138.GF25498@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160430233138.GF25498@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 01, 2016 at 12:31:38AM +0100, Al Viro wrote:
> On Sat, Apr 30, 2016 at 06:33:36PM -0400, Jeff Layton wrote:
> > I'll do the same (re: KASAN).
> > 
> > Also FWIW, a few months ago I hit some oopses in the same inline
> > function (get_freepointer). It turned out to be a double-free due to my
> > own misuse of the fsnotify API. I wonder though if this might also be a
> > double free somewhere?
> 
> It is a double-free somewhere, all right...  What happens there is that
> nfs_readdir really relies upon being the only thread to manipulate the
> page cache of that directory.  We get nfs_revalidate_mapping() called
> and if it ends up evicting a page currently in use by nfs_do_filldir(),
> you get nfs_readdir_clear_array() called _twice_ - once on kicking it
> out of page cache (and those kfree of the names are obviously Not Good(tm)
> for nfs_do_filldir() copying those names to userland) and then when
> nfs_do_filldir() gets to cache_page_release().
> 
> Sigh...

AFAICS, we have desc->page coming either from get_cache_page() or from
direct assignment in uncached_readdir().  The latter is not a problem;
it won't be hit with pagecache eviction anyway.  The former, OTOH, is.

I wonder if we ought to put a counter into nfs_cache_array, initialized to 1
(in nfs_readdir_xdr_to_array()), bumped in get_cache_page() and decremented
both in cache_page_release() and in ->freepage().  With actual freeing
of names happening only when the sucker reaches 0, and get_cache_page()
treating "oops, it's already 0, someone has just evicted it from page cache"
as "page_cache_release() and retry".  Objections?
