Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F219C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 19:04:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1394A20848
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 19:04:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="K5BWv3Vv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1394A20848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726089AbeLCTEk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 14:04:40 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:35798 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725964AbeLCTEk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 14:04:40 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wB3J3dWG070908;
        Mon, 3 Dec 2018 19:04:34 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=8BhAfk3zAQCe6j2myR0aHUT7XumfnV3vb7T4xuufois=;
 b=K5BWv3Vv2kVLEykxkI/faJBFwt63udNhryvgtnMscDXfghjZhcVCKIg8sWc7r4WVHLWW
 NELq3IsAw1pVm9Qh+BEs0UdIlYXtXKJL4xAomPEfa6Z5zpWYCJiHtX9vsR0oM36KgqIm
 JvT8TUkx/4aodwdUhTYhUoRwMAtfdJpK2s4IUDxCUOhC6qhX50LOJMWnlkAgOFzJxuhY
 XFRTkU86R9Sc5ywwxmJereYaK2mEOKZDd3x+c7zzVQChXjEsMZxiZ84vNFr/3hVrvNT3
 A03iywuzzpzzWtqkRKUl0gV0LzFu86gbDQzU/91CZeiwF36Ijv424mSGxA6+YejS5kGH 3g== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2130.oracle.com with ESMTP id 2p3hqtr989-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 03 Dec 2018 19:04:33 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wB3J4SGs007620
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 3 Dec 2018 19:04:28 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wB3J4RLT028162;
        Mon, 3 Dec 2018 19:04:27 GMT
