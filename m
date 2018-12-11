Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD49AC07E85
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 15:29:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 847F620849
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 15:29:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="yS0LSvyC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 847F620849
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726585AbeLKP3o (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 10:29:44 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:47612 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726417AbeLKP3n (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 10:29:43 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBBFSSV3098700;
        Tue, 11 Dec 2018 15:29:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=pYtmBI46jwz2Pu/TudI+mCgN1zlAL9s40duSy0iYjsM=;
 b=yS0LSvyC9/shMEKMksbRH3dNd0JVYHKYgbn9jedSVSXwOkA6ALtsbmqB8SAE9eiRXpRe
 ssZ4zFXIWvAOpOEJjO1lWSLVlgtxx5TCOYROH2NELPw77+Z3jBFhkMUippJmReiYkgrY
 7uCHjOhmt4dE0DIQUS82R3OUZm0pyOKoOfUsppuF+PQXLvToDGd4pYwsCrxu3NsXBf6s
 yVogrs2PWEpVekFcLVdb+yHJ8tNwl/dysQ44E1Bxl1ucKCXBy6SD3USKnLdeIa/kPn5Z
 siJHbUojq+M5IiSGpSDVbYyPCPVUC3s5HG2uZy8+5MbCXD+p3QVKzIloiEyvfUaJMgc5 Rw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2130.oracle.com with ESMTP id 2p85cu4hmx-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 11 Dec 2018 15:29:26 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBBFTKis002850
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 11 Dec 2018 15:29:20 GMT
Received: from abhmp0013.oracle.com (abhmp0013.oracle.com [141.146.116.19])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBBFTKJx029477;
        Tue, 11 Dec 2018 15:29:20 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 11 Dec 2018 07:29:20 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v3 03/24] xprtrdma: Remove support for FMR memory
 registration
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181211140208.GB30471@infradead.org>
Date:   Tue, 11 Dec 2018 10:29:10 -0500
Cc:     Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <F6E2B610-D386-45AC-B93B-906B61E22542@oracle.com>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
 <20181210162934.4198.90529.stgit@manet.1015granger.net>
 <20181211140208.GB30471@infradead.org>
To:     Christoph Hellwig <hch@infradead.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9103 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=808
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812110140
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Dec 11, 2018, at 9:02 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> Can we also kill off rpcrdma_memreg_ops now?  Indirect calls are
> suprisingly expensive, especially in our post-spectre world, and
> xprtrdma always seemed a little odd with this supper generic
> abstraction.

Yep, I'm considering replacing those indirect calls.

However, note that the RPC layer is full of them too, as is the
DMA operations that are used by xprtrdma. I'm not sure it will make
much of a difference.


--
Chuck Lever



