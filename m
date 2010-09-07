From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Remove incorrect do_vfs_lock message
Date: Tue, 7 Sep 2010 13:25:04 -0400
Message-ID: <20100907172504.GB13022@fieldses.org>
References: <20100907025601.22a5ea2f@sleipnir.ol>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <trond@netapp.com>
To: Fabio Olive Leite <fleite@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33796 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932192Ab0IGRZu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 13:25:50 -0400
In-Reply-To: <20100907025601.22a5ea2f-rz8jLxre1qydWlpZFn+bTg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks right to me.

On Tue, Sep 07, 2010 at 02:56:01AM -0300, Fabio Olive Leite wrote:
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
> F=C3=A1bio Oliv=C3=A9
> --=20
> TcheLinux.org, OeSC-Livre.org, Chapec=C3=B3, SC
> ex sed lex awk yacc, e pluribus unix, amem
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
