Return-Path: <SRS0=LIrp=S3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54CD5C43218
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 16:48:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AA080206BF
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Apr 2019 16:48:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="YcQmWuZ8"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726071AbfDYQs6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Apr 2019 12:48:58 -0400
Received: from mail-eopbgr740090.outbound.protection.outlook.com ([40.107.74.90]:52960
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726020AbfDYQs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Apr 2019 12:48:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=nojZVJUBO+3EPzRsrI0mXsF14DIxHcP5wgIrEiejBuk=;
 b=YcQmWuZ8hH1WasrdOWaz4bAE/hJFw/erAdquDafbY+1S//dExTftliIzcn4/apH4eFtLJ/V4GDoOcW7kIILG90+Cd8+0+lCfRl+yBL7nBaQw2tgU2C9mtCmJsK/UvnUVYMBKLnJOjirJ1Mvgyx9EJ2U8lyCAcACPdP9QNkTpq/8=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2287.namprd13.prod.outlook.com (52.135.94.18) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1856.6; Thu, 25 Apr 2019 16:48:55 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::396d:aed6:eeb4:2511]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::396d:aed6:eeb4:2511%7]) with mapi id 15.20.1856.004; Thu, 25 Apr 2019
 16:48:55 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH 6/9] NFSv4: Convert the NFS client idmapper to use the
 container user namespace
Thread-Topic: [PATCH 6/9] NFSv4: Convert the NFS client idmapper to use the
 container user namespace
Thread-Index: AQHU+ueMW9/YXGY8FEO55fCIdOiQ4KZM8a2AgAAHtwCAAAlPgIAAEp6AgAABUQCAAAEWgA==
Date:   Thu, 25 Apr 2019 16:48:54 +0000
Message-ID: <67d3d9af243a0c4efa37c08532f5c0f5157bdb91.camel@hammerspace.com>
References: <20190424214650.4658-2-trond.myklebust@hammerspace.com>
         <20190424214650.4658-3-trond.myklebust@hammerspace.com>
         <20190424214650.4658-4-trond.myklebust@hammerspace.com>
         <20190424214650.4658-5-trond.myklebust@hammerspace.com>
         <20190424214650.4658-6-trond.myklebust@hammerspace.com>
         <20190424214650.4658-7-trond.myklebust@hammerspace.com>
         <20190425143243.GA8133@fieldses.org>
         <e94c2488d89ae13675f9931d013a3d711459ecad.camel@hammerspace.com>
         <20190425153339.GB8133@fieldses.org>
         <e3553fd56047430f171a3c285150b56d5fc69ccd.camel@hammerspace.com>
         <20190425164500.GA9015@fieldses.org>
