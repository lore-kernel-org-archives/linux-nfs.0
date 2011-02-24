Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:37329 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753686Ab1BXKVV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 05:21:21 -0500
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
From: Ian Kent <raven@themaw.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, npiggin@gmail.com
In-Reply-To: <20110224070724.GW22723@ZenIV.linux.org.uk>
References: <20110118040449.23109.33071.stgit@localhost6.localdomain6>
	 <1295420817.3076.24.camel@perseus> <1297779902.13007.86.camel@perseus>
	 <20110224015817.GQ22723@ZenIV.linux.org.uk>
	 <1298516618.2916.20.camel@perseus>
	 <20110224031439.GR22723@ZenIV.linux.org.uk>
	 <1298518137.2916.35.camel@perseus>
	 <20110224035836.GS22723@ZenIV.linux.org.uk>
	 <1298529260.2916.91.camel@perseus>
	 <20110224070724.GW22723@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Feb 2011 18:21:14 +0800
Message-ID: <1298542874.3058.60.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-24 at 07:07 +0000, Al Viro wrote:
> On Thu, Feb 24, 2011 at 02:34:20PM +0800, Ian Kent wrote:
> 
> > It does now but it doesn't do a whole lot, just checks for a negative
> > dentry, returning false, and drops out of RCU mode when the dentry isn't
> > selected or being checked for expiry yet.
> 
> Er?  Where does ->d_revalidate() exist in fs/autofs4?  Mainline doesn't
> have anything of that kind...

snip ...

> 
> OK, now I'm really confused.  Where does your tree live?

It's a working tree.

I can update my autofs4 tree on kernel.org with the changes that I think
are actually needed so far. Even then I'm still not sure that revalidate
will be needed.

Ian


