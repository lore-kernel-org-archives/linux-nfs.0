Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:33909 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbcD3WRX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 18:17:23 -0400
Received: by mail-qg0-f50.google.com with SMTP id 90so40514634qgz.1
        for <linux-nfs@vger.kernel.org>; Sat, 30 Apr 2016 15:17:23 -0700 (PDT)
Message-ID: <1462054639.10011.56.camel@poochiereds.net>
Subject: Re: parallel lookups on NFS
From: Jeff Layton <jlayton@poochiereds.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Date: Sat, 30 Apr 2016 18:17:19 -0400
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
> > Attached. Also I ran the same test on a 4.6.0-rc1 kernel and it worked
> > fine, so it does seem to be a regression introduced somewhere in your
> > patch pile. Also, FWIW the machine is a KVM guest.
> OK...  Could you try #work.lookups on your setup?  That doesn't contain the
> last commit; the deadlock ought to be dealt with, though.  I'm trying to
> reproduce the corruption with KASAN enabled, will try your config once that's
> finished...


That branch seems to work fine. The same test didn't hang and didn't crash.

Cheers,
-- 
Jeff Layton <jlayton@poochiereds.net>

