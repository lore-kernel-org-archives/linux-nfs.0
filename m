Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:25940 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753209Ab3KYXlD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Nov 2013 18:41:03 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: The return of the hanging "ls"...
Date: Mon, 25 Nov 2013 23:41:02 +0000
Message-ID: <1385422860.9247.15.camel@leira.trondhjem.org>
References: <20131125155942.0a3e4ca1@notabene.brown>
	 <A7CF3941-980F-4B96-B473-ECB46375CFCF@oracle.com>
	 <20131126102301.6cbbdb94@notabene.brown>
In-Reply-To: <20131126102301.6cbbdb94@notabene.brown>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2013-11-26 at 10:23 +-1100, NeilBrown wrote:
+AD4- On Mon, 25 Nov 2013 09:59:39 -0500 Chuck Lever +ADw-chuck.lever+AEA-oracle.com+AD4- wrote:
+AD4- 
+AD4- +AD4- Hi Neil-
+AD4- +AD4- 
+AD4- +AD4- On Nov 24, 2013, at 11:59 PM, NeilBrown +ADw-neilb+AEA-suse.de+AD4- wrote:
+AD4- +AD4- 
+AD4- +AD4- +AD4- 
+AD4- +AD4- +AD4- Hi Trond,
+AD4- +AD4- +AD4- I just noticed commit acdc53b2146c7ee67feb1f02f7bc3020126514b8 from 2010
+AD4- +AD4- +AD4- reverts the effect commit 28c494c5c8d425e15b7b82571e4df6d6bc34594d from Chunk
+AD4- +AD4- +AD4- in 2007.
+AD4- +AD4- 
+AD4- +AD4- I'm wondering if a subsequent commit changed filemap+AF8-write+AF8-and+AF8-wait().
+AD4- 
+AD4- I hadn't thought of that possibility.  I've just had a look at the
+AD4- differences between  acdc53b2146c7ee6  and now and cannot find anything that
+AD4- could be related.

To clarify a little: my understanding is that the current 2-pass code in
write+AF8-cache+AF8-pages() is supposed to prevent livelock. Instead of chasing
PAGECACHE+AF8-TAG+AF8-DIRTY tags (which are constantly being set if an
application is actively writing), we call tag+AF8-pages+AF8-for+AF8-writeback() once
in order to convert the current set of PAGECACHE+AF8-TAG+AF8-DIRTY tags into
PAGECACHE+AF8-TAG+AF8-TOWRITE tags, and then we have a second pass write those
pages back (and wait for completion).
IOW: the inode-+AD4-i+AF8-mutex should be unnecessary here...


Now that said, we recently added in the call to nfs+AF8-inode+AF8-dio+AF8-wait(). If
applications are using O+AF8-DIRECT, then +AF8-that+AF8- could livelock. There is
nothing currently preventing the applications from continuing to bump
the inode-+AD4-i+AF8-dio+AF8-count while we're waiting. Christoph has proposed some
locking changes that should fix that problem. I'm still evaluating his
patchset...

Cheers
  Trond

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
