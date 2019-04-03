Return-Path: <SRS0=5sV6=SF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00952C4360F
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 22:10:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 972072084B
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 22:10:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="l8pojy0E"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726199AbfDCWKY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Apr 2019 18:10:24 -0400
Received: from mail-eopbgr700119.outbound.protection.outlook.com ([40.107.70.119]:35681
        "EHLO NAM04-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726167AbfDCWKY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Apr 2019 18:10:24 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=VQYuFi0o3lZsAELQOnf9YlIme7MC1blBKx7DDCzjSQw=;
 b=l8pojy0EjndzajlGYg/PXexTVdLl+BYZ+kqCGd7bLUMD57tPSgTcb9jR2Q0ogxci+SO8mJR6m0uz/32xkvjQ3R1RZri0agBL3C5ZAWx2RYLNvKPg3OYPaN07L0Kz16i47Rm2Vb+HsRm7dRIGrIfx1ra5PU8HUqAxVXHVUULbAWc=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2511.namprd13.prod.outlook.com (52.135.95.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.6; Wed, 3 Apr 2019 22:10:19 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1771.007; Wed, 3 Apr 2019
 22:10:19 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "aglo@umich.edu" <aglo@umich.edu>
Subject: Re: [PATCH v2 00/28] Fix up soft mounts for NFSv4.x
Thread-Topic: [PATCH v2 00/28] Fix up soft mounts for NFSv4.x
Thread-Index: AQHU5nsJRwz03LQg+Ue1ZSadqsrG1KYnihuAgAGstgCAAbo8gIAABjAAjTosx17yxeMPgA==
Date:   Wed, 3 Apr 2019 22:10:19 +0000
Message-ID: <ed970580df945623ad3f72a60a28f2aa4e39ba2c.camel@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
         <CAN-5tyHGWp1o7v4bYCsEFxRJpBhH9Qg9ieGZYDjBVdmtua9KPA@mail.gmail.com>
         <1778bf6d42f956d0226fe05683b385654b4c0109.camel@gmail.com>
         <995086222.2639035.1554324687132.JavaMail.zimbra@desy.de>
         <ab9fed81bb7352541ad8c0bffddccfd376f1dd15.camel@hammerspace.com>
         <683965790.2648561.1554328759153.JavaMail.zimbra@desy.de>
In-Reply-To: <683965790.2648561.1554328759153.JavaMail.zimbra@desy.de>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [63.235.104.78]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 593ec51b-8800-41f0-722c-08d6b88128bd
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2511;
x-ms-traffictypediagnostic: SN6PR13MB2511:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB251128173BBBCB1B35BEC95FB8570@SN6PR13MB2511.namprd13.prod.outlook.com>
x-forefront-prvs: 0996D1900D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39830400003)(396003)(346002)(376002)(366004)(199004)(189003)(13464003)(478600001)(14454004)(99286004)(4326008)(6512007)(71190400001)(25786009)(76176011)(53546011)(6506007)(26005)(102836004)(97736004)(6116002)(5640700003)(53936002)(14444005)(3846002)(71200400001)(256004)(6246003)(5660300002)(2906002)(86362001)(2351001)(105586002)(106356001)(486006)(6916009)(118296001)(2501003)(68736007)(36756003)(6486002)(6436002)(229853002)(54906003)(93886005)(316002)(476003)(11346002)(446003)(2616005)(8676002)(8936002)(81156014)(81166006)(186003)(7736002)(66066001)(305945005)(15974865002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2511;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Z9AocmcwGtmINgGeRWt8O0axrqIDVheX5AHawgyh6yxYd8FPA0OpL675Nleg/7Cm/xLaG3PPbqdeirW1w/VDXBb3Scqx71Ksi7mgUKiobIc7iuICGwx4SVNwvC0/JCIAm03Cv1t3K0OVIpgkm3zoFcDD6vKUhRTjDyvzG9LYe+G6+qj1/+/s34c+funbu8JkD++tCCEsPsdR2iZY+ez9ZRdiOct2E0uje4K9Dzjld2xJxthBiKnZJpAinEZ/i9kjBKDlb3W906+fOu2EogOkTi/p4AICETDVbtHuRa6oy9RxhXDutb8fKlNAGa9eQl8QlyIa7r/0P5xbWQ0tzi9r3nzV0iIjZUdnPV7RapX0ky/FuAPsra73ehsPj0RNFzSEqrUfD2meA+tKhhLA9Kj8xS5ETP9Y+lTnA2pnAZ6q9f8=
Content-Type: text/plain; charset="utf-8"
Content-ID: <CB71D04ECC8CC0429E71462CC4DDD5F2@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 593ec51b-8800-41f0-722c-08d6b88128bd
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Apr 2019 22:10:19.2019
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2511
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTA0LTAzIGF0IDIzOjU5ICswMjAwLCBNa3J0Y2h5YW4sIFRpZ3JhbiB3cm90
ZToNCj4gDQo+IC0tLS0tIE9yaWdpbmFsIE1lc3NhZ2UgLS0tLS0NCj4gPiBGcm9tOiAidHJvbmRt
eSIgPHRyb25kbXlAaGFtbWVyc3BhY2UuY29tPg0KPiA+IFRvOiAiVGlncmFuIE1rcnRjaHlhbiIg
PHRpZ3Jhbi5ta3J0Y2h5YW5AZGVzeS5kZT4NCj4gPiBDYzogImxpbnV4LW5mcyIgPGxpbnV4LW5m
c0B2Z2VyLmtlcm5lbC5vcmc+LCAiT2xnYSBLb3JuaWV2c2thaWEiIDwNCj4gPiBhZ2xvQHVtaWNo
LmVkdT4NCj4gPiBTZW50OiBXZWRuZXNkYXksIEFwcmlsIDMsIDIwMTkgMTE6MTM6MzcgUE0NCj4g
PiBTdWJqZWN0OiBSZTogW1BBVENIIHYyIDAwLzI4XSBGaXggdXAgc29mdCBtb3VudHMgZm9yIE5G
U3Y0LngNCj4gPiBPbiBXZWQsIDIwMTktMDQtMDMgYXQgMjI6NTEgKzAyMDAsIE1rcnRjaHlhbiwg
VGlncmFuIHdyb3RlOg0KPiA+ID4gSGkgVHJvbmQsDQo+ID4gPiANCj4gPiA+IC0tLS0tIE9yaWdp
bmFsIE1lc3NhZ2UgLS0tLS0NCj4gPiA+ID4gRnJvbTogIlRyb25kIE15a2xlYnVzdCIgPHRyb25k
bXlAZ21haWwuY29tPg0KPiA+ID4gPiBUbzogIk9sZ2EgS29ybmlldnNrYWlhIiA8YWdsb0B1bWlj
aC5lZHU+DQo+ID4gPiA+IENjOiAibGludXgtbmZzIiA8bGludXgtbmZzQHZnZXIua2VybmVsLm9y
Zz4NCj4gPiA+ID4gU2VudDogVHVlc2RheSwgQXByaWwgMiwgMjAxOSA4OjI4OjM4IFBNDQo+ID4g
PiA+IFN1YmplY3Q6IFJlOiBbUEFUQ0ggdjIgMDAvMjhdIEZpeCB1cCBzb2Z0IG1vdW50cyBmb3Ig
TkZTdjQueA0KPiA+ID4gPiBPbiBNb24sIDIwMTktMDQtMDEgYXQgMTI6NTQgLTA0MDAsIE9sZ2Eg
S29ybmlldnNrYWlhIHdyb3RlOg0KPiA+ID4gPiA+IE9uIEZyaSwgTWFyIDI5LCAyMDE5IGF0IDY6
MDIgUE0gVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+ID4gPiB0cm9uZG15QGdtYWlsLmNvbT4NCj4g
PiA+ID4gPiB3cm90ZToNCj4gPiA+ID4gPiA+IFRoaXMgcGF0Y2hzZXQgYWltcyB0byBtYWtlIHNv
ZnQgbW91bnRzIGEgdmlhYmxlIG9wdGlvbiBmb3INCj4gPiA+ID4gPiA+IE5GU3Y0DQo+ID4gPiA+
ID4gPiBjbGllbnRzDQo+ID4gPiA+ID4gPiBieSBtaW5pbWlzaW5nIHRoZSByaXNrIG9mIGZhbHNl
IHBvc2l0aXZlIHRpbWVvdXRzLCB3aGlsZQ0KPiA+ID4gPiA+ID4gYWxsb3dpbmcNCj4gPiA+ID4g
PiA+IGZvcg0KPiA+ID4gPiA+ID4gZmFzdGVyIGZhaWxvdmVyIG9mIHJlYWRzIGFuZCB3cml0ZXMg
b25jZSBhIHRpbWVvdXQgaXMNCj4gPiA+ID4gPiA+IGFjdHVhbGx5DQo+ID4gPiA+ID4gPiBvYnNl
cnZlZC4NCj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gVGhlIHBhdGNoZXMgcmVseSBvbiB0aGUg
TkZTIHNlcnZlciBjb3JyZWN0bHkgaW1wbGVtZW50aW5nDQo+ID4gPiA+ID4gPiB0aGUNCj4gPiA+
ID4gPiA+IGNvbnRyYWN0DQo+ID4gPiA+ID4gPiBzcGVjaWZpZWQgaW4gUkZDNzUzMCBzZWN0aW9u
IDMuMS4xIHdpdGggcmVzcGVjdCB0byBub3QNCj4gPiA+ID4gPiA+IGRyb3BwaW5nDQo+ID4gPiA+
ID4gPiByZXF1ZXN0cw0KPiA+ID4gPiA+ID4gd2hpbGUgdGhlIHRyYW5zcG9ydCBjb25uZWN0aW9u
IGlzIHVwLiBXaGVuIHRoaXMgaXMgdGhlDQo+ID4gPiA+ID4gPiBjYXNlLA0KPiA+ID4gPiA+ID4g
dGhlDQo+ID4gPiA+ID4gPiBjbGllbnQNCj4gPiA+ID4gPiA+IGNhbiBzYWZlbHkgYXNzdW1lIHRo
YXQgaWYgdGhlIHJlcXVlc3QgaGFzIG5vdCByZWNlaXZlZCBhDQo+ID4gPiA+ID4gPiByZXBseQ0K
PiA+ID4gPiA+ID4gYWZ0ZXINCj4gPiA+ID4gPiA+IHRyYW5zbWl0dGluZyBhIFJQQyByZXF1ZXN0
LCBpdCBpcyBub3QgYmVjYXVzZSB0aGUgcmVxdWVzdA0KPiA+ID4gPiA+ID4gd2FzDQo+ID4gPiA+
ID4gPiBkcm9wcGVkLA0KPiA+ID4gPiA+ID4gYnV0IHJhdGhlciBpcyBkdWUgdG8gY29uZ2VzdGlv
biwgb3Igc2xvdyBwcm9jZXNzaW5nIG9uIHRoZQ0KPiA+ID4gPiA+ID4gc2VydmVyLg0KPiA+ID4g
PiA+ID4gSU9XOiBhcyBsb25nIGFzIHRoZSBjb25uZWN0aW9uIHJlbWFpbnMgdXAsIHRoZXJlIGlz
IG5vIG5lZWQNCj4gPiA+ID4gPiA+IGZvcg0KPiA+ID4gPiA+ID4gcmVxdWVzdHMNCj4gPiA+ID4g
PiA+IHRvIHRpbWUgb3V0Lg0KPiA+ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiBUaGUgcGF0Y2hlcyBi
cmVhayBkb3duIHJvdWdobHkgYXMgZm9sbG93czoNCj4gPiA+ID4gPiA+IC0gQSBzZXQgb2YgcGF0
Y2hlcyB0byBjbGVhbiB1cCB0aGUgUlBDIGVuZ2luZSB0aW1lb3V0cywgYW5kDQo+ID4gPiA+ID4g
PiBlbnN1cmUNCj4gPiA+ID4gPiA+IHRoZXkNCj4gPiA+ID4gPiA+ICAgYXJlIGFjY3VyYXRlLg0K
PiA+ID4gPiA+ID4gLSBBIHNldCBvZiBwYXRjaGVzIHRvIGNoYW5nZSB0aGUgJ3NvZnQnIG1vdW50
IHNlbWFudGljcyBmb3INCj4gPiA+ID4gPiA+IE5GU3Y0LnguDQo+ID4gPiA+ID4gPiAtIEEgc2V0
IG9mIHBhdGNoZXMgdG8gYWRkIGEgbmV3ICdzb2Z0ZXJyJyBtb3VudCBvcHRpb24gdGhhdA0KPiA+
ID4gPiA+ID4gd29ya3MNCj4gPiA+ID4gPiA+IGxpa2UNCj4gPiA+ID4gPiA+ICAgc29mdCwgYnV0
IGV4cGxpY2l0bHkgc2lnbmFscyB0aW1lb3V0cyB1c2luZyB0aGUgRVRJTUVET1VUDQo+ID4gPiA+
ID4gPiBlcnJvcg0KPiA+ID4gPiA+ID4gY29kZQ0KPiA+ID4gPiA+ID4gICByYXRoZXIgdGhhbiB1
c2luZyBFSU8uIFRoaXMgYWxsb3dzIGFwcGxpY2F0aW9ucyB0byB0dW5lDQo+ID4gPiA+ID4gPiB0
aGVpcg0KPiA+ID4gPiA+ID4gICBiZWhhdmlvdXIgKGUuZy4gYnkgZmFpbGluZyBvdmVyIHRvIGEg
ZGlmZmVyZW50IHNlcnZlcikgaWYNCj4gPiA+ID4gPiA+IGENCj4gPiA+ID4gPiA+IHRpbWVvdXQN
Cj4gPiA+ID4gPiA+ICAgb2NjdXJzLg0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IEknbSBqdXN0IGN1
cmlvdXMgd2h5IHdvdWxkIGFuIGFwcGxpY2F0aW9uIGJlIGF3YXJlIG9mIGENCj4gPiA+ID4gPiBk
aWZmZXJlbnQNCj4gPiA+ID4gPiBzZXJ2ZXIgdG8gY29ubmVjdCB0byBhbmQgYW4gTkZTIGxheWVy
IHdvdWxkIG5vdCBiZT8gSSdtIGFsc28NCj4gPiA+ID4gPiBjdXJpb3VzDQo+ID4gPiA+ID4gd291
bGRuJ3QgaXQgYnJlYWsgYXBwbGljYXRpb24gdGhhdCB0eXBpY2FsbHkgZXhwZWN0IHRvIGdldCBh
bg0KPiA+ID4gPiA+IEVJTw0KPiA+ID4gPiA+IGVycm9ycz8gRG8gYWxsIHN5c3RlbSBjYWxscyBh
bGxvdyB0byByZXR1cm4gRVRJTUVET1VUIGVycm9yPw0KPiA+ID4gPiANCj4gPiA+ID4gVGhpcyBp
cyB3aHkgaXQgaXMgYSBzZXBhcmF0ZSBtb3VudCBvcHRpb24uIC4uLmFuZCBhY3R1YWxseSBtb3N0
DQo+ID4gPiA+IGFwcGxpY2F0aW9ucyBibG93IHVwIHdoZW4gdGhleSBnZXQgRUlPIGFzIHdlbGwu
IEhvd2V2ZXIgeW91IGNhbg0KPiA+ID4gPiBpbWFnaW5lDQo+ID4gPiA+IGFuIGFwcGxpY2F0aW9u
IHRoYXQgbWlnaHQgZGVjaWRlIHRvIHJldHJ5IGlmIGl0IGhpdHMgYW4NCj4gPiA+ID4gRVRJTUVE
T1VULA0KPiA+ID4gPiB3aGlsZSBmYWlsaW5nIGlmIGl0IGhpdHMgYW4gRUlPLg0KPiA+ID4gDQo+
ID4gPiBXaGF0IGlzIHRoZSByZWFzb24gb2YgaW50cm9kdWNpbmcgbmV3IGVycm9yIGNvZGUgZm9y
IElPDQo+ID4gPiBvcGVyYXRpb25zLA0KPiA+ID4gd2hpY2gNCj4gPiA+IGlzIG5vdCBpbiB0aGUg
bGlzdCBvZiBQT1NJWCBzcGVjaWZpZWQgdmFsdWVzIGZvciByZWFkKDIpIGFuZA0KPiA+ID4gd3Jp
dGUoMikuIElzDQo+ID4gPiB0aGVyZSBleHBlY3RlZCBhcHBsaWNhdGlvbiBiZWhhdmlvciBjaGFu
Z2UgY29tcGFyZWQgdG8gRUFHQUlOPw0KPiA+IA0KPiA+IFRoZSBwb2ludCBpcyB0byBhbGxvdyBh
d2FyZSBhcHBsaWNhdGlvbnMgdG8gYmV0dGVyIGhhbmRsZSBhDQo+ID4gc2l0dWF0aW9uDQo+ID4g
d2hpY2ggaXMgbm90IGNvdmVyZWQgYnkgUE9TSVggYmVjYXVzZSBQT1NJWCBoYXMgbm8gY29uY2Vw
dCBvZg0KPiA+IHN0b3JhZ2UNCj4gPiB0aGF0IGlzIHRlbXBvcmFyaWx5IHVuYXZhaWxhYmxlLg0K
PiA+IA0KPiA+IC4uLmFuZCBpdCBpcyBiZWluZyBwcm9wb3NlZCBhcyBhbiBvcHQtaW4gZmVhdHVy
ZSwgcHJlY2lzZWx5IHNvIHRoYXQNCj4gPiBleGlzdGluZyBhcHBsaWNhdGlvbnMgZG9uJ3QgbmVl
ZCB0byBjaGFuZ2UuDQo+IA0KPiBZZXMgYW5kIG5vLiBBcyBhIG1vdW50IG9wdGlvbiwgeW91IGV4
cG9zZSB0aGlzIGJlaGF2aW9yIHRvIGFsbA0KPiBhcHBsaWNhdGlvbnMNCj4gb24gdGhlIGNsaWVu
dC4gVGh1cywgZWl0aGVyIHN0dXBpZCBhcHAgZGllIGFuZCBzbWFydCBzdXJ2aXZlLCBvciBhbGwN
Cj4gYmxvY2ssIGJ1dCBzbWFydCBzdWZmZXIuDQoNCkkgZG9uJ3QgdW5kZXJzdGFuZCB5b3VyIHBv
aW50LiBUaGlzIGlzIGRvaW5nIHRoZSBleGFjdCBzYW1lIHRoaW5nIGFzDQonc29mdCcsIGJ1dCBi
ZWhhdmVzIGRpZmZlcmVudGx5IHdpdGggcmVzcGVjdCB0byB0aW1lb3V0cywgYnkgcmV0dXJuaW5n
DQpFVElNRURPVVQgaW5zdGVhZCBvZiBFSU8uDQoNCklPVzogaWYgeW91IHdhbnQgdGhlIHNhbWUg
YmVoYXZpb3VyLCBidXQgcmV0dXJuaW5nIGEgUE9TSVggZXJyb3Igb2YNCkVJTywgdGhlbiB0aGF0
IGJlaGF2aW91ciBpcyBhbHJlYWR5IHRoZXJlIHdpdGggInNvZnQiLg0KDQo+IEFzIHlvdSBwcm9i
YWJseSBrbm93LCB3ZSBoYXZlIHRvIGhhbmRsZSBzaW1pbGFyIGlzc3VlLiBDdXJyZW50bHkgaXQn
cw0KPiBhDQo+IHNlcnZlciBzaWRlIGNvbmZpZ3VyYXRpb24sIHdoaWNoIGRlcGVuZGluZyBvbiB1
aWQvZ2lkIG9mIHRoZSB1c2VyDQo+IHJldHVybnMNCj4gZWl0aGVyIE5GU0VSUl9JTyBvciBORlNF
UlJfTEFZT1VUVFJZTEFURVIuIFRoaXMgaXMgc3RpbGwgd3JvbmcsIGFzDQo+IG5vdCBhbGwNCj4g
YXBwbGljYXRpb25zIGZyb20gdGhlIHNhbWUgdXNlcnMgcmVxdWlyZWQgdGhlIHNhbWUgaGFuZGxp
bmcuDQoNCllvdSBoYXZlIG9wdGlvbnMgaGVyZSB0b28uDQoNCkNvbnRhaW5lcnMgb3IgVk1zIGFy
ZSBvbmUgb3B0aW9uIGZvciBjb21wbGV0ZWx5IGlzb2xhdGluZyBhcHBsaWNhdGlvbnMNCnRoYXQg
bmVlZCBzcGVjaWFsIGJlaGF2aW91cnMsIGFuZCBnaXZpbmcgdGhlbSB0aGVpciBvd24gc3BlY2lh
bCBtb3VudHMuDQoNCllvdSBjYW4gYWxzbyBpc29sYXRlIGJ5IHBhdGg6IG1vdW50aW5nIHdpdGgg
b25lIHNldCBvZiBvcHRpb25zIGluIG9uZQ0KcGFydCBvZiB5b3VyIG5hbWVzcGFjZSBhbmQgd2l0
aCBhbm90aGVyIHNldCBvZiBvcHRpb25zIGluIGFub3RoZXIgcGFydA0Kb2YgdGhlIG5hbWVzcGFj
ZSwgYW5kIHRoZW4gcG9pbnRpbmcgdGhlIGFwcGxpY2F0aW9ucyBhdCB0aGUgImNvcnJlY3QiDQpw
YXRoIGZvciB0aGUgYmVoYXZpb3VyIHRoZXkgbmVlZC4NCg0KDQo+IFJlZ2FyZHMsDQo+ICAgIFRp
Z3Jhbi4NCj4gDQo+ID4gPiBJIHdvdWxkIGxpa2UgdG8gdXNlIHRoZSBvcHBvcnR1bml0eSB0byBi
cmluZyB0aGUgdG9waWMgb2YNCj4gPiA+IE9fTk9OQkxPQ0sNCj4gPiA+IG9wZW4oMikNCj4gPiA+
IGZsYWcgZm9yIG9mZmxpbmUgZmlsZXMuDQo+ID4gDQo+ID4gLS0NCj4gPiBUcm9uZCBNeWtsZWJ1
c3QNCj4gPiBDVE8sIEhhbW1lcnNwYWNlIEluYw0KPiA+IDQzMDAgRWwgQ2FtaW5vIFJlYWwsIFN1
aXRlIDEwNQ0KPiA+IExvcyBBbHRvcywgQ0EgOTQwMjINCj4gPiB3d3cuaGFtbWVyLnNwYWNlDQot
LSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJz
cGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
