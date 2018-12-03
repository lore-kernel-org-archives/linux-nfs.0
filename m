Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0FC2C04EBF
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 18:23:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8F4FD2087F
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 18:23:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pDezvx6A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F4FD2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726733AbeLCSX3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 13:23:29 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:37860 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726445AbeLCSX3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 13:23:29 -0500
Received: by mail-it1-f195.google.com with SMTP id b5so10092223iti.2;
        Mon, 03 Dec 2018 10:23:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=3SiQY2CMdRhsl2nHeCRKYaQ9sADf2BUXeb/4uXlrMUE=;
        b=pDezvx6ATN5gMgsmNsI8JcwXHXzZwkw87hEYKprMZvTAgRLKl9EU+prVdZ4kL1gHp5
         zCH3aTL51U1bhj45aujAddYW2KvCsShk428l8713EOOzG6jkkNF2xgWNZ4NFs7/R1Lzl
         qIkfJoxR90XHdEYVvCE1gw6wkCvuCz5/9cP92ScyasSjcAW2tI3/8XQ44BB2BOySZGDA
         /NAUJG17JS0JIIwHvH2CKDejjzHvEQoWJcb6YA9lQtWMDIulnSjBlxLU9WV4NxRwPdcu
         L0JMlF0Sasu2Me7rcTJ5hzAKRg8jV/lFnZvn/f2GSo+JLFSq0S2H1JUYm80aw+drWflZ
         J7Lw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:message-id:subject:from:to:cc:date
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=3SiQY2CMdRhsl2nHeCRKYaQ9sADf2BUXeb/4uXlrMUE=;
        b=CsKInjWkKio0uCPMrCHtK64Om18ER5yHJXCigDkLhVPNubPn0AS7YA/rhMREZbZa8z
         wEzUcnJqFBJAmOF5FyY3cBwEmUmKwTuZ78j71kfISk3K1pXQLPcl0HykGDTV/xUyxahI
         S55sD+pTqpEWT4KerTyWoxNI7aX0duyzloTcaYAVRxJDrT0CDs4qhRGGUgYsF/2e9tY3
         PiTIibtXBvEPx3DDwQ3+r4AmW7Tf9LkD204NYM3zCwqldE9z+X6DggJcd+nqxrWDFIRI
         IZxndGyZnEFj+mJ8r31WKX/BHbKVATJJn8AtyA8Uuxv2PUv7puLL1sdDw/cvQz6bcYeV
         jP6g==
X-Gm-Message-State: AA+aEWaS76czbmIbuaJy2pju9aERYJ+oMeN62mPb0JNDARducy6nZR/X
        QXtyYxWyOE+wRC34bfv9bExsTSswi2w=
X-Google-Smtp-Source: AFSGD/WkFUpitfb+wIqJi6BBVgrz09vV2s0+EN76G5/UyaBG8I5EwcVOp+pOksgVXjfMShOxbkLAlQ==
X-Received: by 2002:a24:b305:: with SMTP id e5-v6mr9195415itf.128.1543861402330;
        Mon, 03 Dec 2018 10:23:22 -0800 (PST)
Received: from gouda.nowheycreamery.com (c-68-40-188-1.hsd1.mi.comcast.net. [68.40.188.1])
        by smtp.googlemail.com with ESMTPSA id q9sm5412234ioh.32.2018.12.03.10.23.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Dec 2018 10:23:21 -0800 (PST)
Message-ID: <59b1b9df94be7f8c9716a906dca4254749cd9be8.camel@gmail.com>
Subject: Re: [PATCH 03/11] vfs: no fallback for ->copy_file_range
From:   Anna Schumaker <schumaker.anna@gmail.com>
To:     Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org,
        linux-xfs@vger.kernel.org
Cc:     olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Date:   Mon, 03 Dec 2018 13:23:20 -0500
In-Reply-To: <20181203083416.28978-4-david@fromorbit.com>
References: <20181203083416.28978-1-david@fromorbit.com>
         <20181203083416.28978-4-david@fromorbit.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.2 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Dave,

