Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34156 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbcD3Wdk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 18:33:40 -0400
Received: by mail-qk0-f181.google.com with SMTP id r184so60083637qkc.1
        for <linux-nfs@vger.kernel.org>; Sat, 30 Apr 2016 15:33:40 -0700 (PDT)
Message-ID: <1462055616.10011.62.camel@poochiereds.net>
Subject: Re: parallel lookups on NFS
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Sat, 30 Apr 2016 18:33:36 -0400
In-Reply-To: <20160430205705.GE25498@ZenIV.linux.org.uk>
References: <1461501975.5219.40.camel@poochiereds.net>
	 <20160424191835.GL25498@ZenIV.linux.org.uk>
	 <20160429075812.GY25498@ZenIV.linux.org.uk>
	 <1462022142.10011.19.camel@poochiereds.net>
	 <1462022576.10011.22.camel@poochiereds.net>
	 <20160430142232.GA25498@ZenIV.linux.org.uk>
	 <1462027414.10011.31.camel@poochiereds.net>
	 <20160430185836.GC25498@ZenIV.linux.org.uk>
	 <20160430192931.GD25498@ZenIV.linux.org.uk>
	 <1462048765.10011.44.camel@poochiereds.net>
	 <20160430205705.GE25498@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2016-04-30 at 21:57 +0100, Al Viro wrote:
> On Sat, Apr 30, 2016 at 04:39:25PM -0400, Jeff Layton wrote:
> 
> > 
> > Attached. Also I ran the same test on a 4.6.0-rc1 kernel and it
> > worked
> > fine, so it does seem to be a regression introduced somewhere in
> > your
> > patch pile. Also, FWIW the machine is a KVM guest.
> OK...  Could you try #work.lookups on your setup?  That doesn't
> contain the
> last commit; the deadlock ought to be dealt with, though.  I'm trying
> to
> reproduce the corruption with KASAN enabled, will try your config
> once that's
> finished...

I'll do the same (re: KASAN).

Also FWIW, a few months ago I hit some oopses in the same inline
function (get_freepointer). It turned out to be a double-free due to my
own misuse of the fsnotify API. I wonder though if this might also be a
double free somewhere?

-- 
Jeff Layton <jlayton@poochiereds.net>

