Return-Path: <SRS0=xyvj=N6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48CD4C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 22:57:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 03B6E2080C
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Nov 2018 22:57:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DEL7MhfH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03B6E2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731476AbeKTJXD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 20 Nov 2018 04:23:03 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:36464 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1731164AbeKTJXD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2018 04:23:03 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAJMmtEP033427;
        Mon, 19 Nov 2018 22:56:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=G29Z1rVYJqkKu6OkwArhE8Xds9redzFLJM18ei+faNI=;
 b=DEL7MhfHK7HRuksATHP/BinndND11sMRrW/bTe1/PnEDNE0SVAf7fccqK3rqlsEODHB6
 vFHUv8CA4WKZxoHdtU6fqx9NpoXDYykZB+tAxu2pGs0FRBEB5imkPAn+CQFjl4Z/GG2y
 p5mtY9uuJfw+R1FRI5nSf5VdYLgqE2exujVUhsZX/u8EJVAE/Bzz2yz8TBAbNo7vp/Dj
 9pRA8GRWgT7QqTNZsAWavFDaynHRkWcLY1FRsVWl91TQE9K0hsQfXTxawTPo2g0xz4pO
 k504flRVh3rzqg+3KCotvBldKCJKtLqBbR4PQXyWslPEkJ7k0hUS2fT75vAwzJPdA9Fd Ng== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2120.oracle.com with ESMTP id 2ntbmqgpqe-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 19 Nov 2018 22:56:59 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wAJMuwWb012582
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 19 Nov 2018 22:56:58 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wAJMuvR7004484;
        Mon, 19 Nov 2018 22:56:57 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 19 Nov 2018 14:56:57 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 1/4] xprtrdma: Remove support for FMR memory
 registration
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181119224143.GL4890@ziepe.ca>
Date:   Mon, 19 Nov 2018 17:56:54 -0500
Cc:     Bart Van Assche <bvanassche@acm.org>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Lijun Ou <oulijun@huawei.com>, umalhi@cisco.com,
        zhongjiang@huawei.com, venkata.s.dhanalakota@intel.com,
        Dennis Dalessandro <dennis.dalessandro@intel.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <1172062C-E8CB-4F37-905D-F40EC8D9270C@oracle.com>
References: <20181119153707.10832.42881.stgit@manet.1015granger.net>
 <20181119154551.10832.5498.stgit@manet.1015granger.net>
 <1542644197.185366.50.camel@acm.org> <20181119224143.GL4890@ziepe.ca>
To:     Jason Gunthorpe <jgg@ziepe.ca>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9082 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811190201
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 19, 2018, at 5:41 PM, Jason Gunthorpe <jgg@ziepe.ca> wrote:
>=20
> On Mon, Nov 19, 2018 at 08:16:37AM -0800, Bart Van Assche wrote:
>> On Mon, 2018-11-19 at 10:45 -0500, Chuck Lever wrote:
>>> FMR is not supported on most recent RDMA devices. It is also slower
>>> and less secure than FRWR. As discussed during the RDMA BoF at LPC
>>> 2018, it is time to remove support for FMR in the NFS/RDMA client
>>> stack. NFS/RDMA server-side uses either local memory registration or
>>> FRWR.  There is no change required there to deprecate FMR.
>>>=20
>>> There are a few Infiniband/RoCE devices in the kernel tree that do
>>> not support MEM_MGT_EXTENSIONS, and therefore will no longer support
>>> client-side NFS/RDMA. These are:
>>>=20
>>> - mthca
>>> - qib
>=20
> Ooh, qib was not in the list when we talked on this in plumbers. That
> does change things.=20
>=20
> Dennis: Could qib be changed? HFI1 supports FRWR right?
>=20
>>> - usnic
>>> - hns (RoCE)
>>=20
>> Can someone from Intel comment on how many of their customers rely on =
the qib
>> driver?
>>=20
>> Can someone from Cisco comment on how many of their customers rely on =
the usnic
>> driver?
>=20
> Ignore usnic, it is not a RDMA driver
>=20
>> Can someone from Huawei comment on how many of their customers rely =
on the hns
>> driver?
>=20
> Nor was this, this is an actively used driver..
>=20
> Could hns do FRWR? It is very disappointing that such a new driver
> does not support FRWR.
>=20
> I guess it is worth stating again that FMR is deprecated. People are
> going to be disappointed if they try to submit new drivers that don't
> support FRWR :(

My methodology was to search for whether each driver asserts
IB_DEVICE_MEM_MGT_EXTENSIONS in device_cap_flags.

Interestingly, nes and ocrdma assert it, but qib and hns do not.


--
Chuck Lever



