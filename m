Return-Path: <SRS0=zOxf=RP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DE9CC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 20:04:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F0CDE20449
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Mar 2019 20:04:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="mIqeE1vp"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726685AbfCLUEk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Mar 2019 16:04:40 -0400
Received: from mail-eopbgr700069.outbound.protection.outlook.com ([40.107.70.69]:2785
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726585AbfCLUEk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Mar 2019 16:04:40 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=WrWfO+xJQDBOD8vqY+ReMt2+I45xAA97Aw1Gp3KXBpo=;
 b=mIqeE1vplOMVPzmBQ6EHTVCpf2ZACBWMUduffaRXTIvQJt8oKIjrqU7O8fguAXYG11ktQTVjYN2wHOeNkXir3si9pNcJg0AGFV2uYlUPOPQi0+W8O1smwWOGJjSexXyBTOoFGfzPxsOwQVmq3xz6Ck4QAVo5rbVt+5Xbv9JGv00=
Received: from BN8PR06MB6228.namprd06.prod.outlook.com (20.178.217.156) by
 BN8PR06MB5891.namprd06.prod.outlook.com (20.179.139.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1686.21; Tue, 12 Mar 2019 20:04:36 +0000
Received: from BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::c5ec:66d7:6a15:7d95]) by BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::c5ec:66d7:6a15:7d95%2]) with mapi id 15.20.1686.021; Tue, 12 Mar 2019
 20:04:36 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "trondmy@gmail.com" <trondmy@gmail.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] pNFS: Ensure we return the error if someone kills a
 waiting layoutget
Thread-Topic: [PATCH 1/4] pNFS: Ensure we return the error if someone kills a
 waiting layoutget
