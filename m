Return-Path: <SRS0=2Ld2=NY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4C77C43441
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Nov 2018 00:08:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 60B2F224E0
	for <linux-nfs@archiver.kernel.org>; Tue, 13 Nov 2018 00:08:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="MLKQKXQj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60B2F224E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726198AbeKMKEL (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 13 Nov 2018 05:04:11 -0500
Received: from mail-eopbgr780110.outbound.protection.outlook.com ([40.107.78.110]:31776
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725991AbeKMKEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Nov 2018 05:04:11 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Xrb3Qk65v78wD4YRbo+66388TXtaZmbZIiR/pWwyEFI=;
 b=MLKQKXQjPnvMRh5QRnuesSKu6KP5V1JhuW1tFelp0yu6A4A7vtATEhJ4xKHjTiMoQYhgaFL3wLr3ij1kX0c/6nlTZyv6rhOhiCZUi6Bj3MAhM9GeLiLahi6kVC4btdihZuBaCD4HsrnWqSGlgRgxc5l56LTxJ1SqfdMWZ72zaUE=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2349.namprd13.prod.outlook.com (52.135.94.32) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1339.11; Tue, 13 Nov 2018 00:08:40 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1339.019; Tue, 13 Nov 2018
 00:08:40 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "schumakeranna@gmail.com" <schumakeranna@gmail.com>,
        "chucklever@gmail.com" <chucklever@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NULL dereference in rpcauth_lookup_credcache
Thread-Topic: NULL dereference in rpcauth_lookup_credcache
Thread-Index: AQHUd6xJVdpNrPMTaUWtaTxXqXNyo6VHvSMAgAHSE4CAAuRdgIAABxgAgAAwJgCAAB04gIAAD5eAgAAA5wCAAAItAA==
Date:   Tue, 13 Nov 2018 00:08:40 +0000
Message-ID: <b38d91d9e72944bf6908edb44ef5555eafc9ff98.camel@hammerspace.com>
References: <20181108214452.GH6090@fieldses.org>
         <04114B00-B5A8-4F8A-B052-A266AED7725D@gmail.com>
         <20181110214939.GA16755@fieldses.org>
         <c986450a2d19fa796078ed51b9d0fb8a79eda696.camel@hammerspace.com>
         <20181112182454.GE16755@fieldses.org>
         <2e62a77385b4e5d91e2ca9128313cf817c46a1ae.camel@hammerspace.com>
         <20181112230149.GF16755@fieldses.org>
         <9d36177854ba176f46e7a9842aa0368cc508b599.camel@hammerspace.com>
         <8B4BB2AC-D94B-4B76-BFF2-460303C8FE9B@oracle.com>
In-Reply-To: <8B4BB2AC-D94B-4B76-BFF2-460303C8FE9B@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2349;6:p56TtAt6+AkcG5z6YgWAIJf5WIJR76BpaQi4u2FT0Qitpr8s1CSf7OWhsj5LzRvMul3o+aKE5j45EcxOXbdbN2snZHQcD2Pst2TF04zguynbMDF6TYBFVrfR4mHBNvRwDKW2FTdujCCz7mrt4Lz/teuNdSQwr0P2HctR+7yNH3O2e/LMzbC67CaCRPABIBpUxH7SGQVXRBfPX+ulKytdI/Q1gV4Uq2igzDmOKiegbkxRkYVOtBMXZLvlt6chX6B7x68mIiIMMh2Q7dV/OzOZ9zrDnNraPwz+25JHDOE/EJVxgCdWD1mBr9KRL8/9M67P7E0BEpUcpyaL+JJoSELS92U5vTZSDqQpyU1be3spVoUvtzV7WgruN9tvJMqScIHQZ/Hy9qVZC03EKuM61NYV7WKGWret4Cf/8xXO7vEQF7JhFsVylsWhOveTxP04o5xEgsSKjAX0UmcVH2NpCHSGgQ==;5:lxAImJjgU9EtlburnSc01gVeaXb7LyVD3QZRZGNHPydjv/2stHM22/Q2ldEMSJ7PgtFdtRmlmSgmOqFDKmFaSZSOHiOranhMHG47XDRwsBahy1IQCbsQDh9IjcYB7GRBMxXyML4JkjkwR/2MsPyrxCRnIoU5EbeVxybVJhBIpno=;7:rZW7vEQJmnwIoW400gSG3p/SLTAvxJABUe+Kt42QuaDaM5U+e3VjpxwejAQmkU7AuN/NBBpKK+c+fY+MfSwcMOpHkZe++LXMGp7cQb4fJAGsRwY8V31iC+0dVunsHx8/gIzff7NvabWLNa7Jt2CAZg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 05cc0835-9a53-43d1-9113-08d648fc2aed
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390040)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2349;
x-ms-traffictypediagnostic: SN6PR13MB2349:
x-microsoft-antispam-prvs: <SN6PR13MB23491E77C8E347A6662834BCB8C20@SN6PR13MB2349.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(10201501046)(3002001)(3231382)(944501410)(52105112)(148016)(149066)(150057)(6041310)(20161123560045)(20161123564045)(20161123562045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2349;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2349;
x-forefront-prvs: 085551F5A8
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39830400003)(346002)(376002)(136003)(366004)(199004)(189003)(6916009)(2501003)(66066001)(68736007)(6436002)(6246003)(102836004)(2900100001)(256004)(14444005)(8936002)(71190400001)(53546011)(7736002)(5640700003)(54906003)(53936002)(81156014)(81166006)(71200400001)(316002)(305945005)(3846002)(6512007)(6506007)(229853002)(4001150100001)(6486002)(8676002)(5660300001)(97736004)(93886005)(6116002)(76176011)(106356001)(118296001)(36756003)(99286004)(486006)(11346002)(2616005)(26005)(2351001)(476003)(4326008)(2906002)(478600001)(14454004)(86362001)(446003)(25786009)(105586002)(39060400002)(186003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2349;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: G54igMUeEVIjS26Aq15lxEkwLAtmKqC1T1GVdc9vc2p6OnnBHjjD+Arivqv22PjTAs0S2jCCWaKjcFidZ3coIVHahMZoVzK9hbgw/0ptQivheDpcowhIvyHvYHGu237K0Hh7davH1beSnsqLmbZN4fk+RW51n1sPwlwU73r86VbHtBUT9dzDMy0mJCTuy+s9UPSZMxgWJvt4sA0+fiSNOtmNPuvVQ1kLYsDgLVDuS3LT57rl7JmkCsrefxk3bgeBNjVROa+nmB7pSF+sazkqGtgNpm/8+bAZFkUsNEVLpm2uZZzRBeqKqDwFV7Fu6OVmyvNO0DobfLGe0aXo4NM2dOkNuO551Rq/mD4fUoHCbzk=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <BE3FD71AF50CAC4FABF3F4DDDAF6C14E@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 05cc0835-9a53-43d1-9113-08d648fc2aed
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Nov 2018 00:08:40.7163
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2349
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE4LTExLTEyIGF0IDE2OjAwIC0wODAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBOb3YgMTIsIDIwMTgsIGF0IDM6NTcgUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+ID4gT24gTW9uLCAyMDE4LTEx
LTEyIGF0IDE4OjAxIC0wNTAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3cm90ZToNCj4gPiA+ID4g
T24gTW9uLCBOb3YgMTIsIDIwMTggYXQgMDk6MTc6MTZQTSArMDAwMCwgVHJvbmQgTXlrbGVidXN0
DQo+ID4gPiA+IHdyb3RlOg0KPiA+ID4gPiA+IE9uIE1vbiwgMjAxOC0xMS0xMiBhdCAxMzoyNCAt
MDUwMCwgYmZpZWxkc0BmaWVsZHNlcy5vcmcNCj4gPiA+ID4gPiB3cm90ZToNCj4gPiA+ID4gPiA+
IE9uIE1vbiwgTm92IDEyLCAyMDE4IGF0IDA1OjU5OjMzUE0gKzAwMDAsIFRyb25kIE15a2xlYnVz
dA0KPiA+ID4gPiA+ID4gd3JvdGU6DQo+ID4gPiA+ID4gPiA+IE9uIFNhdCwgMjAxOC0xMS0xMCBh
dCAxNjo0OSAtMDUwMCwgQnJ1Y2UgRmllbGRzIHdyb3RlOg0KPiA+ID4gPiA+ID4gPiBMb29rcyBs
aWtlIGl0J3MgdGhlIGZhdWx0IG9mDQo+ID4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gPiAwN2Qw
MmE2N2I3ZmFhZSAiU1VOUlBDOiBTaW1wbGlmeSBsb29rdXAgY29kZSINCj4gPiA+ID4gPiA+IA0K
PiA+ID4gPiA+ID4gSSdtIGhhdmluZyB0cm91YmxlIHJlcHJvZHVjaW5nIHRoaXMgYnVnLiBJJ3Zl
IHRyaWVkIGJvdGgNCj4gPiA+ID4gPiA+IGN0aG9uDQo+ID4gPiA+ID4gPiBhbmQNCj4gPiA+ID4g
PiA+IHhmc3Rlc3RzIGluIGEgbG9vcCwgc28gZmFyIHdpdGhvdXQgc3VjY2VzcyAoYm90aCBORlN2
MyBhbmQNCj4gPiA+ID4gPiA+IHY0LjEsDQo+ID4gPiA+ID4gPiBidXQNCj4gPiA+ID4gPiA+IG9u
bHkgc2VjPXN5cykuIElzIHRoZXJlIGFueXRoaW5nIGVsc2UgeW91J3JlIGRvaW5nIHRoYXQgSQ0K
PiA+ID4gPiA+ID4gbWlnaHQNCj4gPiA+ID4gPiA+IHRyeT8NCj4gPiA+ID4gPiA+IA0KPiA+ID4g
PiA+ID4gZS5nLiBBcmUgeW91IHJ1bm5pbmcgbXVsdGlwbGUgd29ya2xvYWRzIGluIHBhcmFsbGVs
Pw0KPiA+ID4gPiA+ID4gRGlmZmVyZW50DQo+ID4gPiA+ID4gPiB1c2Vycz8uLg0KPiA+ID4gPiA+
IA0KPiA+ID4gPiA+IE5vdGhpbmcgdGhhdCBpbnRlcmVzdGluZy4gIEN1cnJlbnRseSBpdCdzIGNv
bm5lY3RhdGhvbiBvdmVyDQo+ID4gPiA+ID4gdjQsDQo+ID4gPiA+ID4gdjMsDQo+ID4gPiA+ID4g
djQva3JiNSwgdjMva3JiNSwgdjQva3JiNWksIHY0L2tyYjVwLCB2NC4xLCB2NC4xL2tyYjUsIGJ1
dA0KPiA+ID4gPiA+IGp1c3QNCj4gPiA+ID4gPiBzZXJpYWxseQ0KPiA+ID4gPiA+IG9uZSBhZnRl
ciB0aGUgb3RoZXIuICBUaGVuIHNvbWUgcHluZnMgdGVzdHMgKHdoaWNoIGJ5cGFzcyB0aGUNCj4g
PiA+ID4gPiBjbGllbnQpLA0KPiA+ID4gPiA+IHRoZW4geGZzdGVzdHMgb3ZlciB2NC4yL3N5cy4g
IEFuZCBhbHNvIGEgZmV3IG9uZS1vZmYgbG9ja2luZw0KPiA+ID4gPiA+IHRlc3RzIG9mDQo+ID4g
PiA+ID4gbXkNCj4gPiA+ID4gPiBvd24gdGhhdCBwcm9iYWJseSBhcmVuJ3QgYSBmYWN0b3IgaGVy
ZS4NCj4gPiA+ID4gPiANCj4gPiA+ID4gPiAoSGFoLCBJIGp1c3QgcmVhbGl6ZWQgSSB3YXMgbW91
bnRpbmcgd2l0aCB2ZXJzPTQgYW5kIGFzc3VtaW5nDQo+ID4gPiA+ID4gdGhhdA0KPiA+ID4gPiA+
IG1lYW50DQo+ID4gPiA+ID4gNC4wLCBidXQgYWN0dWFsbHkgaXQncyBjaGFuZ2VkIG92ZXIgdGlt
ZSBkZXBlbmRpbmcgb24gdGhlDQo+ID4gPiA+ID4gZGVmYXVsdHMsDQo+ID4gPiA+ID4gc28NCj4g
PiA+ID4gPiBjdXJyZW50bHkgdGhvc2UgInY0IiBydW5zIGFyZSBhY3R1YWxseSBhbGwgNC4yLiAg
R2FoLikNCj4gPiA+ID4gDQo+ID4gPiA+IEFyZSB5b3UgcGVyaGFwcyBib3RoIHVzaW5nIFJQQ1NF
Q19HU1Mgdy8gaW50ZWdyaXR5IGNoZWNraW5nIGZvcg0KPiA+ID4gPiB5b3VyDQo+ID4gPiA+IEVY
Q0hBTkdFX0lEIGF1dGhlbnRpY2F0aW9uPyBUaGUgY2xpZW50IHdpbGwgYXR0ZW1wdCB0byB1c2Ug
dGhhdA0KPiA+ID4gPiBieQ0KPiA+ID4gPiBkZWZhdWx0IGlmIHJwYy5nc3NkIGlzIHJ1bm5pbmcu
DQo+ID4gPiANCj4gPiA+IFllcywgaW4gYWRkaXRpb24gdG8gdGhlIGtyYjVpIG1vdW50IEknZCBl
eHBlY3QgdGhlIHN5cy9rcmI1L2tyYjVwDQo+ID4gPiBtb3VudHMNCj4gPiA+IGFyZSB1c2luZyBr
cmI1aSBmb3IgRVhDSEFOR0VfSUQuDQo+ID4gPiANCj4gPiA+ID4gSSBhc2sgYmVjYXVzZSBJIHRo
aW5rIHRoZSBpc3N1ZSBtaWdodCBiZSB3aXRoIFJQQ1NFQ19HU1MsDQo+ID4gPiA+IHNwZWNpZmlj
YWxseQ0KPiA+ID4gPiB3aXRoIHRoZSBSUENTRUNfR1NTIGNvbnRleHQgZGVzdHJveSBjb2RlLCBo
ZW5jZSB0aGUgMiBwYXRjaGVzDQo+ID4gPiA+IHRoYXQNCj4gPiA+ID4gSQ0KPiA+ID4gPiBqdXN0
IHNlbnQgb3V0Lg0KPiA+ID4gDQo+ID4gPiBMb29rcyBsaWtlIG15IHRlc3RzIHBhc3MgYWZ0ZXIg
YXBwbHlpbmcgdGhvc2UgdHdvIHBhdGNoZXMuDQo+ID4gPiANCj4gPiANCj4gPiBDb29sISBUaGFu
a3MgZm9yIHRlc3RpbmcuDQo+ID4gDQo+ID4gQ2h1Y2ssIGRvIHlvdSB0aGluayB0aGUgYWJvdmUg
bWlnaHQgYWxzbyBleHBsYWluIHlvdXIgc2lnaHRpbmcgb2YNCj4gPiB0aGUNCj4gPiBzYW1lIE9v
cHM/DQo+IA0KPiBDb3VsZCBiZSwgSSBkb27igJl0IHRoaW5rIEkgc2F3IGl0IHVudGlsIEkgc3Rh
cnRlZCB0ZXN0aW5nIE5GU3Y0Lg0KPiBJIHdvbuKAmXQgYmUgYWJsZSB0byBjb25maXJtIHRoYXQg
dW50aWwgbmV4dCB3ZWVrLg0KPiANCg0KT0suIEVpdGhlciB3YXksIEkga25vdyB0aGF0IHBhcnQg
b2YgdGhlIEdTUyBjb2RlIG5lZWRzIHRvIGJlIGZpeGVkIGluDQpvcmRlciB0byBkZWFsIHdpdGgg
dGhlIHJlZmVyZW5jZSBjb3VudCBiZWluZyAwLCBzbyBJIHRoaW5rIGl0IGlzIHdvcnRoDQptZXJn
aW5nIHRoaXMgcGF0Y2ggbm93LCBhbmQgdGhlbiB3ZSBjYW4gc2VlIGlmIHRoZXJlIGlzIG1vcmUg
dG8gdGhlDQpyZWdyZXNzaW9uIHdoZW4geW91IGNhbiBnZXQgYmFjayB0byB5b3VyIHRlc3Qgcmln
Lg0KDQpUaGFua3MNCiAgVHJvbmQNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2Uu
Y29tDQoNCg0K
