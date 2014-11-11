Return-Path: chuck.lever@oracle.com
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <3987E905-52A4-4F8E-AF97-FCAC0503260F@oracle.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: mount default minor version behavior
Date: Tue, 11 Nov 2014 10:38:01 -0600
To: Benjamin Coddington <bcodding@redhat.com>
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 11, 2014, at 8:39 AM, Benjamin Coddington <bcodding@redhat.com> wro=
te:
>=20
> I will update mount.nfs so the default version is 4.1.

Hi Ben, can you explicitly test your change with NFSv4.0-only servers? Thank=
s!

> I have two quick
> questions on desired behavior:
>=20
> o  Should mounts that do not specify a minor version be upgraded to the de=
fault minor version?
>=20
> For example, should 'mount -overs=3D4' turn into 'mount -overs4.1', if the=

> current default is 4.1?
>=20
>=20
> o If 'yes' to the above, should mount auto-retry decrementing minor
> versions if EPROTONOSUPPORT?
>=20
> For example, 'mount -overs=3D4' with a default of 4.2 would attempt: 4.2,
> then 4.1, then 4.0.
>=20
> Ben
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
