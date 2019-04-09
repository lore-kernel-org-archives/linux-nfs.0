Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62AA6C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 12:53:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 11DFB20855
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 12:53:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="FXh2/35u"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726711AbfDIMxw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 08:53:52 -0400
Received: from mail-eopbgr710103.outbound.protection.outlook.com ([40.107.71.103]:12060
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726112AbfDIMxw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Apr 2019 08:53:52 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=GK7+3YqBSbVE+XT61meJ56hpY1QCrwgXjhR+P7N0azo=;
 b=FXh2/35ujNE2JxsCNJHs0SydYbP9x/zMmCNVEbzl5geWfsEyiJqpNKsfzMjuSx1C6vcI6RpiYPJIySxfznY+u7iEvl5t16tWuTLfvTRpAbkxyhjtSYjxP220gU2/DLSaOQ1LjYIwA6N6INxvcT9khWBpKWWJeQXyXqPKCSSzFk0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2317.namprd13.prod.outlook.com (52.135.94.24) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1792.7; Tue, 9 Apr 2019 12:53:48 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1792.007; Tue, 9 Apr 2019
 12:53:48 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "Diego.SantaCruz@spinetix.com" <Diego.SantaCruz@spinetix.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Write access check not correct on world writable directories
 (regression)
Thread-Topic: Write access check not correct on world writable directories
 (regression)
Thread-Index: AdTurF3PJLe1IvUXS+qxCgYbn/IAGgAJub4A
Date:   Tue, 9 Apr 2019 12:53:47 +0000
Message-ID: <1aea7647abe49e21b64630ba123559fe0eb774c4.camel@hammerspace.com>
References: <VI1PR01MB5167A74BA4409EE4C27B592F882D0@VI1PR01MB5167.eurprd01.prod.exchangelabs.com>
In-Reply-To: <VI1PR01MB5167A74BA4409EE4C27B592F882D0@VI1PR01MB5167.eurprd01.prod.exchangelabs.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: aeb814a9-a9ec-45ec-4947-08d6bcea6886
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600139)(711020)(4605104)(2017052603328)(7193020);SRVR:SN6PR13MB2317;
x-ms-traffictypediagnostic: SN6PR13MB2317:
x-microsoft-antispam-prvs: <SN6PR13MB23173162A7CF76F80EB80597B82D0@SN6PR13MB2317.namprd13.prod.outlook.com>
x-forefront-prvs: 000227DA0C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(366004)(346002)(376002)(199004)(189003)(508600001)(476003)(6506007)(106356001)(11346002)(76176011)(6436002)(14444005)(5024004)(256004)(7736002)(446003)(97736004)(305945005)(2616005)(53936002)(14454004)(36756003)(71200400001)(25786009)(102836004)(66066001)(71190400001)(486006)(5660300002)(6486002)(186003)(8936002)(229853002)(6246003)(4326008)(81156014)(118296001)(2501003)(81166006)(26005)(110136005)(8676002)(86362001)(105586002)(3846002)(68736007)(6512007)(6116002)(99286004)(2906002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2317;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 9pLsY0mQdHlen5k/YYmXHzqBzGwIK4t1HyO5L52diUtfAuFU8JfZUH0R4PUP45KaclWcrMGBu1ogH6b7Npp2X3gk7fMAcw09EUc7hBc7cCZNIhFMeWUHRhugBDc9/Q2U8EctW4zyBquyq3aROV6cdGYy4w9bKerX4BIzGWz9OFJ4g5ioSSPgdeGGG3uukqsqa4BeDLKWcdG5CcgAdb/0AWNIQaK3GzF9tMY7WvCCylexJ/9ATpHAl9zBGZkuMgeVxngvME5AbAerxoAFsnTfQW9u9PBdYbEVAvLl+NhbZWM0PP+C5ZDD6pDpUf/kISEXStBwyaRUPNL8A+ORA+GIf8qbN0U2YusbBo5UmHJhV6JRwGGOfapyDmUOGO5JCN+PnaKAG07D6qETxfNuNBpqhNv+zu2r7XfZUfNoASNFzhc=
Content-Type: text/plain; charset="utf-8"
Content-ID: <E5FD18E4E4CD27419260513268272D62@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: aeb814a9-a9ec-45ec-4947-08d6bcea6886
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Apr 2019 12:53:47.9812
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2317
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTA0LTA5IGF0IDA5OjI2ICswMDAwLCBEaWVnbyBTYW50YSBDcnV6IHdyb3Rl
Og0KPiBIZWxsbywNCj4gDQo+IEkgaGF2ZSBlbmNvdW50ZXJlZCBhIHByb2JsZW0gd2l0aCBhY2Nl
c3MoZGlyLCBXX09LKSBjYWxscyBhbmQgd29ybGQNCj4gd3JpdGFibGUgZGlyZWN0b3JpZXMgb24g
TkZTIHdoaWNoIGFyZSBub3Qgb3duZXIgYnkgdGhlIGNhbGxpbmcgdXNlci4NCj4gVGhlIGNhbGwg
cmV0dXJucyBFQUNDRVMsIGV2ZW4gdGhvdWdoIHRoZSB1c2VyIGNhbiBjcmVhdGUgZmlsZXMgaW4g
dGhlDQo+IGRpcmVjdG9yeS4gSSB1c2UgTkZTdjMsIGJ1dCB0aGlzIG1heSBhbHNvIGltcGFjdCBv
dGhlciBORlMgdmVyc2lvbnMuDQo+IA0KPiBUZXN0IGNhc2UsIG9uIGFuIE5GU3YzIG1vdW50ZWQg
ZGlyZWN0b3J5IGlzOg0KPiAxLiBDcmVhdGUgd29ybGQgd3JpdGFibGUgZGlyZWN0b3J5IGFzIHJv
b3Q6IHN1ZG8gbWtkaXIgLW0gNzc3IHRlc3RkaXINCj4gMi4gVGVzdCB0aGF0IG5vcm1hbCB1c2Vy
IGNhbiBjcmVhdGUgYSBmaWxlOiBybSAtZiB0ZXN0ZGlyL2ZvbyAmJg0KPiB0b3VjaCB0ZXN0ZGly
L2Zvbw0KPiAzLiBUZXN0IGZvciB3cml0YWJpbGl0eSB3aXRoIGFjY2Vzczogc3RyYWNlIC1vIGxv
ZyB0ZXN0IC13IHRlc3RkaXIgJiYNCj4gZWNobyBQQVNTIHx8IGVjaG8gRkFJTA0KPiA0LiBDaGVj
a2luZyB0aGUgc3RyYWNlIGxvZyBzaG93cyB0aGF0IGFjY2VzcygidGVzdGRpciIsIFdfT0spIGZh
aWxzDQo+IHdpdGggRUFDQ0VTDQo+IA0KPiBJIGFtIHVzaW5nIHRoZSBsaW51eC1pbnRlbCBrZXJu
ZWwgNC4xOS4xMywgYnV0IEkgdHJhY2VkIHRoaXMgdG8NCj4gY29tbWl0IGVjYmI5MDNjNTY3NDUg
aW4gbGludXggbWFzdGVyIChORlM6IEJlIG1vcmUgY2FyZWZ1bCBhYm91dA0KPiBtYXBwaW5nIGZp
bGUgcGVybWlzc2lvbnMpLCB0aGF0IHdlbnQgaW50byBrZXJuZWwgNC4xMy4gVGhlIHRlc3Qgd29y
a3MNCj4gZmluZSBpbiBlYXJsaWVyIGtlcm5lbHMuIFRoZSBwcm9ibGVtIGRvZXMgbm90IGFsd2F5
cyBzaG93IHVwIG9uDQo+IGRpcmVjdG9yaWVzIG93bmVkIGJ5IHRoZSBjYWxsaW5nIHVzZXIsIGJ1
dCBpdCBtYXkgYmUgZHVlIHRvIGF0dHJpYnV0ZQ0KPiBjYWNoaW5nIG9yIHNpbWlsYXIuDQo+IA0K
PiBJIGFtIG5vdCB2ZXJ5IE5GUyBzYXZ2eSBidXQgYXMgZmFyIGFzIEkgdW5kZXJzdGFuZCB0aGUg
Y29tbWl0IGFib3ZlDQo+IGNoYW5nZWQgdGhlIHRlc3RzIGluIG5mc19hY2Nlc3NfY2FsY19tYXNr
KCkgZnJvbSAiYW55IGJpdCBpbiBtYXNrIGlzDQo+IHNldCIgdG8gImFsbCBiaXRzIGluIG1hc2sg
YXJlIHNldCIuIFRoZSBtYXNrIGZvciB3cml0YWJsZSBkaXJlY3Rvcmllcw0KPiBpcyBBQ0NFU1Nf
TU9ESUZZLCBBQ0NFU1NfRVhURU5ELCBBQ0NFU1NfREVMRVRFIGJ1dCBmcm9tIHdoYXQgSSBzZWUg
aW4NCj4gYSBuZXR3b3JrIGNhcHR1cmUgdGhlIHJlc3BvbnNlIGZyb20gdGhlIE5GUyBzZXJ2ZXIg
aXMgbGFja2luZyB0aGUNCj4gQUNDRVNTX0RFTEVURSBiaXQuDQo+IA0KPiBUaGUgYXR0YWNoZWQg
cGF0Y2ggcmV2ZXJ0cyB0aGUgdGVzdHMgaW4gbmZzX2FjY2Vzc19jYWxjX21hc2soKSB0bw0KPiAi
YW55IGJpdCBpbiBtYXNrIGlzIHNldCIsIHdoaWNoIG1ha2VzIHRoZSB0ZXN0IGNhc2Ugd29yayBh
Z2FpbiwgYnV0IEkNCj4gYW0gbm90IHN1cmUgaXQgaXMgZW50aXJlbHkgY29ycmVjdCB0byBjaGFu
Z2UgYWxsIHRoZSB0ZXN0cywgb3IgaWYgaXQNCj4gd291bGQgYmUgbW9yZSBhcHByb3ByaWF0ZSB0
byBkcm9wIEFDQ0VTU19ERUxFVEUgZnJvbSB0aGUNCj4gTkZTX0RJUl9NQVlfV1JJVEUgbWFzay4g
VGhlIHBhdGNoIGFwcGxpZXMgY2xlYW5seSBvbiBjdXJyZW50IGxpbnV4DQo+IG1hc3Rlci4NCj4g
DQo+IEkgY2hlY2tlZCB0aGUgTkZTdjMgYW5kIE5GU3Y0IFJGQ3MsIGJ1dCBpdCBpcyBub3QgY2xl
YXIgdG8gbWUgaWYNCj4gQUNDRVNTX0RFTEVURSBpcyBmb3IgdGhlIGRpcmVjdG9yeSBpdHNlbGYg
b3IgaXRzIGNoaWxkcmVuLiBJbiBhbnkNCj4gY2FzZSBteSBORlMgc2VydmVyIGlzIG9taXR0aW5n
IEFDQ0VTU19ERUxFVEUgZnJvbSB0aGUgcmVzcG9uc2UgKGl0IGlzDQo+IGEgU3lub2xvZ3kgcnVu
bmluZyBMaW51eCBrZXJuZWwgMy4xMC4xMDUpLg0KPiANCg0KVGhlIEFDQ0VTU19ERUxFVEUgYml0
IGFwcGxpZXMgX29ubHlfIHRvIGRpcmVjdG9yaWVzLCBzbyBpZiBpdCBpcw0KbWlzc2luZyBpbiB0
aGUgcmVwbHkgZnJvbSB5b3VyIHNlcnZlciBmb3IgYSBkaXJlY3Rvcnkgd2l0aCBQT1NJWCA3NzcN
CnBlcm1pc3Npb25zLCB0aGVuIHlvdSBzaG91bGQgdGFsayB0byB0aGUgc2VydmVyIHZlbmRvci4N
Cg0KQXMgZmFyIGFzIEkgY2FuIHNlZSwgdGhlIGN1cnJlbnQgY29kZSBpcyBjb3JyZWN0LiBJZiB5
b3UgZG8gbm90IGhhdmUNCnRoZSBBQ0NFU1NfREVMRVRFIGJpdCBzZXQgb24geW91ciBkaXJlY3Rv
cnksIHRoZW4gdGhlIHNlcnZlciBpcyB0ZWxsaW5nDQp0aGUgY2xpZW50IHRoYXQgeW91ciBwcm9j
ZXNzIGRvZXMgbm90IGhhdmUgZnVsbCB3cml0ZSBwZXJtaXNzaW9ucyB0bw0KdGhhdCBkaXJlY3Rv
cnkgaW4gYWNjb3JkYW5jZSB3aXRoIHRoZSBQT1NJWCBzcGVjLg0KDQpDaGVlcnMNCiAgVHJvbmQN
Ci0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1l
cnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
