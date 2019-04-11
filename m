Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6B259C10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 18:44:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 030102073F
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 18:44:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="FyreDEg9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726633AbfDKSoJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 14:44:09 -0400
Received: from mail-eopbgr680109.outbound.protection.outlook.com ([40.107.68.109]:13702
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726538AbfDKSoI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 Apr 2019 14:44:08 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=iPo82imjsXkpTXHmG2Oc9KWhms1f39wdyZCyIkfdmso=;
 b=FyreDEg97hgCbDfWuDA4byTnV85LDlaX3Bznm7fZZTVmkvNv3rI1gJ2ZPJRpN1Sa/6jBdfw77WdiVJpKgOfxMGHbr1QMfmgJDWM1d8DK2T/gCAYjmXxm/7w6Sf1GlXiBSuAaAyn8i3LJxFKpFPcOBDiv4slRByij2MPBGu2/Vis=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2559.namprd13.prod.outlook.com (52.135.96.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.11; Thu, 11 Apr 2019 18:44:04 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Thu, 11 Apr 2019
 18:44:04 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/1] NFSv4.1 fix incorrect return value in
 copy_file_range
Thread-Topic: [PATCH v2 1/1] NFSv4.1 fix incorrect return value in
 copy_file_range
Thread-Index: AQHU8JUzwhma4cEY3U2qDlNS1LmSZKY3S+UA
Date:   Thu, 11 Apr 2019 18:44:04 +0000
Message-ID: <7afe24dd8dde96696c479b5550a9fac88b3bd532.camel@hammerspace.com>
References: <20190411183418.4510-1-olga.kornievskaia@gmail.com>
In-Reply-To: <20190411183418.4510-1-olga.kornievskaia@gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 354222f0-e583-45f0-3979-08d6beadabf1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2559;
x-ms-traffictypediagnostic: SN6PR13MB2559:
x-microsoft-antispam-prvs: <SN6PR13MB2559BDBD058E33A6B434B399B82F0@SN6PR13MB2559.namprd13.prod.outlook.com>
x-forefront-prvs: 00046D390F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(39830400003)(136003)(346002)(396003)(189003)(199004)(11346002)(7736002)(76176011)(446003)(5660300002)(256004)(476003)(478600001)(106356001)(105586002)(71200400001)(6246003)(2906002)(14454004)(229853002)(2616005)(97736004)(486006)(14444005)(71190400001)(102836004)(6512007)(53936002)(68736007)(6506007)(81166006)(26005)(8676002)(25786009)(3846002)(86362001)(36756003)(6116002)(66066001)(8936002)(2501003)(99286004)(4326008)(118296001)(6436002)(81156014)(6486002)(305945005)(316002)(110136005)(186003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2559;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 6Cve17ZECzIjqf6QMVzx+UmgwiQuoGPIqD4Mn5y2QCTPpitXvCnIAsTBHHyiEYNXmPb5knGDGUhT7LrbgsqKUZfeFQs8WK0aC9MWDYadIIWKUn2MyFyl67G9svXYqTY6T66n2Hs0bOdDMj3rE/Lu7v2WAKeDYebKwUM03WEcjYv25KQghjOSq6WEnbDvvVOhg84Kn2LBDtzaOJM/eAfE1TPPdDWJd9OstC2MckT+V0jkjPDvm/2mVD3B41Fb4zMRqIhJileaqPumK5gwIPWOcvhm6R36Sk8HCSorQ/wTPAD37ULmD+cN5EwAsjbkJcsrrrqwx4hC9geX0lsInVq+tcN2hSvVRJ7r5VbpzgdF+NrDvaHr10dmhHY84J0bSEVP0TRJAdHd3O+Wyoq2ThLLtI2mMyKx4F9RSksfOEIow84=
Content-Type: text/plain; charset="utf-8"
Content-ID: <6B955F280CB28C448D3F8068A0D3E142@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 354222f0-e583-45f0-3979-08d6beadabf1
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Apr 2019 18:44:04.1175
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2559
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTA0LTExIGF0IDE0OjM0IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gRnJvbTogT2xnYSBLb3JuaWV2c2thaWEgPGtvbGdhQG5ldGFwcC5jb20+DQo+IA0KPiBB
Y2NvcmRpbmcgdG8gdGhlIE5GU3Y0LjIgc3BlYyBpZiB0aGUgaW5wdXQgYW5kIG91dHB1dCBmaWxl
IGlzIHRoZQ0KPiBzYW1lIGZpbGUsIG9wZXJhdGlvbiBzaG91bGQgZmFpbCB3aXRoIEVJTlZBTC4g
SG93ZXZlciwgbGludXgNCj4gY29weV9maWxlX3JhbmdlKCkgc3lzdGVtIGNhbGwgaGFzIG5vIHN1
Y2ggcmVzdHJpY3Rpb25zLiBUaGVyZWZvcmUsDQo+IGluIHN1Y2ggY2FzZSBsZXQncyByZXR1cm4g
RU9QTk9UU1VQUCBhbmQgYWxsb3cgVkZTIHRvIGZhbGxiYWNrDQo+IHRvIGRvaW5nIGRvX3NwbGlj
ZV9kaXJlY3QoKS4gQWxzbyB3aGVuIGNvcHlfZmlsZV9yYW5nZSBpcyBjYWxsZWQNCj4gb24gYW4g
TkZTdjQuMCBvciA0LjEgbW91bnQgKGllLiwgYSBzZXJ2ZXIgdGhhdCBkb2Vzbid0IHN1cHBvcnQN
Cj4gQ09QWSBmdW5jdGlvbmFsaXR5KSwgd2UgYWxzbyBuZWVkIHRvIHJldHVybiBFT1BOT1RTVVBQ
IGFuZA0KPiBmYWxsYmFjayB0byBhIHJlZ3VsYXIgY29weS4NCj4gDQo+IEZpeGVzIHhmc3Rlc3Qg
Z2VuZXJpYy8wNzUsIGdlbmVyaWMvMDkxLCBnZW5lcmljLzExMiwgZ2VuZXJpYy8yNjMNCj4gZm9y
IGFsbCBORlN2NC54IHZlcnNpb25zLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogT2xnYSBLb3JuaWV2
c2thaWEgPGtvbGdhQG5ldGFwcC5jb20+DQo+IC0tLQ0KPiAgZnMvbmZzL25mczQycHJvYy5jIHwg
MyAtLS0NCj4gIGZzL25mcy9uZnM0ZmlsZS5jICB8IDQgKysrLQ0KPiAgMiBmaWxlcyBjaGFuZ2Vk
LCAzIGluc2VydGlvbnMoKyksIDQgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMv
bmZzL25mczQycHJvYy5jIGIvZnMvbmZzL25mczQycHJvYy5jDQo+IGluZGV4IGZmNmY4NWYuLjUx
OTZiZmEgMTAwNjQ0DQo+IC0tLSBhL2ZzL25mcy9uZnM0MnByb2MuYw0KPiArKysgYi9mcy9uZnMv
bmZzNDJwcm9jLmMNCj4gQEAgLTMyOSw5ICszMjksNiBAQCBzc2l6ZV90IG5mczQyX3Byb2NfY29w
eShzdHJ1Y3QgZmlsZSAqc3JjLCBsb2ZmX3QNCj4gcG9zX3NyYywNCj4gIAl9Ow0KPiAgCXNzaXpl
X3QgZXJyLCBlcnIyOw0KPiAgDQo+IC0JaWYgKCFuZnNfc2VydmVyX2NhcGFibGUoZmlsZV9pbm9k
ZShkc3QpLCBORlNfQ0FQX0NPUFkpKQ0KPiAtCQlyZXR1cm4gLUVPUE5PVFNVUFA7DQo+IC0NCj4g
IAlzcmNfbG9jayA9IG5mc19nZXRfbG9ja19jb250ZXh0KG5mc19maWxlX29wZW5fY29udGV4dChz
cmMpKTsNCj4gIAlpZiAoSVNfRVJSKHNyY19sb2NrKSkNCj4gIAkJcmV0dXJuIFBUUl9FUlIoc3Jj
X2xvY2spOw0KPiBkaWZmIC0tZ2l0IGEvZnMvbmZzL25mczRmaWxlLmMgYi9mcy9uZnMvbmZzNGZp
bGUuYw0KPiBpbmRleCA0NWIyMzIyLi4wMGQxNzE5IDEwMDY0NA0KPiAtLS0gYS9mcy9uZnMvbmZz
NGZpbGUuYw0KPiArKysgYi9mcy9uZnMvbmZzNGZpbGUuYw0KPiBAQCAtMTMzLDggKzEzMywxMCBA
QCBzdGF0aWMgc3NpemVfdCBuZnM0X2NvcHlfZmlsZV9yYW5nZShzdHJ1Y3QgZmlsZQ0KPiAqZmls
ZV9pbiwgbG9mZl90IHBvc19pbiwNCj4gIAkJCQkgICAgc3RydWN0IGZpbGUgKmZpbGVfb3V0LCBs
b2ZmX3QNCj4gcG9zX291dCwNCj4gIAkJCQkgICAgc2l6ZV90IGNvdW50LCB1bnNpZ25lZCBpbnQg
ZmxhZ3MpDQo+ICB7DQo+ICsJaWYgKCFuZnNfc2VydmVyX2NhcGFibGUoZmlsZV9pbm9kZShmaWxl
X291dCksIE5GU19DQVBfQ09QWSkpDQo+ICsJCXJldHVybiAtRU9QTk9UU1VQUDsNCj4gIAlpZiAo
ZmlsZV9pbm9kZShmaWxlX2luKSA9PSBmaWxlX2lub2RlKGZpbGVfb3V0KSkNCj4gLQkJcmV0dXJu
IC1FSU5WQUw7DQo+ICsJCXJldHVybiAtRU9QTk9UU1VQUDsNCj4gIAlyZXR1cm4gbmZzNDJfcHJv
Y19jb3B5KGZpbGVfaW4sIHBvc19pbiwgZmlsZV9vdXQsIHBvc19vdXQsDQo+IGNvdW50KTsNCj4g
IH0NCj4gDQpUaGF0IGxvb2tzIGdvb2QuIFRoYW5rcyBPbGdhIQ0KDQotLSANClRyb25kIE15a2xl
YnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlr
bGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
