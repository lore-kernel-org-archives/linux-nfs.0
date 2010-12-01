Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:40716 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752366Ab0LAWnn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Dec 2010 17:43:43 -0500
Date: Wed, 1 Dec 2010 14:43:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Hugh Dickins <hughd@google.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Nick Bowler <nbowler@elliptictech.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, Rik van Riel <riel@redhat.com>,
        Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>,
        Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH v2 3/3] NFS: Fix a memory leak in nfs_readdir
Message-Id: <20101201144314.6a827f8d.akpm@linux-foundation.org>
In-Reply-To: <20101202082913.7cb98444@notabene.brown>
References: <1291217804-11257-1-git-send-email-Trond.Myklebust@netapp.com>
	<1291217804-11257-2-git-send-email-Trond.Myklebust@netapp.com>
	<20101201150428.GA2879@elliptictech.com>
	<1291217804-11257-3-git-send-email-Trond.Myklebust@netapp.com>
	<1291217804-11257-4-git-send-email-Trond.Myklebust@netapp.com>
	<AANLkTi=C8UtWwctEgBY2584d8fDV3OHpf+mGNnQO8ZJt@mail.gmail.com>
	<1291229669.6609.24.camel@heimdal.trondhjem.org>
	<alpine.LSU.2.00.1012011058560.16407@tigran.mtv.corp.google.com>
	<1291233938.6609.37.camel@heimdal.trondhjem.org>
	<20101201123929.ab7cef1d.akpm@linux-foundation.org>
	<20101202082913.7cb98444@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2 Dec 2010 08:29:13 +1100
Neil Brown <neilb@suse.de> wrote:

> > > 
> > > However, while reading Documentation/filesystems/vfs.txt (in order to
> > > add documentation for freepage) I was surprised to read that the
> > > ->releasepage() is itself supposed to be allowed to actually remove the
> > > page from the address space if it so desires.
> > 
> > That doesn't sound right.  It came from Neil in 2006.
> > 
> > Neil, what were you thinking there?   Did you find such a ->releasepage()?
> 
> Nope, no idea, sorry.
> 
> No releasepage functions do anything like that, and no call sites suggest it
> could be a possibility.  Quite the reverse - they are likely to remove the
> page from the mapping without checking that it is still in the mapping.
> 
> So that sentence should be deleted.

This?

From: Andrew Morton <akpm@linux-foundation.org>

->releasepage() does not remove the page from the mapping.

Cc: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 Documentation/filesystems/vfs.txt |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff -puN Documentation/filesystems/vfs.txt~documentation-filesystems-vfstxt-fix-repeasepage-description Documentation/filesystems/vfs.txt
--- a/Documentation/filesystems/vfs.txt~documentation-filesystems-vfstxt-fix-repeasepage-description
+++ a/Documentation/filesystems/vfs.txt
@@ -660,11 +660,10 @@ struct address_space_operations {
   releasepage: releasepage is called on PagePrivate pages to indicate
         that the page should be freed if possible.  ->releasepage
         should remove any private data from the page and clear the
-        PagePrivate flag.  It may also remove the page from the
-        address_space.  If this fails for some reason, it may indicate
-        failure with a 0 return value.
-	This is used in two distinct though related cases.  The first
-        is when the VM finds a clean page with no active users and
+        PagePrivate flag. If releasepage() fails for some reason, it must
+	indicate failure with a 0 return value.
+	releasepage() is used in two distinct though related cases.  The
+	first is when the VM finds a clean page with no active users and
         wants to make it a free page.  If ->releasepage succeeds, the
         page will be removed from the address_space and become free.
 
_