Thread-Index: AQHURUOSbiYf/nGVe0OLLNqxofWpZaYJkxmA
Date:   Tue, 12 Mar 2019 20:04:36 +0000
Message-ID: <233f58676bee06fe87fae6c6ca04708a24716187.camel@netapp.com>
References: <20180905180715.99485-1-trond.myklebust@hammerspace.com>
In-Reply-To: <20180905180715.99485-1-trond.myklebust@hammerspace.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.5 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-originating-ip: [73.145.169.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: befc0a54-6abb-405e-bd18-08d6a725f3a5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7193020);SRVR:BN8PR06MB5891;
x-ms-traffictypediagnostic: BN8PR06MB5891:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtCTjhQUjA2TUI1ODkxOzIzOkNRTmlqeHBLekh1WXk4Q2JiMVlvZUtkdTFy?=
 =?utf-8?B?YldjTHh6NWZyYnE3dHYwUDIwRUpHdmlZTHhnbG5HVWFIb1BsQ0RwVmhMWTJt?=
 =?utf-8?B?azNraXVpWHlUdlI1U2RFUVF0OFVTUGgyY05MdW9mVU9taDRuQWJKRUo0VHFV?=
 =?utf-8?B?VjBvY3lHVmhWTkNBNWJZTTU5aVR5b0I2OGJndHdEaWZldjlkWDFBR25JNFBn?=
 =?utf-8?B?QmFzZjdTOUxiUDRkOW1Cc2pROVM1ZW13TXUzSXZpQUF6dTJvcFFvZ1U0RE4r?=
 =?utf-8?B?N1JwQmpsWmJoNGZhUVIyNWtmdVBWU2FsVjNadUdGeG1LSUpoUUpkeStaNHlw?=
 =?utf-8?B?WWFBTjFSZy9SSHR5YzI0cm5WSGg4UXlvVi9laGE4N2REMHB0N3RmNHQxamRX?=
 =?utf-8?B?WlFjZDUvV2JFUUZLUzlVcllGb0d6YmtOZERsQlRZWDhHZi9KLy9yUVd4bGY4?=
 =?utf-8?B?a0lVQnRPRFVIemU1eDlVcWNUSlBOb0gyOU1vUnA4MVNpaHNRSUdKLzFPaHpH?=
 =?utf-8?B?VjVsZHFNemVBWGJJb3lWZGNQVTQxNWgxMHYwY2tlYXpWQ1lJK1oyT2dMUUxo?=
 =?utf-8?B?UzBtTlJ2bHlxbEVPUVF1eVlkWElQVTR3bWFiNFNORG11WWNFeGF0V0N0Qzg2?=
 =?utf-8?B?dmxPRlQ3RDVkMHNHYWFhT1FnMnFCRWgySE8zRGVpZG9ZM3J6RjRTYy9yZnVu?=
 =?utf-8?B?bXpRQ3d6R3pXQS9wSnF1WkhqVmV6cVI5OTFjUjhKK2p1a282MS9SdEtIYnN2?=
 =?utf-8?B?Z0lZQkEwM1U1Q1JMaE1uWU5pMFppbUw4RjdQOUtTUnF1VVJVaVNpZlpJZmJx?=
 =?utf-8?B?RjdqT0MreXUwZnV4MzZQYUI1NDlqWlNETHRrSUhHaTJCN2JDb0VzaDdTVTJk?=
 =?utf-8?B?T3BZdURpZUIzMDJQaUxYUGhEa3BYSzZINHNZR3lGL1QyQVhOKzd0TitKVjNE?=
 =?utf-8?B?VkIzQmhCV2FZdnFOZGQ5czlGSVE2M0N3Z1BFaHhOY2FGb1BFSXRuWkhFc2lJ?=
 =?utf-8?B?d1BRNzB1aFRXOEsxN3AveWR1d3NTbG1penNKc0FaaXdDZ0N1dGJGVjFrNzZl?=
 =?utf-8?B?QlA0M1k0RmNNcUNJUXIwaEpOU21PMFA3Q3cwYTYwSysycGhnS2hlcDBKR2hP?=
 =?utf-8?B?Nk4vcDhnc3g0dm5ySVBUWisrSFA3RlpOaE01MUtaZ1o3c0tEU1BrK0RHYkZK?=
 =?utf-8?B?NXZCZ1owaWdpdThJNVFGNHNEMG1abm5sejhCdEpBREdMWXVtcW5yOVUzYU9h?=
 =?utf-8?B?aW84ZHNrSVJMSVh6MnlVUER2a1BvUE1PZWtSTGNzbkFyemZhd0hWOHVtQVh6?=
 =?utf-8?B?WUZsRVpVSjBkRGNwamw4UzJBQVREK0MyblV2UCtHTUNPdnMxeStSSFQrbDN4?=
 =?utf-8?B?YWUvUHNUL2NhMmVmUFlIYVd3enlzNjQ4UG1RUk5YbUpYazVONzJUSjE1bWp1?=
 =?utf-8?B?UmxlZXJJejdsOGRkN2dSZlBVZzJNU1grWTlaWk9NdEREc1ViNUhhbE9ZZDF6?=
 =?utf-8?B?ckNLTkFRcmUrSjhKSm1oRUlVRUtMdUdLaUE1Z2ZOaUovcTEyaXVLcnZUU05N?=
 =?utf-8?B?VFpyWEtOclhHNFprQnEwNTFCV0RHMXRBZ1JOSGorVVVZQkJpUTVJUTJQKy9k?=
 =?utf-8?B?ck92NktPYnVhZDBVZ0xzVXA4eTJPaG1yS1RGeHhXZ0lVZGorejBlYVJZT2JK?=
 =?utf-8?B?eHNHQkZoTjYvUjNXNWJaZWwvMDlQMnl5eHBGcHVQZmdlQmRveGZKU3dmd3Bm?=
 =?utf-8?B?YmZHU1RGcVlBZ0xoQWVQemVTWS9RRjZDOEE0Wk1BWENQQUk4N1ptRUJsNVNy?=
 =?utf-8?B?eTBCeWFjellJc3EydXgvL3NyV3R5amV5dU5WL1c3Y08zNi81dVdVRVNuRnNw?=
 =?utf-8?Q?DY46D9vL1zc=3D?=
