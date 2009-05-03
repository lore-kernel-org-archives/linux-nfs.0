From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: very slow NFS boot on linux-next and -mm
Date: Sun, 3 May 2009 14:56:06 +0200
Message-ID: <ac3eb2510905030556p4ce25ff1w9aa5cbf76be2e206@mail.gmail.com>
References: <20090503105456.GA30449@localhost> <20090503124013.GA31700@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-hotplug@vger.kernel.org
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20090503124013.GA31700@localhost>
Sender: linux-hotplug-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 3, 2009 at 14:40, Wu Fengguang <fengguang.wu@intel.com> wro=
te:

> The udevd is doing this busy loop like mad:
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0open("/etc/group", O_RDONLY|O_CLOEXEC) =C2=
=A0=3D 7
> =C2=A0 =C2=A0 =C2=A0 =C2=A0lseek(7, 0, SEEK_CUR) =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0fstat(7, {st_mode=3DS_IFREG|0644, st_size=3D=
797, ...}) =3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mmap(NULL, 797, PROT_READ, MAP_SHARED, 7, =
0) =3D 0x7f6791601000
> =C2=A0 =C2=A0 =C2=A0 =C2=A0lseek(7, 797, SEEK_SET) =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D 797
> =C2=A0 =C2=A0 =C2=A0 =C2=A0munmap(0x7f6791601000, 797) =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =3D 0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0close(7) =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0=3D 0
>
> udev version is 0.141-1.

Are you sure that's "busy loop" in that sense, and not just "load"?

If your config carries OWNER=3D or GROUP=3D rules in the udev rules, bu=
t
your system does not have these users or groups configured, glibc will
try to resolve these names to the uid/gid with every event that needs
these values.

If the in rules configured user/group names can be resolved at startup
of udevd, they will be cached and never looked up again.

Are you sure, that your system is configured correctly regarding the
used rules and referenced system users/groups names?

Thanks,
Kay
--
To unsubscribe from this list: send the line "unsubscribe linux-hotplug=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
