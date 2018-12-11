Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F290C5CFFE
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 15:30:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C6E0D20672
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 15:30:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ui3xXhFk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6E0D20672
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726916AbeLKPaw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 10:30:52 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:48818 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726417AbeLKPav (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 10:30:51 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBBFSTnl098726;
        Tue, 11 Dec 2018 15:30:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=dIq1VQ+LxT8riazWnuYugIHf6fGfMCwzGRVEAc2qezI=;
 b=ui3xXhFkuSrI2z+7C+0bPpO4ciR2LkODYhRcSm+K4AI5R7X//7uozM+ErIf2yJMuPKs5
 o5FDmvEQS1hHLvYp/KIxtNzLDjxA/gyuOlAdag5yympxHBcbl5AXu2YDt4BfENfSrIZN
 NIPlstSODmBE8pp9emhHaJr8HYx1kYUdfubAPabbqYHZQNx4nrt2tzSUoBT6751S0YQP
 4NdJI6JmpOpVcbR8ym/Jy+D6BivlFJdRtAWqRZbCXRFXdHox32ZU++nCKrDa+jpM0NFi
 mjBjSsvIXaSJUOSpTaEhhSCE65WIDh2jPugQXZQNQSzlLwEZhJ+QxBL06t7qZSYgiYzL uA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2p85cu4hwq-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 11 Dec 2018 15:30:31 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBBFUQHg027585
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 11 Dec 2018 15:30:26 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBBFUPQO013247;
        Tue, 11 Dec 2018 15:30:26 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 11 Dec 2018 07:30:25 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v3 05/24] xprtrdma: Reduce max_frwr_depth
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181211140242.GC30471@infradead.org>
Date:   Tue, 11 Dec 2018 10:30:24 -0500
Cc:     Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <69E69F06-4B3C-4C91-9412-3E7FE14C2ADA@oracle.com>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
 <20181210162945.4198.24714.stgit@manet.1015granger.net>
 <20181211140242.GC30471@infradead.org>
To:     Christoph Hellwig <hch@infradead.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9103 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=843
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812110140
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 11, 2018, at 9:02 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Mon, Dec 10, 2018 at 11:29:45AM -0500, Chuck Lever wrote:
>> Some devices advertise a large max_fast_reg_page_list_len
>> capability, but perform optimally when MRs are significantly smaller
>> than that depth -- probably when the MR itself is no larger than a
>> page.
>> 
>> By default, the RDMA R/W core API uses max_sge_rd as the maximum
>> page depth for MRs. For some devices, the value of max_sge_rd is
>> 1, which is also not optimal. Thus, when max_sge_rd is larger than
>> 1, use that value. Otherwise use the value of the
>> max_fast_reg_page_list_len attribute.
>> 
>> I've tested this with a couple of devices, and it reproducibly
>> improves the throughput of large I/Os by several percent.
> 
> Can you list which devices for reference in the changelog?

I have only three devices here. I can't make an exhaustive list.

Besides, this is exactly how rdma_rw works. I thought this was
common knowledge.

--
Chuck Lever