On Mon, 2018-12-03 at 19:34 +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Now that we have generic_copy_file_range(), remove it as a fallback
> case when offloads fail. This puts the responsibility for executing
> fallbacks on the filesystems that implement ->copy_file_range and
> allows us to add operational validity checks to
> generic_copy_file_range().
> 
> Rework vfs_copy_file_range() to call a new do_copy_file_range()
> helper to exceute the copying callout, and move calls to
> generic_file_copy_range() into filesystem methods where they
> currently return failures.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/ceph/file.c      | 17 ++++++++++++++++-
>  fs/cifs/cifsfs.c    |  4 ++++
>  fs/fuse/file.c      | 17 ++++++++++++++++-
>  fs/nfs/nfs4file.c   |  4 ++++

The NFS bits look okay to me:
Acked-by: Anna Schumaker <Anna.Schumaker@Netapp.com

>  fs/overlayfs/file.c |  9 ++++++++-
>  fs/read_write.c     | 24 +++++++++++++++---------
>  6 files changed, 63 insertions(+), 12 deletions(-)
> 
> diff --git a/fs/ceph/file.c b/fs/ceph/file.c
> index 189df668b6a0..cf29f0410dcb 100644
> --- a/fs/ceph/file.c
> +++ b/fs/ceph/file.c
> @@ -1885,7 +1885,7 @@ static int is_file_size_ok(struct inode *src_inode,
> struct inode *dst_inode,
>  	return 0;
>  }
>  
> -static ssize_t ceph_copy_file_range(struct file *src_file, loff_t src_off,
> +static ssize_t __ceph_copy_file_range(struct file *src_file, loff_t src_off,
>  				    struct file *dst_file, loff_t dst_off,
>  				    size_t len, unsigned int flags)
>  {
> @@ -2096,6 +2096,21 @@ static ssize_t ceph_copy_file_range(struct file
> *src_file, loff_t src_off,
>  	return ret;
>  }
>  
> +static ssize_t ceph_copy_file_range(struct file *src_file, loff_t src_off,
> +				    struct file *dst_file, loff_t dst_off,
> +				    size_t len, unsigned int flags)
> +{
> +	ssize_t ret;
> +
> +	ret = __ceph_copy_file_range(src_file, src_off, dst_file, dst_off,
> +					len, flags);
> +
> +	if (ret == -EOPNOTSUPP)
> +		ret = generic_copy_file_range(src_file, src_off, dst_file,
> +					dst_off, len, flags);
> +	return ret;
> +}
> +
>  const struct file_operations ceph_file_fops = {
>  	.open = ceph_open,
>  	.release = ceph_release,
> diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> index 865706edb307..5ef4baec6234 100644
> --- a/fs/cifs/cifsfs.c
> +++ b/fs/cifs/cifsfs.c
> @@ -1141,6 +1141,10 @@ static ssize_t cifs_copy_file_range(struct file
> *src_file, loff_t off,
>  	rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
>  					len, flags);
>  	free_xid(xid);
> +
> +	if (rc == -EOPNOTSUPP)
> +		rc = generic_copy_file_range(src_file, off, dst_file,
> +					destoff, len, flags);
>  	return rc;
>  }
>  
> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> index b52f9baaa3e7..b86fb0298739 100644
> --- a/fs/fuse/file.c
> +++ b/fs/fuse/file.c
> @@ -3024,7 +3024,7 @@ static long fuse_file_fallocate(struct file *file, int
> mode, loff_t offset,
>  	return err;
>  }
>  
> -static ssize_t fuse_copy_file_range(struct file *file_in, loff_t pos_in,
> +static ssize_t __fuse_copy_file_range(struct file *file_in, loff_t pos_in,
>  				    struct file *file_out, loff_t pos_out,
>  				    size_t len, unsigned int flags)
>  {
> @@ -3100,6 +3100,21 @@ static ssize_t fuse_copy_file_range(struct file
> *file_in, loff_t pos_in,
>  	return err;
>  }
>  
> +static ssize_t fuse_copy_file_range(struct file *src_file, loff_t src_off,
> +				    struct file *dst_file, loff_t dst_off,
> +				    size_t len, unsigned int flags)
> +{
> +	ssize_t ret;
> +
> +	ret = __fuse_copy_file_range(src_file, src_off, dst_file, dst_off,
> +					len, flags);
> +
> +	if (ret == -EOPNOTSUPP)
> +		ret = generic_copy_file_range(src_file, src_off, dst_file,
> +					dst_off, len, flags);
> +	return ret;
> +}
> +
>  static const struct file_operations fuse_file_operations = {
>  	.llseek		= fuse_file_llseek,
>  	.read_iter	= fuse_file_read_iter,
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 46d691ba04bc..d7766a6eb0f4 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -141,6 +141,10 @@ static ssize_t nfs4_copy_file_range(struct file *file_in,
> loff_t pos_in,
>  	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
>  	if (ret == -EAGAIN)
>  		goto retry;
> +
> +	if (ret == -EOPNOTSUPP)
> +		ret = generic_copy_file_range(file_in, pos_in, file_out,
> +					pos_out, count, flags);
>  	return ret;
>  }
>  
> diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> index 84dd957efa24..68736e5d6a56 100644
> --- a/fs/overlayfs/file.c
> +++ b/fs/overlayfs/file.c
> @@ -486,8 +486,15 @@ static ssize_t ovl_copy_file_range(struct file *file_in,
> loff_t pos_in,
>  				   struct file *file_out, loff_t pos_out,
>  				   size_t len, unsigned int flags)
>  {
> -	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
> +	ssize_t ret;
> +
> +	ret =  ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
>  			    OVL_COPY);
> +
> +	if (ret == -EOPNOTSUPP)
> +		ret = generic_copy_file_range(file_in, pos_in, file_out,
> +					pos_out, len, flags);
> +	return ret;
>  }
>  
>  static loff_t ovl_remap_file_range(struct file *file_in, loff_t pos_in,
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 50114694c98b..44339b44accc 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1570,6 +1570,18 @@ ssize_t generic_copy_file_range(struct file *file_in,
> loff_t pos_in,
>  }
>  EXPORT_SYMBOL(generic_copy_file_range);
>  
> +static ssize_t do_copy_file_range(struct file *file_in, loff_t pos_in,
> +			    struct file *file_out, loff_t pos_out,
> +			    size_t len, unsigned int flags)
> +{
> +	if (file_out->f_op->copy_file_range)
> +		return file_out->f_op->copy_file_range(file_in, pos_in,
> file_out,
> +						      pos_out, len, flags);
> +
> +	return generic_copy_file_range(file_in, &pos_in, file_out, &pos_out,
> +					len, flags);
> +}
> +
>  /*
>   * copy_file_range() differs from regular file read and write in that it
>   * specifically allows return partial success.  When it does so is up to
> @@ -1634,15 +1646,9 @@ ssize_t vfs_copy_file_range(struct file *file_in,
> loff_t pos_in,
>  		}
>  	}
>  
> -	if (file_out->f_op->copy_file_range) {
> -		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
> -						      pos_out, len, flags);
> -		if (ret != -EOPNOTSUPP)
> -			goto done;
> -	}
> -
> -	ret = generic_copy_file_range(file_in, &pos_in, file_out, &pos_out,
> -					len, flags);
> +	ret = do_copy_file_range(file_in, pos_in, file_out, pos_out, len,
> +				flags);
> +	WARN_ON_ONCE(ret == -EOPNOTSUPP);
>  done:
>  	if (ret > 0) {
>  		fsnotify_access(file_in);

