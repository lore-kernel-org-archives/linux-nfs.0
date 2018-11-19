Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 311FBC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 17:59:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EBEC621104
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 17:59:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="q8tUJmWE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBEC621104
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731377AbeKTEXz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Nov 2018 23:23:55 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:38108 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731237AbeKTEXz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Nov 2018 23:23:55 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAJHosJH003484;
        Mon, 19 Nov 2018 17:59:03 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=tlHqtT2WOiqMkoUDkmkjJ74NxRCFeLEYv4ni7yngOc0=;
 b=q8tUJmWExh76E02rTxO0fluaMj/OVt3+STUlIJnrLuC8CNVvx1UN7Tf5yooYb7BjfhPK
 bN/7W9z6WPIFOubU1/sQSGhXk9B39IPQBkga2M1IlQDDneBEv6GOr2NZBstVJ0gEuf1t
 cPQMoQfPM4UjDLibuPp4MgQ/401fbVj9KVoZjmijsHzQmNahbu5Q9tmCG4ScH9F4EKr7
 XHvQuRT3qCrTL5sG35TXUfBWAW3fvM8x+9FFBQx4f7S+Qq8jNSL/jtr0azkgLOhHxEmi
 P3qt5JIrw6YWjADvduHiap4vgGWYR7xGvnNvUSlOcw0nI1yO3nrJKGH53r8jkI3ndcPE BQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2ntbmqfg46-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 19 Nov 2018 17:59:03 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wAJHwvsG009668
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 19 Nov 2018 17:58:57 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wAJHwvQG009764;
        Mon, 19 Nov 2018 17:58:57 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 19 Nov 2018 09:58:57 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 4/4] xprtrdma: Plant XID in on-the-wire RDMA offset
 (FRWR)
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyG26W+TjTsjpTVvF3RJOGCnD8L79dCbRqKTm5F1V3fuxw@mail.gmail.com>
Date:   Mon, 19 Nov 2018 12:58:55 -0500
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <6592845E-0136-4D42-8426-3E2A0BB5FFE7@oracle.com>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154607.10832.92558.stgit@manet.1015granger.net>
 <CAN-5tyG26W+TjTsjpTVvF3RJOGCnD8L79dCbRqKTm5F1V3fuxw@mail.gmail.com>
To:     Olga Kornievskaia <aglo@umich.edu>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9082 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=849
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811190163
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 19, 2018, at 12:47 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>=20
> On Mon, Nov 19, 2018 at 10:46 AM Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>> Place the associated RPC transaction's XID in the upper 32 bits of
>> each RDMA segment's rdma_offset field. These bits are currently
>> always zero.
>>=20
>> There are two reasons to do this:
>>=20
>> - The R_key only has 8 bits that are different from registration to
>>  registration. The XID adds more uniqueness to each RDMA segment to
>>  reduce the likelihood of a software bug on the server reading from
>>  or writing into memory it's not supposed to.
>>=20
>> - On-the-wire RDMA Read and Write operations do not otherwise carry
>>  any identifier that matches them up to an RPC. The XID in the
>>  upper 32 bits will act as an eye-catcher in network captures.
>=20
> Is this just an "eye-catcher" or do you have plans to use it in
> wireshark? If the latter, then can we really do that? while a linux
> implementation may do that, other (or even possibly future linux)
> implementation might not do this. Can we justify changing the
> wireshark logic for it?

No plans to change the wireshark RPC-over-RDMA dissector.
That would only be a valid thing to do if adding the XID
were made part of the RPC-over-RDMA protocol via an RFC.


--
Chuck Lever



