From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Replace NFS4ERR_NOTEMPY with NFS4ERR_EXIST
Date: Wed, 18 Mar 2009 19:10:02 -0400
Message-ID: <20090318231002.GL18894@fieldses.org>
References: <49B8A224.6070803@cn.fujitsu.com> <49C054A3.9010402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Ni Wenjuan <niwj@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:55038 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754275AbZCRXKE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 19:10:04 -0400
In-Reply-To: <49C054A3.9010402@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 18, 2009 at 09:55:47AM +0800, Ni Wenjuan wrote:
> Ni Wenjuan =E5=86=99=E9=81=93:
> > Fix a test in rename operation. rename dir1 into existing,nonempty =
dir2 should
> > return  NFS4ERR_EXIST instead got NFS4ERR_NOTEMPTY. RFC says if the=
 target is a
> > directory but not empty, the server will return the error, NFS4ERR_=
EXIST.
> >=20
> > Signed-off-by:Ni Wenjuan  <niwj@cn.fujitsu.com>
> >=20
> > ---
> >  fs/nfsd/nfs4proc.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 9fa60a3..c1e2e22 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -605,7 +605,7 @@ nfsd4_rename(struct svc_rqst *rqstp, struct
> > nfsd4_compound_state *cstate,
> >=20
> >  	/* the underlying filesystem returns different error's than requi=
red
> >  	 * by NFSv4. both save_fh and current_fh have been verified.. */
> > -	if (status =3D=3D nfserr_isdir)
> > +	if (status =3D=3D nfserr_isdir || status =3D=3D nfserr_notempty)
> >  		status =3D nfserr_exist;
> >  	else if ((status =3D=3D nfserr_notdir) &&
> >                    (S_ISDIR(cstate->save_fh.fh_dentry->d_inode->i_m=
ode) &&
>=20
> Bruce ,do you think this patch is ok ?   Can it be accepted?

OK.  Did you already post this patch?  Sorry, I can't seem to find it.
Could you repost in the standard format?

--b.
