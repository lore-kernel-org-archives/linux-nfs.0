Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:39560 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932340Ab1BXD6m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Feb 2011 22:58:42 -0500
Date: Thu, 24 Feb 2011 03:58:37 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Ian Kent <raven@themaw.net>
Cc: Nick Piggin <npiggin@kernel.dk>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        David Howells <dhowells@redhat.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Fixes for vfs-scale and vfs-automount
Message-ID: <20110224035836.GS22723@ZenIV.linux.org.uk>
References: <20110118040449.23109.33071.stgit@localhost6.localdomain6>
 <1295420817.3076.24.camel@perseus>
 <1297779902.13007.86.camel@perseus>
 <20110224015817.GQ22723@ZenIV.linux.org.uk>
 <1298516618.2916.20.camel@perseus>
 <20110224031439.GR22723@ZenIV.linux.org.uk>
 <1298518137.2916.35.camel@perseus>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1298518137.2916.35.camel@perseus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Feb 24, 2011 at 11:28:57AM +0800, Ian Kent wrote:

> Ha, I haven't even turned on my Ultrsparc 2 in months, it's only got an
> old version of Solaris on it now anyway, ;)

U60, with lenny (and mainline kernel) on it.  Probably ought to upgrade
to squeeze one of those days...  It works, all right, but it's only 2-way,
so reproducing would probably be harder.  Plus the fun of building the tests
themselves on somewhat different userland...

Anyway, I wonder why you care about __d_lookup_rcu() and ->d_inode stability;
d_mountpoint() _is_ stable at that point (we hold vfsmount_lock) and you
don't seem to look at ->d_inode at all in RCU case.  Note that ->d_automount()
is never called in RCU case at all; nor is ->lookup() and friends, so you
really only have ->d_manage() to cope with, what with autofs4 having no
->d_revalidate() anymore.

BTW, Nick has moved to kernel.dk; whether he's still reachable there is
a question, though - he seems to have disappeared since mid-January.
