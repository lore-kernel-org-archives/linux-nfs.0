From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Remove incorrect do_vfs_lock message
Date: Tue, 7 Sep 2010 13:38:54 -0400
Message-ID: <20100907133854.1936b695@tlielax.poochiereds.net>
References: <20100907025601.22a5ea2f@sleipnir.ol>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Fabio Olive Leite <fleite@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35349 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932147Ab0IGRi4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 13:38:56 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o87Hctu4016062
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 13:38:56 -0400
In-Reply-To: <20100907025601.22a5ea2f-rz8jLxre1qydWlpZFn+bTg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 7 Sep 2010 02:56:01 -0300
=46abio Olive Leite <fleite@redhat.com> wrote:

> The do_vfs_lock function on fs/nfs/file.c is only called if NLM is
> not being used, via the -onolock mount option. Therefore it cannot
> really be "out of sync with lock manager" when the local locking
> function called returns an error, as there will be no corresponding
> call to the NLM. For details, simply check the if/else on do_setlk
> and do_unlk on fs/nfs/file.c.
>=20
> Signed-Off-By: Fabio Olive Leite <fleite@redhat.com>
>=20
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -723,10 +723,6 @@ static int do_vfs_lock(struct file *file, struct=
 file_lock *fl)
>  		default:
>  			BUG();
>  	}
> -	if (res < 0)
> -		dprintk(KERN_WARNING "%s: VFS is out of sync with lock manager"
> -			" - error %d!\n",
> -				__func__, res);
>  	return res;
>  }
> =20
>=20
> Please keep me copied as I don't subscribe to the list.
>=20
> Regards,
> F=E1bio Oliv=E9

Reviewed-by: Jeff Layton <jlayton@redhat.com>
