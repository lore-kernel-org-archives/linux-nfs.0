Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out1.smtp.messagingengine.com ([66.111.4.25]:55205 "EHLO
	out1.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932229Ab1BXD3E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 22:29:04 -0500
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
From: Ian Kent <raven@themaw.net>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Nick Piggin <npiggin@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <20110224031439.GR22723@ZenIV.linux.org.uk>
References: <20110118040449.23109.33071.stgit@localhost6.localdomain6>
	 <1295420817.3076.24.camel@perseus> <1297779902.13007.86.camel@perseus>
	 <20110224015817.GQ22723@ZenIV.linux.org.uk>
	 <1298516618.2916.20.camel@perseus>
	 <20110224031439.GR22723@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Feb 2011 11:28:57 +0800
Message-ID: <1298518137.2916.35.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-24 at 03:14 +0000, Al Viro wrote:
> On Thu, Feb 24, 2011 at 11:03:38AM +0800, Ian Kent wrote:
> 
> > I also have a sick feeling that dentrys may become negative at any point
> > after __d_lookup_rcu() .....
> 
> Yes.  To get stability of ->d_inode (assuming the sucker isn't pinned down
> in normal way by ->d_count) you need ->d_lock.
> 
> > > Ho-hum...  I can reach RHTS, but I'd rather do that at home boxen, if
> > > possible...  Has it been reproduced on UP boxen with SMP kernels, BTW?
> > 
> > Nope, I'd need to build a kernel specifically for that. I'm not sure how
> > useful that would be though since the test is specifically meant to
> > expose problems with multiple concurrent processes accessing an
> > automount tree. I don't see any problem running the Connectathon tests
> > which is essentially one automount and one client process.
> 
> Heh...  No, it's just that the only SMP box I have locally right now
> is dual ultrasparc.  Anyway, I can live with RHTS.

If you want to get hold of the test I'm using checkout autofs-RHEL-5,
"cd autofs-tests/submount-test", "make rpm" and use the resulting
rh-tests-autofs-submount-test-1.0-15.noarch.rpm. There are some
beaker/rhts rpm dependencies. Let me know if it gets painful and I'll
try and work out what you need. The test isn't very flash but it does
stress autofs.

Ha, I haven't even turned on my Ultrsparc 2 in months, it's only got an
old version of Solaris on it now anyway, ;)


