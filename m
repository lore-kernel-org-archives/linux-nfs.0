Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FEABC282CB
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:17:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 008C82082E
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 14:17:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="e0ZXkivT"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728525AbfBDORK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 09:17:10 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:45682 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725980AbfBDORK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2019 09:17:10 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x14E928F028308;
        Mon, 4 Feb 2019 14:16:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=svXNWI0UNKrFHhtxukSD8YRq6HN7PJSSSlxk48z5xqg=;
 b=e0ZXkivTIknYb7PEtDaEMSpwBG2YIgmAwTC12d9qZBByNv+ydX18XE9QvakQpP5+3Pvr
 JvnI5g2VlR6mLM3qApCOBJpAn9seh531vrBB06ZMEzsHkg/J8d0QsoukUae2m2sdPpN0
 kU3S7Z37/TwdlqywQB9DwOlFrYwOAtjnZESVwGDA6Eip/9KLPnBKnH6nMwJa6O7FHAju
 gIj8ZmbODTrrUE1tbRGfs0WC75eRL3arhm1eqDLiRi5UaHI+Q40AwHTpg+NvXy7RpCaX
 FJ4dgHRbj1mf5+Zq0aD3rYjhu29BnLPOV6zoi9VYKIm77Q6rZgpVdFGGp7U1PJZPLcf3 Ng== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2qd97enbqw-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 04 Feb 2019 14:16:57 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x14EGuQ0021263
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 4 Feb 2019 14:16:57 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x14EGuFS024519;
        Mon, 4 Feb 2019 14:16:56 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 04 Feb 2019 14:16:56 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190204075336.GA28337@infradead.org>
Date:   Mon, 4 Feb 2019 09:16:54 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>, simo@redhat.com
Content-Transfer-Encoding: 7bit
Message-Id: <0EB44600-7CF7-45C3-A1AB-75B76EFA1546@oracle.com>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195747.11389.75164.stgit@manet.1015granger.net>
 <20190202170258.GA14074@infradead.org>
 <52468C38-9E9C-49A7-B44B-2BE302A33145@oracle.com>
 <20190204075336.GA28337@infradead.org>
To:     Christoph Hellwig <hch@infradead.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9156 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902040113
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 4, 2019, at 2:53 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Sat, Feb 02, 2019 at 05:49:35PM -0500, Chuck Lever wrote:
>>>> Byte-swapping causes a CPU pipeline bubble on some processors. When
>>>> a decoder is comparing an on-the-wire value for equality, byte-
>>>> swapping can be avoided by comparing it directly to a pre-byte-
>>>> swapped constant value.
>>> 
>>> Which ones?
>> 
>> I assume you mean on which processors have I observed CPU cycle
>> spikes around bswap instructions.
> 
> Yes.
> 
>> I've seen this behavior only
>> on Intel processors of various families.
> 
> Interesting. In general we should not do separate byte swap instructions
> on x86, as MOVBE can be used to do a load or store with an included
> byteswap, and I thought the whole point for that was that they could
> be handled in the same cycle.
> 
> In fact https://www.agner.org/optimize/instruction_tables.pdf
> says that movbe is generally a single cycle instruction.
> 
>> Would you prefer a different justification for this clean-up?
> 
> I don't really care about the cleanup, it is just that the explanation
> goes against conventional wisdom, which is why I was a little surpised.
> 
> And that is not just the cycles, but also as Trond pointed out
> that the Linux byte swapping macro on constants should usually be
> optimized away at compile time anyway.

They are. The problem is that we are byte-swapping the incoming wire
data and then comparing to CPU-endian constants in some hot paths.
It's better to leave the incoming data alone and compare to a pre-
byte-swapped constant. This patch adds some of these constants that
were missing, in preparation for fixing the hot paths.

That is apparently not clear from the patch description, so I will
endeavor to improve it.


--
Chuck Lever



