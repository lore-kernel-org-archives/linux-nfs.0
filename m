Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:35230 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbcEANfg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 1 May 2016 09:35:36 -0400
Received: by mail-qg0-f46.google.com with SMTP id f74so59952321qge.2
        for <linux-nfs@vger.kernel.org>; Sun, 01 May 2016 06:35:36 -0700 (PDT)
Message-ID: <1462109732.2790.1.camel@poochiereds.net>
Subject: Re: parallel lookups on NFS
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Sun, 01 May 2016 09:35:32 -0400
In-Reply-To: <20160501010843.GI25498@ZenIV.linux.org.uk>
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
	 <20160501010843.GI25498@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2016-05-01 at 02:08 +0100, Al Viro wrote:
> On Sun, May 01, 2016 at 01:18:16AM +0100, Al Viro wrote:
> > 
> > On Sun, May 01, 2016 at 01:02:55AM +0100, Al Viro wrote:
> > > 
> > > I wonder if we ought to put a counter into nfs_cache_array,
> > > initialized to 1
> > > (in nfs_readdir_xdr_to_array()), bumped in get_cache_page() and
> > > decremented
> > > both in cache_page_release() and in ->freepage().  With actual
> > > freeing
> > > of names happening only when the sucker reaches 0, and
> > > get_cache_page()
> > > treating "oops, it's already 0, someone has just evicted it from
> > > page cache"
> > > as "page_cache_release() and retry".  Objections?
> > Something like (completely untested)
> No problems after 100 iterations...  Folded and pushed.

Same here. Ran same test vs. your work.lookups branch and it seems fine
now.

Cheers,
-- 
Jeff Layton <jlayton@poochiereds.net>

