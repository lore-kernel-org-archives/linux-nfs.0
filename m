Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 909B6C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 15:19:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5F89020855
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 15:19:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="mCaQYKeB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727814AbfBHPT5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 10:19:57 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:57358 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726813AbfBHPT5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Feb 2019 10:19:57 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x18FJXaI186999;
        Fri, 8 Feb 2019 15:19:45 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=WDprZtGFwS39ysYsRrEQpQ0ZChneWxzWQUyZpZg+jIg=;
 b=mCaQYKeBtCqvZoaLYftI4iykCzYpozdAg/AO+e05FfBFNIvsqyavqKhLS5eyAFYZHOqq
 YpRF/2Mn3hdj1F1+8mxfeVis1gj1SrnFXJ57M5CvgLEYUhgDlf3NI/hB4Zs8Llr5zXsM
 J3ojuw5zOdEOmUT+gsDEAKR8nQG7SFWxvdh7+bJd0c9FrYMTTcDuDzGGxqW5I+RF5CqD
 pfDeo6LcS+UjwRLvR2300jFM6Gwg2jhp3e8Vk1EkgoUxcflR9jxG5/FLxxaD3PyyqwEW
 aQdqr3aGgUJhcDmDoxF1mnsvb/p1K5QOvAucn93nSkciUc74eEz0YiZWneqd3pAjMqN4 4A== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2qd98nn6v5-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 08 Feb 2019 15:19:44 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x18FJhNA029439
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 8 Feb 2019 15:19:43 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x18FJfWo002477;
        Fri, 8 Feb 2019 15:19:43 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 08 Feb 2019 07:19:41 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <B730E8AE-AFA3-4CE7-9103-FCCC35C37EDD@redhat.com>
Date:   Fri, 8 Feb 2019 10:19:40 -0500
Cc:     Jason Tibbitts <tibbs@math.uh.edu>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <7C8B2CA6-0254-44B2-B5A8-A2A9E0C042E9@oracle.com>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
 <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
 <ufak1isms71.fsf@epithumia.math.uh.edu>
 <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
 <FC712F54-5A7A-436D-B076-936B29C013F4@redhat.com>
 <87imxwab12.fsf@hippogriff.math.uh.edu>
 <662CE7B3-235E-4E2D-9C8C-0F6233F3085F@redhat.com>
 <87d0o3aadg.fsf@hippogriff.math.uh.edu>
 <B730E8AE-AFA3-4CE7-9103-FCCC35C37EDD@redhat.com>
To:     Benjamin Coddington <bcodding@redhat.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9160 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902080107
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 8, 2019, at 7:01 AM, Benjamin Coddington <bcodding@redhat.com> =
wrote:
>=20
>=20
> On 7 Feb 2019, at 10:25, Jason Tibbitts wrote:
>=20
>>>>>>> "BC" =3D=3D Benjamin Coddington <bcodding@redhat.com> writes:
>>=20
>> BC> -10063 is -NFS4ERR_SEQ_MISORDERED.. I wonder why the
>> BC> trace_nfs4_sequence_done() in nfs41_sequence_process() isn't =
showing
>> BC> up in the trace?  Ah.. my fault - add "nfs4:*" to the set_events.
>>=20
>> OK, attached is another trace.  Here's the same sequence I snipped
>> previously:
>=20
> So the client is calling SEQ over and over.. xs_stream_read_data sees
> -EAGAIN.. I'm not an expert here, and not seeing what's going wrong.

<wag>

The server is returning SEQ_MISORDERED to a singleton SEQUENCE.
That suggests the client is trying to re-establish its lease but is
sending a slot nr the server doesn't recognize for the virtual slot
used for this purpose. Could be a problem on either side, and I
don't know enough to say how this loop could have started.

</wag>


> Hmm.. commit c443305529d1d3d3bee0d68fdd14ae89835e091f changed
> xs_read_stream_reply() to return recv.copied instead of "ret" to
> xprt_complete_rqst()..
>=20
> You could try reverting that commit and see if the problem goes away..
>=20
> Ben

--
Chuck Lever



