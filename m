Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE738C10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 21:23:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A3C2320880
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 21:23:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="wF9wrrEK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727197AbfDHVXu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 17:23:50 -0400
Received: from mail-eopbgr770120.outbound.protection.outlook.com ([40.107.77.120]:37970
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726486AbfDHVXt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Apr 2019 17:23:49 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=j4ARFDH08rB9jEcl2nSNqKMEA3fRJVmfeXwJjqSkAQ8=;
 b=wF9wrrEKIIufyvafv8/Q+YpUrZzIWgFF/3OF6R3KLFJ4M7peNo1pThI22NnDlIlIX8yVLsuTblmfYawSzaWJI0bUoq0cPeVSMTmXaxWADPVL0e11LTUQRJvfZ4vwAn9sY+F7tqLAvV7zZtHIQr9DkzDbm0xCih0YGU1xjo0o0UQ=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2270.namprd13.prod.outlook.com (52.135.93.159) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.7; Mon, 8 Apr 2019 21:23:42 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Mon, 8 Apr 2019
 21:23:42 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "kolga@netapp.com" <kolga@netapp.com>
Subject: Re: [PATCH v1] NFS: Fix handling of reply page vector
Thread-Topic: [PATCH v1] NFS: Fix handling of reply page vector
Thread-Index: AQHU7kW8ipWQk7MB5UOoW6Ab09Puv6YyuYYAgAAFfYCAAAcRAA==
Date:   Mon, 8 Apr 2019 21:23:42 +0000
Message-ID: <aa8a63d9bfc6d76800ef00bfa3b6921e312cfd44.camel@hammerspace.com>
References: <20190408200030.16366.22026.stgit@manet.1015granger.net>
         <bede7559be11f283e9f37db2da0b47ddf869a468.camel@hammerspace.com>
         <B28ACEA4-BB35-4137-A81F-50A1D2974F6A@oracle.com>
In-Reply-To: <B28ACEA4-BB35-4137-A81F-50A1D2974F6A@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ce7ae99b-de2c-43f2-b651-08d6bc6879d9
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:SN6PR13MB2270;
x-ms-traffictypediagnostic: SN6PR13MB2270:
x-microsoft-antispam-prvs: <SN6PR13MB2270E058EE5F0C84A52C3EF0B82C0@SN6PR13MB2270.namprd13.prod.outlook.com>
x-forefront-prvs: 0001227049
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39830400003)(376002)(366004)(346002)(136003)(189003)(199004)(305945005)(476003)(229853002)(6512007)(3846002)(6116002)(53936002)(6436002)(25786009)(6486002)(316002)(2906002)(2501003)(4326008)(102836004)(26005)(2616005)(5640700003)(99286004)(7736002)(6246003)(486006)(54906003)(6916009)(446003)(186003)(118296001)(53546011)(105586002)(36756003)(76176011)(6506007)(256004)(11346002)(5660300002)(106356001)(68736007)(66066001)(2351001)(14454004)(8676002)(478600001)(71190400001)(86362001)(97736004)(81156014)(81166006)(14444005)(71200400001)(8936002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2270;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 2y3ylw6XJjTCe/R79g5vrQhRJW51tvM0aZE1PnWWsHOXQlVJE8ZaOWr/LMtmDxS8FzzJcCfcxwY9TGlfKLOWckUWYQT5zS7mV22TTtNpeXpme5XzT+j9J9X7f8g9d0FvEgXKkFJ5SIWa2PCYpN9EKPVAlZbA+xb0koqMcZQwB0SBazVOyZM1ShAckGakV3BLUcLd8phe2mqg+PRUdX6SS4cExkJabRG8wNGYbHAvRrFiQebAGGHgyBhdlAnB4lWGlUb9lLLLIf5OcpzobyNTyvPHzvJugNXkM8hCGj93FlRuQe2s4s1Y9/DxrG4o+DZ+CSqvLdN9J5U1flANGAysGC3aCpfslZEC1cGM7xewW+xb7OzHzcdzCIXXge42yQCAPA8aiBqv/3BsSJr98BrLDah4W5tVT9jXufi33pasgek=
Content-Type: text/plain; charset="utf-8"
Content-ID: <E00212DE186DCA4991A760D5B89F6F9A@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ce7ae99b-de2c-43f2-b651-08d6bc6879d9
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Apr 2019 21:23:42.4994
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2270
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTA0LTA4IGF0IDE2OjU4IC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBBcHIgOCwgMjAxOSwgYXQgNDozOCBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiB0cm9u
ZG15QGhhbW1lcnNwYWNlLmNvbT4gd3JvdGU6DQo+ID4gDQo+ID4gT24gTW9uLCAyMDE5LTA0LTA4
IGF0IDE2OjAwIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiA+IE5GU3Y0IEdFVEFDTCBh
bmQgRlNfTE9DQVRJT05TIHJlcXVlc3RzIHN0b3BwZWQgd29ya2luZyBpbiB2NS4xLQ0KPiA+ID4g
cmMuDQo+ID4gPiANCj4gPiA+IFRoZXNlIHR3byBuZWVkIHRoZSBleHRyYSBwYWRkaW5nIHRvIGJl
IGFkZGVkIGRpcmVjdGx5IHRvIHRoZQ0KPiA+ID4gcmVwbHkNCj4gPiA+IGxlbmd0aC4NCj4gPiA+
IA0KPiA+ID4gUmVwb3J0ZWQtYnk6IE9sZ2EgS29ybmlldnNrYWlhIDxhZ2xvQHVtaWNoLmVkdT4N
Cj4gPiA+IEZpeGVzOiAwMmVmMDRlNDMyYmEgKCJORlM6IEFjY291bnQgZm9yIFhEUiBwYWQgb2Yg
YnVmLT5wYWdlcyIpDQo+ID4gPiBTaWduZWQtb2ZmLWJ5OiBDaHVjayBMZXZlciA8Y2h1Y2subGV2
ZXJAb3JhY2xlLmNvbT4NCj4gPiA+IC0tLQ0KPiA+ID4gZnMvbmZzL25mczR4ZHIuYyB8ICAgIDQg
KystLQ0KPiA+ID4gMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMo
LSkNCj4gPiA+IA0KPiA+ID4gZGlmZiAtLWdpdCBhL2ZzL25mcy9uZnM0eGRyLmMgYi9mcy9uZnMv
bmZzNHhkci5jDQo+ID4gPiBpbmRleCBjZmNhYmMzLi42MDI0NDYxIDEwMDY0NA0KPiA+ID4gLS0t
IGEvZnMvbmZzL25mczR4ZHIuYw0KPiA+ID4gKysrIGIvZnMvbmZzL25mczR4ZHIuYw0KPiA+ID4g
QEAgLTI1ODksNyArMjU4OSw3IEBAIHN0YXRpYyB2b2lkIG5mczRfeGRyX2VuY19nZXRhY2woc3Ry
dWN0DQo+ID4gPiBycGNfcnFzdA0KPiA+ID4gKnJlcSwgc3RydWN0IHhkcl9zdHJlYW0gKnhkciwN
Cj4gPiA+IAkJCUFSUkFZX1NJWkUobmZzNF9hY2xfYml0bWFwKSwgJmhkcik7DQo+ID4gPiANCj4g
PiA+IAlycGNfcHJlcGFyZV9yZXBseV9wYWdlcyhyZXEsIGFyZ3MtPmFjbF9wYWdlcywgMCwNCj4g
PiA+IC0JCQkJYXJncy0+YWNsX2xlbiwgcmVwbGVuKTsNCj4gPiA+ICsJCQkJYXJncy0+YWNsX2xl
biwgcmVwbGVuICsgMSk7DQo+ID4gPiAJZW5jb2RlX25vcHMoJmhkcik7DQo+ID4gPiB9DQo+ID4g
PiANCj4gPiA+IEBAIC0yODExLDcgKzI4MTEsNyBAQCBzdGF0aWMgdm9pZA0KPiA+ID4gbmZzNF94
ZHJfZW5jX2ZzX2xvY2F0aW9ucyhzdHJ1Y3QNCj4gPiA+IHJwY19ycXN0ICpyZXEsDQo+ID4gPiAJ
fQ0KPiA+ID4gDQo+ID4gPiAJcnBjX3ByZXBhcmVfcmVwbHlfcGFnZXMocmVxLCAoc3RydWN0IHBh
Z2UgKiopJmFyZ3MtPnBhZ2UsIDAsDQo+ID4gPiAtCQkJCVBBR0VfU0laRSwgcmVwbGVuKTsNCj4g
PiA+ICsJCQkJUEFHRV9TSVpFLCByZXBsZW4gKyAxKTsNCj4gPiA+IAllbmNvZGVfbm9wcygmaGRy
KTsNCj4gPiA+IH0NCj4gPiA+IA0KPiA+IA0KPiA+IEknbSBoYXZpbmcgdHJvdWJsZSB3aXRoIHRo
ZSBtYXRoIGhlcmUuIFdoeSBhcmUgd2UgcHJlLWVtcHRpdmVseQ0KPiA+IHN1YnRyYWN0aW5nIGEg
d29yZCBmcm9tIHRoZSB0YWlsPyBUaGUgaGVhZGVyIGNvbnN0YW50cyBhcmUgYWx3YXlzDQo+ID4g
NC1iaXQgDQo+ID4gYWxpZ25lZCBiZWNhdXNlIHRoZXkgYXJlIGNhbGN1bGF0ZWQgYXMgYSB3b3Jk
IGNvdW50LCBzbyBJJ20gbm90DQo+ID4gdW5kZXJzdGFuZGluZyB3aHkgd2UgbmVlZCBjb21taXQg
MDJlZjA0ZTQzMmJhIGF0IGFsbC4NCj4gPiANCj4gPiBDYW4geW91IHBsZWFzZSBleHBsYWluLCBD
aHVjaz8NCj4gDQo+IFRoZSBnb2FsIGlzIHRvIGFsbG9jYXRlIGEgcmVwbHkgYnVmZmVyIHRoYXQg
aXMganVzdCBsYXJnZSBlbm91Z2gNCj4gdG8gZml0IHRoZSBleHBlY3RlZCByZXBseSwgYW5kIGVu
c3VyZSB0aGF0IHRoZSB2YXJpYWJsZS1sZW5ndGgNCj4gcGF5bG9hZCB3aWxsIHN0YXJ0IGV4YWN0
bHkgd2hlcmUgdGhlIHhkcl9idWYncyBwYWdlcyBiZWdpbi4NCj4gDQo+IEluIGNhc2VzIHdoZXJl
IHRoZSBwYXlsb2FkIGxlbmd0aCBpcyBub3QgYWxpZ25lZCB0byBmb3VyIGJ5dGVzLA0KPiBhbiBl
eHRyYSBxdWFkIGhhcyB0byBiZSBhbGxvY2F0ZWQgaW4gdGhlIHRhaWwuIFNvLCB0aGUgdG90YWwN
Cj4gcmVwbHkgbGVuZ3RoIGlzIGluY3JlYXNlZCBieSBvbmUgcXVhZCBzbyB0aGVyZSBpcyBlbm91
Z2ggc3BhY2UNCj4gZm9yIHRoZSBYRFIgcGFkIGJ5dGVzIGluIHRoZSB0YWlsLg0KPiANClJpZ2h0
LCBidXQgd2Ugc2hvdWxkIG5ldmVyIGhpdCB0aGF0IHByb2JsZW0gYmVjYXVzZSB0aGUgcHJvYy0+
cF9hcmdsZW4NCmFuZCBwcm9jLT5wX3JlcGxlbiBhcmUgYWx3YXlzIGluIHVuaXRzIG9mIDMyLWJp
dCB3b3Jkcy4NCg0KSU9XOiB0aGUgZnVuY3Rpb25zIHRoYXQgYWxsb2NhdGUgbWVtb3J5LCB3aWxs
IGFsd2F5cyBkbyBzbyBpbiBmdWxsDQp3b3JkcywgaGVuY2UgaXQgc2hvdWxkIG5vdCBiZSBuZWNl
c3NhcnkgZm9yIHhkcl9pbmxpbmVfcGFnZXMoKSB0bw0KYWRqdXN0IHRoYXQgYWxsb2NhdGlvbi4N
Cg0KVGhlIG9uZSB0aGluZyB0aGF0IHdlIF9taWdodF8gd2FudCB0byBkbyBpZiB3ZSdyZSB0byBk
byBhbnl0aGluZyBhdCBhbGwNCmlzIHRvIHBlcmhhcHMgYWRqdXN0IHRhaWwtPmlvdl9iYXNlIGJ5
ICh4ZHItPnBhZ2VfbGVuICYgMykgYnl0ZXMgdG8NCmVuc3VyZSB0aGF0IHdlIGhhdmUgd29yZC1h
bGlnbmVkIGRhdGEgaW4gdGhlIHRhaWwuDQoNCmkuZS4gY2FwdHVyZSB0aGUgcGFkZGluZyBpbiB0
aGUgcmVtYWluaW5nIGJ5dGVzIGluIHRoYXQgZmlyc3Qgd29yZCwgc28NCnRoYXQgeGRyX3JlYWRf
cGFnZXMoKSBzZXRzIHdvcmQgYWxpZ25lZCB2YWx1ZXMgZm9yIHhkci0+cCBhbmQgeGRyLT5lbmQu
DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1t
ZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
