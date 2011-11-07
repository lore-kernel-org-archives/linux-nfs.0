Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:57855 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab1KGU3d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Nov 2011 15:29:33 -0500
Received: by faan17 with SMTP id n17so399259faa.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 Nov 2011 12:29:32 -0800 (PST)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
Date: Mon, 7 Nov 2011 21:29:31 +0100
Message-ID: <CAGue13qcDxW9wFfuVuRnbZBcxuTWaXzW8CK1VFWj9483ardp0g@mail.gmail.com>
Subject: regression in referrals resolution
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,


today we was running test with referrals and notice that 'current'
3.1+ has a regression.
The referrals are resolved, but client returns IO error :


  [957401.805315] encode_sequence:
sessionid=638433358:33554432:0:16777216 seqid=17 slotid=0 max_slotid=0
cache_this=0
[957401.807810] decode_attr_type: type=00
[957401.807812] decode_attr_change: change attribute=0
[957401.807814] decode_attr_size: file size=0
[957401.807816] decode_attr_fsid: fsid=(0x100/0x11)
[957401.807818] decode_attr_fileid: fileid=0
[957401.807820] decode_attr_fs_locations: fsroot path /pnfs/p3
[957401.807824] decode_attr_fs_locations: servers 131.169.80.47 path
/pnfs/desy.de/petra3
[957401.807828] decode_attr_fs_locations: fs_locations done, error = 524288
[957401.807830] decode_attr_mode: file mode=00
[957401.807832] decode_attr_nlink: nlink=1
[957401.807834] decode_attr_owner: uid=-2
[957401.807835] decode_attr_group: gid=-2
[957401.807837] decode_attr_rdev: rdev=(0x0:0x0)
[957401.807839] decode_attr_space_used: space used=0
[957401.807841] decode_attr_time_access: atime=0
[957401.807842] decode_attr_time_metadata: ctime=0
[957401.807844] decode_attr_time_modify: mtime=0
[957401.807846] decode_attr_mounted_on_fileid: fileid=0
[957401.807848] decode_getfattr_attrs: xdr returned -2097152
[957401.807850] decode_getfattr_generic: xdr returned 0
[957401.807852] nfs41_sequence_done: Error 0 free the slot
[957401.807854] nfs4_free_slot: free_slotid 0 highest_used_slotid -1
[957401.807859] nfs4_proc_fs_locations: returned status = 0
[957401.807862] nfs4_map_errors could not handle NFSv4 error 10019


this is with

7670c7010c7b367ca40c3aba02afb36149764a6e

from git://linux-nfs.org/~trondmy/nfs-2.6.git  bugfixes

The same server and same configuration with kernel from fedora16 works
out-of-box.

Regards,
   Tigran.
