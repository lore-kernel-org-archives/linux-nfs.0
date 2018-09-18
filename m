Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:40922 "EHLO
        elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1729156AbeIRWlP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Sep 2018 18:41:15 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: <zhu.shangzhong@zte.com.cn>, <devel@lists.nfs-ganesha.org>,
        <linux-nfs@vger.kernel.org>
References: <201809171939042772224@zte.com.cn>
In-Reply-To: <201809171939042772224@zte.com.cn>
Subject: RE: [NFS-Ganesha-Devel] [NFS-Ganesha-Devel]ceph_fsal_setattr2 returned Operation not permitted
Date: Tue, 18 Sep 2018 10:07:43 -0700
Message-ID: <013901d44f72$1df02350$59d069f0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ah, when FSAL_CEPH was written, Ceph didn't have CEPH_SETATTR_ATIME_NOW =
and CEPH_SETATTR_MTIME_NOW. Now that they are available, we should use =
them. We may need to conditional compile.

Frank

> -----Original Message-----
> From: zhu.shangzhong@zte.com.cn [mailto:zhu.shangzhong@zte.com.cn]
> Sent: Monday, September 17, 2018 4:39 AM
> To: devel@lists.nfs-ganesha.org; linux-nfs@vger.kernel.org
> Subject: [NFS-Ganesha-Devel] [NFS-Ganesha-Devel]ceph_fsal_setattr2 =
returned
> Operation not permitted
>=20
> How to reproduce:
> 1. mount the nfs-ganesha export directory with NFSV3 2. create new =
users:
> user1 and user2, there is the same user group for user1 and user2
>     uid=3D9998(user1) gid=3D100(users) groups=3D100(users)
>     uid=3D9997(user2) gid=3D100(users) groups=3D100(users) 3. log in =
using user1 and
> create new file named abc.txt 4. chmod 664 abc.txt 5. log in using =
user2, and
> write new content to abc.txt
>     echo 'Hello' > abc.txt
> 6. The error "Operation not permitted" will be output
>=20
> Expected result:
> user2 may write data to file abc.txt successfully.
>=20
> The more detailed info could be found in =
http://tracker.ceph.com/issues/35961
> The issue may be fixed by changing the following code, is it =
appropriate changes
> for fixing the issue?
>=20
> src\FSAL\FSAL_CEPH\handle.c
> fsal_status_t ceph_setattr2(struct fsal_obj_handle *obj_hdl, bool =
bypass, struct
> state_t *state, struct attrlist *attrib_set) { ...
> 	if (FSAL_TEST_MASK(attrib_set->valid_mask, ATTR_ATIME_SERVER)) {
> 		struct timespec timestamp;
> mask |=3D CEPH_SETATTR_ATIME;  //
> s/CEPH_SETATTR_ATIME/CEPH_SETATTR_ATIME_NOW
> ...
> if (FSAL_TEST_MASK(attrib_set->valid_mask, ATTR_MTIME_SERVER)) {
> 		struct timespec timestamp;
> mask |=3D CEPH_SETATTR_MTIME; //
> s/CEPH_SETATTR_MTIME/CEPH_SETATTR_MTIME_NOW
> ...
> }
