Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30914 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753226AbaHLQoG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 12:44:06 -0400
Message-ID: <53EA4450.1060900@RedHat.com>
Date: Tue, 12 Aug 2014 12:44:00 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Pavel Shilovsky <pshilovsky@samba.org>
CC: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
        Jeff Layton <jlayton@samba.org>
Subject: Re: [PATCH 5/5] special: fix op_unlk and op_ren tests output
References: <1407326472-13853-1-git-send-email-pshilovsky@samba.org> <1407326472-13853-6-git-send-email-pshilovsky@samba.org>
In-Reply-To: <1407326472-13853-6-git-send-email-pshilovsky@samba.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Just curious... what is wrong with the output of these
two tests? 

steved.

On 08/06/2014 08:01 AM, Pavel Shilovsky wrote:
> Signed-off-by: Pavel Shilovsky <pshilovsky@samba.org>
> ---
>  special/op_ren.c  | 16 +++++++++++++---
>  special/op_unlk.c |  8 +++++---
>  2 files changed, 18 insertions(+), 6 deletions(-)
> 
> diff --git a/special/op_ren.c b/special/op_ren.c
> index 348b4f9..93b02c5 100644
> --- a/special/op_ren.c
> +++ b/special/op_ren.c
> @@ -32,6 +32,8 @@
>  
>  #define TBUFSIZ 100
>  static char wbuf[TBUFSIZ], rbuf[TBUFSIZ];
> +static char bufa[BUFSIZ];
> +static char bufb[BUFSIZ];
>  #define TMSG "This is a test message written to the target file\n"
>  
>  static void
> @@ -120,13 +122,19 @@ main(argc, argv)
>  #endif /* O_RDWR */
>  
>  	printf("nfsjunk files before rename:\n  ");
> -	system("ls -al .nfs*");
> +	sprintf(bufa, "ls -al %s", taname);
> +	sprintf(bufb, "ls -al %s", tbname);
> +	system(bufa);
> +	printf("  ");
> +	system(bufb);
>  	ret = rename(taname, tbname);
>  	printf("%s open; rename ret = %d\n", tbname, ret);
>  	if (ret)
>  		xxit(" unlink");
>  	printf("nfsjunk files after rename:\n  ");
> -	system("ls -al .nfs*");
> +	system(bufa);
> +	printf("  ");
> +	system(bufb);
>  	strcpy(wbuf, TMSG);
>  	if ((ret = write(fd, wbuf, TBUFSIZ)) != TBUFSIZ) {
>  		fprintf(stderr, "write ret %d; expected %d\n", ret, TBUFSIZ);
> @@ -165,7 +173,9 @@ main(argc, argv)
>  	}
>  
>  	printf("nfsjunk files after close:\n  ");
> -	system("ls -al .nfs*");
> +	system(bufa);
> +	printf("  ");
> +	system(bufb);
>  
>  	if ((ret = close(fd)) == 0) {
>  		errcount++;
> diff --git a/special/op_unlk.c b/special/op_unlk.c
> index 93a09b0..d92aa22 100644
> --- a/special/op_unlk.c
> +++ b/special/op_unlk.c
> @@ -33,6 +33,7 @@
>  
>  #define TBUFSIZ 100
>  static char wbuf[TBUFSIZ], rbuf[TBUFSIZ];
> +static char buf[BUFSIZ];
>  #define TMSG "This is a test message written to the unlinked file\n"
>  
>  static void
> @@ -78,13 +79,14 @@ main(argc, argv)
>  #ifndef WIN32
>  	/* For WIN you can not delete the file if it is open */
>  	printf("nfsjunk files before unlink:\n  ");
> -	system("ls -al .nfs*");
> +	sprintf(buf, "ls -al %s", tname);
> +	system(buf);
>  	ret = unlink(tname);
>  	printf("%s open; unlink ret = %d\n", tname, ret);
>  	if (ret)
>  		xxit(" unlink");
>  	printf("nfsjunk files after unlink:\n  ");
> -	system("ls -al .nfs*");
> +	system(buf);
>  #endif
>  	strcpy(wbuf, TMSG);
>  	if ((ret = write(fd, wbuf, TBUFSIZ)) != TBUFSIZ) {
> @@ -137,7 +139,7 @@ main(argc, argv)
>  
>  #ifndef WIN32
>  	printf("nfsjunk files after close:\n  ");
> -	system("ls -al .nfs*");
> +	system(buf);
>  #endif
>  
>  	if ((ret = close(fd)) == 0) {
> 
