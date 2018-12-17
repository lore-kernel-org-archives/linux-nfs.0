Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C612C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 18:55:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B632820874
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 18:55:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="CevJfSDs"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728301AbeLQSzp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 13:55:45 -0500
Received: from mail-eopbgr680128.outbound.protection.outlook.com ([40.107.68.128]:49708
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1732389AbeLQSzp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Dec 2018 13:55:45 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=texKrfXQjdjqE8pairlKfyC0dM0x8+mlsWrtgSmCF+M=;
 b=CevJfSDsm3dQo16trR9zr5y2zpWUgL5f7Se5WujZa9ei9mgM7bHdZwJijpD0MZzxBv6DRdW/pZExJlC7MI0HJNTx8mr03k1MGwr5qFtnFFLZpZcg5LSIhxPuNMalWfaoAoTMrLIRiB84HwM7Lbm3X2IXl0xWiaOaA/OaAD7R9ck=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2478.namprd13.prod.outlook.com (52.135.95.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.10; Mon, 17 Dec 2018 18:55:28 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1446.015; Mon, 17 Dec 2018
 18:55:28 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 06/30] xprtrdma: Don't wake pending tasks until
 disconnect is done
Thread-Topic: [PATCH v4 06/30] xprtrdma: Don't wake pending tasks until
 disconnect is done
Thread-Index: AQHUlicnTIY1+P6R7kSNyXN8lbLAWaWDL5oAgAATPgCAAAT9gA==
Date:   Mon, 17 Dec 2018 18:55:27 +0000
Message-ID: <c639c203e1c9a5c0016a46e95ceb690744480583.camel@hammerspace.com>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
         <20181217163953.24133.29214.stgit@manet.1015granger.net>
         <f080c79d6722ad339e47e20c6da72f9b0fc8a297.camel@hammerspace.com>
         <FD0CDDF9-EDEF-41C6-83F5-C956F3FF098E@oracle.com>
In-Reply-To: <FD0CDDF9-EDEF-41C6-83F5-C956F3FF098E@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2478;6:tiarztmMFO6x7vACa5O5kPxvCoE/UC8gdXVkSyOH8D4iOKxt9RKrHww3Km/K95wQznvqyUj4vRHmxMB7iC7G1HGO/T2ZHSirxbLeJriYhRBSC4AqaRoWhfVh21HwreKoX0yTQcjINrwJHjtQcDGEpmA0wzcsOqNoe4Qx2Ir1rjhg3TU7TzlZJ67vJ+JpMTobrcVypuT7ILEvvpCoOpUzlDPR+5lQTXRrzvI4clJ19p7UDgkCoRpMpkxKGsFGyhGuHnvkZt/dgk/Or743XSo/yENWDS3anC165V23b1hHBOwqgQ7DL5C1aOg2iQ6Cm718GrAl9XSm6AGdRLFKIQaehpFXLZa7Hc97DtB2lfbD7UvgPwyEQ9+to1YM0Erezc9SdL6tAk+ZOF1p1m+xvvveVpuZ9pj607fHAqJqVJNQxbo28kilqNcCcH8uOZJiyZyqVdWuiKfH8N8+boBAjPoDtw==;5:Pk7pFooQvHMwvaC1vWXePqImAnoBFXWOPfOIw/GFyrR3CTEdPpzuUGYcEubQp6ktdHkTBKXmX6Ig0Rqqi3DsVEEuI4YrsZQmsFZQ1O2vOf/ZFCMHQVdrCdxqZHeamqGY7rJ6e05UwFhpoSoJdFpneo+vZYqA4q5PKaYpUcvZRsQ=;7:IOk46BXWHfBC9LxI9ZmQkI1R4gpvw+QheRA24bvdrSnSKttHzznO4d9ij/YvDzmu6sByLI/FWdLn+a7FKr0q2pHpunhZVSrJK5UZCa+A0Mke2rF3f/yGuTVRzNx2FyFKeJcqHvFX7U49VnUu1xlOgQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 14f7b888-7ad9-4736-bc8a-08d664513613
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2478;
x-ms-traffictypediagnostic: SN6PR13MB2478:
x-microsoft-antispam-prvs: <SN6PR13MB24788C9646BFF2583961E6CCB8BC0@SN6PR13MB2478.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(3231475)(944501520)(52105112)(3002001)(10201501046)(148016)(149066)(150057)(6041310)(20161123564045)(20161123562045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2478;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2478;
x-forefront-prvs: 08897B549D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(376002)(366004)(396003)(39830400003)(199004)(189003)(51444003)(93886005)(478600001)(5640700003)(6512007)(316002)(5660300001)(6246003)(7736002)(25786009)(305945005)(68736007)(4326008)(53936002)(54906003)(6116002)(3846002)(97736004)(81166006)(102836004)(53546011)(186003)(8676002)(26005)(36756003)(8936002)(76176011)(66066001)(99286004)(118296001)(2501003)(6506007)(86362001)(6436002)(4001150100001)(106356001)(105586002)(71200400001)(81156014)(71190400001)(6486002)(2616005)(476003)(486006)(229853002)(6916009)(256004)(14444005)(14454004)(446003)(11346002)(2351001)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2478;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: cQKae9aZwePDRzoURT6kE8h6azz3w6onAP6jDUM7BvA9BtTP5YoIx6H2N+buQPYSJ2ls14MjjMBpJ27M2AuWsxGgWDPnHCydt/ZHVu07Usz7NXKWXjxKbUiWZwl0UdPFIMcuJDpYu6EzZ1rthfsIcKearTQ+dCy/YCLpYw7Bifw5PmHCGj1s1mQBUCT6L2yTgW+M6oq4YnU+pjK3AciMfolp6yXaE91OQMd9Q+KhCaOg8HrieeiCYni1Stw/tpiO1fdWTTWuBN0492u+Kyr/c2/V77TMu7+5+0VqL+unPA48mPikcZZ3emsA7rws9vaf
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <3749D4328FEFAD449D92AE46BABE605C@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 14f7b888-7ad9-4736-bc8a-08d664513613
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Dec 2018 18:55:28.0824
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2478
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE4LTEyLTE3IGF0IDEzOjM3IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBEZWMgMTcsIDIwMTgsIGF0IDEyOjI4IFBNLCBUcm9uZCBNeWtsZWJ1c3QgPA0KPiA+IHRy
b25kbXlAaGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiANCj4gPiBPbiBNb24sIDIwMTgtMTIt
MTcgYXQgMTE6MzkgLTA1MDAsIENodWNrIExldmVyIHdyb3RlOg0KPiA+ID4gVHJhbnNwb3J0IGRp
c2Nvbm5lY3QgcHJvY2Vzc2luZyBkb2VzIGEgIndha2UgcGVuZGluZyB0YXNrcyIgYXQNCj4gPiA+
IHZhcmlvdXMgcG9pbnRzLg0KPiA+ID4gDQo+ID4gPiBTdXBwb3NlIGFuIFJQQyBSZXBseSBpcyBi
ZWluZyBwcm9jZXNzZWQuIFRoZSBSUEMgdGFzayB0aGF0IFJlcGx5DQo+ID4gPiBnb2VzIHdpdGgg
aXMgd2FpdGluZyBvbiB0aGUgcGVuZGluZyBxdWV1ZS4gSWYgYSBkaXNjb25uZWN0IHdha2UtDQo+
ID4gPiB1cA0KPiA+ID4gaGFwcGVucyBiZWZvcmUgcmVwbHkgcHJvY2Vzc2luZyBpcyBkb25lLCB0
aGF0IHJlcGx5LCBldmVuIGlmIGl0DQo+ID4gPiBpcw0KPiA+ID4gZ29vZCwgaXMgdGhyb3duIGF3
YXksIGFuZCB0aGUgUlBDIGhhcyB0byBiZSBzZW50IGFnYWluLg0KPiA+ID4gDQo+ID4gPiBUaGlz
IHdpbmRvdyBhcHBhcmVudGx5IGRvZXMgbm90IGV4aXN0IGZvciBzb2NrZXQgdHJhbnNwb3J0cw0K
PiA+ID4gYmVjYXVzZQ0KPiA+ID4gdGhlcmUgaXMgYSBsb2NrIGhlbGQgd2hpbGUgYSByZXBseSBp
cyBiZWluZyByZWNlaXZlZCB3aGljaA0KPiA+ID4gcHJldmVudHMNCj4gPiA+IHRoZSB3YWtlLXVw
IGNhbGwgdW50aWwgYWZ0ZXIgcmVwbHkgcHJvY2Vzc2luZyBpcyBkb25lLg0KPiA+ID4gDQo+ID4g
PiBUbyByZXNvbHZlIHRoaXMsIGFsbCBSUEMgcmVwbGllcyBiZWluZyBwcm9jZXNzZWQgb24gYW4g
UlBDLW92ZXItDQo+ID4gPiBSRE1BDQo+ID4gPiB0cmFuc3BvcnQgaGF2ZSB0byBjb21wbGV0ZSBi
ZWZvcmUgcGVuZGluZyB0YXNrcyBhcmUgYXdva2VuIGR1ZSB0bw0KPiA+ID4gYQ0KPiA+ID4gdHJh
bnNwb3J0IGRpc2Nvbm5lY3QuDQo+ID4gPiANCj4gPiA+IENhbGxlcnMgdGhhdCBhbHJlYWR5IGhv
bGQgdGhlIHRyYW5zcG9ydCB3cml0ZSBsb2NrIG1heSBpbnZva2UNCj4gPiA+IC0+b3BzLT5jbG9z
ZSBkaXJlY3RseS4gT3RoZXJzIHVzZSBhIGdlbmVyaWMgaGVscGVyIHRoYXQgc2NoZWR1bGVzDQo+
ID4gPiBhIGNsb3NlIHdoZW4gdGhlIHdyaXRlIGxvY2sgY2FuIGJlIHRha2VuIHNhZmVseS4NCj4g
PiA+IA0KPiA+ID4gU2lnbmVkLW9mZi1ieTogQ2h1Y2sgTGV2ZXIgPGNodWNrLmxldmVyQG9yYWNs
ZS5jb20+DQo+ID4gPiAtLS0NCj4gPiA+IGluY2x1ZGUvbGludXgvc3VucnBjL3hwcnQuaCAgICAg
ICAgICAgICAgICB8ICAgIDEgKw0KPiA+ID4gbmV0L3N1bnJwYy94cHJ0LmMgICAgICAgICAgICAg
ICAgICAgICAgICAgIHwgICAxOQ0KPiA+ID4gKysrKysrKysrKysrKysrKysrKw0KPiA+ID4gbmV0
L3N1bnJwYy94cHJ0cmRtYS9iYWNrY2hhbm5lbC5jICAgICAgICAgIHwgICAxMyArKysrKysrLS0t
LS0tDQo+ID4gPiBuZXQvc3VucnBjL3hwcnRyZG1hL3N2Y19yZG1hX2JhY2tjaGFubmVsLmMgfCAg
ICA4ICsrKysrLS0tDQo+ID4gPiBuZXQvc3VucnBjL3hwcnRyZG1hL3RyYW5zcG9ydC5jICAgICAg
ICAgICAgfCAgIDE2ICsrKysrKysrKystLS0tLQ0KPiA+ID4gLQ0KPiA+ID4gbmV0L3N1bnJwYy94
cHJ0cmRtYS92ZXJicy5jICAgICAgICAgICAgICAgIHwgICAgNSArKy0tLQ0KPiA+ID4gNiBmaWxl
cyBjaGFuZ2VkLCA0NCBpbnNlcnRpb25zKCspLCAxOCBkZWxldGlvbnMoLSkNCj4gPiA+IA0KPiA+
ID4gZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvc3VucnBjL3hwcnQuaA0KPiA+ID4gYi9pbmNs
dWRlL2xpbnV4L3N1bnJwYy94cHJ0LmgNCj4gPiA+IGluZGV4IGE0YWI0ZjguLmVlOTRlZDAgMTAw
NjQ0DQo+ID4gPiAtLS0gYS9pbmNsdWRlL2xpbnV4L3N1bnJwYy94cHJ0LmgNCj4gPiA+ICsrKyBi
L2luY2x1ZGUvbGludXgvc3VucnBjL3hwcnQuaA0KPiA+ID4gQEAgLTQwMSw2ICs0MDEsNyBAQCBz
dGF0aWMgaW5saW5lIF9fYmUzMg0KPiA+ID4gKnhwcnRfc2tpcF90cmFuc3BvcnRfaGVhZGVyKHN0
cnVjdCBycGNfeHBydCAqeHBydCwgX19iZTMyICoNCj4gPiA+IGJvb2wJCQl4cHJ0X3JlcXVlc3Rf
Z2V0X2Nvbmcoc3RydWN0IHJwY194cHJ0DQo+ID4gPiAqeHBydCwNCj4gPiA+IHN0cnVjdCBycGNf
cnFzdCAqcmVxKTsNCj4gPiA+IHZvaWQJCQl4cHJ0X2Rpc2Nvbm5lY3RfZG9uZShzdHJ1Y3QgcnBj
X3hwcnQNCj4gPiA+ICp4cHJ0KTsNCj4gPiA+IHZvaWQJCQl4cHJ0X2ZvcmNlX2Rpc2Nvbm5lY3Qo
c3RydWN0IHJwY194cHJ0DQo+ID4gPiAqeHBydCk7DQo+ID4gPiArdm9pZAkJCXhwcnRfZGlzY29u
bmVjdF9ub3dha2Uoc3RydWN0IHJwY194cHJ0DQo+ID4gPiAqeHBydCk7DQo+ID4gPiB2b2lkCQkJ
eHBydF9jb25kaXRpb25hbF9kaXNjb25uZWN0KHN0cnVjdA0KPiA+ID4gcnBjX3hwcnQNCj4gPiA+
ICp4cHJ0LCB1bnNpZ25lZCBpbnQgY29va2llKTsNCj4gPiA+IA0KPiA+ID4gYm9vbAkJCXhwcnRf
bG9ja19jb25uZWN0KHN0cnVjdCBycGNfeHBydCAqLA0KPiA+ID4gc3RydWN0DQo+ID4gPiBycGNf
dGFzayAqLCB2b2lkICopOw0KPiA+ID4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBydC5jIGIv
bmV0L3N1bnJwYy94cHJ0LmMNCj4gPiA+IGluZGV4IGNlOTI3MDAuLmFmZTQxMmUgMTAwNjQ0DQo+
ID4gPiAtLS0gYS9uZXQvc3VucnBjL3hwcnQuYw0KPiA+ID4gKysrIGIvbmV0L3N1bnJwYy94cHJ0
LmMNCj4gPiA+IEBAIC02ODUsNiArNjg1LDI1IEBAIHZvaWQgeHBydF9mb3JjZV9kaXNjb25uZWN0
KHN0cnVjdCBycGNfeHBydA0KPiA+ID4gKnhwcnQpDQo+ID4gPiB9DQo+ID4gPiBFWFBPUlRfU1lN
Qk9MX0dQTCh4cHJ0X2ZvcmNlX2Rpc2Nvbm5lY3QpOw0KPiA+ID4gDQo+ID4gPiArLyoqDQo+ID4g
PiArICogeHBydF9kaXNjb25uZWN0X25vd2FrZSAtIGZvcmNlIGEgY2FsbCB0byB4cHJ0LT5vcHMt
PmNsb3NlDQo+ID4gPiArICogQHhwcnQ6IHRyYW5zcG9ydCB0byBkaXNjb25uZWN0DQo+ID4gPiAr
ICoNCj4gPiA+ICsgKiBUaGUgY2FsbGVyIG11c3QgZW5zdXJlIHRoYXQgeHBydF93YWtlX3BlbmRp
bmdfdGFza3MoKSBpcw0KPiA+ID4gKyAqIGNhbGxlZCBsYXRlci4NCj4gPiA+ICsgKi8NCj4gPiA+
ICt2b2lkIHhwcnRfZGlzY29ubmVjdF9ub3dha2Uoc3RydWN0IHJwY194cHJ0ICp4cHJ0KQ0KPiA+
ID4gK3sNCj4gPiA+ICsgICAgICAgLyogRG9uJ3QgcmFjZSB3aXRoIHRoZSB0ZXN0X2JpdCgpIGlu
IHhwcnRfY2xlYXJfbG9ja2VkKCkNCj4gPiA+ICovDQo+ID4gPiArICAgICAgIHNwaW5fbG9ja19i
aCgmeHBydC0+dHJhbnNwb3J0X2xvY2spOw0KPiA+ID4gKyAgICAgICBzZXRfYml0KFhQUlRfQ0xP
U0VfV0FJVCwgJnhwcnQtPnN0YXRlKTsNCj4gPiA+ICsgICAgICAgLyogVHJ5IHRvIHNjaGVkdWxl
IGFuIGF1dG9jbG9zZSBSUEMgY2FsbCAqLw0KPiA+ID4gKyAgICAgICBpZiAodGVzdF9hbmRfc2V0
X2JpdChYUFJUX0xPQ0tFRCwgJnhwcnQtPnN0YXRlKSA9PSAwKQ0KPiA+ID4gKyAgICAgICAgICAg
ICAgIHF1ZXVlX3dvcmsoeHBydGlvZF93b3JrcXVldWUsICZ4cHJ0LQ0KPiA+ID4gPnRhc2tfY2xl
YW51cCk7DQo+ID4gPiArICAgICAgIHNwaW5fdW5sb2NrX2JoKCZ4cHJ0LT50cmFuc3BvcnRfbG9j
ayk7DQo+ID4gPiArfQ0KPiA+ID4gK0VYUE9SVF9TWU1CT0xfR1BMKHhwcnRfZGlzY29ubmVjdF9u
b3dha2UpOw0KPiA+ID4gKw0KPiA+IA0KPiA+IFdlIHNob3VsZG4ndCBuZWVkIGJvdGggeHBydF9k
aXNjb25uZWN0X25vd2FrZSgpIGFuZA0KPiA+IHhwcnRfZm9yY2VfZGlzY29ubmVjdCgpIHRvIGJl
IGV4cG9ydGVkIGdpdmVuIHRoYXQgeW91IGNhbiBidWlsZCB0aGUNCj4gPiBsYXR0ZXIgZnJvbSB0
aGUgZm9ybWVyICsgeHBydF93YWtlX3BlbmRpbmdfdGFza3MoKSAod2hpY2ggaXMgYWxzbw0KPiA+
IGFscmVhZHkgZXhwb3J0ZWQpLg0KPiANCj4gVGhhbmtzIGZvciB5b3VyIHJldmlldyENCj4gDQo+
IEkgY2FuIGdldCByaWQgb2YgeHBydF9kaXNjb25uZWN0X25vd2FrZS4gVGhlcmUgYXJlIHNvbWUg
dmFyaWF0aW9ucywNCj4gZGVwZW5kaW5nIG9uIHdoeSB3YWtlX3BlbmRpbmdfdGFza3MgaXMgcHJv
dGVjdGVkIGJ5IHhwcnQtDQo+ID50cmFuc3BvcnRfbG9jay4NCg0KSSdtIGhhdmluZyBzb21lIHNl
Y29uZCB0aG91Z2h0cyBhYm91dCB0aGUgcGF0Y2ggdGhhdCBTY290dCBzZW50IG91dA0KbGFzdCB3
ZWVrIHRvIGZpeCB0aGUgaXNzdWUgdGhhdCBEYXZlIGFuZCBoZSB3ZXJlIHNlZWluZy4gSSB0aGlu
ayB0aGF0DQp3aGF0IHdlIHJlYWxseSBuZWVkIHRvIGRvIHRvIGZpeCBoaXMgaXNzdWUgaXMgdG8g
Y2FsbA0KeHBydF9kaXNjb25uZWN0X2RvbmUoKSBhZnRlciB3ZSd2ZSByZWxlYXNlZCB0aGUgVENQ
IHNvY2tldC4NCg0KR2l2ZW4gdGhhdCByZWFsaXNhdGlvbiwgSSB0aGluayB0aGF0IHdlIGNhbiBm
aXggdXANCnhwcnRfZm9yY2VfZGlzY29ubmVjdCgpIHRvIG9ubHkgd2FrZSB1cCB0aGUgdGFzayB0
aGF0IGhvbGRzIHRoZQ0KWFBSVF9MT0NLRUQgaW5zdGVhZCBvZiBkb2luZyBhIHRodW5kZXJpbmcg
aGVyZCB3YWtldXAgbGlrZSB3ZSBkbyB0b2RheS4NClRoYXQgc2hvdWxkIChJIHRoaW5rKSBvYnZp
YXRlIHRoZSBuZWVkIGZvciBhIHNlcGFyYXRlDQp4cHJ0X2Rpc2Nvbm5lY3Rfbm93YWtlKCkuDQoN
CkEgcGF0Y2ggaXMgZm9ydGhjb21pbmcgbGF0ZXIgdG9kYXkuIEknbGwgbWFrZSBzdXJlIHlvdSBh
cmUgQ2NlZCBzbyB5b3UNCmNhbiBjb21tZW50Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGlu
dXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhh
bW1lcnNwYWNlLmNvbQ0KDQoNCg==
