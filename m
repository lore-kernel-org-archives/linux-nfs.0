Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:38829 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657Ab2DWPDQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 11:03:16 -0400
Subject: Re: [PATCH RFC v3] vfs: make fstatat retry once on ESTALE errors from getattr call
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <87hawasdrb.fsf@tucsk.pomaz.szeredi.hu>
Date: Mon, 23 Apr 2012 11:02:32 -0400
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        Malahal Naineni <malahal@us.ibm.com>,
        Steve Dickson <SteveD@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        pstaubach@exagrid.com, trond.myklebust@fys.uio.no, rees@umich.edu
Message-Id: <9991AAC7-5256-4AFE-9722-7AF1119EE7BE@oracle.com>
References: <20120420104055.511e15bc@tlielax.poochiereds.net> <4F91C49D.8070908@RedHat.com> <20120420203725.GA3512@us.ibm.com> <20120420171314.73801874@corrin.poochiereds.net> <CAJfpegt40cgMJQQo3JuNaaS1w957Y2a_NxVoyvx3bmTMj1TGOA@mail.gmail.com> <20120423080012.7c23ef24@tlielax.poochiereds.net> <20120423130009.GA13681@fieldses.org> <20120423091255.00f926c4@tlielax.poochiereds.net> <20120423133412.GB13681@fieldses.org> <20120423095021.1a91a23b@tlielax.poochiereds.net> <20120423135456.GC13681@fieldses.org> <87hawasdrb.fsf@tucsk.pomaz.szeredi.hu>
To: Miklos Szeredi <miklos@szeredi.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 23, 2012, at 10:51 AM, Miklos Szeredi wrote:

> "J. Bruce Fields" <bfields@fieldses.org> writes:
> 
>> 
>> I also wonder whether it would be making too many assumptions about the
>> server or filesystem: just because ordinary posix interfaces don't allow
>> atomic replacement of a whole directory tree doesn't mean the server
>> might not have some way to do it.
> 
> Exactly because posix limits the atomic replacement to empty directories
> is that this feature is not useful and is why linux can get away with
> the dead directory behavior in this case.  And thinking about fixing
> this in NFS is completely pointless since no one will rely on the atomic
> replacement behavior.  Fixing local filesystems is also pointless for
> the same reason.
> 
> Atomic replacement of whole directory trees would indeed be more useful,
> but it's highly unlikely to be used anywhere since applications relying
> on this feature would be limited to special filesystems that allow this.

The cases I can think of have to do with file system restore, file system and block device snapshots, and so on.  This type of use case may not practical on today's Linux server, but they are a reality for anyone using high-end NFS storage.

> So my statement is "ENOENT is equivalent to ESTALE if already retrying
> path lookup with LOOKUP_REVAL on any operation that takes an parent
> directory and a name (lookup, create, link, unlink, symlink, mkdir,
> rmdir, mknod, rename)."
> 
> This equivalence is in the sense that it doesn't change behavior
> compared to local filesystems.
> 
> For other operations ENOENT is not equivalent to ESTALE.
> 
> Thanks,
> Miklos
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




