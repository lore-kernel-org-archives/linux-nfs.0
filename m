Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D9A8C282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 21:40:58 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1BA332083B
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 21:40:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="GMFW0a67"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726960AbfBDVk5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 16:40:57 -0500
Received: from mail-eopbgr710094.outbound.protection.outlook.com ([40.107.71.94]:6064
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726965AbfBDVkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Feb 2019 16:40:55 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=i3LwHBrwszwtjhvegFV8FXqdLRI/SnBTCmbqezn6yio=;
 b=GMFW0a67SEaLcB3d+ZuY4CHXJpmEXGDvkdyckwO1p0wriMvTMQaStQ1rF8mTFVdbzjpe5a3wJ+GGuN5BO7YINVM49pBUEF2k+5hll9jjClq4D/kTLtROYQ2CoVVlhflWqtxV4Plc0cnQMexZ8EXxpmn+p3op+VyueTHiqletKTA=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2544.namprd13.prod.outlook.com (52.135.96.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.8; Mon, 4 Feb 2019 21:40:48 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0%3]) with mapi id 15.20.1601.016; Mon, 4 Feb 2019
 21:40:48 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bcodding@redhat.com" <bcodding@redhat.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Don't use page_file_mapping after removing the page
Thread-Topic: [PATCH] NFS: Don't use page_file_mapping after removing the page
Thread-Index: AQHUvLVOMBU/aGgFlEWHK7NYEV9MQ6XP9oWAgAAImACAAAExAIAAA6qAgAATuoCAABNwgA==
Date:   Mon, 4 Feb 2019 21:40:48 +0000
Message-ID: <602aa0cc867676254cf09d6e329eb6a8f7345920.camel@hammerspace.com>
References: <b85247642d77ea12153d042a4dce85b94d7624ca.1549303962.git.bcodding@redhat.com>
         <c525031691d77cff46adc30dc16bf1d19fb46900.camel@hammerspace.com>
         <22D43CDC-BB14-4C8F-A10E-DF7816EBF0B0@redhat.com>
         <C1BFD544-69A6-4AE4-87EA-2C711C6ABB3B@redhat.com>
         <9857F7D4-FA2E-43D0-8D4B-4C753A81687C@redhat.com>
         <628931F4-B625-4430-96FF-268CF926934A@redhat.com>
