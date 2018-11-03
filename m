Return-Path: <SRS0=m0hb=NO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44633C0044C
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Nov 2018 03:27:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9FF5A2081F
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Nov 2018 03:27:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Fnz88vKL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FF5A2081F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726064AbeKCMhE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Nov 2018 08:37:04 -0400
Received: from mail-dm3nam03on0094.outbound.protection.outlook.com ([104.47.41.94]:38784
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726051AbeKCMhE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 3 Nov 2018 08:37:04 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9vPkAXU242kVD+tOUGPjdYrIX044yKrnszSrl8UrOdQ=;
 b=Fnz88vKLo93SvOAs6CCuVN63AZDgMdmdD3i3Sdd9+2Hr+6NC4eStV6aEr77NZlplilJctw+2kytaUOyqKHAoJJsIMFmX32QUyMcsTmUGQYg7p7isvVDUMYiPmBiCVFNS5zYqqWVqjJY3rKCkgnxDmfSBjhi/08OXn5LbPQBpXMM=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2318.namprd13.prod.outlook.com (52.135.94.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.12; Sat, 3 Nov 2018 03:27:11 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1294.024; Sat, 3 Nov 2018
 03:27:10 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "eshel@us.ibm.com" <eshel@us.ibm.com>
CC:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "mbenjami@redhat.com" <mbenjami@redhat.com>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "malahal@gmail.com" <malahal@gmail.com>
Subject: Re: "(deleted)" directories
Thread-Topic: "(deleted)" directories
Thread-Index: AQHUcmyqhAuTrD/t40CG05LKPmMcxKU8UwcAgABQ1ACAAEv8gIAAHDsAgAAjx4CAACfkgIAADZwA
Date:   Sat, 3 Nov 2018 03:27:10 +0000
Message-ID: <6416528545ec801c93e9baadc46216ed989ae464.camel@hammerspace.com>
References: <CAGD+tkyTyOb-iiykQLYMoa1h5cmizbe_0M0_HS=9cQC1NDznSw@mail.gmail.com>
         <24BEBD2F-BCC2-4AE0-81D7-185D6CAB8CD7@redhat.com>
         <CAGD+tkzyDoq6tdseFQu4ymJCc-+-2i6XEUmBGKe4mu4_ngv7QA@mail.gmail.com>
         <435a5a0fcdbefc30201c91b0a36b6159f6df32eb.camel@hammerspace.com>
         <CAKOnarkG4tpA7F306hgpk14XNELEFY1gaY7=QY4h6Dr-zSQzRw@mail.gmail.com>
         <a45a428ad45e5834fa7030088a75275584b13ab2.camel@hammerspace.com>
         <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com>
In-Reply-To: <OF63D29519.B9156C69-ON8825833A.000DEE9B-8825833A.000E8123@notes.na.collabserv.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2318;6:sDwjSCqJaGZLoD4UW1sJROTCWldLry0l3ThbQh2sKwXx8KGm0rFKtPbOZq7mXcK1PQKqgxMAtspa4ZaUixJNFSp585y7lzxQGQCnCeCoofZc6OzSzrYInRiSR2sDAsCwxf/oKYnRv6sL4t71QbPuw2kg3HPzQZeN3qzF1gcYjpN8Mf23GwJb4CUW+FaxO9b1ApvF1EapDqnzWnXquGTIEwoOstx3wzd33v3OUzniOWf1z3galsOMfVN+wtUnc0IxamrZ7oYGyPE0H90QPGMUnyVaZ70rM5j5WgJL3Ch5ypyDUPRxQPLz0eC7Vqus/TofDMGMiOLt6QLlSa5bn1LGvuMYn2C+5vi6gd/toV7/sEiaLHpNr1XYlTjDYuUmT3iNp3sVIdCt7iayhaoD+uuh9Tlt5KIhaVLAG8b9zbU6dS9j4vudTdxHSFHLhJ4sbExXFXSeUD/la4y5kG29zKrtxA==;5:Non5iTVvtM1qdFWPFVldqT6Mcca2D/M1t67lIfVYgPUjqKsDnLma7+IenwcYB6jD55gB36k3MRtsns1YWI6ImPxTg2F1/xMJ5mFcWFOGPhV1JPjCSNLmjmF0x9CP7Wq5JKs2R8szrUnClLemvzPWoA6VWcUfXeNZokPOiuMXHHU=;7:QCS4DQlq8BcM3fBxv4seaMoyDwn4ESm4gjvh5XH7SutEF6VYXrcQgj/d4MkJ3D97mL6vrvjApK0mBK4W22pYaJO6fbAb/xbRTt/XdwSojeu1qwB9T/7hNTHk39hrKaOPLeLNxVRCLa5CZmjVSR1piA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: f5050016-03d1-43bb-2161-08d6413c3da8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2318;
x-ms-traffictypediagnostic: SN6PR13MB2318:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2318C62CCEF52AAB6A33ED78B8C80@SN6PR13MB2318.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:(9452136761055)(85827821059158)(158342451672863)(20558992708506);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(93006095)(93001095)(10201501046)(3002001)(3231382)(944501410)(52105095)(148016)(149066)(150057)(6041310)(20161123564045)(20161123560045)(20161123562045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2318;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2318;
x-forefront-prvs: 08457955C4
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(376002)(366004)(396003)(346002)(39830400003)(53754006)(199004)(189003)(93886005)(36756003)(6916009)(53936002)(7736002)(305945005)(25786009)(8676002)(102836004)(6436002)(81156014)(446003)(2900100001)(2616005)(8936002)(81166006)(11346002)(26005)(1730700003)(6512007)(76176011)(5640700003)(66066001)(105586002)(15974865002)(5660300001)(2906002)(106356001)(316002)(2351001)(68736007)(118296001)(99286004)(6246003)(478600001)(186003)(14454004)(54906003)(6506007)(229853002)(71190400001)(53546011)(486006)(3846002)(6486002)(2501003)(97736004)(256004)(6116002)(4326008)(14444005)(39060400002)(575784001)(86362001)(71200400001)(476003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2318;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: rC9tDGbIxvuNHC71w6bgTGQfdC9EzOZQWNb8BtKQTQnvyzCyxwtR1tlPxi17j/5ei8mv/nxJhLBCPaaNMTVZhvkBcAO3Zz+g9PGjcXiJosBPn7yvDTLzOBRXET3Qe8FJ+wm4ZAE3OBz/MiNlx0ivN1/6YA5/ekBEhHrHLj6G6S/pDUhaSf1/xn8ExVHlLpcKUeftO+sETPbr2qvMKENzkKaElj2r7Mtb1YjZwlOyOHY0ymKjKoH76uTS8btSEYsL0g6B8c9vWdkqFImJddHslpgFFjneKWOvyc5u9iT5oHEFzOFkDdAxa9VPXBbp1ClskWbfYeGwXyS0vePzvzqfCZb/007LpwxtYkGcnm/js9s=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <65D19E060A2BAA4F87D5FE196A41603C@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f5050016-03d1-43bb-2161-08d6413c3da8
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Nov 2018 03:27:10.6584
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2318
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTAyIGF0IDE4OjM4IC0wODAwLCBNYXJjIEVzaGVsIHdyb3RlOg0KPiBP
bmUgcmVhc29uIHRvIGhhdmUgZGlmZmVyZW50IEZIcyBmb3IgdGhlIHNhbWUgZmlsZSBpcyB0aGF0
IGEgZmlsZSBjYW4NCj4gYmUgDQo+IGxpbmtlZCBmcm9tIG11bHRpcGxlIGRpcmVjdG9yaWVzLg0K
PiBBZGRpbmcgdGhlIHBhcmVudCBpbm9kZSB0byB0aGUgRkggaGVscCBmaW5kaW5nIHRoZSB0aGUg
bmFtZSBvZiB0aGUNCj4gZmlsZSBieSANCj4gbG9va2luZyBmb3IgdGhlIGZpbGUgaW5vZGUgaW4N
Cj4gdGhlIHBhcmVudCBkaXJlY3RveS4NCj4gDQoNCk5vLi4uIFdlJ3ZlIGJlZW4gdGhlcmUgYW5k
IGRvbmUgdGhhdC4gRW5jb2RpbmcgcGFyZW50IGRpcmVjdG9yaWVzIGluDQp0aGUgZmlsZWhhbmRs
ZSBicmVha3MgcmVuYW1lLCB1bmxpbmssIGFuZCBtYWtlcyBpdCBhIHBhaW4gdG8gcmVjb3Zlcg0K
c3RhdGUuDQpUaGVyZSBpcyBubyB3YXkgaW4gaGVsbCB3ZSdyZSBnb2luZyB0byBjb21taXQgdG8g
c3VwcG9ydCB0aGF0IG1vZGVsLg0KDQo+IE1hcmMuDQo+IA0KPiBsaW51eC1uZnMtb3duZXJAdmdl
ci5rZXJuZWwub3JnIHdyb3RlIG9uIDExLzAyLzIwMTggMDU6MTU6NDIgUE06DQo+IA0KPiA+IEZy
b206IFRyb25kIE15a2xlYnVzdCA8dHJvbmRteUBoYW1tZXJzcGFjZS5jb20+DQo+ID4gVG86ICJt
YmVuamFtaUByZWRoYXQuY29tIiA8bWJlbmphbWlAcmVkaGF0LmNvbT4NCj4gPiBDYzogImJjb2Rk
aW5nQHJlZGhhdC5jb20iIDxiY29kZGluZ0ByZWRoYXQuY29tPiwgIm1hbGFoYWxAZ21haWwuY29t
DQo+ID4gIg0KPiA+IDxtYWxhaGFsQGdtYWlsLmNvbT4sICJsaW51eC1uZnNAdmdlci5rZXJuZWwu
b3JnIiANCj4gPGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+DQo+ID4gRGF0ZTogMTEvMDIvMjAx
OCAwNToxNSBQTQ0KPiA+IFN1YmplY3Q6IFJlOiAiKGRlbGV0ZWQpIiBkaXJlY3Rvcmllcw0KPiA+
IFNlbnQgYnk6IGxpbnV4LW5mcy1vd25lckB2Z2VyLmtlcm5lbC5vcmcNCj4gPiANCj4gPiBPbiBG
cmksIDIwMTgtMTEtMDIgYXQgMTg6MDcgLTA0MDAsIE1hdHQgQmVuamFtaW4gd3JvdGU6DQo+ID4g
PiBJdCBzb3VuZHMgbGlrZSBhIHByZXR0eSBnb29kIG9uZSwgdGhhdCBnb2VzIHRvIHRoZSBoZWFy
dCBvZiB3aGF0DQo+ID4gPiBhDQo+ID4gPiBzcGVjaWZpY2F0aW9uIGlzDQo+ID4gPiANCj4gPiAN
Cj4gPiBXaGlsZSBhZG1pdHRlZGx5IGl0IGlzIChzdGlsbCkgRGlhIGRlIGxvcyBNdWVydG9zIHRv
ZGF5LCBJIHdvdWxkDQo+ID4gdGhpbmsNCj4gPiB0aGF0IHNvbWVvbmUgd2hvIHJlc3VycmVjdGVk
IGEgcGFydCBvZiB0aGUgTkZTdjMgc3BlYyB0aGF0IGhhcyBiZWVuDQo+ID4gdW51c2VkIGZvciB0
aGUgZnVsbCAyMyB5ZWFycyBvZiBpdHMgZXhpc3RlbmNlIG1pZ2h0IGhhdmUgc29tZQ0KPiA+IGV4
cGxhbmF0aW9uIGZvciB3aHkgdGhleSBkaWQgc28/DQo+ID4gDQo+ID4gSU9XOiBub3QgYmVpbmcg
b2YgYSBwYXJ0aWN1bGFybHkgcmVsaWdpb3VzIHBlcnN1YXNpb24sIEkgdXN1YWxseQ0KPiA+IHdh
bnQNCj4gPiB0byB1bmRlcnN0YW5kIHdoeSBmZWF0dXJlcyBhcmUgbmVlZGVkIHJhdGhlciB0aGFu
IGhhdmluZyBibGluZA0KPiA+IGZhaXRoIGluDQo+ID4gdGhlIHBlcnNvbiB3aG8gd3JvdGUgdGhl
IHNwZWMuDQo+ID4gDQo+ID4gPiBNYXR0DQo+ID4gPiANCj4gPiA+IE9uIEZyaSwgTm92IDIsIDIw
MTggYXQgNDoyNiBQTSwgVHJvbmQgTXlrbGVidXN0IDwNCj4gPiA+IHRyb25kbXlAaGFtbWVyc3Bh
Y2UuY29tPiB3cm90ZToNCj4gPiA+ID4gT24gRnJpLCAyMDE4LTExLTAyIGF0IDIxOjI0ICswNTMw
LCBNYWxhaGFsIE5haW5lbmkgd3JvdGU6DQo+ID4gPiA+ID4gQmVuLCBORlN2MyBSRkMxODEzLnR4
dCBzdGF0ZXM6ICJJZiB0d28gZmlsZSBoYW5kbGVzIGZyb20gdGhlDQo+ID4gPiA+ID4gc2FtZQ0K
PiA+ID4gPiA+IHNlcnZlciBhcmUgZXF1YWwsIHRoZXkgbXVzdCByZWZlciB0byB0aGUgc2FtZSBm
aWxlLCBidXQgaWYNCj4gPiA+ID4gPiB0aGV5ICBhcmUNCj4gPiA+ID4gPiBub3QgZXF1YWwsIG5v
IGNvbmNsdXNpb25zIGNhbiBiZSBkcmF3bi4iIEdhbmVzaGEgZG9lcyByZXR1cm4NCj4gPiA+ID4g
PiBzYW1lDQo+ID4gPiA+ID4gZmlsZWlkIGhlcmUgKGlub2RlKS4NCj4gPiA+ID4gPiANCj4gPiA+
ID4gPiBJbiBORlN2NCwgdGhleSBoYXZlIGludHJvZHVjZWQgInVuaXF1ZV9oYW5kbGVzIiBhdHRy
aWJ1dGUuIEkNCj4gPiA+ID4gPiBkb24ndA0KPiA+ID4gPiA+IHNlZQ0KPiA+ID4gPiA+IExpbnV4
IE5GUyBjbGllbnQgdXNpbmcgdGhpcyBhdCBhbGwgdGhvdWdoLg0KPiA+ID4gPiANCj4gPiA+ID4g
V2h5IGRvZXMgeW91ciBzZXJ2ZXIgbmVlZCB0byBoYXZlIG11bHRpcGxlIGZpbGVoYW5kbGVzIHJl
ZmVyIHRvDQo+ID4gPiA+IHRoZQ0KPiA+ID4gPiBzYW1lIGZpbGUsIGFuZCB3aHkgZG8geW91IGV4
cGVjdCBjbGllbnRzIHRvIHN1cHBvcnQgdGhpcz8NCj4gPiA+ID4gDQo+ID4gPiA+IFllcywgdGhl
IHNwZWMgYWxsb3dzIGl0LCBidXQgdGhhdCdzIG5vdCBhIHN1ZmZpY2llbnQgcmVhc29uLg0KPiA+
ID4gPiANCj4gPiA+ID4gPiBSZWdhcmRzLCBNYWxhaGFsLg0KPiA+ID4gPiA+IE9uIEZyaSwgTm92
IDIsIDIwMTggYXQgNDozNSBQTSBCZW5qYW1pbiBDb2RkaW5ndG9uIDwNCj4gPiA+ID4gPiBiY29k
ZGluZ0ByZWRoYXQuY29tPiB3cm90ZToNCj4gPiA+ID4gPiA+IE9uIDIgTm92IDIwMTgsIGF0IDE6
MjYsIE1hbGFoYWwgTmFpbmVuaSB3cm90ZToNCj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gPiBI
aSBBbGwsIHdlIGFyZSB1c2luZyBORlMtR2FuZXNoYSB3aXRoIExpbnV4IE5GUyBjbGllbnRzLg0K
PiA+ID4gPiA+ID4gPiBUaGUNCj4gPiA+ID4gPiA+ID4gY2xpZW50J3MNCj4gPiA+ID4gPiA+ID4g
c2hlbGwgcmVwb3J0cyB0aGUgZm9sbG93aW5nLiBCYXNlZCBvbiBsc29mLCB0aGUgZGlyZWN0b3J5
DQo+ID4gPiA+ID4gPiA+IGlzDQo+ID4gPiA+ID4gPiA+IG1hcmtlZA0KPiA+ID4gPiA+ID4gPiBk
ZWxldGVkLiAiY2QgdG8gUk9PVCBhbmQgY2QgdG8gdGhlIHNhbWUgaG9tZSBkaXJlY3RvcnkNCj4g
PiA+ID4gPiA+ID4gZml4ZXMNCj4gPiA+ID4gPiA+ID4gdGhlDQo+ID4gPiA+ID4gPiA+IGlzc3Vl
LiBUaGUgY2xpZW50IGJlaGF2ZXMgYXMgdGhvdWdoIHRoZSBkaXJlY3RvcnkgaXMNCj4gPiA+ID4g
PiA+ID4gZGVsZXRlZA0KPiA+ID4gPiA+ID4gPiBhbmQNCj4gPiA+ID4gPiA+ID4gcmVjcmVhdGVk
ISBPdXIgTkZTLUdhbmVzaGEgc2VydmVyIGltcGxlbWVudGF0aW9uIHVzZXMNCj4gPiA+ID4gPiA+
ID4gbXVsdGlwbGUNCj4gPiA+ID4gPiA+ID4gZmlsZQ0KPiA+ID4gPiA+ID4gPiBoYW5kbGVzIHRo
YXQgcG9pbnQgdG8gdGhlIHNhbWUgb2JqZWN0LiBORlMgc3BlYyBzYXlzIHRoaXMNCj4gPiA+ID4g
PiA+ID4gc2hvdWxkDQo+ID4gPiA+ID4gPiA+IGJlDQo+ID4gPiA+ID4gPiA+IGZpbmUsIGJ1dCBM
aW51eCBORlMgc2VlbXMgdG8gYmUgYnJva2VuIGluIHRoaXMgcmVnYXJkLg0KPiA+ID4gPiA+ID4g
PiB0Y3BkdW1wDQo+ID4gPiA+ID4gPiA+IGRvZXMNCj4gPiA+ID4gPiA+ID4gaW5kaWNhdGUgZmls
ZSBoYW5kbGUgY2hhbmdlIChub3RlIHRoYXQgYWxsIGZpbGUgaGFuZGxlcw0KPiA+ID4gPiA+ID4g
PiBhcmUNCj4gPiA+ID4gPiA+ID4gcGVybWFuZW50LA0KPiA+ID4gPiA+ID4gPiBtZWFuaW5nIHRo
ZXkgYXJlIHZhbGlkIGF0IHRoZSBzZXJ2ZXIgYW55IHRpbWUpIGFyb3VuZA0KPiA+ID4gPiA+ID4g
PiB0aGlzDQo+ID4gPiA+ID4gPiA+IGlzc3VlDQo+ID4gPiA+ID4gPiA+IHRpbWUuDQo+ID4gPiA+
ID4gPiA+IA0KPiA+ID4gPiA+ID4gPiAic2hlbGwtaW5pdDogZXJyb3IgcmV0cmlldmluZyBjdXJy
ZW50IGRpcmVjdG9yeTogZ2V0Y3dkOg0KPiA+ID4gPiA+ID4gPiBjYW5ub3QNCj4gPiA+ID4gPiA+
ID4gYWNjZXNzDQo+ID4gPiA+ID4gPiA+IHBhcmVudCBkaXJlY3RvcmllczogTm8gc3VjaCBmaWxl
IG9yIGRpcmVjdG9yeSINCj4gPiA+ID4gPiA+ID4gc2ggICAgICAgIDExMjU0NCAgICAgICAgICAg
IG1hbGFoYWwgIGN3ZCAgICAgICBESVINCj4gPiA+ID4gPiA+ID4gMCw2Nw0KPiA+ID4gPiA+ID4g
PiAgICAgIDY1NTM2ICAgNDU2MDUyMDkgL2hvbWUvbWFsYWhhbCAoZGVsZXRlZCkNCj4gPiA+ID4g
PiA+ID4gKDEwLjEyMC4xNTQuNDI6L25mcy9tYWxhaGFsLWV4cG9ydC8pDQo+ID4gPiA+ID4gPiA+
IA0KPiA+ID4gPiA+ID4gPiBGdW5jdGlvbiBuZnNfcHJpbWVfZGNhY2hlKCkgc2VlbXMgdG8gaW52
YWxpZGF0ZSB0aGUNCj4gPiA+ID4gPiA+ID4gZGNhY2hlDQo+ID4gPiA+ID4gPiA+IGVudHJ5DQo+
ID4gPiA+ID4gPiA+IGlmDQo+ID4gPiA+ID4gPiA+IG5mc19zYW1lX2ZpbGUoKSByZXR1cm5zIGZh
bHNlLiBuZnNfc2FtZV9maWxlKCkgZG9lcyBzZWVtDQo+ID4gPiA+ID4gPiA+IHRvDQo+ID4gPiA+
ID4gPiA+IHJldHVybg0KPiA+ID4gPiA+ID4gPiBmYWxzZSB3aXRoIHRoZSBmb2xsb3dpbmcgY2hh
bmdlLCBpZiBJIHJlYWQgaXQgY29ycmVjdGx5LA0KPiA+ID4gPiA+ID4gPiBpZg0KPiA+ID4gPiA+
ID4gPiB0aGVyZQ0KPiA+ID4gPiA+ID4gPiBpcyBhDQo+ID4gPiA+ID4gPiA+IGZpbGUgaGFuZGxl
IGNoYW5nZS4gQ2FuIHRoaXMgYmUgdGhlIHNvdXJjZSBvZiBteSBpc3N1ZT8NCj4gPiA+ID4gPiA+
ID4gSXQNCj4gPiA+ID4gPiA+ID4gc2VlbXMNCj4gPiA+ID4gPiA+ID4gdGhhdA0KPiA+ID4gPiA+
ID4gPiB0aGUgY2xpZW50IHNob3VsZCBkbyB0aGlzIG9ubHkgaWYgdGhlIGZpbGUgaGFuZGxlIGlz
IE5PVA0KPiA+ID4gPiA+ID4gPiB2YWxpZA0KPiA+ID4gPiA+ID4gPiAoZS5nLg0KPiA+ID4gPiA+
ID4gPiBpZiBpdCBnZXRzIEVTVEFMRSksIHJpZ2h0Pw0KPiA+ID4gPiA+ID4gPiANCj4gPiA+ID4g
PiA+ID4gVGhlIGZvbGxvd2luZyBjb21taXQgc2VlbXMgdG8gYXNzdW1lIHRoYXQgdGhlIG9iamVj
dHMgYXJlDQo+ID4gPiA+ID4gPiA+IGRpZmZlcmVudCBpZg0KPiA+ID4gPiA+ID4gPiB0aGV5IGhh
dmUgZGlmZmVyZW50IGZpbGUgaGFuZGxlcyENCj4gPiA+ID4gPiA+ID4gY29tbWl0IDdkYzcyZDVm
N2EwZWM5N2E1M2UxMjZjNDZlMmNiZDI1NjA3NTc5NTUNCj4gPiA+ID4gPiA+ID4gQXV0aG9yOiBU
cm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20+DQo+ID4gPiA+
ID4gPiA+IERhdGU6ICAgVGh1IFNlcCAyMiAxMzozODo1MiAyMDE2IC0wNDAwDQo+ID4gPiA+ID4g
PiA+IA0KPiA+ID4gPiA+ID4gPiAgICAgTkZTOiBGaXggaW5vZGUgY29ycnVwdGlvbiBpbiBuZnNf
cHJpbWVfZGNhY2hlKCkNCj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+ID4gTXkgdW5kZXJzdGFuZGlu
ZyBpcyB0aGF0IGZvciBORlN2MyB3ZSBoYXZlIHRvIGFzc3VtZSB0aGF0DQo+ID4gPiA+ID4gPiBk
aXN0aW5jdA0KPiA+ID4gPiA+ID4gZmlsZWhhbmRsZXMgYXJlIGRpc3RpbmN0IG9iamVjdHMsIGJ1
dCBtYXliZSBJJ20gd3JvbmcgYWJvdXQNCj4gPiA+ID4gPiA+IHRoaXMuDQo+ID4gPiA+ID4gPiAN
Cj4gPiA+ID4gPiA+IEZvciBORlN2NC54LCB3ZSBjYW4gZm9sbG93IHRoZSBndWlkYW5jZSBpbiBS
RkNzIDU2NjEgb3INCj4gPiA+ID4gPiA+IDc1MzANCj4gPiA+ID4gPiA+IHNlY3Rpb24gMTAuMy40
DQo+ID4gPiA+ID4gPiB0byBkZXRlcm1pbmUgaWYgdGhlIGRpZmZlcmluZyBmaWxlaGFuZGxlcyBh
cmUgdGhlIHNhbWUNCj4gPiA+ID4gPiA+IG9iamVjdCwNCj4gPiA+ID4gPiA+IHNwZWNpZmljYWxs
eQ0KPiA+ID4gPiA+ID4gdGhlIGZpbGVpZCByZWNvbW1lbmRlZCBhdHRyaWJ1dGUgbmVlZHMgdG8g
YmUNCj4gPiA+ID4gPiA+IGltcGxlbWVudGVkLiAgSXMNCj4gPiA+ID4gPiA+IEdhbmVzaGENCj4g
PiA+ID4gPiA+IHJldHVybmluZyB0aGUgc2FtZSBmaWxlaWQgZm9yIGJvdGggZmlsZWhhbmRsZXM/
DQo+ID4gPiA+ID4gPiANCj4gPiA+ID4gPiA+IEJlbg0KPiA+ID4gPiAtLQ0KPiA+ID4gPiBUcm9u
ZCBNeWtsZWJ1c3QNCj4gPiA+ID4gQ1RPLCBIYW1tZXJzcGFjZSBJbmMNCj4gPiA+ID4gNDMwMCBF
bCBDYW1pbm8gUmVhbCwgU3VpdGUgMTA1DQo+ID4gPiA+IExvcyBBbHRvcywgQ0EgOTQwMjINCj4g
PiA+ID4gd3d3LmhhbW1lci5zcGFjZQ0KPiA+ID4gPiANCj4gPiA+ID4gDQo+ID4gLS0gDQo+ID4g
VHJvbmQgTXlrbGVidXN0DQo+ID4gQ1RPLCBIYW1tZXJzcGFjZSBJbmMNCj4gPiA0MzAwIEVsIENh
bWlubyBSZWFsLCBTdWl0ZSAxMDUNCj4gPiBMb3MgQWx0b3MsIENBIDk0MDIyDQo+ID4gd3d3Lmhh
bW1lci5zcGFjZQ0KPiA+IA0KPiA+IA0KPiANCj4gDQotLSANClRyb25kIE15a2xlYnVzdA0KQ1RP
LCBIYW1tZXJzcGFjZSBJbmMNCjQzMDAgRWwgQ2FtaW5vIFJlYWwsIFN1aXRlIDEwNQ0KTG9zIEFs
dG9zLCBDQSA5NDAyMg0Kd3d3LmhhbW1lci5zcGFjZQ0KDQoNCg==
