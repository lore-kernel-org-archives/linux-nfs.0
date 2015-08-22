Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:33552 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbHVW4W (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Aug 2015 18:56:22 -0400
Received: by ykll84 with SMTP id l84so102995413ykl.0
        for <linux-nfs@vger.kernel.org>; Sat, 22 Aug 2015 15:56:21 -0700 (PDT)
Date: Sat, 22 Aug 2015 18:56:18 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: knfsd: clean up nfsd filesystem interfaces
Message-ID: <20150822185618.41d20096@tlielax.poochiereds.net>
In-Reply-To: <20150822195814.GA20768@mwanda>
References: <20150822195814.GA20768@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 22 Aug 2015 22:58:14 +0300
Dan Carpenter <dan.carpenter@oracle.com> wrote:

> Hello Jeff Layton,
> 
> The patch 3dd98a3bccb1: "knfsd: clean up nfsd filesystem interfaces"
> from Jun 10, 2008, leads to the following static checker warning:
> 
> 	fs/nfsd/nfsctl.c:1030 __write_recoverydir()
> 	error: buffer overflow 'buf' 4088 <= 4095
> 
> fs/nfsd/nfsctl.c
>   1020  static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size,
>   1021                                     struct nfsd_net *nn)
>   1022  {
>   1023          char *mesg = buf;
>   1024          char *recdir;
>   1025          int len, status;
>   1026  
>   1027          if (size > 0) {
>   1028                  if (nn->nfsd_serv)
>   1029                          return -EBUSY;
>   1030                  if (size > PATH_MAX || buf[size-1] != '\n')
> 
> This test is wrong.  simple_transaction_get() doesn't return a PAGE_SIZE
> buf.  On the other hand, it's harmless because simple_transaction_get()
> has it's own limit check.
> 
> 
> I feel like the limit check in simple_transaction_get() is one char
> too restrictive.  Maybe the simple_transaction_argresp struct used to
> have a data[1] back before we had git?
> 
> 
> Anyway, we could either delete this check or change it to:
> 
> 		if (size > SIMPLE_TRANSACTION_LIMIT || buf[size-1] != '\n')
> 

(Note that I'm no longer at Red Hat, so jlayton@redhat.com will
probably bounce...)

Hmmm...is that the case on all arches though? What if PAGE_SIZE is >4k?

    #define PATH_MAX 4096

...and...

    #define SIMPLE_TRANSACTION_LIMIT (PAGE_SIZE - sizeof(struct simple_transaction_argresp))

If PAGE_SIZE > 4096, then we could still end up with a pathname that
is longer than we can actually use in that situation.

I think we need to keep that check there (or something like it), even if
just to future-proof this code. But, I am open to suggestions on ways to
make the static checker happy.

>   1031                          return -EINVAL;
>   1032                  buf[size-1] = 0;
>   1033  
>   1034                  recdir = mesg;
>   1035                  len = qword_get(&mesg, recdir, size);
>   1036                  if (len <= 0)
>   1037                          return -EINVAL;
>   1038  
>   1039                  status = nfs4_reset_recoverydir(recdir);
>   1040                  if (status)
>   1041                          return status;
>   1042          }
>   1043  
>   1044          return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%s\n",
>   1045                                                          nfs4_recoverydir());
>   1046  }
> 
> regards,
> dan carpenter
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@poochiereds.net>