In-Reply-To: <628931F4-B625-4430-96FF-268CF926934A@redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2544;6:8r2DKxTluVIQSQXQUu2WY0toIvtC6Pqg+OS4tbgEoyenEyLczsNSlt2UwFuZLQX3GsM5/DQMTQgTlqPzkA6IC94TpCFDfrK6DpNrPg1G5N4s6CS75ncORiT+wx3Pe6wsW7aaSBdYAzS/D0IJ9T1BtyKCZSsmRHeqL2DZW88/UJ+hlYLBFZxZz3OnG4lIAt3mx5nXV73qzrHM7m94s3mRkRdrltVt1ZmUUf6JtbieB3+r9f1EqHKRuRojPDMf2R7NrxZAxqsp2vQw6oTbTHcYnKZBe8jENgFwg3CBcMBEZ/1Mz4YBwX0mzmRtujzoKxovD13rOOmufsczOK8iJgnYkbcfblwA0MGHQFKo5pUcZrVoWGck+vBSYngA4N3imNyJBSVkZ/iIPJVLwHPW9BDdWO2iGeRo7edNAlSwJOIX6ACWyUxl8BOPo+qdxnj2Iztg8vHcg/dTaje4EBLGXqYrjg==;5:+voq8xiGzo8637kBjEW076rtCXgojSzJOPbIlvg6MbkEJZwHIy4h4ykS73+3M2pxfoICspNz3khCbu8plG+MQW50Bjv3NAEzGKGI8eOrLyO0j0eIZr6TEVd6ak/0qMMXOcFS2i59VVXKWQAzhqTcFCcaE1F5aWRMtnHjqF3UNwXB2I/h9xdiKbTomNt6VTi3A0iLbl4vDYOUz4VV7LXbXw==;7:P1NHQN78uR102tkzRSaHVAn4V/0gb3yk1gAyOeBhuwwNx4BwG62THTpIUaPe+ZjZS49VwidDO5d9z9o8BH1kjnvLHym94Ef4rUBw2qJL94LU0U5VnfLICgJn33o7JJ4rBCi4RnzAS4KJ1m1NeDkTxA==
x-ms-office365-filtering-correlation-id: 41895477-79cd-49d5-16e8-08d68ae96d3b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(7021145)(8989299)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2544;
x-ms-traffictypediagnostic: SN6PR13MB2544:
x-microsoft-antispam-prvs: <SN6PR13MB25448F2E169492908138432AB86D0@SN6PR13MB2544.namprd13.prod.outlook.com>
x-forefront-prvs: 0938781D02
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(396003)(136003)(39830400003)(346002)(366004)(189003)(199004)(54906003)(4326008)(53546011)(446003)(11346002)(2906002)(3846002)(316002)(6486002)(2616005)(6116002)(476003)(6916009)(486006)(14444005)(2351001)(76176011)(106356001)(305945005)(66066001)(256004)(186003)(105586002)(229853002)(6506007)(93886005)(6246003)(97736004)(6512007)(2501003)(36756003)(118296001)(86362001)(8936002)(7736002)(14454004)(68736007)(1730700003)(26005)(81156014)(53936002)(81166006)(8676002)(508600001)(6436002)(71190400001)(25786009)(102836004)(71200400001)(99286004)(5640700003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2544;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 0MheaxSmR6+PQtSbifhjLdqpErSDI1UgXkhtYxWBJG7vl/xVpCnH5YWW0w710hNJEt0eVPGUYK4yqAU9poUWfA20PtwDF7IuxVhocoO730KSn9PYKQ5Wf+y+sFiyV/i8ridsB4n9eDPKtION9P++7Wugm74/hqdDNdGxlNh5W4wjBEAr2AqgajO75H4uyBjxxNgJtUwIoisF6xLdAL4ygZVvWTySsHX1YNstvYqRJ1txl1FwzrGQDoW+4D5FjVqHFzhSwv0AqbMcyz4rUf+CD2kEzMIB3p+R/3sJMpd+a9WfB+8FORrGjAV+1IYR8Ri+7XXxsG41n4/SfmOv9G98o6U+lu96KpJAfzqxAFBj7/btXIURy5yypa0/IzPZsuojYAqVjP0r4Xj6m10ZoH0CWpXkCLqiQYVPAGwaGGbr8ok=
Content-Type: text/plain; charset="utf-8"
Content-ID: <243C468149B2724181AD37FAD0C40F04@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 41895477-79cd-49d5-16e8-08d68ae96d3b
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Feb 2019 21:40:48.2724
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2544
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAyLTA0IGF0IDE1OjMxIC0wNTAwLCBCZW5qYW1pbiBDb2RkaW5ndG9uIHdy
b3RlOg0KPiBPbiA0IEZlYiAyMDE5LCBhdCAxNDoyMCwgQmVuamFtaW4gQ29kZGluZ3RvbiB3cm90
ZToNCj4gDQo+ID4gT24gNCBGZWIgMjAxOSwgYXQgMTQ6MDcsIEJlbmphbWluIENvZGRpbmd0b24g
d3JvdGU6DQo+ID4gDQo+ID4gPiBPbiA0IEZlYiAyMDE5LCBhdCAxNDowMywgQmVuamFtaW4gQ29k
ZGluZ3RvbiB3cm90ZToNCj4gPiA+IA0KPiA+ID4gPiBPbiA0IEZlYiAyMDE5LCBhdCAxMzozMiwg
VHJvbmQgTXlrbGVidXN0IHdyb3RlOg0KPiA+ID4gPiANCj4gPiA+ID4gPiBPbiBNb24sIDIwMTkt
MDItMDQgYXQgMTM6MTMgLTA1MDAsIEJlbmphbWluIENvZGRpbmd0b24gd3JvdGU6DQo+ID4gPiA+
ID4gPiBJZiBuZnNfcGFnZV9hc3luY19mbHVzaCgpIHJlbW92ZXMgdGhlIHBhZ2UgZnJvbSB0aGUN
Cj4gPiA+ID4gPiA+IG1hcHBpbmcsIHRoZW4gd2UNCj4gPiA+ID4gPiA+IGNhbid0IHVzZSBwYWdl
X2ZpbGVfbWFwcGluZygpIG9uIGl0IGFzIG5mc191cGRhdGVwYXRlKCkgaXMNCj4gPiA+ID4gPiA+
IHdvbnQgdG8gZG8NCj4gPiA+ID4gPiA+IHdoZW4gcmVjZWl2aW5nIGFuIGVycm9yLiAgSW5zdGVh
ZCwgc2ltcGxpZnkNCj4gPiA+ID4gPiA+IG5mc196YXBfbWFwcGluZygpIHRvIHRha2UNCj4gPiA+
ID4gPiA+IHRoZSBpbm9kZS4NCj4gPiA+ID4gPiA+IA0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IFdv
bid0IHRoaXMgYnJlYWsgTkZTIHN3YXA/DQo+ID4gPiA+IA0KPiA+ID4gPiBJIGd1ZXNzIGl0IG1h
eSwgYnV0IHRoZW4gSSB3b25kZXI6IGlzIHRoYXQgYSB0aGluZyB0aGF0IGFueW9uZQ0KPiA+ID4g
PiBkb2VzPyAgSXQNCj4gPiA+ID4gc291bmRzIGxpa2UgYSB0ZXJyaWJsZSBpZGVhLi4NCj4gPiA+
ID4gDQo+ID4gPiA+IEknbSBjdXJpb3VzIGVub3VnaCB0aG91Z2gsIGFuZCBkb2luZyBzb21lIHJl
c2VhcmNoIG9uIGl0Lg0KPiA+ID4gDQo+ID4gPiBUaGVyZSdzIGVub3VnaCB0byBjb21taXRzIGlu
IHRoZSB0cmVlIGZpeGluZyBwcm9ibGVtIG9yDQo+ID4gPiBzdXBwb3J0aW5nIHN3YXANCj4gPiA+
IG9uIE5GUywgc28gSSBzdXBwb3NlIEkndmUganVzdCBtaXNzZWQgYWxsIHRoYXQuDQo+ID4gDQo+
ID4gU28gZm9yIGRpc2tsZXNzIHN5c3RlbXMsIGFoLiAgSXQgbWFrZXMgc2Vuc2UuDQo+ID4gDQo+
ID4gQnV0IGRvZXMgaXQgbWFrZSBhbnkgc2Vuc2UgdG8gc2V0IE5GU19JTk9fSU5WQUxJRF9EQVRB
IG9uIGEgc3dhcA0KPiA+IGZpbGU/DQo+ID4gRG9lcyBhbnlvbmUgc2hhcmUgdGhlbT8NCj4gPiAN
Cj4gPiBEYXplZCBhbmQgY29uZnVzZWQsIGJ1dCB0cnlpbmcgdG8gY29udGludWUuLg0KPiANCj4g
U28gaWYgdGhlIHBhZ2UgaXMgYmFja2luZyBhIHN3YXAgZmlsZSwgbmZzX3phcF9tYXBwaW5nKCkg
d2lsbCBmYWlsIHRvDQo+IHNldA0KPiBORlNfSU5PX0lOVkFMSURfREFUQSBiZWNhdXNlIGlfbWFw
cGluZy5ucnBhZ2VzIHdpbGwgYWx3YXlzIGJlIDAuDQo+IA0KPiBCdXQgaXQgbG9va3MgbGlrZSBO
RlMgaGFzIGFscmVhZHkgZGVjaWRlZCB0byBub3QgY2FyZSBpZiB0aGUgbWFwcGluZw0KPiBuZWVk
cw0KPiByZXZhbGlkYXRpb24gZm9yIHN3YXAsIHNpbmNlIHdlIGFzc3VtZSAvc2hhcmVkLyBzd2Fw
IGZpbGVzIGFyZQ0KPiBpbnNhbmUuDQo+IA0KPiBTbyB3aXRob3V0IHRlc3Rpbmcgc3dhcCBvbiBO
RlMgYXQgYWxsLCBpdCBzZWVtcyBzYWZlLg0KPiANCg0KV2hhdCBhYm91dCB0aGUgY2FzZSB3aGVu
IHRoZSBwYWdlIGlzIGluIHRoZSBzd2FwIGNhY2hlPyBJcyB0aGF0IGFsc28NCnNhZmU/DQoNCi0t
IA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNw
YWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
