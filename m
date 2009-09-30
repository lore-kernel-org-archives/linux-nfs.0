From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Subject: Re: NFS problem with past 2.6.31 git tree
Date: Wed, 30 Sep 2009 08:55:44 +0200
Message-ID: <c4e36d110909292355i1b5801b6r9b1ea823a9f1c9b7@mail.gmail.com>
References: <c4e36d110909250812g74e049b7u39566d189970d77e@mail.gmail.com>
	 <1253892426.31072.37.camel@heimdal.trondhjem.org>
	 <c4e36d110909251246s6af618e8n663afe2b66c4cd5d@mail.gmail.com>
	 <1254160202.7124.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753385AbZI3Gzp@vger.kernel.org>
In-Reply-To: <1254160202.7124.2.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2009/9/28 Trond Myklebust <Trond.Myklebust@netapp.com>:
> On Fri, 2009-09-25 at 21:46 +0200, Zdenek Kabelac wrote:
>> 2009/9/25 Trond Myklebust <Trond.Myklebust@netapp.com>:
>> > On Fri, 2009-09-25 at 17:12 +0200, Zdenek Kabelac wrote:
>> >> Hi
>> >>
>> >> I've noticed that my qemu guest is now unable to use localy expor=
ted
>> >> nfs directory.
>> >> Directory gets mounted, plain 'ls' shows filenames - but nothing =
else
>> >> could be done.
>> >>
>> >> ls -la gives this output:
>> >> ls: cannot access patch: Input/output error
>> >> ...
>> >>
>> >>
>> >> Both host & guest are running same kernel:
>> >> 851b147e4411df6a1e7e90e2a609773c277eefd2
>> >>
>> >> I've checked last few commits and tried to revert them -
>> >> and this one seems to cure my problem when reverted:
>> >>
>> >> Sep 23: =A08a6e5deb8a8caa810fef2c525f5dbea2cfe04a47
>> >> NFS: Get rid of the NFS_MOUNT_VER3 and NFS_MOUNT_TCP flags
>> >>
>> >> I should also probably note that I'm seeing this message in my dm=
esg log:
>> >> svc: failed to register lockdv1 RPC service (errno 97)
>> >>
>> >> rpcinfo -p
>> >> =A0 =A0program vers proto =A0 port
>> >> =A0 =A0 100000 =A0 =A02 =A0 tcp =A0 =A0111 =A0portmapper
>> >> =A0 =A0 100000 =A0 =A02 =A0 udp =A0 =A0111 =A0portmapper
>> >> =A0 =A0 100024 =A0 =A01 =A0 udp =A053550 =A0status
>> >> =A0 =A0 100024 =A0 =A01 =A0 tcp =A044174 =A0status
>> >> =A0 =A0 100021 =A0 =A01 =A0 udp =A049878 =A0nlockmgr
>> >> =A0 =A0 100021 =A0 =A03 =A0 udp =A049878 =A0nlockmgr
>> >> =A0 =A0 100021 =A0 =A04 =A0 udp =A049878 =A0nlockmgr
>> >> =A0 =A0 100021 =A0 =A01 =A0 tcp =A047319 =A0nlockmgr
>> >> =A0 =A0 100021 =A0 =A03 =A0 tcp =A047319 =A0nlockmgr
>> >> =A0 =A0 100021 =A0 =A04 =A0 tcp =A047319 =A0nlockmgr
>> >>
>> >> automount(pid1720) /misc autofs
>> >> rw,relatime,fd=3D4,pgrp=3D1720,timeout=3D300,minproto=3D2,maxprot=
o=3D4,indirect
>> >> 0 0
>> >> 192.168.122.1:/home/u/export /misc/u nfs
>> >> rw,relatime,vers=3D3,rsize=3D524288,wsize=3D524288,namlen=3D255,s=
oft,proto=3Dtcp,port=3D65535,timeo=3D600,retrans=3D2,sec=3Dsys,mountadd=
r=3D192.168.xxx.yyy,mountvers=3D3,mountproto=3Dtcp,addr=3D192.168.xxx.y=
yy
>> >> 0 0
>> >>
>> >>
>> >> Zdenek
>> > What does
>> >
>> > =A0 cat /proc/self/mountinfo
>> >
>> > give you?
>> >
>>
>>
>> Working version: (kernel 2.6.31 or current git with reverted NFS pat=
ch)
>>
>> 22 12 0:17 / /misc rw,relatime - autofs automount(pid1720)
>> rw,fd=3D4,pgrp=3D1720,timeout=3D300,minproto=3D2,maxproto=3D4,indire=
ct
>>
>> 24 22 0:19 / /misc/kabi rw,relatime - nfs IP:/home/kabi/export
>> rw,vers=3D3,rsize=3D524288,wsize=3D524288,namlen=3D255,soft,proto=3D=
tcp,port=3D65535,timeo=3D600,retrans=3D2,sec=3Dsys,mountaddr=3DIP,mount=
vers=3D3,mountproto=3Dtcp,addr=3DIP
>>
>>
>> Nonworking version:
>>
>> 22 12 0:17 / /misc rw,relatime - autofs automount(pid1704)
>> rw,fd=3D4,pgrp=3D1704,timeout=3D300,minproto=3D2,maxproto=3D4,indire=
ct
>>
>> 24 22 0:19 / /misc/kabi rw,relatime - nfs IP:/home/kabi/export
>> rw,vers=3D2,rsize=3D8192,wsize=3D8192,namlen=3D255,soft,proto=3Dtcp,=
port=3D65535,timeo=3D600,retrans=3D2,sec=3Dsys,mountaddr=3DIP,mountvers=
=3D3,mountproto=3Dtcp,addr=3DIP
>>
>>
>>
>> Looks like vers=3D2 =A0!=3D vers=3D3 =A0 and rsize/wsize - which is =
also set by
>> the kernel itself to those lower values.
>> (i.e. my /etc/init.d/autofs doesn't modify localoptions - of course =
I
>> could use this to set 8192 wsize and rsize for my working kernel)
>>
>> Zdenek
>
>
> OK. The following patch fixes the default nfs version issue for me. I
> have another one to fix the incorrectly displayed port numbers...

