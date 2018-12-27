Return-Path: <SRS0=fblw=PE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ABA94C43387
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Dec 2018 22:34:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6CA392148E
	for <linux-nfs@archiver.kernel.org>; Thu, 27 Dec 2018 22:34:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="YV83CEd9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730058AbeL0Wet (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 27 Dec 2018 17:34:49 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:39454 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729908AbeL0Wet (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Dec 2018 17:34:49 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBRMTu8Z075620;
        Thu, 27 Dec 2018 22:34:46 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=tSbbs4sazqv5WJ/mlvGMZYdkey3cKT9s4DZGHiDo6dQ=;
 b=YV83CEd9OKzqh5gwc55YDBcQcR6PznVSmYA9UUHlGm2Ct6kAQT7kEnYJ4aWipeKH2HsS
 pSME7KkYA9sJAt21E25l0iKCYWEla8XvPmIWXywacrVqOtKi+allzTBVeoxb7AObj53U
 ncFZ5zgc1OOt21emITTxF/SIMYH+g+RvPRuS9yIKm5w5GEtxmz3URcMX3ZAaREbjGbtJ
 DY+pDGSSqgscDEWCx5QBUBX1HdPJXYpy7+ay0asf8WXLa3b5GFh2J3GXb0e1MyCDUsks
 unVA2hoHdPiOiLJ3KIMlIh/Y2nf7Y8qUy+vxbU0z9kWBsr5C1u3aJ0e7CbL9wQeHW86M ow== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2phcptxsfc-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 27 Dec 2018 22:34:46 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBRMYjde012462
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Thu, 27 Dec 2018 22:34:46 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wBRMYjLA025768;
        Thu, 27 Dec 2018 22:34:45 GMT
Received: from [192.168.1.184] (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 27 Dec 2018 14:34:45 -0800
Content-Type: text/plain;
        charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
From:   Chuck Lever <chuck.lever@oracle.com>
X-Mailer: iPad Mail (16C50)
In-Reply-To: <BC34B04D-4AD5-46FB-8DC6-310BF3FBEBD3@hammerspace.com>
Date:   Thu, 27 Dec 2018 17:34:42 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <4FB643C8-4790-42B9-AF38-622E10F6A1B2@oracle.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com> <20180917130335.112832-2-trond.myklebust@hammerspace.com> <20180917130335.112832-3-trond.myklebust@hammerspace.com> <20180917130335.112832-4-trond.myklebust@hammerspace.com> <20180917130335.112832-5-trond.myklebust@hammerspace.com> <20180917130335.112832-6-trond.myklebust@hammerspace.com> <20180917130335.112832-7-trond.myklebust@hammerspace.com> <20180917130335.112832-8-trond.myklebust@hammerspace.com> <20180917130335.112832-9-trond.myklebust@hammerspace.com> <20180917130335.112832-10-trond.myklebust@hammerspace.com> <20180917130335.112832-11-trond.myklebust@hammerspace.com> <20180917130335.112832-12-trond.myklebust@hammerspace.com> <20180917130335.112832-13-trond.myklebust@hammerspace.com> <20180917130335.112832-14-trond.myklebust@hammerspace.com> <20180917130335.112832-15-trond.myklebust@hammerspace.com> <20180917130335.112832-16-trond.myklebust@hammerspace.com> <20180917130335.112832-17-trond.myklebust@!
 hammerspace.com> <20180917130335.112832-18-trond.myklebust@hammerspace.com> <20180917130335.112832-19-trond.myklebust@hammerspace.com> <20180917130335.112832-20-trond.myklebust@hammerspace.com> <20180917130335.112832-21-trond.myklebust@hammerspace.com> <20180917130335.112832-22-trond.myklebust@hammerspace.com> <20180917130335.112832-23-trond.myklebust@hammerspace.com> <20180917130335.112832-24-trond.myklebust@hammerspace.com> <20180917130335.112832-25-trond.myklebust@hammerspace.com> <20180917130335.112832-26-trond.myklebust@hammerspace.com> <20180917130335.112832-27-trond.myklebust@hammerspace.com> <4D3465FB-041C-4BB1-AB75-03511FA5AAF1@oracle.com> <BC34B04D-4AD5-46FB-8DC6-310BF3FBEBD3@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9119 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=359
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812270194
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> On Dec 27, 2018, at 5:14 PM, Trond Myklebust <trondmy@hammerspace.com> wro=
te:
>=20
>=20
>=20
>> On Dec 27, 2018, at 20:21, Chuck Lever <chuck.lever@oracle.com> wrote:
>>=20
>> Hi Trond-
>>=20
>> I've chased down a couple of remaining regressions with the v4.20 NFS cli=
ent,
>> and they seem to be rooted in this commit.
>>=20
>> When using sec=3Dkrb5, krb5i, or krb5p I found that multi-threaded worklo=
ads
>> trigger a lot of server-side disconnects. This is with TCP and RDMA trans=
ports.
>> An instrumented server shows that the client is under-running the GSS seq=
uence
>> number window. I monitored the order in which GSS sequence numbers appear=
 on
>> the wire, and after this commit, the sequence numbers are wildly misorder=
ed.
>> If I revert the hunk in xprt_request_enqueue_transmit, the problem goes a=
way.
>>=20
>> I also found that reverting that hunk results in a 3-4% improvement in fi=
o
>> IOPS rates, as well as improvement in average and maximum latency as repo=
rted
>> by fio.
>>=20
>=20
> Hmm=E2=80=A6 Provided the sequence numbers still lie within the window, th=
en why would the order matter?

The misordering is so bad that one request is delayed long enough to
fall outside the window. The new =E2=80=9Cneed re-encode=E2=80=9D logic does=
 not
trigger.


> Cheers
>  Trond
>=20
>=20
> _________________________________
> Trond Myklebust
> Linux NFS client maintainer, Hammerspace
> trond.myklebust@hammerspace.com
>=20

