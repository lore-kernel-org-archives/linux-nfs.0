Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 892FFC43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:49:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4D6E8217D9
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 16:49:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="aS5PDojK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728064AbeLSQtc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 11:49:32 -0500
Received: from mail-eopbgr680100.outbound.protection.outlook.com ([40.107.68.100]:4800
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729135AbeLSQtQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 19 Dec 2018 11:49:16 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=O0tc9hSaJCu7msphfklGQTxSSNukxAc0QuoY8lUjJN8=;
 b=aS5PDojKbQYKX2/fCupS9enpTMY/85iwR7hyUthL/RPYJRJ7w2ohsOkOu2eWcaKky09JpQX0QvscEqPGsS2o7GM0toroD9AyCVii+y3Gzft+USi2OyWzrhg6LKg4wITj8rPhrS/RLpYpSgqgZAdgB3ps5lsKMg/7W7imSfbMbIs=
Received: from BN7PR13MB2481.namprd13.prod.outlook.com (52.135.253.160) by
 BN7PR13MB2388.namprd13.prod.outlook.com (52.135.252.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.10; Wed, 19 Dec 2018 16:49:12 +0000
Received: from BN7PR13MB2481.namprd13.prod.outlook.com
 ([fe80::d14b:22e8:b0e3:a9ea]) by BN7PR13MB2481.namprd13.prod.outlook.com
 ([fe80::d14b:22e8:b0e3:a9ea%5]) with mapi id 15.20.1446.018; Wed, 19 Dec 2018
 16:49:11 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client  bugfixes
Thread-Topic: [GIT PULL] Please pull NFS client  bugfixes
Thread-Index: AQHUl7rEWKS2hhetX0evnKtSV/Xs9g==
Date:   Wed, 19 Dec 2018 16:49:11 +0000
Message-ID: <1d49def46ad91048c59da7b1f76f135ee1aa1060.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BN7PR13MB2388;6:FZ+5o0ifAgLzHwQQ/GHZQNcqod3yf+fXYNC9mTtDZRZcfPo9RhaOYniUenM+EPbcq6IMvEP79G7Q/2jCW8F8YqrOtcStpdZVXNcFWAlSV8+ugFcMPSACNm2+VFP21T0G8tgu8pblZZbdvm0XW1zNutLRVXHdxvK4iTk6bYOKJokh0SIFqF98Gg5H6lcffvr5usMKtO6wytxjatb5LHOv0DbTQpwrIGqBAkYwsykTF+YgAIYwy/d7+rfiXFxA7fgZMn+l0AmeUIIbehfjTMmaQI3y/BKwyH3ZEHkHzEqBb5jEAYioDOcZyxuAQl6H/CXXJ45qjUhRM1uPl+lVnzq0N3qTOQcGGWR28lQRv2HvhzjS/wMlD/4uu5YUJNKVZpR33jcrnrs6qbbDtKZcgAFBp/17z1gTwgEkZgKm8zsDs2VbDYU030NCchFfanDSOJ5l3pRCvJIBLzPKtbzMA4BQ+A==;5:ggcBjKEBcSwm8pFcMtp8pqX72pTzCObGUg9qhV+9wg6+AJVF3E1qiAaIn/wqbmAjmaEirJuDYWQfisLxRoy8Vjdr4aBhXgJY5MQDuRIsjCLrpUbuLbaANQkGOTQij7OEMZu1Ygc6K1RhMEi+QRZH7mH3Ufc8KmMbUQxR9aUvijI=;7:XxEOSWuDhO7IU0pC5EJBoMSPZnH7K3ojZjPTtuF7i5Nb9JF/aX5X4kIJtu571UfkK5mQe+OX96EvFSU2MdnOtMgEQuaTF9iHLt83nmosixvhBPOydg8UcRkgzifTu61SquRcNG3KxUGK2jF+zjFkGA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: f6cd354a-36df-4061-9158-08d665d1e716
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BN7PR13MB2388;
x-ms-traffictypediagnostic: BN7PR13MB2388:
x-microsoft-antispam-prvs: <BN7PR13MB2388759C5EB17226A40D96DEB8BE0@BN7PR13MB2388.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(6040522)(2401047)(8121501046)(5005006)(10201501046)(3002001)(93006095)(93001095)(3231475)(944501520)(52105112)(148016)(149066)(150057)(6041310)(20161123564045)(20161123562045)(20161123558120)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:BN7PR13MB2388;BCL:0;PCL:0;RULEID:;SRVR:BN7PR13MB2388;
x-forefront-prvs: 0891BC3F3D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(366004)(396003)(39830400003)(136003)(199004)(189003)(2351001)(71190400001)(71200400001)(99286004)(486006)(106356001)(2501003)(105586002)(97736004)(2616005)(4001150100001)(186003)(3846002)(6116002)(26005)(476003)(2906002)(102836004)(6506007)(14444005)(256004)(316002)(54906003)(81166006)(8676002)(8936002)(6436002)(14454004)(6512007)(1730700003)(5660300001)(68736007)(81156014)(25786009)(575784001)(86362001)(5640700003)(6486002)(478600001)(7736002)(305945005)(53936002)(66066001)(4326008)(118296001)(6916009)(36756003);DIR:OUT;SFP:1102;SCL:1;SRVR:BN7PR13MB2388;H:BN7PR13MB2481.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: E8ytFEALFa7m5grzq5pfdc8yIq88SG4+nxHckVol88OHdx2j41CbswKZ85JqnChIuspiPkWl3DF2UGBETTKjlXg6UOiiwlxQgJuq0/fpaD/lmBHQliL9jx9suSp4B/E/X5NlNzIlHZc9QwmXo3CBKpQ3w0xuQxIyVu22Ek/bAo0LNZGCXXgrhLj+XHXZz0SQzjb1YT64LTzlm5fjJfctUzXrkgNCgLIlDE6iFVYLaXPOWkuwhbsxyyvEnfMgohD87W8DNy5p8UaryflVwcCeMsXuwCp2pll6rVjyXrqE9N3C8pl6NagoV5aWtx2ZMLgP
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <F4EFBC8A7CDCFA43A812F7D81D031E99@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f6cd354a-36df-4061-9158-08d665d1e716
X-MS-Exchange-CrossTenant-originalarrivaltime: 19 Dec 2018 16:49:11.6548
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN7PR13MB2388
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGludXMsDQoNClRoZSBmb2xsb3dpbmcgMyBwYXRjaGVzIGZpeCBhIHJlZ3Jlc3Npb24gaW4g
dGhlIE5GUy9SUEMgVFBDIHJlLQ0KY29ubmVjdGlvbiBjb2RlIHdoaWNoIGNhbiBjYXVzZSB0aGUg
UlBDIHRyYW5zbWlzc2lvbiB0byBoYW5nLiBUaGUgaXNzdWUNCndhcyBkaXNjb3ZlcmVkIGJ5IERh
dmUgV3lzb2NoYW5za2kgbGFzdCB3ZWVrLg0KDQpXaXRoIHRoaXMgcHVsbCwgd2Ugc3RpbGwgaGF2
ZSBvbmUgbW9yZSByZWdyZXNzaW9uIHRvIGZpeC4gTUlQUyBpcw0Kc2VlaW5nIGRhdGEgY29ycnVw
dGlvbiBkdWUgdG8gdGhlIGZhY3QgdGhhdCB0aGUgaW92ZWNfaXRlciBjb2RlIGRvZXMNCm5vdCBh
cHBlYXIgdG8gY2FsbCBmbHVzaF9kY2FjaGVfcGFnZSgpIGFmdGVyIGNvcHlpbmcgZGF0YSBpbnRv
IHRoZSBidmVjDQpwYWdlcy4gV2UgbmVlZCBndWlkYW5jZSBmcm9tIEFsIGFzIHRvIGhvdyBoZSB3
YW50cyB0aGlzIGZpeGVkLg0KDQpDaGVlcnMNCiAgVHJvbmQNCg0KVGhlIGZvbGxvd2luZyBjaGFu
Z2VzIHNpbmNlIGNvbW1pdCA3NTY2ZWMzOTNmNDE2MTU3MmJhNmYxMWFkNTE3MWZkNWQ1OWIwZmJk
Og0KDQogIExpbnV4IDQuMjAtcmM3ICgyMDE4LTEyLTE2IDE1OjQ2OjU1IC0wODAwKQ0KDQphcmUg
YXZhaWxhYmxlIGluIHRoZSBHaXQgcmVwb3NpdG9yeSBhdDoNCg0KICBnaXQ6Ly9naXQubGludXgt
bmZzLm9yZy9wcm9qZWN0cy90cm9uZG15L2xpbnV4LW5mcy5naXQgdGFncy9uZnMtZm9yLTQuMjAt
Ng0KDQpmb3IgeW91IHRvIGZldGNoIGNoYW5nZXMgdXAgdG8gYWJjMTMyNzU3NzFmYWM3N2UyZDdi
MTI5YzI4OTUyMmRhY2I2NDRiNjoNCg0KICBTVU5SUEM6IFJlbW92ZSB4cHJ0X2Nvbm5lY3Rfc3Rh
dHVzKCkgKDIwMTgtMTItMTggMTE6MDQ6MTAgLTA1MDApDQoNCi0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NCk5GUyBjbGllbnQg
YnVnZml4ZXMgZm9yIExpbnV4IDQuMjANCg0KQnVnZml4ZXM6DQotIEZpeCBUQ1Agc29ja2V0IGRp
c2Nvbm5lY3Rpb24gcmFjZXMgYnkgZW5zdXJpbmcgd2UgYWx3YXlzIGNhbGwNCiAgeHBydF9kaXNj
b25uZWN0X2RvbmUoKSBhZnRlciByZWxlYXNpbmcgdGhlIHNvY2tldC4NCi0gRml4IGEgcmFjZSB3
aGVuIGNsZWFyaW5nIGJvdGggWFBSVF9DT05ORUNUSU5HIGFuZCBYUFJUX0xPQ0tFRA0KLSBSZW1v
dmUgeHBydF9jb25uZWN0X3N0YXR1cygpIHNvIGl0IGRvZXMgbm90IG1hc2sgZXJyb3JzIHRoYXQg
c2hvdWxkDQogIGJlIGhhbmRsZWQgYnkgY2FsbF9jb25uZWN0X3N0YXR1cygpDQoNCi0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0N
ClRyb25kIE15a2xlYnVzdCAoMyk6DQogICAgICBTVU5SUEM6IEZpeCBkaXNjb25uZWN0aW9uIHJh
Y2VzDQogICAgICBTVU5SUEM6IEZpeCBhIHJhY2Ugd2l0aCBYUFJUX0NPTk5FQ1RJTkcNCiAgICAg
IFNVTlJQQzogUmVtb3ZlIHhwcnRfY29ubmVjdF9zdGF0dXMoKQ0KDQogbmV0L3N1bnJwYy9jbG50
LmMgICAgIHwgIDEgKw0KIG5ldC9zdW5ycGMveHBydC5jICAgICB8IDM1ICsrKystLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tDQogbmV0L3N1bnJwYy94cHJ0c29jay5jIHwgMTAgKysrKy0t
LS0tLQ0KIDMgZmlsZXMgY2hhbmdlZCwgOSBpbnNlcnRpb25zKCspLCAzNyBkZWxldGlvbnMoLSkN
Cg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFt
bWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
