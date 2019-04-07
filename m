Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D4EBC10F0E
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 11:40:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D290120879
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 11:40:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726263AbfDGLk5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 07:40:57 -0400
Received: from smtp65.cstnet.cn ([159.226.251.65]:47960 "EHLO cstnet.cn"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726245AbfDGLk5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 7 Apr 2019 07:40:57 -0400
Received: by ajax-webmail-APP-19 (Coremail) ; Sun, 7 Apr 2019 19:40:43 +0800
 (GMT+08:00)
X-Originating-IP: [124.16.85.84]
Date:   Sun, 7 Apr 2019 19:40:43 +0800 (GMT+08:00)
X-CM-HeaderCharset: UTF-8
From:   =?UTF-8?B?5piT5p6X?= <yilin@iie.ac.cn>
To:     linux-nfs@vger.kernel.org
Cc:     bfields@fieldses.org, jlayton@kernel.org,
        "jian liu" <liujian6@iie.ac.cn>,
        "csong@cs.ucr.edu" <csong@cs.ucr.edu>,
        "yiqiuping@gmail.com" <yiqiuping@gmail.com>,
        "zhiyunq@cs.ucr.edu" <zhiyunq@cs.ucr.edu>
Subject: =?UTF-8?Q?should_the_svc=5Fxprt=5Fget_called_after_th?=
 =?UTF-8?Q?e_object_assigned_to_a_global_variable=EF=BC=9F?=
X-Priority: 3
X-Mailer: Coremail Webmail Server Version XT5.0.5 build 20161025(89512.9021)
 Copyright (c) 2002-2019 www.mailtech.cn cstnet
Content-Transfer-Encoding: base64
Content-Type: text/plain; charset=UTF-8
MIME-Version: 1.0
Message-ID: <4ac222da.7767b.169f799c48f.Coremail.yilin@iie.ac.cn>
X-Coremail-Locale: zh_CN
X-CM-TRANSID: 2QCowABHGP284alchpu6AA--.48438W
X-CM-SenderInfo: p1lox0o6llvhldfou0/1tbiCQQNAFlo+5W-twABsW
X-Coremail-Antispam: 1Ur529EdanIXcx71UUUUU7IcSsGvfJ3iIAIbVAYjsxI4VW7Jw
        CS07vEb4IE77IF4wCS07vE1I0E4x80FVAKz4kxMIAIbVAFxVCaYxvI4VCIwcAKzIAtYxBI
        daVFxhVjvjDU=
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGksIGFsbDoKICAgIHdoZW4gYW5hbHl6aW5nIHRoZSB2NS4xIHNvdXJjZSBjb2RlLCBJIG5vdGlj
ZSB0aGF0IGluIGZ1bmN0aW9uIG5mc2Q0X3Byb2Nlc3NfY2JfdXBkYXRlLCAKdGhlIG9iamVjdCBj
LT5jbl94cHJ0IGFzc2lnbmVkIHRvIGEgbG9jYWwgdmFyaWFibGUgY29ubi5jYl94cHJ0IHdpdGgg
YSByZWZjb3VudCBpbmNyZWFzZWQ6CiAgICAgIGlmIChjKSB7CgkJc3ZjX3hwcnRfZ2V0KGMtPmNu
X3hwcnQpOwoJCWNvbm4uY2JfeHBydCA9IGMtPmNuX3hwcnQ7CgkJc2VzID0gYy0+Y25fc2Vzc2lv
bjsKCX0KCmFuZCB0aGUgdmFyaWFibGUgY29ubi5jYl94cHJ0IHdpbGwgYmUgYXNzaWduZWQgdG8g
YSBnbG9iYWwgb2JqZWN0IGNscC0+Y2xfY2JfY29ubi5jYl94cHJ0IAppbiBjYWxsZWUgc2V0dXBf
Y2FsbGJhY2tfY2xpZW50IHdpdGggYSBjb25kaXRpb24gdGhhdCBjbHAtPmNsX21pbm9ydmVyc2lv
biAhPSAwOgoKICAgICAgIGlmIChjbHAtPmNsX21pbm9ydmVyc2lvbiA9PSAwKSB7CgkJaWYgKCFj
bHAtPmNsX2NyZWQuY3JfcHJpbmNpcGFsICYmCgkJCQkoY2xwLT5jbF9jcmVkLmNyX2ZsYXZvciA+
PSBSUENfQVVUSF9HU1NfS1JCNSkpCgkJCXJldHVybiAtRUlOVkFMOwoJCWFyZ3MuY2xpZW50X25h
bWUgPSBjbHAtPmNsX2NyZWQuY3JfcHJpbmNpcGFsOwoJCWFyZ3MucHJvZ251bWJlcgk9IGNvbm4t
PmNiX3Byb2c7CgkJYXJncy5wcm90b2NvbCA9IFhQUlRfVFJBTlNQT1JUX1RDUDsKCQlhcmdzLmF1
dGhmbGF2b3IgPSBjbHAtPmNsX2NyZWQuY3JfZmxhdm9yOwoJCWNscC0+Y2xfY2JfaWRlbnQgPSBj
b25uLT5jYl9pZGVudDsKCX0gZWxzZSB7CgkJaWYgKCFjb25uLT5jYl94cHJ0KQoJCQlyZXR1cm4g
LUVJTlZBTDsKCQljbHAtPmNsX2NiX2Nvbm4uY2JfeHBydCA9IGNvbm4tPmNiX3hwcnQ7CgkJY2xw
LT5jbF9jYl9zZXNzaW9uID0gc2VzOwoJCWFyZ3MuYmNfeHBydCA9IGNvbm4tPmNiX3hwcnQ7CgkJ
YXJncy5wcm9nbnVtYmVyID0gY2xwLT5jbF9jYl9zZXNzaW9uLT5zZV9jYl9wcm9nOwoJCWFyZ3Mu
cHJvdG9jb2wgPSBjb25uLT5jYl94cHJ0LT54cHRfY2xhc3MtPnhjbF9pZGVudCB8CgkJCQlYUFJU
X1RSQU5TUE9SVF9CQzsKCQlhcmdzLmF1dGhmbGF2b3IgPSBzZXMtPnNlX2NiX3NlYy5mbGF2b3I7
Cgl9Cgp3aGF0IGlmIHRoZSBjbF9taW5vcnZlcnNpb24gZXF1YWxzIDAgPyB0aGUgYy0+Y25feHBy
dCdzIHJlZmNvdW50IHdpbGwgaW5jcmVhc2VkIHdpdGhvdXQgYSBhc3NpZ25tZW50LiAKQ2FuIGl0
IGJlIGVuc3VyZWQgdGhhdCB0aGUgY2xfbWlub3J2ZXJzaW9uIHdvbid0IGJlIHplcm8gd2l0aCB0
aGUgcmVmY291bnQgaW5jcmVtZW50PwoKQmVzdCBSZWdhcmRzCgpMaW4gWWk=
