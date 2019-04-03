Return-Path: <SRS0=5sV6=SF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF118C4360F
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 21:13:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4E33620663
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 21:13:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="BoFEBQYF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726329AbfDCVNm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Apr 2019 17:13:42 -0400
Received: from mail-eopbgr820130.outbound.protection.outlook.com ([40.107.82.130]:40576
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726151AbfDCVNm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 3 Apr 2019 17:13:42 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=daucWa/EjyhdkTG1VSuIs54yvSD+ADwO3StjywS48PA=;
 b=BoFEBQYFbfLgRR/tfKuGtejn8GY9hprWI1KLhTX1Li87h1GGIeXs4tN2cjgKJElTzhRAx0TB5sL9hNMlwoh/zwGiG1Y5gcsSeqD5ngWkCRa7UWhPNqJ760LcT7Ke0V2wXM0qjIcQ32Xpn0Lwlp89mXuxlBoSSVZWK0fEsqjsjRw=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.6; Wed, 3 Apr 2019 21:13:37 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1771.007; Wed, 3 Apr 2019
 21:13:37 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "aglo@umich.edu" <aglo@umich.edu>
Subject: Re: [PATCH v2 00/28] Fix up soft mounts for NFSv4.x
Thread-Topic: [PATCH v2 00/28] Fix up soft mounts for NFSv4.x
Thread-Index: AQHU5nsJRwz03LQg+Ue1ZSadqsrG1KYnihuAgAGstgCAAbo8gIAABjAA
Date:   Wed, 3 Apr 2019 21:13:37 +0000
Message-ID: <ab9fed81bb7352541ad8c0bffddccfd376f1dd15.camel@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
         <CAN-5tyHGWp1o7v4bYCsEFxRJpBhH9Qg9ieGZYDjBVdmtua9KPA@mail.gmail.com>
         <1778bf6d42f956d0226fe05683b385654b4c0109.camel@gmail.com>
         <995086222.2639035.1554324687132.JavaMail.zimbra@desy.de>
In-Reply-To: <995086222.2639035.1554324687132.JavaMail.zimbra@desy.de>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [63.235.104.78]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 7ac01494-185b-4659-656f-08d6b8793d50
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2494;
x-ms-traffictypediagnostic: SN6PR13MB2494:
x-ms-exchange-purlcount: 1
x-microsoft-antispam-prvs: <SN6PR13MB24948FF96BFCFD2149CF3FEEB8570@SN6PR13MB2494.namprd13.prod.outlook.com>
x-forefront-prvs: 0996D1900D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(396003)(366004)(39830400003)(376002)(189003)(13464003)(199004)(8936002)(186003)(6436002)(6486002)(486006)(316002)(26005)(478600001)(54906003)(5640700003)(476003)(53546011)(6506007)(81166006)(4326008)(36756003)(99286004)(11346002)(446003)(81156014)(229853002)(76176011)(2616005)(6116002)(71200400001)(71190400001)(102836004)(6512007)(8676002)(93886005)(53936002)(14454004)(6246003)(2501003)(106356001)(118296001)(7736002)(66066001)(305945005)(2351001)(6916009)(5660300002)(15974865002)(68736007)(97736004)(86362001)(105586002)(25786009)(256004)(14444005)(3846002)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2494;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 6aMXU9xN5/gvq9IiQS7HXy8rXQwPdsHXqcjpLu3CW4jtFWXqRHNL771OJLMnYXydGlNRdllPK2k9VPatFVadLCAnRWjuQLwwPWh2HTqg7a8Hf9d/lEH5VSk9lEucvKmNAOr7GxWPDf/xbAsdVV9fS2Ez+4/IbrZI9rZjXWElRwwG3kOrY6eWHFxNHuCp+Ogur9PeH3ZICg4jVW0Seg41pG+KalPp/gNFbvb5qgZIVlSUr/C0Zs/scc7ZU2RpnHxBtye5cXWMuKnUkFISHQaQEX7ey80IlWRW4SO6tndMsKeCS/IzpWxd//45IXLjm3mwgnghbE0JZZQjFeUOc1OUBDD+uh3QR8TZKqk1DmhqB8Tt7V9sZo0EaPgCXAunwl3U2SgU1yFFPLNqCzghzdWT0IHgj7u2MEUqD4XBA19XYNw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <0C855C6FD6B1734EA14D3AFB541FA347@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7ac01494-185b-4659-656f-08d6b8793d50
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Apr 2019 21:13:37.7145
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2494
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTA0LTAzIGF0IDIyOjUxICswMjAwLCBNa3J0Y2h5YW4sIFRpZ3JhbiB3cm90
ZToNCj4gSGkgVHJvbmQsDQo+IA0KPiAtLS0tLSBPcmlnaW5hbCBNZXNzYWdlIC0tLS0tDQo+ID4g
RnJvbTogIlRyb25kIE15a2xlYnVzdCIgPHRyb25kbXlAZ21haWwuY29tPg0KPiA+IFRvOiAiT2xn
YSBLb3JuaWV2c2thaWEiIDxhZ2xvQHVtaWNoLmVkdT4NCj4gPiBDYzogImxpbnV4LW5mcyIgPGxp
bnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+DQo+ID4gU2VudDogVHVlc2RheSwgQXByaWwgMiwgMjAx
OSA4OjI4OjM4IFBNDQo+ID4gU3ViamVjdDogUmU6IFtQQVRDSCB2MiAwMC8yOF0gRml4IHVwIHNv
ZnQgbW91bnRzIGZvciBORlN2NC54DQo+ID4gT24gTW9uLCAyMDE5LTA0LTAxIGF0IDEyOjU0IC0w
NDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90ZToNCj4gPiA+IE9uIEZyaSwgTWFyIDI5LCAyMDE5
IGF0IDY6MDIgUE0gVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+IHRyb25kbXlAZ21haWwuY29tPg0K
PiA+ID4gd3JvdGU6DQo+ID4gPiA+IFRoaXMgcGF0Y2hzZXQgYWltcyB0byBtYWtlIHNvZnQgbW91
bnRzIGEgdmlhYmxlIG9wdGlvbiBmb3INCj4gPiA+ID4gTkZTdjQNCj4gPiA+ID4gY2xpZW50cw0K
PiA+ID4gPiBieSBtaW5pbWlzaW5nIHRoZSByaXNrIG9mIGZhbHNlIHBvc2l0aXZlIHRpbWVvdXRz
LCB3aGlsZQ0KPiA+ID4gPiBhbGxvd2luZw0KPiA+ID4gPiBmb3INCj4gPiA+ID4gZmFzdGVyIGZh
aWxvdmVyIG9mIHJlYWRzIGFuZCB3cml0ZXMgb25jZSBhIHRpbWVvdXQgaXMgYWN0dWFsbHkNCj4g
PiA+ID4gb2JzZXJ2ZWQuDQo+ID4gPiA+IA0KPiA+ID4gPiBUaGUgcGF0Y2hlcyByZWx5IG9uIHRo
ZSBORlMgc2VydmVyIGNvcnJlY3RseSBpbXBsZW1lbnRpbmcgdGhlDQo+ID4gPiA+IGNvbnRyYWN0
DQo+ID4gPiA+IHNwZWNpZmllZCBpbiBSRkM3NTMwIHNlY3Rpb24gMy4xLjEgd2l0aCByZXNwZWN0
IHRvIG5vdCBkcm9wcGluZw0KPiA+ID4gPiByZXF1ZXN0cw0KPiA+ID4gPiB3aGlsZSB0aGUgdHJh
bnNwb3J0IGNvbm5lY3Rpb24gaXMgdXAuIFdoZW4gdGhpcyBpcyB0aGUgY2FzZSwNCj4gPiA+ID4g
dGhlDQo+ID4gPiA+IGNsaWVudA0KPiA+ID4gPiBjYW4gc2FmZWx5IGFzc3VtZSB0aGF0IGlmIHRo
ZSByZXF1ZXN0IGhhcyBub3QgcmVjZWl2ZWQgYSByZXBseQ0KPiA+ID4gPiBhZnRlcg0KPiA+ID4g
PiB0cmFuc21pdHRpbmcgYSBSUEMgcmVxdWVzdCwgaXQgaXMgbm90IGJlY2F1c2UgdGhlIHJlcXVl
c3Qgd2FzDQo+ID4gPiA+IGRyb3BwZWQsDQo+ID4gPiA+IGJ1dCByYXRoZXIgaXMgZHVlIHRvIGNv
bmdlc3Rpb24sIG9yIHNsb3cgcHJvY2Vzc2luZyBvbiB0aGUNCj4gPiA+ID4gc2VydmVyLg0KPiA+
ID4gPiBJT1c6IGFzIGxvbmcgYXMgdGhlIGNvbm5lY3Rpb24gcmVtYWlucyB1cCwgdGhlcmUgaXMg
bm8gbmVlZCBmb3INCj4gPiA+ID4gcmVxdWVzdHMNCj4gPiA+ID4gdG8gdGltZSBvdXQuDQo+ID4g
PiA+IA0KPiA+ID4gPiBUaGUgcGF0Y2hlcyBicmVhayBkb3duIHJvdWdobHkgYXMgZm9sbG93czoN
Cj4gPiA+ID4gLSBBIHNldCBvZiBwYXRjaGVzIHRvIGNsZWFuIHVwIHRoZSBSUEMgZW5naW5lIHRp
bWVvdXRzLCBhbmQNCj4gPiA+ID4gZW5zdXJlDQo+ID4gPiA+IHRoZXkNCj4gPiA+ID4gICBhcmUg
YWNjdXJhdGUuDQo+ID4gPiA+IC0gQSBzZXQgb2YgcGF0Y2hlcyB0byBjaGFuZ2UgdGhlICdzb2Z0
JyBtb3VudCBzZW1hbnRpY3MgZm9yDQo+ID4gPiA+IE5GU3Y0LnguDQo+ID4gPiA+IC0gQSBzZXQg
b2YgcGF0Y2hlcyB0byBhZGQgYSBuZXcgJ3NvZnRlcnInIG1vdW50IG9wdGlvbiB0aGF0DQo+ID4g
PiA+IHdvcmtzDQo+ID4gPiA+IGxpa2UNCj4gPiA+ID4gICBzb2Z0LCBidXQgZXhwbGljaXRseSBz
aWduYWxzIHRpbWVvdXRzIHVzaW5nIHRoZSBFVElNRURPVVQNCj4gPiA+ID4gZXJyb3INCj4gPiA+
ID4gY29kZQ0KPiA+ID4gPiAgIHJhdGhlciB0aGFuIHVzaW5nIEVJTy4gVGhpcyBhbGxvd3MgYXBw
bGljYXRpb25zIHRvIHR1bmUgdGhlaXINCj4gPiA+ID4gICBiZWhhdmlvdXIgKGUuZy4gYnkgZmFp
bGluZyBvdmVyIHRvIGEgZGlmZmVyZW50IHNlcnZlcikgaWYgYQ0KPiA+ID4gPiB0aW1lb3V0DQo+
ID4gPiA+ICAgb2NjdXJzLg0KPiA+ID4gDQo+ID4gPiBJJ20ganVzdCBjdXJpb3VzIHdoeSB3b3Vs
ZCBhbiBhcHBsaWNhdGlvbiBiZSBhd2FyZSBvZiBhIGRpZmZlcmVudA0KPiA+ID4gc2VydmVyIHRv
IGNvbm5lY3QgdG8gYW5kIGFuIE5GUyBsYXllciB3b3VsZCBub3QgYmU/IEknbSBhbHNvDQo+ID4g
PiBjdXJpb3VzDQo+ID4gPiB3b3VsZG4ndCBpdCBicmVhayBhcHBsaWNhdGlvbiB0aGF0IHR5cGlj
YWxseSBleHBlY3QgdG8gZ2V0IGFuIEVJTw0KPiA+ID4gZXJyb3JzPyBEbyBhbGwgc3lzdGVtIGNh
bGxzIGFsbG93IHRvIHJldHVybiBFVElNRURPVVQgZXJyb3I/DQo+ID4gDQo+ID4gVGhpcyBpcyB3
aHkgaXQgaXMgYSBzZXBhcmF0ZSBtb3VudCBvcHRpb24uIC4uLmFuZCBhY3R1YWxseSBtb3N0DQo+
ID4gYXBwbGljYXRpb25zIGJsb3cgdXAgd2hlbiB0aGV5IGdldCBFSU8gYXMgd2VsbC4gSG93ZXZl
ciB5b3UgY2FuDQo+ID4gaW1hZ2luZQ0KPiA+IGFuIGFwcGxpY2F0aW9uIHRoYXQgbWlnaHQgZGVj
aWRlIHRvIHJldHJ5IGlmIGl0IGhpdHMgYW4gRVRJTUVET1VULA0KPiA+IHdoaWxlIGZhaWxpbmcg
aWYgaXQgaGl0cyBhbiBFSU8uDQo+IA0KPiBXaGF0IGlzIHRoZSByZWFzb24gb2YgaW50cm9kdWNp
bmcgbmV3IGVycm9yIGNvZGUgZm9yIElPIG9wZXJhdGlvbnMsDQo+IHdoaWNoDQo+IGlzIG5vdCBp
biB0aGUgbGlzdCBvZiBQT1NJWCBzcGVjaWZpZWQgdmFsdWVzIGZvciByZWFkKDIpIGFuZA0KPiB3
cml0ZSgyKS4gSXMNCj4gdGhlcmUgZXhwZWN0ZWQgYXBwbGljYXRpb24gYmVoYXZpb3IgY2hhbmdl
IGNvbXBhcmVkIHRvIEVBR0FJTj8NCg0KVGhlIHBvaW50IGlzIHRvIGFsbG93IGF3YXJlIGFwcGxp
Y2F0aW9ucyB0byBiZXR0ZXIgaGFuZGxlIGEgc2l0dWF0aW9uDQp3aGljaCBpcyBub3QgY292ZXJl
ZCBieSBQT1NJWCBiZWNhdXNlIFBPU0lYIGhhcyBubyBjb25jZXB0IG9mIHN0b3JhZ2UNCnRoYXQg
aXMgdGVtcG9yYXJpbHkgdW5hdmFpbGFibGUuDQoNCi4uLmFuZCBpdCBpcyBiZWluZyBwcm9wb3Nl
ZCBhcyBhbiBvcHQtaW4gZmVhdHVyZSwgcHJlY2lzZWx5IHNvIHRoYXQNCmV4aXN0aW5nIGFwcGxp
Y2F0aW9ucyBkb24ndCBuZWVkIHRvIGNoYW5nZS4NCg0KPiBJIHdvdWxkIGxpa2UgdG8gdXNlIHRo
ZSBvcHBvcnR1bml0eSB0byBicmluZyB0aGUgdG9waWMgb2YgT19OT05CTE9DSw0KPiBvcGVuKDIp
DQo+IGZsYWcgZm9yIG9mZmxpbmUgZmlsZXMuDQoNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkNU
TywgSGFtbWVyc3BhY2UgSW5jDQo0MzAwIEVsIENhbWlubyBSZWFsLCBTdWl0ZSAxMDUNCkxvcyBB
bHRvcywgQ0EgOTQwMjINCnd3dy5oYW1tZXIuc3BhY2UNCg0KDQo=
