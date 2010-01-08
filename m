From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: whether can NFS exports option 'nohide' work?
Date: Fri, 8 Jan 2010 00:02:59 -0500
Message-ID: <20100108050259.GA4984@fieldses.org>
References: <4B45A234.8080503@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Bian Naimeng <biannm@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51507 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750746Ab0AHFCH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jan 2010 00:02:07 -0500
In-Reply-To: <4B45A234.8080503@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 07, 2010 at 04:58:28PM +0800, Bian Naimeng wrote:
> Hi,
>=20
> I want to use this option=EF=BC=8C but i find it doesn't work at RHEL=
5.4GA and Fedora12.
>=20
> My /etc/exports like this:
> # cat /etc/exports
>   /nfsroot/nfsv4	127.0.0.1(rw,nohide,fsid=3D0)
>   /nfsroot/nfsv4/dir1	127.0.0.1(rw,nohide,crossmnt)
>   /nfsroot/nfsv4/dir2	127.0.0.1(rw,nohide,crossmnt)
>=20
> Then:
>=20
> # mkdir /nfsroot/nfsv4/dir1/tmpdir
> # echo "best wishes" > /nfsroot/nfsv4/dir1/file1
> # echo "happy new year" > /nfsroot/nfsv4/dir2/file2
>=20
> # service nfs restart
> # mount -t nfs4 127.0.0.1:/dir2 /nfsroot/nfsv4/dir1/tmpdir
> # mount -t nfs4 127.0.0.1:/dir1 /mnt
>=20
> There is file2 at /nfsroot/nfsv4/dir1/tmpdir, but nothing at /mnt/tmp=
dir.
> I'm not sure i have used it correctly, and whether it really work?=20
> Thanks for your help.

You can't re-export nfs filesystems.

(I wonder why we aren't warning about this?)

--b.
