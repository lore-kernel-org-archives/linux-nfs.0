Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:44173 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbaDUDXA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Apr 2014 23:23:00 -0400
Received: by mail-pd0-f175.google.com with SMTP id x10so3229480pdj.20
        for <linux-nfs@vger.kernel.org>; Sun, 20 Apr 2014 20:22:59 -0700 (PDT)
Message-ID: <53548EF2.40408@gmail.com>
Date: Mon, 21 Apr 2014 11:22:26 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Bernd Schubert <bernd.schubert@fastmail.fm>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: nfsd4_decode_create: Fix a possible NULL pointer
 dereference
References: <lis0kj$kaj$1@ger.gmane.org>
In-Reply-To: <lis0kj$kaj$1@ger.gmane.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2014/4/19 04:06, Bernd Schubert wrote:
> While running FhGFS-to-NFS stress tests, I noticed this bug (with a
> RHEL 6.5 kernel, but I think it also in linux-git).
>
> [ 3428.087489] BUG: unable to handle kernel paging request at ffff880735fb8000
> [ 3428.094821] IP: [<ffffffffa038066e>] nfsd4_create+0x27e/0x380 [nfsd]
>
> gdb resolves this to
>
> (gdb) l *(nfsd4_create+0x27e)
> 0x1469e is in nfsd4_create (fs/nfsd/nfs4proc.c:527).
> 522                      * null-terminate by brute force, since at worst we
> 523                      * will overwrite the first byte of the create namelen
> 524                      * in the XDR buffer, which has already been extracted
> 525                      * during XDR decode.
> 526                      */
> 527                     create->cr_linkname[create->cr_linklen] = 0;
> 528
> 529                     status = nfsd_symlink(rqstp, &cstate->current_fh,
> 530                                           create->cr_name, create->cr_namelen,
> 531                                           create->cr_linkname, create->cr_linklen,
>
>
> create->cr_linkname is set in nfsd4_decode_create and
> even current .git does not check for the result of savemem
> there.
>
> --
> nfsd: nfsd4_decode_create: Fix a possible NULL pointer dereference
>
> From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
>
> create->cr_linkname was later used without any check if savemem()
> succeeded.
>
>
> Signed-off-by: Bernd Schubert <bernd.schubert@fastmail.fm>
> ---
>   fs/nfsd/nfs4xdr.c |    4 ++++
>   1 file changed, 4 insertions(+)
>
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 2723c1b..eb65d1e 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -603,6 +603,10 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
>   		READ32(create->cr_linklen);
>   		READ_BUF(create->cr_linklen);
>   		SAVEMEM(create->cr_linkname, create->cr_linklen);
> +		status = check_filename(create->cr_linkname,
> +					create->cr_linklen);

Don't call check_filename() here.

cr_linkname maybe a path contains '/', or '.',
check_filename will return error nfserr_badname for those path.

IMO, just check whether the length is zero as,

if (create->cr_linklen == 0)
	return nfserr_inval;

thanks,
Kinglong Mee
