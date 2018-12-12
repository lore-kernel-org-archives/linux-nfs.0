Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D794C04EB8
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 11:31:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5BE2A20839
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 11:31:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BE2A20839
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727120AbeLLLbM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 06:31:12 -0500
Received: from mx2.suse.de ([195.135.220.15]:51000 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726913AbeLLLbM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 06:31:12 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 74007AEDC;
        Wed, 12 Dec 2018 11:31:09 +0000 (UTC)
From:   Luis Henriques <lhenriques@suse.com>
To:     Dave Chinner <david@fromorbit.com>
Cc:     "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org,
        olga.kornievskaia@gmail.com, linux-nfs@vger.kernel.org,
        linux-unionfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org
Subject: Re: [PATCH 04/11] vfs: add missing checks to copy_file_range
References: <20181203083416.28978-1-david@fromorbit.com>
        <20181203083416.28978-5-david@fromorbit.com>
Date:   Wed, 12 Dec 2018 11:31:23 +0000
In-Reply-To: <20181203083416.28978-5-david@fromorbit.com> (Dave Chinner's
        message of "Mon, 3 Dec 2018 19:34:09 +1100")
Message-ID: <87a7lbrng4.fsf@suse.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Dave Chinner <david@fromorbit.com> writes:

<snip>

> +int generic_copy_file_checks(struct file *file_in, loff_t pos_in,
> +			 struct file *file_out, loff_t pos_out,
> +			 size_t *req_count, unsigned int flags)
> +{

<snip>

> +	/* Don't allow overlapped copying within the same file. */
> +	if (inode_in == inode_out &&
> +	    pos_out + count > pos_in &&
> +	    pos_out < pos_in + count)
> +		return -EINVAL;

I was wondering if, with the above check, it would make sense to also
have an extra patch changing some filesystems (ceph, nfs and cifs) to
simply return -EOPNOTSUPP (instead of -EINVAL) when inode_in ==
inode_out.  Something like the diff below (not tested!).

This caught my attention when I was running the latest generic xfstests
on ceph and realised that I had some new failures due to the recently
added copy_file_range support in fsx by Darrick.  The failures were
caused by the usage of the same fd both as source and destination.

Cheers,
-- 
Luis


diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 189df668b6a0..c22ac60ec0ba 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -1904,7 +1904,7 @@ static ssize_t ceph_copy_file_range(struct file *src_file, loff_t src_off,
 	bool do_final_copy = false;
 
 	if (src_inode == dst_inode)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 	if (ceph_snap(dst_inode) != CEPH_NOSNAP)
 		return -EROFS;
 
diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 865706edb307..d4f63eae531e 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -1068,7 +1068,7 @@ ssize_t cifs_file_copychunk_range(unsigned int xid,
 	cifs_dbg(FYI, "copychunk range\n");
 
 	if (src_inode == target_inode) {
-		rc = -EINVAL;
+		rc = -EOPNOTSUPP;
 		goto out;
 	}
 
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 46d691ba04bc..910a2abade92 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -136,7 +136,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	ssize_t ret;
 
 	if (file_inode(file_in) == file_inode(file_out))
-		return -EINVAL;
+		return -EOPNOTSUPP;
 retry:
 	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
 	if (ret == -EAGAIN)
