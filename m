Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39300 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754630AbdECULV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 16:11:21 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1493837027.22125.17.camel@perches.com>
References: <1493837027.22125.17.camel@perches.com> <1493835998.22125.15.camel@perches.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk> <1493835238.3180.7.camel@poochiereds.net> <4597.1493836661@warthog.procyon.org.uk>
To: Joe Perches <joe@perches.com>
Cc: dhowells@redhat.com, Jeff Layton <jlayton@poochiereds.net>,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 03 May 2017 21:11:17 +0100
Message-ID: <6013.1493842277@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:

> > > krealloc would probably be more efficient and possible
> > > readable as likely there's already padding in the original
> > > allocation.
> > 
> > The problem is if krealloc() fails: you've lost all those pointers to things
> > you then need to free.
> 
> Huh?  How could that happen?
> 
> krealloc must always use a temporary.
> If krealloc returns NULL, the original allocation is kept.

Hmmm...  Good point.

David
