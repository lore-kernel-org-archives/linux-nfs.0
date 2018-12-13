Return-Path: <SRS0=HBvY=OW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EF10C65BAE
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 14:13:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DB74A2086D
	for <linux-nfs@archiver.kernel.org>; Thu, 13 Dec 2018 14:12:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="zY1FvMSV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB74A2086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727618AbeLMOM7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 13 Dec 2018 09:12:59 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:38442 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727551AbeLMOM7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2018 09:12:59 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBDE4MZ8022060;
        Thu, 13 Dec 2018 14:12:55 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=1g/iredHfgVy0JKseQvtly5k07K5e/bbw5FgBXkQnbM=;
 b=zY1FvMSVoKB5i8bgX5oA91JUB8tVGru7IW313hFRZNn6hzHil8AEKL/e7Nd/YtPZx833
 VmzcCbx7yNOsCnn21gQLJiQjE/Z7UgUS2d6xQ9DdsRM0mJDC7ysqghpeacd/CkL8upBl
 TOHBkALgfhWaGwG2LFGlp5XzRP1mxjS02OqenyynRXEUVV4RVQ5E5Sfu40myyOaEV8dX
 Rnrzx5MOS8eNd8X6S5LIcAttIi/M7UdqF2gYwxvpKRR4i30xcCxJy3hKad24xywAZJMx
 /5slhGggsijERNBnBLUZbEQLsYBIqleZ3QEOebNPQ7S+vVv9cLiBU8J973L8cMxp/qsl IA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2pb7tf4aed-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 13 Dec 2018 14:12:55 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBDECtxF009109
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 13 Dec 2018 14:12:55 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBDECq52020814;
        Thu, 13 Dec 2018 14:12:55 GMT
Received: from kadam (/41.202.241.62)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 13 Dec 2018 06:12:52 -0800
Date:   Thu, 13 Dec 2018 17:12:41 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     trond.myklebust@hammerspace.com
Cc:     linux-nfs@vger.kernel.org
Subject: [bug report] SUNRPC: Simplify lookup code
Message-ID: <20181213141241.GA3971@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9105 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=1 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=459
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812130123
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello Trond Myklebust,

The patch 07d02a67b7fa: "SUNRPC: Simplify lookup code" from Oct 12,
2018, leads to the following static checker warning:

	net/sunrpc/auth_generic.c:248 generic_key_timeout()
	warn: 'tcred' can also be NULL

net/sunrpc/auth_generic.c
   238          /* Fast track for the normal case */
   239          if (test_bit(RPC_CRED_NOTIFY_TIMEOUT, &acred->ac_flags))
   240                  return 0;
   241  
   242          /* lookup_cred either returns a valid referenced rpc_cred, or PTR_ERR */
   243          tcred = auth->au_ops->lookup_cred(auth, acred, 0);
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   244          if (IS_ERR(tcred))
   245                  return -EACCES;
   246  
   247          /* Test for the almost error case */
   248          ret = tcred->cr_ops->crkey_timeout(tcred);
   249          if (ret != 0) {
   250                  set_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
   251                  ret = 0;
   252          } else {

The proble is nul_lookup_cred() returns get_rpccred().  It used to be
that get_rpccred() would only return NULL if we passed it a NULL but now
we return NULL if refcount_inc_not_zero() returns zero.  In other words
it maybe should be something like:

static inline
struct rpc_cred *get_rpccred(struct rpc_cred *cred)
{
	if (!cred)
		return NULL;
	if (refcount_inc_not_zero(&cred->cr_count))
		return cred;
	return -EACCES;
}

regards,
dan carpenter

