Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.82]:47393 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751219Ab1KADCY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Oct 2011 23:02:24 -0400
Date: Mon, 31 Oct 2011 23:01:40 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Benny Halevy <bhalevy@tonian.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Silence compiler warning
Message-ID: <20111101030140.GA4449@umich.edu>
References: <20111101013720.GA4237@umich.edu>
 <1320114622.10028.36.camel@lade.trondhjem.org>
 <20111101024200.GA4382@umich.edu>
 <1320116217.10028.44.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320116217.10028.44.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:

  On Mon, 2011-10-31 at 22:42 -0400, Jim Rees wrote: 
  > Trond Myklebust wrote:
  > 
  >   On Mon, 2011-10-31 at 21:37 -0400, Jim Rees wrote: 
  >   > I think this is still needed, isn't it?  I haven't tried compiling
  >   > nfs-for-next but I don't see a fix for it in there.
  >   
  >   AFAICS, this is a bogus warning: if lo is uninitialised, we will
  >   automatically exit with a return value of NFS4ERR_NOMATCHING_LAYOUT.
  > 
  > Yes, the warning is bogus.  I just want the damn compiler to shut up so I
  > can see if there are any real warnings.
  
  How about cleaning up the whole unnecessary "bool found" crap that has
  it confused? You can easily replace that with a test for 'ino != NULL'.
  We don't usually "fix" compiler bugs by changing valid kernel code, but
  cleanups are acceptable if they help to clarify what is going on.
  
  Oh, another thing: that code will currently race very nicely against
  'umount', and looks capable of triggering the 'VFS: Busy inodes after
  unmount of foo. Self-destruct in 5 seconds.  Have a nice day..." since
  it doesn't do anything to pin the super block while holding a reference
  to the inode.

There's a patch in Benny's tree that I think addresses these issues in
addition to the compiler warnings.  Maybe Benny would like to move it
forward?
