Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6D21C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:26:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 762D32080A
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:26:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="gzpYdphb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 762D32080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726139AbeLAIhQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 03:37:16 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:43772 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725749AbeLAIhQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 03:37:16 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAULInYe151683;
        Fri, 30 Nov 2018 21:26:36 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=M/htfynNrey2sN/V8rNc/TSYcj5K3tldp3iUXyB/pbE=;
 b=gzpYdphb6quQfFNAXKZ6ac1Zn7v5N1zEOJgia5WbNVA/ssoTjVaGJAJUWghAbki1TaY/
 8hkKwIab7QyDK9YzQ3dcI6I6g55b89X5SKCNdQXwUEKmgtVfq4HYtOcGIhLrzR031OrE
 5fB7hDlnI4dAxwx1wExaBBlDYSRaYPvcmVQ/ivjQ0+kLfXMBfvPIvnJKE6m3Q6geHdlo
 /vJcvrplADVSm1o2rPbitYel7MRadXbSueV2LUXDI2uUCN78UZrrGTbyexILdHDQkg1u
 +W//EU+6o0XSSY8z72maSstX927ISjnXdfQ64Lja4yHJVE9QGEwJtQWdIfanEBgtV/yx hw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2p2jf0qrp4-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 21:26:36 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wAULQZtF011112
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 21:26:36 GMT
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
        by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wAULQZ7P030943;
        Fri, 30 Nov 2018 21:26:35 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 30 Nov 2018 13:26:35 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2 17/20] SUNRPC: Remove support for kerberos_v1
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <952872188dd26c5469f4bafe5689a5b2b377803f.camel@gmail.com>
Date:   Fri, 30 Nov 2018 16:26:34 -0500
Cc:     linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <F9AC1596-B0F1-4F52-B798-3D94550D4560@oracle.com>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
 <20181126200717.10321.8819.stgit@manet.1015granger.net>
 <952872188dd26c5469f4bafe5689a5b2b377803f.camel@gmail.com>
To:     Anna Schumaker <schumaker.anna@gmail.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9093 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=902
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811300181
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 30, 2018, at 4:19 PM, Anna Schumaker <schumaker.anna@gmail.com> =
wrote:
>=20
> Hi Chuck,
>=20
> On Mon, 2018-11-26 at 15:07 -0500, Chuck Lever wrote:
>> Kerberos v1 allows the selection of encryption types that are known
>> to be insecure and are no longer widely deployed. Also there is no
>> convenient facility for testing v1 or these enctypes, so essentially
>> this code has been untested for some time.
>>=20
>> Note that RFC 6649 deprecates DES and Arcfour_56 in Kerberos, and
>> RFC 8429 (October 2018) deprecates DES3 and Arcfour.
>>=20
>> Support for DES_CBC_RAW, DES_CBC_CRC, DES_CBC_MD4, DES_CBC_MD5,
>> DES3_CBC_RAW, and ARCFOUR_HMAC encryption in the Linux kernel
>> RPCSEC_GSS implementation is removed by this patch.
>=20
> I guess my biggest question is if any servers in the wild might still =
be using
> Kerberos v1 encryption that we need to worry about?

What we want to do here is remove encryption types that the upstream
community can no longer support, and that the IETF says are insecure
and thus should not be used (even if we could support them). IMO this
is not a matter of continuing to support old servers: they need to
update.


> And does the rpc.gssd daemon need to be updated as well?

If the kernel doesn't ask for these encryption types, gssd won't use
them. It might do with some clean up, though, but I haven't looked
closely at it.


--
Chuck Lever



