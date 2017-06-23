Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39852 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751620AbdFWP3c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Jun 2017 11:29:32 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20170614175426.GA26229@htj.duckdns.org>
References: <20170614175426.GA26229@htj.duckdns.org> <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk> <149745355907.10897.10073768158664960494.stgit@warthog.procyon.org.uk>
To: Tejun Heo <tj@kernel.org>
Cc: dhowells@redhat.com, mszeredi@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Li Zefan <lizefan@huawei.com>,
        Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org
Subject: Re: [PATCH 27/27] kernfs, sysfs, cgroup: Support fs_context [ver #5]
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Date: Fri, 23 Jun 2017 16:29:28 +0100
Message-ID: <6414.1498231768@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tejun Heo <tj@kernel.org> wrote:

> > Make kernfs support superblock creation/mount/remount with fs_context.
> > 
> > This requires that sysfs and cgroup, which are built on kernfs, be made to
> > support fs_context also.
> 
> Can you please include a brief rationale for doing this and include a
> pointer to the fuller description on what's going on?

The overview is that I'm trying to create a method by which mount creation can
be better parameterised.  This includes:

 (1) Improved option passing from userspace.  We're limited to what we can
     cram into a single page and we have to pass all the options in one go.

     I was impressed by Miklós's idea that he presented at LSF/MM for opening
     an fd to the filesystem driver, passing the parameters individually by
     write() and then performing a mount from that, so I could permit:

     (a) Allow each individual option to exceed PAGE_SIZE in size.

     (b) Allow options to contain binary data as no characters need to be
     	 reserved for parsing tokens (NUL terminators, commas).

     (c) Allow feedback on individual options.

     (d) Allow the filesystem to ask for information, such as passwords.

     (e) Allow selection of a subtree of the "device" to actually use
     	 (ie. combine a bind mount with the mount).

 (2) Loading a context from an already mounted filesystem, thereby providing a
     better way of doing:

     (a) Bind mounts

     (b) Filesystem reconfiguration.

     (c) Parameter propagation to automounts/submounts.

 (3) Up-front parameter parsing and resource allocation.  This allows
     parameters to be parsed validated and resources to be allocated before we
     begin the super_block initialisation/creation/loading/whatever process,
     allowing us to get some error handling out of the way earlier.

     Ext4 has an interesting issue here: it will load the parameters from
     disk, then overlay them with the parameters given to sys_mount() as it
     parses them - but this will leave you with a half-set-up superblock if a
     parse error occurs.  I *think* the new-mount branch just discards the
     superblock in that case, but in the case of remount, only *some* of the
     changes will be applied - which is bad.

 (4) Better handling of namespaces - the fs_context gives us somewhere to
     anchor namespaces and potentially configure these before mounting.
     Certainly, it would give somewhere to pass namespace information to a
     submount.

     This would potentially make it possible to mount directly into someone
     else's namespaces for container handing.


I'd also like to make it possible to return better error messages from the
kernel as a lot of different things can go wrong during a mount and we only
have a small integer to convey this - plus dmesg, which might be inaccessible
and may mixed up with other things.

Originally, I implemented the supplementary error message handling as hanging
off the fs_context struct, but that got tricky with NFS because NFS4 creates a
mount for the root on a server and then invokes pathwalk to the intended path
from within the ->mount() function.

This pathwalk is expected to trip one or more automount points as changes in
FSID are detected - but they have no access to the parent fs_context struct in
which to supplement any error that is incurred.

So I've moved this to task_struct and provided a couple of prctls to manage it
- this also has the added bonus of making it more widely available and also
making it potentially useful to determine what happened in the case of an
automount failure.  However, Al would prefer me to move it back to the
fs_struct as it's too generic otherwise.

David
