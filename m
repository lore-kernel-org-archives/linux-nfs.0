Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:20827 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933245AbcFMAeo convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Jun 2016 20:34:44 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5D0Yb45020032
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jun 2016 20:34:43 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23getk2tb2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jun 2016 20:34:43 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Sun, 12 Jun 2016 18:34:42 -0600
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 1C8283E4001C
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jun 2016 18:34:39 -0600 (MDT)
Received: from b03ledav001.gho.boulder.ibm.com (b03ledav001.gho.boulder.ibm.com [9.17.130.232])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5D0YdtE42074254
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jun 2016 17:34:39 -0700
Received: from b03ledav001.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id EDD376E038
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jun 2016 18:34:38 -0600 (MDT)
Received: from d50lp03.ny.us.ibm.com (unknown [146.89.104.211])
	by b03ledav001.gho.boulder.ibm.com (Postfix) with ESMTPS id B95B16E035
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jun 2016 18:34:38 -0600 (MDT)
Received: from localhost
	by d50lp03.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Sun, 12 Jun 2016 20:34:38 -0400
Received: from /spool/local
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Mon, 13 Jun 2016 00:34:35 -0000
In-Reply-To: <OFAE63B935.50A753D1-ON88257FD0.00812E5D-88257FD0.0081788A@LocalDomain>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, "Srikanth Srinivasan" <ssrikanth@in.ibm.com>,
        "Trond Myklebust" <trond.myklebust@primarydata.com>,
        "Venkateswara R Puvvada" <vpuvvada@in.ibm.com>
Subject: Re: NFS fixes
From: "Marc Eshel" <eshel@us.ibm.com>
Date: Sun, 12 Jun 2016 17:34:32 -0700
References: <OF9C78122D.D4F282BF-ON88257FD0.00686038-88257FD0.006E09F0@LocalDomain>
 <OFAE63B935.50A753D1-ON88257FD0.00812E5D-88257FD0.0081788A@LocalDomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Message-Id: <OF4D8DDA37.ED72F2E9-ON88257FD1.00031E93-88257FD1.0003298D@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We are seeing a data corruption when putting very high load on the NFS V3 
client reading multi gigabyte files in parallel. The check-sum on the 
files is showing the corruption, and looking at the data we see data that 
in one block that belongs in another block but it is not the full block. 
The test is done on multiple set of hardware using different type of 
server including kNFS and Ganesha servers with EXT3 or GPFS file system. 
The only common part in all test are NFSv3 client on REHL7.0, 7.1, 7.2.

The question is there anything up stream that might fix data corruption by 
the NFSv3 client, oo do we know if this problem might have been reported 
by other users.

The only fix that I see that might be related is attached, can this 
explain a data corruption?

Thanks, Marc. 


Author: Trond Myklebust <trond.myklebust@primarydata.com>
Date:   Mon Aug 17 12:57:07 2015 -0500

    NFS: nfs_set_pgio_error sometimes misses errors
 
    We should ensure that we always set the pgio_header's error field
    if a READ or WRITE RPC call returns an error. The current code depends
    on 'hdr->good_bytes' always being initialised to a large value, which
    is not always done correctly by callers.
    When this happens, applications may end up missing important errors.
 
    Cc: stable@vger.kernel.org
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 4984bbe..7c5718b 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -77,8 +77,8 @@ EXPORT_SYMBOL_GPL(nfs_pgheader_init);
 void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t 
pos)
 {
        spin_lock(&hdr->lock);
-       if (pos < hdr->io_start + hdr->good_bytes) {
-               set_bit(NFS_IOHDR_ERROR, &hdr->flags);
+       if (!test_and_set_bit(NFS_IOHDR_ERROR, &hdr->flags)
+           || pos < hdr->io_start + hdr->good_bytes) {
                clear_bit(NFS_IOHDR_EOF, &hdr->flags);
                hdr->good_bytes = pos - hdr->io_start;

\

