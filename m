From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd restart failures without /proc/fs/nfsd filesystem mounted
Date: Tue, 1 Apr 2008 17:06:27 -0400
Message-ID: <20080401210627.GD21343@fieldses.org>
References: <DDFD17CC94A9BD49A82147DDF7D545C59D349C@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Anirban Sinha <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37944 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756793AbYDAVG3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Apr 2008 17:06:29 -0400
In-Reply-To: <DDFD17CC94A9BD49A82147DDF7D545C59D349C-Lp/cVzEoVyb8BYCnuv3k+coc7lC+zEt2hPhL2mjWHbk@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 31, 2008 at 03:39:04PM -0700, Anirban Sinha wrote:
> Hi:
>=20
> I am using a system where we do not use the /proc/nfs/nfsd filesystem=
 (due to several reasons). I understand that without this filesystem, n=
fsutils does not use the "new cache" mechanism. However, a nfsd restart=
 operation should still be functional. However, when I try doing this m=
anually, I get the following error:=20
>=20
> root:my_node:/etc/rc.d/init.d# /sbin/service nfs restart
> Shutting down NFS mountd:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 [=C2=A0 OK=C2=A0 ]
> Shutting down NFS daemon:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0 [FAILED]
> Shutting down NFS services:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
 [=C2=A0 OK=C2=A0 ]
> Starting NFS services:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 [=C2=A0 OK=C2=A0 ]
> Starting NFS daemon:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0[FAILED]
> Starting NFS mountd:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 [=C2=A0 OK=C2=A0 ]
>=20
> And the kernel log says:
> [13:37:37.766844] nfsd: Could not allocate memory read-ahead cache.

What kernel version is this?  In the latest
fs/nfsd/vfs.c:nfsd_racache_init(int cache_size):

	raparml =3D kcalloc(cache_size, sizeof(struct raparms), GFP_KERNEL);

	if (!raparml) {
		printk(KERN_WARNING
			"nfsd: Could not allocate memory read-ahead cache.\n");
		return -ENOMEM;
	}

which is called from fs/nfsd/nfssvc.c:nfsd_svc() as:

	error =3D nfsd_racache_init(2*nrservs);

where nrservs is the number of server threads.  How many server threads=
 are you
trying to start, and how much memory do you have?

--b.

>=20
> This issue is happening on an intel platform. However, this same oper=
ation succeeds on our mips platform (without nfsd filesystem). What is =
also interesting is that once I turn on /proc/fs/nfsd filesystem on Int=
el, the issue seems to go away.
>=20
> Several weeks back, I reported an issue regarding exportfs -a failure=
 on an already exported filesystem when nfsd FS was not used. It turned=
 out to be a bug in the nfsutils. Did we bump into another bug here? Is=
 there no other option but to turn on nfsd filesystem?=20
>=20
> Thanks for whoever responds to this ...
>=20
> Cheers,
>=20
> Ani
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
