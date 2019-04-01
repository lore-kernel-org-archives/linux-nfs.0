Return-Path: <SRS0=xBSR=SD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FAKE_REPLY_C,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C873C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Apr 2019 06:36:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DE59B20896
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Apr 2019 06:36:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="toZNPcGl"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727377AbfDAGgo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 1 Apr 2019 02:36:44 -0400
Received: from aserp2130.oracle.com ([141.146.126.79]:53190 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727076AbfDAGgo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Apr 2019 02:36:44 -0400
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x316T30o152900;
        Mon, 1 Apr 2019 06:36:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type : in-reply-to;
 s=corp-2018-07-02; bh=hQITIU83Ky5O5zvQyjzbVhK7av+LdkkOo6UJu1jc148=;
 b=toZNPcGlmVECMReC2CzXdfIx4q6y5gV+X8By9vqe8uWKd9zymSKijUNgSW7UybCZrRbR
 jWIhbyu9PzjLMId8DanDDJ+ZzlBIt01ljPOCtwzknKZGhB6vt3Oc9MTurIh4Zpt2kNDb
 JZBUjhl6Bia4F8Q0MWt+NfIeb11Dh4OxWa3Sdm17+08jRpVsIm9KmySTyemIXUSi/TSw
 fq4oHtYivbQNeP4wXMLqC51RBcKoDU+5uWV8OYnC0kTaJK3fZbpVdRn92wzudWtMBRuB
 MlN18WDDjT1fYZiq42Hvnrk2nnljVPr2/a8cOfhmqrUXV/sWe6fKE1yPIyNh8lE4LpfF Hg== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2130.oracle.com with ESMTP id 2rhwycw2a7-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 01 Apr 2019 06:36:39 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x316ablx008960
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 1 Apr 2019 06:36:38 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x316ab9u032138;
        Mon, 1 Apr 2019 06:36:37 GMT
Received: from kadam (/41.202.241.37)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sun, 31 Mar 2019 23:36:36 -0700
Date:   Mon, 1 Apr 2019 09:36:27 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     kbuild@01.org, Trond Myklebust <trondmy@gmail.com>
Cc:     kbuild-all@01.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 19/25] NFS: Replace custom error reporting mechanism with
 generic one
Message-ID: <20190401063627.GW32613@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328205239.29674-20-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9213 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=877 adultscore=0
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
fs/nfs/write.c:1849 nfs_commit_release_pages() error: we previously assumed 'req->wb_page' could be null (see line 1840)
fs/nfs/write.c:1850 nfs_commit_release_pages() warn: variable dereferenced before check 'req->wb_page' (see line 1849)


# https://github.com/0day-ci/linux/commit/2f2cfd52810bf732da40334bf590dbadda75d6cf
git remote add linux-review https://github.com/0day-ci/linux
git remote update linux-review
git checkout 2f2cfd52810bf732da40334bf590dbadda75d6cf
vim +1849 fs/nfs/write.c

c9d8f89d9 Trond Myklebust 2008-04-15  1829  
f453a54a0 Fred Isaman     2012-04-20  1830  static void nfs_commit_release_pages(struct nfs_commit_data *data)
c9d8f89d9 Trond Myklebust 2008-04-15  1831  {
c9d8f89d9 Trond Myklebust 2008-04-15  1832  	struct nfs_page	*req;
c9d8f89d9 Trond Myklebust 2008-04-15  1833  	int status = data->task.tk_status;
f453a54a0 Fred Isaman     2012-04-20  1834  	struct nfs_commit_info cinfo;
353db7966 NeilBrown       2014-09-24  1835  	struct nfs_server *nfss;
788e7a89a Trond Myklebust 2006-03-20  1836  
^1da177e4 Linus Torvalds  2005-04-16  1837  	while (!list_empty(&data->pages)) {
^1da177e4 Linus Torvalds  2005-04-16  1838  		req = nfs_list_entry(data->pages.next);
^1da177e4 Linus Torvalds  2005-04-16  1839  		nfs_list_remove_request(req);
67911c8f1 Anna Schumaker  2016-01-19 @1840  		if (req->wb_page)
                                                            ^^^^^^^^^^^^

d6d6dc7cd Fred Isaman     2012-03-08  1841  			nfs_clear_page_commit(req->wb_page);
^1da177e4 Linus Torvalds  2005-04-16  1842  
1e8968c5b Niels de Vos    2013-12-17  1843  		dprintk("NFS:       commit (%s/%llu %d@%lld)",
3d4ff43d8 Al Viro         2011-06-22  1844  			req->wb_context->dentry->d_sb->s_id,
2b0143b5c David Howells   2015-03-17  1845  			(unsigned long long)NFS_FILEID(d_inode(req->wb_context->dentry)),
^1da177e4 Linus Torvalds  2005-04-16  1846  			req->wb_bytes,
^1da177e4 Linus Torvalds  2005-04-16  1847  			(long long)req_offset(req));
c9d8f89d9 Trond Myklebust 2008-04-15  1848  		if (status < 0) {
2f2cfd528 Trond Myklebust 2019-03-28 @1849  			nfs_mapping_set_error(req->wb_page, status);
                                                                                      ^^^^^^^^^^^^
Dereferenced inside function probably?

38a33101d Kinglong Mee    2017-03-09 @1850  			if (req->wb_page)
                                                                    ^^^^^^^^^^^^
Too late.

^1da177e4 Linus Torvalds  2005-04-16  1851  				nfs_inode_remove_request(req);
ddeaa6379 Joe Perches     2016-10-15  1852  			dprintk_cont(", error = %d\n", status);
^1da177e4 Linus Torvalds  2005-04-16  1853  			goto next;
^1da177e4 Linus Torvalds  2005-04-16  1854  		}
^1da177e4 Linus Torvalds  2005-04-16  1855  

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
