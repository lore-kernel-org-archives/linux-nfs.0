Return-Path: <SRS0=aDhS=QJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7E16C282D7
	for <linux-nfs@archiver.kernel.org>; Sat,  2 Feb 2019 22:49:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B1EB120855
	for <linux-nfs@archiver.kernel.org>; Sat,  2 Feb 2019 22:49:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Qv9MJb3h"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726770AbfBBWty (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 2 Feb 2019 17:49:54 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:42672 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726721AbfBBWty (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Feb 2019 17:49:54 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x12MnEoN064432;
        Sat, 2 Feb 2019 22:49:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=l75nnAArW2QDtkZzFdC5cFtjMMSgSahJrxPNCHfdRu8=;
 b=Qv9MJb3hGSUmHLUK5kYIo9P6qKAF4MGl1MBgZxacmgG3b+P/kDZtsAICOC5N3Bq/PNmg
 HT9a+HJ8LJ48DZc/DNzYItT2IvnN75/O3zYW2nsFlXZ3RUm2KP2B6wtkc/2GnXd6tRww
 atL3hzzGX6dsIIqL9VqFx1Gd3NJhTA/N9AJ8VG0PiJXzSIvXEH3aP38zrmGYNSr2N1kC
 GCh27kIjSiVXcZ1y1voW3dS+zkpdt2pil4/3Rabq1SlhwuyuECh36TLFZp5/6MrgPXX6
 bgy7j2eCdbOulPBIfre1/9QuiSQtFtjDDpwT8aI3OwKfqV7zY6nwme28g8FRea69PbB5 sw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2120.oracle.com with ESMTP id 2qd98mrt1y-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 02 Feb 2019 22:49:38 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x12MncdF002851
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Sat, 2 Feb 2019 22:49:38 GMT
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x12MnbcF024303;
        Sat, 2 Feb 2019 22:49:37 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Sat, 02 Feb 2019 22:49:37 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190202170258.GA14074@infradead.org>
Date:   Sat, 2 Feb 2019 17:49:35 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>, simo@redhat.com
Content-Transfer-Encoding: 7bit
Message-Id: <52468C38-9E9C-49A7-B44B-2BE302A33145@oracle.com>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195747.11389.75164.stgit@manet.1015granger.net>
 <20190202170258.GA14074@infradead.org>
To:     Christoph Hellwig <hch@infradead.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9155 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=919 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902020190
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 2, 2019, at 12:02 PM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Fri, Feb 01, 2019 at 02:57:47PM -0500, Chuck Lever wrote:
>> Byte-swapping causes a CPU pipeline bubble on some processors. When
>> a decoder is comparing an on-the-wire value for equality, byte-
>> swapping can be avoided by comparing it directly to a pre-byte-
>> swapped constant value.
> 
> Which ones?

I assume you mean on which processors have I observed CPU cycle
spikes around bswap instructions. I've seen this behavior only
on Intel processors of various families.

Would you prefer a different justification for this clean-up?


--
Chuck Lever



