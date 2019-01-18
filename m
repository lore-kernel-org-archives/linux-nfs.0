Return-Path: <SRS0=ZX+r=P2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD033C43387
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Jan 2019 15:42:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7EBFF2087E
	for <linux-nfs@archiver.kernel.org>; Fri, 18 Jan 2019 15:42:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="1eND8r0x"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727324AbfARPmQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 18 Jan 2019 10:42:16 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:51464 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727241AbfARPmQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2019 10:42:16 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0IFee6X120004;
        Fri, 18 Jan 2019 15:42:03 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=gXv8tBxBGzf89HNz9TECv5opstSTMFKDTGjMlpLAgpM=;
 b=1eND8r0x9uMLZUIoS3SgnC8nceV/y4KNoQEqg2ey1bbupIjKlErZAoRUr4ON5/H1d6XX
 PYa0aHoP74gYVrJRK/mGHDMHuBugloKlbHDMm3PC4O5mrk7hBcqnCPdHmh1gjSA4GLh8
 sYCJZNqeRQBsbLHgqInVby6+UMYWIQG4M6fUXH9jh4ZWGpeMTCLRmAebzWE0wBg5uuWn
 z9JCbgiMxlHYaG0N1AUVd1ZRMiNDkQaftV4GrjF/blj7uWJRyq8cvdeQxNfbm9qYAYsx
 Du8SdKQgBbTGX8AhuoPW+SJ3ql7Is6ghgbhoEu5uaJkov6CQMzercbDf9up78Zei+cda QQ== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2pybjsp9hq-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 18 Jan 2019 15:42:03 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0IFg2Yh020982
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 18 Jan 2019 15:42:02 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0IFg28a013491;
        Fri, 18 Jan 2019 15:42:02 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 18 Jan 2019 07:42:02 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH RFC] SUNRPC: Add SPDX IDs to some net/sunrpc/auth_gss/
 files
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190118072942.GA22125@infradead.org>
Date:   Fri, 18 Jan 2019 10:42:00 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kstewart@linuxfoundation.org, simo@redhat.com
Content-Transfer-Encoding: 7bit
Message-Id: <EDB5039C-2DD9-4134-A447-040840B34D85@oracle.com>
References: <20190117220233.13961.53423.stgit@manet.1015granger.net>
 <20190118072942.GA22125@infradead.org>
To:     Christoph Hellwig <hch@infradead.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9140 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=850
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901180112
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 18, 2019, at 2:29 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> The general idea is to replace the existing boilerplate with just the tag,
> not add it on top.  Altough someone will have to conform how that works
> with the BSD license.

The online SPDX license text matches the license text in these particular
files. Can I therefore assume I have permission to remove the boilerplate
in this patch?

--
Chuck Lever



