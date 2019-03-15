Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA172C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:54:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9C7F5218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 17:54:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="m9CwSPva"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726575AbfCORyy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 13:54:54 -0400
Received: from mail-eopbgr760108.outbound.protection.outlook.com ([40.107.76.108]:43374
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726549AbfCORyy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Mar 2019 13:54:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=GGHmtantwUzwF6F/OHZCzQxwuiTBXXbaYaLnplNrf9g=;
 b=m9CwSPvanRxeFXLjlUPqP8bJvAopzQ4usZOmVso3Cnlh23xrJiEIOKBWBsqY/vPU8YO4BMZVbt/Vn5xSPsJxLDVYiKnl7WvecbR7LfpiymtK0iOTwKtWKM6/g3LmlA/tyBsxy4tD5FjirvC42R4l8HsA0+kngCc1rz6xqtSv1PM=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2446.namprd13.prod.outlook.com (52.135.95.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1730.7; Fri, 15 Mar 2019 17:54:48 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1730.003; Fri, 15 Mar 2019
 17:54:48 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "marc.c.dionne@gmail.com" <marc.c.dionne@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Hanging nfs mount - bisected to merge commit 06b5fc3ad94e
Thread-Topic: Hanging nfs mount - bisected to merge commit 06b5fc3ad94e
Thread-Index: AQHU2pyr+k1OoMdVHUaOmREwTzEX96YM+yAA
Date:   Fri, 15 Mar 2019 17:54:48 +0000
Message-ID: <0e15881e705bb78910d6f3032273491eb1d5f369.camel@hammerspace.com>
References: <CAB9dFduu5_UDP_G-QXiYCYMPoytMOJQJ5OxXB02rGtbfMXO5BQ@mail.gmail.com>
In-Reply-To: <CAB9dFduu5_UDP_G-QXiYCYMPoytMOJQJ5OxXB02rGtbfMXO5BQ@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bbf66256-4e02-4e76-af06-08d6a96f5105
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2446;
x-ms-traffictypediagnostic: SN6PR13MB2446:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB244661D440592B43235FB4F8B8440@SN6PR13MB2446.namprd13.prod.outlook.com>
x-forefront-prvs: 09778E995A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(136003)(39830400003)(396003)(366004)(346002)(189003)(199004)(6436002)(5660300002)(478600001)(6506007)(105586002)(106356001)(66066001)(2906002)(8936002)(86362001)(26005)(6116002)(53546011)(99286004)(3846002)(71190400001)(71200400001)(76176011)(2501003)(6486002)(2201001)(229853002)(102836004)(966005)(14454004)(25786009)(97736004)(14444005)(256004)(68736007)(6246003)(6512007)(36756003)(118296001)(53936002)(7736002)(186003)(486006)(305945005)(476003)(81166006)(81156014)(8676002)(2616005)(316002)(11346002)(6306002)(446003)(110136005)(98903001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2446;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: rTGjRUKlX1EBrPnyxI4P2jW/k6Csuo+8or7jj364lgEYFJuX6FBjpdCyyFb6PmD9oGHIX2V/xtoQPVyj6Bkc4HvTAQwrJk0kgX9zfnIxsvsrVK+rByKXrW74aJi9vg7Wrek8cE53Sfgz682Gg3/oqDUTy4/MSVnMQjxw9xTNw6EGHhvVrtDRk2BRQ5H4Mq2t7z3BE5TtWFR5sNBXE62g6iYw8b7GwTzA5I3QuNRHvZKj7zpzmhb7PB6ryqSxtspbpoFPzkexql5/8UjOQcvGx4t1su5Snh61lWJ/h24Gw0pGxNPpkrIBXe1aYuHdA33cKwAQEjrlog/rfyboFa6aOGxCrQMvr31VR5VSTzakZsyLY9xcVnUIm2FQDy+izRBVjVFl9IRVuv2i6HjJDPLWSKhAg3mRi4rOP4yoid//lkU=
Content-Type: text/plain; charset="utf-8"
Content-ID: <E7EAC5D7DF76AD488F9341CE9060E7C3@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: bbf66256-4e02-4e76-af06-08d6a96f5105
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Mar 2019 17:54:48.4053
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2446
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTWFyYw0KDQpPbiBUaHUsIDIwMTktMDMtMTQgYXQgMTY6MzIgLTAzMDAsIE1hcmMgRGlvbm5l
IHdyb3RlOg0KPiBJIGhhdmUgYW4gb2RkIG5mcyBpc3N1ZSB3aXRoIHRoZSBjdXJyZW50IG1haW5s
aW5lIGtlcm5lbCwgd2hlcmUgYQ0KPiBtb3VudCBoYW5ncyBhbmQgZXZlbnR1YWxseSB0aW1lcyBv
dXQgd2hlbiBhdHRlbXB0aW5nIGEgbW91bnQgd2l0aCBuZnMNCj4gdmVyc2lvbiA0IGFuZCB0aGF0
IGlzIG5vdCBvZmZlcmVkIGJ5IHRoZSBzZXJ2ZXIuICBXaXRoIHByaW9yIGtlcm5lbHMNCj4gaXQg
ZmFpbHMgcXVpY2tseSB3aXRoICJtb3VudC5uZnM6IFByb3RvY29sIG5vdCBzdXBwb3J0ZWQiLg0K
PiANCj4gVG8gcmVwcm9kdWNlLCBJIGhhdmUgcnBjLm5mc2Qgc3RhcnQgd2l0aCAiLU4gNCIsIHRo
ZW4gdHJ5IHRvIG1vdW50DQo+IHNvbWV0aGluZyBsb2NhbCB3aXRoIC1vIG5mc3ZlcnM9NCwgZm9y
IGluc3RhbmNlOg0KPiAgICQgbW91bnQgLXQgbmZzIC1vIG5mc3ZlcnM9NCBsb2NhbGhvc3Q6L3Mg
L21udA0KPiANCj4gSSBiaXNlY3RlZCB0aGUgYmVoYXZpb3VyIGRvd24gdG8gY29tbWl0IDA2YjVm
YzNhZDk0ZSAoIk1lcmdlIHRhZw0KPiAnbmZzLXJkbWEtZm9yLTUuMS0xJyBvZg0KPiBnaXQ6Ly9n
aXQubGludXgtbmZzLm9yZy9wcm9qZWN0cy9hbm5hL2xpbnV4LW5mcyIpLiAgSXQncyBhIG1lcmdl
DQo+IGNvbW1pdCwgYnV0IG9uZSB0aGF0IGhhcyBxdWl0ZSBhIGJpdCBvZiBjb25mbGljdCByZXNv
bHV0aW9uLiAgSSBhbHNvDQo+IHZlcmlmaWVkIHRoYXQgdGhlIDIgcGFyZW50IGNvbW1pdHMgb2Yg
dGhlIG1lcmdlICg1MDg1NjA3ZDIwOTEgYW5kDQo+IDJjOTRiOGVjYTFhMikgYm90aCBiZWhhdmUg
YXMgb2xkIGtlcm5lbHMgZGlkLg0KPiANCj4gVGhhbmtzDQo+IE1hcmMNCg0KQ2FuIHlvdSBwbGVh
c2UgY2hlY2sgaWYgdGhlIGZvbGxvd2luZyBwYXRjaCBhbmQvb3IgdGhlICd0ZXN0aW5nJyBicmFu
Y2gNCmluIA0KaHR0cDovL2dpdC5saW51eC1uZnMub3JnLz9wPXRyb25kbXkvbGludXgtbmZzLmdp
dDthPXNob3J0bG9nO2g9cmVmcy9oZWFkcy90ZXN0aW5nDQpmaXhlcyB0aGUgaXNzdWU/DQoNClRo
YW5rcw0KICBUcm9uZA0KODwtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tDQpGcm9tIDUxMzE0OTYwN2QxOWJjMzgyMTM4NmZiNWFjNzVmOGI5OWZkNGIxMTUgTW9u
IFNlcCAxNyAwMDowMDowMCAyMDAxDQpGcm9tOiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xl
YnVzdEBoYW1tZXJzcGFjZS5jb20+DQpEYXRlOiBGcmksIDE1IE1hciAyMDE5IDEyOjU1OjU5IC0w
NDAwDQpTdWJqZWN0OiBbUEFUQ0ggMi82XSBTVU5SUEM6IEZpeCB0aGUgbWluaW1hbCBzaXplIGZv
ciByZXBseSBidWZmZXIgYWxsb2NhdGlvbg0KDQpXZSBtdXN0IGF0IG1pbmltdW0gYWxsb2NhdGUg
ZW5vdWdoIG1lbW9yeSB0byBiZSBhYmxlIHRvIHNlZSBhbnkgYXV0aA0KZXJyb3JzIGluIHRoZSBy
ZXBseSBmcm9tIHRoZSBzZXJ2ZXIuDQoNCkZpeGVzOiAyYzk0YjhlY2ExYTI2ICgiU1VOUlBDOiBV
c2UgYXVfcnNsYWNrIHdoZW4gY29tcHV0aW5nIHJlcGx5Li4uIikNClNpZ25lZC1vZmYtYnk6IFRy
b25kIE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCi0tLQ0KIG5l
dC9zdW5ycGMvY2xudC5jIHwgNyArKysrKystDQogMSBmaWxlIGNoYW5nZWQsIDYgaW5zZXJ0aW9u
cygrKSwgMSBkZWxldGlvbigtKQ0KDQpkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy9jbG50LmMgYi9u
ZXQvc3VucnBjL2NsbnQuYw0KaW5kZXggNDIxNmZlMzMyMDRhLi4zMTA4NzM4OTU1NzggMTAwNjQ0
DQotLS0gYS9uZXQvc3VucnBjL2NsbnQuYw0KKysrIGIvbmV0L3N1bnJwYy9jbG50LmMNCkBAIC0x
NzMwLDcgKzE3MzAsMTIgQEAgY2FsbF9hbGxvY2F0ZShzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2spDQog
CXJlcS0+cnFfY2FsbHNpemUgPSBSUENfQ0FMTEhEUlNJWkUgKyAoYXV0aC0+YXVfY3NsYWNrIDw8
IDEpICsNCiAJCQkgICBwcm9jLT5wX2FyZ2xlbjsNCiAJcmVxLT5ycV9jYWxsc2l6ZSA8PD0gMjsN
Ci0JcmVxLT5ycV9yY3ZzaXplID0gUlBDX1JFUEhEUlNJWkUgKyBhdXRoLT5hdV9yc2xhY2sgKyBw
cm9jLT5wX3JlcGxlbjsNCisJLyoNCisJICogTm90ZTogdGhlIHJlcGx5IGJ1ZmZlciBtdXN0IGF0
IG1pbmltdW0gYWxsb2NhdGUgZW5vdWdoIHNwYWNlDQorCSAqIGZvciB0aGUgJ3N0cnVjdCBhY2Nl
cHRlZF9yZXBseScgZnJvbSBSRkM1NTMxLg0KKwkgKi8NCisJcmVxLT5ycV9yY3ZzaXplID0gUlBD
X1JFUEhEUlNJWkUgKyBhdXRoLT5hdV9yc2xhY2sgKyBcDQorCQkJbWF4X3Qoc2l6ZV90LCBwcm9j
LT5wX3JlcGxlbiwgMik7DQogCXJlcS0+cnFfcmN2c2l6ZSA8PD0gMjsNCiANCiAJc3RhdHVzID0g
eHBydC0+b3BzLT5idWZfYWxsb2ModGFzayk7DQotLSANCjIuMjAuMQ0KDQotLSANClRyb25kIE15
a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQu
bXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
