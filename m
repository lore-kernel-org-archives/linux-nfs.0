From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: whether can NFS exports option 'nohide' work?
Date: Thu, 07 Jan 2010 16:58:28 +0800
Message-ID: <4B45A234.8080503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52172 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752518Ab0AGI7k convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jan 2010 03:59:40 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I want to use this option=81C but i find it doesn't work at RHEL5.4GA a=
nd Fedora12.

My /etc/exports like this:
# cat /etc/exports
  /nfsroot/nfsv4	127.0.0.1(rw,nohide,fsid=3D0)
  /nfsroot/nfsv4/dir1	127.0.0.1(rw,nohide,crossmnt)
  /nfsroot/nfsv4/dir2	127.0.0.1(rw,nohide,crossmnt)

Then:

# mkdir /nfsroot/nfsv4/dir1/tmpdir
# echo "best wishes" > /nfsroot/nfsv4/dir1/file1
# echo "happy new year" > /nfsroot/nfsv4/dir2/file2

# service nfs restart
# mount -t nfs4 127.0.0.1:/dir2 /nfsroot/nfsv4/dir1/tmpdir
# mount -t nfs4 127.0.0.1:/dir1 /mnt

There is file2 at /nfsroot/nfsv4/dir1/tmpdir, but nothing at /mnt/tmpdi=
r.
I'm not sure i have used it correctly, and whether it really work?=20
Thanks for your help.

--=20
Best Regards
Bian

