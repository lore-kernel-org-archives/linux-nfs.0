Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B095CC4360F
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 20:12:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 728322147C
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 20:12:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="eKTZ8ACB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726573AbfCLUMa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 16:12:30 -0400
Received: from mail-eopbgr800132.outbound.protection.outlook.com ([40.107.80.132]:16224
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726571AbfCLUMa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Mar 2019 16:12:30 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=34Ob5OrxLAX6sx3Brufo41UPwMshpyvoMl4HhWfTY6c=;
 b=eKTZ8ACBrXEdjYUaOzBQHVgjI2MR2DOjRws7ljJllwWgYMXmB01U11pdIVAL9RRCnfKbmI7zi3MaW2jl8cNV25bHBomeek+bruWlSuMTkavFfmHwRnEs0hfsoYXcrACZcYy/BIiZQrkyuX+483lMkLrU6qJqV2F5VmC5J44DBy4=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2574.namprd13.prod.outlook.com (52.135.96.22) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1709.10; Tue, 12 Mar 2019 20:12:08 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::d1d6:9683:8c9b:3dcb%3]) with mapi id 15.20.1709.011; Tue, 12 Mar 2019
 20:12:08 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] pNFS: Ensure we return the error if someone kills a
 waiting layoutget
Thread-Topic: [PATCH 1/4] pNFS: Ensure we return the error if someone kills a
 waiting layoutget
Thread-Index: AQHURUNoW4zAXF/260mqOpWC6FLreqYJkxsAgAACGAA=
Date:   Tue, 12 Mar 2019 20:12:08 +0000
Message-ID: <6057b85eea9d1b25189e2c1ead89112c91180ff0.camel@hammerspace.com>
References: <20180905180715.99485-1-trond.myklebust@hammerspace.com>
         <233f58676bee06fe87fae6c6ca04708a24716187.camel@netapp.com>
