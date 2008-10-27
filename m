From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Device or resource busy
Date: Mon, 27 Oct 2008 10:01:52 -0400
Message-ID: <1225116112.7842.3.camel@heimdal.trondhjem.org>
References: <20081027131034.GC25001@speutel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Stephan =?ISO-8859-1?Q?Windm=FCller?=
	<stephan.windmueller-ogaGWlaKng3jEoi5djuKH7NAH6kLmebB@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:49039 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbYJ0OB5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Oct 2008 10:01:57 -0400
In-Reply-To: <20081027131034.GC25001-YXCdMCmAy7qELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2008-10-27 at 14:10 +0100, Stephan Windm=C3=BCller wrote:
> Hello!
>=20
> On our Ubuntu (8.04) machine we mount home directories from a Solaris
> server with NFS and autofs. From time to time users complain that the=
y
> are unable to delete any directories. The error message is "Device or
> resource busy".
>=20
> When I look with "nfsstat -m", I can see a lot of mount points for ea=
ch
> user, including the directory which cannot be deleted. One user had a
> total of 200 mounts!
>=20
> My question is: Why does NFS mount each directory seperately?
>=20
> Here is an example output for a user:
>=20
> /ldaphome/username from host:/export/username
>  Flags: rw,vers=3D3,rsize=3D1048576,wsize=3D1048576,hard,intr,
>  proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,addr=3Dhost
>=20
> TIA
>  Stephan

If /export/username is on a different volume from /export on the server=
,
then the NFS client has to mount it as being a different volume on the
client. 'cat /proc/fs/nfsfs/volumes' should be able to tell you if your
server is exporting more than one volume.

Cheers
  Trond

