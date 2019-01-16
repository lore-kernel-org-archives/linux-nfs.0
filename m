Return-Path: <SRS0=vPHX=PY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 964CFC43444
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 15:24:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 65319205C9
	for <linux-nfs@archiver.kernel.org>; Wed, 16 Jan 2019 15:24:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="aZgJ0P/B"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391207AbfAPPYo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Jan 2019 10:24:44 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:57262 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2391192AbfAPPYo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jan 2019 10:24:44 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0GFCobr043143;
        Wed, 16 Jan 2019 15:24:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=2IVepsuiRhn+9aZtBtz0EBIICl7G9iSMAJ1B+oPpDD4=;
 b=aZgJ0P/BpRnjpPo9pnCcRFlYs1Y24dLjUI5uVVe6qEsnqFJ9Gkc22ZKxJc0DCnhzP00c
 IeSa/Rh0Z06TrSuzUe+gSoIeg3oB5ECaj09oO4/L7MiKVZgUFLYus4W2HKe0T2jNvrI3
 mQ2fIiilcEOR2TcPu/yAWU5gGAFl+byLDwjJnt0Hkt+NSZlsW2pTvqrZS5wPdPK+oUdG
 iyJMddB2ba86C31wRoxx8ApzSxhzVWC6URN2lCMEAilFR8/hmOo8kdAxCBdWShOEGOkR
 uVcuAYDxcb3PQiiR4GsksbUhZdPR7QwElX9RIVkXGsBrQwlYqLFCzf1Fz8vLgJxfffnp ew== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2pybjnthfv-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 16 Jan 2019 15:24:31 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0GFOP7E014634
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 16 Jan 2019 15:24:26 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0GFON5V005010;
        Wed, 16 Jan 2019 15:24:23 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 16 Jan 2019 07:24:23 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: linux-next: Fixes tag needs some work in the nfs-anna tree
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190115233811.GD26416@windriver.com>
Date:   Wed, 16 Jan 2019 10:24:20 -0500
Cc:     Takashi Iwai <tiwai@suse.de>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <0014CBAD-D596-4DA5-B6DE-61160FFD033C@oracle.com>
References: <20190116083831.256824cf@canb.auug.org.au>
 <A4B834E5-2DFD-428E-8E24-9F6F6A822B09@oracle.com>
 <s5hbm4hfu45.wl-tiwai@suse.de> <20190115233811.GD26416@windriver.com>
To:     Paul Gortmaker <paul.gortmaker@windriver.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9138 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901160125
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



On Jan 15, 2019, at 6:38 PM, Paul Gortmaker =
<paul.gortmaker@windriver.com> wrote:

> [Re: linux-next: Fixes tag needs some work in the nfs-anna tree] On =
15/01/2019 (Tue 23:12) Takashi Iwai wrote:
>=20
>> On Tue, 15 Jan 2019 22:41:21 +0100,
>> Chuck Lever wrote:
>>>=20
>>> Hi Stephen-
>>>=20
>>> On Jan 15, 2019, at 4:38 PM, Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>>>=20
>>>> [I am experimenting with checking the Fixes tags in commits in =
linux-next.
>>>> Please let me know if you think I am being too strict.]
>>>>=20
>>>> Hi all,
>>>>=20
>>>> Commit
>>>>=20
>>>> deaa5c96c2f7 ("SUNRPC: Address Kerberos performance/behavior =
regression")
>>>>=20
>>>> has problem with this Fixes tag:
>>>>=20
>>>> Fixes: 918f3c1fe83c ("SUNRPC: Improve latency for interactive ... =
")
>>>>=20
>>>> The subject should match the subject of the fixed commit.
>>>>=20
>>>> --=20
>>>> Cheers,
>>>> Stephen Rothwell
>>>=20
>>> I shortened the commit title so that the Fixes: line is shorter than =
68
>>> characters. I can leave these titles alone if that's preferred.
>>=20
>> I've sometimes shorted the subject like the above, too, as I find a
>> too long text annoying.  Maybe the partial string matching should
>> suffice, especially when it ends with "..." ?
>=20
> The problem is consistency.  Perhaps you shorten at four words.  A
> person searches with five words or 70 chars -  they never see your =
commit.
>=20
> The idea of consistency across the "Fixes:" tags is to allow a level =
of
> automated processing so that the creators of the stable releases can =
do
> a lot less manual hands-on processing.  They have enough work to do.

My impression was the scripted processing here relies on the commit
ID and not on the patch short description.

The convention of shortening the description with an ellipsis is
already widely used. I think it's reasonable to allow it.


--
Chuck Lever



