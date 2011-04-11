From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/5] nfsd: distinguish functions of NFSD_MAY_* flags
Date: Mon, 11 Apr 2011 08:42:41 -0400
Message-ID: <20110411124241.GA32332@fieldses.org>
References: <20110410162536.GC26233@fieldses.org>
 <1302452973-27272-1-git-send-email-bfields@redhat.com>
 <4DA2703B.8070300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "J. Bruce Fields" <bfields@redhat.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Bryan Schumaker <bjschuma@netapp.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59999 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293Ab1DKMmq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Apr 2011 08:42:46 -0400
In-Reply-To: <4DA2703B.8070300@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 11, 2011 at 11:06:35AM +0800, Mi Jinlong wrote:
>=20
>=20
> J. Bruce Fields =E5=86=99=E9=81=93:
> > Most of the NFSD_MAY_* flags actually request permissions, but over=
 the
> > years we've accreted a few that modify the behavior of the permissi=
on or
> > open code in other ways.
> >=20
> > Distinguish the two cases a little more.  In particular, allow the
> > shortcut at the start of nfsd_permission to ignore the
> > non-permission-requesting bits.
> >=20
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/vfs.c |    2 +-
> >  fs/nfsd/vfs.h |    3 +++
> >  2 files changed, 4 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 2e1cebd..ac4f0b4 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -2027,7 +2027,7 @@ nfsd_permission(struct svc_rqst *rqstp, struc=
t svc_export *exp,
> >  	struct inode	*inode =3D dentry->d_inode;
> >  	int		err;
> > =20
> > -	if (acc =3D=3D NFSD_MAY_NOP)
> > +	if (acc & NFSD_MAY_MASK =3D=3D NFSD_MAY_NOP)
> >  		return 0;
>=20
>   Maybe there is a problem, the priority of '=3D=3D' is higher than '=
&',=20
>   this line equal to "if (acc & (NFSD_MAY_MASK =3D=3D NFSD_MAY_NOP))"=
,
>   "return 0" will appears every time, I think it's not we really want=
=2E
>=20
>   "if ((acc & NFSD_MAY_MASK) =3D=3D NFSD_MAY_NOP)" is we need,
>   do you think so?

Yes, thanks--fixed.--b.