Received: from localhost (/67.169.218.210)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 03 Dec 2018 11:04:26 -0800
Date:   Mon, 3 Dec 2018 11:04:24 -0800
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 04/11] vfs: add missing checks to copy_file_range
Message-ID: <20181203190424.GC24487@magnolia>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-5-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203083416.28978-5-david@fromorbit.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9096 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=945
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812030176
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 03, 2018 at 07:34:09PM +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> Like the clone and dedupe interfaces we've recently fixed, the
> copy_file_range() implementation is missing basic sanity, limits and
> boundary condition tests on the parameters that are passed to it
> from userspace. Create a new "generic_copy_file_checks()" function
> modelled on the generic_remap_checks() function to provide this
> missing functionality.
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/read_write.c    | 27 ++++++------------
>  include/linux/fs.h |  3 ++
>  mm/filemap.c       | 69 ++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 81 insertions(+), 18 deletions(-)
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 44339b44accc..69809345977e 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1578,7 +1578,7 @@ static ssize_t do_copy_file_range(struct file *file_in, loff_t pos_in,
>  		return file_out->f_op->copy_file_range(file_in, pos_in, file_out,
>  						      pos_out, len, flags);
>  
> -	return generic_copy_file_range(file_in, &pos_in, file_out, &pos_out,
> +	return generic_copy_file_range(file_in, pos_in, file_out, pos_out,
>  					len, flags);
>  }
>  
> @@ -1598,10 +1598,14 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	if (flags != 0)
>  		return -EINVAL;
>  
> -	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
> -		return -EISDIR;
> -	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
> -		return -EINVAL;
> +	/* this could be relaxed once a method supports cross-fs copies */
> +	if (inode_in->i_sb != inode_out->i_sb)
> +		return -EXDEV;
> +
> +	ret = generic_copy_file_checks(file_in, pos_in, file_out, pos_out, &len,
> +					flags);
> +	if (ret < 0)
> +		return ret;
>  
>  	ret = rw_verify_area(READ, file_in, &pos_in, len);
>  	if (unlikely(ret))
> @@ -1611,22 +1615,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	if (unlikely(ret))
>  		return ret;
>  
> -	if (!(file_in->f_mode & FMODE_READ) ||
> -	    !(file_out->f_mode & FMODE_WRITE) ||
> -	    (file_out->f_flags & O_APPEND))
> -		return -EBADF;
> -
> -	/* this could be relaxed once a method supports cross-fs copies */
> -	if (inode_in->i_sb != inode_out->i_sb)
> -		return -EXDEV;
> -
>  	if (len == 0)
>  		return 0;
>  
> -	/* If the source range crosses EOF, fail the copy */
> -	if (pos_in >= i_size(inode_in) || pos_in + len > i_size(inode_in))
> -		return -EINVAL;
> -
>  	file_start_write(file_out);
>  
>  	/*
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index a4478764cf63..0d9d2d93d4df 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -3022,6 +3022,9 @@ extern ssize_t generic_write_checks(struct kiocb *, struct iov_iter *);
>  extern int generic_remap_checks(struct file *file_in, loff_t pos_in,
>  				struct file *file_out, loff_t pos_out,
>  				loff_t *count, unsigned int remap_flags);
> +extern int generic_copy_file_checks(struct file *file_in, loff_t pos_in,
> +				struct file *file_out, loff_t pos_out,
> +				size_t *count, unsigned int flags);
>  extern ssize_t generic_file_read_iter(struct kiocb *, struct iov_iter *);
>  extern ssize_t __generic_file_write_iter(struct kiocb *, struct iov_iter *);
>  extern ssize_t generic_file_write_iter(struct kiocb *, struct iov_iter *);
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 81adec8ee02c..0a170425935b 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2975,6 +2975,75 @@ int generic_remap_checks(struct file *file_in, loff_t pos_in,
>  	return 0;
>  }
>  
> +
> +/*
> + * Performs necessary checks before doing a file copy
> + *
> + * Can adjust amount of bytes to copy
> + * Returns appropriate error code that caller should return or
> + * zero in case the copy should be allowed.
> + */
> +int generic_copy_file_checks(struct file *file_in, loff_t pos_in,
> +			 struct file *file_out, loff_t pos_out,
> +			 size_t *req_count, unsigned int flags)
> +{
> +	struct inode *inode_in = file_inode(file_in);
> +	struct inode *inode_out = file_inode(file_out);
> +	uint64_t count = *req_count;
> +	uint64_t bcount;
> +	loff_t size_in, size_out;
> +	loff_t bs = inode_out->i_sb->s_blocksize;
> +	int ret;
> +
> +	/* Don't touch certain kinds of inodes */
> +	if (IS_IMMUTABLE(inode_out))
> +		return -EPERM;
> +
> +	if (IS_SWAPFILE(inode_in) || IS_SWAPFILE(inode_out))
> +		return -ETXTBSY;
> +
> +	/* Don't copy dirs, pipes, sockets... */
> +	if (S_ISDIR(inode_in->i_mode) || S_ISDIR(inode_out->i_mode))
> +		return -EISDIR;
> +	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
> +		return -EINVAL;
> +
> +	if (!(file_in->f_mode & FMODE_READ) ||
> +	    !(file_out->f_mode & FMODE_WRITE) ||
> +	    (file_out->f_flags & O_APPEND))
> +		return -EBADF;

These five checks are the same as the ones that are split between
do_clone_file_range and generic_remap_file_range_prep.  Perhaps they
should be factored into a single function that can be called from the
do_clone_file_range function as well as do_copy_file_range?

(I suspect also vfs_dedupe_file_range_one() should call it too, but the
dedupe code is so grotty and weird...)

--D

> +
> +	/* Ensure offsets don't wrap. */
> +	if (pos_in + count < pos_in || pos_out + count < pos_out)
> +		return -EOVERFLOW;
> +
> +	size_in = i_size_read(inode_in);
> +	size_out = i_size_read(inode_out);
> +
> +	/* If the source range crosses EOF, fail the copy */
> +	if (pos_in >= size_in)
> +		return -EINVAL;
> +	if (pos_in + count > size_in)
> +		return -EINVAL;
> +
> +	ret = generic_access_check_limits(file_in, pos_in, &count);
> +	if (ret)
> +		return ret;
> +
> +	ret = generic_write_check_limits(file_out, pos_out, &count);
> +	if (ret)
> +		return ret;
> +
> +	/* Don't allow overlapped copying within the same file. */
> +	if (inode_in == inode_out &&
> +	    pos_out + count > pos_in &&
> +	    pos_out < pos_in + count)
> +		return -EINVAL;
> +
> +	*req_count = count;
> +	return 0;
> +}
> +
>  int pagecache_write_begin(struct file *file, struct address_space *mapping,
>  				loff_t pos, unsigned len, unsigned flags,
>  				struct page **pagep, void **fsdata)
> -- 
> 2.19.1
> 
