Return-Path: <SRS0=zHXY=OH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AE78C43441
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 21:39:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0C13B2081C
	for <linux-nfs@archiver.kernel.org>; Wed, 28 Nov 2018 21:39:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="U+QJK2Gc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C13B2081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=netapp.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726318AbeK2ImO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 29 Nov 2018 03:42:14 -0500
Received: from mail-eopbgr800051.outbound.protection.outlook.com ([40.107.80.51]:37536
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726307AbeK2ImO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Nov 2018 03:42:14 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+cD7QvjSF0SqngBm0imHojcM5Q7ex5Du1RewLOetk84=;
 b=U+QJK2Gc/rvTvOwviwJDb/sx7f67SNXlnELKsArjjFXBnhKjIKQpUala18n1cSw8OGY6UnoxRvus+O0bHunAxkgYuqT5KZlFiQISnKG5Zqhyfir6tbgohrnrb85UQiWxrkeswQqsM8UFxwGKtVLPISRJqowaZIEXxZn7zWh4qHQ=
Received: from DM5PR06MB3161.namprd06.prod.outlook.com (10.174.240.148) by
 DM5PR06MB3242.namprd06.prod.outlook.com (10.174.241.11) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1361.15; Wed, 28 Nov 2018 21:38:29 +0000
Received: from DM5PR06MB3161.namprd06.prod.outlook.com
 ([fe80::d40a:85bd:7b8a:7420]) by DM5PR06MB3161.namprd06.prod.outlook.com
 ([fe80::d40a:85bd:7b8a:7420%2]) with mapi id 15.20.1361.019; Wed, 28 Nov 2018
 21:38:29 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "thomas.preston@codethink.co.uk" <thomas.preston@codethink.co.uk>,
        "jlayton@kernel.org" <jlayton@kernel.org>
CC:     "linux-kernel@lists.codethink.co.uk" 
        <linux-kernel@lists.codethink.co.uk>,
        "ben.dooks@codethink.co.uk" <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH v2 1/1] SUNRPC: allow /proc entries without
 CONFIG_SUNRPC_DEBUG
Thread-Topic: [PATCH v2 1/1] SUNRPC: allow /proc entries without
 CONFIG_SUNRPC_DEBUG
Thread-Index: AQHUhyvx3wzhSjuCUUGCp5TpiL0piqVltwIA
Date:   Wed, 28 Nov 2018 21:38:28 +0000
Message-ID: <dbacc0e7939c409057482e0ccc0f623b15f7ecb8.camel@netapp.com>
References: <20181128150558.9455-1-thomas.preston@codethink.co.uk>
         <20181128150558.9455-2-thomas.preston@codethink.co.uk>
