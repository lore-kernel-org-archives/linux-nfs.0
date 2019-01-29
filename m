Return-Path: <SRS0=GD9Z=QF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87FC4C169C4
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 17:03:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 52A042087F
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 17:03:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="a6udmXYI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727100AbfA2RDN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Jan 2019 12:03:13 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:56368 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726374AbfA2RDN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jan 2019 12:03:13 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0TGwrvQ033478;
        Tue, 29 Jan 2019 17:03:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : content-type :
 content-transfer-encoding : mime-version : subject : message-id : date :
 cc : to; s=corp-2018-07-02;
 bh=Ai5aHolrsSdV1MB4rMjLCYEhQ+QNuNXBPBMT088yGNo=;
 b=a6udmXYID5yL+gaZgiDiPHx8qVTdgR8UqshYZH2qlmjxg+3FSTwulJoa/2QDo2FqSFyc
 jL5Vd7ZkZaYTqYxsfrMWRG7r34K70fDeeUu+Mz1QQMv42/4hZOxyVrHLfLxxAKQxjGB/
 pe+PE8wUKwC/mqZjIusMXQ/sRroWbUIs5h6YlGTRnP34SsejTE0IdPMqJFxX1shdo0fh
 ijQvXYhIN7eD89apqp+3rzxMxn8OsEfTzF4VOlgCZn5GVFuk7Lad5ZihmCPXiboa4/1U
 n+4FJiXron3ptPxeayu1bF2ataUh6b7dt9o0IRbWuV573RCN2mV7XNWDqxLg5zJrMo4D jA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by aserp2130.oracle.com with ESMTP id 2q8d2e5x37-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 29 Jan 2019 17:03:10 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0TH38v6011165
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 29 Jan 2019 17:03:09 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0TH38qf012752;
        Tue, 29 Jan 2019 17:03:08 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 29 Jan 2019 09:03:08 -0800
From:   Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: [LSF/MM TOPIC] NFS topics
Message-Id: <1E8A9D5C-1893-4D5B-B72E-9C18254B90B4@oracle.com>
Date:   Tue, 29 Jan 2019 12:03:07 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
To:     lsf-pc@lists.linux-foundation.org
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9150 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901290127
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Here are a few ongoing problem areas where I feel it would be
useful to have a group conversation. These are not plenary topics
by any means, but might be interesting as part of a BoF or break-
out session for attendees interested in network file systems.

- NFS performance
Identify common goals, see if there's low-hanging fruit. There are
common issues for Linux's remote filesystem implementations related
to memory allocation, scheduler behavior, and network APIs that would
be useful to discuss. How do we plan to leverage persistent and
storage class memory? What kind of continuous performance engineering
is going on?


- Recovery after temporary or permanent NFS server outages
We discussed this during last year's LSF but the conversation is
not finished. Jeff's writeback error reporting work enables the NFS
client to recover from server outages the same way that local
filesystems might recover from a failed disk. We need the NFS client
to behave better in these scenarios. Indeed, container environments
need this kind of recovery to reduce friction between tenants that
share NFS resources.


- Kernel DNS service
NFSv4 referrals can return a list of server hostnames, or hostnames
that resolve to multiple IP addresses. Our remote filesystem client
implementations handle only a single address in these cases, and that
limits the ability to select the best network path to the server.


--
Chuck Lever



