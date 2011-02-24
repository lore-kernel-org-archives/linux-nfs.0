Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34274 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932071Ab1BXDPA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 22:15:00 -0500
Date: Thu, 24 Feb 2011 03:14:39 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Ian Kent <raven@themaw.net>
Cc: Nick Piggin <npiggin@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
Message-ID: <20110224031439.GR22723@ZenIV.linux.org.uk>
References: <20110118040449.23109.33071.stgit@localhost6.localdomain6>
 <1295420817.3076.24.camel@perseus>
 <1297779902.13007.86.camel@perseus>
 <20110224015817.GQ22723@ZenIV.linux.org.uk>
 <1298516618.2916.20.camel@perseus>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1298516618.2916.20.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 24, 2011 at 11:03:38AM +0800, Ian Kent wrote:

> I also have a sick feeling that dentrys may become negative at any point
> after __d_lookup_rcu() .....

Yes.  To get stability of ->d_inode (assuming the sucker isn't pinned down
in normal way by ->d_count) you need ->d_lock.

> > Ho-hum...  I can reach RHTS, but I'd rather do that at home boxen, if
> > possible...  Has it been reproduced on UP boxen with SMP kernels, BTW?
> 
> Nope, I'd need to build a kernel specifically for that. I'm not sure how
> useful that would be though since the test is specifically meant to
> expose problems with multiple concurrent processes accessing an
> automount tree. I don't see any problem running the Connectathon tests
> which is essentially one automount and one client process.

Heh...  No, it's just that the only SMP box I have locally right now
is dual ultrasparc.  Anyway, I can live with RHTS.
