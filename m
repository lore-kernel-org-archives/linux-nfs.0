Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45318 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751662AbdH2VwJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Aug 2017 17:52:09 -0400
Date: Tue, 29 Aug 2017 17:52:09 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 0/3] Eliminate delegation self-conflicts
Message-ID: <20170829215209.GA13385@fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
 <1BD0901E-8339-4993-A012-9F8402BF16EF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1BD0901E-8339-4993-A012-9F8402BF16EF@oracle.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 26, 2017 at 02:06:05PM -0400, Chuck Lever wrote:
> 
> > On Aug 25, 2017, at 5:52 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > This is my attempt to fix the NFS server so we don't unnecessarily
> > recall delegations when the operation breaking the delegation comes from
> > the same client that holds the delegation.
> > 
> > To do that we need some way to pass the identity of the breaker down
> > through the VFS.
> > 
> > I didn't feel like adding another argument to all the VFS functions that
> > this might need to be passed down through.  But all of those functions
> > already take a struct inode **delegated inode, so instead I turned that
> > into a single-member struct deleg_ctrl *, which I then added a second
> > member to.
> > 
> > I dunno, welcome any more straightforward ways of doing this if anyone
> > has suggestions.
> > 
> > My first attempt was to do this by instead checking for conflicts in the
> > caller (nfsd) and then passing down one just one bit telling the lease
> > code conflicts had already been checked so it didn't need to.  But
> > that's much too early to check for conflicts, since the caller doesn't
> > have the necessary inode locks yet.
> > 
> > I'm still missing testing.  Regression tests pass, but I haven't
> > actually confirmed that the self-conflicts are gone!  Off to go hack on
> > pynfs....
> 
> FWIW, I observe a lot of delegation recall activity when running

How are you measuring that?

> the git regression tests on an NFSv4.x mount. This is a single
> client.

> 
> Unpack a recent release of the git tarball.
> 
> $ cd src/git
> $ make clean
> $ make
> $ make test
> 
> Easily scriptable, and you can "cd t/" and run individual
> regression tests if you like.

Thanks, I'll look into that.

--b.
