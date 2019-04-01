Return-Path: <SRS0=xBSR=SD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FAKE_REPLY_C,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44DF4C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Apr 2019 06:38:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 14A4120896
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Apr 2019 06:38:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="1yDHYw1D"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727447AbfDAGiL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 1 Apr 2019 02:38:11 -0400
Received: from userp2130.oracle.com ([156.151.31.86]:34226 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726836AbfDAGiL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Apr 2019 02:38:11 -0400
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x316T3tq150146;
        Mon, 1 Apr 2019 06:38:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type : in-reply-to;
 s=corp-2018-07-02; bh=XIQraBu6zIwuYBg65i4rz66WsySvtHSrSJLCcPnyiN0=;
 b=1yDHYw1DJcIyMn2XfqzWVk4GfP/SEI7ntnrTNjkvN2I90WWXNFSizUiYkxGZBCeSI0FK
 kCRkm/A3hhp4ezxzgDIiMWdjflUKLHu+/tvwuzB1kKwI196C6pdjJVULL/NVBipCTBKG
 zDoDASgiXzrZNFlF5yqZzXnXF/Yhc+7en0HPxqlWKhxur+EyiLgmNGXQBUekuhQSYVFH
 +uMn6ZYRJN+P5GZ9p0iVPN5PVygBEGDA0iEExXFdMeKNvmgBXZFOqBhdentjv4GRFqIp
 wlCUA27AzaJpiD6scMiRN/qA9ewN+9KVAXN1Cw1KBBOZQHGyvk7LfQmLA9hj3YiXuSTr ig== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2rhyvsvxfw-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 01 Apr 2019 06:38:08 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x316c2tC011061
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 1 Apr 2019 06:38:02 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x316c2Ft000343;
        Mon, 1 Apr 2019 06:38:02 GMT
Received: from kadam (/41.202.241.37)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 31 Mar 2019 23:38:01 -0700
Date:   Mon, 1 Apr 2019 09:37:54 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     kbuild@01.org, Trond Myklebust <trondmy@gmail.com>
Cc:     kbuild-all@01.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 25/25] NFS: Remove redundant open context from nfs_page
Message-ID: <20190401063753.GX32613@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328205239.29674-26-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9213 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904010048
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Trond,

url:    https://github.com/0day-ci/linux/commits/Trond-Myklebust/Fix-up-soft-mounts-for-NFSv4-x/20190331-130454
base:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git linux-next

New smatch warnings:
fs/nfs/pagelist.c:423 nfs_clear_request() warn: variable dereferenced before check 'l_ctx' (see line 417)

# https://github.com/0day-ci/linux/commit/1f204cd821631257d43efaaf86b8d1541f818585
git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 1f204cd821631257d43efaaf86b8d1541f818585
vim +/l_ctx +423 fs/nfs/pagelist.c

^1da177e Linus Torvalds      2005-04-16  405  
4d65c520 Trond Myklebust     2011-03-25  406  /*
^1da177e Linus Torvalds      2005-04-16  407   * nfs_clear_request - Free up all resources allocated to the request
^1da177e Linus Torvalds      2005-04-16  408   * @req:
^1da177e Linus Torvalds      2005-04-16  409   *
bb6fbc45 Trond Myklebust     2010-03-11  410   * Release page and open context resources associated with a read/write
bb6fbc45 Trond Myklebust     2010-03-11  411   * request after it has completed.
^1da177e Linus Torvalds      2005-04-16  412   */
4d65c520 Trond Myklebust     2011-03-25  413  static void nfs_clear_request(struct nfs_page *req)
^1da177e Linus Torvalds      2005-04-16  414  {
cd52ed35 Trond Myklebust     2006-03-20  415  	struct page *page = req->wb_page;
f11ac8db Trond Myklebust     2010-06-25  416  	struct nfs_lock_context *l_ctx = req->wb_lock_context;
1f204cd8 Trond Myklebust     2019-03-28 @417  	struct nfs_open_context *ctx = l_ctx->open_context;
                                                                               ^^^^^^^^^^^^^^^^^^^
Dereferenced

bb6fbc45 Trond Myklebust     2010-03-11  418  
cd52ed35 Trond Myklebust     2006-03-20  419  	if (page != NULL) {
09cbfeaf Kirill A. Shutemov  2016-04-01  420  		put_page(page);
^1da177e Linus Torvalds      2005-04-16  421  		req->wb_page = NULL;
^1da177e Linus Torvalds      2005-04-16  422  	}
f11ac8db Trond Myklebust     2010-06-25 @423  	if (l_ctx != NULL) {
                                                    ^^^^^^^^^^^^^
Check

7d6ddf88 Benjamin Coddington 2017-04-11  424  		if (atomic_dec_and_test(&l_ctx->io_count)) {
723c921e Peter Zijlstra      2018-03-15  425  			wake_up_var(&l_ctx->io_count);
7d6ddf88 Benjamin Coddington 2017-04-11  426  			if (test_bit(NFS_CONTEXT_UNLOCK, &ctx->flags))
7d6ddf88 Benjamin Coddington 2017-04-11  427  				rpc_wake_up(&NFS_SERVER(d_inode(ctx->dentry))->uoc_rpcwaitq);
7d6ddf88 Benjamin Coddington 2017-04-11  428  		}
f11ac8db Trond Myklebust     2010-06-25  429  		nfs_put_lock_context(l_ctx);
f11ac8db Trond Myklebust     2010-06-25  430  		req->wb_lock_context = NULL;
f11ac8db Trond Myklebust     2010-06-25  431  	}
^1da177e Linus Torvalds      2005-04-16  432  }
^1da177e Linus Torvalds      2005-04-16  433  

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
