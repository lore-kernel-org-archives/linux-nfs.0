Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:56552 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751528AbeDGAPk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Apr 2018 20:15:40 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: NFS troubles
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <fa393c5e-a18c-2963-3aa8-f56ba35e8baf@nwra.com>
Date: Fri, 6 Apr 2018 20:15:35 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D16F3893-3A2C-46B0-A05A-52C8155C66AB@oracle.com>
References: <a6548640-bc0c-3bdd-7a0c-b1996978a26d@nwra.com>
 <A5B6EFB3-239C-420C-91F4-2B8D1BCBA85A@redhat.com>
 <efe6d26f-d1e9-bf16-e608-a2595e4fdbdf@nwra.com>
 <fa393c5e-a18c-2963-3aa8-f56ba35e8baf@nwra.com>
To: Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 6, 2018, at 12:07 PM, Orion Poplawski <orion@nwra.com> wrote:
>=20
> On 04/03/2018 09:44 AM, Orion Poplawski wrote:
>> Kernel is 3.10.0-693.21.1.el7.x86_64  I don't have Red Hat support =
for these
>> systems.
>>=20
>> I discovered that I'd been forcing vers=3D4.0 mounts in order to work =
around a
>> mounting issue. =20
>=20
> And I'm back to seeing the mount issue at boot.  Here's the situation =
- we're
> forcing kerberos on the public network, but allowing sec=3Dsys on some =
private
> networks:
>=20
> /etc/exports:
> /               -ro,async,fsid=3D0 192.168.1.0/24(sec=3Dsys)
> 192.168.2.0/24(sec=3Dsys) *.nwra.com(sec=3Dkrb5)
> /export/home    -rw,async,nohide 192.168.1.0/24(sec=3Dsys)
> 192.168.2.0/24(sec=3Dsys) *.nwra.com(sec=3Dkrb5)
>=20
> So for a while after boot, attempts to mount with sec=3Dsys fail:
>=20
> # mount -t nfs4 -s -o
> =
sec=3Dsys,intr,rsize=3D262144,wsize=3D262144,noatime,lookupcache=3Dpositiv=
e,actimeo=3D1
> earthib.cora.nwra.com:/export/home/greg /mnt
> mount.nfs4: Operation not permitted
>=20
> But then later they work:
>=20
> # mount -t nfs4 -s -o
> =
sec=3Dsys,intr,rsize=3D262144,wsize=3D262144,noatime,lookupcache=3Dpositiv=
e,actimeo=3D1
> earthib.cora.nwra.com:/export/home/greg /mnt
> # umount /mnt
>=20
> This can cycle back and forth.
>=20
> I've attached a packet capture of some failed mount attempts.  It =
seems that
> even with specifying sec=3Dsys, some kerberos stuff is going on.

> It appears to be related to mounting a different sec=3Dkrb5 mount over =
the
> public network from the same server.  While that mount is active, the =
sec=3Dsys
> mounts fail.  When it is unmounted, they work.  At least now I think I =
can
> work around this...

Bruce-

I examined the attached network capture. There are two attempts to do an
EXCHANGE_ID operation. Both times:

- a fresh GSS context is established successfully
- a fresh TCP connection is established by the client
- EXCHANGE_ID is sent using krb5i and the previously established GSS =
context
-- client owner verifier is 0x5ac794e81d0a1d81
-- client owner is "Linux NFSv4.1 qcomp1.cora.nwra.com"
-- state protection is SP4_MACH_CRED
- the server responds NFS4_OK; the CONFIRMED_R, PNFS_MDS, and =
MOVED_REFER flags are set
- the client destroys the GSS context
- the client closes the TCP connection


--
Chuck Lever



