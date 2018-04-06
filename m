Return-Path: <chuck.lever@oracle.com>
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: Re: NFS troubles
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <fa393c5e-a18c-2963-3aa8-f56ba35e8baf@nwra.com>
Date: Fri, 6 Apr 2018 12:24:21 -0400
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7A560163-BA54-4051-9BB4-12087952987D@oracle.com>
References: <a6548640-bc0c-3bdd-7a0c-b1996978a26d@nwra.com>
 <A5B6EFB3-239C-420C-91F4-2B8D1BCBA85A@redhat.com>
 <efe6d26f-d1e9-bf16-e608-a2595e4fdbdf@nwra.com>
 <fa393c5e-a18c-2963-3aa8-f56ba35e8baf@nwra.com>
To: Orion Poplawski <orion@nwra.com>
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
>=20
> It appears to be related to mounting a different sec=3Dkrb5 mount over =
the
> public network from the same server.  While that mount is active, the =
sec=3Dsys
> mounts fail.  When it is unmounted, they work.  At least now I think I =
can
> work around this...

For NFSv4, the client is going to use krb5i to do lease management even
on sec=3Dsys mounts. An NFSv4 server has to know for sure when it is =
talking
to the same client on different network interfaces or with different
security flavors. Thus the client has to use the same security flavor =
for
lease management on all of its mounts of that server. That's not =
controlled
by the sec=3D mount option.

I assume that "but then later" lasts only a few multiples of the =
server's
lease time (90 seconds by default)?

Clients that use only the private network interface should be able to =
use
sec=3Dsys. But clients that use both the public and private interfaces =
should
need to use sec=3Dkrb5 on both.


--
Chuck Lever
