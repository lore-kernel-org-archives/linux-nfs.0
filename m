Return-Path: <SRS0=fIcc=S6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 252FAC43218
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Apr 2019 15:06:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D0A6C206A3
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Apr 2019 15:06:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Vs/Sgj41"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726374AbfD1PGU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 28 Apr 2019 11:06:20 -0400
Received: from mail-eopbgr720139.outbound.protection.outlook.com ([40.107.72.139]:6171
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726741AbfD1PGT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 28 Apr 2019 11:06:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nUvZ4Wcpe0l9ur/LMZEcPtGF2X6JFoMEKm6F7L4YaAI=;
 b=Vs/Sgj41sSvsocA5Zw2IA3lsqMF1pOZ/gMyp2NWkpcWRYZ0HbBkXhIAS9gJivR1C3wd0BfpqFbdc0WmhkNKNsb1zxdBBWJH/akxy2EbQDsNpZW9ZU+mcOShA+5iNHkMlBqAY68YD5IwSu0IwFBAVOOD2SRN+hZZWJNkjptDhHJY=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2367.namprd13.prod.outlook.com (52.135.94.147) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.6; Sun, 28 Apr 2019 15:06:14 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::396d:aed6:eeb4:2511]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::396d:aed6:eeb4:2511%7]) with mapi id 15.20.1856.008; Sun, 28 Apr 2019
 15:06:14 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "jlayton@kernel.org" <jlayton@kernel.org>,
        "amir73il@gmail.com" <amir73il@gmail.com>
CC:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Volker.Lendecke@sernet.de" <Volker.Lendecke@sernet.de>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "pshilov@microsoft.com" <pshilov@microsoft.com>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
Thread-Topic: Better interop for NFS/SMB file share mode/reservation
Thread-Index: AQHUv6BUED9wy3m1tE24F/mnamgiLqXV4DAAgAAaggCAABW6AIB63KrUgAEKN4CAABrTAIAAFnQA
Date:   Sun, 28 Apr 2019 15:06:13 +0000
Message-ID: <1d5265510116ece75d6eb7af6314e6709e551c6e.camel@hammerspace.com>
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
         <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
         <CAOQ4uxgewN=j3ju5MSowEvwhK1HqKG3n1hBRUQTi1W5asaO1dQ@mail.gmail.com>
         <930108f76b89c93b2f1847003d9e060f09ba1a17.camel@kernel.org>
         <CAOQ4uxgQsRaEOxz1aYzP1_1fzRpQbOm2-wuzG=ABAphPB=7Mxg@mail.gmail.com>
         <20190426140023.GB25827@fieldses.org>
         <CAOQ4uxhuxoEsoBbvenJ8eLGstPc4AH-msrxDC-tBFRhvDxRSNg@mail.gmail.com>
         <20190426145006.GD25827@fieldses.org>
         <e69d149c80187b84833fec369ad8a51247871f26.camel@kernel.org>
         <CAOQ4uxjt+MkufaJWoqWSYZbejWa1nJEe8YYRroEBSb1jHjzkwQ@mail.gmail.com>
         <8504a05f2b0462986b3a323aec83a5b97aae0a03.camel@kernel.org>
         <CAOQ4uxi6fQdp_RQKHp-i6Q-m-G1+384_DafF3QzYcUq4guLd6w@mail.gmail.com>
