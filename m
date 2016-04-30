Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35229 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbcD3Xbl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 19:31:41 -0400
Date: Sun, 1 May 2016 00:31:38 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: parallel lookups on NFS
Message-ID: <20160430233138.GF25498@ZenIV.linux.org.uk>
References: <20160429075812.GY25498@ZenIV.linux.org.uk>
 <1462022142.10011.19.camel@poochiereds.net>
 <1462022576.10011.22.camel@poochiereds.net>
 <20160430142232.GA25498@ZenIV.linux.org.uk>
 <1462027414.10011.31.camel@poochiereds.net>
 <20160430185836.GC25498@ZenIV.linux.org.uk>
 <20160430192931.GD25498@ZenIV.linux.org.uk>
 <1462048765.10011.44.camel@poochiereds.net>
 <20160430205705.GE25498@ZenIV.linux.org.uk>
 <1462055616.10011.62.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1462055616.10011.62.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 30, 2016 at 06:33:36PM -0400, Jeff Layton wrote:
> I'll do the same (re: KASAN).
> 
> Also FWIW, a few months ago I hit some oopses in the same inline
> function (get_freepointer). It turned out to be a double-free due to my
> own misuse of the fsnotify API. I wonder though if this might also be a
> double free somewhere?

It is a double-free somewhere, all right...  What happens there is that
nfs_readdir really relies upon being the only thread to manipulate the
page cache of that directory.  We get nfs_revalidate_mapping() called
and if it ends up evicting a page currently in use by nfs_do_filldir(),
you get nfs_readdir_clear_array() called _twice_ - once on kicking it
out of page cache (and those kfree of the names are obviously Not Good(tm)
for nfs_do_filldir() copying those names to userland) and then when
nfs_do_filldir() gets to cache_page_release().

Sigh...
