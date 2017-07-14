Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30922 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751012AbdGNTtD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jul 2017 15:49:03 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: NFSv2 mounts use AUTH_NULL no matter what sec= is specified
Date: Fri, 14 Jul 2017 15:48:56 -0400
Message-Id: <E61926F0-2402-487C-8BEA-F36D7B86DDD5@oracle.com>
Cc: Dros Adamson <dros@primarydata.com>,
        Jeff Layton <jlayton@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I was trying to test a server NFS/RDMA change that happened to
effect the NFSv2 XDR decoders, and ran into this issue.

When I try to mount with NFSv2 and sec=sys, the mount succeeds,
but the RPCs use AUTH_NULL credentials. LOOKUP fails immediately
with EACCES if the server's export does not permit AUTH_NULL.

In v3.12, Jeff introduced a change to use a mock mount flavor
list for MNTv1, which does not return one:

commit fb9b02fda06798cfca975c8b7fae3e6188a30572
Author:     Jeff Layton <jlayton@redhat.com>
AuthorDate: Thu Jun 27 15:54:40 2013 -0400
Commit:     Trond Myklebust <Trond.Myklebust@netapp.com>
CommitDate: Fri Jun 28 15:51:51 2013 -0400

    nfs: have nfs_mount fake up a auth_flavs list when the server didn't provide it

The flavor list contains only AUTH_NULL. That is probably a
related change, though NFSv2 is still working at that point.

A full bisect ends on this commit, introduced in v3.13:

[cel@manet bisect]$ git bisect good
4d4b69dd847a098cdca341c45326f6c6f61b8691 is the first bad commit
commit 4d4b69dd847a098cdca341c45326f6c6f61b8691
Author: Weston Andros Adamson <dros@netapp.com>
Date:   Fri Oct 18 15:15:19 2013 -0400

    NFS: add support for multiple sec= mount options
    
    This patch adds support for multiple security options which can be
    specified using a colon-delimited list of security flavors (the same
    syntax as nfsd's exports file).
    
    This is useful, for instance, when NFSv4.x mounts cross SECINFO
    boundaries. With this patch a user can use "sec=krb5i,krb5p"
    to mount a remote filesystem using krb5i, but can still cross
    into krb5p-only exports.
    
    New mounts will try all security options before failing.  NFSv4.x
    SECINFO results will be compared against the sec= flavors to
    find the first flavor in both lists or if no match is found will
    return -EPERM.
    
    Signed-off-by: Weston Andros Adamson <dros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

:040000 040000 bd52b0280a77fcf84b9c97e12824f2ce552d4a68 4b7ff476542ef06fe6dfb009437dd50d16c593c7 M	fs
:040000 040000 d40e43b33868ecb3175e38773f4967005a05791f ba78d1063471fb6e2653234f1feda1c48f1762d2 M	include
[cel@manet bisect]$

There are some interesting quandaries here:

 - The mount uses AUTH_NULL no matter what "sec=" setting is
   specified; thus "sec=" is not effective on NFSv2 mounts
 - Shouldn't a "sec=sys" mount be rejected immediately if the
   only entry in the mount flavor list is AUTH_NULL ?
 - If "vers=3" is specified, there is a UID associated with
   each NFS operation, but if "vers=2" is specified, they will
   all be associated with "nobody" (assuming the export permits
   AUTH_NULL access)
 - Back in 2013, the community hadn't stopped testing NFSv2
   yet (I think) but this still got by somehow


WHY YOU SHOULD CARE ;-)

Even though this is NFSv2, this problem effects a large number
of kernels that are currently in use by distributions which
still ostensibly support NFSv2. Therefore I feel it needs to
be addressed upstream and backported to stable and distribution
kernels from v3.13 and newer. Unfortunately I won't have the
time to address this myself for a few weeks, so I'm posting
here hoping that someone closer to this code can have a crack
at it soon.

The reproducer is straightforward:

1. sudo mount -o vers=2,tcp,sec=sys server:/export /mnt
2. ls -l /mnt

This step fails with "Permission denied" on broken kernels.

3. sudo umount /mnt


--
Chuck Lever