In-Reply-To: <CAOQ4uxi6fQdp_RQKHp-i6Q-m-G1+384_DafF3QzYcUq4guLd6w@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 601cc55e-cfe5-43ce-029d-08d6cbeb0eaa
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2367;
x-ms-traffictypediagnostic: SN6PR13MB2367:
x-microsoft-antispam-prvs: <SN6PR13MB2367166092EBAA7CB1045268B8380@SN6PR13MB2367.namprd13.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:5516;
x-forefront-prvs: 0021920B5A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(136003)(346002)(376002)(366004)(396003)(199004)(189003)(53546011)(25786009)(64756008)(66476007)(66556008)(478600001)(66446008)(86362001)(91956017)(2906002)(102836004)(71200400001)(97736004)(8676002)(36756003)(5660300002)(71190400001)(93886005)(6506007)(256004)(3846002)(76116006)(66946007)(4326008)(6116002)(14444005)(73956011)(14454004)(54906003)(229853002)(6246003)(81166006)(81156014)(316002)(99286004)(8936002)(6486002)(76176011)(6436002)(110136005)(186003)(476003)(2616005)(7736002)(305945005)(11346002)(486006)(53936002)(561944003)(68736007)(6512007)(26005)(118296001)(446003)(2501003)(66066001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2367;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: RubVM6gnwXPMunA7SZOz1pbLU8zgIdFkO5SE5ElShqJN4KauWpHt9bMq9k0Ty9b7OfHNl99CN/Q/pWiA4fKDaVqMRMs02Nzx9UT8H7VcxPJckACp36sP5ZiGJH4wQbAw07ERelA2x2CtmqoecrO5925Lj9mMw2b24buq1tEtAu3ri4r6UE2/MUxvRHaH3XsDI8dUSJiaS1ur+SUWv3DKSUoWkCa03odwRh8ADP55xPIFmE1XALxGYIob3exdtxy5rIG78j9kJdtjz/HLIUw2EE9d0yEEznKKB3G0Je3mRpb5qXU7wh37v60WMO9of0kQ6urVhbp8E9l9jxytT+P0VLrcvbEtb9VAx4+xFzDWVDYqiw9BBByzMVsPiiTbGshgYPCSKR5CXg+nC9j4NSXwzrK7dDdg9kr7c3xAe/PhIdk=
Content-Type: text/plain; charset="utf-8"
Content-ID: <FD77D35C01F5A449A58CCF6BFE0C9C2C@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 601cc55e-cfe5-43ce-029d-08d6cbeb0eaa
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Apr 2019 15:06:14.0441
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2367
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gU3VuLCAyMDE5LTA0LTI4IGF0IDA5OjQ1IC0wNDAwLCBBbWlyIEdvbGRzdGVpbiB3cm90ZToN
Cj4gT24gU3VuLCBBcHIgMjgsIDIwMTkgYXQgODowOSBBTSBKZWZmIExheXRvbiA8amxheXRvbkBr
ZXJuZWwub3JnPg0KPiB3cm90ZToNCj4gPiBPbiBTYXQsIDIwMTktMDQtMjcgYXQgMTY6MTYgLTA0
MDAsIEFtaXIgR29sZHN0ZWluIHdyb3RlOg0KPiA+ID4gW2FkZGluZyBiYWNrIHNhbWJhL25mcyBh
bmQgZnNkZXZlbF0NCj4gPiA+IA0KPiA+IA0KPiA+IGNjJ2luZyBQYXZlbCB0b28gLS0gaGUgZGlk
IGEgYnVuY2ggb2Ygd29yayBpbiB0aGlzIGFyZWEgYSBmZXcgeWVhcnMNCj4gPiBhZ28uDQo+ID4g
DQo+ID4gPiBPbiBGcmksIEFwciAyNiwgMjAxOSBhdCA2OjIyIFBNIEplZmYgTGF5dG9uIDxqbGF5
dG9uQGtlcm5lbC5vcmc+DQo+ID4gPiB3cm90ZToNCj4gPiA+ID4gT24gRnJpLCAyMDE5LTA0LTI2
IGF0IDEwOjUwIC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6DQo+ID4gPiA+ID4gT24gRnJp
LCBBcHIgMjYsIDIwMTkgYXQgMDQ6MTE6MDBQTSArMDIwMCwgQW1pciBHb2xkc3RlaW4NCj4gPiA+
ID4gPiB3cm90ZToNCj4gPiA+ID4gPiA+IE9uIEZyaSwgQXByIDI2LCAyMDE5LCA0OjAwIFBNIEou
IEJydWNlIEZpZWxkcyA8DQo+ID4gPiA+ID4gPiBiZmllbGRzQGZpZWxkc2VzLm9yZz4gd3JvdGU6
DQo+ID4gPiA+ID4gPiANCj4gPiA+ID4gVGhhdCBzYWlkLCB3ZSBjb3VsZCBhbHNvIGxvb2sgYXQg
YSB2ZnMtbGV2ZWwgbW91bnQgb3B0aW9uIHRoYXQNCj4gPiA+ID4gd291bGQNCj4gPiA+ID4gbWFr
ZSB0aGUga2VybmVsIGVuZm9yY2UgdGhlc2UgZm9yIGFueSBvcGVuZXIuIFRoYXQgY291bGQgYWxz
bw0KPiA+ID4gPiBiZSB1c2VmdWwsDQo+ID4gPiA+IGFuZCBzaG91bGRuJ3QgYmUgdG9vIGhhcmQg
dG8gaW1wbGVtZW50LiBNYXliZSBldmVuIG1ha2UgaXQgYQ0KPiA+ID4gPiB2ZnNtb3VudC0NCj4g
PiA+ID4gbGV2ZWwgb3B0aW9uIChsaWtlIC1vIHJvIGlzKS4NCj4gPiA+ID4gDQo+ID4gPiANCj4g
PiA+IFllaCwgSSBhbSBodW1ibHkgZ29pbmcgdG8gbGVhdmUgdGhpcyBzdHJ1Z2dsZSB0byBzb21l
b25lIGVsc2UuDQo+ID4gPiBOb3QgaW1wb3J0YW50IGVub3VnaCBJTU8gYW5kIGNvbXBsZXRlbHkg
aW5kZXBlbmRlbnQgZWZmb3J0IHRvIHRoZQ0KPiA+ID4gYWR2aXNvcnkgYXRvbWljIG9wZW4mbG9j
ayBBUEkuDQo+ID4gDQo+ID4gSGF2aW5nIHRoZSBrZXJuZWwgYWxsb3cgc2V0dGluZyBkZW55IG1v
ZGVzIG9uIGFueSBvcGVuIGNhbGwgaXMgYQ0KPiA+IG5vbi0NCj4gPiBzdGFydGVyLCBmb3IgdGhl
IHJlYXNvbnMgQnJ1Y2Ugb3V0bGluZWQgZWFybGllci4gVGhpcyBfbXVzdF8gYmUNCj4gPiByZXN0
cmljdGVkIGluIHNvbWUgZmFzaGlvbiBvciB3ZSdsbCBiZSBvcGVuaW5nIHVwIGEgZ2lub3Jtb3Vz
IERvUw0KPiA+IG1lY2hhbmlzbS4NCj4gPiANCj4gPiBNeSBwcm9wb3NhbCB3YXMgdG8gbWFrZSB0
aGlzIG9ubHkgYmUgZW5mb3JjZWQgYnkgYXBwbGljYXRpb25zIHRoYXQNCj4gPiBleHBsaWNpdGx5
IG9wdC1pbiBieSBzZXR0aW5nIE9fU0gqL09fRVgqIGZsYWdzLiBJdCB3b3VsZG4ndCBiZSB0b28N
Cj4gPiBkaWZmaWN1bHQgdG8gYWxzbyBhbGxvdyB0aGVtIHRvIGJlIGVuZm9yY2VkIG9uIGEgcGVy
LWZzIGJhc2lzIHZpYQ0KPiA+IG1vdW50DQo+ID4gb3B0aW9uIG9yIHNvbWV0aGluZy4gTWF5YmUg
d2UgY291bGQgZXhwYW5kIHRoZSBtZWFuaW5nIG9mICctbyBtYW5kJw0KPiA+ID8NCj4gPiANCj4g
PiBIb3cgd291bGQgeW91IHByb3Bvc2UgdGhhdCB3ZSByZXN0cmljdCB0aGlzPw0KPiA+IA0KPiAN
Cj4gT3VyIGNvbW11bmljYXRpb24gY2hhbm5lbCBpcyBicm9rZW4uDQo+IEkgZGlkIG5vdCBpbnRl
bmQgdG8gcHJvcG9zZSBhbnkgaW1wbGljaXQgbG9ja2luZy4NCj4gSWYgc2FtYmEgYW5kIG5mc2Qg
Y2FuIG9wdC1pbiB3aXRoIE9fU0hBUkUgZmxhZ3MsIEkgZG8gbm90DQo+IHVuZGVyc3RhbmQgd2h5
IGEgbW91bnQgb3B0aW9uIGlzIGhlbHBmdWwgZm9yIHRoZSBjYXVzZSBvZg0KPiBzYW1iYS9uZnNk
IGludGVyb3AuDQo+IA0KPiBJZiBzb21lb25lIGVsc2UgaXMgaW50ZXJlc3RlZCBpbiBzYW1iYS9s
b2NhbCBpbnRlcm9wIHRoYW4NCj4geWVzLCBhIG1vdW50IG9wdGlvbiBsaWtlIHN1Z2dlc3RlZCBi
eSBQYXZlbCBjb3VsZCBiZSBhIGdvb2Qgb3B0aW9uLA0KPiBidXQgaXQgaXMgYW4gb3J0aG9nb25h
bCBlZmZvcnQgSU1PLg0KDQpJZiBhbiBORlMgY2xpZW50ICdvcHRzIGluJyB0byBzZXQgc2hhcmUg
ZGVueSwgdGhlbiB0aGF0IHN0aWxsIG1ha2VzIGl0DQphIG5vbi1vcHRpb25hbCBsb2NrIGZvciB0
aGUgb3RoZXIgTkZTIGNsaWVudHMsIGJlY2F1c2UgYWxsIG9yZGluYXJ5DQpvcGVuKCkgY2FsbHMg
d2lsbCBiZSBnYXRlZCBieSB0aGUgc2VydmVyIHdoZXRoZXIgb3Igbm90IHRoZWlyDQphcHBsaWNh
dGlvbiBzcGVjaWZpZXMgdGhlIE9fU0hBUkUgZmxhZy4gVGhlcmUgaXMgbm8gZmxhZyBpbiB0aGUg
TkZTDQpwcm90b2NvbCB0aGF0IGNvdWxkIHRlbGwgdGhlIHNlcnZlciB0byBpZ25vcmUgZGVueSBt
b2Rlcy4NCg0KSU9XOiBpdCB3b3VsZCBzdWZmaWNlIGZvciAxIGNsaWVudCB0byB1c2UgT19TSEFS
RXxPX0RFTlkqIHRvIG9wdCBhbGwNCnRoZSBvdGhlciBjbGllbnRzIGluLg0KDQotLSANClRyb25k
IE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJv
bmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
