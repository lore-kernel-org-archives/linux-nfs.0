Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:36619 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbdECR13 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 May 2017 13:27:29 -0400
Received: by mail-qt0-f180.google.com with SMTP id m91so10509475qte.3
        for <linux-nfs@vger.kernel.org>; Wed, 03 May 2017 10:27:29 -0700 (PDT)
Message-ID: <1493832439.3180.1.camel@poochiereds.net>
Subject: Re: [RFC][PATCH 0/9] VFS: Introduce mount context
From: Jeff Layton <jlayton@poochiereds.net>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mszeredi@redhat.com
Date: Wed, 03 May 2017 13:27:19 -0400
In-Reply-To: <31716.1493830216@warthog.procyon.org.uk>
References: <1493829847.2699.3.camel@poochiereds.net>
         <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <31716.1493830216@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-05-03 at 17:50 +0100, David Howells wrote:
> Jeff Layton <jlayton@poochiereds.net> wrote:
> 
> > >  (*) Move the walk-from-root stuff that nfs has to generic code so that you
> > >      can do something akin to:
> > > 
> > > 	mount /dev/sda1:/foo/bar /mnt
> > > 
> > >      See nfs_follow_remote_path() and mount_subtree().  This is slightly
> > >      tricky in NFS as we have to prevent referral loops.
> > > 
> > 
> > ':' is a legitimate character in a path component. How will you
> > distinguish that case?
> 
> Fair point.  Could instead do something like:
> 
> 	mount /dev/sda1 /mnt -o subroot=/foo/bar
> 
> or just limit it to the fsopen interface.
> 
> 

Yeah, something like that would certainly work. I like the basic idea
though of combining a mount and bind mount for local fs'.
-- 
Jeff Layton <jlayton@poochiereds.net>
