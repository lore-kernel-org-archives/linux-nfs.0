Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:35386 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbcEABIt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 21:08:49 -0400
Date: Sun, 1 May 2016 02:08:43 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: parallel lookups on NFS
Message-ID: <20160501010843.GI25498@ZenIV.linux.org.uk>
References: <20160430142232.GA25498@ZenIV.linux.org.uk>
 <1462027414.10011.31.camel@poochiereds.net>
 <20160430185836.GC25498@ZenIV.linux.org.uk>
 <20160430192931.GD25498@ZenIV.linux.org.uk>
 <1462048765.10011.44.camel@poochiereds.net>
 <20160430205705.GE25498@ZenIV.linux.org.uk>
 <1462055616.10011.62.camel@poochiereds.net>
 <20160430233138.GF25498@ZenIV.linux.org.uk>
 <20160501000254.GG25498@ZenIV.linux.org.uk>
 <20160501001816.GH25498@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160501001816.GH25498@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 01, 2016 at 01:18:16AM +0100, Al Viro wrote:
> On Sun, May 01, 2016 at 01:02:55AM +0100, Al Viro wrote:
> > I wonder if we ought to put a counter into nfs_cache_array, initialized to 1
> > (in nfs_readdir_xdr_to_array()), bumped in get_cache_page() and decremented
> > both in cache_page_release() and in ->freepage().  With actual freeing
> > of names happening only when the sucker reaches 0, and get_cache_page()
> > treating "oops, it's already 0, someone has just evicted it from page cache"
> > as "page_cache_release() and retry".  Objections?
> 
> Something like (completely untested)

No problems after 100 iterations...  Folded and pushed.
