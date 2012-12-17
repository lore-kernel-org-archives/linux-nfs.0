Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57750 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753302Ab2LQVq2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 16:46:28 -0500
Message-ID: <50CF927D.5080104@RedHat.com>
Date: Mon, 17 Dec 2012 16:45:33 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>,
        Sean Finney <sean.finney@sonyericsson.com>
Subject: Re: [nfs-utils PATCH] mountd: fix checking for errors when exporting
 filesystems.
References: <20121213112529.06ebda22@notabene.brown>
In-Reply-To: <20121213112529.06ebda22@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/12/12 19:25, NeilBrown wrote:
> 
> 
> commit 5604b35a61e22930873ffc4e9971002f578e7978
>   nfs-utils: Increase the stdio file buffer size for procfs files
> 
> changed writes to some sysfs files to be line buffered (_IOLBF) where
> they weren't before.  While this probably makes sense, it introduced a bug.
> 
> With fully buffered streams, you don't expect to get an error until you
> call fflush().
> With line buffered streams you can get the error from fprintf() et al.
> 
> qword_eol() only tests the return from fflush(), not from fprintf().  Consequently
> errors were not noticed.
> 
> One result of this is that if you export, with crossmnt, a filesystem underneath
> which are mounted non-exportable filesystems (e.g. /proc) then an 'ls -l' on the
> client will block indefinitely waiting for a meaningful 'yes' or 'no' from the
> server, but will never get one.
> 
> This patch changes qword_eol to test both fprintf and fflush.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed...

steved.

> 
> diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
> index e641c45..61e07a8 100644
> --- a/support/nfs/cacheio.c
> +++ b/support/nfs/cacheio.c
> @@ -162,11 +162,16 @@ int qword_eol(FILE *f)
>  {
>  	int err;
>  
> -	fprintf(f,"\n");
> -	err = fflush(f);
> -	if (err) {
> -		xlog_warn("qword_eol: fflush failed: errno %d (%s)",
> +	err = fprintf(f,"\n");
> +	if (err < 0) {
> +		xlog_warn("qword_eol: fprintf failed: errno %d (%s)",
>  			    errno, strerror(errno));
> +	} else {
> +		err = fflush(f);
> +		if (err) {
> +			xlog_warn("qword_eol: fflush failed: errno %d (%s)",
> +				  errno, strerror(errno));
> +		}
>  	}
>  	/*
>  	 * We must send one line (and one line only) in a single write
> 
