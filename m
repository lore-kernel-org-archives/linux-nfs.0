Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E03BC10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 17:07:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 129B920818
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 17:07:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="BugMOLnz"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726391AbfDKRHB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 13:07:01 -0400
Received: from mail-eopbgr800131.outbound.protection.outlook.com ([40.107.80.131]:10304
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726800AbfDKRHB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 11 Apr 2019 13:07:01 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=xac4zXqTwhApCwOpQQ6Ojwo249Yf7XGbwCaAB2uswZA=;
 b=BugMOLnzYQHMRtor/eyximQmUad/IizEa8ac2Nt1t9q9D3BYsd/uz94WkQV7H4KFUOfQV3cIeWBPKy6o8d4dcAotd5H/dwmzI6mVxG4oJ9RtPbipI7ldt2Z4T0CoOP8a0AEUcvYjbOEiTcvXBYyadjKsvzE1K3PNIdtOvnFxFsY=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2382.namprd13.prod.outlook.com (52.135.94.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.10; Thu, 11 Apr 2019 17:06:18 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Thu, 11 Apr 2019
 17:06:18 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "olga.kornievskaia@gmail.com" <olga.kornievskaia@gmail.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv4.1 fix incorrect return value in copy_file_range
Thread-Topic: [PATCH 1/1] NFSv4.1 fix incorrect return value in
 copy_file_range
Thread-Index: AQHU8IOGkX0JgFjPkkOfyqt8wY1bPqY3K0gAgAABlICAAAPcAA==
Date:   Thu, 11 Apr 2019 17:06:18 +0000
Message-ID: <d7146ead1f35af97a8f107326904f13d4031b8fc.camel@hammerspace.com>
References: <20190411162747.4360-1-olga.kornievskaia@gmail.com>
         <0de6cbcd86a69d2e19e4adc2cd70822ce0ae557a.camel@hammerspace.com>
         <CAN-5tyGz1Vd6_p3pVtv8+zw5YQ+vTNH=MtYAQyg_mQ67632nBA@mail.gmail.com>
In-Reply-To: <CAN-5tyGz1Vd6_p3pVtv8+zw5YQ+vTNH=MtYAQyg_mQ67632nBA@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 99c3d5cf-696e-4c8a-3bb4-08d6bea0039b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2382;
x-ms-traffictypediagnostic: SN6PR13MB2382:
x-microsoft-antispam-prvs: <SN6PR13MB2382162F5AD4DE2AA0FE4105B82F0@SN6PR13MB2382.namprd13.prod.outlook.com>
x-forefront-prvs: 00046D390F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(39830400003)(376002)(136003)(346002)(199004)(189003)(316002)(5660300002)(36756003)(54906003)(446003)(118296001)(71200400001)(478600001)(486006)(6246003)(53936002)(86362001)(14454004)(66066001)(256004)(4326008)(71190400001)(476003)(14444005)(11346002)(99286004)(106356001)(3846002)(6116002)(105586002)(7736002)(305945005)(2616005)(97736004)(6506007)(2351001)(76176011)(2501003)(6486002)(229853002)(6916009)(81166006)(8676002)(53546011)(5640700003)(6436002)(81156014)(1361003)(102836004)(68736007)(6512007)(186003)(26005)(25786009)(2906002)(8936002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2382;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: sfNacoXoM7ogJjgkjizGh38ZfHlIQirwjnQbN1c1Y1fCF9ITr5aogZDNCD7KOTV5trbBw/DlYLi+zB+cp/eG61YN07AyiH8Du01Dbm1G4W6EkTXV/3ITVEUVEjxs05NoXvQQDjmErUpgUVLbxydKM+yLWFmgBsHOi9azeRBI3lQDidtyX6cSLQ0e9nR+/2/8o4mHC3elCjrq9rLwfQtYDeGhEsaqHfUUpB9zBCgMpqKYOVCdKM31g2tbs9i6RDNmdxxYVixlDVQSGIycbK/u1fTMJfFu1bky8+uwwi9EcckciZSClRG5vDvmJqHDHi2k+k/737sxJ7wApfPVuepDrSZ39HNIZ9DIZRuW6+DcekzbmJoMN4Xb+WGUJ0kHc7Y3D9RPhzadK6J2ARUWC5RnOR6qnwJ0Bv9AU2AA6WyS+IQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <B1A3B343FB5BA247A37DB430DA8E3F6A@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 99c3d5cf-696e-4c8a-3bb4-08d6bea0039b
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Apr 2019 17:06:18.2722
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2382
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTA0LTExIGF0IDEyOjUyIC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gT24gVGh1LCBBcHIgMTEsIDIwMTkgYXQgMTI6NDYgUE0gVHJvbmQgTXlrbGVidXN0DQo+
IDx0cm9uZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gT24gVGh1LCAyMDE5LTA0LTEx
IGF0IDEyOjI3IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90ZToNCj4gPiA+IEZyb206IE9s
Z2EgS29ybmlldnNrYWlhIDxrb2xnYUBuZXRhcHAuY29tPg0KPiA+ID4gDQo+ID4gPiBXaGVuIFZG
UyBjYWxscyBjb3B5X2ZpbGVfcmFuZ2Ugb24gYSA0LjAgbW91bnQgKGFuZCB3aGVuIGluIGFuZA0K
PiA+ID4gb3V0DQo+ID4gPiBmaWxlIGlzIHRoZSBzYW1lKSwgd2UgbmVlZCB0byByZXR1cm4gRU5P
VFNVUFAgaW5zdGVhZCBvZiBFSU5WQUwuDQo+ID4gPiBTaW5jZSBubyBDT1BZIG9wZXJhdGlvbiBp
cyBkZWZpbmVkIGluIDQuMCwgdGhlbiBsaWtlIDMuMCwgaXQNCj4gPiA+IHNob3VsZA0KPiA+ID4g
ZmFsbGJhY2sgdG8gZG9pbmcgZG9fc3BsaWNlX2RpcmVjdCgpLg0KPiA+ID4gDQo+ID4gPiBPdGhl
cndpc2UgeGZzdGVzdCBnZW5lcmljLzA3NSwwOTEsMTEyLDI2MyBmYWlsLg0KPiA+ID4gDQo+ID4g
PiBTaWduZWQtb2ZmLWJ5OiBPbGdhIEtvcm5pZXZza2FpYSA8a29sZ2FAbmV0YXBwLmNvbT4NCj4g
PiA+IC0tLQ0KPiA+ID4gIGZzL25mcy9uZnM0ZmlsZS5jIHwgNiArKysrKysNCj4gPiA+ICAxIGZp
bGUgY2hhbmdlZCwgNiBpbnNlcnRpb25zKCspDQo+ID4gPiANCj4gPiA+IGRpZmYgLS1naXQgYS9m
cy9uZnMvbmZzNGZpbGUuYyBiL2ZzL25mcy9uZnM0ZmlsZS5jDQo+ID4gPiBpbmRleCA0NWIyMzIy
Li45YTIyMmIwIDEwMDY0NA0KPiA+ID4gLS0tIGEvZnMvbmZzL25mczRmaWxlLmMNCj4gPiA+ICsr
KyBiL2ZzL25mcy9uZnM0ZmlsZS5jDQo+ID4gPiBAQCAtMTMzLDYgKzEzMywxMiBAQCBzdGF0aWMg
c3NpemVfdCBuZnM0X2NvcHlfZmlsZV9yYW5nZShzdHJ1Y3QNCj4gPiA+IGZpbGUNCj4gPiA+ICpm
aWxlX2luLCBsb2ZmX3QgcG9zX2luLA0KPiA+ID4gICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICAgIHN0cnVjdCBmaWxlICpmaWxlX291dCwgbG9mZl90DQo+ID4gPiBwb3Nfb3V0LA0KPiA+
ID4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHNpemVfdCBjb3VudCwgdW5zaWdu
ZWQgaW50DQo+ID4gPiBmbGFncykNCj4gPiA+ICB7DQo+ID4gPiArICAgICBzdHJ1Y3QgbmZzX3Nl
cnZlciAqc2VydmVyID0gTkZTX1NFUlZFUihmaWxlX2lub2RlKGZpbGVfaW4pOw0KPiA+ID4gKyAg
ICAgc3RydWN0IG5mc19jbGllbnQgKmNsaWVudCA9IHNlcnZlci0+bmZzX2NsaWVudDsNCj4gPiA+
ICsNCj4gPiA+ICsgICAgIGlmIChjbGllbnQtPmNsX21pbm9ydmVyc2lvbiA8IDEpDQo+ID4gPiAr
ICAgICAgICAgICAgIHJldHVybiAtRU9QTk9UU1VQUDsNCj4gPiA+ICsNCj4gPiA+ICAgICAgIGlm
IChmaWxlX2lub2RlKGZpbGVfaW4pID09IGZpbGVfaW5vZGUoZmlsZV9vdXQpKQ0KPiA+ID4gICAg
ICAgICAgICAgICByZXR1cm4gLUVJTlZBTDsNCj4gPiA+ICAgICAgIHJldHVybiBuZnM0Ml9wcm9j
X2NvcHkoZmlsZV9pbiwgcG9zX2luLCBmaWxlX291dCwgcG9zX291dCwNCj4gPiA+IGNvdW50KTsN
Cj4gPiANCj4gPiBMZXQncyBwbGVhc2UganVzdCBtb3ZlIHRoZSB0ZXN0IGZvciBORlNfQ0FQX0NP
UFkgZnJvbQ0KPiA+IG5mczQyX3Byb2NfY29weSgpDQo+ID4gaW50byB0aGUgYWJvdmUgZnVuY3Rp
b24uDQo+IA0KPiBCdXQgdGhlIHJldHVybiBvcmRlciBvZiBlcnJvcnMgaGVyZSBmb3IgZGlmZmVy
ZW50IGNvbmRpdGlvbnMgbWF0dGVyLg0KPiBGb3IgNC4xKyBtb3VudHMsIGlmIGluID09IG91dCwg
d2UnZCBleHBlY3QgRUlOVkFMIGV2ZW4gaWYgc2VydmVyDQo+IGlzbid0DQo+IGNhcGFibGUuIEJ1
dCB3ZSBjYW4ndCBqdXN0IHB1dCB0aGUgaW4gPT0gb3V0IGZpcnN0IGJlY2F1c2UgZm9yIDQuMCwN
Cj4gd2UNCj4gbmVlZCB0byBhbHdheXMgcmV0dXJuIEVPUE5PVFNVUFAuDQo+IA0KPiA+IEJUVzog
V2h5IGRvIHdlIHJldHVybiAtRUlOVkFMIGluIHRoZSBmaWxlX2luID09IGZpbGVfb3V0IGNhc2U/
IElzDQo+ID4gdGhlcmUNCj4gPiBhbnkgcmVhc29uIHdoeSB3ZSBzaG91bGRuJ3QganVzdCByZXR1
cm4gRU9QTk9UU1VQUCB0aGVyZSB0b28gaW4NCj4gPiBvcmRlcg0KPiA+IHRvIGxldCBzcGxpY2Uo
KSBmdWxmaWwgdGhlIG9wZXJhdGlvbj8NCj4gDQo+IFllczogaW4gPT0gb3V0IC0+IEVJTlZBTCBp
cyBhIHNwZWMgcmVxdWlyZW1lbnQuDQo+IA0KDQpSZXR1cm5pbmcgTkZTNEVSUl9JTlZBTCB3aGVu
IHRoZSBmaWxlcyBhcmUgaWRlbnRpY2FsIGlzIGEgcmVxdWlyZW1lbnQNCmZvciB0aGUgTkZTdjQu
MiBzZXJ2ZXIuDQoNCk9uIHRoZSBvdGhlciBoYW5kLCB0aGUgcmVxdWlyZW1lbnQgZm9yIHRoZSBM
aW51eCBmaWxlIGNvcHkgb3BlcmF0aW9uIGlzDQp0aGF0IGl0IHNob3VsZCBzdWNjZWVkIGluIHRo
aXMgc2l0dWF0aW9uLiBTbyBhcyBmYXIgYXMgSSBjYW4gdGVsbCwgd2UNCndpbGwgY29udGludWUg
dG8gZmFpbCB4ZnN0ZXN0cyB1bnRpbCB3ZSB3b3JrIGFyb3VuZCB0aGUgZGlzY3JlcGFuY3kNCndp
dGggdGhlIHByb3RvY29sIHJlcXVpcmVtZW50IGhlcmUuIFRoZSBzaW1wbGVzdCB3YXkgdG8gZG8g
c28gd291bGQNCmFwcGVhciB0byBiZSB0byByZXR1cm4gRU9QTk9UU1VQUC4NCg0KLS0gDQpUcm9u
ZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRy
b25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
