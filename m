Return-Path: <SRS0=Opkj=SP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AD3FC10F11
	for <linux-nfs@archiver.kernel.org>; Sat, 13 Apr 2019 14:56:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 054362084D
	for <linux-nfs@archiver.kernel.org>; Sat, 13 Apr 2019 14:56:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="sPCvhIX3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727091AbfDMO4k (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 13 Apr 2019 10:56:40 -0400
Received: from mail-eopbgr740120.outbound.protection.outlook.com ([40.107.74.120]:22592
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727069AbfDMO4k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 13 Apr 2019 10:56:40 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=x3gEscDx2y/4tdVjzOdT7gcZExhH6gQ4/WW5KSBeoMQ=;
 b=sPCvhIX3aVPmqY0jUi753jEOaJMNx1wg3Ogmutbx3W4jNBd7h50BBYHOh5W1imwnFsTWPCDXgWXxCKibyZUsqcg7PTxHmKQj+LTnK49wtU/zSifZIohgvlcTqjQkThz0yyqM6HNYjArwRnsfbCzJwWPcGzTJo4fpwgJ0jhCY9H0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2238.namprd13.prod.outlook.com (52.135.93.151) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.9; Sat, 13 Apr 2019 14:56:36 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1813.006; Sat, 13 Apr 2019
 14:56:36 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfixes
Thread-Topic: [GIT PULL] Please pull NFS client bugfixes
Thread-Index: AQHU8gkXdIwKPdo5eUGqDvBdXtyF/g==
Date:   Sat, 13 Apr 2019 14:56:35 +0000
Message-ID: <6398aab500bfe326030981f919a0a1f7d92fcf28.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 746bcc96-2fe8-4c5c-4e6b-08d6c02039c3
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2238;
x-ms-traffictypediagnostic: SN6PR13MB2238:
x-microsoft-antispam-prvs: <SN6PR13MB2238420C882644CF418501ADB8290@SN6PR13MB2238.namprd13.prod.outlook.com>
x-forefront-prvs: 00064751B6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(396003)(39830400003)(136003)(346002)(199004)(189003)(106356001)(105586002)(118296001)(1730700003)(81166006)(8676002)(2501003)(8936002)(305945005)(81156014)(2351001)(14454004)(36756003)(5640700003)(3846002)(6116002)(53936002)(68736007)(2906002)(478600001)(6916009)(25786009)(6512007)(7736002)(4326008)(71200400001)(71190400001)(102836004)(14444005)(66066001)(54906003)(316002)(26005)(97736004)(186003)(6436002)(86362001)(5660300002)(6506007)(2616005)(99286004)(256004)(486006)(476003)(6486002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2238;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: gqRRSrnXRHpENzfrlTORyy6ivkPd3STg+8k1+eJs/tL3m2cvC77ZOyc7Ry0bXG6fArRrUxC0dqaz93MgtzexRgyrhw7VqXcYa92txWCpW/jy6F9w4875uK6TcS/LIGpzbXLwF7ig2K73Dg1EZ+BumyAqrB3TxAEXrb4kcPKWN2J5yWoscz4xbqSxHDd/YyDYF1org8aa8PemthV1/b/n6eSMEvz+H5XAf8ZAX/4kgqYGfolu370qxBRv0BcMLRB6+Yzp9N7uS6kdI6+gN6tZV4YMy5u0mFgHWceQN/wQsGB91be4R27sUMT4hrvOwuXQr+HcCtvptXmXiNVy8sguhHaDYCSDs2JWJa9apM5vrSWXIwzlE/0S7yEtCC+kKV5Aj2jzA+o/yrszCVbRki1tHrP/i6Kvtkxhce6eDv+biHI=
Content-Type: text/plain; charset="utf-8"
Content-ID: <2257CAAE2064CC4DA78635D14F5EDF24@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 746bcc96-2fe8-4c5c-4e6b-08d6c02039c3
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Apr 2019 14:56:35.8410
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2238
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGludXMsDQoNClRoZSBmb2xsb3dpbmcgY2hhbmdlcyBzaW5jZSBjb21taXQgNTgyNTQ5ZTNm
YmUxMzdlYjZjZTliZTU5MWFjYTI1YzIyMjJhMzZiNDoNCg0KICBNZXJnZSB0YWcgJ2Zvci1saW51
cycgb2YgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHViL3NjbS9saW51eC9rZXJuZWwvZ2l0L3JkbWEv
cmRtYSAoMjAxOS0wNC0xMCAwOTozOTowNCAtMTAwMCkNCg0KYXJlIGF2YWlsYWJsZSBpbiB0aGUg
R2l0IHJlcG9zaXRvcnkgYXQ6DQoNCiAgZ2l0Oi8vZ2l0LmxpbnV4LW5mcy5vcmcvcHJvamVjdHMv
dHJvbmRteS9saW51eC1uZnMuZ2l0IHRhZ3MvbmZzLWZvci01LjEtNA0KDQpmb3IgeW91IHRvIGZl
dGNoIGNoYW5nZXMgdXAgdG8gYWY2YjYxZDdlZjU4MDk5YzgyZDg1NDM5NWEwZTAwMmJlNmJkMDM2
YzoNCg0KICBSZXZlcnQgIlNVTlJQQzogTWljcm8tb3B0aW1pc2Ugd2hlbiB0aGUgdGFzayBpcyBr
bm93biBub3QgdG8gYmUgc2xlZXBpbmciICgyMDE5LTA0LTExIDE1OjQxOjE0IC0wNDAwKQ0KDQot
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tDQpORlMgY2xpZW50IGJ1Z2ZpeGVzIGZvciBMaW51eCA1LjENCg0KSGlnaGxpZ2h0cyBp
bmNsdWRlOg0KDQpTdGFibGUgZml4ZXM6DQotIEZpeCBhIGRlYWRsb2NrIGluIGNsb3NlKCkgZHVl
IHRvIGluY29ycmVjdCBkcmFpbmluZyBvZiBSRE1BIHF1ZXVlcw0KDQpCdWdmaXhlczoNCi0gUmV2
ZXJ0ICJTVU5SUEM6IE1pY3JvLW9wdGltaXNlIHdoZW4gdGhlIHRhc2sgaXMga25vd24gbm90IHRv
IGJlIHNsZWVwaW5nIg0KICBhcyBpdCBpcyBjYXVzaW5nIHN0YWNrIG92ZXJmbG93cw0KLSBGaXgg
YSByZWdyZXNzaW9uIHdoZXJlIE5GU3Y0IGdldGFjbCBhbmQgZnNfbG9jYXRpb25zIHN0b3BwZWQg
d29ya2luZw0KLSBGb3JiaWQgc2V0dGluZyBBRl9JTkVUNiB0byAic3RydWN0IHNvY2thZGRyX2lu
Ii0+c2luX2ZhbWlseS4NCi0gRml4IHhmc3Rlc3RzIGZhaWx1cmVzIGR1ZSB0byBpbmNvcnJlY3Qg
Y29weV9maWxlX3JhbmdlKCkgcmV0dXJuIHZhbHVlcw0KDQotLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQpDaHVjayBMZXZlciAo
Mik6DQogICAgICBORlM6IEZpeCBoYW5kbGluZyBvZiByZXBseSBwYWdlIHZlY3Rvcg0KICAgICAg
eHBydHJkbWE6IEZpeCBoZWxwZXIgdGhhdCBkcmFpbnMgdGhlIHRyYW5zcG9ydA0KDQpPbGdhIEtv
cm5pZXZza2FpYSAoMSk6DQogICAgICBORlN2NC4xIGZpeCBpbmNvcnJlY3QgcmV0dXJuIHZhbHVl
IGluIGNvcHlfZmlsZV9yYW5nZQ0KDQpUZXRzdW8gSGFuZGEgKDEpOg0KICAgICAgTkZTOiBGb3Ji
aWQgc2V0dGluZyBBRl9JTkVUNiB0byAic3RydWN0IHNvY2thZGRyX2luIi0+c2luX2ZhbWlseS4N
Cg0KVHJvbmQgTXlrbGVidXN0ICgxKToNCiAgICAgIFJldmVydCAiU1VOUlBDOiBNaWNyby1vcHRp
bWlzZSB3aGVuIHRoZSB0YXNrIGlzIGtub3duIG5vdCB0byBiZSBzbGVlcGluZyINCg0KIGZzL25m
cy9uZnM0MnByb2MuYyAgICAgICAgICAgfCAgMyAtLS0NCiBmcy9uZnMvbmZzNGZpbGUuYyAgICAg
ICAgICAgIHwgIDQgKysrLQ0KIGZzL25mcy9uZnM0eGRyLmMgICAgICAgICAgICAgfCAgNCArKy0t
DQogZnMvbmZzL3N1cGVyLmMgICAgICAgICAgICAgICB8ICAzICsrLQ0KIGluY2x1ZGUvbGludXgv
c3VucnBjL3NjaGVkLmggfCAgOCAtLS0tLS0tLQ0KIG5ldC9zdW5ycGMvY2xudC5jICAgICAgICAg
ICAgfCA0NSArKysrKysrKy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KIG5l
dC9zdW5ycGMveHBydHJkbWEvdmVyYnMuYyAgfCAgMiArLQ0KIDcgZmlsZXMgY2hhbmdlZCwgMTYg
aW5zZXJ0aW9ucygrKSwgNTMgZGVsZXRpb25zKC0pDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpM
aW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RA
aGFtbWVyc3BhY2UuY29tDQoNCg0K
