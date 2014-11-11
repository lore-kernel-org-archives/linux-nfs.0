Return-Path: dros@primarydata.com
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Subject: Re: mount default minor version behavior
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
Date: Tue, 11 Nov 2014 10:01:01 -0500
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <CA0FEA36-5A18-41B6-8F7E-31376B67BA31@primarydata.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 11, 2014, at 9:39 AM, Benjamin Coddington <bcodding@redhat.com> =
wrote:
>=20
> I will update mount.nfs so the default version is 4.1.  I have two =
quick
> questions on desired behavior:
>=20
> o  Should mounts that do not specify a minor version be upgraded to =
the default minor version?
>=20
> For example, should 'mount -overs=3D4' turn into 'mount -overs4.1', if =
the
> current default is 4.1?

No. We don=E2=80=99t want to change the minor version of mounts in =
users=E2=80=99 fstabs. The lack of a minor
version in mount options has always meant minor version 0.

What you=E2=80=99re talking about is making the default (i.e. when no =
version is specified) to be v4.1,
right? I think we definitely want to auto retry in this case, i.e. try =
v4.1, then v4.0, then v3.

-dros

>=20
>=20
> o If 'yes' to the above, should mount auto-retry decrementing minor
> versions if EPROTONOSUPPORT?
>=20
> For example, 'mount -overs=3D4' with a default of 4.2 would attempt: =
4.2,
> then 4.1, then 4.0.
>=20
> Ben
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
