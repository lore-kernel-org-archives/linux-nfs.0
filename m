Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oxalide-out.extra.cea.fr ([132.168.224.8]:57189 "EHLO
	oxalide-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab1LEOCW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Dec 2011 09:02:22 -0500
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by oxalide.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.2) with ESMTP id pB5DqAR8001088
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 5 Dec 2011 14:52:10 +0100
Received: from muguet2.intra.cea.fr (muguet2.intra.cea.fr [132.166.192.7])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id pB5DqADQ019549
	for <linux-nfs@vger.kernel.org>; Mon, 5 Dec 2011 14:52:10 +0100
	(envelope-from philippe.deniel@cea.fr)
Received: from zia.esteban.ctsi (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet2.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id pB5Dq9x1005810
	for <linux-nfs@vger.kernel.org>; Mon, 5 Dec 2011 14:52:09 +0100
Message-ID: <4EDCCC89.6080205@cea.fr>
Date: Mon, 05 Dec 2011 14:52:09 +0100
From: DENIEL Philippe <philippe.deniel@cea.fr>
MIME-Version: 1.0
To: Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Help wanted: ENOCLK returned during lock test#2 in connectathon's
 test
Content-Type: multipart/mixed;
 boundary="------------050200060204020800000406"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050200060204020800000406
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

as you may know (we may have met at Bake-A-Thon), I am working on 
NFS-Ganesha, a NFS server running in userspace. I currently face an 
issue when running cthon04 test suite, during the "lock step".
Client is linux 3.1.0-rc4, server is nfs-ganesha compiled with FSAL_VFS 
support. Server is mounted via command "mount 
-overs=4.minorversion=1,lock <server>:<path> /mnt"

During the test#2 in "lock" tests, I got the following error:

    Creating parent/child synchronization pipes.

    Test #2 - Try to lock the whole file.
            Parent: 2.0  - F_TLOCK [               0,          ENDING]
    FAILED!
            Parent: **** Expected success, returned errno=37...
            Parent: **** Probably implementation error.

    ** PARENT pass 1 results: 0/0 pass, 0/0 warn, 1/1 fail (pass/total).

    **  CHILD pass 1 results: 0/0 pass, 0/0 warn, 0/0 fail (pass/total).


I made a wireshark capture of the packet (see attachement). Apparently, 
the client does 2 compounds, one for OP4_OPEN and a second to call 
OP4_OPEN_CONFIRM.

On the client side, the "locl/locklfs" binary fails when calling lockf() 
(this is not the first time it calls it, it has been done in test#1 
which passed successfully). Error return is ENOLCK (posix error #37).
I enabled the kernel's debug message by using the command 'echo 32767 > 
/proc/sys/sunrpc/nfs_debug' (complete log in attachement, reduced to 
what is related to lock#2). Grepping 'NFS' in this shows this:

    Dec  5 13:31:08 aury63 kernel: NFS: nfs_update_inode(0:16/523265
    ct=2 info=0x27e7f)
    Dec  5 13:31:08 aury63 kernel: NFS: permission(0:16/523265),
    mask=0x1, res=0
    Dec  5 13:31:08 aury63 kernel: NFS: nfs_lookup_revalidate(/rep) is valid
    Dec  5 13:31:08 aury63 kernel: NFS: nfs_update_inode(0:16/544895
    ct=1 info=0x27e7f)
    Dec  5 13:31:08 aury63 kernel: NFS: permission(0:16/544895),
    mask=0x1, res=0
    Dec  5 13:31:08 aury63 kernel: NFS: permission(0:16/544895),
    mask=0x1, res=0
    Dec  5 13:31:08 aury63 kernel: NFS: atomic_lookup(0:16/544895),
    lockfile2908
    Dec  5 13:31:08 aury63 kernel: decode_attr_pnfstype: bitmap is 0
    Dec  5 13:31:08 aury63 kernel: nfs4_schedule_state_renewal:
    requeueing work. Lease period = 80
    Dec  5 13:31:08 aury63 kernel: --> nfs_put_client({2})
    Dec  5 13:31:08 aury63 kernel: <-- nfs4_setup_sequence status=0
    Dec  5 13:31:08 aury63 kernel: NFS: nfs_update_inode(0:16/544895
    ct=1 info=0x27e67)
    Dec  5 13:31:08 aury63 kernel: NFS: change_attr change on server for
    file 0:16/544895
    Dec  5 13:31:08 aury63 kernel: NFS: mtime change on server for file
    0:16/544895
    Dec  5 13:31:08 aury63 kernel: NFS: nfs_fhget(0:16/544930 ct=1)
    Dec  5 13:31:08 aury63 kernel: NFS: open file(rep/lockfile2908)
    Dec  5 13:31:08 aury63 kernel: NFS: permission(0:16/544930),
    mask=0x26, res=0
    Dec  5 13:31:08 aury63 kernel: NFS: lock(rep/lockfile2908, t=1,
    fl=1, r=0:9223372036854775807)

I can see no reason why ENOLCK is returned. This is clearly a bug on the 
server handside (within nfs-ganesha) but I have to know what the client 
is doing here to have a clearer idea.
I ran the same test using NFSv4.1 and NFSv3+NLMv4, things go perfectly 
OK with no failure.

Can someone help me ?

    Regards

       Philippe


--------------050200060204020800000406
Content-Type: application/octet-stream;
 name="bug_lock_2.pcap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="bug_lock_2.pcap"

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
--------------050200060204020800000406
Content-Type: text/plain;
 name="log_kernel_bug_lock2.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="log_kernel_bug_lock2.txt"

Dec  5 13:31:08 aury63 kernel: encode_compound: tag=
Dec  5 13:31:08 aury63 kernel: decode_attr_type: type=040000
Dec  5 13:31:08 aury63 kernel: decode_attr_change: change attribute=1323082676
Dec  5 13:31:08 aury63 kernel: decode_attr_size: file size=856064
Dec  5 13:31:08 aury63 kernel: decode_attr_fsid: fsid=(0xc0/0xa8)
Dec  5 13:31:08 aury63 kernel: decode_attr_fileid: fileid=523265
Dec  5 13:31:08 aury63 kernel: decode_attr_fs_locations: fs_locations done, error = 0
Dec  5 13:31:08 aury63 kernel: decode_attr_mode: file mode=01777
Dec  5 13:31:08 aury63 kernel: decode_attr_nlink: nlink=14
Dec  5 13:31:08 aury63 kernel: decode_attr_owner: uid=0
Dec  5 13:31:08 aury63 kernel: decode_attr_group: gid=0
Dec  5 13:31:08 aury63 kernel: decode_attr_rdev: rdev=(0x0:0x0)
Dec  5 13:31:08 aury63 kernel: decode_attr_space_used: space used=860160
Dec  5 13:31:08 aury63 kernel: decode_attr_time_access: atime=1323081627
Dec  5 13:31:08 aury63 kernel: decode_attr_time_metadata: ctime=1323082676
Dec  5 13:31:08 aury63 kernel: decode_attr_time_modify: mtime=1323082676
Dec  5 13:31:08 aury63 kernel: decode_attr_mounted_on_fileid: fileid=0
Dec  5 13:31:08 aury63 kernel: decode_getfattr: xdr returned 0
Dec  5 13:31:08 aury63 kernel: NFS: nfs_update_inode(0:16/523265 ct=2 info=0x27e7f)
Dec  5 13:31:08 aury63 kernel: NFS: permission(0:16/523265), mask=0x1, res=0
Dec  5 13:31:08 aury63 kernel: NFS: nfs_lookup_revalidate(/rep) is valid
Dec  5 13:31:08 aury63 kernel: encode_compound: tag=
Dec  5 13:31:08 aury63 kernel: decode_attr_type: type=040000
Dec  5 13:31:08 aury63 kernel: decode_attr_change: change attribute=1323088137
Dec  5 13:31:08 aury63 kernel: decode_attr_size: file size=4096
Dec  5 13:31:08 aury63 kernel: decode_attr_fsid: fsid=(0xc0/0xa8)
Dec  5 13:31:08 aury63 kernel: decode_attr_fileid: fileid=544895
Dec  5 13:31:08 aury63 kernel: decode_attr_fs_locations: fs_locations done, error = 0
Dec  5 13:31:08 aury63 kernel: decode_attr_mode: file mode=0755
Dec  5 13:31:08 aury63 kernel: decode_attr_nlink: nlink=2
Dec  5 13:31:08 aury63 kernel: decode_attr_owner: uid=0
Dec  5 13:31:08 aury63 kernel: decode_attr_group: gid=0
Dec  5 13:31:08 aury63 kernel: decode_attr_rdev: rdev=(0x0:0x0)
Dec  5 13:31:08 aury63 kernel: decode_attr_space_used: space used=4096
Dec  5 13:31:08 aury63 kernel: decode_attr_time_access: atime=1323071853
Dec  5 13:31:08 aury63 kernel: decode_attr_time_metadata: ctime=1323088137
Dec  5 13:31:08 aury63 kernel: decode_attr_time_modify: mtime=1323088137
Dec  5 13:31:08 aury63 kernel: decode_attr_mounted_on_fileid: fileid=0
Dec  5 13:31:08 aury63 kernel: decode_getfattr: xdr returned 0
Dec  5 13:31:08 aury63 kernel: NFS: nfs_update_inode(0:16/544895 ct=1 info=0x27e7f)
Dec  5 13:31:08 aury63 kernel: NFS: permission(0:16/544895), mask=0x1, res=0
Dec  5 13:31:08 aury63 kernel: NFS: permission(0:16/544895), mask=0x1, res=0
Dec  5 13:31:08 aury63 kernel: NFS: atomic_lookup(0:16/544895), lockfile2908
Dec  5 13:31:08 aury63 kernel: encode_compound: tag=
Dec  5 13:31:08 aury63 kernel: encode_compound: tag=
Dec  5 13:31:08 aury63 kernel: decode_attr_lease_time: file size=120
Dec  5 13:31:08 aury63 kernel: decode_attr_maxfilesize: maxfilesize=0
Dec  5 13:31:08 aury63 kernel: decode_attr_maxread: maxread=1024
Dec  5 13:31:08 aury63 kernel: decode_attr_maxwrite: maxwrite=1024
Dec  5 13:31:08 aury63 kernel: decode_attr_pnfstype: bitmap is 0
Dec  5 13:31:08 aury63 kernel: decode_attr_layout_blksize: bitmap is 0
Dec  5 13:31:08 aury63 kernel: decode_fsinfo: xdr returned 0!
Dec  5 13:31:08 aury63 kernel: nfs4_schedule_state_renewal: requeueing work. Lease period = 80
Dec  5 13:31:08 aury63 kernel: --> nfs_put_client({2})
Dec  5 13:31:08 aury63 kernel: <-- nfs4_setup_sequence status=0
Dec  5 13:31:08 aury63 kernel: encode_compound: tag=
Dec  5 13:31:08 aury63 kernel: decode_attr_type: type=0100000
Dec  5 13:31:08 aury63 kernel: decode_attr_change: change attribute=1323088268
Dec  5 13:31:08 aury63 kernel: decode_attr_size: file size=0
Dec  5 13:31:08 aury63 kernel: decode_attr_fsid: fsid=(0xc0/0xa8)
Dec  5 13:31:08 aury63 kernel: decode_attr_fileid: fileid=544930
Dec  5 13:31:08 aury63 kernel: decode_attr_fs_locations: fs_locations done, error = 0
Dec  5 13:31:08 aury63 kernel: decode_attr_mode: file mode=0644
Dec  5 13:31:08 aury63 kernel: decode_attr_nlink: nlink=1
Dec  5 13:31:08 aury63 kernel: decode_attr_owner: uid=-2
Dec  5 13:31:08 aury63 kernel: decode_attr_group: gid=-2
Dec  5 13:31:08 aury63 kernel: decode_attr_rdev: rdev=(0x0:0x0)
Dec  5 13:31:08 aury63 kernel: decode_attr_space_used: space used=0
Dec  5 13:31:08 aury63 kernel: decode_attr_time_access: atime=1323088268
Dec  5 13:31:08 aury63 kernel: decode_attr_time_metadata: ctime=1323088268
Dec  5 13:31:08 aury63 kernel: decode_attr_time_modify: mtime=1323088268
Dec  5 13:31:08 aury63 kernel: decode_attr_mounted_on_fileid: fileid=0
Dec  5 13:31:08 aury63 kernel: decode_getfattr: xdr returned 0
Dec  5 13:31:08 aury63 kernel: decode_attr_type: type=040000
Dec  5 13:31:08 aury63 kernel: decode_attr_change: change attribute=1323088137
Dec  5 13:31:08 aury63 kernel: decode_attr_size: file size=4096
Dec  5 13:31:08 aury63 kernel: decode_attr_fsid: fsid=(0xc0/0xa8)
Dec  5 13:31:08 aury63 kernel: decode_attr_fileid: fileid=544895
Dec  5 13:31:08 aury63 kernel: decode_attr_fs_locations: fs_locations done, error = 0
Dec  5 13:31:08 aury63 kernel: decode_attr_mode: file mode=0755
Dec  5 13:31:08 aury63 kernel: decode_attr_nlink: nlink=2
Dec  5 13:31:08 aury63 kernel: decode_attr_owner: uid=-2
Dec  5 13:31:08 aury63 kernel: decode_attr_group: gid=-2
Dec  5 13:31:08 aury63 kernel: decode_attr_rdev: rdev=(0x0:0x0)
Dec  5 13:31:08 aury63 kernel: decode_attr_space_used: space used=4096
Dec  5 13:31:08 aury63 kernel: decode_attr_time_access: atime=1323071853
Dec  5 13:31:08 aury63 kernel: decode_attr_time_metadata: ctime=1323088268
Dec  5 13:31:08 aury63 kernel: decode_attr_time_modify: mtime=1323088268
Dec  5 13:31:08 aury63 kernel: decode_attr_mounted_on_fileid: fileid=0
Dec  5 13:31:08 aury63 kernel: decode_getfattr: xdr returned 0
Dec  5 13:31:08 aury63 kernel: NFS: nfs_update_inode(0:16/544895 ct=1 info=0x27e67)
Dec  5 13:31:08 aury63 kernel: NFS: change_attr change on server for file 0:16/544895
Dec  5 13:31:08 aury63 kernel: NFS: mtime change on server for file 0:16/544895
Dec  5 13:31:08 aury63 kernel: encode_compound: tag=
Dec  5 13:31:08 aury63 kernel: NFS: nfs_fhget(0:16/544930 ct=1)
Dec  5 13:31:08 aury63 kernel: NFS: open file(rep/lockfile2908)
Dec  5 13:31:08 aury63 kernel: NFS: permission(0:16/544930), mask=0x26, res=0
Dec  5 13:31:08 aury63 kernel: NFS: lock(rep/lockfile2908, t=1, fl=1, r=0:9223372036854775807)

--------------050200060204020800000406--