In-Reply-To: <20190425164500.GA9015@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: f5f9fe85-a87b-488b-250e-08d6c99de787
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2287;
x-ms-traffictypediagnostic: SN6PR13MB2287:
x-microsoft-antispam-prvs: <SN6PR13MB22875317AD5FDCD190A3DBDFB83D0@SN6PR13MB2287.namprd13.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8882;
x-forefront-prvs: 0018A2705B
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(366004)(39830400003)(376002)(346002)(189003)(199004)(66476007)(66556008)(66446008)(7736002)(3846002)(6116002)(6246003)(66946007)(73956011)(76116006)(91956017)(6916009)(446003)(11346002)(256004)(64756008)(99286004)(5660300002)(6512007)(97736004)(2906002)(93886005)(305945005)(36756003)(53936002)(14454004)(86362001)(229853002)(316002)(5640700003)(71200400001)(71190400001)(6436002)(476003)(66066001)(25786009)(6486002)(486006)(2616005)(8936002)(1730700003)(81166006)(81156014)(26005)(8676002)(6506007)(478600001)(4326008)(2351001)(2501003)(54906003)(186003)(68736007)(118296001)(102836004)(76176011);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2287;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 0sd2MStjMetPyLtSrW5AIZEkDqp/ee4AIIPMd5VrDvzAJLZ+VmGju/XSegYzfyptIKagDDsnUKgDvZvv2+gHkMng/RREQw874OVMqAb20XTBX2E/mzDl+bVC+swxeJjMkj9rCxqU58GGl7lPu9hPmPNRJI03tRcEkA2J8LO7mI06zW2YN39jNpziTmWCQQ1ET7l4EjqTfVGBTMk39BoczCH/2085Iq+J6EQ8MmKI6OT6akVpZybniMSsSrdTjY5moOe52IpY0z6jxV7R6n7V5fMteJlJ10cIOVOgzNJ30a4QbuZJoldJiravXjUHf3OsVXBB6KvmREnKngAJ0W8MJNB1O7iff4uPdET3CYlN/y85sJ7QkYRwpGvIeVspanINO/47/1+kvmuhjUnO224R0gRrOdSSVmE1zbhAbthJaIw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <3A3C3DFF2625D045A6C153219EA23492@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f5f9fe85-a87b-488b-250e-08d6c99de787
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Apr 2019 16:48:54.8867
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2287
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTA0LTI1IGF0IDEyOjQ1IC0wNDAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gVGh1LCBBcHIgMjUsIDIwMTkgYXQgMDQ6NDA6MThQTSArMDAwMCwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPiA+IE9uIFRodSwgMjAxOS0wNC0yNSBhdCAxMTozMyAtMDQwMCwg
YmZpZWxkc0BmaWVsZHNlcy5vcmcgd3JvdGU6DQo+ID4gPiBPbiBUaHUsIEFwciAyNSwgMjAxOSBh
dCAwMzowMDoyMlBNICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+ID4gPiA+IFRoZSBh
c3N1bXB0aW9uIGlzIHRoYXQgaWYgeW91IGhhdmUgZW5vdWdoIHByaXZpbGVnZXMgdG8gbW91bnQg
YQ0KPiA+ID4gPiBmaWxlc3lzdGVtIHVzaW5nIHRoZSBORlMgY2xpZW50LCB0aGVuIHlvdSB3b3Vs
ZCBhbHNvIGhhdmUNCj4gPiA+ID4gZW5vdWdoDQo+ID4gPiA+IHByaXZpbGVnZXMgdG8gcnVuIGEg
dXNlcnNwYWNlIGNsaWVudCwgc28gdGhlcmUgaXMgbGl0dGxlIHBvaW50DQo+ID4gPiA+IGluDQo+
ID4gPiA+IHJlc3RyaWN0aW5nIHRoZSBORlMgY2xpZW50Lg0KPiA+ID4gPiANCj4gPiA+ID4gU28g
dGhlIGd1aWRpbmcgcHJpbmNpcGxlIGlzIHRoYXQgYSBORlMgY2xpZW50IG1vdW50IHRoYXQgaXMN
Cj4gPiA+ID4gc3RhcnRlZA0KPiA+ID4gPiBpbg0KPiA+ID4gPiBhIGNvbnRhaW5lciBzaG91bGQg
YmVoYXZlIGFzIGlmIGl0IHdlcmUgc3RhcnRlZCBieSBhIHByb2Nlc3MgaW4NCj4gPiA+ID4gYQ0K
PiA+ID4gPiAicmVhbA0KPiA+ID4gPiBWTSIuIFRoYXQgbWVhbnMgdGhhdCB0aGUgcm9vdCB1aWQv
Z2lkIGluIHRoZSBjb250YWluZXIgbWFwcyB0bw0KPiA+ID4gPiBhDQo+ID4gPiA+IHJvb3QNCj4g
PiA+ID4gdWlkL2dpZCBvbiB0aGUgd2lyZS4NCj4gPiA+ID4gRGl0dG8sIGlmIHRoZXJlIGlzIGEg
bmVlZCB0byBydW4gdGhlIGlkbWFwcGVyIGluIHRoZSBjb250YWluZXIsDQo+ID4gPiA+IHRoZW4N
Cj4gPiA+ID4gdGhlIGV4cGVjdGF0aW9uIGlzIHRoYXQgcHJvY2Vzc2VzIHJ1bm5pbmcgYXMgJ3Vz
ZXInIHdpdGggdWlkDQo+ID4gPiA+ICd1JywNCj4gPiA+ID4gd2lsbA0KPiA+ID4gPiBzZWUgdGhl
aXIgY3JlZHMgbWFwcGVkIGNvcnJlY3RseSBieSB0aGUgaWRtYXBwZXIuIEFnYWluLCB0aGF0J3MN
Cj4gPiA+ID4gd2hhdA0KPiA+ID4gPiB5b3Ugd291bGQgc2VlIGlmIHRoZSBwcm9jZXNzIHdlcmUg
cnVubmluZyBpbiBhIFZNIGluc3RlYWQgb2YgYQ0KPiA+ID4gPiBjb250YWluZXIuDQo+ID4gPiA+
IA0KPiA+ID4gPiBEb2VzIHRoYXQgYWxsIG1ha2Ugc2Vuc2U/DQo+ID4gPiANCj4gPiA+IFllcywg
dGhhbmtzIQ0KPiA+ID4gDQo+ID4gPiBJIHRob3VnaHQgdGhlcmUgd2FzIGEgcHJvYmxlbSB0aGF0
IHRoZSBpZG1hcHBlciBkZXBlbmRlZCBvbg0KPiA+ID4ga2V5cmluZyB1c2VybW9kZWhlbHBlciBj
YWxscyB0aGF0IGl0IHdhcyBoYXJkIHRvIHBhc3MgbmFtZXNwYWNlDQo+ID4gPiBpbmZvcm1hdGlv
biB0by4gIERpZCB0aGF0IGdldCBmaXhlZCBhbmQgSSBtaXNzZWQgaXQgb3Igb3IgZm9yZ290Pw0K
PiA+IA0KPiA+IE5vLCB5b3UgYXJlIGNvcnJlY3QsIGFuZCBzbyB3ZSBhc3N1bWUgdGhlIGNvbnRh
aW5lciBpcyB1c2luZw0KPiA+IHJwYy5pZG1hcGQNCj4gPiAoYW5kIHJwYy5nc3NkKSBpZiBpdCBp
cyBydW5uaW5nIE5GU3Y0IHdpdGggUlBDU0VDX0dTUy4NCj4gPiANCj4gPiBJZiB0aGUga2V5cmlu
ZyB1cGNhbGwgZ2V0cyBmaXhlZCwgdGhlbiB3ZSBtYXkgYWxsb3cgaXQgdG8gYmUgdXNlZA0KPiA+
IGluDQo+ID4gZnV0dXJlIGtlcm5lbHMuDQo+IA0KPiBPSywgZ290IGl0LiAgSXMgdGhlcmUgYW55
dGhpbmcgd2UgbG9zZSBieSB1c2luZw0KPiBpZG1hcGQ/ICAoSURNQVBfTkFNRVNaDQo+IG1pZ2h0
IGJlIGEgbGltaXRhdGlvbj8pDQoNCklETUFQX05BTUVTWiBzaG91bGQgYmUgc2V0IHRvIDEyOCBi
eSBkZWZhdWx0LCBzbyBzaG91bGQgd29yayBmb3IgbW9zdA0KY2FzZXMuIEkgZG9uJ3QgdGhpbmsg
dGhlcmUgYXJlIGFueSBmdXJ0aGVyIGxpbWl0YXRpb25zLg0KDQotLSANClRyb25kIE15a2xlYnVz
dA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVi
dXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
