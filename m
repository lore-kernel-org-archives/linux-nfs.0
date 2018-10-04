Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57382 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725997AbeJEFqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 Oct 2018 01:46:16 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <87a7nttm5o.fsf@notabene.neil.brown.name>
References: <87a7nttm5o.fsf@notabene.neil.brown.name> <153861496327.30373.10501882399296347125.stgit@noble> <153861471803.30373.6184444014227748848.stgit@noble> <28763.1538662213@warthog.procyon.org.uk>
To: NeilBrown <neilb@suse.com>
Cc: dhowells@redhat.com, "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Jan Harkes <jaharkes@cs.cmu.edu>, linux-nfs@vger.kernel.org,
        Miklos Szeredi <miklos@szeredi.hu>,
        Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, coda@cs.cmu.edu,
        linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/3] VFS: introduce MAY_ACT_AS_OWNER
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 04 Oct 2018 23:50:34 +0100
Message-ID: <2793.1538693434@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown <neilb@suse.com> wrote:

> Thanks for the review.
> As afs doesn't use the generic xattr code and doesn't call
> setattr_prepare(), this is all largely irrelevant for afs.

Yeah - there's no xattr support yet.

> afs_permission() will probably only get MAY_ACT_AS_OWNER passed when
> someone uses fcntl(F_SETFL) to set the O_NOATIME flag.

There's no atime in AFS.

> Currently a permission test based on UID is performed which, as you say,
> is wrong.  My patch simply preserved this current (wrong) behaviour.
> Shall I change it to always allow access, like with NFS?

You have to have an appropriate key to be able to do anything not granted to
anonymous with the server.  If the server says your key (or lack thereof) is
allowed to do something, you can do it; if it does not, you can't.

> Probably O_NOATIME is ignored, in which case f_op->check_flags should
> probably report -EINVAL (???) ... or might that cause a regression?

No atime.  I just ignore things like O_NOATIME.  You will be able to query the
filesystem with fsinfo() hopefully soon to find out if there is an atime and
if you can disable it.

Davod
