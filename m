From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Remove incorrect do_vfs_lock message
Date: Tue, 07 Sep 2010 14:24:17 -0400
Message-ID: <1283883857.2788.51.camel@heimdal.trondhjem.org>
References: <20100907025601.22a5ea2f@sleipnir.ol>
	 <20100907133854.1936b695@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fabio Olive Leite <fleite@redhat.com>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:36935 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932519Ab0IGSYY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 14:24:24 -0400
In-Reply-To: <20100907133854.1936b695-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-09-07 at 13:38 -0400, Jeff Layton wrote:
> On Tue, 7 Sep 2010 02:56:01 -0300
> Fabio Olive Leite <fleite@redhat.com> wrote:
>=20
> > The do_vfs_lock function on fs/nfs/file.c is only called if NLM is
> > not being used, via the -onolock mount option. Therefore it cannot
> > really be "out of sync with lock manager" when the local locking
> > function called returns an error, as there will be no corresponding
> > call to the NLM. For details, simply check the if/else on do_setlk
> > and do_unlk on fs/nfs/file.c.
> >=20
> > Signed-Off-By: Fabio Olive Leite <fleite@redhat.com>
> >=20
> > diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> > --- a/fs/nfs/file.c
> > +++ b/fs/nfs/file.c
> > @@ -723,10 +723,6 @@ static int do_vfs_lock(struct file *file, stru=
ct file_lock *fl)
> >  		default:
> >  			BUG();
> >  	}
> > -	if (res < 0)
> > -		dprintk(KERN_WARNING "%s: VFS is out of sync with lock manager"
> > -			" - error %d!\n",
> > -				__func__, res);
> >  	return res;
> >  }
> > =20
> >=20
> > Please keep me copied as I don't subscribe to the list.
> >=20
> > Regards,
> > F=C3=A1bio Oliv=C3=A9
>=20
> Reviewed-by: Jeff Layton <jlayton@redhat.com>

Applied (after removing the ^M)...

Trond

