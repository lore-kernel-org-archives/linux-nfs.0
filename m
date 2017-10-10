Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40012 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753333AbdJJT1H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 10 Oct 2017 15:27:07 -0400
Date: Tue, 10 Oct 2017 15:27:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [GIT PULL] nfsd changes for 4.14-rc
Message-ID: <20171010192706.GA18513@fieldses.org>
References: <20171010182425.GA19163@fieldses.org>
 <CA+55aFz5vGYnwzZ5mMQz5PXXRaMd3RaDF_fe11WKRDzWJCahJQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+55aFz5vGYnwzZ5mMQz5PXXRaMd3RaDF_fe11WKRDzWJCahJQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 10, 2017 at 11:42:01AM -0700, Linus Torvalds wrote:
> On Tue, Oct 10, 2017 at 11:24 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Please pull nfsd fixes from
> >
> >   git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.14-1
> 
> There's nothing there. That tag just points to my 4.14-rc1 commit.
> 
> > One fix for a 4.14 regression, and one minor fix to the MAINTAINERs
> > file. (I was weirdly flattered by the idea that lots of random people
> > suddenly seemed to think Jeff and I were VFS experts.  Turns out it was
> > just a typo.)
> 
> .. and there's also no diffstat and commit list in your pull request,
> probably exactly because you screwed up the tag so there's nothing to
> pull..

Sigh, so it's not like I didn't have enough warning signs.

I just deleted redid the tag with the same name.  (Does it cause a
problem that the old object is still sitting around somewhere with the
same name but nothing pointing at it?  I'm assuming not.)

--b.

  git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.14-1

----------------------------------------------------------------
One fix for a 4.14 regression, and one minor fix to the MAINTAINERs
file. (I was weirdly flattered by the idea that lots of random people
suddenly seemed to think Jeff and I were VFS experts.  Turns out it was
just a typo.)

----------------------------------------------------------------
Eric Biggers (1):
      MAINTAINERS: associate linux/fs.h with VFS instead of file locking

Eryu Guan (1):
      nfsd4: define nfsd4_secinfo_no_name_release()

 MAINTAINERS        | 4 ++--
 fs/nfsd/nfs4proc.c | 9 ++++++++-
 2 files changed, 10 insertions(+), 3 deletions(-)
