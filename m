Return-Path: <SRS0=9Ter=N7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63C6EC46475
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 21:19:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EAD892080F
	for <linux-nfs@archiver.kernel.org>; Tue, 20 Nov 2018 21:18:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="dDIF8yDi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAD892080F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725926AbeKUHuH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 21 Nov 2018 02:50:07 -0500
Received: from mail-eopbgr680134.outbound.protection.outlook.com ([40.107.68.134]:12352
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725887AbeKUHuH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Nov 2018 02:50:07 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=hDERy+xGImHMRijYCiQHZUw+Xagt0WT8H5imjv1l7oE=;
 b=dDIF8yDiirtc6NIS5go/eyJ7jGkMc3Uvhwcrea42aWgKWBfJ0Pl2/RVRgsYzLoVZ/QW/CNU4K9FDAiDoOeEQC1d+UGZV4r2EzNXUvEZZAWa0nA9Ed5Vrbt50gos1kYyzSAOtMQRCPeM53BxH8z4rI9mPllj3f/6WXirSyy2Yeuk=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2415.namprd13.prod.outlook.com (52.135.94.159) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1361.14; Tue, 20 Nov 2018 21:18:46 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1361.013; Tue, 20 Nov 2018
 21:18:46 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>,
        "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "rmacklem@uoguelph.ca" <rmacklem@uoguelph.ca>
Subject: Re: [PATCH] flexfiles: use per-mirror specified stateid for IO
Thread-Topic: [PATCH] flexfiles: use per-mirror specified stateid for IO
Thread-Index: AQHUeo/z5hiJo6+OSUSLioLVoqpV/6VZOBkA
Date:   Tue, 20 Nov 2018 21:18:46 +0000
Message-ID: <20dd91f5c12ce9312e5c955c3a94008c8315d478.camel@hammerspace.com>
References: <20181112135918.12011-1-tigran.mkrtchyan@desy.de>
In-Reply-To: <20181112135918.12011-1-tigran.mkrtchyan@desy.de>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2415;6:84i+2HihEVSpJh4LU6b+ZH1+SZORsmhne7CvWqW7pPUMtbPh7yF7b460yjXDq1qSD41f8rePmYFA6Mpik/yJCpodUFuj/LX1uShKFgpEfo/rsLFnHSdN0r8ciN+wIq9beYQuDCQECYHE1dEKVLi2e1X2KoBt1XkhOLzWYHC0bQiudw402pfvCj8cfvepJOvApt1vaUgLHAYctc9pMRlTsFo8KgDGFRiXYsIShP/ml74aQ4TOQN4TJO0XiMD4UWVhKSwY1RjRgzXFLneF0AgC00splBXRw4YxTuGsBzCmV3dw09zhszTL8dJXiXGX1DeJ4fRDn3nOe7UhhUQgMoXvJOppuDElk81KIMEXdpOk4MF6aQ9Qf6eEu7DJ8nWHujMiq622UNnF+iqZjqoNS5uiYM9HW1Vkc4Mpe67B0G8ELc+0X5Z7CepgBrGGZFnAowUefJkYVoBtsUVIDEyfu0vTcw==;5:DMeZXAxclmwdrRZ6kHcvA3YhMRdrDAZfU9CLKheHkibkjdNk6WZdFY+qSyp+yNwTLLvpZgmWsvxIDgmV3bqSnONzFir4/ebVNVPGlL4ArSNfmvNleUGKsK9+7kwb8jL+0yNtUTT4sp3KJ9tYCs+DkBaMi8byQe9+sEclY8qgnlI=;7:RmkZT98ZzBgvBzz/gvoaIEu68d0rlqmcd5mkMKcS5zd902EBYIH5unnilEb+Yx67+6nkNDKCBaUf00oeuCaER3Jk6HhHJ1HagfJ+hX0FAcHVk4CgaFxjzcPrkKrUnA0BqbvJMJoseak1QuIrmAC4mg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: e245868e-9fb5-468a-5267-08d64f2dc1ec
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2415;
x-ms-traffictypediagnostic: SN6PR13MB2415:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2415C8CBD5D27E0B43D50025B8D90@SN6PR13MB2415.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(10201501046)(3231442)(944501410)(52105112)(3002001)(93006095)(93001095)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123558120)(20161123560045)(20161123564045)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2415;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2415;
x-forefront-prvs: 08626BE3A5
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(376002)(136003)(39830400003)(366004)(189003)(199004)(4001150100001)(102836004)(26005)(6506007)(229853002)(186003)(71200400001)(2616005)(476003)(71190400001)(8676002)(99286004)(81156014)(14454004)(446003)(110136005)(11346002)(6486002)(118296001)(81166006)(2906002)(54906003)(36756003)(8936002)(316002)(6246003)(478600001)(5660300001)(66066001)(86362001)(2501003)(105586002)(4326008)(3846002)(305945005)(6116002)(97736004)(256004)(6436002)(53936002)(106356001)(76176011)(7736002)(6512007)(486006)(2900100001)(25786009)(68736007)(14444005);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2415;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 1ivhfJgSCrr2kbdQ5eeyzUR6GBhZTQ453zwnaf5v3wHZBqG9CGEhpsnIQG0VUhL6a92TrVykDrMGUx3+0jespgeX5qFMiMLG0sIHrlEGpFIOG9Ed/2YVO9cADVWFthRJwSY4QLnuVpBL21Rfu1vB16jbaeFu8n43th7Mw9CaKKQWHQspS+EGFjJw42s6xOcTxGTu4rxezwTHLRBJcEH632QKWUr4PuUblK/jHlpr5qmESxCn3cQHXK5gNkOX4DY6BRVRoYOEYYzpKH40X4AYF3FtJxUJHKpN/sK9FV/uHLT14rtyQX3B2y9/7XGwjy9NSxiVFEf4DK4nck16ynhTmYrBNvr+gnR1wag+EEaVIK4=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <0F6DCC1D4C0F78499FD6F52209C977C1@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e245868e-9fb5-468a-5267-08d64f2dc1ec
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Nov 2018 21:18:46.3455
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2415
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgVGlncmFuLA0KDQpPbiBNb24sIDIwMTgtMTEtMTIgYXQgMTQ6NTkgKzAxMDAsIFRpZ3JhbiBN
a3J0Y2h5YW4gd3JvdGU6DQo+IHJmYzg0MzUgc2F5czoNCj4gDQo+ICAgRm9yIHRpZ2h0IGNvdXBs
aW5nLCBmZmRzX3N0YXRlaWQgcHJvdmlkZXMgdGhlIHN0YXRlaWQgdG8gYmUgdXNlZCBieQ0KPiAg
IHRoZSBjbGllbnQgdG8gYWNjZXNzIHRoZSBmaWxlLg0KPiANCj4gSG93ZXZlciBjdXJyZW50IGlt
cGxlbWVudGF0aW9uIHJlcGxhY2VzIHBlci1taXJyb3IgcHJvdmlkZWQgc3RhdGVpZA0KPiB3aXRo
DQo+IGJ5IG9wZW4gb3IgbG9jayBzdGF0ZWlkLg0KPiANCj4gRW5zdXJlIHRoYXQgcGVyLW1pcnJv
ciBzdGF0ZWlkIGlzIHVzZWQgYnkgZmZfbGF5b3V0X3dyaXRlX3ByZXBhcmVfdjQNCj4gYW5kDQo+
IG5mczRfZmZfbGF5b3V0X3ByZXBhcmVfZHMuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBUaWdyYW4g
TWtydGNoeWFuIDx0aWdyYW4ubWtydGNoeWFuQGRlc3kuZGU+DQo+IFNpZ25lZC1vZmYtYnk6IFJp
Y2sgTWFja2xlbSA8cm1hY2tsZW1AdW9ndWVscGguY2E+DQo+IC0tLQ0KPiAgZnMvbmZzL2ZsZXhm
aWxlbGF5b3V0L2ZsZXhmaWxlbGF5b3V0LmMgICAgfCAyMSArKysrKysrKysrKysrLS0tLS0tLS0N
Cj4gIGZzL25mcy9mbGV4ZmlsZWxheW91dC9mbGV4ZmlsZWxheW91dC5oICAgIHwgIDIgKysNCj4g
IGZzL25mcy9mbGV4ZmlsZWxheW91dC9mbGV4ZmlsZWxheW91dGRldi5jIHwgMTcgKysrKysrKysr
KysrKysrKysNCj4gIDMgZmlsZXMgY2hhbmdlZCwgMzIgaW5zZXJ0aW9ucygrKSwgOCBkZWxldGlv
bnMoLSkNCj4gDQo+IGRpZmYgLS1naXQgYS9mcy9uZnMvZmxleGZpbGVsYXlvdXQvZmxleGZpbGVs
YXlvdXQuYw0KPiBiL2ZzL25mcy9mbGV4ZmlsZWxheW91dC9mbGV4ZmlsZWxheW91dC5jDQo+IGlu
ZGV4IDg2YmNiYTQwY2E2MS4uNGM3ZjA0MmRiOWM0IDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvZmxl
eGZpbGVsYXlvdXQvZmxleGZpbGVsYXlvdXQuYw0KPiArKysgYi9mcy9uZnMvZmxleGZpbGVsYXlv
dXQvZmxleGZpbGVsYXlvdXQuYw0KPiBAQCAtMTM2MywxMCArMTM2Myw2IEBAIHN0YXRpYyB2b2lk
IGZmX2xheW91dF9yZWFkX3ByZXBhcmVfdjQoc3RydWN0DQo+IHJwY190YXNrICp0YXNrLCB2b2lk
ICpkYXRhKQ0KPiAgDQo+ICAJaWYgKGZmX2xheW91dF9yZWFkX3ByZXBhcmVfY29tbW9uKHRhc2ss
IGhkcikpDQo+ICAJCXJldHVybjsNCj4gLQ0KPiAtCWlmIChuZnM0X3NldF9yd19zdGF0ZWlkKCZo
ZHItPmFyZ3Muc3RhdGVpZCwgaGRyLT5hcmdzLmNvbnRleHQsDQo+IC0JCQloZHItPmFyZ3MubG9j
a19jb250ZXh0LCBGTU9ERV9SRUFEKSA9PSAtRUlPKQ0KPiAtCQlycGNfZXhpdCh0YXNrLCAtRUlP
KTsgLyogbG9zdCBsb2NrLCB0ZXJtaW5hdGUgSS9PICovDQo+ICB9DQo+ICANCj4gIHN0YXRpYyB2
b2lkIGZmX2xheW91dF9yZWFkX2NhbGxfZG9uZShzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2ssIHZvaWQN
Cj4gKmRhdGEpDQo+IEBAIC0xNTQ0LDEwICsxNTQwLDYgQEAgc3RhdGljIHZvaWQgZmZfbGF5b3V0
X3dyaXRlX3ByZXBhcmVfdjQoc3RydWN0DQo+IHJwY190YXNrICp0YXNrLCB2b2lkICpkYXRhKQ0K
PiAgDQo+ICAJaWYgKGZmX2xheW91dF93cml0ZV9wcmVwYXJlX2NvbW1vbih0YXNrLCBoZHIpKQ0K
PiAgCQlyZXR1cm47DQo+IC0NCj4gLQlpZiAobmZzNF9zZXRfcndfc3RhdGVpZCgmaGRyLT5hcmdz
LnN0YXRlaWQsIGhkci0+YXJncy5jb250ZXh0LA0KPiAtCQkJaGRyLT5hcmdzLmxvY2tfY29udGV4
dCwgRk1PREVfV1JJVEUpID09IC1FSU8pDQo+IC0JCXJwY19leGl0KHRhc2ssIC1FSU8pOyAvKiBs
b3N0IGxvY2ssIHRlcm1pbmF0ZSBJL08gKi8NCj4gIH0NCj4gIA0KPiAgc3RhdGljIHZvaWQgZmZf
bGF5b3V0X3dyaXRlX2NhbGxfZG9uZShzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2ssIHZvaWQNCj4gKmRh
dGEpDQo+IEBAIC0xNzEzLDYgKzE3MDUsNyBAQCBmZl9sYXlvdXRfcmVhZF9wYWdlbGlzdChzdHJ1
Y3QgbmZzX3BnaW9faGVhZGVyDQo+ICpoZHIpDQo+ICAJdTMyIGlkeCA9IGhkci0+cGdpb19taXJy
b3JfaWR4Ow0KPiAgCWludCB2ZXJzOw0KPiAgCXN0cnVjdCBuZnNfZmggKmZoOw0KPiArCW5mczRf
c3RhdGVpZCAqc3RhdGVpZDsNCj4gIA0KPiAgCWRwcmludGsoIi0tPiAlcyBpbm8gJWx1IHBnYmFz
ZSAldSByZXEgJXp1QCVsbHVcbiIsDQo+ICAJCV9fZnVuY19fLCBoZHItPmlub2RlLT5pX2lubywN
Cj4gQEAgLTE3NDIsNiArMTczNSwxMiBAQCBmZl9sYXlvdXRfcmVhZF9wYWdlbGlzdChzdHJ1Y3Qg
bmZzX3BnaW9faGVhZGVyDQo+ICpoZHIpDQo+ICAJZmggPSBuZnM0X2ZmX2xheW91dF9zZWxlY3Rf
ZHNfZmgobHNlZywgaWR4KTsNCj4gIAlpZiAoZmgpDQo+ICAJCWhkci0+YXJncy5maCA9IGZoOw0K
PiArDQo+ICsJc3RhdGVpZCA9IG5mczRfZmZfbGF5b3V0X3NlbGVjdF9kc19zdGF0ZWlkKGxzZWcs
IGlkeCk7DQo+ICsJaWYgKCFzdGF0ZWlkKQ0KPiArCQlnb3RvIG91dF9mYWlsZWQ7DQo+ICsJbmZz
NF9zdGF0ZWlkX2NvcHkoJmhkci0+YXJncy5zdGF0ZWlkLCBzdGF0ZWlkKTsNCj4gKw0KPiAgCS8q
DQo+ICAJICogTm90ZSB0aGF0IGlmIHdlIGV2ZXIgZGVjaWRlIHRvIHNwbGl0IGFjcm9zcyBEU2Vz
LA0KPiAgCSAqIHRoZW4gd2UgbWF5IG5lZWQgdG8gaGFuZGxlIGRlbnNlLWxpa2Ugb2Zmc2V0cy4N
Cj4gQEAgLTE3NzQsNiArMTc3Myw3IEBAIGZmX2xheW91dF93cml0ZV9wYWdlbGlzdChzdHJ1Y3Qg
bmZzX3BnaW9faGVhZGVyDQo+ICpoZHIsIGludCBzeW5jKQ0KPiAgCWxvZmZfdCBvZmZzZXQgPSBo
ZHItPmFyZ3Mub2Zmc2V0Ow0KPiAgCWludCB2ZXJzOw0KPiAgCXN0cnVjdCBuZnNfZmggKmZoOw0K
PiArCW5mczRfc3RhdGVpZCAqc3RhdGVpZDsNCj4gIAlpbnQgaWR4ID0gaGRyLT5wZ2lvX21pcnJv
cl9pZHg7DQo+ICANCj4gIAlkcyA9IG5mczRfZmZfbGF5b3V0X3ByZXBhcmVfZHMobHNlZywgaWR4
LCB0cnVlKTsNCj4gQEAgLTE4MDQsNiArMTgwNCwxMSBAQCBmZl9sYXlvdXRfd3JpdGVfcGFnZWxp
c3Qoc3RydWN0DQo+IG5mc19wZ2lvX2hlYWRlciAqaGRyLCBpbnQgc3luYykNCj4gIAlpZiAoZmgp
DQo+ICAJCWhkci0+YXJncy5maCA9IGZoOw0KPiAgDQo+ICsJc3RhdGVpZCA9IG5mczRfZmZfbGF5
b3V0X3NlbGVjdF9kc19zdGF0ZWlkKGxzZWcsIGlkeCk7DQo+ICsJaWYgKCFzdGF0ZWlkKQ0KPiAr
CQlnb3RvIG91dF9mYWlsZWQ7DQo+ICsJbmZzNF9zdGF0ZWlkX2NvcHkoJmhkci0+YXJncy5zdGF0
ZWlkLCBzdGF0ZWlkKTsNCg0KU2luY2UgdGhlIGFib3ZlIDMgbGluZXMgYXJlIHJlcGVhdGVkIGZv
ciBib3RoIGZ1bmN0aW9ucywgYW5kIGFsc28gZm9yY2UNCnRoZSBzdGFjayBhbGxvY2F0aW9uIG9m
IGEgdGVtcG9yYXJ5IHBvaW50ZXIsIHdoeSBub3QganVzdCBoYXZlIHRoZQ0KbmZzNF9mZl9sYXlv
dXRfc2VsZWN0X2RzX3N0YXRlaWQoKSBjb3B5IHRoZSBzdGF0ZWlkPw0KDQo+ICsNCj4gIAkvKg0K
PiAgCSAqIE5vdGUgdGhhdCBpZiB3ZSBldmVyIGRlY2lkZSB0byBzcGxpdCBhY3Jvc3MgRFNlcywN
Cj4gIAkgKiB0aGVuIHdlIG1heSBuZWVkIHRvIGhhbmRsZSBkZW5zZS1saWtlIG9mZnNldHMuDQo+
IGRpZmYgLS1naXQgYS9mcy9uZnMvZmxleGZpbGVsYXlvdXQvZmxleGZpbGVsYXlvdXQuaA0KPiBi
L2ZzL25mcy9mbGV4ZmlsZWxheW91dC9mbGV4ZmlsZWxheW91dC5oDQo+IGluZGV4IDQxMTc5ODM0
NmU0OC4uZmRmYmNiNDcxOTk5IDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvZmxleGZpbGVsYXlvdXQv
ZmxleGZpbGVsYXlvdXQuaA0KPiArKysgYi9mcy9uZnMvZmxleGZpbGVsYXlvdXQvZmxleGZpbGVs
YXlvdXQuaA0KPiBAQCAtMjE1LDYgKzIxNSw4IEBAIHVuc2lnbmVkIGludCBmZl9sYXlvdXRfZmV0
Y2hfZHNfaW9lcnIoc3RydWN0DQo+IHBuZnNfbGF5b3V0X2hkciAqbG8sDQo+ICAJCXVuc2lnbmVk
IGludCBtYXhudW0pOw0KPiAgc3RydWN0IG5mc19maCAqDQo+ICBuZnM0X2ZmX2xheW91dF9zZWxl
Y3RfZHNfZmgoc3RydWN0IHBuZnNfbGF5b3V0X3NlZ21lbnQgKmxzZWcsIHUzMg0KPiBtaXJyb3Jf
aWR4KTsNCj4gK25mczRfc3RhdGVpZCAqDQo+ICtuZnM0X2ZmX2xheW91dF9zZWxlY3RfZHNfc3Rh
dGVpZChzdHJ1Y3QgcG5mc19sYXlvdXRfc2VnbWVudCAqbHNlZywNCj4gdTMyIG1pcnJvcl9pZHgp
Ow0KPiAgDQo+ICBzdHJ1Y3QgbmZzNF9wbmZzX2RzICoNCj4gIG5mczRfZmZfbGF5b3V0X3ByZXBh
cmVfZHMoc3RydWN0IHBuZnNfbGF5b3V0X3NlZ21lbnQgKmxzZWcsIHUzMg0KPiBkc19pZHgsDQo+
IGRpZmYgLS1naXQgYS9mcy9uZnMvZmxleGZpbGVsYXlvdXQvZmxleGZpbGVsYXlvdXRkZXYuYw0K
PiBiL2ZzL25mcy9mbGV4ZmlsZWxheW91dC9mbGV4ZmlsZWxheW91dGRldi5jDQo+IGluZGV4IDc0
ZDhkNTM1MjQzOC4uOTE3ODdjZjY4MDU3IDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvZmxleGZpbGVs
YXlvdXQvZmxleGZpbGVsYXlvdXRkZXYuYw0KPiArKysgYi9mcy9uZnMvZmxleGZpbGVsYXlvdXQv
ZmxleGZpbGVsYXlvdXRkZXYuYw0KPiBAQCAtMzcwLDYgKzM3MCwyMyBAQCBuZnM0X2ZmX2xheW91
dF9zZWxlY3RfZHNfZmgoc3RydWN0DQo+IHBuZnNfbGF5b3V0X3NlZ21lbnQgKmxzZWcsIHUzMiBt
aXJyb3JfaWR4KQ0KPiAgCXJldHVybiBmaDsNCj4gIH0NCj4gIA0KPiArbmZzNF9zdGF0ZWlkICoN
Cj4gK25mczRfZmZfbGF5b3V0X3NlbGVjdF9kc19zdGF0ZWlkKHN0cnVjdCBwbmZzX2xheW91dF9z
ZWdtZW50ICpsc2VnLA0KPiB1MzIgbWlycm9yX2lkeCkNCj4gK3sNCj4gKwlzdHJ1Y3QgbmZzNF9m
Zl9sYXlvdXRfbWlycm9yICptaXJyb3IgPSBGRl9MQVlPVVRfQ09NUChsc2VnLA0KPiBtaXJyb3Jf
aWR4KTsNCj4gKwluZnM0X3N0YXRlaWQgKnN0YXRlaWQgPSBOVUxMOw0KPiArDQo+ICsJaWYgKCFm
Zl9sYXlvdXRfbWlycm9yX3ZhbGlkKGxzZWcsIG1pcnJvciwgZmFsc2UpKSB7DQo+ICsJCXByX2Vy
cl9yYXRlbGltaXRlZCgiTkZTOiAlczogTm8gZGF0YSBzZXJ2ZXIgZm9yIG1pcnJvcg0KPiBvZmZz
ZXQgaW5kZXggJWRcbiIsDQo+ICsJCQlfX2Z1bmNfXywgbWlycm9yX2lkeCk7DQo+ICsJCWdvdG8g
b3V0Ow0KPiArCX0NCj4gKw0KPiArCXN0YXRlaWQgPSAmbWlycm9yLT5zdGF0ZWlkOw0KPiArb3V0
Og0KPiArCXJldHVybiBzdGF0ZWlkOw0KPiArfQ0KPiArDQo+ICAvKioNCj4gICAqIG5mczRfZmZf
bGF5b3V0X3ByZXBhcmVfZHMgLSBwcmVwYXJlIGEgRFMgY29ubmVjdGlvbiBmb3IgYW4gUlBDDQo+
IGNhbGwNCj4gICAqIEBsc2VnOiB0aGUgbGF5b3V0IHNlZ21lbnQgd2UncmUgb3BlcmF0aW5nIG9u
DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1t
ZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
