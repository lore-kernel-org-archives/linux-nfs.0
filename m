Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE8C4C10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 18:07:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 828042084C
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 18:07:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="q+ow3Puj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728648AbfDHSHq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 14:07:46 -0400
Received: from mail-eopbgr730093.outbound.protection.outlook.com ([40.107.73.93]:34159
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725983AbfDHSHp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 Apr 2019 14:07:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=l0/f9CH+8w7DVvX3v7CpL1iOuPPhveWTnn5caJLHocE=;
 b=q+ow3Puj6fkrp7qAh94434nX+5lND/XlWpbyGCeUfoMduSUd4/bgpoiv1cm0x1QdVmCc4hRskYRZsrSThCNljf0qADNhwcVoig7nRLPmzmEGTd65DDpsPXo+UrKjFm9ZqXY18xCkQVyBcep+IlAO/oQF3vDfjibw4jMBf60Gi/Y=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2512.namprd13.prod.outlook.com (52.135.95.154) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.8; Mon, 8 Apr 2019 18:07:42 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Mon, 8 Apr 2019
 18:07:42 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@redhat.com" <bfields@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2] nfsd: Don't release the callback slot unless it was
 actually held
Thread-Topic: [PATCH v2] nfsd: Don't release the callback slot unless it was
 actually held
Thread-Index: AQHU68guSUpusONVv0Gu5SenJuNaWaYyZbYAgAAWdoCAABgsAA==
Date:   Mon, 8 Apr 2019 18:07:42 +0000
Message-ID: <8b39dd2556fe80970d1c43fa2225a6345f6b849c.camel@hammerspace.com>
References: <20190405155437.5545-1-trond.myklebust@hammerspace.com>
         <4bf043aa23b4230bf41fbcd5611b3baff4977f1d.camel@hammerspace.com>
         <20190408164109.GA18799@parsley.fieldses.org>
In-Reply-To: <20190408164109.GA18799@parsley.fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 470890b5-b969-4f2b-d611-08d6bc4d1829
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2512;
x-ms-traffictypediagnostic: SN6PR13MB2512:
x-microsoft-antispam-prvs: <SN6PR13MB25126148C73E573D0F23A64CB82C0@SN6PR13MB2512.namprd13.prod.outlook.com>
x-forefront-prvs: 0001227049
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(396003)(39830400003)(376002)(366004)(346002)(199004)(189003)(256004)(68736007)(106356001)(105586002)(2351001)(97736004)(305945005)(7736002)(66066001)(36756003)(8676002)(86362001)(81166006)(81156014)(8936002)(2501003)(1730700003)(71190400001)(6506007)(99286004)(5640700003)(11346002)(6436002)(5660300002)(476003)(2616005)(316002)(229853002)(6486002)(6916009)(2906002)(118296001)(486006)(478600001)(186003)(14454004)(26005)(102836004)(53936002)(6512007)(6246003)(4326008)(6116002)(25786009)(3846002)(446003)(76176011)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2512;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: eGs2tFlXbFovZgL4hLsovKl8OPxrjEOrasQeOGi8nRQlyIZC1ayV1YPXeh0pok6cZGm/z4iftGlEaoXHgBXWIZX/Q2IP4ZrGi+VSSa9ScwBGHmE2hKERKNNyKHspFmAPg3KHxL5ipwD86kDfkSm0832orZMHulmilwcbT3uUmgek4RS47lFcWLUFUr3N1aLiigs2wAOJNEq6L04aWojjpIRR9gYkME+a4e4L/HC6VNiz/i7UcwoN2h47OMmrKBBK8VJz8COr55xgSjUiUA/9GHFYX/4aigtshjJFkBVAu1MNPFuX//V0gAaKzVVBJAJMBHkEY0ETX0sZG+a6U9lgn8/UsXcGSwLX1yRTkgGT3jcx9n+tXIQy0AtOB1c2QPR5LREdsmFCbEQSb3srQeaq/tO9v6WuUmxx6rjTtjDXwpI=
Content-Type: text/plain; charset="utf-8"
Content-ID: <5001D82FCFDC8147A95365868CC65E72@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 470890b5-b969-4f2b-d611-08d6bc4d1829
X-MS-Exchange-CrossTenant-originalarrivaltime: 08 Apr 2019 18:07:42.1591
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2512
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTA0LTA4IGF0IDEyOjQxIC0wNDAwLCBKLiBCcnVjZSBGaWVsZHMgd3JvdGU6
DQo+IE9uIE1vbiwgQXByIDA4LCAyMDE5IGF0IDAzOjIwOjQ4UE0gKzAwMDAsIFRyb25kIE15a2xl
YnVzdCB3cm90ZToNCj4gPiBPbiBGcmksIDIwMTktMDQtMDUgYXQgMDg6NTQgLTA3MDAsIFRyb25k
IE15a2xlYnVzdCB3cm90ZToNCj4gPiA+IElmIHRoZXJlIGFyZSBtdWx0aXBsZSBjYWxsYmFja3Mg
cXVldWVkLCB3YWl0aW5nIGZvciB0aGUgY2FsbGJhY2sNCj4gPiA+IHNsb3Qgd2hlbiB0aGUgY2Fs
bGJhY2sgZ2V0cyBzaHV0IGRvd24sIHRoZW4gdGhleSBhbGwgY3VycmVudGx5DQo+ID4gPiBlbmQg
dXAgYWN0aW5nIGFzIGlmIHRoZXkgaG9sZCB0aGUgc2xvdCwgYW5kIGNhbGwNCj4gPiA+IG5mc2Q0
X2NiX3NlcXVlbmNlX2RvbmUoKSByZXN1bHRpbmcgaW4gaW50ZXJlc3Rpbmcgc2lkZS1lZmZlY3Rz
Lg0KPiA+ID4gDQo+ID4gPiBJbiBhZGRpdGlvbiwgdGhlICdyZXRyeV9ub3dhaXQnIHBhdGggaW4g
bmZzZDRfY2Jfc2VxdWVuY2VfZG9uZSgpDQo+ID4gPiBjYXVzZXMgYSBsb29wIGJhY2sgdG8gbmZz
ZDRfY2JfcHJlcGFyZSgpIHdpdGhvdXQgZmlyc3QgZnJlZWluZw0KPiA+ID4gdGhlDQo+ID4gPiBz
bG90LCB3aGljaCBjYXVzZXMgYSBkZWFkbG9jayB3aGVuIG5mc2Q0MV9jYl9nZXRfc2xvdCgpIGdl
dHMNCj4gPiA+IGNhbGxlZA0KPiA+ID4gYSBzZWNvbmQgdGltZS4NCj4gPiA+IA0KPiA+ID4gVGhp
cyBwYXRjaCB0aGVyZWZvcmUgYWRkcyBhIGJvb2xlYW4gdG8gdHJhY2sgd2hldGhlciBvciBub3Qg
dGhlDQo+ID4gPiBjYWxsYmFjayBkaWQgcGljayB1cCB0aGUgc2xvdCwgc28gdGhhdCBpdCBjYW4g
ZG8gdGhlIHJpZ2h0IHRoaW5nDQo+ID4gPiBpbiB0aGVzZSAyIGNhc2VzLg0KPiA+ID4gDQo+ID4g
PiBTaWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBoYW1tZXJz
cGFjZS5jb20+DQo+ID4gPiAtLS0NCj4gPiA+IHYyOiB0cnkgdG8gcmVzdGFydCB0aGUgY2FsbGJh
Y2sgaWYgd2UgaGl0DQo+ID4gPiBuZnNkNF9jYl9zZXF1ZW5jZV9kb25lKCkNCj4gPiA+ICAgICB3
aXRob3V0IGEgc2xvdC4NCj4gPiA+IA0KPiA+ID4gDQo+ID4gDQo+ID4gSGkgQnJ1Y2UsDQo+ID4g
DQo+ID4gU2hvdWxkIHRoaXMgcGF0Y2ggcGVyaGFwcyBiZSBjb25zaWRlcmVkIGZvciBzdGFibGU/
IFRoZSBjYWxsYmFjaw0KPiA+IHNsb3QNCj4gPiBsZWFrIGlzIHBlcm1hbmVudCAob3IgYXQgbGVh
c3QgZm9yIHRoZSBsaWZldGltZSBvZiB0aGUNCj4gPiBuZnM0X2NsaWVudCkuDQo+IA0KPiBNYWtl
cyBzZW5zZSB0byBtZTsgSSdsbCBxdWV1ZSBpdCB1cCBmb3IgNS4xIGFuZCBzdGFibGUuDQo+IA0K
PiBXaGF0IHdlcmUgdGhlIG9yaWdpbmFsIHN5bXB0b21zIHRoYXQgcHJvbXB0ZWQgdGhpcz8NCj4g
DQoNCldlIHdlcmUgdXNpbmcgdGhlIE5GU3Y0LjIgY2xpZW50IGZvciBkb2luZyBDTE9ORSBhZ2Fp
bnN0IGEga25mc2QNCnNlcnZlciwgYW5kIGV2ZW50dWFsbHkgZW5kZWQgdXAgd2l0aCBhIGJ1bmNo
IG9mIENCX1JFQ0FMTCByZXF1ZXN0cyB0aGF0DQp3ZXJlIHNlZW4gaGFuZ2luZyBmb3JldmVyIG9u
IHRoZSBzZXJ2ZXIuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoN
Cg0K
