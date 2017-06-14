Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f176.google.com ([209.85.213.176]:33811 "EHLO
        mail-yb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751714AbdFNRy3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Jun 2017 13:54:29 -0400
Date: Wed, 14 Jun 2017 13:54:26 -0400
From: Tejun Heo <tj@kernel.org>
To: David Howells <dhowells@redhat.com>
Cc: mszeredi@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Li Zefan <lizefan@huawei.com>,
        Johannes Weiner <hannes@cmpxchg.org>, cgroups@vger.kernel.org
Subject: Re: [PATCH 27/27] kernfs, sysfs, cgroup: Support fs_context [ver #5]
Message-ID: <20170614175426.GA26229@htj.duckdns.org>
References: <149745330648.10897.9605870130502083184.stgit@warthog.procyon.org.uk>
 <149745355907.10897.10073768158664960494.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <149745355907.10897.10073768158664960494.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, David.

On Wed, Jun 14, 2017 at 04:19:19PM +0100, David Howells wrote:
> Make kernfs support superblock creation/mount/remount with fs_context.
> 
> This requires that sysfs and cgroup, which are built on kernfs, be made to
> support fs_context also.

Can you please include a brief rationale for doing this and include a
pointer to the fuller description on what's going on?

> Weirdies:
> 
>  (*) cgroup_do_get_tree() calls cset_cgroup_from_root() with locks held,
>      but then uses the resulting pointer after dropping the locks.  I'm
>      told this is okay and needs commenting.

Yeah, will add the comment.

>  (*) The cgroup refcount web.  This really needs documenting.

If you're talking about the mount refcnt part, yeah, it's confusing to
me too and we definitely need to document it better.

>  (*) cgroup2 only has one root?

Yeap.

Thanks.

-- 
tejun
