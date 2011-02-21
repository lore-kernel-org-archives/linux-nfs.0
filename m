Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:51238 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754413Ab1BUJJl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2011 04:09:41 -0500
Received: by iwn8 with SMTP id 8so1673439iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Feb 2011 01:09:40 -0800 (PST)
In-Reply-To: <AANLkTikGAHBEKxeQqVegtW3VmZcJScMPkzGOyWfvD9h7@mail.gmail.com>
References: <AANLkTikGAHBEKxeQqVegtW3VmZcJScMPkzGOyWfvD9h7@mail.gmail.com>
Date: Mon, 21 Feb 2011 11:09:40 +0200
Message-ID: <AANLkTinZ61OZObYMeuisJ-H2+o3PgFM1K+kExyUMaTNL@mail.gmail.com>
Subject: Re: 2.6.32, NFSv4, "Stale NFS file handle" problem
From: Nick Patavalis <npat@efault.net>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

On Mon, Feb 21, 2011 at 2:54 AM, Nick Patavalis <npat@efault.net> wrote:
>
> I don't know if this is an NFS bug, but seems a lot like it... My
> server-host exports a few NTFS filesystems (read-only exports) using
> NFSv4. Two client-hosts mount these file-systems.
>
> Client A runs 2.6.31, and client B 2.6.32. Client A works fine. Client
> B, while it initially mounts everything ok, and for some time
> everything works ok (or so it seems), after a while it starts
> returning "Stale NFS file hande" errors for random files and
> directories. Client A NEVER returns stale errors, EVEN after a server
> reboot.
>

Some additional information.

After the problem appears (i.e. after "client B" starts returning
"stale file handle" errors), an "ls" on a file (directory) for
which the file-handle is stale, with "sunrpc.nfs_debug = 1023"
shows:

  # ls /mnt/thepat/mydvds5-6/MyDVDs5
  ls: cannot access /mnt/thepat/mydvds5-6/MyDVDs5: Stale NFS file
  handle
  # ls /mnt/thepat/mydvds5-6/MyDVDs5
  ls: cannot access /mnt/thepat/mydvds5-6/MyDVDs5: Stale NFS file
  handle

While in syslog:

  Feb 21 10:59:19 azure kernel: [197436.952297] encode_compound: tag=
  Feb 21 10:59:19 azure kernel: [197436.957441] decode_attr_type: type=040000
  Feb 21 10:59:19 azure kernel: [197436.957448] decode_attr_change:
change attribute=381218604654685448
  Feb 21 10:59:19 azure kernel: [197436.957454] decode_attr_size: file size=4096
  Feb 21 10:59:19 azure kernel: [197436.957460] decode_attr_fsid: fsid=(0x4/0x0)
  Feb 21 10:59:19 azure kernel: [197436.957465] decode_attr_fileid: fileid=5
  Feb 21 10:59:19 azure kernel: [197436.957471]
decode_attr_fs_locations: fs_locations done, error = 0
  Feb 21 10:59:19 azure kernel: [197436.957477] decode_attr_mode: file mode=0777
  Feb 21 10:59:19 azure kernel: [197436.957481] decode_attr_nlink: nlink=1
  Feb 21 10:59:19 azure kernel: [197436.957489] decode_attr_owner:
nfs_map_name_to_uid failed!
  Feb 21 10:59:19 azure kernel: [197436.957494] decode_attr_owner: uid=-2
  Feb 21 10:59:19 azure kernel: [197436.957501] decode_attr_group:
nfs_map_group_to_gid failed!
  Feb 21 10:59:19 azure kernel: [197436.957506] decode_attr_group: gid=-2
  Feb 21 10:59:19 azure kernel: [197436.957511] decode_attr_rdev: rdev=(0x0:0x0)
  Feb 21 10:59:19 azure kernel: [197436.957516]
decode_attr_space_used: space used=4096
  Feb 21 10:59:19 azure kernel: [197436.957522]
decode_attr_time_access: atime=1297893893
  Feb 21 10:59:19 azure kernel: [197436.957527]
decode_attr_time_metadata: ctime=1297893893
  Feb 21 10:59:19 azure kernel: [197436.957533]
decode_attr_time_modify: mtime=1297893893
  Feb 21 10:59:19 azure kernel: [197436.957538]
decode_attr_mounted_on_fileid: fileid=0
  Feb 21 10:59:19 azure kernel: [197436.957543] decode_getfattr: xdr returned 0
  Feb 21 10:59:19 azure kernel: [197436.957557] NFS:
nfs_update_inode(0:1e/5 ct=3 info=0x27e67)
  Feb 21 10:59:19 azure kernel: [197436.957567] NFS:
permission(0:1e/5), mask=0x1, res=0
  Feb 21 10:59:19 azure kernel: [197436.957578] NFS:
nfs_lookup_revalidate(/MyDVDs5) is valid
  Feb 21 10:59:19 azure kernel: [197436.957586] NFS: revalidating (0:1e/33)
  Feb 21 10:59:19 azure kernel: [197436.957596] encode_compound: tag=
  Feb 21 10:59:19 azure kernel: [197436.963413] nfs_revalidate_inode:
(0:1e/33) getattr failed, error=-116
  Feb 21 10:59:19 azure kernel: [197436.963422] NFS: dentry_delete(/MyDVDs5, 88)
  Feb 21 10:59:28 azure kernel: [197446.008528] NFS:
permission(0:1e/5), mask=0x1, res=0
  Feb 21 10:59:28 azure kernel: [197446.008540] NFS:
nfs_lookup_revalidate(/MyDVDs5) is valid
  Feb 21 10:59:28 azure kernel: [197446.008547] NFS: revalidating (0:1e/33)
  Feb 21 10:59:28 azure kernel: [197446.008568] encode_compound: tag=
  Feb 21 10:59:28 azure kernel: [197446.015965] nfs_revalidate_inode:
(0:1e/33) getattr failed, error=-116
  Feb 21 10:59:28 azure kernel: [197446.015974] NFS: dentry_delete(/MyDVDs5, 88)
