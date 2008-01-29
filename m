From: Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>
Subject: Re: atimes not updated over NFS
Date: Tue, 29 Jan 2008 21:37:14 +0100
Message-ID: <20080129203713.GS17213@aym.net2.nerim.net>
References: <20080121190638.GL17468@fieldses.org> <1200943865.25562.56.camel@heimdal.trondhjem.org> <20080121210230.GA22046@janus> <20080121210925.GQ17468@fieldses.org> <20080122171717.GD24697@fieldses.org> <20080129025940.GI16785@fieldses.org> <20080129041411.GC1190@fieldses.org> <20080129083402.GN15220@kernel.dk> <20080129182721.GB28032@fieldses.org> <20080129183042.GH15220@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Frank van Maarseveen <frankvm@frankvm.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-102-tuesday.noc.nerim.net ([62.4.17.102]:1409 "EHLO
	mallaury.nerim.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753259AbYA2UhS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2008 15:37:18 -0500
In-Reply-To: <20080129183042.GH15220@kernel.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2008-01-29 19:30 +0100, Jens Axboe wrote:

> diff --git a/fs/splice.c b/fs/splice.c
> index 0a0b79b..504a096 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -1052,8 +1052,10 @@ out_release:
>  	/*
>  	 * If we transferred some data, return the number of bytes:
>  	 */
> -	if (bytes > 0)
> +	if (bytes > 0) {
> +		file_accessed(in);
>  		return bytes;
> +	}
> =20
>  	return ret;

Does the (bytes > 0) test mean that read(2) on an empty file will
not update the atime ? Not a big deal for me personally, but that
would be inconsistent with local file system behaviour.

--=20
Andr=E9 Majorel <URL:http://www.teaser.fr/~amajorel/>
Do not use this account for regular correspondence.
See the URL above for contact information.
