Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D51ADC282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:56:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A4BF32082F
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:56:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WNFHdfBA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729383AbfBDO4a (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 09:56:30 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:41684 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729692AbfBDO43 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2019 09:56:29 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x14Eu1PR072940;
        Mon, 4 Feb 2019 14:56:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=dxDhnMqB+vmDNIVxJmbfwRHAsvh4IvpZk7bgzayrbMo=;
 b=WNFHdfBAgGusFNfeQdrq2Kl4BDco3alfiTZ1E6AzaIY5sNw3BzuHqVhzMvFpgxBrX0Lm
 9Js+EA2d6j0dG7XwEVVSIy1swm60KPMU5guwlwF2uFGbRTBaKzzRl7KEZFnI3wMQsbXZ
 9EZM78Wh3yNZqLkMQBO8wXZJ8n5qRhVdOZ6C3Ta/ZAYPiMGGMVX79QgS4j0af+0jtqte
 kxmyDbvgu5RrZssnJF5izSiuHQXWRGzGUG17kvdFt2TAwG57CE4JmhF7WR6krsa7HHT4
 ACp6zzjO9dGgApVk332jnr5LMJt/rI6Oq31dixk6WvtGAc8fpsUnkdXggUk0gYqHBrG2 ww== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2qd97enk1e-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 04 Feb 2019 14:56:22 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x14EuM8u011321
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 4 Feb 2019 14:56:22 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x14EuLbo018084;
        Mon, 4 Feb 2019 14:56:21 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 04 Feb 2019 14:56:21 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190204143239.GA15081@infradead.org>
Date:   Mon, 4 Feb 2019 09:56:20 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>, simo@redhat.com
Content-Transfer-Encoding: 7bit
Message-Id: <7532348A-4059-4435-9D87-291902148681@oracle.com>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195747.11389.75164.stgit@manet.1015granger.net>
 <20190202170258.GA14074@infradead.org>
 <52468C38-9E9C-49A7-B44B-2BE302A33145@oracle.com>
 <20190204075336.GA28337@infradead.org>
 <0EB44600-7CF7-45C3-A1AB-75B76EFA1546@oracle.com>
 <20190204143239.GA15081@infradead.org>
To:     Christoph Hellwig <hch@infradead.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9156 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902040118
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 4, 2019, at 9:32 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Mon, Feb 04, 2019 at 09:16:54AM -0500, Chuck Lever wrote:
>> They are. The problem is that we are byte-swapping the incoming wire
>> data and then comparing to CPU-endian constants in some hot paths.
>> It's better to leave the incoming data alone and compare to a pre-
>> byte-swapped constant. This patch adds some of these constants that
>> were missing, in preparation for fixing the hot paths.
>> 
>> That is apparently not clear from the patch description, so I will
>> endeavor to improve it.
> 
> Why do we need new enums / #defines for that?
> 
> Just replace:
> 
> 	if (beXX_to_cpu(pkt->field) == SOME_CONSTANT)
> 
> with
> 
> 	if (pkt->field == cpu_to_be32(SOME_CONSTANT))
> 
> and we are done.

True.


> The latter is a pretty common pattern through the kernel.

However the pattern in the NFS server and lockd is to define a
lower-case version of the same macro that is pre-byte-swapped.
I'm attempting to follow existing precedent in this area.

We already have, for example, in various sunrpc headers:

enum rpc_accept_stat {
        RPC_SUCCESS = 0,
        RPC_PROG_UNAVAIL = 1,
        RPC_PROG_MISMATCH = 2,
  ...
};

#define rpc_success             cpu_to_be32(RPC_SUCCESS)
#define rpc_prog_unavail        cpu_to_be32(RPC_PROG_UNAVAIL)
#define rpc_prog_mismatch       cpu_to_be32(RPC_PROG_MISMATCH)

Or, for NFS:

enum nfs_stat {
   ...
   NFSERR_SHARE_DENIED = 10015,
   ...
};

#define nfserr_share_denied cpu_to_be32(NFSERR_SHARE_DENIED)

There are some missing lower-case macros, which I am trying to
add to our existing collection before I rewrite the RPC header
encoding and decoding functions. So I'm adding:

+       rpc_gss_version = cpu_to_be32(RPC_GSS_VERSION),

+       rpc_call                = cpu_to_be32(RPC_CALL),
+       rpc_reply               = cpu_to_be32(RPC_REPLY),
+
+       rpc_msg_accepted        = cpu_to_be32(RPC_MSG_ACCEPTED),
+       rpc_msg_denied          = cpu_to_be32(RPC_MSG_DENIED),

Actually since we have decided not to use enum for these, this
smaller addition can simply be squashed into the later patches,
and I can drop this patch, which was intended as a clean-up but
now appears to be unnecessary.

--
Chuck Lever



