Return-Path: <SRS0=D8Fn=N2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B638C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Nov 2018 00:12:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B193421582
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Nov 2018 00:12:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="bcFCqRZc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B193421582
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726452AbeKOKRf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 15 Nov 2018 05:17:35 -0500
Received: from mail-eopbgr790138.outbound.protection.outlook.com ([40.107.79.138]:2383
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726080AbeKOKRf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Nov 2018 05:17:35 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Aq1ONZAHgHFdes4pt0KzBc+HGC2YXhLbegd0xHy31DQ=;
 b=bcFCqRZc0O9Uf9VoU5lsfTJePePdDJFPVU+/buhEKepE362+PJR280+Xes2lWeaOsAbkqtu06FDM763GMlgk2j5q8xU+cNmIL2ePufolo3+hXiq1yli5c8m3DTY06yB87mlAbyshWPxap7nEWyAN1UoFDvLOMDTTWkQxiL6f1G0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2287.namprd13.prod.outlook.com (52.135.94.18) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1339.12; Thu, 15 Nov 2018 00:12:01 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1361.004; Thu, 15 Nov 2018
 00:12:01 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS fixes for 4.20
Thread-Topic: [GIT PULL] Please pull NFS fixes for 4.20
Thread-Index: AQHUfHfUVW2lu4QPyUSk+LyTqFzoQw==
Date:   Thu, 15 Nov 2018 00:12:01 +0000
Message-ID: <15f600c2e93b3c764a236168e47891c1f46fc2e5.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2287;6:d1Kep49GH6qsD/AES/1R9NgdUGyxV++je5UFF31nTtyL90k5n4N15g0ceY05Gky/nJdFe32LQraF02UQtRI1krulPoOiyORH41Rt9WuNmvU96jxVJYrXItmDqfXP1X4G0nrcf0t7BgEVJjuWg/hHRGKhm3UktgnzQ1tu1iE5+e5ui4Skwm9BKdExLGi2rSywc6mGPJOLSi7zavPAG0FCdjw795G8rybuu87aBJ+B6E4iBpJNVa9YrFusF4xc6o3v6oOJjyn0iewwfzfV2F/cEopkXp2fYUTcJo82C456b2enIcBauKMdeDSyZnxiWK0Yi7sOj+frq4sOh4rMHizxj8+fbOdaWT1MYzUo8Tgjp5nP12UX/xotbmJ3Xtx3VhWmIauwkmcTGqiYMWFppYpeCM+q5AzIgcvPPQCTP85r16Xi2Witn3oXWpyIudbxwLwx7X91rM622yNRV5HL5m9yhA==;5:43VOHXXEB+nRKATxUshh6w+RgFnsg2Q8NLtL+BpcBx2hW933rOCpJQSpcMJ5TKX2XKcUdqATNiYzpNGldcH6gkyJ72fJTws9p+Nkz1uysRf+F8Fmhj51Xf4bve2ZhVtXlbl2fyn/5fDh+FGErXvUJ4CYA7QpP6QBUvqMVOKs3oo=;7:DgTuGilH2CwSqlX+69qcPOPoFwPvir9muj8PNS+jiyFxHtZ4+o+goDScg+4FQ82OGpDsBnFI+kqsYl7C4+os+4uEpzGJFQiUqDB5kYpOQgAEd6uuNF4lwk6CkT1dhedPFUGF5BhSjeRB3XpNtAwh7A==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 39425c43-b077-49b7-0e29-08d64a8ef790
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2287;
x-ms-traffictypediagnostic: SN6PR13MB2287:
x-microsoft-antispam-prvs: <SN6PR13MB2287D27104162AE5E7F74EE2B8DC0@SN6PR13MB2287.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(3002001)(10201501046)(3231415)(944501410)(52105112)(148016)(149066)(150057)(6041310)(20161123558120)(20161123562045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2287;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2287;
x-forefront-prvs: 08572BD77F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(979002)(346002)(136003)(39830400003)(376002)(366004)(396003)(189003)(199004)(478600001)(53936002)(86362001)(186003)(71200400001)(71190400001)(105586002)(118296001)(256004)(14444005)(106356001)(97736004)(6512007)(26005)(575784001)(6916009)(102836004)(6506007)(305945005)(5660300001)(14454004)(2900100001)(6436002)(2501003)(6346003)(5640700003)(4001150100001)(66066001)(7736002)(6486002)(4326008)(6116002)(1730700003)(8676002)(25786009)(81156014)(81166006)(486006)(99286004)(316002)(2616005)(54906003)(8936002)(476003)(3846002)(2351001)(2906002)(36756003)(68736007)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2287;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-message-info: Itk1TQO5qhJl/JcukWnXYSn8VvWJ/WHjNez72laUKzDQm5++8K//HLK6vWeH2BfJlW6vJIQigwRRyXJ2Qv5vfjcxOosQvcSMmGCRus2KNvfc9r1iqMr+pxmVNbIIVvJZ4mUQ9ObwjTEPwFMW71S0z0IVLRZdmGEaqKauW5pRJ5wFZqQz7wQIdqfjOHuFW9FhojyaBKoFyXeY+Se/69YO2Z+57fSZ6PzCzSILPGL5m48yPnMFFd3Hb3kXfG6IxSVSGT8NhWPT0+0V26BtMbnAVqLUW8WXVX1XOrp49pwuKqvKZuHn0S7DrfrRR2Tv1997k+WrOGhWDmfltOWl5v/VMdnkA5BaU4borrX8CDMdT2g=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <515F9C4070FCF241B8A61752A127744F@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 39425c43-b077-49b7-0e29-08d64a8ef790
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Nov 2018 00:12:01.6446
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2287
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGludXMsDQoNClRoZSBmb2xsb3dpbmcgY2hhbmdlcyBzaW5jZSBjb21taXQgY2NkYTRhZjBm
NGI5MmY3YjRjMzA4ZDNhY2MyNjJmNGE3ZTNhZmZhZDoNCg0KICBMaW51eCA0LjIwLXJjMiAoMjAx
OC0xMS0xMSAxNzoxMjozMSAtMDYwMCkNCg0KYXJlIGF2YWlsYWJsZSBpbiB0aGUgR2l0IHJlcG9z
aXRvcnkgYXQ6DQoNCiAgZ2l0Oi8vZ2l0LmxpbnV4LW5mcy5vcmcvcHJvamVjdHMvdHJvbmRteS9s
aW51eC1uZnMuZ2l0IHRhZ3MvbmZzLWZvci00LjIwLTMNCg0KZm9yIHlvdSB0byBmZXRjaCBjaGFu
Z2VzIHVwIHRvIGUzOWQ4YTE4NmVkMDAyODU0MTk2NjY4Y2I3NTYyZmZkZmJjNmQzNzk6DQoNCiAg
TkZTdjQ6IEZpeCBhbiBPb3BzIGR1cmluZyBkZWxlZ2F0aW9uIGNhbGxiYWNrcyAoMjAxOC0xMS0x
MyAxNzoxNToxNyAtMDUwMCkNCg0KQ2hlZXJzLA0KICAgVHJvbmQNCg0KLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KTkZTIGNs
aWVudCBidWdmaXhlcyBmb3IgTGludXggNC4yMA0KDQpIaWdobGlnaHRzIGluY2x1ZGU6DQoNClN0
YWJsZSBmaXhlczoNCi0gRG9uJ3QgZXhpdCB0aGUgTkZTdjQgc3RhdGUgbWFuYWdlciB3aXRob3V0
IGNsZWFyaW5nIE5GUzRDTE5UX01BTkFHRVJfUlVOTklORw0KDQpCdWdmaXhlczoNCi0gRml4IGFu
IE9vcHMgd2hlbiBkZXN0cm95aW5nIHRoZSBSUENTRUNfR1NTIGNyZWRlbnRpYWwgY2FjaGUNCi0g
Rml4IGFuIE9vcHMgZHVyaW5nIGRlbGVnYXRpb24gY2FsbGJhY2tzDQotIEVuc3VyZSB0aGF0IHRo
ZSBORlN2NCBzdGF0ZSBtYW5hZ2VyIGV4aXRzIHRoZSBsb29wIG9uIFNJR0tJTEwNCi0gRml4IGEg
Ym9ndXMgZ2V0L3B1dCBpbiBnZW5lcmljX2tleV90b19leHBpcmUoKQ0KDQotLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQpUcm9u
ZCBNeWtsZWJ1c3QgKDUpOg0KICAgICAgTkZTdjQ6IERvbid0IGV4aXQgdGhlIHN0YXRlIG1hbmFn
ZXIgd2l0aG91dCBjbGVhcmluZyBORlM0Q0xOVF9NQU5BR0VSX1JVTk5JTkcNCiAgICAgIE5GU3Y0
OiBFbnN1cmUgdGhhdCB0aGUgc3RhdGUgbWFuYWdlciBleGl0cyB0aGUgbG9vcCBvbiBTSUdLSUxM
DQogICAgICBTVU5SUEM6IEZpeCBhIE9vcHMgd2hlbiBkZXN0cm95aW5nIHRoZSBSUENTRUNfR1NT
IGNyZWRlbnRpYWwgY2FjaGUNCiAgICAgIFNVTlJQQzogRml4IGEgYm9ndXMgZ2V0L3B1dCBpbiBn
ZW5lcmljX2tleV90b19leHBpcmUoKQ0KICAgICAgTkZTdjQ6IEZpeCBhbiBPb3BzIGR1cmluZyBk
ZWxlZ2F0aW9uIGNhbGxiYWNrcw0KDQogZnMvbmZzL2NhbGxiYWNrX3Byb2MuYyAgICAgICAgIHwg
IDQgKy0tDQogZnMvbmZzL2RlbGVnYXRpb24uYyAgICAgICAgICAgIHwgMTEgKysrKysrLS0NCiBm
cy9uZnMvbmZzNHN0YXRlLmMgICAgICAgICAgICAgfCAxMCArKysrLS0tDQogbmV0L3N1bnJwYy9h
dXRoX2dlbmVyaWMuYyAgICAgIHwgIDggKy0tLS0tDQogbmV0L3N1bnJwYy9hdXRoX2dzcy9hdXRo
X2dzcy5jIHwgNjEgKysrKysrKysrKysrKysrKysrKysrKysrKysrKystLS0tLS0tLS0tLS0tDQog
NSBmaWxlcyBjaGFuZ2VkLCA2MCBpbnNlcnRpb25zKCspLCAzNCBkZWxldGlvbnMoLSkNCi0tIA0K
VHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNl
DQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
