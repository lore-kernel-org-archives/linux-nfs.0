Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62B7FC43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 17:15:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 307202073D
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 17:15:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GTKRQOhC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732449AbfACRPe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 12:15:34 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:47166 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731717AbfACRPe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Jan 2019 12:15:34 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x03HEUvo170943;
        Thu, 3 Jan 2019 17:15:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=rMQFGChcMOILTsWlWv7tMiS6TzRhfjLI+q9fKMDdqoY=;
 b=GTKRQOhCMhQHl9fclJJIWaXjFblNWrGE10hc60bghEDGeYnRqZJjYuWjObBo+FM/B+4B
 xQdAwel5eCriIWlslQc9sazy5Xod9vyolMjQTOegwibeMs+LcRprpUkkSbvfYCCojzZV
 cVfbd+rDwT3wPbxp4RQq0mZRTMOpZLOkkJ/GwAqZzdlnmmDzq+MLmiFD2e2fLACHxwnp
 tWX5mpfm1UJLyfwnAKXHo6jY1i7waBYOrMAtXpvcF/ug/kpursxjJ3dgLMsg5KXDfpEl
 ZLdHcy2P+6GC0z/Lru8puQlQj5WY8u5DmADrrIFEnEZfVDuQS+nXJcpnQ0UhdmNVPIS+ ng== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2130.oracle.com with ESMTP id 2pnxee8dh1-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 03 Jan 2019 17:15:31 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x03HFUi9020543
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 3 Jan 2019 17:15:30 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x03HFU5M015981;
        Thu, 3 Jan 2019 17:15:30 GMT
Received: from anon-dhcp-121.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 03 Jan 2019 09:15:29 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH 0/4] bugfixes for RPCSEC_GSS client support
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
Date:   Thu, 3 Jan 2019 12:15:28 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <6381D541-77F6-4F5C-809C-0292D61134E9@oracle.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
To:     Trond Myklebust <trondmy@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9124 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901030152
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 2, 2019, at 5:53 PM, Trond Myklebust <trondmy@gmail.com> wrote:
> 
> These patches address a couple of issues that are mainly affecting our
> RPCSEC_GSS client support.
> 
> Trond Myklebust (4):
>  SUNRPC: Ensure rq_bytes_sent is reset before request transmission
>  SUNRPC: Fix the RPCSEC_GSS sequence semantics after request
>    re-encoding
>  SUNRPC: Allow for some re-ordering of RPCSEC_GSS requests on the
>    server
>  SUNRPC: Ensure we respect the RPCSEC_GSS sequence number limit

I tested with only 1 and 2 applied, no change.

I tested with only 1, 2, and 3 applied, and the disconnect rate
was reduced did not go to zero, similar to my test where the
client's window was 64 and the server's was 128.


> net/sunrpc/auth_gss/auth_gss.c | 22 +++++++++++++++-------
> net/sunrpc/clnt.c              | 20 ++++++++++++--------
> net/sunrpc/xprt.c              |  7 +++++++
> 3 files changed, 34 insertions(+), 15 deletions(-)
> 
> -- 
> 2.20.1
> 

--
Chuck Lever



