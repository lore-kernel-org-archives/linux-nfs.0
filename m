Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57590 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751287AbdECQuT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 May 2017 12:50:19 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1493829847.2699.3.camel@poochiereds.net>
References: <1493829847.2699.3.camel@poochiereds.net> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Subject: Re: [RFC][PATCH 0/9] VFS: Introduce mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 03 May 2017 17:50:16 +0100
Message-ID: <31716.1493830216@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@poochiereds.net> wrote:

> >  (*) Move the walk-from-root stuff that nfs has to generic code so that you
> >      can do something akin to:
> > 
> > 	mount /dev/sda1:/foo/bar /mnt
> > 
> >      See nfs_follow_remote_path() and mount_subtree().  This is slightly
> >      tricky in NFS as we have to prevent referral loops.
> > 
> 
> ':' is a legitimate character in a path component. How will you
> distinguish that case?

Fair point.  Could instead do something like:

	mount /dev/sda1 /mnt -o subroot=/foo/bar

or just limit it to the fsopen interface.

David