In-Reply-To: <233f58676bee06fe87fae6c6ca04708a24716187.camel@netapp.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ca51ce8c-992a-44b3-ab4f-08d6a727015d
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2574;
x-ms-traffictypediagnostic: SN6PR13MB2574:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2574E1E6EEDAFD7D1DBB6976B8490@SN6PR13MB2574.namprd13.prod.outlook.com>
x-forefront-prvs: 09749A275C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39830400003)(376002)(366004)(396003)(346002)(199004)(189003)(3846002)(6116002)(26005)(5660300002)(66066001)(14444005)(5024004)(256004)(106356001)(446003)(2351001)(486006)(68736007)(25786009)(71190400001)(71200400001)(11346002)(2906002)(8676002)(86362001)(81156014)(81166006)(4326008)(8936002)(6916009)(99286004)(229853002)(2616005)(2501003)(53936002)(7736002)(97736004)(186003)(6506007)(316002)(53546011)(76176011)(478600001)(6246003)(14454004)(6486002)(6436002)(118296001)(105586002)(6512007)(5640700003)(36756003)(476003)(305945005)(102836004);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2574;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 20aV4SgrkkN8hn2DRK9mNKaxl31+oSgEHO67utKcf4g4SXbhlmcyEcJbRdsF2M0PEbjMc6Lk4xhOTbhMkRnwSuqg2c8ua+ZS92UUqcPZWTHis2e+Gt9iB22Yfs6XhCkn1nDOB+LUM+Yj4z8EmD3zSgmw0ktMYfN/whlsFCVqE5j7IYnUNEk/01yz5vphK/XagypINuAT3NzJ4J/JdZ084hz5BJw3KrM3PNaVwKdnkXf5DnjiTT/SQvoVlOQOBR5dn7zdrWJCS9BccYNRuWoBPHXX/Yurxkj+ZI4PLy22yfspJm8X7QoYC1H4F00dBBt1UoFhZd1LaDa4pRv0BIhDmoA0gpv7tOXVb7kfqwQ25d3Pat/k/j365FMz1Ea2D/9Ius62gbDRGwvpdUd+WUX3OYb1XOodBUx2MCJENOz5mVg=
Content-Type: text/plain; charset="utf-8"
Content-ID: <829467F0E938C94DBE26548A4E3BD3DD@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ca51ce8c-992a-44b3-ab4f-08d6a727015d
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Mar 2019 20:12:08.6281
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2574
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTAzLTEyIGF0IDIwOjA0ICswMDAwLCBTY2h1bWFrZXIsIEFubmEgd3JvdGU6
DQo+IEhpIFRyb25kLA0KPiANCj4gSSdtIHNlZWluZyBhIGhhbmcgd2hlbiB0ZXN0aW5nIHhmc3Rl
c3RzIGdlbmVyaWMvMDEzIG9uIHY0LjEgd2l0aCBwTkZTDQo+IGFmdGVyIHRoaXMNCj4gcGF0Y2g6
DQo+IA0KPiBPbiBXZWQsIDIwMTgtMDktMDUgYXQgMTQ6MDcgLTA0MDAsIFRyb25kIE15a2xlYnVz
dCB3cm90ZToNCj4gPiBJZiBzb21lb25lIGludGVycnVwdHMgYSB3YWl0IG9uIG9uZSBvciBtb3Jl
IG91dHN0YW5kaW5nIGxheW91dGdldHMNCj4gPiBpbg0KPiA+IHBuZnNfdXBkYXRlX2xheW91dCgp
IHRoZW4gcmV0dXJuIHRoZSBFUkVTVEFSVFNZUy9FSU5UUiBlcnJvci4NCj4gPiANCj4gPiBTaWdu
ZWQtb2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5j
b20+DQo+ID4gLS0tDQo+ID4gIGZzL25mcy9wbmZzLmMgfCAyNiArKysrKysrKysrKysrKysrLS0t
LS0tLS0tLQ0KPiA+ICAxIGZpbGUgY2hhbmdlZCwgMTYgaW5zZXJ0aW9ucygrKSwgMTAgZGVsZXRp
b25zKC0pDQo+ID4gDQo+ID4gZGlmZiAtLWdpdCBhL2ZzL25mcy9wbmZzLmMgYi9mcy9uZnMvcG5m
cy5jDQo+ID4gaW5kZXggZThmMjMyZGU0ODRmLi43ZDlhNTFlNmI4NDcgMTAwNjQ0DQo+ID4gLS0t
IGEvZnMvbmZzL3BuZnMuYw0KPiA+ICsrKyBiL2ZzL25mcy9wbmZzLmMNCj4gPiBAQCAtMTc0MCwx
NiArMTc0MCwxNiBAQCBzdGF0aWMgYm9vbCBwbmZzX3dpdGhpbl9tZHN0aHJlc2hvbGQoc3RydWN0
DQo+ID4gbmZzX29wZW5fY29udGV4dCAqY3R4LA0KPiA+ICAJcmV0dXJuIHJldDsNCj4gPiAgfQ0K
PiA+ICANCj4gPiAtc3RhdGljIGJvb2wgcG5mc19wcmVwYXJlX3RvX3JldHJ5X2xheW91dGdldChz
dHJ1Y3QgcG5mc19sYXlvdXRfaGRyDQo+ID4gKmxvKQ0KPiA+ICtzdGF0aWMgaW50IHBuZnNfcHJl
cGFyZV90b19yZXRyeV9sYXlvdXRnZXQoc3RydWN0IHBuZnNfbGF5b3V0X2hkcg0KPiA+ICpsbykN
Cj4gPiAgew0KPiA+ICAJLyoNCj4gPiAgCSAqIHNlbmQgbGF5b3V0Y29tbWl0IGFzIGl0IGNhbiBo
b2xkIHVwIGxheW91dHJldHVybiBkdWUgdG8gbHNlZw0KPiA+ICAJICogcmVmZXJlbmNlDQo+ID4g
IAkgKi8NCj4gPiAgCXBuZnNfbGF5b3V0Y29tbWl0X2lub2RlKGxvLT5wbGhfaW5vZGUsIGZhbHNl
KTsNCj4gPiAtCXJldHVybiAhd2FpdF9vbl9iaXRfYWN0aW9uKCZsby0+cGxoX2ZsYWdzLCBORlNf
TEFZT1VUX1JFVFVSTiwNCj4gPiArCXJldHVybiB3YWl0X29uX2JpdF9hY3Rpb24oJmxvLT5wbGhf
ZmxhZ3MsIE5GU19MQVlPVVRfUkVUVVJOLA0KPiA+ICAJCQkJICAgbmZzX3dhaXRfYml0X2tpbGxh
YmxlLA0KPiA+IC0JCQkJICAgVEFTS19VTklOVEVSUlVQVElCTEUpOw0KPiA+ICsJCQkJICAgVEFT
S19LSUxMQUJMRSk7DQo+ID4gIH0NCj4gPiAgDQo+ID4gIHN0YXRpYyB2b2lkIG5mc19sYXlvdXRn
ZXRfYmVnaW4oc3RydWN0IHBuZnNfbGF5b3V0X2hkciAqbG8pDQo+ID4gQEAgLTE4MzAsNyArMTgz
MCw5IEBAIHBuZnNfdXBkYXRlX2xheW91dChzdHJ1Y3QgaW5vZGUgKmlubywNCj4gPiAgCX0NCj4g
PiAgDQo+ID4gIGxvb2t1cF9hZ2FpbjoNCj4gPiAtCW5mczRfY2xpZW50X3JlY292ZXJfZXhwaXJl
ZF9sZWFzZShjbHApOw0KPiA+ICsJbHNlZyA9IEVSUl9QVFIobmZzNF9jbGllbnRfcmVjb3Zlcl9l
eHBpcmVkX2xlYXNlKGNscCkpOw0KPiA+ICsJaWYgKElTX0VSUihsc2VnKSkNCj4gPiArCQlnb3Rv
IG91dDsNCj4gPiAgCWZpcnN0ID0gZmFsc2U7DQo+ID4gIAlzcGluX2xvY2soJmluby0+aV9sb2Nr
KTsNCj4gPiAgCWxvID0gcG5mc19maW5kX2FsbG9jX2xheW91dChpbm8sIGN0eCwgZ2ZwX2ZsYWdz
KTsNCj4gPiBAQCAtMTg2Myw5ICsxODY1LDkgQEAgcG5mc191cGRhdGVfbGF5b3V0KHN0cnVjdCBp
bm9kZSAqaW5vLA0KPiA+ICAJaWYgKGxpc3RfZW1wdHkoJmxvLT5wbGhfc2VncykgJiYNCj4gPiAg
CSAgICBhdG9taWNfcmVhZCgmbG8tPnBsaF9vdXRzdGFuZGluZykgIT0gMCkgew0KPiA+ICAJCXNw
aW5fdW5sb2NrKCZpbm8tPmlfbG9jayk7DQo+ID4gLQkJaWYgKHdhaXRfdmFyX2V2ZW50X2tpbGxh
YmxlKCZsby0+cGxoX291dHN0YW5kaW5nLA0KPiA+IC0JCQkJCWF0b21pY19yZWFkKCZsby0NCj4g
PiA+cGxoX291dHN0YW5kaW5nKSA9PSAwDQo+ID4gLQkJCQkJfHwgIWxpc3RfZW1wdHkoJmxvLT5w
bGhfc2VncykpKQ0KPiA+ICsJCWxzZWcgPSBFUlJfUFRSKHdhaXRfdmFyX2V2ZW50X2tpbGxhYmxl
KCZsby0NCj4gPiA+cGxoX291dHN0YW5kaW5nLA0KPiA+ICsJCQkJCWF0b21pY19yZWFkKCZsby0N
Cj4gPiA+cGxoX291dHN0YW5kaW5nKSkpOw0KPiA+ICsJCWlmIChJU19FUlIobHNlZykgfHwgIWxp
c3RfZW1wdHkoJmxvLT5wbGhfc2VncykpDQo+IA0KPiBXYXMgZHJvcHBpbmcgdGhlICI9PSAwIiBj
b25kaXRpb24gYXR0YWNoZWQgdG8gdGhlIGF0b21pY19yZWFkKCkgaGVyZQ0KPiBhIG1pc3Rha2U/
DQo+IEkgdGhpbmsgd2hhdCdzIGhhcHBlbmluZyBpcyB0aGF0IG15IGNsaWVudCBpcyB3YWl0aW5n
IGZvcg0KPiBwbGhfb3V0c3RhbmRpbmcgdG8gYmUNCj4gYW55dGhpbmcgb3RoZXIgdGhhbiAwIHdo
ZW4gdGhlcmUgaXNuJ3QgYW55IHdvcmsgbGVmdCB0byBkby4NCg0KWWVzLiBUaGF0J3MgYSBidWcu
IEhvdyBhYm91dCB0aGUgZm9sbG93aW5nIHBhdGNoPw0KDQo4PC0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KRnJvbSA0MDA0MTdiMDVmM2VjMDUzMTU0
NGNhNWY5NGU2NGQ4MzhkOGI4ODQ5IE1vbiBTZXAgMTcgMDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJv
bmQgTXlrbGVidXN0IDx0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tPg0KRGF0ZTogVHVl
LCAxMiBNYXIgMjAxOSAxNjowNDo1MSAtMDQwMA0KU3ViamVjdDogW1BBVENIXSBwTkZTOiBGaXgg
YSB0eXBvIGluIHBuZnNfdXBkYXRlX2xheW91dA0KDQpXZSdyZSBzdXBwb3NlZCB0byB3YWl0IGZv
ciB0aGUgb3V0c3RhbmRpbmcgbGF5b3V0IGNvdW50IHRvIGdvIHRvIHplcm8sDQpidXQgdGhhdCBn
b3QgbG9zdCBzb21laG93Lg0KDQpGaXhlczogZDAzMzYwYWFmNWNjYSAoInBORlM6IEVuc3VyZSB3
ZSByZXR1cm4gdGhlIGVycm9yIGlmIHNvbWVvbmUuLi4iKQ0KUmVwb3J0ZWQtYnk6IEFubmEgU2No
dW1ha2VyIDxBbm5hLlNjaHVtYWtlckBOZXRhcHAuY29tPg0KU2lnbmVkLW9mZi1ieTogVHJvbmQg
TXlrbGVidXN0IDx0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tPg0KLS0tDQogZnMvbmZz
L3BuZnMuYyB8IDIgKy0NCiAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24oKyksIDEgZGVsZXRp
b24oLSkNCg0KZGlmZiAtLWdpdCBhL2ZzL25mcy9wbmZzLmMgYi9mcy9uZnMvcG5mcy5jDQppbmRl
eCA4MjQ3YmQxNjM0Y2IuLjcwNjZjZDdjN2FmZiAxMDA2NDQNCi0tLSBhL2ZzL25mcy9wbmZzLmMN
CisrKyBiL2ZzL25mcy9wbmZzLmMNCkBAIC0xODg5LDcgKzE4ODksNyBAQCBwbmZzX3VwZGF0ZV9s
YXlvdXQoc3RydWN0IGlub2RlICppbm8sDQogCSAgICBhdG9taWNfcmVhZCgmbG8tPnBsaF9vdXRz
dGFuZGluZykgIT0gMCkgew0KIAkJc3Bpbl91bmxvY2soJmluby0+aV9sb2NrKTsNCiAJCWxzZWcg
PSBFUlJfUFRSKHdhaXRfdmFyX2V2ZW50X2tpbGxhYmxlKCZsby0+cGxoX291dHN0YW5kaW5nLA0K
LQkJCQkJYXRvbWljX3JlYWQoJmxvLT5wbGhfb3V0c3RhbmRpbmcpKSk7DQorCQkJCQkhYXRvbWlj
X3JlYWQoJmxvLT5wbGhfb3V0c3RhbmRpbmcpKSk7DQogCQlpZiAoSVNfRVJSKGxzZWcpIHx8ICFs
aXN0X2VtcHR5KCZsby0+cGxoX3NlZ3MpKQ0KIAkJCWdvdG8gb3V0X3B1dF9sYXlvdXRfaGRyOw0K
IAkJcG5mc19wdXRfbGF5b3V0X2hkcihsbyk7DQotLSANCjIuMjAuMQ0KDQotLSANClRyb25kIE15
a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQu
bXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
