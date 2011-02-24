Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46786 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754446Ab1BXPS0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 10:18:26 -0500
Date: Thu, 24 Feb 2011 15:18:09 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Ian Kent <raven@themaw.net>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, npiggin@gmail.com
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
Message-ID: <20110224151809.GB22723@ZenIV.linux.org.uk>
References: <1297779902.13007.86.camel@perseus>
 <20110224015817.GQ22723@ZenIV.linux.org.uk>
 <1298516618.2916.20.camel@perseus>
 <20110224031439.GR22723@ZenIV.linux.org.uk>
 <1298518137.2916.35.camel@perseus>
 <20110224035836.GS22723@ZenIV.linux.org.uk>
 <1298529260.2916.91.camel@perseus>
 <20110224070724.GW22723@ZenIV.linux.org.uk>
 <1298542053.3058.56.camel@perseus>
 <20110224145947.GA22723@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110224145947.GA22723@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 24, 2011 at 02:59:47PM +0000, Al Viro wrote:

> Well...  In principle, you could mark all mountpoints in a tree as managed,
> have an "expiry search in progress" flag to stop everything in there while
> the expiry happens, then wait out all RCU walks in progress, then go ahead
> with your expiry checks.  Would that work for you?

There's at least one leak I can see in expiry.c, BTW - autofs4_expire_direct()
leaks root dentry if you hit
        /* No point expiring a pending mount */
        if (ino->flags & AUTOFS_INF_PENDING) {
                spin_unlock(&sbi->fs_lock);
                return NULL;
        }
in there.  Try to stick dput(root) before that return and see if that's what
it is...
