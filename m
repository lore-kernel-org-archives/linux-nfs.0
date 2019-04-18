Return-Path: <SRS0=DJTG=SU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F486C10F0E
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 22:03:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E75A7205ED
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 22:03:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="MRKRELBk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725872AbfDRWDN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Apr 2019 18:03:13 -0400
Received: from mail-eopbgr680094.outbound.protection.outlook.com ([40.107.68.94]:19627
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725824AbfDRWDN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Apr 2019 18:03:13 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Sp7CyXmZhCm22T0/jVfWAU/dNrXDxyQ3U4/1JYR1D58=;
 b=MRKRELBkXfqi9lg0E6/CPXFytwBgtw3PmTd1CAJIzayq9bsyDZ0TkWIGC/0SZCr5x8PstsBlJZxMZQBq4BC3nAjVHxO7O+6NpT8B0k1YfbHANjMBVbaYMXVzI8C7NQUkqeiihho7Kd5WuVz1/DoV+ys2Zlw98gLnnf+NFF+YvRs=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2495.namprd13.prod.outlook.com (52.135.95.149) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.6; Thu, 18 Apr 2019 22:03:09 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::48d2:c5de:2651:4c30]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::48d2:c5de:2651:4c30%2]) with mapi id 15.20.1835.003; Thu, 18 Apr 2019
 22:03:09 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "smayhew@redhat.com" <smayhew@redhat.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH] nfsd: CB_RECALL can race with FREE_STATEID
Thread-Topic: [PATCH] nfsd: CB_RECALL can race with FREE_STATEID
Thread-Index: AQHU9eoA+LnbIrF7jEWsGwkuP/UCjKZCBqYAgABeNgCAABRRgA==
Date:   Thu, 18 Apr 2019 22:03:09 +0000
Message-ID: <15806b00f7ba569a109549eb551bb116d981226d.camel@hammerspace.com>
References: <20190418132400.24161-1-smayhew@redhat.com>
         <20190418151312.GB29274@fieldses.org>
         <20190418205024.GB15226@coeurl.usersys.redhat.com>
