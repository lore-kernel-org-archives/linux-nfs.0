Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56791 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125Ab1BXTKU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 14:10:20 -0500
Date: Thu, 24 Feb 2011 19:10:13 +0000
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
Message-ID: <20110224191012.GC22723@ZenIV.linux.org.uk>
References: <1295420817.3076.24.camel@perseus>
 <1297779902.13007.86.camel@perseus>
 <20110224015817.GQ22723@ZenIV.linux.org.uk>
 <1298516618.2916.20.camel@perseus>
 <20110224031439.GR22723@ZenIV.linux.org.uk>
 <1298518137.2916.35.camel@perseus>
 <20110224035836.GS22723@ZenIV.linux.org.uk>
 <1298529260.2916.91.camel@perseus>
 <20110224070724.GW22723@ZenIV.linux.org.uk>
 <1298542053.3058.56.camel@perseus>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1298542053.3058.56.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 24, 2011 at 06:07:33PM +0800, Ian Kent wrote:

> Yes, that's a problem.
> 
> Previously the dcache_lock would have blocked on the dput() ... mmm, I'd
> missed that so far, although Nick didn't talk with me about his changes
> very much at all and I didn't pay enough attention to his patch series
> along the way, oops!

Actually, dcache_lock blocks only the _final_ dput().  I.e. one that has
refcount going to 0.  Not the case here, so that's a problem without
RCU stuff as well.
