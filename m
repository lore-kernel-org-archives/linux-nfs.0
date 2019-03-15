Return-Path: <SRS0=RY80=RS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBFB8C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 18:41:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9130C218A1
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Mar 2019 18:41:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="TMCRPZJ8"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726431AbfCOSlY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Mar 2019 14:41:24 -0400
Received: from mail-eopbgr770127.outbound.protection.outlook.com ([40.107.77.127]:6560
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726329AbfCOSlY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Mar 2019 14:41:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+7of1XXY6tOI8hKr8uzp8k8Na0mZKgs/+GHH/rJGARA=;
 b=TMCRPZJ8zyNwJe2qKNtbuWvTTztrBtY6/7pXbf0Gwlty1ZdgqSf990QR+FtaSLcwQ2MaiDsowBXS1HGz18sxpNs5d1RLo0sle3kIAkN1dR0tUSHTTpIrWYPwN8klku6KIiZt8HT8tlUMEY6NRNpt79JViddv7RkIlqCf8cnh1N4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2302.namprd13.prod.outlook.com (52.135.94.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.11; Fri, 15 Mar 2019 18:41:20 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1730.003; Fri, 15 Mar 2019
 18:41:20 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "jakub.kicinski@netronome.com" <jakub.kicinski@netronome.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: mount.nfs: Protocol error after upgrade to linux/master
Thread-Topic: mount.nfs: Protocol error after upgrade to linux/master
Thread-Index: AQHU21nAVbUikm+ruU2zAQUINtdA/KYNBqYA
Date:   Fri, 15 Mar 2019 18:41:20 +0000
Message-ID: <f74ac3d790748542914ca545a88d34e7cb644f33.camel@hammerspace.com>
References: <20190315110555.0807d015@cakuba.netronome.com>
In-Reply-To: <20190315110555.0807d015@cakuba.netronome.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 5db681e4-2b03-440e-9ad2-08d6a975d159
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2302;
x-ms-traffictypediagnostic: SN6PR13MB2302:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB23020A95957B47875B98A825B8440@SN6PR13MB2302.namprd13.prod.outlook.com>
x-forefront-prvs: 09778E995A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39830400003)(346002)(396003)(376002)(366004)(189003)(199004)(6116002)(5640700003)(6916009)(11346002)(66066001)(68736007)(6246003)(25786009)(4326008)(118296001)(81156014)(36756003)(81166006)(486006)(316002)(54906003)(4744005)(7736002)(305945005)(2906002)(105586002)(99286004)(8676002)(5660300002)(71200400001)(2351001)(71190400001)(106356001)(256004)(102836004)(86362001)(6486002)(476003)(2616005)(76176011)(8936002)(6506007)(26005)(6512007)(97736004)(966005)(229853002)(14454004)(186003)(3846002)(478600001)(6436002)(446003)(2501003)(53936002)(6306002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2302;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: UCjGZ5sPpiCAe/xLB4oKpyCDqHCXAec4OLib1qlvnJ4i+97sRv2Qhmed7oyoZaiMbP4dlwB+RjUAz+LZDbxDEsVqWxPP5k8RUqJnrxLw5EGqZxhD+a07IRMyB2MBKN12Erwym8zwFrVNHM/04/nqGXkEAwbOnEekD6OdA8Y4e5uOzS03456EkCwedI4mMJI4rt9ZKqJghIXPyBaUzKvURwpB0v9so9LvMeHi4kDcHMZWB7lDYPPGr6ehNwyhBUx5xRTqteO0MhY8UblQ6XA0DCENmXSp2SL1/2vPzDZFdA0igra8qSHvma3Zt5pwxeM9jaKe6SOfG+K2MpEB0EaJcp80UEpxQytHkG11BMH6Hxngodn2M66AjHqoLSHtiRQ2sMwMs6z8a5L98w+9p848RFHSI/xBaqvQlPhRXWQaTTc=
Content-Type: text/plain; charset="utf-8"
Content-ID: <2DD532BFE66C2142B6894D8746D43C9C@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5db681e4-2b03-440e-9ad2-08d6a975d159
X-MS-Exchange-CrossTenant-originalarrivaltime: 15 Mar 2019 18:41:20.6891
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2302
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE5LTAzLTE1IGF0IDExOjA1IC0wNzAwLCBKYWt1YiBLaWNpbnNraSB3cm90ZToN
Cj4gSGksDQo+IA0KPiBJIGp1c3QgdXBncmFkZWQgZnJvbToNCj4gDQo+IGNvbW1pdCBhM2IxOTMz
ZDM0ZDViYjI2ZDc1MDM3NTJlMzUyODMxNWE5ZTI4MzM5IChuZXQpDQo+IE1lcmdlOiBjNjg3M2Qx
OGNiNGEgMjQzMTkyNTg2NjBhDQo+IEF1dGhvcjogRGF2aWQgUy4gTWlsbGVyIDxkYXZlbUBkYXZl
bWxvZnQubmV0Pg0KPiBEYXRlOiAgIE1vbiBNYXIgMTEgMTY6MjI6NDkgMjAxOSAtMDcwMA0KPiAN
Cj4gdG8NCj4gDQo+IGNvbW1pdCAzYjMxOWVlMjIwYTg3OTU0MDY4NTJhODk3Mjk5ZGJkZmMxYjA5
OTExDQo+IE1lcmdlOiA5MzUyY2E1ODViMmEgYjZlODgxMTlmMWVkDQo+IEF1dGhvcjogTGludXMg
VG9ydmFsZHMgPHRvcnZhbGRzQGxpbnV4LWZvdW5kYXRpb24ub3JnPg0KPiBEYXRlOiAgIFRodSBN
YXIgMTQgMTA6NDg6MTQgMjAxOSAtMDcwMA0KPiANCj4gYW5kIEknbSBzZWVpbmc6DQo+IA0KPiAj
IG1vdW50IC9ob21lLw0KPiBtb3VudC5uZnM6IFByb3RvY29sIGVycm9yDQo+IA0KPiBObyBlcnJv
cnMgaW4gZG1lc2csIHBsZWFzZSBsZXQgbWUga25vdyBpZiBpdCdzIGEga25vd24gcHJvYmxlbSBv
cg0KPiB3aGF0DQo+IG90aGVyIGluZm8gY291bGQgYmUgb2YgdXNlLg0KDQpJdCBzb3VuZHMgbGlr
ZSB0aGUgZXhhY3Qgc2FtZSBwcm9ibGVtIHRoYXQgTWFyYyBEaW9ubmUgcmVwb3J0ZWQgc2VlaW5n
Lg0KQ2FuIHlvdSBhbHNvIHRyeSB0aGUgcGF0Y2ggYXQgDQpodHRwOi8vZ2l0LmxpbnV4LW5mcy5v
cmcvP3A9dHJvbmRteS9saW51eC1uZnMuZ2l0O2E9cGF0Y2g7aD01MTMxNDk2MDdkMTliYzM4MjEz
ODZmYjVhYzc1ZjhiOTlmZDRiMTE1DQo/DQoNClRoYW5rcw0KICBUcm9uZA0KLS0gDQpUcm9uZCBN
eWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25k
Lm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
