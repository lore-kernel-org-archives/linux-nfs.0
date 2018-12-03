Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 791F6C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 18:24:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4510B208A3
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 18:24:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="MEXG0IGa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4510B208A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726893AbeLCSYk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 13:24:40 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:45464 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726394AbeLCSYj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 13:24:39 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wB3IOTPe007368;
        Mon, 3 Dec 2018 18:24:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=V0R/BXWxLXh5A/7kmZd8KEtzy17ZrQV0E4gsR/uzDJw=;
 b=MEXG0IGapQyreCpwtEoIO1HRDcZdiG/xTY0iCPsIZkJEfC8vKf5g1gejV9HOe6znjV6F
 SgUFU2eH5suORkP9HE+NQFU+XTMwL/HB8gshukjcIH7LQR7YhpN/CD16lqVuMCbfBCW9
 dGJTSgyfZximDyT7lcg9YA17T0/vo2ugkFP+0K56J7pnTLbC62q1u20IWCLJ/qFdhJDT
 Jq+Aeug23buwz04+HtAZv3pPY7t/i/Ow5pLHk7wywK959yqVqIN3A4rD8i38f1ShgOq2
 +B8XGLJJEBZdlh2nlXgOYBHaH8ZtgLsCtwKKk03ymEbFq7hTsS39J0jMPVrHhJOLfeoO Jw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2120.oracle.com with ESMTP id 2p3j8q82m7-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 03 Dec 2018 18:24:28 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wB3IOR4V016077
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 3 Dec 2018 18:24:27 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wB3IORAo006656;
        Mon, 3 Dec 2018 18:24:27 GMT
Received: from localhost (/67.169.218.210)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 03 Dec 2018 10:24:27 -0800
Date:   Mon, 3 Dec 2018 10:24:25 -0800
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     Dave Chinner <david@fromorbit.com>
Cc:     linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 08/11] vfs: push EXDEV check down into ->remap_file_range
Message-ID: <20181203182425.GA24487@magnolia>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-9-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203083416.28978-9-david@fromorbit.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9096 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=662
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812030170
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Dec 03, 2018 at 07:34:13PM +1100, Dave Chinner wrote:
> From: Dave Chinner <dchinner@redhat.com>
> 
> before we can enable cross-device copies into copy_file_range(),
> we have to ensure that ->remap_file_range() implemenations will
> correctly reject attempts to do cross filesystem clones. Currently
> these checks are done above calls to ->remap_file_range(), but
> we need to drive them inwards so that we get EXDEV protection for all
> callers of ->remap_file_range().
> 
> Signed-off-by: Dave Chinner <dchinner@redhat.com>
> ---
>  fs/read_write.c | 21 +++++++++++++--------
>  1 file changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 3288db1d5f21..174cf92eea1d 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1909,6 +1909,19 @@ int generic_remap_file_range_prep(struct file *file_in, loff_t pos_in,
>  	bool same_inode = (inode_in == inode_out);
>  	int ret;
>  
> +	/*
> +	 * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
> +	 * the same mount. Practically, they only need to be on the same file
> +	 * system. We check this here rather than at the ioctl layers because
> +	 * this is effectively a limitation of the fielsystem implementations,

"filesystem"...

--D

> +	 * not so much the API itself. Further, ->remap_file_range() can be
> +	 * called from syscalls that don't have cross device copy restrictions
> +	 * (such as copy_file_range()) and so we need to catch them before we
> +	 * do any damage.
> +	 */
> +	if (inode_in->i_sb != inode_out->i_sb)
> +		return -EXDEV;
> +
>  	/* Don't touch certain kinds of inodes */
>  	if (IS_IMMUTABLE(inode_out))
>  		return -EPERM;
> @@ -2013,14 +2026,6 @@ loff_t do_clone_file_range(struct file *file_in, loff_t pos_in,
>  	if (!S_ISREG(inode_in->i_mode) || !S_ISREG(inode_out->i_mode))
>  		return -EINVAL;
>  
> -	/*
> -	 * FICLONE/FICLONERANGE ioctls enforce that src and dest files are on
> -	 * the same mount. Practically, they only need to be on the same file
> -	 * system.
> -	 */
> -	if (inode_in->i_sb != inode_out->i_sb)
> -		return -EXDEV;
> -
>  	if (!(file_in->f_mode & FMODE_READ) ||
>  	    !(file_out->f_mode & FMODE_WRITE) ||
>  	    (file_out->f_flags & O_APPEND))
> -- 
> 2.19.1
> 
