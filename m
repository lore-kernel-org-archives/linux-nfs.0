Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:35296 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751563AbdCCOjb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Mar 2017 09:39:31 -0500
Received: by mail-it0-f66.google.com with SMTP id 203so2488399ith.2
        for <linux-nfs@vger.kernel.org>; Fri, 03 Mar 2017 06:38:14 -0800 (PST)
Subject: Re: [PATCH] NFSv4.2: Fix file creating with O_EXCL get a bad mode
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <a76cec59-f007-5c26-dc26-4cc8a6e4daef@gmail.com>
Cc: linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruenba@redhat.com>,
        Matthieu Herrb <matthieu.herrb@laas.fr>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <aaab019a-cba0-00a1-8278-c5933211e717@gmail.com>
Date: Fri, 3 Mar 2017 21:32:58 +0800
MIME-Version: 1.0
In-Reply-To: <a76cec59-f007-5c26-dc26-4cc8a6e4daef@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ping...

What's the state? The problem is also exist in the latest kernel.

Also, the patch should be updated based on the latest kernel.

thanks,
Kinglong Mee

On 1/7/2017 22:45, Kinglong Mee wrote:
> Acorrding to Matthieu Herrb's test cases, a new created file will
> get a bad mode as 0666 (expected 0644) after commit dff25ddb4808
> "nfs: add support for the umask attribute".
> 
> It is caused by missing check of FATTR4_WORD2_MODE_UMASK
> in nfs4_exclusive_attrset.
> 
> #include <sys/types.h>
> #include <sys/stat.h>
> #include <err.h>
> #include <fcntl.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <unistd.h>
> 
> /*
>  * Demonstrate file creation bug on NFS v4 and linux kernel 4.4+
>  *
>  * mktemp() is used on purpose.
>  */
> int
> main(int argc, char *argv[])
> {
> 	const char *name = argv[1];
> 	char tmp[] = "./tmpXXXXXXXXXX";
> 	struct stat buf;
> 	mode_t expected;
> 	int fd, i, n = 40;
> 
> 	umask(S_IWGRP | S_IWOTH);
> 	expected = 0666 & ~(S_IWGRP | S_IWOTH);
> 	if (argv[1] == NULL)
> 		name = mktemp(tmp);
> 	for (i = 0; i < n; i++) {
> 		fd = open(name, O_RDWR|O_CREAT|O_EXCL, 0666);
> 		if (fd < 0)
> 			err(1, "open %s", name);
> 		memset(&buf, 0, sizeof(buf));
> 		if (stat(name, &buf) < 0)
> 			err(1, "stat %s", name);
> 		if ((buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO)) != expected)
> 			printf("%s: %o\n", name,
> 			    (int)buf.st_mode & (S_IRWXU|S_IRWXG|S_IRWXO));
> 		else
> 			printf("%s: ok\n", name);
> 		unlink(name);
> 	}
> 	exit(0);
> }
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  fs/nfs/nfs4proc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 6dcbc5d..a3e9ef1 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -2697,7 +2697,8 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata,
>  		sattr->ia_valid |= ATTR_MTIME;
>  
>  	/* Except MODE, it seems harmless of setting twice. */
> -	if ((attrset[1] & FATTR4_WORD1_MODE))
> +	if ((attrset[1] & FATTR4_WORD1_MODE) ||
> +	    (attrset[2] & FATTR4_WORD2_MODE_UMASK))
>  		sattr->ia_valid &= ~ATTR_MODE;
>  
>  	if (attrset[2] & FATTR4_WORD2_SECURITY_LABEL)
> 
