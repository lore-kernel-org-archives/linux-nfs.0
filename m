Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19E4BC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 17:08:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C4E5D20834
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 17:08:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="U4w690Cy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4E5D20834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727343AbeLAESr (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 30 Nov 2018 23:18:47 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:34598 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726732AbeLAESr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2018 23:18:47 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAUH4Znq117676;
        Fri, 30 Nov 2018 17:08:46 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : content-type :
 content-transfer-encoding : mime-version : subject : message-id : date :
 cc : to; s=corp-2018-07-02;
 bh=rzpi4D+q8BJ/yiafZbv12JXHAIZEqjv00bP0KKWxZLk=;
 b=U4w690CyEJHArsvBquRp1xPC1soNKYq6OUoQugPfzegdJVdWBpJcxCTfY0tB0w65T8EW
 a32aJ7AsYd54RU6sjmd+U+v+4ekwV8640DIz5DpVIMln3japWGecJIdBeMkcnQnL4rfo
 a61co7osH3MT9QeIHpcH8g9lPFPshx7DMcwXCiVDsfN0Zc3N1s4g2Nak4zAPH19Zy7vK
 hRjTFXmCzzGPMyFWaJWlNcazZEoArN7ehyorkEZBBBlpQIGOHcBZQkhn0zCMWuoHMxef
 Jbrcrit/N1R9RPJFnW541Hbf/NjWQ9ibpTjawKbywP0Pa9wp2TZUtU9izui3rL4y0XL6 eg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2120.oracle.com with ESMTP id 2nxxkqydx1-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 17:08:46 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wAUH8jg7027969
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 17:08:45 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wAUH8jdl009106;
        Fri, 30 Nov 2018 17:08:45 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 30 Nov 2018 09:08:44 -0800
From:   Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: kerberos with v4.20-rc4 heads up
Message-Id: <028A9DC5-4136-413C-8A79-F32F997A8AB1@oracle.com>
Date:   Fri, 30 Nov 2018 12:08:43 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9093 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=772
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811300146
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi-

I'm testing krb5/krb5i/krb5p with stock v4.20-rc4 and NFS/TCP.
The workload is synthetic:

 /home/cel/bin/iozone -M -+u -i0 -i1 -s1g -r8k -t16 -c

The client is a 12-core Xeon system.


I'm seeing all kinds of symptoms:

 - memory leaks: bvec and enc_pages are leaking

 - EBADMSG is reported to user space

 - data corruption

 - connect deadlocks resulting in a mount hang

 - invalid soft IRQ receive buffer warnings


--
Chuck Lever



