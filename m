Return-Path: <SRS0=g2DM=C2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41DABC433E2
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Sep 2020 06:36:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1082E21D24
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Sep 2020 06:36:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726109AbgIQGgm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 17 Sep 2020 02:36:42 -0400
Received: from szxga02-in.huawei.com ([45.249.212.188]:3544 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726106AbgIQGgl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Sep 2020 02:36:41 -0400
X-Greylist: delayed 924 seconds by postgrey-1.27 at vger.kernel.org; Thu, 17 Sep 2020 02:36:40 EDT
Received: from dggeme752-chm.china.huawei.com (unknown [172.30.72.54])
        by Forcepoint Email with ESMTP id 5402E246117BD6188804;
        Thu, 17 Sep 2020 14:21:14 +0800 (CST)
Received: from dggeme753-chm.china.huawei.com (10.3.19.99) by
 dggeme752-chm.china.huawei.com (10.3.19.98) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256) id
 15.1.1913.5; Thu, 17 Sep 2020 14:21:14 +0800
Received: from dggeme753-chm.china.huawei.com ([10.7.64.70]) by
 dggeme753-chm.china.huawei.com ([10.7.64.70]) with mapi id 15.01.1913.007;
 Thu, 17 Sep 2020 14:21:13 +0800
From:   linmiaohe <linmiaohe@huawei.com>
To:     Nick Desaulniers <ndesaulniers@google.com>
CC:     "Gustavo A . R . Silva" <gustavo@embeddedor.com>,
        Joe Perches <joe@perches.com>,
        Nathan Chancellor <natechancellor@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "clang-built-linux@googlegroups.com" 
        <clang-built-linux@googlegroups.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v2] nfs: remove incorrect fallthrough label
Thread-Topic: [PATCH v2] nfs: remove incorrect fallthrough label
Thread-Index: AdaMuodnVDGlupKbQBWadlZPzzQK5g==
Date:   Thu, 17 Sep 2020 06:21:13 +0000
Message-ID: <5de6c6d3ced340ac80702c527bb38d12@huawei.com>
Accept-Language: zh-CN, en-US
Content-Language: zh-CN
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.174.176.109]
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-CFilter-Loop: Reflected
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

TmljayBEZXNhdWxuaWVycyA8bmRlc2F1bG5pZXJzQGdvb2dsZS5jb20+IHdyb3RlOg0KPiBUaGVy
ZSBpcyBubyBjYXNlIGFmdGVyIHRoZSBkZWZhdWx0IGZyb20gd2hpY2ggdG8gZmFsbHRocm91Z2gg
dG8uIENsYW5nIHdpbGwgZXJyb3IgaW4gdGhpcyBjYXNlICh1bmhlbHBmdWxseSB3aXRob3V0IGNv
bnRleHQsIHNlZSBsaW5rIGJlbG93KSBhbmQgR0NDIHdpbGwgd2l0aCAtV3N3aXRjaC11bnJlYWNo
YWJsZS4NCj4NCj5UaGUgcHJldmlvdXMgY29tbWl0IHNob3VsZCBoYXZlIGp1c3QgcmVwbGFjZWQg
dGhlIGNvbW1lbnQgd2l0aCBhIGJyZWFrIHN0YXRlbWVudC4NCj4NCj5JZiB3ZSBjb25zaWRlciBp
bXBsaWNpdCBmYWxsdGhyb3VnaCB0byBiZSBhIGRlc2lnbiBtaXN0YWtlIG9mIEMsIHRoZW4gYWxs
IGNhc2Ugc3RhdGVtZW50cyBzaG91bGQgYmUgdGVybWluYXRlZCB3aXRoIG9uZSBvZiB0aGUgZm9s
bG93aW5nDQo+c3RhdGVtZW50czoNCj4qIGJyZWFrDQo+KiBjb250aW51ZQ0KPiogcmV0dXJuDQo+
KiBfX2F0dHJpYnV0ZV9fKF9fZmFsbHRocm91Z2hfXykNCj4qIGdvdG8gKHBseiBubykNCj4qIChj
YWxsIG9mIGZ1bmN0aW9uIHdpdGggX19hdHRyaWJ1dGVfXyhfX25vcmV0dXJuX18pKQ0KPg0KPkZp
eGVzOiAyYTEzOTBjOTVhNjkgKCJuZnM6IENvbnZlcnQgdG8gdXNlIHRoZSBwcmVmZXJyZWQgZmFs
bHRocm91Z2ggbWFjcm8iKQ0KPkxpbms6IGh0dHBzOi8vYnVncy5sbHZtLm9yZy9zaG93X2J1Zy5j
Z2k/aWQ9NDc1MzkNCj5TdWdnZXN0ZWQtYnk6IEpvZSBQZXJjaGVzIDxqb2VAcGVyY2hlcy5jb20+
DQo+U2lnbmVkLW9mZi1ieTogTmljayBEZXNhdWxuaWVycyA8bmRlc2F1bG5pZXJzQGdvb2dsZS5j
b20+DQo+LS0tDQoNClJldmlld2VkLWJ5OiBNaWFvaGUgTGluIDxsaW5taWFvaGVAaHVhd2VpLmNv
bT4NCg0KDQo=
