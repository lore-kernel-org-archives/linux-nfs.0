Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from barracuda.gccsda.com ([66.110.220.202]:52964 "EHLO
	barracuda.gccsda.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbCKOjk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Mar 2015 10:39:40 -0400
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176]) by barracuda.gccsda.com with ESMTP id nQeT6mzsddPLfVjN (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NO) for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2015 10:39:40 -0400 (EDT)
Received: by qcxr5 with SMTP id r5so10676144qcx.4
        for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2015 07:39:40 -0700 (PDT)
MIME-Version: 1.0
From: Andrew LaPierre <alapierre@gccsda.com>
Date: Wed, 11 Mar 2015 10:39:19 -0400
Message-ID: <CAGM=iFHupH6xQmPZzysfkWL2bSFEAax-cjYyzjzKsNsox-J0kg@mail.gmail.com>
Subject: rsync ACLs over NFSv4 - rsync_xal_set: lsetxattr - Operation not supported
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm hopeful somebody can give me direction on this, I've been
searching for over a week for a solution and have turned up nil.
Thanks for looking!

I'm trying to rsync with options --acls --xattrs over an NFSv4 mount
TO an ext4 drive FROM an ext4 drive and both have acl and user_xattr
enabled. The command:

    rsync -aAX /data/ /mnt/back/data

results in:

    rsync: rsync_xal_set:
lsetxattr(""/mnt/back/data/Users/user/Documents/Desktop"","security.NTACL")
failed: Operation not supported (95)

along with all the other files.

Running the same command to a local folder works perfect so I'm
assuming it has something to do with NFS4 or EXT4 on the Server side.

My fstab mount:

    UUID=732683f0-e6ac-42d6-a492-e07643d7719c /media/back   ext4
defaults,acl,user_xattr,barrier=1       0       0

My nfs exports file:

    /media/back  10.111.106.3(fsid=0,rw,async,no_root_squash,no_subtree_check)

My mount command:

    mount -t nfs4 -o proto=tcp,port=2049 10.111.106.12:/ /mnt/back

Version info:

Server

    Ubuntu 14.04.2

Client

    Ubuntu 14.04.2
    rsync 3.1.0

Thanks for any suggestions!
