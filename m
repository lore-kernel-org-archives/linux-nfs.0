Return-Path: <SRS0=j4kQ=A7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 856EDC433E5
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Jul 2020 12:02:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 653AA2070A
	for <linux-nfs@archiver.kernel.org>; Mon, 20 Jul 2020 12:02:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="j6XPYQ+C"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728761AbgGTMCL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 20 Jul 2020 08:02:11 -0400
Received: from userp2130.oracle.com ([156.151.31.86]:45252 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728058AbgGTMCJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2020 08:02:09 -0400
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.42/8.16.0.42) with SMTP id 06KBgOfD013639;
        Mon, 20 Jul 2020 12:01:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2020-01-29; bh=CsvqhpsFDg/xFVvqvQZRc0FebpxDspvp1KpFdQRqkyw=;
 b=j6XPYQ+CgaxcbVd/qcTmMejykJaPCN5iE4bxglhxsTG5zXgy13cm7xl70LztuQZdom47
 b3xMgh6nBmHvppQ2jSdFYBGRX2/Nk/fouKCyWHEKXaxYxCDgGIyfafjd4vED5a3CFGUH
 wU96ZdDNASOOjrLLetqRrQrlEAnfmcb9EZQPedD13vremWh+nvN3O9N7jOzq7JGw0Te7
 UyhByVUK47p6R1CXHCl78ULhwvIQwvCu9sVhwC6/N1VWNmemShEW8DyHHAJ/vwEbOPCM
 fGO+3QeV5tZ80dR6RDWtZxC1aWXfqNBAgNkNV1fsTi12+GQ4LBhi9HpSOh0dDu0Y7nK1 Zw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
        by userp2130.oracle.com with ESMTP id 32brgr6fvs-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
        Mon, 20 Jul 2020 12:01:59 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
        by userp3030.oracle.com (8.16.0.42/8.16.0.42) with SMTP id 06KBwxG0187955;
        Mon, 20 Jul 2020 12:01:58 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userp3030.oracle.com with ESMTP id 32da2cu49v-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 20 Jul 2020 12:01:58 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id 06KC1uO5016185;
        Mon, 20 Jul 2020 12:01:57 GMT
Received: from anon-dhcp-152.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 20 Jul 2020 12:01:56 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 13.4 \(3608.80.23.2.2\))
Subject: Re: [PATCH] nfsd: netns.h: delete a duplicated word
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20200720001403.26974-1-rdunlap@infradead.org>
Date:   Mon, 20 Jul 2020 08:01:55 -0400
Cc:     linux-kernel@vger.kernel.org, Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <1549CEA9-F6D9-47F2-B466-C1FCAF3A8464@oracle.com>
References: <20200720001403.26974-1-rdunlap@infradead.org>
To:     Randy Dunlap <rdunlap@infradead.org>
X-Mailer: Apple Mail (2.3608.80.23.2.2)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9687 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0 bulkscore=0
 suspectscore=0 spamscore=0 phishscore=0 mlxscore=0 adultscore=0
 mlxlogscore=999 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.12.0-2006250000 definitions=main-2007200083
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9687 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 malwarescore=0 bulkscore=0 spamscore=0
 impostorscore=0 suspectscore=0 adultscore=0 clxscore=1015 mlxlogscore=999
 priorityscore=1501 phishscore=0 lowpriorityscore=0 mlxscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.12.0-2006250000
 definitions=main-2007200082
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jul 19, 2020, at 8:14 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> 
> Drop the repeated word "the" in a comment.
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: Chuck Lever <chuck.lever@oracle.com>
> Cc: linux-nfs@vger.kernel.org

Acked-by: Chuck Lever <chuck.lever@oracle.com>


> ---
> fs/nfsd/netns.h |    2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- linux-next-20200717.orig/fs/nfsd/netns.h
> +++ linux-next-20200717/fs/nfsd/netns.h
> @@ -171,7 +171,7 @@ struct nfsd_net {
> 	unsigned int             longest_chain_cachesize;
> 
> 	struct shrinker		nfsd_reply_cache_shrinker;
> -	/* utsname taken from the the process that starts the server */
> +	/* utsname taken from the process that starts the server */
> 	char			nfsd_name[UNX_MAXNODENAME+1];
> };
> 

--
Chuck Lever



