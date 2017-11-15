Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:42018 "EHLO
        mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754099AbdKOQKw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Nov 2017 11:10:52 -0500
Received: by mail-io0-f176.google.com with SMTP id u42so2077292ioi.9
        for <linux-nfs@vger.kernel.org>; Wed, 15 Nov 2017 08:10:51 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
Message-ID: <1510762249.2569.19.camel@gmail.com>
Subject: Re: [RFC v3 0/7] NFS Force Unmounting
To: Trond Myklebust <trondmy@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>,
        "neilb@suse.com" <neilb@suse.com>
Cc: "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>
Date: Wed, 15 Nov 2017 10:10:49 -0600
In-Reply-To: <1510753204.9878.52.camel@primarydata.com>
References: <20171114230631.14682-1-JPEWhacker@gmail.com>
         <1510753204.9878.52.camel@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-11-15 at 13:40 +0000, Trond Myklebust wrote:
> On Tue, 2017-11-14 at 17:06 -0600, Joshua Watt wrote:
> > After some additional testing on version 2, I realized that 1) my
> > test
> > setup was bad (Doh!) and 2) using remount isn't really an ideal
> > method
> > for setting the "serverfailed" mount flag. The reason being that
> > any
> > userspace remount is going to touch the file system and probably
> > invoke
> > some RPCs for inode validation as such. If the server is truly
> > dead,
> > these RPCs will have to time out before the flag could actually be
> > set.
> > This not only takes a long time, but will probably also fail,
> > causing
> > the remount to fail and not set the flag, defeating the purpose.
> 
> Why? There should be no reason to have to revalidate the path in
> order
> to change mount options on a mount point.

I figured this out... the revalidation is not required for the mount(2)
syscall when remounting. However, libmount tries to do a few file
system checks that do required validation. You can convince it to skip
these checks like so:

 mount -c 172.16.9.0:/ /tmp/nfsmount -o remount,serverfailed

The "-c" prevents canonicalizing the mount path (meaning you must
provide the canonical path on the command line), and you have to
specify the "block device" (e.g. "172.16.9.0:/") to prevent it doing
some fstatat() checks on the mount path while parsing through mtab.

It's annoying you can't do the easier:

 mount /tmp/nfsmount -o remount,serverfailed

but that's not the kernels fault.

> 
> > This patch set works around this by exposing the failed server flag
> > in
> > debugfs. In addition, the flag now applies at the nfs_client level
> > (instead of the nfs_server). Setting the flag will cancel all RPCs
> > in
> > the client, as well as all nfs_servers attached to it. This ensures
> > that
> > you get all the mounts, even when dealing with submounts that cross
> > remote device boundaries. This is also where the nosharecache
> > option
> > applying to nfs_clients becomes useful... it will prevent sharing
> > between other explicit mount calls, but submounts will all still
> > share a
> > nfs_client (and fail together).
> > 
> > Obviously, debugfs is not a permanent solution for this, so some
> > discussion needs to be had on how this will be administered "in the
> > real
> > world" (I think "remount" is off the table).
> > 
> 
> We're not adding any APIs to debugfs. That's a deal breaker...

Sure. Is the mount option still the best way forward then, or are there
other options to be explored?

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
