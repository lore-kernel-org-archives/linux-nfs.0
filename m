Return-Path: <SRS0=fIcc=S6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B41D9C43218
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Apr 2019 22:08:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6047220675
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Apr 2019 22:08:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="KxzaTvI+"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726443AbfD1WIy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 28 Apr 2019 18:08:54 -0400
Received: from mail-eopbgr790124.outbound.protection.outlook.com ([40.107.79.124]:26558
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726393AbfD1WIy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 28 Apr 2019 18:08:54 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=8ugMPQQ3ol5bWEovDAg8mehDOCQMNjdeGWsTUMo+kQQ=;
 b=KxzaTvI+ol3EH0xEX58c3wCImkd1mwdnyeBpVDfKY0IUjaZ9zLR+CpGR7YY3QEujHmi8nLfm6iUqn56iH9e2yqxkBvyfHa7tb3J3F6qcVMrnaXo9ZTNuU2xmisDWco40FcjQbtqzVok308NUookjQUxKQ/TyNfz70MQm72KYzHA=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2366.namprd13.prod.outlook.com (52.135.94.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.5; Sun, 28 Apr 2019 22:08:48 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::396d:aed6:eeb4:2511]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::396d:aed6:eeb4:2511%7]) with mapi id 15.20.1856.008; Sun, 28 Apr 2019
 22:08:48 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "amir73il@gmail.com" <amir73il@gmail.com>
CC:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "Volker.Lendecke@sernet.de" <Volker.Lendecke@sernet.de>,
        "pshilov@microsoft.com" <pshilov@microsoft.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
Thread-Topic: Better interop for NFS/SMB file share mode/reservation
Thread-Index: AQHUv6BUED9wy3m1tE24F/mnamgiLqXV4DAAgAAaggCAABW6AIB63KrUgAEKN4CAABrTAIAAFnQAgABzxACAAAJMgA==
Date:   Sun, 28 Apr 2019 22:08:47 +0000
Message-ID: <95bc6ace0f46a1b1a38de9b536ce74faaa460182.camel@hammerspace.com>
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
         <1d5265510116ece75d6eb7af6314e6709e551c6e.camel@hammerspace.com>
         <CAOQ4uxjUBRt99efZMY8EV6SAH+9eyf6t82uQuKWHQ56yjpjqMw@mail.gmail.com>
