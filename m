Return-Path: <SRS0=4jnv=OM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C5A6C04EB9
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 18:25:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5467F208A3
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Dec 2018 18:25:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="octJD3AK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5467F208A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=Oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726615AbeLCSZq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Dec 2018 13:25:46 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:46592 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726468AbeLCSZq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2018 13:25:46 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wB3IOejl007723;
        Mon, 3 Dec 2018 18:25:43 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : subject : to :
 message-id : date : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=pYfSwQr0bADeM+9mAEDfzBzXT3a+4Nf32BeQG5A7rOQ=;
 b=octJD3AKG1L1j5GlbNznrKnJ9FDSwywMKFUPl2h8pQxeCrLhBXHq2grCaHhgEQCghFJ7
 7ee8yX4X3hslXYWVfX3uBlA71jkTZudDq2q9XKi7mjtWjtWOwXVc2eguHOEY5uUvj5X8
 9mGcu2+nCuRvaianBBx/gAeDDIUJctbcgZ9UraAdJVcU7V6Wo99zdnKcwrRdDexvZFgA
 iATooqnt+MJQlhG1aOrP0fGtoAy0j3R82LS1R7ot1t4F/fafRbSI3hOrzDFOnmk6AucR
 vPyjBUyll0o59uTODqzLKAiqMcSgt8FE9Qy5dn1eQzD5YncHcdRHATwIu9Xnrhux6uez mA== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2120.oracle.com with ESMTP id 2p3j8q82u8-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 03 Dec 2018 18:25:43 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wB3IPgkE019759
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 3 Dec 2018 18:25:42 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wB3IPg8p005629;
        Mon, 3 Dec 2018 18:25:42 GMT
Received: from [10.135.188.54] (/10.135.188.54)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 03 Dec 2018 10:25:42 -0800
From:   Bill Baker <Bill.Baker@Oracle.com>
Subject: Early Announcement: Bake-a-thon for Spring 2019
To:     NFSv4 <nfsv4@ietf.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-ID: <126533ee-ff4a-e98b-559f-ced33a709bac@Oracle.com>
Date:   Mon, 3 Dec 2018 12:25:45 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.5.2
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9096 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=21 spamscore=0 mlxscore=0 mlxlogscore=839
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812030170
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


Greetings,

I am pleased to announce that Oracle will be hosting the Spring
2019 Bake-a-thon, hosted at the Oracle offices in Ann Arbor, MI.
The event will run from the morning of May 13th through noon on May
17th.

I will be handling the registration process, so please send me
your attendee list.  The event is free of charge, but only
individuals and organizations with legitimate testing interests
will be allowed to register.  Due to space limitations, we can
only accept the first 25 registrants.

The Oracle offices are located at:

777 E. Eisenhower Pkwy, Ste. 950
Ann Arbor, MI 48108

There are several decent and reasonably priced hotels just
east of Boardwalk and south of Eisenhower.  It is an easy walk from
these to the Oracle office, but the building also has plenty of free
ground parking.

We look forward to seeing you at Bake-a-thon!

-- 
Bill Baker - Oracle Linux NFS development
