Return-Path: <SRS0=m0hb=NO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B93DC0044C
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Nov 2018 05:40:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 985312081B
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Nov 2018 05:40:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="n7p6Gc+K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 985312081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726147AbeKCOuT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Nov 2018 10:50:19 -0400
Received: from mail-co1nam03on0094.outbound.protection.outlook.com ([104.47.40.94]:20704
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726129AbeKCOuS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 3 Nov 2018 10:50:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=SCcJyuQtl62/WfuNmk65Iw3BSH9ChK3tpbw51727FBk=;
 b=n7p6Gc+KQil8udXfiksfiosChZh6xLA6pRsH90Olyft5nzWdbc7yjXbCPuxM8aN7aQaBgRjHo3hFKdYDrP1iBUEIPKfMXtcrdzhNPirqTMhAj2vPt85+9p0RNh6ad5yffc8pHNX5ggNrSbYvdpvf0vOBhNDNosp8C19Xnuoa/e0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2237.namprd13.prod.outlook.com (52.135.93.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.14; Sat, 3 Nov 2018 05:40:04 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1294.024; Sat, 3 Nov 2018
 05:40:04 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "malahal@gmail.com" <malahal@gmail.com>
CC:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: "(deleted)" directories
Thread-Topic: "(deleted)" directories
Thread-Index: AQHUcmyqhAuTrD/t40CG05LKPmMcxKU8UwcAgABQ1ACAAEv8gIAAj6WAgAAK/wA=
Date:   Sat, 3 Nov 2018 05:40:04 +0000
Message-ID: <2d78df48703c0e0840e09127f41add4c10ac5af2.camel@hammerspace.com>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
         <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com>
         <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com>
         <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com>
         <CAGD+tkyLAVn62Yb8SHig1rV8+3h7_fZzVaPuYA0ts=sHoYgSYw@mail.gmail.com>
In-Reply-To: <CAGD+tkyLAVn62Yb8SHig1rV8+3h7_fZzVaPuYA0ts=sHoYgSYw@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2237;6:uTU4YZDPUrmSeZgJ8hZPKvutinYZrTggXIoNikiGsOFEO9wZ+OS209/9W8e4Hurhr9Pm2T9GlEPVdUIvxMYsPA0S+s1gYLzYpp67QoZdraC0mA1NLtU6gMCMzh/4KaGHRHibqSJriI4ONnZwBfxgyC3MLs9gBBchI6g4uDr/sP5RICKbYoKiGuPXq3n8+OTg4aJEhIEFrSmF/T6vrnB6FGjNEEuZ/U074xx+hNf5nRdcU/CjQU1f1QA3Do4zSLXMntRClZ2gZoNv+gtFxmM6lpXumco61jbuyMei7uM1ljQh2kfkKRTbipvCPm6qXVq8Ie7blU7o8SnZUPJZx6X2p51qrCExq4QJJeLdqTExA5z3Sqqqic3LAlHv2FFL3Ee14Nfc2QI+uCm1K1NA4v9n7bn0JfXJmsQ7sWKvivvfy4rIF0qmBlSybe/nB6ujUWBNLbd4PjiOl3eEx9r7oezoeQ==;5:7l9Wrvd5wePU3Plnj+Kbzgh1aZP+p/l0VfTaumsRF1Uk2d3f0Hg4OtQu0fCMohbS4eXU8m346wAnLR5hj5oLe9IjzEsfbd4S9uFRiTpf61XuVnePZVwVcz2pkAhIpiADouNkhASgVSM90z2zvVQW8di0vtTurgI2Vxr4gUI/pX4=;7:H3gFjnR2i9qPwIx4hRzMBE9JOieGj4Qm946LySP9p5nLzTCg6ZanONbkyoJVXW82wX3NyeOkaQK1MchNfzoMTY9pJTpm7Qn7AUAdp102sdHwNuxCr3Me4fklvrvFd6X0sR0zcUlMK+uwXa7vQf7RCQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 88bc82f3-c03e-4d9c-c6c1-08d6414ece58
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2237;
x-ms-traffictypediagnostic: SN6PR13MB2237:
x-microsoft-antispam-prvs: <SN6PR13MB2237E619C4F17CD286A86001B8C80@SN6PR13MB2237.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:(158342451672863)(20558992708506);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(3231382)(944501410)(52105095)(93006095)(93001095)(3002001)(10201501046)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123558120)(20161123562045)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2237;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2237;
x-forefront-prvs: 08457955C4
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(376002)(346002)(39830400003)(136003)(53754006)(189003)(199004)(99286004)(186003)(6506007)(305945005)(102836004)(53546011)(36756003)(575784001)(86362001)(6246003)(8936002)(118296001)(14444005)(15974865002)(68736007)(6916009)(2900100001)(11346002)(478600001)(97736004)(5660300001)(26005)(2616005)(71190400001)(476003)(14454004)(446003)(71200400001)(256004)(6116002)(1411001)(3846002)(1730700003)(39060400002)(8676002)(93886005)(66066001)(316002)(486006)(1361003)(2906002)(54906003)(4326008)(6512007)(5640700003)(6436002)(7736002)(76176011)(105586002)(6486002)(2351001)(25786009)(106356001)(2501003)(53936002)(229853002)(81156014)(81166006);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2237;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: P+hwLi8L30fJJD8vSRbTt37wYdTzM4Ma24qOOEU4QWr01VA0mKTRxl5zbYuunL0p/tn3AT//G0M1ySlAcU70KbYysYHQir0/O1yYYvb+HNLvFG0kPToYN2mETwtshuc7LtQFH10HhmSG5hS7V/2L3oEjJCNxdPyYGokGNMDLtTC56VtdwZ42DxJJo/JcC+YxUuMzFUzpJ9vYcixr2EcY7JeqYfjbqbHILJJ4QpF5m7Ik4k3LiGpLWT8pKBbHEBI3ygr2yYiOHx3+c2bOH76pch0A9sUA3Vxt8AdxgdsCYa12DM/jwHaey2pNCmHmm5/ntqE4iz2rEiqHFHS0qdm8sxwTeFWlApJNEYdv4z5C6Sc=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <73325B898FE12C4AA671E55E95758EDA@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 88bc82f3-c03e-4d9c-c6c1-08d6414ece58
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Nov 2018 05:40:04.3502
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2237
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gU2F0LCAyMDE4LTExLTAzIGF0IDEwOjMwICswNTMwLCBNYWxhaGFsIE5haW5lbmkgd3JvdGU6
DQo+ID4gV2h5IGRvZXMgeW91ciBzZXJ2ZXIgbmVlZCB0byBoYXZlIG11bHRpcGxlIGZpbGVoYW5k
bGVzIHJlZmVyIHRvIHRoZQ0KPiA+IHNhbWUgZmlsZQ0KPiANCj4gVHJvbmQsIHRoZSBmaXJzdCB0
aGluZyBJIHdhbnQgdG8gdW5kZXJzdGFuZCBpcyB0aGF0IHRoaXMgc2VydmVyJ3MNCj4gbXVsdGlw
bGUgZmlsZWhhbmRsZXMgcmVmZXJyaW5nIHRvIHRoZSBzYW1lIGZpbGUvZGlyZWN0b3J5IGlzIHRo
ZQ0KPiByZWFzb24gZm9yIHRoZSBjbGllbnQncyBiZWhhdmlvciBkZXNjcmliZWQgaW4gdGhpcyBl
bWFpbC4gSSBhbSBwcmV0dHkNCj4gc3VyZSBpdCBpcywgYnV0IHdhbnQgYSBjb25maXJtYXRpb24h
DQoNCldlIHRyZWF0IGFsd2F5cyBkaWZmZXJlbnQgZmlsZWhhbmRsZXMgYXMgaWYgdGhleSByZWZl
ciB0byBkaWZmZXJlbnQNCmZpbGVzLiBJdCBoYXMgbG9uZyBiZWVuIHRoZSBjYXNlIHRoYXQgc25h
cHNob3RzIGZyb20gc2V2ZXJhbCB2ZW5kb3JzDQphcmUgZW5jb2RlZCB0byBsb29rIGxpa2UgdGhl
IHNhbWUgZmlsZSAoc2FtZSBmaWxlaWQgKyBzYW1lICBmc2lkKSBhbmQNCmRpZmZlcmluZyBvbmx5
IGJ5IGZpbGVoYW5kbGUuIElmIHdlIHdlcmUgdG8gdHJ5IHRvIGNvbnNvbGlkYXRlIHRob3NlDQpp
bm9kZXMgd2Ugd291bGQgZW5kIHVwIGNvcnJ1cHRpbmcgYXBwbGljYXRpb24gZGF0YS4NCg0KTm90
ZSB0aGF0IHRoaXMgc2hvdWxkIGJlIGNvbnNpc3RlbnQgd2l0aCBORlN2NCwgd2hlcmUgdGhlIHN0
YXRlIG1vZGVsDQpyZXF1aXJlcyB0aGUgY2xpZW50IHRvIHRyZWF0IHN0YXRlIHRoYXQgYmVsb25n
cyB0byBkaWZmZXJlbnQNCmZpbGVoYW5kbGVzIGFzIGlmIGl0IHdlcmUgcmVmZXJyaW5nIHRvIGRp
ZmZlcmVudCBmaWxlcy4gVGhlIGNsaWVudCBpcw0KYWxsb3dlZCB0byAoYnV0IG5vdCByZXF1aXJl
ZCB0bykgY29uc29saWRhdGUgdGhlIGZpbGUgIGRhdGEgY2FjaGVzIGluDQp0aGVzZSBjYXNlcywg
aG93ZXZlciBpdCBtYXkgbm90IGNvbnNvbGlkYXRlIGZpbGUgZGVsZWdhdGlvbiwgbGF5b3V0LA0K
c2hhcmUgb3IgYnl0ZSByYW5nZSBsb2NraW5nIHN0YXRlLg0KDQpOb3RlIGFsc28gdGhhdCB0aGUg
TGludXggVkZTJ3MgZGNhY2hlIG1vZGVsIGRvZXMgbm90IGF0IGFsbCBzdXBwb3J0DQpoYXJkIGxp
bmtlZCBkaXJlY3Rvcmllcywgbm9yIGRvZXMgaXQgcmVhbGx5IGFsbG93IGZvciBhbGlhc2VkIGRl
bnRyaWVzLg0KDQo+IEdhbmVzaGEgYnkgZGVzaWduIHVzZXMgb25lIGZpbGUgaGFuZGxlIG9uIGJp
ZyBlbmRpYW4gc3lzdGVtcyBhbmQNCj4gYW5vdGhlciBvbmUgb24gbGl0dGxlIGVuZGlhbiBzeXN0
ZW1zLiBJZiBhIG1peGVkIGNsdXN0ZXIgaXMgZ29pbmcgdG8NCj4gc2VydmUgdGhlIHNhbWUgZmls
ZSBzeXN0ZW0sIHRoZW4gdGhlIHNhbWUgZmlsZSB3aWxsIGhhdmUgYXQgbGVhc3QgdHdvDQo+IGRp
ZmZlcmVudCBmaWxlIGhhbmRsZXMuIFRoaXMgaXMgcHJvYmFibHkgZG9uZSB0byBhdm9pZCBuZWVk
bGVzcw0KPiBob3N0Mm5ldCBhbmQgbmV0Mmhvc3QgaW50ZWdlciBjb252ZXJzaW9ucy4NCg0KVGhl
IExpbnV4IGNsaWVudCB3aWxsIG5vdCB0cmVhdCB0aG9zZSBmaWxlaGFuZGxlcyBhcyBpZiB0aGV5
IHJlZmVyIHRvDQp0aGUgc2FtZSBpbm9kZSBmb3IgdGhlIHJlYXNvbnMgc3RhdGVkIGFib3ZlLiBJ
IHVuZGVyc3RhbmQgeW91cg0KcGVyZm9ybWFuY2UgbW90aXZhdGlvbiwgYnV0IGJhY2t3YXJkIGNv
bXBhdGliaWxpdHkgd2l0aCBleGlzdGluZyBzZXR1cHMNCm11c3QgY29tZSBmaXJzdC4NCg0KTm90
ZSB0aGF0IGlmIGVhY2ggZmlsZXN5c3RlbSBpcyBzZXJ2ZWQgZnJvbSBvbmx5IG9uZSBzZXJ2ZXIs
IHRoZW4NCmV2ZXJ5dGhpbmcgd2lsbCB3b3JrIGZpbmUsIEl0IGlzIHdoZW4geW91IHN0YXJ0IHRv
IHBsYXkgZ2FtZXMgd2l0aA0KY2x1c3RlcmluZyBJUCBhZGRyZXNzZXMgb3Igc2ltaWxhciB0aGF0
IHRoaW5ncyBicmVhaywgYW5kIGFzIEkgc2FpZCwNCnRoZSBORlN2NCBwcm90b2NvbCB3b3VsZCBi
ZSBhIGhvcnJpYmxlIG1lc3MgZm9yIHRoaXMgY2FzZS4NCg0KPiBBbHNvLCBob3cgZG8gc2VydmVy
cyBkZWFsIHdpdGggdmVyc2lvbiBjaGFuZ2VzIGluIGZpbGUgaGFuZGxlPyBMb29rcw0KPiBsaWtl
IGxpdmUgbWlncmF0aW9ucyB3aWxsIGJlIGJyb2tlbiB3aGVuIHRoZXJlIGlzIGEgZmlsZSBoYW5k
bGUNCj4gdmVyc2lvbiBjaGFuZ2U/DQoNClN1cmUsIGJ1dCBhZ2FpbiBubyBleGlzdGluZyBzZXJ2
ZXJzIGFyZSB1c2luZyB0aGF0IGZlYXR1cmUgYW5kIG5vYm9keQ0Kc28gZmFyIGhhcyB2b2x1bnRl
ZXJlZCBhbnkgaW50ZXJlc3QgaW4gd29ya2luZyBvbiBpdC4NCg0KPiBSZWdhcmRzLCBNYWxhaGFs
Lg0KPiANCj4gT24gU2F0LCBOb3YgMywgMjAxOCBhdCAxOjU2IEFNIFRyb25kIE15a2xlYnVzdCA8
DQo+IHRyb25kbXlAaGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiBPbiBGcmksIDIwMTgtMTEt
MDIgYXQgMjE6MjQgKzA1MzAsIE1hbGFoYWwgTmFpbmVuaSB3cm90ZToNCj4gPiA+IEJlbiwgTkZT
djMgUkZDMTgxMy50eHQgc3RhdGVzOiAiSWYgdHdvIGZpbGUgaGFuZGxlcyBmcm9tIHRoZSBzYW1l
DQo+ID4gPiBzZXJ2ZXIgYXJlIGVxdWFsLCB0aGV5IG11c3QgcmVmZXIgdG8gdGhlIHNhbWUgZmls
ZSwgYnV0IGlmDQo+ID4gPiB0aGV5ICBhcmUNCj4gPiA+IG5vdCBlcXVhbCwgbm8gY29uY2x1c2lv
bnMgY2FuIGJlIGRyYXduLiIgR2FuZXNoYSBkb2VzIHJldHVybiBzYW1lDQo+ID4gPiBmaWxlaWQg
aGVyZSAoaW5vZGUpLg0KPiA+ID4gDQo+ID4gPiBJbiBORlN2NCwgdGhleSBoYXZlIGludHJvZHVj
ZWQgInVuaXF1ZV9oYW5kbGVzIiBhdHRyaWJ1dGUuIEkNCj4gPiA+IGRvbid0DQo+ID4gPiBzZWUN
Cj4gPiA+IExpbnV4IE5GUyBjbGllbnQgdXNpbmcgdGhpcyBhdCBhbGwgdGhvdWdoLg0KPiA+IA0K
PiA+IFdoeSBkb2VzIHlvdXIgc2VydmVyIG5lZWQgdG8gaGF2ZSBtdWx0aXBsZSBmaWxlaGFuZGxl
cyByZWZlciB0byB0aGUNCj4gPiBzYW1lIGZpbGUsIGFuZCB3aHkgZG8geW91IGV4cGVjdCBjbGll
bnRzIHRvIHN1cHBvcnQgdGhpcz8NCj4gPiANCj4gPiBZZXMsIHRoZSBzcGVjIGFsbG93cyBpdCwg
YnV0IHRoYXQncyBub3QgYSBzdWZmaWNpZW50IHJlYXNvbi4NCj4gPiANCj4gPiA+IFJlZ2FyZHMs
IE1hbGFoYWwuDQo+ID4gPiBPbiBGcmksIE5vdiAyLCAyMDE4IGF0IDQ6MzUgUE0gQmVuamFtaW4g
Q29kZGluZ3RvbiA8DQo+ID4gPiBiY29kZGluZ0ByZWRoYXQuY29tPiB3cm90ZToNCj4gPiA+ID4g
T24gMiBOb3YgMjAxOCwgYXQgMToyNiwgTWFsYWhhbCBOYWluZW5pIHdyb3RlOg0KPiA+ID4gPiAN
Cj4gPiA+ID4gPiBIaSBBbGwsIHdlIGFyZSB1c2luZyBORlMtR2FuZXNoYSB3aXRoIExpbnV4IE5G
UyBjbGllbnRzLiBUaGUNCj4gPiA+ID4gPiBjbGllbnQncw0KPiA+ID4gPiA+IHNoZWxsIHJlcG9y
dHMgdGhlIGZvbGxvd2luZy4gQmFzZWQgb24gbHNvZiwgdGhlIGRpcmVjdG9yeSBpcw0KPiA+ID4g
PiA+IG1hcmtlZA0KPiA+ID4gPiA+IGRlbGV0ZWQuICJjZCB0byBST09UIGFuZCBjZCB0byB0aGUg
c2FtZSBob21lIGRpcmVjdG9yeSBmaXhlcw0KPiA+ID4gPiA+IHRoZQ0KPiA+ID4gPiA+IGlzc3Vl
LiBUaGUgY2xpZW50IGJlaGF2ZXMgYXMgdGhvdWdoIHRoZSBkaXJlY3RvcnkgaXMgZGVsZXRlZA0K
PiA+ID4gPiA+IGFuZA0KPiA+ID4gPiA+IHJlY3JlYXRlZCEgT3VyIE5GUy1HYW5lc2hhIHNlcnZl
ciBpbXBsZW1lbnRhdGlvbiB1c2VzDQo+ID4gPiA+ID4gbXVsdGlwbGUNCj4gPiA+ID4gPiBmaWxl
DQo+ID4gPiA+ID4gaGFuZGxlcyB0aGF0IHBvaW50IHRvIHRoZSBzYW1lIG9iamVjdC4gTkZTIHNw
ZWMgc2F5cyB0aGlzDQo+ID4gPiA+ID4gc2hvdWxkDQo+ID4gPiA+ID4gYmUNCj4gPiA+ID4gPiBm
aW5lLCBidXQgTGludXggTkZTIHNlZW1zIHRvIGJlIGJyb2tlbiBpbiB0aGlzIHJlZ2FyZC4NCj4g
PiA+ID4gPiB0Y3BkdW1wDQo+ID4gPiA+ID4gZG9lcw0KPiA+ID4gPiA+IGluZGljYXRlIGZpbGUg
aGFuZGxlIGNoYW5nZSAobm90ZSB0aGF0IGFsbCBmaWxlIGhhbmRsZXMgYXJlDQo+ID4gPiA+ID4g
cGVybWFuZW50LA0KPiA+ID4gPiA+IG1lYW5pbmcgdGhleSBhcmUgdmFsaWQgYXQgdGhlIHNlcnZl
ciBhbnkgdGltZSkgYXJvdW5kIHRoaXMNCj4gPiA+ID4gPiBpc3N1ZQ0KPiA+ID4gPiA+IHRpbWUu
DQo+ID4gPiA+ID4gDQo+ID4gPiA+ID4gInNoZWxsLWluaXQ6IGVycm9yIHJldHJpZXZpbmcgY3Vy
cmVudCBkaXJlY3Rvcnk6IGdldGN3ZDoNCj4gPiA+ID4gPiBjYW5ub3QNCj4gPiA+ID4gPiBhY2Nl
c3MNCj4gPiA+ID4gPiBwYXJlbnQgZGlyZWN0b3JpZXM6IE5vIHN1Y2ggZmlsZSBvciBkaXJlY3Rv
cnkiDQo+ID4gPiA+ID4gc2ggICAgICAgIDExMjU0NCAgICAgICAgICAgIG1hbGFoYWwgIGN3ZCAg
ICAgICBESVINCj4gPiA+ID4gPiAwLDY3DQo+ID4gPiA+ID4gICAgICA2NTUzNiAgIDQ1NjA1MjA5
IC9ob21lL21hbGFoYWwgKGRlbGV0ZWQpDQo+ID4gPiA+ID4gKDEwLjEyMC4xNTQuNDI6L25mcy9t
YWxhaGFsLWV4cG9ydC8pDQo+ID4gPiA+ID4gDQo+ID4gPiA+ID4gRnVuY3Rpb24gbmZzX3ByaW1l
X2RjYWNoZSgpIHNlZW1zIHRvIGludmFsaWRhdGUgdGhlIGRjYWNoZQ0KPiA+ID4gPiA+IGVudHJ5
DQo+ID4gPiA+ID4gaWYNCj4gPiA+ID4gPiBuZnNfc2FtZV9maWxlKCkgcmV0dXJucyBmYWxzZS4g
bmZzX3NhbWVfZmlsZSgpIGRvZXMgc2VlbSB0bw0KPiA+ID4gPiA+IHJldHVybg0KPiA+ID4gPiA+
IGZhbHNlIHdpdGggdGhlIGZvbGxvd2luZyBjaGFuZ2UsIGlmIEkgcmVhZCBpdCBjb3JyZWN0bHks
IGlmDQo+ID4gPiA+ID4gdGhlcmUNCj4gPiA+ID4gPiBpcyBhDQo+ID4gPiA+ID4gZmlsZSBoYW5k
bGUgY2hhbmdlLiBDYW4gdGhpcyBiZSB0aGUgc291cmNlIG9mIG15IGlzc3VlPyBJdA0KPiA+ID4g
PiA+IHNlZW1zDQo+ID4gPiA+ID4gdGhhdA0KPiA+ID4gPiA+IHRoZSBjbGllbnQgc2hvdWxkIGRv
IHRoaXMgb25seSBpZiB0aGUgZmlsZSBoYW5kbGUgaXMgTk9UDQo+ID4gPiA+ID4gdmFsaWQNCj4g
PiA+ID4gPiAoZS5nLg0KPiA+ID4gPiA+IGlmIGl0IGdldHMgRVNUQUxFKSwgcmlnaHQ/DQo+ID4g
PiA+ID4gDQo+ID4gPiA+ID4gVGhlIGZvbGxvd2luZyBjb21taXQgc2VlbXMgdG8gYXNzdW1lIHRo
YXQgdGhlIG9iamVjdHMgYXJlDQo+ID4gPiA+ID4gZGlmZmVyZW50IGlmDQo+ID4gPiA+ID4gdGhl
eSBoYXZlIGRpZmZlcmVudCBmaWxlIGhhbmRsZXMhDQo+ID4gPiA+ID4gY29tbWl0IDdkYzcyZDVm
N2EwZWM5N2E1M2UxMjZjNDZlMmNiZDI1NjA3NTc5NTUNCj4gPiA+ID4gPiBBdXRob3I6IFRyb25k
IE15a2xlYnVzdCA8dHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbT4NCj4gPiA+ID4gPiBE
YXRlOiAgIFRodSBTZXAgMjIgMTM6Mzg6NTIgMjAxNiAtMDQwMA0KPiA+ID4gPiA+IA0KPiA+ID4g
PiA+ICAgICBORlM6IEZpeCBpbm9kZSBjb3JydXB0aW9uIGluIG5mc19wcmltZV9kY2FjaGUoKQ0K
PiA+ID4gPiANCj4gPiA+ID4gTXkgdW5kZXJzdGFuZGluZyBpcyB0aGF0IGZvciBORlN2MyB3ZSBo
YXZlIHRvIGFzc3VtZSB0aGF0DQo+ID4gPiA+IGRpc3RpbmN0DQo+ID4gPiA+IGZpbGVoYW5kbGVz
IGFyZSBkaXN0aW5jdCBvYmplY3RzLCBidXQgbWF5YmUgSSdtIHdyb25nIGFib3V0DQo+ID4gPiA+
IHRoaXMuDQo+ID4gPiA+IA0KPiA+ID4gPiBGb3IgTkZTdjQueCwgd2UgY2FuIGZvbGxvdyB0aGUg
Z3VpZGFuY2UgaW4gUkZDcyA1NjYxIG9yIDc1MzANCj4gPiA+ID4gc2VjdGlvbiAxMC4zLjQNCj4g
PiA+ID4gdG8gZGV0ZXJtaW5lIGlmIHRoZSBkaWZmZXJpbmcgZmlsZWhhbmRsZXMgYXJlIHRoZSBz
YW1lIG9iamVjdCwNCj4gPiA+ID4gc3BlY2lmaWNhbGx5DQo+ID4gPiA+IHRoZSBmaWxlaWQgcmVj
b21tZW5kZWQgYXR0cmlidXRlIG5lZWRzIHRvIGJlIGltcGxlbWVudGVkLiAgSXMNCj4gPiA+ID4g
R2FuZXNoYQ0KPiA+ID4gPiByZXR1cm5pbmcgdGhlIHNhbWUgZmlsZWlkIGZvciBib3RoIGZpbGVo
YW5kbGVzPw0KPiA+ID4gPiANCj4gPiA+ID4gQmVuDQo+ID4gLS0NCj4gPiBUcm9uZCBNeWtsZWJ1
c3QNCj4gPiBDVE8sIEhhbW1lcnNwYWNlIEluYw0KPiA+IDQzMDAgRWwgQ2FtaW5vIFJlYWwsIFN1
aXRlIDEwNQ0KPiA+IExvcyBBbHRvcywgQ0EgOTQwMjINCj4gPiB3d3cuaGFtbWVyLnNwYWNlDQo+
ID4gDQo+ID4gDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFp
bmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