In-Reply-To: <CAOQ4uxjUBRt99efZMY8EV6SAH+9eyf6t82uQuKWHQ56yjpjqMw@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1a876c16-d0db-472c-382b-08d6cc2616f7
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2366;
x-ms-traffictypediagnostic: SN6PR13MB2366:
x-microsoft-antispam-prvs: <SN6PR13MB23664087A68B658EF9EE018BB8380@SN6PR13MB2366.namprd13.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:7691;
x-forefront-prvs: 0021920B5A
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(376002)(346002)(39830400003)(136003)(396003)(199004)(189003)(26005)(486006)(53546011)(6506007)(6512007)(6246003)(25786009)(14454004)(476003)(53936002)(71190400001)(71200400001)(102836004)(561944003)(118296001)(186003)(1411001)(2906002)(4326008)(6916009)(229853002)(2501003)(2351001)(36756003)(91956017)(76116006)(64756008)(66446008)(66556008)(305945005)(66946007)(93886005)(5660300002)(68736007)(99286004)(7736002)(3846002)(6116002)(8676002)(81156014)(81166006)(97736004)(8936002)(6436002)(11346002)(66066001)(2616005)(478600001)(6486002)(14444005)(256004)(446003)(86362001)(316002)(1361003)(54906003)(5640700003)(66476007)(73956011)(76176011);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2366;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: f+a8FiT+uZr/V7tnk2GHh+C8VSLmLTYqV6pP7HmjDVhg75JjvSw64aa+G4btvMC9q/XC7Mv1+wqNR8KFEKqtAkTA/qL6700WjozPdlakbkmIuO38q4yzunCwl4JZZyqYByYELYeQj6w1CFxwe3w6ilPb6gGslSkbouTsrWJy/XHiMKOK5RieuQ3ACjCltIUwffNm6CtMeeqGYK0xqxGg89NIi354Gg1IV4XAS8Njvb26FIIF8+agD2EpiaM43u7qMI6yXcvdaAcf+4X6ECnzfjyLJBLTuPZTIBWdLCaEwSLl8xM29Th76raMvrNsGbu+f8GgUoDdhIvqCG8wjdOHVF/VjjD4usHgD/II8vBtpEGy3HGJOEnHMirs3bfbvN5Jyslufq7Nae9fHZvgwA43bOQIherJmooFmkV+vp3Gric=
Content-Type: text/plain; charset="utf-8"
Content-ID: <5D96BFB66042EC4D8011EE48AC6C6BA3@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1a876c16-d0db-472c-382b-08d6cc2616f7
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Apr 2019 22:08:48.3429
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2366
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gU3VuLCAyMDE5LTA0LTI4IGF0IDE4OjAwIC0wNDAwLCBBbWlyIEdvbGRzdGVpbiB3cm90ZToN
Cj4gT24gU3VuLCBBcHIgMjgsIDIwMTkgYXQgMTE6MDYgQU0gVHJvbmQgTXlrbGVidXN0DQo+IDx0
cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gT24gU3VuLCAyMDE5LTA0LTI4IGF0
IDA5OjQ1IC0wNDAwLCBBbWlyIEdvbGRzdGVpbiB3cm90ZToNCj4gPiA+IE9uIFN1biwgQXByIDI4
LCAyMDE5IGF0IDg6MDkgQU0gSmVmZiBMYXl0b24gPGpsYXl0b25Aa2VybmVsLm9yZz4NCj4gPiA+
IHdyb3RlOg0KPiA+ID4gPiBPbiBTYXQsIDIwMTktMDQtMjcgYXQgMTY6MTYgLTA0MDAsIEFtaXIg
R29sZHN0ZWluIHdyb3RlOg0KPiA+ID4gPiA+IFthZGRpbmcgYmFjayBzYW1iYS9uZnMgYW5kIGZz
ZGV2ZWxdDQo+ID4gPiA+ID4gDQo+ID4gPiA+IA0KPiA+ID4gPiBjYydpbmcgUGF2ZWwgdG9vIC0t
IGhlIGRpZCBhIGJ1bmNoIG9mIHdvcmsgaW4gdGhpcyBhcmVhIGEgZmV3DQo+ID4gPiA+IHllYXJz
DQo+ID4gPiA+IGFnby4NCj4gPiA+ID4gDQo+ID4gPiA+ID4gT24gRnJpLCBBcHIgMjYsIDIwMTkg
YXQgNjoyMiBQTSBKZWZmIExheXRvbiA8DQo+ID4gPiA+ID4gamxheXRvbkBrZXJuZWwub3JnPg0K
PiA+ID4gPiA+IHdyb3RlOg0KPiA+ID4gPiA+ID4gT24gRnJpLCAyMDE5LTA0LTI2IGF0IDEwOjUw
IC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6DQo+ID4gPiA+ID4gPiA+IE9uIEZyaSwgQXBy
IDI2LCAyMDE5IGF0IDA0OjExOjAwUE0gKzAyMDAsIEFtaXIgR29sZHN0ZWluDQo+ID4gPiA+ID4g
PiA+IHdyb3RlOg0KPiA+ID4gPiA+ID4gPiA+IE9uIEZyaSwgQXByIDI2LCAyMDE5LCA0OjAwIFBN
IEouIEJydWNlIEZpZWxkcyA8DQo+ID4gPiA+ID4gPiA+ID4gYmZpZWxkc0BmaWVsZHNlcy5vcmc+
IHdyb3RlOg0KPiA+ID4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gVGhhdCBzYWlkLCB3ZSBjb3Vs
ZCBhbHNvIGxvb2sgYXQgYSB2ZnMtbGV2ZWwgbW91bnQgb3B0aW9uDQo+ID4gPiA+ID4gPiB0aGF0
DQo+ID4gPiA+ID4gPiB3b3VsZA0KPiA+ID4gPiA+ID4gbWFrZSB0aGUga2VybmVsIGVuZm9yY2Ug
dGhlc2UgZm9yIGFueSBvcGVuZXIuIFRoYXQgY291bGQNCj4gPiA+ID4gPiA+IGFsc28NCj4gPiA+
ID4gPiA+IGJlIHVzZWZ1bCwNCj4gPiA+ID4gPiA+IGFuZCBzaG91bGRuJ3QgYmUgdG9vIGhhcmQg
dG8gaW1wbGVtZW50LiBNYXliZSBldmVuIG1ha2UgaXQNCj4gPiA+ID4gPiA+IGENCj4gPiA+ID4g
PiA+IHZmc21vdW50LQ0KPiA+ID4gPiA+ID4gbGV2ZWwgb3B0aW9uIChsaWtlIC1vIHJvIGlzKS4N
Cj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IFllaCwgSSBhbSBodW1ibHkgZ29p
bmcgdG8gbGVhdmUgdGhpcyBzdHJ1Z2dsZSB0byBzb21lb25lDQo+ID4gPiA+ID4gZWxzZS4NCj4g
PiA+ID4gPiBOb3QgaW1wb3J0YW50IGVub3VnaCBJTU8gYW5kIGNvbXBsZXRlbHkgaW5kZXBlbmRl
bnQgZWZmb3J0IHRvDQo+ID4gPiA+ID4gdGhlDQo+ID4gPiA+ID4gYWR2aXNvcnkgYXRvbWljIG9w
ZW4mbG9jayBBUEkuDQo+ID4gPiA+IA0KPiA+ID4gPiBIYXZpbmcgdGhlIGtlcm5lbCBhbGxvdyBz
ZXR0aW5nIGRlbnkgbW9kZXMgb24gYW55IG9wZW4gY2FsbCBpcw0KPiA+ID4gPiBhDQo+ID4gPiA+
IG5vbi0NCj4gPiA+ID4gc3RhcnRlciwgZm9yIHRoZSByZWFzb25zIEJydWNlIG91dGxpbmVkIGVh
cmxpZXIuIFRoaXMgX211c3RfIGJlDQo+ID4gPiA+IHJlc3RyaWN0ZWQgaW4gc29tZSBmYXNoaW9u
IG9yIHdlJ2xsIGJlIG9wZW5pbmcgdXAgYSBnaW5vcm1vdXMNCj4gPiA+ID4gRG9TDQo+ID4gPiA+
IG1lY2hhbmlzbS4NCj4gPiA+ID4gDQo+ID4gPiA+IE15IHByb3Bvc2FsIHdhcyB0byBtYWtlIHRo
aXMgb25seSBiZSBlbmZvcmNlZCBieSBhcHBsaWNhdGlvbnMNCj4gPiA+ID4gdGhhdA0KPiA+ID4g
PiBleHBsaWNpdGx5IG9wdC1pbiBieSBzZXR0aW5nIE9fU0gqL09fRVgqIGZsYWdzLiBJdCB3b3Vs
ZG4ndCBiZQ0KPiA+ID4gPiB0b28NCj4gPiA+ID4gZGlmZmljdWx0IHRvIGFsc28gYWxsb3cgdGhl
bSB0byBiZSBlbmZvcmNlZCBvbiBhIHBlci1mcyBiYXNpcw0KPiA+ID4gPiB2aWENCj4gPiA+ID4g
bW91bnQNCj4gPiA+ID4gb3B0aW9uIG9yIHNvbWV0aGluZy4gTWF5YmUgd2UgY291bGQgZXhwYW5k
IHRoZSBtZWFuaW5nIG9mICctbw0KPiA+ID4gPiBtYW5kJw0KPiA+ID4gPiA/DQo+ID4gPiA+IA0K
PiA+ID4gPiBIb3cgd291bGQgeW91IHByb3Bvc2UgdGhhdCB3ZSByZXN0cmljdCB0aGlzPw0KPiA+
ID4gPiANCj4gPiA+IA0KPiA+ID4gT3VyIGNvbW11bmljYXRpb24gY2hhbm5lbCBpcyBicm9rZW4u
DQo+ID4gPiBJIGRpZCBub3QgaW50ZW5kIHRvIHByb3Bvc2UgYW55IGltcGxpY2l0IGxvY2tpbmcu
DQo+ID4gPiBJZiBzYW1iYSBhbmQgbmZzZCBjYW4gb3B0LWluIHdpdGggT19TSEFSRSBmbGFncywg
SSBkbyBub3QNCj4gPiA+IHVuZGVyc3RhbmQgd2h5IGEgbW91bnQgb3B0aW9uIGlzIGhlbHBmdWwg
Zm9yIHRoZSBjYXVzZSBvZg0KPiA+ID4gc2FtYmEvbmZzZCBpbnRlcm9wLg0KPiA+ID4gDQo+ID4g
PiBJZiBzb21lb25lIGVsc2UgaXMgaW50ZXJlc3RlZCBpbiBzYW1iYS9sb2NhbCBpbnRlcm9wIHRo
YW4NCj4gPiA+IHllcywgYSBtb3VudCBvcHRpb24gbGlrZSBzdWdnZXN0ZWQgYnkgUGF2ZWwgY291
bGQgYmUgYSBnb29kDQo+ID4gPiBvcHRpb24sDQo+ID4gPiBidXQgaXQgaXMgYW4gb3J0aG9nb25h
bCBlZmZvcnQgSU1PLg0KPiA+IA0KPiA+IElmIGFuIE5GUyBjbGllbnQgJ29wdHMgaW4nIHRvIHNl
dCBzaGFyZSBkZW55LCB0aGVuIHRoYXQgc3RpbGwgbWFrZXMNCj4gPiBpdA0KPiA+IGEgbm9uLW9w
dGlvbmFsIGxvY2sgZm9yIHRoZSBvdGhlciBORlMgY2xpZW50cywgYmVjYXVzZSBhbGwgb3JkaW5h
cnkNCj4gPiBvcGVuKCkgY2FsbHMgd2lsbCBiZSBnYXRlZCBieSB0aGUgc2VydmVyIHdoZXRoZXIg
b3Igbm90IHRoZWlyDQo+ID4gYXBwbGljYXRpb24gc3BlY2lmaWVzIHRoZSBPX1NIQVJFIGZsYWcu
IFRoZXJlIGlzIG5vIGZsYWcgaW4gdGhlIE5GUw0KPiA+IHByb3RvY29sIHRoYXQgY291bGQgdGVs
bCB0aGUgc2VydmVyIHRvIGlnbm9yZSBkZW55IG1vZGVzLg0KPiA+IA0KPiA+IElPVzogaXQgd291
bGQgc3VmZmljZSBmb3IgMSBjbGllbnQgdG8gdXNlIE9fU0hBUkV8T19ERU5ZKiB0byBvcHQNCj4g
PiBhbGwNCj4gPiB0aGUgb3RoZXIgY2xpZW50cyBpbi4NCj4gPiANCj4gDQo+IFNvcnJ5IGZvciBi
ZWluZyB0aGljaywgSSBkb24ndCB1bmRlcnN0YW5kIGlmIHdlIGFyZSBpbiBhZ3JlZW1lbnQgb3IN
Cj4gbm90Lg0KPiANCj4gTXkgdW5kZXJzdGFuZGluZyBpcyB0aGF0IHRoZSBuZXR3b3JrIGZpbGUg
c2VydmVyIGltcGxlbWVudGF0aW9ucw0KPiAoaS5lLiBzYW1iYSwga25mZHMsIEdhbmVzaGEpIHdp
bGwgYWx3YXlzIHVzZSBzaGFyZS9kZW55IG1vZGVzLg0KPiBTbyBmb3IgZXhhbXBsZSBuZnMgdjMg
b3BlbnMgd2lsbCBhbHdheXMgdXNlIE9fREVOWV9OT05FDQo+IGluIG9yZGVyIHRvIGhhdmUgY29y
cmVjdCBpbnRlcm9wIHdpdGggc2FtYmEgYW5kIG5mcyB2NC4NCj4gDQo+IElmIEkgYW0gbWlzdW5k
ZXJzdGFuZGluZyBzb21ldGhpbmcsIHBsZWFzZSBlbmxpZ2h0ZW4gbWUuDQo+IElmIHRoZXJlIGlz
IGEgcmVhc29uIHdoeSBtb3VudCBvcHRpb24gaXMgbmVlZGVkIGZvciB0aGUgc29sZSBwdXJwb3Nl
DQo+IG9mIGludGVyb3AgYmV0d2VlbiBuZXR3b3JrIGZpbGVzeXN0ZW0gc2VydmVycywgcGxlYXNl
IGVubGlnaHRlbiBtZS4NCj4gDQo+IA0KDQpTYW1lIGRpZmZlcmVuY2UuIEFzIGxvbmcgYXMgbmZz
ZCBhbmQvb3IgR2FuZXNoYSBhcmUgdHJhbnNsYXRpbmcNCk9QRU40X1NIQVJFX0FDQ0VTU19SRUFE
IGFuZCBPUEVONF9TSEFSRV9BQ0NFU1NfV1JJVEUgaW50byBzaGFyZSBhY2Nlc3MNCmxvY2tzLCB0
aGVuIHRob3NlIHdpbGwgY29uZmxpY3Qgd2l0aCBhbnkgZGVueSBsb2NrcyBzZXQgYnkgd2hhdGV2
ZXINCmFwcGxpY2F0aW9uIHRoYXQgdXNlcyB0aGVtLg0KDQpJT1c6IGFueSBvcGVuKE9fUkRPTkxZ
KSBhbmQgb3BlbihPX1JEV1IpIHdpbGwgY29uZmxpY3Qgd2l0aCBhbg0KT19ERU5ZX1JFQUQgdGhh
dCBpcyBzZXQgb24gdGhlIHNlcnZlciwgYW5kIGFueSBvcGVuKE9fV1JPTkxZKSBhbmQNCm9wZW4o
T19SRFdSKSB3aWxsIGNvbmZsaWN0IHdpdGggYW4gT19ERU5ZX1dSSVRFIHRoYXQgaXMgc2V0IG9u
IHRoZQ0Kc2VydmVyLiBUaGVyZSBpcyBubyBvcHQtb3V0IGZvciBORlMgY2xpZW50cyBvbiB0aGlz
IGlzc3VlLCBiZWNhdXNlDQpzdGF0ZWZ1bCBORlN2NCBvcGVucyBNVVNUIHNldCBvbmUgb3IgbW9y
ZSBvZiBPUEVONF9TSEFSRV9BQ0NFU1NfUkVBRA0KYW5kIE9QRU40X1NIQVJFX0FDQ0VTU19XUklU
RS4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwg
SGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