x-microsoft-antispam-prvs: <BN8PR06MB5891D3BC029566011EF0416BF8490@BN8PR06MB5891.namprd06.prod.outlook.com>
x-forefront-prvs: 09749A275C
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(366004)(376002)(136003)(396003)(39860400002)(346002)(199004)(189003)(6506007)(7736002)(25786009)(14454004)(1411001)(26005)(5660300002)(58126008)(478600001)(72206003)(6916009)(229853002)(5640700003)(86362001)(99286004)(71190400001)(118296001)(316002)(2501003)(4326008)(71200400001)(14444005)(256004)(66066001)(97736004)(5024004)(8936002)(6436002)(6486002)(6116002)(1361003)(76176011)(36756003)(53936002)(3846002)(476003)(11346002)(2616005)(6512007)(186003)(102836004)(106356001)(105586002)(68736007)(81166006)(81156014)(1730700003)(8676002)(486006)(2351001)(2906002)(305945005)(446003)(6246003);DIR:OUT;SFP:1101;SCL:1;SRVR:BN8PR06MB5891;H:BN8PR06MB6228.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 1Tx3Q89sURkMSgYOR38KlDpuhhY+lO8IsUTsHVsvgkxSKfEBPe2h/iOLdyvyOcvl8LsXCSFTXzMaXQ0dVM7ZUgw0LekPCPDOxY9C/Ap53TWQb5ZDrwDBwF7RVB8Yo+1BZJf+/vukpkCbh0GvjPWgq6RAbDxsDxItqBTaX04PRkWT8eteN0CsKy1ze6cMLY0HSkDXX+YAj/JEqTGOeAJC9q1kVDhPEsIUU6eOq73oiuia5inxdOVkIRIVPK9FZ/tTPf1iGkNeaQp4fx2NJmBNZ9uzijwlM/WKKpWtSTCowDSlt979Ij7Czli7XpLmppPfd/uvnwbxtFjj6MCD3xmfmJP64li7I2dwZABKc+MmjFqgfIkaxAYwLFXoUkcRr7703I0aealiCEZJV/fdXE8uKWT54mN9zxU5u6Z/KtrgdkU=
Content-Type: text/plain; charset="utf-8"
Content-ID: <B810CEEFB45CC14CA02AAA184E074D07@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: befc0a54-6abb-405e-bd18-08d6a725f3a5
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Mar 2019 20:04:36.2287
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR06MB5891
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgVHJvbmQsDQoNCkknbSBzZWVpbmcgYSBoYW5nIHdoZW4gdGVzdGluZyB4ZnN0ZXN0cyBnZW5l
cmljLzAxMyBvbiB2NC4xIHdpdGggcE5GUyBhZnRlciB0aGlzDQpwYXRjaDoNCg0KT24gV2VkLCAy
MDE4LTA5LTA1IGF0IDE0OjA3IC0wNDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+IElmIHNv
bWVvbmUgaW50ZXJydXB0cyBhIHdhaXQgb24gb25lIG9yIG1vcmUgb3V0c3RhbmRpbmcgbGF5b3V0
Z2V0cyBpbg0KPiBwbmZzX3VwZGF0ZV9sYXlvdXQoKSB0aGVuIHJldHVybiB0aGUgRVJFU1RBUlRT
WVMvRUlOVFIgZXJyb3IuDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPHRy
b25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20+DQo+IC0tLQ0KPiAgZnMvbmZzL3BuZnMuYyB8
IDI2ICsrKysrKysrKysrKysrKystLS0tLS0tLS0tDQo+ICAxIGZpbGUgY2hhbmdlZCwgMTYgaW5z
ZXJ0aW9ucygrKSwgMTAgZGVsZXRpb25zKC0pDQo+IA0KPiBkaWZmIC0tZ2l0IGEvZnMvbmZzL3Bu
ZnMuYyBiL2ZzL25mcy9wbmZzLmMNCj4gaW5kZXggZThmMjMyZGU0ODRmLi43ZDlhNTFlNmI4NDcg
MTAwNjQ0DQo+IC0tLSBhL2ZzL25mcy9wbmZzLmMNCj4gKysrIGIvZnMvbmZzL3BuZnMuYw0KPiBA
QCAtMTc0MCwxNiArMTc0MCwxNiBAQCBzdGF0aWMgYm9vbCBwbmZzX3dpdGhpbl9tZHN0aHJlc2hv
bGQoc3RydWN0DQo+IG5mc19vcGVuX2NvbnRleHQgKmN0eCwNCj4gIAlyZXR1cm4gcmV0Ow0KPiAg
fQ0KPiAgDQo+IC1zdGF0aWMgYm9vbCBwbmZzX3ByZXBhcmVfdG9fcmV0cnlfbGF5b3V0Z2V0KHN0
cnVjdCBwbmZzX2xheW91dF9oZHIgKmxvKQ0KPiArc3RhdGljIGludCBwbmZzX3ByZXBhcmVfdG9f
cmV0cnlfbGF5b3V0Z2V0KHN0cnVjdCBwbmZzX2xheW91dF9oZHIgKmxvKQ0KPiAgew0KPiAgCS8q
DQo+ICAJICogc2VuZCBsYXlvdXRjb21taXQgYXMgaXQgY2FuIGhvbGQgdXAgbGF5b3V0cmV0dXJu
IGR1ZSB0byBsc2VnDQo+ICAJICogcmVmZXJlbmNlDQo+ICAJICovDQo+ICAJcG5mc19sYXlvdXRj
b21taXRfaW5vZGUobG8tPnBsaF9pbm9kZSwgZmFsc2UpOw0KPiAtCXJldHVybiAhd2FpdF9vbl9i
aXRfYWN0aW9uKCZsby0+cGxoX2ZsYWdzLCBORlNfTEFZT1VUX1JFVFVSTiwNCj4gKwlyZXR1cm4g
d2FpdF9vbl9iaXRfYWN0aW9uKCZsby0+cGxoX2ZsYWdzLCBORlNfTEFZT1VUX1JFVFVSTiwNCj4g
IAkJCQkgICBuZnNfd2FpdF9iaXRfa2lsbGFibGUsDQo+IC0JCQkJICAgVEFTS19VTklOVEVSUlVQ
VElCTEUpOw0KPiArCQkJCSAgIFRBU0tfS0lMTEFCTEUpOw0KPiAgfQ0KPiAgDQo+ICBzdGF0aWMg
dm9pZCBuZnNfbGF5b3V0Z2V0X2JlZ2luKHN0cnVjdCBwbmZzX2xheW91dF9oZHIgKmxvKQ0KPiBA
QCAtMTgzMCw3ICsxODMwLDkgQEAgcG5mc191cGRhdGVfbGF5b3V0KHN0cnVjdCBpbm9kZSAqaW5v
LA0KPiAgCX0NCj4gIA0KPiAgbG9va3VwX2FnYWluOg0KPiAtCW5mczRfY2xpZW50X3JlY292ZXJf
ZXhwaXJlZF9sZWFzZShjbHApOw0KPiArCWxzZWcgPSBFUlJfUFRSKG5mczRfY2xpZW50X3JlY292
ZXJfZXhwaXJlZF9sZWFzZShjbHApKTsNCj4gKwlpZiAoSVNfRVJSKGxzZWcpKQ0KPiArCQlnb3Rv
IG91dDsNCj4gIAlmaXJzdCA9IGZhbHNlOw0KPiAgCXNwaW5fbG9jaygmaW5vLT5pX2xvY2spOw0K
PiAgCWxvID0gcG5mc19maW5kX2FsbG9jX2xheW91dChpbm8sIGN0eCwgZ2ZwX2ZsYWdzKTsNCj4g
QEAgLTE4NjMsOSArMTg2NSw5IEBAIHBuZnNfdXBkYXRlX2xheW91dChzdHJ1Y3QgaW5vZGUgKmlu
bywNCj4gIAlpZiAobGlzdF9lbXB0eSgmbG8tPnBsaF9zZWdzKSAmJg0KPiAgCSAgICBhdG9taWNf
cmVhZCgmbG8tPnBsaF9vdXRzdGFuZGluZykgIT0gMCkgew0KPiAgCQlzcGluX3VubG9jaygmaW5v
LT5pX2xvY2spOw0KPiAtCQlpZiAod2FpdF92YXJfZXZlbnRfa2lsbGFibGUoJmxvLT5wbGhfb3V0
c3RhbmRpbmcsDQo+IC0JCQkJCWF0b21pY19yZWFkKCZsby0+cGxoX291dHN0YW5kaW5nKSA9PSAw
DQo+IC0JCQkJCXx8ICFsaXN0X2VtcHR5KCZsby0+cGxoX3NlZ3MpKSkNCj4gKwkJbHNlZyA9IEVS
Ul9QVFIod2FpdF92YXJfZXZlbnRfa2lsbGFibGUoJmxvLT5wbGhfb3V0c3RhbmRpbmcsDQo+ICsJ
CQkJCWF0b21pY19yZWFkKCZsby0+cGxoX291dHN0YW5kaW5nKSkpOw0KPiArCQlpZiAoSVNfRVJS
KGxzZWcpIHx8ICFsaXN0X2VtcHR5KCZsby0+cGxoX3NlZ3MpKQ0KDQpXYXMgZHJvcHBpbmcgdGhl
ICI9PSAwIiBjb25kaXRpb24gYXR0YWNoZWQgdG8gdGhlIGF0b21pY19yZWFkKCkgaGVyZSBhIG1p
c3Rha2U/DQpJIHRoaW5rIHdoYXQncyBoYXBwZW5pbmcgaXMgdGhhdCBteSBjbGllbnQgaXMgd2Fp
dGluZyBmb3IgcGxoX291dHN0YW5kaW5nIHRvIGJlDQphbnl0aGluZyBvdGhlciB0aGFuIDAgd2hl
biB0aGVyZSBpc24ndCBhbnkgd29yayBsZWZ0IHRvIGRvLg0KDQpUaGFua3MsDQpBbm5hDQoNCj4g
IAkJCWdvdG8gb3V0X3B1dF9sYXlvdXRfaGRyOw0KPiAgCQlwbmZzX3B1dF9sYXlvdXRfaGRyKGxv
KTsNCj4gIAkJZ290byBsb29rdXBfYWdhaW47DQo+IEBAIC0xODk4LDggKzE5MDAsMTEgQEAgcG5m
c191cGRhdGVfbGF5b3V0KHN0cnVjdCBpbm9kZSAqaW5vLA0KPiAgCQlpZiAodGVzdF9hbmRfc2V0
X2JpdChORlNfTEFZT1VUX0ZJUlNUX0xBWU9VVEdFVCwNCj4gIAkJCQkgICAgICZsby0+cGxoX2Zs
YWdzKSkgew0KPiAgCQkJc3Bpbl91bmxvY2soJmluby0+aV9sb2NrKTsNCj4gLQkJCXdhaXRfb25f
Yml0KCZsby0+cGxoX2ZsYWdzLCBORlNfTEFZT1VUX0ZJUlNUX0xBWU9VVEdFVCwNCj4gLQkJCQkg
ICAgVEFTS19VTklOVEVSUlVQVElCTEUpOw0KPiArCQkJbHNlZyA9IEVSUl9QVFIod2FpdF9vbl9i
aXQoJmxvLT5wbGhfZmxhZ3MsDQo+ICsJCQkJCQlORlNfTEFZT1VUX0ZJUlNUX0xBWU9VVEdFVCwN
Cj4gKwkJCQkJCVRBU0tfS0lMTEFCTEUpKTsNCj4gKwkJCWlmIChJU19FUlIobHNlZykpDQo+ICsJ
CQkJZ290byBvdXRfcHV0X2xheW91dF9oZHI7DQo+ICAJCQlwbmZzX3B1dF9sYXlvdXRfaGRyKGxv
KTsNCj4gIAkJCWRwcmludGsoIiVzIHJldHJ5aW5nXG4iLCBfX2Z1bmNfXyk7DQo+ICAJCQlnb3Rv
IGxvb2t1cF9hZ2FpbjsNCj4gQEAgLTE5MjUsNyArMTkzMCw4IEBAIHBuZnNfdXBkYXRlX2xheW91
dChzdHJ1Y3QgaW5vZGUgKmlubywNCj4gIAlpZiAodGVzdF9iaXQoTkZTX0xBWU9VVF9SRVRVUk4s
ICZsby0+cGxoX2ZsYWdzKSkgew0KPiAgCQlzcGluX3VubG9jaygmaW5vLT5pX2xvY2spOw0KPiAg
CQlkcHJpbnRrKCIlcyB3YWl0IGZvciBsYXlvdXRyZXR1cm5cbiIsIF9fZnVuY19fKTsNCj4gLQkJ
aWYgKHBuZnNfcHJlcGFyZV90b19yZXRyeV9sYXlvdXRnZXQobG8pKSB7DQo+ICsJCWxzZWcgPSBF
UlJfUFRSKHBuZnNfcHJlcGFyZV90b19yZXRyeV9sYXlvdXRnZXQobG8pKTsNCj4gKwkJaWYgKCFJ
U19FUlIobHNlZykpIHsNCj4gIAkJCWlmIChmaXJzdCkNCj4gIAkJCQlwbmZzX2NsZWFyX2ZpcnN0
X2xheW91dGdldChsbyk7DQo+ICAJCQlwbmZzX3B1dF9sYXlvdXRfaGRyKGxvKTsNCg==
