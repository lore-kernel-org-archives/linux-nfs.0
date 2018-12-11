Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A91DC5CFFE
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 19:19:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C90492087F
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 19:19:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="RDUY3m1f"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C90492087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726788AbeLKTTq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 14:19:46 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:35760 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726508AbeLKTTq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 14:19:46 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBBJJ3un063005;
        Tue, 11 Dec 2018 19:19:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc : subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=bNVoMqXwNkT2A12Bzht7FIuu9XxlnDNVtqrlWoQwst4=;
 b=RDUY3m1fr9OAyNHaYaMTay5OcwYTbrsvgVvOsneRMXPQkou7SjY8vNy7jOg2K3TSrRMj
 aulG3/mQ9QfizjPbm8Z9fIpX0xrcuBMaabSEM9HAzVFJGgxIeYHVx2zfvR8smLGQ5mld
 dZ7Abx70wEAn0Pi62q71PstTd3JxMg5eWwDM5WXgDAJW6I88ODOGx8Mxb673dRYH9JOm
 J0JM5IIz9XbHZlzFoIOY9u15YUsesEOs+qbBxRv9qqoCFqAAtHukXbqgQIxqYukVS41w
 jOD/hedbMzNRf7iYG+pqDGWz7eeRgYXttkrWsKqsGo7Zwnj8bUyCm5hfqxKkVaqLP9yi KA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2130.oracle.com with ESMTP id 2p83fe60wb-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 11 Dec 2018 19:19:44 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBBJJhf2006510
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 11 Dec 2018 19:19:43 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBBJJgpW011759;
        Tue, 11 Dec 2018 19:19:42 GMT
Received: from mbp2018.cdmnet.org (/82.27.120.181)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 11 Dec 2018 11:19:42 -0800
Cc:     Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 18/24] NFS: Fix NFSv4 symbolic trace point output
To:     Chuck Lever <chuck.lever@oracle.com>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
 <20181210163055.4198.68306.stgit@manet.1015granger.net>
 <632f5635-4c37-16ae-cdd0-65679d21c9ec@oracle.com>
From:   Calum Mackay <calum.mackay@oracle.com>
Organization: Oracle
Message-ID: <1f9f5d63-6168-db5a-3ba3-9ed479eef505@oracle.com>
Date:   Tue, 11 Dec 2018 19:19:38 +0000
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:65.0)
 Gecko/20100101 Thunderbird/65.0a1
MIME-Version: 1.0
In-Reply-To: <632f5635-4c37-16ae-cdd0-65679d21c9ec@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9103 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=790
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812110171
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

hi Chuck,

On 10/12/2018 4:30 pm, Chuck Lever wrote:
> These symbolic values were not being displayed in string form.
> TRACE_ENUM_DEFINE was missing in many cases.

-> TRACE_DEFINE_ENUM

cheers,
calum.