In-Reply-To: <20190418205024.GB15226@coeurl.usersys.redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 69f8c798-24fb-45ca-a1e5-08d6c449a4d9
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600141)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:SN6PR13MB2495;
x-ms-traffictypediagnostic: SN6PR13MB2495:
x-microsoft-antispam-prvs: <SN6PR13MB24950689C506BBB21D1942F6B8260@SN6PR13MB2495.namprd13.prod.outlook.com>
x-forefront-prvs: 0011612A55
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(136003)(396003)(366004)(39830400003)(199004)(189003)(316002)(305945005)(7736002)(6506007)(102836004)(186003)(3846002)(26005)(36756003)(66476007)(118296001)(91956017)(66446008)(73956011)(110136005)(66556008)(64756008)(14454004)(256004)(97736004)(229853002)(2501003)(8676002)(8936002)(5660300002)(4326008)(71190400001)(71200400001)(6486002)(86362001)(81166006)(81156014)(446003)(11346002)(476003)(2616005)(2906002)(6436002)(478600001)(486006)(6116002)(66066001)(53936002)(76176011)(6246003)(99286004)(6512007)(25786009)(68736007)(54906003)(66946007)(76116006);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2495;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: LbB/X/G3YO1UkTOVesCH+FOm/dXQhtfRIHfld/F/0dItRZsx5qryazWyNe7B9T2EE50wVyktIFB1HRF7IplZTXbarRtVO3KVQ9U0kTBIVGhR6I8aaRFBPq8babC0K/KHVFGWz4phmt2+IQpwUgV+EVM6X8Ou5iFKXbjKkeVDq95ar1hp5Be6wBIEiShU/WzColRSrXdQteB6FbEXL5kUoROVtQs8wmY7oQWFLISW7Rz2Lke3L++BiAfQmABDgqsOfd9Xy+Bg+uRap1uxTwlwQlR54udhPM+Lj7Q39cAXO1Gnptt9h7XBhogOFKQYNMkwPfhhEtXFOWhnJvrxh9+1k8lW0myqVdDEMnQE/kq6hZwptCKj5PkqzpV8Hw/Z18C5swlAW1x5YAuMfYY/99Uvm71e545hiI3IaCi0MmEBurY=
Content-Type: text/plain; charset="utf-8"
Content-ID: <FDFEE4DF9E076F4AAA41AA1C3EE59117@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 69f8c798-24fb-45ca-a1e5-08d6c449a4d9
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Apr 2019 22:03:09.5225
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2495
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTA0LTE4IGF0IDE2OjUwIC0wNDAwLCBTY290dCBNYXloZXcgd3JvdGU6DQo+
IE9uIFRodSwgMTggQXByIDIwMTksIEouIEJydWNlIEZpZWxkcyB3cm90ZToNCj4gDQo+ID4gT24g
VGh1LCBBcHIgMTgsIDIwMTkgYXQgMDk6MjQ6MDBBTSAtMDQwMCwgU2NvdHQgTWF5aGV3IHdyb3Rl
Og0KPiA+ID4gV2hpbGUgdHJ5aW5nIHRvIHRyYWNrIGRvd24gc29tZSBpc3N1ZXMgaW52b2x2aW5n
IGxhcmdlIG51bWJlcnMgb2YNCj4gPiA+IGRlbGVnYXRpb25zIGJlaW5nIHJlY2FsbGVkL3Jldm9r
ZWQsIEkgY2F1Z2h0IHRoZSBzZXJ2ZXIgc2V0dGluZw0KPiA+ID4gU0VRNF9TVEFUVVNfQ0JfUEFU
SF9ET1dOIHdoaWxlIHRoZSBjbGllbnQgd2FzIGFjdGl2ZWx5IHJlc3BvbmRpbmcNCj4gPiA+IHRv
DQo+ID4gPiBDQl9SRUNBTExzLiAgSXQgdHVybnMgb3V0IHRoYXQgdGhlIGNsaWVudCBoYWQgYWxy
ZWFkeSBkb25lIGENCj4gPiA+IFRFU1RfU1RBVEVJRCBhbmQgRlJFRV9TVEFURUlEIGZvciBhIGRl
bGVnYXRpb24gYmVpbmcgcmVjYWxsZWQgYnkNCj4gPiA+IHRoZQ0KPiA+ID4gdGltZSBpdCByZWNl
aXZlZCB0aGUgQ0JfUkVDQUxMLg0KPiA+IA0KPiA+IFRoYXQncyBpbnRlcmVzdGluZywgdGhhbmtz
IQ0KPiA+IA0KPiA+IFRoaXMgZXhjZXB0aW9uIHNlZW1zIGF3ZnVsbHkgbmFycm93LCB0aG91Z2gu
DQo+ID4gDQo+ID4gSWYgd2UgZ2V0IGJhY2sgYW55IE5GUy1sZXZlbCBlcnJvciBhdCBhbGwsIHRo
ZW4gSSB0aGluayB0aGUNCj4gPiBjYWxsYmFjaw0KPiA+IGNoYW5uZWwgaXMgd29ya2luZyAoYW0g
SSB3cm9uZz8pDQo+IA0KPiBDb3JyZWN0LCBpZiB0aGUgY2xpZW50IHJlcGxpZXMgd2l0aCBlaXRo
ZXIgTkZTNEVSUl9ERUxBWSBvcg0KPiBORlM0RVJSX0JBRF9TVEFURUlELCB0aGUgc2VydmVyIHdp
bGwgcmV0cnkgMSB0aW1lIChzZWUgZGxfcmV0cmllcykuDQo+IEFmdGVyIHRoYXQsIHdlIGZhbGwg
dGhydSBhbmQgbmZzZDRfY2JfcmVjYWxsX2RvbmUoKSByZXR1cm5zIC0xIHdoaWNoDQo+IGNhdXNl
cyB0aGUgU0VRNF9TVEFUVVNfQ0JfUEFUSF9ET1dOIGZsYWcgdG8gYmUgc2V0Lg0KDQpUaGVyZSBp
cyBubyBoYW5kbGluZyBvZiBORlM0RVJSX0RFTEFZIGluIG5mc2Q0X2NiX3JlY2FsbF9kb25lKCku
DQoNCkFzIGZhciBhcyBJIGNhbiBzZWUsIHRoZXJlZm9yZSwgaWYgdGhlIGNsaWVudCByZXR1cm5z
IE5GUzRFUlJfREVMQVkNCih3aGljaCBpdCB1c3VhbGx5IGRvZXMgaWYgaXQgaXMgYWxyZWFkeSBp
biB0aGUgcHJvY2VzcyBvZiByZXR1cm5pbmcgdGhlDQpkZWxlZ2F0aW9uKSB0aGVuIHRoZSByZWNh
bGwgd2lsbCBmYWlsIGltbWVkaWF0ZWx5Lg0KDQo+ID4gYW5kIHRlbGxpbmcgdGhlIGNsaWVudCB0
byBzZXQgdXAgYSBuZXcNCj4gPiBvbmUgaXMgcHJvYmFibHkgbm90IGdvaW5nIHRvIGhlbHAuICBU
aGUgYmVzdCB3ZSBjYW4gZG8gaXMgcHJvYmFibHkNCj4gPiBqdXN0DQo+ID4gZ2l2ZSB1cA0KPiAN
Cj4gVGhhdCdzIHdoYXQgdGhlIHBhdGNoIGlzIGVzc2VudGlhbGx5IGRvaW5nLiAgT3IgYXJlIHlv
dSBzYXlpbmcgZG9uJ3QNCj4gZXZlbiBib3RoZXIgd2l0aCB0aGUgY2hlY2tzIGJ1dCBzdGlsbCBy
ZXR1cm4gMSBzbyB3ZSBkb24ndCBzZXQgdGhlDQo+IFNFUTRfU1RBVFVTX0NCX1BBVEhfRE9XTiBm
bGFnPw0KPiANCj4gPiBhbmQgbGV0IHRoZSBjbGllbnQgZGVhbCB3aXRoIHRoZSBlbnN1aW5nDQo+
ID4gUkVDQUxMQUJMRV9TVEFURV9SRVZPS0VEIGZsYWcuDQo+IA0KPiBUaGUgY2xpZW50J3MgYWxy
ZWFkeSBkZWFsaW5nIHdpdGggdGhlIFJFQ0FMTEFCTEVfU1RBVEVfUkVWT0tFRCBmbGFnLA0KPiB0
aGF0J3Mgd2h5IGl0IHNlbnQgYSBURVNUX1NUQVRFSUQgYW5kIEZSRUVfU1RBVEVJRCBiZWZvcmUg
aXQgZ290IHRoaXMNCj4gcGFydGljdWxhciBDQl9SRUNBTEwuICBUaGUgaWRlYSBiZWhpbmQgdGhl
IHBhdGNoIGlzIHRvIG5vdCBnaXZlIHRoZQ0KPiBzdGF0ZSBtYW5hZ2VyIG9uIHRoZSBjbGllbnQg
YWRkaXRpb25hbCB3b3JrIGJ5IHNldHRpbmcgQ0JfUEFUSF9ET1dODQo+IHdoZW4NCj4gdGhlIGNh
bGxiYWNrIGNoYW5uZWwgaXMgY2xlYXJseSB3b3JraW5nLi4uDQo+IA0KDQpFaXRoZXIgd2F5LCB0
aGUgTGludXggY2xpZW50IHdpbGwgaWdub3JlIGFueSBmdXJ0aGVyIHNlcXVlbmNlIGZsYWdzDQp1
bnRpbCBpdCBpcyBkb25lIHdpdGggdGhlIHJlY292ZXJ5IG9mIHRoZSBSRUNBTExBQkxFX1NUQVRF
X1JFVk9LRUQNCmZsYWcuIFRoZSByZWFzb24gaXMgdGhhdCB0aGUgZmxhZ3MgYXJlIGVkZ2UgdHJp
Z2dlcmVkIChpLmUuIHRoZXkgZG9uJ3QNCmNsZWFyIHVudGlsIHRoZSBzdGF0ZSBjaGFuZ2VzKSwg
YW5kIHNvIHdlIG5lZWQgdG8gYmUgYWJsZSB0byBwZXJmb3JtIGENCmZ1bGwgcmVjb3ZlcnkgYmVm
b3JlIHdlIGNhbiBjaGVjayB0aGVtIGFnYWluLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGlu
dXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhh
bW1lcnNwYWNlLmNvbQ0KDQoNCg==
