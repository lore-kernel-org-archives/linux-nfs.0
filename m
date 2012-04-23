Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:37537 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292Ab2DWOur (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 10:50:47 -0400
Received: by bkcik5 with SMTP id ik5so8697580bkc.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 07:50:45 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@redhat.com>, Malahal Naineni <malahal@us.ibm.com>,
        Steve Dickson <SteveD@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        chuck.lever@oracle.com, pstaubach@exagrid.com,
        trond.myklebust@fys.uio.no, rees@umich.edu
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors from getattr call
References: <20120420104055.511e15bc@tlielax.poochiereds.net>
	<4F91C49D.8070908@RedHat.com> <20120420203725.GA3512@us.ibm.com>
	<20120420171314.73801874@corrin.poochiereds.net>
	<CAJfpegt40cgMJQQo3JuNaaS1w957Y2a_NxVoyvx3bmTMj1TGOA@mail.gmail.com>
	<20120423080012.7c23ef24@tlielax.poochiereds.net>
	<20120423130009.GA13681@fieldses.org>
	<20120423091255.00f926c4@tlielax.poochiereds.net>
	<20120423133412.GB13681@fieldses.org>
	<20120423095021.1a91a23b@tlielax.poochiereds.net>
	<20120423135456.GC13681@fieldses.org>
Date: Mon, 23 Apr 2012 16:51:04 +0200
In-Reply-To: <20120423135456.GC13681@fieldses.org> (J. Bruce Fields's message
	of "Mon, 23 Apr 2012 09:54:56 -0400")
Message-ID: <87hawasdrb.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> writes:

>
> I also wonder whether it would be making too many assumptions about the
> server or filesystem: just because ordinary posix interfaces don't allow
> atomic replacement of a whole directory tree doesn't mean the server
> might not have some way to do it.

Exactly because posix limits the atomic replacement to empty directories
is that this feature is not useful and is why linux can get away with
the dead directory behavior in this case.  And thinking about fixing
this in NFS is completely pointless since no one will rely on the atomic
replacement behavior.  Fixing local filesystems is also pointless for
the same reason.

Atomic replacement of whole directory trees would indeed be more useful,
but it's highly unlikely to be used anywhere since applications relying
on this feature would be limited to special filesystems that allow this.

So my statement is "ENOENT is equivalent to ESTALE if already retrying
path lookup with LOOKUP_REVAL on any operation that takes an parent
directory and a name (lookup, create, link, unlink, symlink, mkdir,
rmdir, mknod, rename)."

This equivalence is in the sense that it doesn't change behavior
compared to local filesystems.

For other operations ENOENT is not equivalent to ESTALE.

Thanks,
Miklos
