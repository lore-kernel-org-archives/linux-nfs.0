Return-Path: <SRS0=PH1c=P7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72FABC282C0
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 17:30:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 40AF520870
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Jan 2019 17:30:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="P25t6Mpf"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725966AbfAWRag (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Jan 2019 12:30:36 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:45462 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725896AbfAWRag (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2019 12:30:36 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0NHSaMe087688;
        Wed, 23 Jan 2019 17:30:30 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=/ghzNNcPiXiDiiexgKq3gtq5LfQdAV3KHBmP9WwEzjM=;
 b=P25t6MpfGFq76SMf/qPQtyxSsAnaLt3OQBZD22agvLVMRHgf6A22T/jt2tcYhYoSP9xN
 tLKXBy2LgHOhsI8zHke533ghIyY/j2P4I36tDQWKVIJgbR4bad1CpQ7KDy3YnmvEma0Z
 DBIyCl5+N1YMMb3s9RkHg887gH+fDBl0hVdROTl8yVyVDE/vfRKhL9f8TXMUszG6v4A6
 144LMAS0ivnp7KPDvpOBeCfVwfT0HynW1LhftiBZ7ZP0BFI+WzpE7F0ozO0cH0QT17UT
 VM0BZ+2r+oHSEFp1DrrEHX2VYo8HyQT6+IHjhNRDt2/bZm1c5r0rZLMeKze1a1YNrNtI hg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2q3uauubj2-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 23 Jan 2019 17:30:30 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0NHUPDq014041
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 23 Jan 2019 17:30:25 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0NHUOpK011827;
        Wed, 23 Jan 2019 17:30:24 GMT
Received: from dhcp-10-211-47-54.usdhcp.oraclecorp.com (/10.211.47.54)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 23 Jan 2019 09:30:24 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] xprtrdma: Make sure Send CQ is allocated on an existing
 CPU
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1dd8b5a5-4ce7-a53e-9510-bd122039bcfb@suse.de>
Date:   Wed, 23 Jan 2019 12:30:42 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <7D9897D4-F7E6-46A2-BA50-BB2D5220F162@oracle.com>
References: <3f5da1e4-99f1-8376-a291-e50a7d52c303@suse.com>
 <BF1A6DC0-FF34-4B80-8602-6B122AD5ABFD@oracle.com>
 <18bbe249-7d03-2475-d943-2f7d386a3797@suse.de>
 <1dd8b5a5-4ce7-a53e-9510-bd122039bcfb@suse.de>
To:     Nicolas Morey-Chaisemartin <nmoreychaisemartin@suse.de>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9145 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=3 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901230129
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Jan 23, 2019, at 12:07 PM, Nicolas Morey-Chaisemartin =
<nmoreychaisemartin@suse.de> wrote:
>=20
>=20
>=20
> On 1/23/19 6:06 PM, Nicolas Morey-Chaisemartin wrote:
>>=20
>> On 1/23/19 5:51 PM, Chuck Lever wrote:
>>> Hi Nicolas-
>>>=20
>>>> On Jan 23, 2019, at 8:12 AM, Nicolas Morey-Chaisemartin =
<nmoreychaisemartin@suse.com> wrote:
>>>>=20
>>>> Make sure host has at least 2 CPU before allocating to CPU#1
>>> The fourth parameter of ib_alloc_cq() is not a CPU number,
>>> it's a completion vector number. What failure did you see
>>> that prompted this patch?
>> When trying to mount, I get this:
>> + mount -o rdma,port=3D20049 192.168.20.15:/tmp/RAM /tmp/RAM
>> mount.nfs: mounting 192.168.20.15:/tmp/RAM failed, reason given by =
server: No such file or directory
>>=20
>> Digging a bit into the code, it appears that the cq allocation here =
returns a ENOENT which come from mlx5_vector2eqn.
>> On my system (VM with a mlx5 card with SRIOV), the comp_eqs_list only =
contains one entry with index =3D=3D 0
>>=20
>> Nicolas
>>=20
>=20
> Also, adding a 2nd core to my VM fixes the issue (thus my =
understanding that it was a CPU number)

Fair enough. The 2nd CPU adds a 2nd compvec. Instead of
num_cpus_online() you want ib_device::num_comp_vectors.

I suspect there's a spiffier way to go about this these
days thanks to ib_get_vector_affinity, but you've found
a longstanding bug. So let's get something that can be
comfortably backported to stable.


--
Chuck Lever



