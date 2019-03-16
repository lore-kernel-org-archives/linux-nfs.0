Return-Path: <SRS0=f8xw=RT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41464C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 18:33:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EE541206BA
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Mar 2019 18:33:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="ZsBJ7+F0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726629AbfCPSdi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Mar 2019 14:33:38 -0400
Received: from mail-eopbgr720099.outbound.protection.outlook.com ([40.107.72.99]:64160
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726578AbfCPSdh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 16 Mar 2019 14:33:37 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=X300Hd0ekVX5uZPRDxdJnt32j5AIQKi8YG4NtYg63HI=;
 b=ZsBJ7+F0vkSXnqgTOcUboYFh5pBsvm7/ce1hzdKfEJb5bszviC6cKu5GuiMBCpYrR0taDt9vSdf9tjt8/q88v34pp2YRaM0p5UZ9ZXpfmgYvCs2uD0IMVhB+pShjw/8QVb3FYFUA+1uDU7BWIrtv/tW+n6wfTIMyG/WincN0IFU=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2254.namprd13.prod.outlook.com (52.135.93.155) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.7; Sat, 16 Mar 2019 18:33:33 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1730.003; Sat, 16 Mar 2019
 18:33:33 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfixes for 5.1
Thread-Topic: [GIT PULL] Please pull NFS client bugfixes for 5.1
Thread-Index: AQHU3CbCoviNcgOOW0+w8ft5Rig7pQ==
Date:   Sat, 16 Mar 2019 18:33:33 +0000
Message-ID: <3a30ab7dd854db06aca0a5f70b66e54cb9415c6e.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 4a905429-bf8e-494a-4204-08d6aa3de55d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2254;
x-ms-traffictypediagnostic: SN6PR13MB2254:
x-microsoft-antispam-prvs: <SN6PR13MB2254A846A4DE44AFBDE91E41B8450@SN6PR13MB2254.namprd13.prod.outlook.com>
x-forefront-prvs: 09781D4C35
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(366004)(346002)(376002)(39830400003)(199004)(189003)(86362001)(106356001)(68736007)(81166006)(256004)(25786009)(14444005)(186003)(4326008)(71190400001)(486006)(36756003)(2616005)(99286004)(105586002)(476003)(2351001)(66066001)(26005)(71200400001)(6506007)(102836004)(1730700003)(5660300002)(305945005)(7736002)(118296001)(14454004)(97736004)(81156014)(8676002)(54906003)(316002)(2501003)(8936002)(478600001)(6916009)(6512007)(2906002)(53936002)(5640700003)(6116002)(3846002)(6486002)(6436002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2254;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 7MxK7/bLVMEIL6F85fhoiQffEFPRQT9yqJWUiQQ4CS8BWKFPdZ17jU4oB6xzBgmqW9iC33V3IoHCWHXKdDho0ERFWH8Lwla3Qj3M2hpWUdmTuqCWqQ6qCKfKm6uwmN4KcAnd1c3U4hM+jAHK1vX2eFxAnawj9P04RmKEgQ7uIqjwRROkFkPs4rSKSFM20gToFTvbWlSBERilpZ2CwOpTrE/UWtL0tj0aYYGWlhZQfa2zPg4ONSciz7l0LMx+c86Cw4kyNvneZZpe/fjSnyNuSgiWvAj9dGHSBrVvBitTtgbEro6a3JhQl+5Sd41JCNo0Pl2HJmn4HDYVmzLpKhgKyNfi4+mDEhxxi61RrReJHF79+YKh753tJcrmk+HIYm3oz8PsYDKUNcq+W57VfPNb7iD1h8uwL2lcfqTAZzsV88E=
Content-Type: text/plain; charset="utf-8"
Content-ID: <0BFE8AEFD586C4468443CA101A5C7935@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4a905429-bf8e-494a-4204-08d6aa3de55d
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Mar 2019 18:33:33.5403
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2254
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGludXMsDQoNClRoZSBmb2xsb3dpbmcgY2hhbmdlcyBzaW5jZSBjb21taXQgNGQ2YzY3MWFj
ZTU2OWQ0YjBkM2Y4ZDkyYWIzYWVmMThhNWQxNjZiYzoNCg0KICBTVU5SUEM6IFRha2UgdGhlIHRy
YW5zcG9ydCBzZW5kIGxvY2sgYmVmb3JlIGJpbmRpbmcrY29ubmVjdGluZyAoMjAxOS0wMy0xMCAx
NDowODoxOSAtMDQwMCkNCg0KYXJlIGF2YWlsYWJsZSBpbiB0aGUgR2l0IHJlcG9zaXRvcnkgYXQ6
DQoNCiAgZ2l0Oi8vZ2l0LmxpbnV4LW5mcy5vcmcvcHJvamVjdHMvdHJvbmRteS9saW51eC1uZnMu
Z2l0IHRhZ3MvbmZzLWZvci01LjEtMg0KDQpmb3IgeW91IHRvIGZldGNoIGNoYW5nZXMgdXAgdG8g
NWUzODYzZmQ1OTdlYmE4YzY2NzlkZTgwNTY4MTYzMWIxYWFkOWJkYjoNCg0KICBTVU5SUEM6IFJl
bW92ZSByZWR1bmRhbnQgY2hlY2sgZm9yIHRoZSByZXBseSBsZW5ndGggaW4gY2FsbF9kZWNvZGUo
KSAoMjAxOS0wMy0xNSAxMzoxMTozNiAtMDQwMCkNCg0KQ2hlZXJzDQogIFRyb25kDQoNCi0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0NCk5GUyBjbGllbnQgYnVnZml4ZXMgZm9yIExpbnV4IDUuMQ0KDQpIaWdobGlnaHRzIGluY2x1
ZGU6DQoNCkJ1Z2ZpeGVzOg0KLSBGaXggYW4gT29wcyBpbiBTVU5SUEMgYmFjayBjaGFubmVsIHRy
YWNlcG9pbnRzDQotIEZpeCBhIFNVTlJQQyBjbGllbnQgcmVncmVzc2lvbiB3aGVuIGhhbmRsaW5n
IG92ZXJzaXplZCByZXBsaWVzDQotIEZpeCB0aGUgbWluaW1hbCBzaXplIGZvciBTVU5SUEMgcmVw
bHkgYnVmZmVyIGFsbG9jYXRpb24NCi0gcnBjX2RlY29kZV9oZWFkZXIoKSBtdXN0IGFsd2F5cyBy
ZXR1cm4gYSBub24temVybyB2YWx1ZSBvbiBlcnJvcg0KLSBGaXggYSB0eXBvIGluIHBuZnNfdXBk
YXRlX2xheW91dCgpDQoNCkNsZWFudXBzOg0KLSBSZW1vdmUgcmVkdW5kYW50IGNoZWNrIGZvciB0
aGUgcmVwbHkgbGVuZ3RoIGluIGNhbGxfZGVjb2RlKCkNCg0KLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KT2xnYSBLb3JuaWV2
c2thaWEgKDEpOg0KICAgICAgZml4IG51bGwgcG9pbnRlciBkZXJlZiBpbiB0cmFjZXBvaW50cyBp
biBiYWNrIGNoYW5uZWwNCg0KVHJvbmQgTXlrbGVidXN0ICg3KToNCiAgICAgIHBORlM6IEZpeCBh
IHR5cG8gaW4gcG5mc191cGRhdGVfbGF5b3V0DQogICAgICBTVU5SUEM6IEZpeCBhIGNsaWVudCBy
ZWdyZXNzaW9uIHdoZW4gaGFuZGxpbmcgb3ZlcnNpemVkIHJlcGxpZXMNCiAgICAgIFNVTlJQQzog
Rml4IHRoZSBtaW5pbWFsIHNpemUgZm9yIHJlcGx5IGJ1ZmZlciBhbGxvY2F0aW9uDQogICAgICBT
VU5SUEM6IFVzZSB0aGUgRU5PVENPTk4gZXJyb3Igb24gc29ja2V0IGRpc2Nvbm5lY3QNCiAgICAg
IFNVTlJQQzogcnBjX2RlY29kZV9oZWFkZXIoKSBtdXN0IGFsd2F5cyByZXR1cm4gYSBub24temVy
byB2YWx1ZSBvbiBlcnJvcg0KICAgICAgU1VOUlBDOiBIYW5kbGUgdGhlIFNZU1RFTV9FUlIgcnBj
IGVycm9yDQogICAgICBTVU5SUEM6IFJlbW92ZSByZWR1bmRhbnQgY2hlY2sgZm9yIHRoZSByZXBs
eSBsZW5ndGggaW4gY2FsbF9kZWNvZGUoKQ0KDQogZnMvbmZzL3BuZnMuYyAgICAgICAgICAgICAg
ICAgfCAgMiArLQ0KIGluY2x1ZGUvdHJhY2UvZXZlbnRzL3N1bnJwYy5oIHwgIDYgKysrKy0tDQog
bmV0L3N1bnJwYy9jbG50LmMgICAgICAgICAgICAgfCAzMiArKysrKysrKysrKysrKy0tLS0tLS0t
LS0tLS0tLS0tLQ0KIG5ldC9zdW5ycGMveHBydC5jICAgICAgICAgICAgIHwgIDIgKy0NCiBuZXQv
c3VucnBjL3hwcnRzb2NrLmMgICAgICAgICB8ICAyICstDQogNSBmaWxlcyBjaGFuZ2VkLCAyMSBp
bnNlcnRpb25zKCspLCAyMyBkZWxldGlvbnMoLSkNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51
eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFt
bWVyc3BhY2UuY29tDQoNCg0K
