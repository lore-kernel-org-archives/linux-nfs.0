Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26CA3C10F01
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:51:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E8A562183F
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 03:51:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="VBjQt2mW"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727035AbfBTDvp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 22:51:45 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:50170 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725916AbfBTDvp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 22:51:45 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1K3nj2x039264;
        Wed, 20 Feb 2019 03:51:42 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=5N0VWsTyH4rUUGS1Qvplg9AaXcqzmudT+KkruLexRuo=;
 b=VBjQt2mWL1gckYPNoeJ3yPBa/rbXj8ZO1A9ou4PQEgGZcLZOmhKp01++wcNk0aXhTk4M
 lCw3LpM0RpVtpOalxyBmvPOJcWxFCG5odsExSmK4dCcKvs8UK7FkHDOkvGkLv06JVk5+
 E0M80nQ7DEJLgqkhBzir0jiK1IyzuIxx6rGsfSemKk4/hUawaUn5hjlEReA3eGx7GVi7
 GIK+ezRYwUD7MycxeQ0J0Hehywg720qIbu08DwlocJYbckpJpdxTsepNpWEUw2YfCsrG
 3N1SvUgCHnPfm5ET1jOsyp0y6jelAeD1CkroOZDVflkVwwxVS5kCLjp+HmBn0QazVcZi OA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by userp2130.oracle.com with ESMTP id 2qp9xty3u9-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 20 Feb 2019 03:51:42 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1K3pgVW028134
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 20 Feb 2019 03:51:42 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1K3pfgE027146;
        Wed, 20 Feb 2019 03:51:41 GMT
Received: from [192.168.1.184] (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 19 Feb 2019 19:51:41 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH RFC 0/4] IMA on NFS prototype
From:   Chuck Lever <chuck.lever@oracle.com>
X-Mailer: iPad Mail (16D57)
In-Reply-To: <1550623002.17768.10.camel@linux.ibm.com>
Date:   Tue, 19 Feb 2019 22:51:40 -0500
Cc:     linux-nfs@vger.kernel.org, linux-integrity@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <ABC54315-2F2B-4FA7-98A8-28A3FC2092DB@oracle.com>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net> <1550623002.17768.10.camel@linux.ibm.com>
To:     Mimi Zohar <zohar@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9172 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902200025
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> On Feb 19, 2019, at 7:36 PM, Mimi Zohar <zohar@linux.ibm.com> wrote:
>=20
> Hi Chuck,
>=20
>> EVM is not supported in this prototype. NFS does not support several
>> of the xattrs that are protected by EVM: SMACK64, Posix ACLs, and
>> Linux file capabilities are not supported, which makes EVM more
>> difficult to support on NFS mounts.
>=20
> There's no requirement for all of these xattrs to exist.  If an xattr
> does exist, then it is included in the security.evm hmac/signature.

Understood. The issue is that if they exist on a file residing on an NFS ser=
ver,
such xattrs would not be visible to clients. My understanding is that then E=
VM
verification would fail on such files on NFS clients.

We could possibly make EVM work in limited scenarios until such time that
the NFS protocol can make those xattrs available to NFS clients. I hope that=

having only security.ima is useful at least for experimenting and maybe more=
.

However, if folks think having security.evm also is needed, that is straight=
-
forward... just saying that there are currently other limits in NFS that mak=
e a
full EVM implementation problematic.=