In-Reply-To: <20181128150558.9455-2-thomas.preston@codethink.co.uk>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.2 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-originating-ip: [23.28.75.121]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;DM5PR06MB3242;6:4G9r7aSEO+pQAnenbP1+zO9qQUm+bz79sCfCRZxJEMWZmPlsVUrd/Vi3pa9VdMJ24LI+FkjoC9B8txA+5EndPSK4Jojjcm13SACl2oCfVghdhucBmWJf9a2A+3ovhg1PefgYIguzuQjYtmb0UF/G4XVD+f2aNg7xQ3d5cat5YtA0P2yhqUZ48PKT5z9R8Q1UqKoX3Zs9U6RzOzW54i5VwwiHMLtCTrn4BJKXGiPtVMH9MgznVNIrqeduPnxVligQSiIf6igjkaDlLv1hotpGbI9smeOInL8zfk4+u83p92Rti7iED2cpNP/Yl+ybAb6CWX5TuVZYA0KSs7ImUcoqUbS0Ap9c5N+I1HtRkHziYqOB89e2qkKg/8Om6iYfRXY1Bor+MYx+qTU5/fzgeGakWcDNiXg5v/gkI+GG0IscPPqb3vC03AoOt0TaUGkmaH2QeDBBRQtJtuBqSMxGDC/1KA==;5:oGiwuw22wuoce9XR4R6ZGmWs14U9mF6kPeB3vTs7JIsap+4wZkiO6ksz5656lN8AbHP21WsNS/W7PMwylA7OdJHlCYdphDJq9zUK7uhew8238vtB7TZMxWILuuHJF+eBjuXk7ON4007Zh7oEr//02xQc0BTeZWzuwErf8LEQ8j4=;7:0dnDIJuh6Vki7tX21J6dnCv76FVBXDAF+J07SF/Rn55e1ACSRQCJPhOphm5Ow5x+dHSnN0upf784wQJ6jnEuGBbuthaPYD+wvMl7OqJoR30TFvV4I0ATWkkuBoxeLCEwz30MgCE5ZCpQ6Quyma9YgA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 2df83866-83cd-4b7b-4a4a-08d65579d61b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:DM5PR06MB3242;
x-ms-traffictypediagnostic: DM5PR06MB3242:
x-microsoft-antispam-prvs: <DM5PR06MB3242C7E630F95418DEF6CB4CF8D10@DM5PR06MB3242.namprd06.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(8211001083)(6040522)(2401047)(5005006)(8121501046)(10201501046)(93006095)(93001095)(3231443)(999002)(944501410)(52105112)(3002001)(6055026)(148016)(149066)(150057)(6041310)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123562045)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:DM5PR06MB3242;BCL:0;PCL:0;RULEID:;SRVR:DM5PR06MB3242;
x-forefront-prvs: 0870212862
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(396003)(136003)(376002)(346002)(39860400002)(366004)(189003)(199004)(316002)(478600001)(486006)(81156014)(66066001)(102836004)(81166006)(186003)(25786009)(26005)(305945005)(256004)(229853002)(2616005)(99286004)(76176011)(476003)(7736002)(3846002)(446003)(6506007)(11346002)(6246003)(8936002)(106356001)(14454004)(105586002)(97736004)(4001150100001)(71190400001)(5660300001)(71200400001)(6116002)(68736007)(6436002)(8676002)(4326008)(118296001)(6512007)(53936002)(110136005)(36756003)(2201001)(2906002)(86362001)(6486002)(54906003)(2501003)(58126008)(72206003);DIR:OUT;SFP:1101;SCL:1;SRVR:DM5PR06MB3242;H:DM5PR06MB3161.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: iiSZkPvIdcpuQFhsV/lIwWBEtdbLiWmqnUibXjpyzzovYvPk+ShOxLIJhyJer35vMo/idxZ/2qBdsaBiozwC96ZN3aoKuTvxogGIAx8U7VWP1xpTXxjyPhUHqruK0FX5MN1+vpHU5neh5BwTZtuEFWF/Pm+6ShxC0UQuhkjQIJK032Sw8IGTTWyv3Vp5TgEwKfJMubEieybRB4YLnlzlPLHrnB0wLzBsuU2JcIsUbYtg85sHXUoLj5nkL1NbFtG1LWRRB0uUFoBAne/ehKi6cOC2DavRrzHtnDfe3kXK3158ElL0mtgLKDCiCGA0GXgyaInzglePqANAByEy4Qi6rufZIXLZJgNpnxmDobZJex0=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <DC6BE1EAE4862B419D3A335D33A7803E@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 2df83866-83cd-4b7b-4a4a-08d65579d61b
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Nov 2018 21:38:28.9819
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-Transport-CrossTenantHeadersStamped: DM5PR06MB3242
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgVGhvbWFzLA0KDQpPbiBXZWQsIDIwMTgtMTEtMjggYXQgMTU6MDUgKzAwMDAsIFRob21hcyBQ
cmVzdG9uIHdyb3RlOg0KPiBGcm9tOiBCZW4gRG9va3MgPGJlbi5kb29rc0Bjb2RldGhpbmsuY28u
dWs+DQo+IA0KPiBJZiB3ZSB3YW50IC9wcm9jL3N5cy9zdW5ycGMgdGhlIGN1cnJlbnQga2VybmVs
IGFsc28gZHJhZ3MgaW4gb3RoZXIgZGVidWcNCj4gZmVhdHVyZXMgd2hpY2ggd2UgZG9uJ3QgcmVh
bGx5IHdhbnQuIEluc3RlYWQsIHdlIHNob3VsZCBhbHdheXMgc2hvdyB0aGUNCj4gZm9sbG93aW5n
IGVudHJpZXM6DQo+IA0KPiAvcHJvYy9zeXMvc3VucnBjL3VkcF9zbG90X3RhYmxlX2VudHJpZXMN
Cj4gL3Byb2Mvc3lzL3N1bnJwYy90Y3Bfc2xvdF90YWJsZV9lbnRyaWVzDQo+IC9wcm9jL3N5cy9z
dW5ycGMvdGNwX21heF9zbG90X3RhYmxlX2VudHJpZXMNCj4gL3Byb2Mvc3lzL3N1bnJwYy9taW5f
cmVzdnBvcnQNCj4gL3Byb2Mvc3lzL3N1bnJwYy9tYXhfcmVzdnBvcnQNCj4gL3Byb2Mvc3lzL3N1
bnJwYy90Y3BfZmluX3RpbWVvdXQNCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEJlbiBEb29rcyA8YmVu
LmRvb2tzQGNvZGV0aGluay5jby51az4NCj4gU2lnbmVkLW9mZi1ieTogVGhvbWFzIFByZXN0b24g
PHRob21hcy5wcmVzdG9uQGNvZGV0aGluay5jby51az4NCg0KVGhhbmtzLCB0aGlzIGxvb2tzIGdy
ZWF0IHRvIG1lIQ0KDQpBbm5hDQoNCj4gLS0tDQo+ICBuZXQvc3VucnBjL3hwcnRzb2NrLmMgfCA4
IC0tLS0tLS0tDQo+ICAxIGZpbGUgY2hhbmdlZCwgOCBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYg
LS1naXQgYS9uZXQvc3VucnBjL3hwcnRzb2NrLmMgYi9uZXQvc3VucnBjL3hwcnRzb2NrLmMNCj4g
aW5kZXggYWU3N2M3MWMxZjY0Li5jNmMwN2ZhNDEwZDEgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5y
cGMveHBydHNvY2suYw0KPiArKysgYi9uZXQvc3VucnBjL3hwcnRzb2NrLmMNCj4gQEAgLTY4LDgg
KzY4LDYgQEAgc3RhdGljIHVuc2lnbmVkIGludCB4cHJ0X21heF90Y3Bfc2xvdF90YWJsZV9lbnRy
aWVzID0NCj4gUlBDX01BWF9TTE9UX1RBQkxFOw0KPiAgc3RhdGljIHVuc2lnbmVkIGludCB4cHJ0
X21pbl9yZXN2cG9ydCA9IFJQQ19ERUZfTUlOX1JFU1ZQT1JUOw0KPiAgc3RhdGljIHVuc2lnbmVk
IGludCB4cHJ0X21heF9yZXN2cG9ydCA9IFJQQ19ERUZfTUFYX1JFU1ZQT1JUOw0KPiAgDQo+IC0j
aWYgSVNfRU5BQkxFRChDT05GSUdfU1VOUlBDX0RFQlVHKQ0KPiAtDQo+ICAjZGVmaW5lIFhTX1RD
UF9MSU5HRVJfVE8JKDE1VSAqIEhaKQ0KPiAgc3RhdGljIHVuc2lnbmVkIGludCB4c190Y3BfZmlu
X3RpbWVvdXQgX19yZWFkX21vc3RseSA9IFhTX1RDUF9MSU5HRVJfVE87DQo+ICANCj4gQEAgLTE1
OSw4ICsxNTcsNiBAQCBzdGF0aWMgc3RydWN0IGN0bF90YWJsZSBzdW5ycGNfdGFibGVbXSA9IHsN
Cj4gIAl7IH0sDQo+ICB9Ow0KPiAgDQo+IC0jZW5kaWYNCj4gLQ0KPiAgLyoNCj4gICAqIFdhaXQg
ZHVyYXRpb24gZm9yIGEgcmVwbHkgZnJvbSB0aGUgUlBDIHBvcnRtYXBwZXIuDQo+ICAgKi8NCj4g
QEAgLTMxMTQsMTAgKzMxMTAsOCBAQCBzdGF0aWMgc3RydWN0IHhwcnRfY2xhc3MJeHNfYmNfdGNw
X3RyYW5zcG9ydCA9IHsNCj4gICAqLw0KPiAgaW50IGluaXRfc29ja2V0X3hwcnQodm9pZCkNCj4g
IHsNCj4gLSNpZiBJU19FTkFCTEVEKENPTkZJR19TVU5SUENfREVCVUcpDQo+ICAJaWYgKCFzdW5y
cGNfdGFibGVfaGVhZGVyKQ0KPiAgCQlzdW5ycGNfdGFibGVfaGVhZGVyID0gcmVnaXN0ZXJfc3lz
Y3RsX3RhYmxlKHN1bnJwY190YWJsZSk7DQo+IC0jZW5kaWYNCj4gIA0KPiAgCXhwcnRfcmVnaXN0
ZXJfdHJhbnNwb3J0KCZ4c19sb2NhbF90cmFuc3BvcnQpOw0KPiAgCXhwcnRfcmVnaXN0ZXJfdHJh
bnNwb3J0KCZ4c191ZHBfdHJhbnNwb3J0KTsNCj4gQEAgLTMxMzMsMTIgKzMxMjcsMTAgQEAgaW50
IGluaXRfc29ja2V0X3hwcnQodm9pZCkNCj4gICAqLw0KPiAgdm9pZCBjbGVhbnVwX3NvY2tldF94
cHJ0KHZvaWQpDQo+ICB7DQo+IC0jaWYgSVNfRU5BQkxFRChDT05GSUdfU1VOUlBDX0RFQlVHKQ0K
PiAgCWlmIChzdW5ycGNfdGFibGVfaGVhZGVyKSB7DQo+ICAJCXVucmVnaXN0ZXJfc3lzY3RsX3Rh
YmxlKHN1bnJwY190YWJsZV9oZWFkZXIpOw0KPiAgCQlzdW5ycGNfdGFibGVfaGVhZGVyID0gTlVM
TDsNCj4gIAl9DQo+IC0jZW5kaWYNCj4gIA0KPiAgCXhwcnRfdW5yZWdpc3Rlcl90cmFuc3BvcnQo
JnhzX2xvY2FsX3RyYW5zcG9ydCk7DQo+ICAJeHBydF91bnJlZ2lzdGVyX3RyYW5zcG9ydCgmeHNf
dWRwX3RyYW5zcG9ydCk7DQo=
