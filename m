Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B574C4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 16:01:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CF77B2085A
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 16:01:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ACKzz28V"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388326AbfCAQBU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 11:01:20 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:59464 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727952AbfCAQBU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 11:01:20 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x21G0uZ0167864;
        Fri, 1 Mar 2019 16:01:17 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=Vx6wGPXn8qGPXobFimrsuxTCoNi+2uYkcObjoguIsRI=;
 b=ACKzz28VxR7SrqsrwOh0x/jwwZJERe4cFlYlSBu2KeAnEhZwEZv3A6O7FNQBIqKa2942
 Jzgu6hbY1c0edhAm/4C5aJc1aCk8FXHfoMikW1qHeUXGzD+y9Trd+psJCdiR6c6eqwN1
 HW1kKESmvxdsuCrlIVeeLmuyRPR4MkqiZKykL7zGkT9K6o993dQQiJ01F2xa2U/njpeg
 ERenSQQZVMVqBeJlMWzbUwjupbxNdsKML9+o6ocaz46CDqzocWNTKrVBHWHaMQ7TWZ6u
 uVrmFNTGTQFUC5UPZPPvzE7Qa63SjGHFp1vvwcxMWRf1Zjqw0DC2W8M+JSLToUrmZFrh Mg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2130.oracle.com with ESMTP id 2qtuperbwk-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 01 Mar 2019 16:01:16 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x21G1F6H025960
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 1 Mar 2019 16:01:15 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x21G1Fhe026129;
        Fri, 1 Mar 2019 16:01:15 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 01 Mar 2019 08:01:14 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 4/4] NFSD: Prototype support for IMA on NFS (server)
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190301150401.GA17160@fieldses.org>
Date:   Fri, 1 Mar 2019 11:01:14 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org
Content-Transfer-Encoding: 7bit
Message-Id: <B8F76BFF-73DB-4904-8DB6-5ADE093AB051@oracle.com>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
 <20190214204326.6469.25843.stgit@manet.1015granger.net>
 <20190218193218.GA5879@fieldses.org>
 <A7D59BDC-08B3-4338-8E3B-6B41AC652968@oracle.com>
 <20190301150401.GA17160@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9182 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903010112
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Mar 1, 2019, at 10:04 AM, Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Mon, Feb 18, 2019 at 02:41:24PM -0500, Chuck Lever wrote:
>> 
>> 
>>> On Feb 18, 2019, at 2:32 PM, bfields@fieldses.org wrote:
>>> 
>>> On Thu, Feb 14, 2019 at 03:43:26PM -0500, Chuck Lever wrote:
>>>> When NFSv4 Security Label support is enabled and kernel Integrity
>>>> and IMA support is enabled (via CONFIG), then build in code to
>>>> handle the "security.ima" xattr. The NFS server converts incoming
>>>> GETATTR and SETATTR calls to acesses and updates of the xattr.
>>>> 
>>>> The FATTR4 bit is made up; meaning we still have to go through a
>>>> standards process to allocate a bit that all NFS vendors agree on.
>>>> Thus there is no guarantee this prototype will interoperate with
>>>> others or with a future standards-based implementation.
>>> 
>>> Why the dependence on CONFIG_NFSD_V4_SECURITY_LABEL?
>> 
>> Hrm, well there is some mechanism on the client side that IMA
>> needs that is behind CONFIG_NFS_V4_SECURITY_LABEL. I guess I
>> didn't think about not doing the same thing on the server. It
>> may just be an artifact of an earlier version of this code.
>> 
>> 
>>> (Also, I wonder if we actually need CONFIG_NFSD_V4_SECURITY_LABEL or if
>>> we could just remove it, or replace it by CONFIG_SECURITY where
>>> necessary.)
>> 
>> On the server, there is already a (run-time) export option to
>> enable and disable security labels. Is there a reason a
>> distribution would want to disable client or server support
>> for security labels at build time?
> 
> Distributions tend to want kernels that can do anything, with run time
> controls that are adequate to handle any use cases.
> 
> So given that we need adequate run-time configuration, why might someone
> also want the ability to disable at build time?  Some reasons I can
> think of:
> 
> 	- they need a really small kernel.
> 	- the feature is too hard to support, or they think it
> 	  introduces security risks, so they don't want their users
> 	  turning it on at all.
> 
> I could see any of those being reasons for someone not to want NFSD_V4
> or SECURITY at all, but is there likely to be a big need to configure in
> both of those things but configure out NFSD_V4_SECURITY_LABEL?  That
> seems unnecessarily fine grained.

I'm not clear, then. Are you proposing to control support for IMA labels
with the "security_labels" export option?


--
Chuck Lever



