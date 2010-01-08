From: Bian Naimeng <biannm@cn.fujitsu.com>
Subject: Re: whether can NFS exports option 'nohide' work?
Date: Fri, 08 Jan 2010 17:49:42 +0800
Message-ID: <4B46FFB6.9010901@cn.fujitsu.com>
References: <4B45A234.8080503@cn.fujitsu.com> <20100108050259.GA4984@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=Shift_JIS
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51121 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751112Ab0AHJu4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jan 2010 04:50:56 -0500
In-Reply-To: <20100108050259.GA4984@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields =8E=CA=93=B9:
> On Thu, Jan 07, 2010 at 04:58:28PM +0800, Bian Naimeng wrote:
>> Hi,
>>
>> I want to use this option=81C but i find it doesn't work at RHEL5.4G=
A and Fedora12.
>>
>> My /etc/exports like this:
>> # cat /etc/exports
>>   /nfsroot/nfsv4	127.0.0.1(rw,nohide,fsid=3D0)
>>   /nfsroot/nfsv4/dir1	127.0.0.1(rw,nohide,crossmnt)
>>   /nfsroot/nfsv4/dir2	127.0.0.1(rw,nohide,crossmnt)
>>
>> Then:
>>
>> # mkdir /nfsroot/nfsv4/dir1/tmpdir
>> # echo "best wishes" > /nfsroot/nfsv4/dir1/file1
>> # echo "happy new year" > /nfsroot/nfsv4/dir2/file2
>>
>> # service nfs restart
>> # mount -t nfs4 127.0.0.1:/dir2 /nfsroot/nfsv4/dir1/tmpdir
>> # mount -t nfs4 127.0.0.1:/dir1 /mnt
>>
>> There is file2 at /nfsroot/nfsv4/dir1/tmpdir, but nothing at /mnt/tm=
pdir.
>> I'm not sure i have used it correctly, and whether it really work?=20
>> Thanks for your help.
>=20
> You can't re-export nfs filesystems.
>=20
> (I wonder why we aren't warning about this?)
>=20

  Though i does not mount nfs filesystem, instead by ext3 filesystem /d=
ev/hda,
  there is not anyting at /mnt/tmpdir.

  # mount /dev/hda3 /nfsroot/nfsv4/dir1/tmpdir
  # mount -t nfs4 127.0.0.1:/dir1  /mnt

  # ll /mnt/tmpdir/
    total 0

  Then, i test it at two different RHEL5.4 host.

  host1=81infs server=81j:
  # cat /etc/exports
    /nfsroot/nfsv4		host2(rw,nohide,crossmnt,fsid=3D0)
    /nfsroot/nfsv4/dir1		host2(rw,nohide,crossmnt)

  # mount /dev/hda3 /nfsroot/nfsv4/dir1/tmpdir

  host2 (nfs client):
  # mount -t nfs4 host1:/dir1 /mnt
  # ll /mnt/
    ls: /nfsv4/tmpdir: Stale NFS file handle
    total 4
    -rw-r--r-- 1 root root    0 Jan  5  2010 file1
    drwxr-xr-x 6 root root 4096 Jan  6  2010 tmpdir

  # ll /nfsv4/tmpdir
    ls: /nfsv4/tmpdir: Stale NFS file handle
    ls: /nfsv4/tmpdir: Stale NFS file handle

 Best Regards
  Bian

