Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34888 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbcD3U5I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 16:57:08 -0400
Date: Sat, 30 Apr 2016 21:57:05 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: parallel lookups on NFS
Message-ID: <20160430205705.GE25498@ZenIV.linux.org.uk>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1462048765.10011.44.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 30, 2016 at 04:39:25PM -0400, Jeff Layton wrote:

> Attached. Also I ran the same test on a 4.6.0-rc1 kernel and it worked
> fine, so it does seem to be a regression introduced somewhere in your
> patch pile. Also, FWIW the machine is a KVM guest.

OK...  Could you try #work.lookups on your setup?  That doesn't contain the
last commit; the deadlock ought to be dealt with, though.  I'm trying to
reproduce the corruption with KASAN enabled, will try your config once that's
finished...