Hi

Thanks - this patch seems to fix my reported problem.



>
> Cheers
> =A0Trond
> ---------------------------------------------------------------------=
---
> NFS: Fix a default mount regression...
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
>
> With the recent spate of changes, the nfs protocol version will now d=
efault
> to 2 instead of 3, while the mount protocol version defaults to 3.
>
> The following patch should ensure the defaults are consistent with th=
e
> previous defaults of vers=3D3,proto=3Dtcp,mountvers=3D3,mountproto=3D=
tcp.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---


Reported-and-tested-by: Zdenek Kabelac <zdenek.kabelac@gmail.com>


>
> =A0fs/nfs/super.c | =A0 13 ++++++-------
> =A01 files changed, 6 insertions(+), 7 deletions(-)
>
>
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 29786d3..0343ebc 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -728,22 +728,24 @@ static void nfs_umount_begin(struct super_block=
 *sb)
> =A0 =A0 =A0 =A0unlock_kernel();
> =A0}
>
> -static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(int=
 flags)
> +static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(uns=
igned int version)
> =A0{
> =A0 =A0 =A0 =A0struct nfs_parsed_mount_data *data;
>
> =A0 =A0 =A0 =A0data =3D kzalloc(sizeof(*data), GFP_KERNEL);
> =A0 =A0 =A0 =A0if (data) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->flags =A0 =A0 =A0 =A0 =A0 =A0 =3D=
 flags;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->rsize =A0 =A0 =A0 =A0 =A0 =A0 =3D=
 NFS_MAX_FILE_IO_SIZE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->wsize =A0 =A0 =A0 =A0 =A0 =A0 =3D=
 NFS_MAX_FILE_IO_SIZE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->acregmin =A0 =A0 =A0 =A0 =A0=3D =
NFS_DEF_ACREGMIN;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->acregmax =A0 =A0 =A0 =A0 =A0=3D =
NFS_DEF_ACREGMAX;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->acdirmin =A0 =A0 =A0 =A0 =A0=3D =
NFS_DEF_ACDIRMIN;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->acdirmax =A0 =A0 =A0 =A0 =A0=3D =
NFS_DEF_ACDIRMAX;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->mount_server.port =3D NFS_UNSPEC_=
PORT;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->nfs_server.port =A0 =3D NFS_UNSP=
EC_PORT;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->nfs_server.protocol =3D XPRT_TRAN=
SPORT_TCP;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->auth_flavors[0] =A0 =3D RPC_AUTH=
_UNIX;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->auth_flavor_len =A0 =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 data->version =A0 =A0 =A0 =A0 =A0 =3D v=
ersion;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0data->minorversion =A0 =A0 =A0=3D 0;
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return data;
> @@ -1711,8 +1713,6 @@ static int nfs_validate_mount_data(void *option=
s,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!(data->flags & NFS_MOUNT_TCP))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0args->nfs_server.proto=
col =3D XPRT_TRANSPORT_UDP;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 args->nfs_server.protoc=
ol =3D XPRT_TRANSPORT_TCP;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* N.B. caller will free nfs_server.ho=
stname in all cases */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0args->nfs_server.hostname =3D kstrdup(=
data->hostname, GFP_KERNEL);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0args->namlen =A0 =A0 =A0 =A0 =A0 =A0=3D=
 data->namlen;
> @@ -2106,7 +2106,7 @@ static int nfs_get_sb(struct file_system_type *=
fs_type,
> =A0 =A0 =A0 =A0};
> =A0 =A0 =A0 =A0int error =3D -ENOMEM;
>
> - =A0 =A0 =A0 data =3D nfs_alloc_parsed_mount_data(NFS_MOUNT_VER3 | N=
=46S_MOUNT_TCP);
> + =A0 =A0 =A0 data =3D nfs_alloc_parsed_mount_data(3);
> =A0 =A0 =A0 =A0mntfh =3D kzalloc(sizeof(*mntfh), GFP_KERNEL);
> =A0 =A0 =A0 =A0if (data =3D=3D NULL || mntfh =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_fh;
> @@ -2376,7 +2376,6 @@ static int nfs4_validate_mount_data(void *optio=
ns,
> =A0 =A0 =A0 =A0if (data =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_no_data;
>
> - =A0 =A0 =A0 args->version =A0 =A0 =A0 =A0 =A0 =3D 4;
> =A0 =A0 =A0 =A0switch (data->version) {
> =A0 =A0 =A0 =A0case 1:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (data->host_addrlen > sizeof(args->=
nfs_server.address))
> @@ -2660,7 +2659,7 @@ static int nfs4_get_sb(struct file_system_type =
*fs_type,
> =A0 =A0 =A0 =A0struct nfs_parsed_mount_data *data;
> =A0 =A0 =A0 =A0int error =3D -ENOMEM;
>
> - =A0 =A0 =A0 data =3D nfs_alloc_parsed_mount_data(0);
> + =A0 =A0 =A0 data =3D nfs_alloc_parsed_mount_data(4);
> =A0 =A0 =A0 =A0if (data =3D=3D NULL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_free_data;
>
>
>
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
