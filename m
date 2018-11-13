Return-Path: <SRS0=2Ld2=NY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7961CC43441
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Nov 2018 00:17:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2CDE0224E0
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Nov 2018 00:17:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="QaSQ6BfG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2CDE0224E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727333AbeKMKMu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 13 Nov 2018 05:12:50 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:34140 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725991AbeKMKMu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Nov 2018 05:12:50 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAD04PnW155693;
        Tue, 13 Nov 2018 00:17:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=XRejs5u3juXB0o81ok2I+VGoEIbUst6JRBSqVnKbFO8=;
 b=QaSQ6BfGrm4fKBs4SIG5llSAKI8RdiXwo67smIImsstgg1eNt8cZuQwNub6cD2OmNWVO
 Wvlgj6bTLtgepXvnqi0k8CzxlNEmZEb9eLUgBTvhgpO4NgLksERmlgLJzzTR3b+XMM+h
 6Swtk+CKnir8+Rh4bAVMzWarkmKMFWZW/cCDm4FXj0cYpqQ4Gq9QPwHq1FSulVOM9NHS
 tVOKFq+Czmy81DGjETrSnJR6hfNAlUvaKUgA1od25Z6cNJYuiyWqA62GVdT/Tx1gvjIR
 kkGk4rZuJHLnADi2PeeyOBFJYSC/3T9kO7zxbukQP9yEhkBy9K7fZQ1dIT41QnVChXqQ WQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2120.oracle.com with ESMTP id 2nnw6efkv2-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 13 Nov 2018 00:17:16 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wAD0HAKl025740
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 13 Nov 2018 00:17:10 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wAD0HAN0014146;
        Tue, 13 Nov 2018 00:17:10 GMT
Received: from [192.168.39.5] (/64.114.255.114)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 12 Nov 2018 16:17:10 -0800
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: NULL dereference in rpcauth_lookup_credcache
From:   Chuck Lever <chuck.lever@oracle.com>
X-Mailer: iPad Mail (16A404)
In-Reply-To: <b38d91d9e72944bf6908edb44ef5555eafc9ff98.camel@hammerspace.com>
Date:   Mon, 12 Nov 2018 16:17:04 -0800
Cc:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "schumakeranna@gmail.com" <schumakeranna@gmail.com>,
        "chucklever@gmail.com" <chucklever@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <BB402AA8-1F8D-4343-BA26-186DDB498E2E@oracle.com>
References: <20181108214452.GH6090@fieldses.org> <04114B00-B5A8-4F8A-B052-A266AED7725D@gmail.com> <20181110214939.GA16755@fieldses.org> <c986450a2d19fa796078ed51b9d0fb8a79eda696.camel@hammerspace.com> <20181112182454.GE16755@fieldses.org> <2e62a77385b4e5d91e2ca9128313cf817c46a1ae.camel@hammerspace.com> <20181112230149.GF16755@fieldses.org> <9d36177854ba176f46e7a9842aa0368cc508b599.camel@hammerspace.com> <8B4BB2AC-D94B-4B76-BFF2-460303C8FE9B@oracle.com> <b38d91d9e72944bf6908edb44ef5555eafc9ff98.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9075 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1811130000
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> On Nov 12, 2018, at 4:08 PM, Trond Myklebust <trondmy@hammerspace.com> wro=
te:
>=20
> On Mon, 2018-11-12 at 16:00 -0800, Chuck Lever wrote:
>>> On Nov 12, 2018, at 3:57 PM, Trond Myklebust <
>>> trondmy@hammerspace.com> wrote:
>>>=20
>>>>> On Mon, 2018-11-12 at 18:01 -0500, bfields@fieldses.org wrote:
>>>>> On Mon, Nov 12, 2018 at 09:17:16PM +0000, Trond Myklebust
>>>>> wrote:
>>>>>> On Mon, 2018-11-12 at 13:24 -0500, bfields@fieldses.org
>>>>>> wrote:
>>>>>>> On Mon, Nov 12, 2018 at 05:59:33PM +0000, Trond Myklebust
>>>>>>> wrote:
>>>>>>>> On Sat, 2018-11-10 at 16:49 -0500, Bruce Fields wrote:
>>>>>>>> Looks like it's the fault of
>>>>>>>>=20
>>>>>>>> 07d02a67b7faae "SUNRPC: Simplify lookup code"
>>>>>>>=20
>>>>>>> I'm having trouble reproducing this bug. I've tried both
>>>>>>> cthon
>>>>>>> and
>>>>>>> xfstests in a loop, so far without success (both NFSv3 and
>>>>>>> v4.1,
>>>>>>> but
>>>>>>> only sec=3Dsys). Is there anything else you're doing that I
>>>>>>> might
>>>>>>> try?
>>>>>>>=20
>>>>>>> e.g. Are you running multiple workloads in parallel?
>>>>>>> Different
>>>>>>> users?..
>>>>>>=20
>>>>>> Nothing that interesting.  Currently it's connectathon over
>>>>>> v4,
>>>>>> v3,
>>>>>> v4/krb5, v3/krb5, v4/krb5i, v4/krb5p, v4.1, v4.1/krb5, but
>>>>>> just
>>>>>> serially
>>>>>> one after the other.  Then some pynfs tests (which bypass the
>>>>>> client),
>>>>>> then xfstests over v4.2/sys.  And also a few one-off locking
>>>>>> tests of
>>>>>> my
>>>>>> own that probably aren't a factor here.
>>>>>>=20
>>>>>> (Hah, I just realized I was mounting with vers=3D4 and assuming
>>>>>> that
>>>>>> meant
>>>>>> 4.0, but actually it's changed over time depending on the
>>>>>> defaults,
>>>>>> so
>>>>>> currently those "v4" runs are actually all 4.2.  Gah.)
>>>>>=20
>>>>> Are you perhaps both using RPCSEC_GSS w/ integrity checking for
>>>>> your
>>>>> EXCHANGE_ID authentication? The client will attempt to use that
>>>>> by
>>>>> default if rpc.gssd is running.
>>>>=20
>>>> Yes, in addition to the krb5i mount I'd expect the sys/krb5/krb5p
>>>> mounts
>>>> are using krb5i for EXCHANGE_ID.
>>>>=20
>>>>> I ask because I think the issue might be with RPCSEC_GSS,
>>>>> specifically
>>>>> with the RPCSEC_GSS context destroy code, hence the 2 patches
>>>>> that
>>>>> I
>>>>> just sent out.
>>>>=20
>>>> Looks like my tests pass after applying those two patches.
>>>>=20
>>>=20
>>> Cool! Thanks for testing.
>>>=20
>>> Chuck, do you think the above might also explain your sighting of
>>> the
>>> same Oops?
>>=20
>> Could be, I don=E2=80=99t think I saw it until I started testing NFSv4.
>> I won=E2=80=99t be able to confirm that until next week.
>>=20
>=20
> OK. Either way, I know that part of the GSS code needs to be fixed in
> order to deal with the reference count being 0, so I think it is worth
> merging this patch now, and then we can see if there is more to the
> regression when you can get back to your test rig.

Sounds fine to me.


> Thanks
>  Trond
> --=20
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>=20
>=20

