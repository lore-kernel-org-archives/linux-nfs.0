Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:40947 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab2DWPXg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 11:23:36 -0400
Received: by wejx9 with SMTP id x9so7530639wej.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 08:23:35 -0700 (PDT)
From: Miklos Szeredi <miklos@szeredi.hu>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        Malahal Naineni <malahal@us.ibm.com>,
        Steve Dickson <SteveD@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        viro@zeniv.linux.org.uk, hch@infradead.org,
        michael.brantley@deshaw.com, sven.breuner@itwm.fraunhofer.de,
        pstaubach@exagrid.com, trond.myklebust@fys.uio.no, rees@umich.edu
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
	<87hawasdrb.fsf@tucsk.pomaz.szeredi.hu>
	<9991AAC7-5256-4AFE-9722-7AF1119EE7BE@oracle.com>
Date: Mon, 23 Apr 2012 17:23:54 +0200
In-Reply-To: <9991AAC7-5256-4AFE-9722-7AF1119EE7BE@oracle.com> (Chuck Lever's
	message of "Mon, 23 Apr 2012 11:02:32 -0400")
Message-ID: <874nsasc8l.fsf@tucsk.pomaz.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> writes:

> On Apr 23, 2012, at 10:51 AM, Miklos Szeredi wrote:
>
>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>> 
>>> 
>>> I also wonder whether it would be making too many assumptions about the
>>> server or filesystem: just because ordinary posix interfaces don't allow
>>> atomic replacement of a whole directory tree doesn't mean the server
>>> might not have some way to do it.
>> 
>> Exactly because posix limits the atomic replacement to empty directories
>> is that this feature is not useful and is why linux can get away with
>> the dead directory behavior in this case.  And thinking about fixing
>> this in NFS is completely pointless since no one will rely on the atomic
>> replacement behavior.  Fixing local filesystems is also pointless for
>> the same reason.
>> 
>> Atomic replacement of whole directory trees would indeed be more useful,
>> but it's highly unlikely to be used anywhere since applications relying
>> on this feature would be limited to special filesystems that allow this.
>
> The cases I can think of have to do with file system restore, file
> system and block device snapshots, and so on.  This type of use case
> may not practical on today's Linux server, but they are a reality for
> anyone using high-end NFS storage.

Problem with this is: if some directory file handles are stale (e.g. due
to directories being removed, recreated, moved around) and on the client
there are cwd-s referring to these handles, then they are going to
become stale no matter what you do, even if the same path does exist
after the restore on the server.

Thanks,
Miklos
