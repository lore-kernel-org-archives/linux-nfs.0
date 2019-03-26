Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PULL_REQUEST,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14632C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 20:12:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A84142070D
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 20:12:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="n+vEU/+x"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732414AbfCZUML (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 16:12:11 -0400
Received: from mail-eopbgr760121.outbound.protection.outlook.com ([40.107.76.121]:28355
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726207AbfCZUML (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 16:12:11 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Xbw1xYsN5fP5Hf626OWt7rIAcDGBzjDD5a6d2BeeQBA=;
 b=n+vEU/+xS9OTxnirbB6Ns6sKWirCkkmih9hpAokY1smVo8KXT9CIq6joLZa5X6PdSKZjBhTqwv/HzlEzVVzJF1f3fRI4Jm8MZ4Mx9vKTiJ5Z0hoH0hW8ChGiLABkkKbLHDOC3z/wgerVOTc/5oBPimt0oGfhj5iGsW2pJLFS238=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2397.namprd13.prod.outlook.com (52.135.94.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.15; Tue, 26 Mar 2019 20:12:07 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1750.013; Tue, 26 Mar 2019
 20:12:07 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client fixes
Thread-Topic: [GIT PULL] Please pull NFS client fixes
Thread-Index: AQHU5BAvup5HoM4wn0+jPp5aSsD9iA==
Date:   Tue, 26 Mar 2019 20:12:07 +0000
Message-ID: <938c564de7930769feacf1403fae0c9511f10993.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [65.158.186.241]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 73c66c42-6607-43d0-52cd-08d6b2275280
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(7021145)(8989299)(5600127)(711020)(4605104)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2397;
x-ms-traffictypediagnostic: SN6PR13MB2397:
x-microsoft-antispam-prvs: <SN6PR13MB23975FC9734C0158A6EDFA3CB85F0@SN6PR13MB2397.namprd13.prod.outlook.com>
x-forefront-prvs: 09888BC01D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(366004)(376002)(39830400003)(346002)(199004)(189003)(86362001)(2616005)(305945005)(36756003)(476003)(6916009)(54906003)(316002)(53936002)(2501003)(7736002)(6116002)(6512007)(508600001)(71200400001)(3846002)(14454004)(118296001)(71190400001)(4326008)(186003)(25786009)(66066001)(102836004)(8936002)(26005)(2906002)(256004)(106356001)(68736007)(97736004)(6436002)(6506007)(1730700003)(99286004)(5640700003)(8676002)(486006)(81156014)(2351001)(5660300002)(81166006)(6486002)(105586002)(14444005);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2397;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: mJXjtqK/03mLwz95gD1yTm94d4aPgfjhyjxeeiBZwS7ZxCUWaKCCFL8hOsr3NqdM+NKZXcwUqXIOP1xvU4sB0e19fu6jzae0ExC9UBJmGqZgfDGvxZW36ADFhYZDclVIMkQU1kAwV7C0n7Kp+d0FW59Y7asRE0Ztx7RQeT+KrpVOIInHp53hnI2fDLmcdVu+EQ8PNGBn/5S3idhik5IhhD0ZsgRKwP1SFaGjvB4SGf9bHbrdNd/PPYIaY9GaZW0EELy1SordNkWd9fBt8HAFK1feSsEr0kjRkZdxGOE3k3MWYNokvqKYxxXqP21wkOC0JaPvy0w19MK2PQz+H/7vAXLEws5ymXUmg0LI+PTvIDBPSYTF6ScIKTJk8hxQlX37nkIOxMWJqe2CSkOXazqaOPw7sjQTY7063LqfQ876cGQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <FCC77C697D5F454BA5E930B8C985CB97@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 73c66c42-6607-43d0-52cd-08d6b2275280
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Mar 2019 20:12:07.5392
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2397
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGludXMsDQoNClRoZSBmb2xsb3dpbmcgY2hhbmdlcyBzaW5jZSBjb21taXQgOWU5OGM2Nzhj
MmQ2YWUzYTE3Y2IyZGU1NWQxN2Y2OWRkZGFhMjMxYjoNCg0KICBMaW51eCA1LjEtcmMxICgyMDE5
LTAzLTE3IDE0OjIyOjI2IC0wNzAwKQ0KDQphcmUgYXZhaWxhYmxlIGluIHRoZSBHaXQgcmVwb3Np
dG9yeSBhdDoNCg0KICBnaXQ6Ly9naXQubGludXgtbmZzLm9yZy9wcm9qZWN0cy90cm9uZG15L2xp
bnV4LW5mcy5naXQgdGFncy9uZnMtZm9yLTUuMS0zDQoNCmZvciB5b3UgdG8gZmV0Y2ggY2hhbmdl
cyB1cCB0byAwMWYyZjViODJhMmI1MjNhZTc2YWY1M2YyZmY0M2M0OGRkZTEwYTAwOg0KDQogIFNV
TlJQQzogZml4IHVuaW5pdGlhbGl6ZWQgdmFyaWFibGUgd2FybmluZyAoMjAxOS0wMy0yNiAxMzow
NDozMiAtMDcwMCkNCg0KLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KTkZTIGNsaWVudCBidWdmaXhlcyBmb3IgTGludXggNS4x
DQoNCkhpZ2hsaWdodHMgaW5jbHVkZToNCg0KU3RhYmxlIGZpeGVzOg0KLSBGaXggbmZzNF9sb2Nr
X3N0YXRlIHJlZmNvdW50aW5nIGluIG5mczRfYWxsb2Nfe2xvY2ssdW5sb2NrfWRhdGEoKQ0KLSBm
aXggbW91bnQvdW1vdW50IHJhY2UgaW4gbmxtY2xudC4NCi0gTkZTdjQuMSBkb24ndCBmcmVlIGlu
dGVycnVwdGVkIHNsb3Qgb24gb3Blbg0KDQpCdWdmaXhlczoNCi0gRG9uJ3QgbGV0IFJQQ19TT0ZU
Q09OTiB0YXNrcyB0aW1lIG91dCBpZiB0aGUgdHJhbnNwb3J0IGlzIGNvbm5lY3RlZA0KLSBGaXgg
YSB0eXBvIGluIG5mc19pbml0X3RpbWVvdXRfdmFsdWVzKCkNCi0gRml4IGxheW91dHN0YXRzIGhh
bmRsaW5nIGR1cmluZyByZWFkIGZhaWxvdmVycw0KLSBmaXggdW5pbml0aWFsaXplZCB2YXJpYWJs
ZSB3YXJuaW5nDQoNCi0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0NCkFsYWtlc2ggSGFsb2kgKDEpOg0KICAgICAgU1VOUlBDOiBm
aXggdW5pbml0aWFsaXplZCB2YXJpYWJsZSB3YXJuaW5nDQoNCkNhdGFsaW4gTWFyaW5hcyAoMSk6
DQogICAgICBORlM6IEZpeCBuZnM0X2xvY2tfc3RhdGUgcmVmY291bnRpbmcgaW4gbmZzNF9hbGxv
Y197bG9jayx1bmxvY2t9ZGF0YSgpDQoNCk5laWxCcm93biAoMSk6DQogICAgICBORlM6IGZpeCBt
b3VudC91bW91bnQgcmFjZSBpbiBubG1jbG50Lg0KDQpPbGdhIEtvcm5pZXZza2FpYSAoMSk6DQog
ICAgICBORlN2NC4xIGRvbid0IGZyZWUgaW50ZXJydXB0ZWQgc2xvdCBvbiBvcGVuDQoNClRyb25k
IE15a2xlYnVzdCAoMyk6DQogICAgICBTVU5SUEM6IERvbid0IGxldCBSUENfU09GVENPTk4gdGFz
a3MgdGltZSBvdXQgaWYgdGhlIHRyYW5zcG9ydCBpcyBjb25uZWN0ZWQNCiAgICAgIE5GUzogRml4
IGEgdHlwbyBpbiBuZnNfaW5pdF90aW1lb3V0X3ZhbHVlcygpDQogICAgICBwTkZTL2ZsZXhmaWxl
czogRml4IGxheW91dHN0YXRzIGhhbmRsaW5nIGR1cmluZyByZWFkIGZhaWxvdmVycw0KDQogZnMv
bG9ja2QvaG9zdC5jICAgICAgICAgICAgICAgICAgICAgICAgfCAgMyArLS0NCiBmcy9uZnMvY2xp
ZW50LmMgICAgICAgICAgICAgICAgICAgICAgICB8ICAyICstDQogZnMvbmZzL2ZsZXhmaWxlbGF5
b3V0L2ZsZXhmaWxlbGF5b3V0LmMgfCAgNSArKysrLQ0KIGZzL25mcy9uZnM0cHJvYy5jICAgICAg
ICAgICAgICAgICAgICAgIHwgIDUgKystLS0NCiBuZXQvc3VucnBjL2NsbnQuYyAgICAgICAgICAg
ICAgICAgICAgICB8IDEyICsrKysrKysrKysrLQ0KIG5ldC9zdW5ycGMveHBydHNvY2suYyAgICAg
ICAgICAgICAgICAgIHwgIDQgKystLQ0KIDYgZmlsZXMgY2hhbmdlZCwgMjEgaW5zZXJ0aW9ucygr
KSwgMTAgZGVsZXRpb25zKC0pDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVu
dCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNv
bQ0KDQoNCg==
