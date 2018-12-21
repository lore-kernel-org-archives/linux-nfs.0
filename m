Return-Path: <SRS0=HAHT=O6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84B9EC43387
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 09:10:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 51F17218E2
	for <linux-nfs@archiver.kernel.org>; Fri, 21 Dec 2018 09:10:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="uf+cRLc/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731368AbeLUJK6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 21 Dec 2018 04:10:58 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:34492 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725845AbeLUJK6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Dec 2018 04:10:58 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBL98w8Z011984;
        Fri, 21 Dec 2018 09:10:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=rwaRpDTpt4EdsKgtmNqDRhCSBcv+YT/v7XRZC8pBo80=;
 b=uf+cRLc/GX3zic3Vv2MqeqwxbXwzwgKTf0AjS1jmqIgnssnUEG5hDDDGSDkEA5Gyp9lc
 nhQH4ifVLLcjA1OCo2ycqkhHiM3O096kkpFnAoBIaXD+SDpuhgLJjyfSBYoUawggsDJd
 NbpuLy5eTofb5VBrp7M7nCxvanKrfc+IU7oJWW71fQh8sFt9kMWqT92MIwJFALasJVBK
 Ke/9t0Gx52ZcOGysI4Sl9evt5BkiD34HnQXIKm2ZBmU1woq2G0JoOmBelOhyuzDriC8D
 wlemNcaU+BxvI2obSWLAFpl/BwPk2nIcGg/WDTz11N7H4npe/aNM8Lqz4ZLtqcuBYmlg GQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2pf8gfn1ff-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 21 Dec 2018 09:10:31 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBL9AUqI004778
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 21 Dec 2018 09:10:30 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBL9AU5u023416;
        Fri, 21 Dec 2018 09:10:30 GMT
Received: from kadam (/197.157.0.16)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 21 Dec 2018 01:10:30 -0800
Date:   Fri, 21 Dec 2018 12:10:24 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     neilb@suse.com
Cc:     linux-nfs@vger.kernel.org
Subject: [bug report] SUNRPC: simplify auth_unix.
Message-ID: <20181221091024.GF2735@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9113 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=510
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812210074
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello NeilBrown,

This is a semi-automatic email about new static checker warnings.

The patch 394f319df78e: "SUNRPC: simplify auth_unix." from Dec 3, 
2018, leads to the following Smatch complaint:

    net/sunrpc/auth_unix.c:90 unx_match()
    warn: variable dereferenced before check 'acred->cred' (see line 87)

net/sunrpc/auth_unix.c
    86	
    87		if (!uid_eq(cred->cr_cred->fsuid, acred->cred->fsuid) || !gid_eq(cred->cr_cred->fsgid, acred->cred->fsgid))
                                                  ^^^^^^^^^^^
New dereference

    88			return 0;
    89	
    90		if (acred->cred && acred->cred->group_info != NULL)
                    ^^^^^^^^^^^
But the old code checked for NULL

    91			groups = acred->cred->group_info->ngroups;
    92		if (groups > UNX_NGROUPS)

regards,
dan carpenter
