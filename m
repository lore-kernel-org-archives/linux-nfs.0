Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f180.google.com ([209.85.128.180]:41080 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbaFFUhF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2014 16:37:05 -0400
Received: by mail-ve0-f180.google.com with SMTP id jw12so1028629veb.11
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jun 2014 13:37:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1402082953.28220.7.camel@ceramic.home.fifi.org>
References: <1402082953.28220.7.camel@ceramic.home.fifi.org>
Date: Fri, 6 Jun 2014 16:37:03 -0400
Message-ID: <CAHQdGtS2BL9u4DV=FZ0HaXO-iTNPU4hTGVR--HubNa4A_6UNog@mail.gmail.com>
Subject: Re: Phantom ACL-related xattrs on 3.14.4 NFS client
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Philippe Troin <phil@coldcreektech.com>,
        Christoph Hellwig <hch@infradead.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 6, 2014 at 3:29 PM, Philippe Troin <phil@coldcreektech.com> wrote:
> This happens on an NFS client running on:
> Linux ceramic32 3.14.4 #1 SMP Fri May 30 00:52:07 PDT 2014 i686 i686 i386 GNU/Linux
> (also happens on x86_64).
>
> The NFS server can be either 3.14 or 3.13, it doesn't change a thing.
>
> Mount options are:
> (from /proc/mtab)
> ceramic:/export/home/phil /home/phil nfs rw,nosuid,nodev,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=172.17.1.2,mountvers=3,mountport=20048,mountproto=tcp,local_lock=none,addr=172.17.1.2 0 0
> (This is NFSv3)
>
> The symptom:
>
> Run getfacl on any NFS inode.  See there are no ACLs:
>
>         % getfacl .
>         # file: .
>         # owner: phil
>         # group: phil
>         user::rwx
>         group::r-x
>         other::r-x
>
> Yet, getfattr says there are some acl-related xattrs:
>
>         % getfattr -m '.*' .
>         # file: .
>         system.posix_acl_access
>         system.posix_acl_default
>
> But when you want to retrieve these phantom xattrs, I get errors:
>
>         % getfattr -n system.posix_acl_access .
>         .: system.posix_acl_access: No such attribute
>         [1]    1136 exit 1     getfattr -n system.posix_acl_access .
>         % getfattr -n system.posix_acl_default .
>         .: system.posix_acl_default: No such attribute
>         [1]    1146 exit 1     getfattr -n system.posix_acl_default .
>
> I've noticed because it breaks the patch utility.
>
> This is a regression from 3.13, probably due to the 3.14 NFS ACL overhaul.
>

Christoph, what is the intended interface for telling
posix_acl_xattr_list() that there are no acls on a particular file?
Should there perhaps be a call to get_acl()?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
