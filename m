Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:37455 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728403AbeIRX0t (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Sep 2018 19:26:49 -0400
Received: by mail-qt0-f179.google.com with SMTP id n6-v6so2550098qtl.4
        for <linux-nfs@vger.kernel.org>; Tue, 18 Sep 2018 10:53:07 -0700 (PDT)
Message-ID: <754e4e356fb1083444756caf81515ff81c3b36f9.camel@redhat.com>
Subject: Re: [NFS-Ganesha-Devel] [NFS-Ganesha-Devel]ceph_fsal_setattr2
 returned Operation not permitted
From: Jeff Layton <jlayton@redhat.com>
To: zhu.shangzhong@zte.com.cn, devel@lists.nfs-ganesha.org,
        linux-nfs@vger.kernel.org
Date: Tue, 18 Sep 2018 13:53:03 -0400
In-Reply-To: <201809171939042772224@zte.com.cn>
References: <201809171939042772224@zte.com.cn>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2018-09-17 at 19:39 +0800, zhu.shangzhong@zte.com.cn wrote:
> How to reproduce:
> 1. mount the nfs-ganesha export directory with NFSV3
> 2. create new users: user1 and user2, there is the same user group for user1 and user2
>     uid=9998(user1) gid=100(users) groups=100(users)
>     uid=9997(user2) gid=100(users) groups=100(users)
> 3. log in using user1 and create new file named abc.txt
> 4. chmod 664 abc.txt
> 5. log in using user2, and write new content to abc.txt
>     echo 'Hello' > abc.txt
> 6. The error "Operation not permitted" will be output
> 
> Expected result:
> user2 may write data to file abc.txt successfully.
> 
> The more detailed info could be found in http://tracker.ceph.com/issues/35961
> The issue may be fixed by changing the following code, is it appropriate changes for fixing the issue?
> 
> src\FSAL\FSAL_CEPH\handle.c
> fsal_status_t ceph_setattr2(struct fsal_obj_handle *obj_hdl, bool bypass, struct state_t *state, struct attrlist *attrib_set)
> {
> ...
> 	if (FSAL_TEST_MASK(attrib_set->valid_mask, ATTR_ATIME_SERVER)) {
> 		struct timespec timestamp;
> mask |= CEPH_SETATTR_ATIME;  // s/CEPH_SETATTR_ATIME/CEPH_SETATTR_ATIME_NOW
> ...
> if (FSAL_TEST_MASK(attrib_set->valid_mask, ATTR_MTIME_SERVER)) {
> 		struct timespec timestamp;
> mask |= CEPH_SETATTR_MTIME; // s/CEPH_SETATTR_MTIME/CEPH_SETATTR_MTIME_NOW
> ...
> }]

If I'm reading the ceph code right, then we need to do:

    mask |= CEPH_SETATTR_MTIME|CEPH_SETATTR_MTIME_NOW;

The *_NOW fields just override how permissions are checked.

-- 
Jeff Layton <jlayton@redhat.com>
