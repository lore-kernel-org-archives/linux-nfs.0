From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Device or resource busy
Date: Mon, 27 Oct 2008 11:01:52 -0400
Message-ID: <1225119712.14242.10.camel@heimdal.trondhjem.org>
References: <20081027131034.GC25001@speutel.de>
	 <1225116112.7842.3.camel@heimdal.trondhjem.org>
	 <20081027142944.GD25001@speutel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Stephan =?ISO-8859-1?Q?Windm=FCller?=
	<stephan.windmueller-ogaGWlaKng3jEoi5djuKH7NAH6kLmebB@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:55819 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbYJ0PB4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Oct 2008 11:01:56 -0400
In-Reply-To: <20081027142944.GD25001-YXCdMCmAy7qELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-10-27 at 15:29 +0100, Stephan Windm=C3=BCller wrote:
> On Mon, 27. Oct 2008, Trond Myklebust wrote:
>=20
> > > When I look with "nfsstat -m", I can see a lot of mount points fo=
r each
> > > user, including the directory which cannot be deleted. One user h=
ad a
> > > total of 200 mounts!
> > If /export/username is on a different volume from /export on the se=
rver,
> > then the NFS client has to mount it as being a different volume on =
the
> > client. 'cat /proc/fs/nfsfs/volumes' should be able to tell you if =
your
> > server is exporting more than one volume.
>=20
> /export and /export/home/username are different volumes, but I only
> share /export/home/username. Also it is not only the homedirectory
> itself but many subdirectories which cause this error. A sample outpu=
t
> from 'nfsstat -m':
>=20
> -----
>=20
> /home/username from fileserver:/export/home/username
>  Flags: rw,vers=3D3,rsize=3D1048576,wsize=3D1048576,hard,intr,proto=3D=
tcp,timeo=3D600,retrans=3D2,sec=3Dsys,addr=3Dfileserver
>=20
> /home/username/workspace/ls5/da/text/Konzept from
> fileserver:/export/home/username/workspace/ls5/da/text/Konzept
>  Flags: rw,vers=3D3,rsize=3D1048576,wsize=3D1048576,hard,intr,proto=3D=
tcp,timeo=3D600,retrans=3D2,sec=3Dsys,addr=3Dfileserver
>=20
> /home/username/.eclipse/org.eclipse.platform_3.3.0_1148896627 from
> fileserver:/export/home/username/.eclipse/org.eclipse.platform_3.3.0_=
1148896627
>  Flags: rw,vers=3D3,rsize=3D1048576,wsize=3D1048576,hard,intr,proto=3D=
tcp,timeo=3D600,retrans=3D2,sec=3Dsys,addr=3Dfileserver
>=20
> [...]
>=20
> -----
>=20
> The output from /proc/fs/nfsfs/volumes looks like:
>=20
> NV SERVER   PORT DEV     FSID
> v3 81d91add  801 0:29    1000001009f:0
> v3 81d91add  801 0:27    1000001010f:0
> v3 81d91ade  801 0:30    100000100f1:0
> v3 81d91add  801 0:31    1000001018b:0
> v3 81d91add  801 0:26    10000010189:0
> v3 81d91ade  801 0:28    100000100ef:0
> v3 81d91ade  801 0:32    100000100f6:0
> v3 81d91add  801 0:33    10000010192:0

Which shows you have at least 5 different volumes mounted from server
129.217.26.221, and 3 different volumes mounted from server
129.217.26.222.
As I said earlier, every time you cross from one volume to another (eve=
n
if it is on the same server), a mountpoint is automatically created.
Otherwise, you would have issues with two different files possibly
sharing the same inode number on the same NFS filesystem.

Cheers
  Trond

