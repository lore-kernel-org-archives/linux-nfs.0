Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f54.google.com ([209.85.160.54]:54036 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbaFFT3P (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jun 2014 15:29:15 -0400
Received: by mail-pb0-f54.google.com with SMTP id jt11so2866395pbb.13
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jun 2014 12:29:15 -0700 (PDT)
Message-ID: <1402082953.28220.7.camel@ceramic.home.fifi.org>
Subject: Phantom ACL-related xattrs on 3.14.4 NFS client
From: Philippe Troin <phil@coldcreektech.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Date: Fri, 06 Jun 2014 12:29:13 -0700
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This happens on an NFS client running on:
Linux ceramic32 3.14.4 #1 SMP Fri May 30 00:52:07 PDT 2014 i686 i686 i386 GNU/Linux
(also happens on x86_64).

The NFS server can be either 3.14 or 3.13, it doesn't change a thing.

Mount options are:
(from /proc/mtab)
ceramic:/export/home/phil /home/phil nfs rw,nosuid,nodev,relatime,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=172.17.1.2,mountvers=3,mountport=20048,mountproto=tcp,local_lock=none,addr=172.17.1.2 0 0
(This is NFSv3)

The symptom:

Run getfacl on any NFS inode.  See there are no ACLs:

        % getfacl .
        # file: .
        # owner: phil
        # group: phil
        user::rwx
        group::r-x
        other::r-x

Yet, getfattr says there are some acl-related xattrs:

        % getfattr -m '.*' .
        # file: .
        system.posix_acl_access
        system.posix_acl_default

But when you want to retrieve these phantom xattrs, I get errors:

        % getfattr -n system.posix_acl_access . 
        .: system.posix_acl_access: No such attribute
        [1]    1136 exit 1     getfattr -n system.posix_acl_access .
        % getfattr -n system.posix_acl_default .
        .: system.posix_acl_default: No such attribute
        [1]    1146 exit 1     getfattr -n system.posix_acl_default .
        
I've noticed because it breaks the patch utility.

This is a regression from 3.13, probably due to the 3.14 NFS ACL overhaul.

I'm ready & willing to try patches.

Phil.

