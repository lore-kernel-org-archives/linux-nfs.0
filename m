Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79CFFC65BAF
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 16:42:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3F3162084E
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 16:42:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="zdwM7AOw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F3162084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727879AbeLLQmZ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 11:42:25 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:47200 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726358AbeLLQmZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Dec 2018 11:42:25 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBCGg6bv055254;
        Wed, 12 Dec 2018 16:42:18 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=N4DvN3NtfXP+CEykIH9aU0qS797m1T4Uci0I0+U8BxA=;
 b=zdwM7AOwEZEZvWKxx+K7SaPlFCxviOYysq5E0SZasNH884g/jbjOfgrFTxjOpA7CHLmc
 tmpq5QiRmwT2GlC7ZWlveGREmd/LFjiGkYKIsUN134GRLkRuuMQuf24xfTZYumhfk4//
 7pVfgQHi7H/t4EK8Q23UzldxYe5kE5TmGbO0GE0z8KZ4EcsBwA2sksDPUNAqK9QYlCt/
 QsVLAte2aJfX1Vs2lehlcUcpaV8SolTQVoVlFK7IDdxuUoNp2VMex25diPvRJBunrPoR
 bmsRdyypATqnhsi6Cj3Vn9+gVvC+Kgp6YPUMhLfGbVIrYVCM+FjRtU400J2JoUR6k9F1 FQ== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2130.oracle.com with ESMTP id 2pawwp2wv3-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 12 Dec 2018 16:42:18 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBCGgHu8032447
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 12 Dec 2018 16:42:17 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBCGgHMJ008786;
        Wed, 12 Dec 2018 16:42:17 GMT
Received: from localhost (/67.169.218.210)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 12 Dec 2018 08:42:16 -0800
Date:   Wed, 12 Dec 2018 08:42:15 -0800
From:   "Darrick J. Wong" <darrick.wong@oracle.com>
To:     Luis Henriques <lhenriques@suse.com>
Cc:     Dave Chinner <david@fromorbit.com>, linux-fsdevel@vger.kernel.org,
        linux-xfs@vger.kernel.org, olga.kornievskaia@gmail.com,
        linux-nfs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org
Subject: Re: [PATCH 04/11] vfs: add missing checks to copy_file_range
Message-ID: <20181212164215.GY24487@magnolia>
References: <20181203083416.28978-1-david@fromorbit.com>
 <20181203083416.28978-5-david@fromorbit.com>
 <87a7lbrng4.fsf@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87a7lbrng4.fsf@suse.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9104 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812120143
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Dec 12, 2018 at 11:31:23AM +0000, Luis Henriques wrote:
> Dave Chinner <david@fromorbit.com> writes:
> 
> <snip>
> 
> > +int generic_copy_file_checks(struct file *file_in, loff_t pos_in,
> > +			 struct file *file_out, loff_t pos_out,
> > +			 size_t *req_count, unsigned int flags)
> > +{
> 
> <snip>
> 
> > +	/* Don't allow overlapped copying within the same file. */
> > +	if (inode_in == inode_out &&
> > +	    pos_out + count > pos_in &&
> > +	    pos_out < pos_in + count)
> > +		return -EINVAL;
> 
> I was wondering if, with the above check, it would make sense to also
> have an extra patch changing some filesystems (ceph, nfs and cifs) to
> simply return -EOPNOTSUPP (instead of -EINVAL) when inode_in ==
> inode_out.  Something like the diff below (not tested!).
> 
> This caught my attention when I was running the latest generic xfstests
> on ceph and realised that I had some new failures due to the recently
> added copy_file_range support in fsx by Darrick.  The failures were
> caused by the usage of the same fd both as source and destination.

Looks reasonable to /me/, since EOPNOTSUPP currently triggers the
splice fallback.

--D

> Cheers,
> -- 
> Luis
> 
> 
> diff --git a/fs/ceph/file.c b/fs/ceph/file.c
> index 189df668b6a0..c22ac60ec0ba 100644
> --- a/fs/ceph/file.c
> +++ b/fs/ceph/file.c
> @@ -1904,7 +1904,7 @@ static ssize_t ceph_copy_file_range(struct file *src_file, loff_t src_off,
>  	bool do_final_copy = false;
>  
>  	if (src_inode == dst_inode)
> -		return -EINVAL;
> +		return -EOPNOTSUPP;
>  	if (ceph_snap(dst_inode) != CEPH_NOSNAP)
>  		return -EROFS;
>  
> diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> index 865706edb307..d4f63eae531e 100644
> --- a/fs/cifs/cifsfs.c
> +++ b/fs/cifs/cifsfs.c
> @@ -1068,7 +1068,7 @@ ssize_t cifs_file_copychunk_range(unsigned int xid,
>  	cifs_dbg(FYI, "copychunk range\n");
>  
>  	if (src_inode == target_inode) {
> -		rc = -EINVAL;
> +		rc = -EOPNOTSUPP;
>  		goto out;
>  	}
>  
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 46d691ba04bc..910a2abade92 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -136,7 +136,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
>  	ssize_t ret;
>  
>  	if (file_inode(file_in) == file_inode(file_out))
> -		return -EINVAL;
> +		return -EOPNOTSUPP;
>  retry:
>  	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
>  	if (ret == -EAGAIN)
