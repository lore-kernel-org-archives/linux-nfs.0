Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A700C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:30:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E1DDD20863
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 22:30:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="gebLhIWw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1DDD20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727012AbeLAJlC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 04:41:02 -0500
Received: from mail-eopbgr800098.outbound.protection.outlook.com ([40.107.80.98]:21152
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726893AbeLAJlC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Dec 2018 04:41:02 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=PasJSHEMNeMIrytbPmmPsxb9L98Uhz7OHoW0qW64pq0=;
 b=gebLhIWwbRMk2Jqrb6w3x+4XAVHUyp/OK2Rll1G5QIXNpVXRG9rz/LQkFN9OEaE4pRjKts+E0wW6AOtw1K+ek215DLuwvWIc7VOJZevqYfU+gSz77tC7LvOGfQIqL3AsPFh9pml6WNgKg9XaH24ICO+4esA8gMyapr3l5c8G0Ho=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2557.namprd13.prod.outlook.com (52.135.96.16) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1404.7; Fri, 30 Nov 2018 22:30:11 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.011; Fri, 30 Nov 2018
 22:30:11 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
Thread-Topic: [PATCH v3 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
Thread-Index: AQHUiPekUfCRRl/oV0O8KonnDr8pv6Vo4moAgAAA+wCAAAFKgIAAAeKA
Date:   Fri, 30 Nov 2018 22:30:11 +0000
Message-ID: <499a31eab46be4e0ad0ec13e7ae693cd133a0444.camel@hammerspace.com>
References: <20181130215555.91107-1-trond.myklebust@hammerspace.com>
         <20181130215555.91107-2-trond.myklebust@hammerspace.com>
         <20181130215555.91107-3-trond.myklebust@hammerspace.com>
         <E9450F2D-D888-4EFC-B0BD-6506E4EC2887@oracle.com>
         <545d13619ffe92a69097f8f68fc36df85944cac2.camel@hammerspace.com>
         <7B7D615F-8A5B-4EBD-96DC-FDDA9DC35DD9@oracle.com>
In-Reply-To: <7B7D615F-8A5B-4EBD-96DC-FDDA9DC35DD9@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2557;6:g7GzoXWTpsCA352cgd5JPhF1wiEpM0xULwWA/3I+2ew3Fhuci4bxURMYQv/E83niEqcGsQ6tkZoAg2XVqwTJKN0A9M/P0kDp8gQ7Av6EmiZXzLD8jnNI1hoP6wEef94E5d+bLb0eTVccgxPRDJlJswZPsXaobW+A0q/iDaJpcbV4sRDy8hC8cov63l1+4Ke/zDSYYwNngER0lw4NCJykjEdgKzVFtYR1pRWUmXBbEG9cACv+TzfHK0gr1nVZjFJb8AHElZ1aJPfDJ5F+XpV7htLE16KremBX23vluqAipwg0ASfB4oIeMCoFcVxjWZybiAbn/NB8d9WJmfxrcYeSv18Ws4fJlOXgtjU7fWOyVjSdgHF6B8ASTVQfUjgOweeCwt/u6LRr4L2xsF0idmLG+30EqqqNARn7EamkLPzwVxDAHbkzrzyykN3ohrp3ayqPKGw5VIbyGBzZ2W8xNGZtFg==;5:UcQmFroUbJQqObPyDTAV+HrWkBDal0gV25yz9mq+VxukGeWUQthqzIyhHTQPkSzVuj0flXnYCCG5WHzU+5BG/eAegCCsO5MAHLZ8E2eHMQDHHxvz+vbpIFk14/PJh7+J2WCWnron7pXoEvfHz15QbfQmpaMnmLajKdde5/rJDBE=;7:BAV7r3nseniOWXDExoq7zteQVW7ZarvYQsmjtgj/Pw3zMUWvhbsOIDIxo3F7SPJpmyBgiJaQCkvzdeRjPb9LSSnMIxTyAdbNTK4jTp1HoWENjgUOvc9L2ESI/HkLdDqb/PP9+8ejCny4fclG9h2MVQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 8a0930d2-22c1-4fd9-d6ef-08d657136403
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2557;
x-ms-traffictypediagnostic: SN6PR13MB2557:
x-microsoft-antispam-prvs: <SN6PR13MB2557FC44D1E3AEB76AAD1767B8D30@SN6PR13MB2557.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(3002001)(10201501046)(3231453)(999002)(944501469)(52105112)(93006095)(93001095)(148016)(149066)(150057)(6041310)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123558120)(20161123564045)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2557;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2557;
x-forefront-prvs: 087223B4DA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(396003)(366004)(346002)(376002)(39830400003)(199004)(189003)(2616005)(5640700003)(76176011)(486006)(86362001)(14444005)(97736004)(53936002)(6916009)(4001150100001)(93886005)(6246003)(66066001)(229853002)(71190400001)(476003)(256004)(11346002)(446003)(36756003)(6486002)(2351001)(6346003)(26005)(8936002)(6436002)(4326008)(105586002)(81166006)(81156014)(118296001)(2501003)(71200400001)(106356001)(8676002)(186003)(6506007)(53546011)(68736007)(25786009)(3846002)(305945005)(7736002)(316002)(6116002)(102836004)(478600001)(6512007)(5660300001)(2906002)(14454004)(99286004);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2557;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-message-info: eSa7t3tQs9Oms3Wol01PgoGKO+O5kBDkr7G3ehYTAocdC2Qdr35LXQR99zuouOrbnXJs0BmPpLjOPoO2F5hpc9f4oDPA5SElKEt6ZhSNnxtsOwH4z8Fo7C2HVZRhulme/Z+VkXukiXeuczpINzGI3+a3Kbo6d3EcQGklGjzpzIyYybL+wQZVQYtZ6BG3o12cjM3B/aKDocYI2tXNlfYwUxo3lrrMHrVAIkA7OiOkCtjLL+keR95Z4I+dGyQ/4hKxeG0MKe1ohVGXv3dBJvmb1jdpH7iLorKoYzN2V+7rqGA3CvuOL1RCsLFMVN1oloe9ow1VG8HzRmU9KLUGMdhRHC6oFDs1ZV3x1ichRzF/ZGA=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <402A28D441A1F94BA06089C33057B180@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8a0930d2-22c1-4fd9-d6ef-08d657136403
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Nov 2018 22:30:11.1861
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2557
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTMwIGF0IDE3OjIzIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBOb3YgMzAsIDIwMTgsIGF0IDU6MTggUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIEZyaSwgMjAxOC0xMS0z
MCBhdCAxNzoxNSAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiA+IE9uIE5vdiAzMCwg
MjAxOCwgYXQgNDo1NSBQTSwgVHJvbmQgTXlrbGVidXN0IDx0cm9uZG15QGdtYWlsLmNvbQ0KPiA+
ID4gPiA+DQo+ID4gPiA+IHdyb3RlOg0KPiA+ID4gPiANCj4gPiA+ID4gQSBjYWxsIHRvIGdzc193
cmFwX3JlcV9wcml2KCkgd2lsbCBlbmQgdXAgcmVwbGFjaW5nIHRoZQ0KPiA+ID4gPiBvcmlnaW5h
bA0KPiA+ID4gPiBhcnJheQ0KPiA+ID4gPiBpbiBycXN0cC0+cnFfc25kX2J1Zi5wYWdlcyB3aXRo
IGEgbmV3IG9uZSBjb250YWluaW5nIHRoZQ0KPiA+ID4gPiBlbmNyeXB0ZWQNCj4gPiA+ID4gZGF0
YS4gSW4gb3JkZXIgdG8gYXZvaWQgaGF2aW5nIHRoZSBycXN0cC0+cnFfc25kX2J1Zi5idmVjIHBv
aW50DQo+ID4gPiA+IHRvDQo+ID4gPiA+IHRoZQ0KPiA+ID4gPiB3cm9uZyBwYWdlIGRhdGEsIHdl
IG5lZWQgdG8gcmVmcmVzaCB0aGF0IHRvby4NCj4gPiA+IA0KPiA+ID4gSSB3b3VsZCBhZGQgYSBu
b3RlIGhlcmUgdGhhdCB0aGlzIHBhdGNoIGZpeGVzIGEgbWVtb3J5IGxlYWsuIEFuZA0KPiA+ID4g
eW91IG1pZ2h0IHdhbnQgdG8gYWRkIGEgRml4ZXM6IHRhZy4NCj4gPiA+IA0KPiA+IA0KPiA+IEl0
IG9ubHkgYXBwbGllcyB0byBuZXcgY29kZSB0aGF0IHdlbnQgaW50byA0LjIwLCBzbyBpdCB3b24n
dCBuZWVkDQo+ID4gYW55DQo+ID4gc3RhYmxlIGJhY2twb3J0aW5nLg0KPiA+IA0KPiA+IFRoYXQg
c2FpZCwgSSdtIHJlYWxpc2luZyAoc2xvd2x5IC0gYXBwYXJlbnRseSBJJ20gYXNsZWVwIHRvZGF5
KQ0KPiA+IHRoYXQNCj4gPiB0aGlzIGlzIHJlY2VpdmUgc2lkZSBjb2RlLCBzbw0KPiA+IA0KPiA+
IGEpIFRoZSBjb250ZW50cyBvZiBycV9zbmRfYnVmIGFyZSBpcnJlbGV2YW50Lg0KPiA+IGIpIFdl
IHdhbnQgdG8gYmV3YXJlIG9mIGNoYW5naW5nIGl0IHdoaWxlIHRoZXJlIGlzIGEgY29weSBpbg0K
PiA+IHJxX3ByaXZhdGVfYnVmLg0KPiA+IA0KPiA+IElPVzogYSB2NCBpcyBmb3J0aGNvbWluZy4N
Cj4gDQo+IGZ3aXcsIGkgc2VlIHRoZSBzb2Z0IElSUSB3YXJuaW5ncyB3aXRoIE5GUy9SRE1BIHRv
by4NCj4gDQo+IEkgd291bGQgbGlrZSB0byB0dXJuIHRob3NlIGludG8gYSBwcl93YXJuX3JhdGVf
bGltaXRlZC4gSSBkb24ndA0KPiBzZWUgbXVjaCBwb2ludCBpbiB0aGUgYmFja3RyYWNlIGJsYXRo
ZXIuDQo+IA0KDQpZb3VyIGluaXRpYWwgZW1haWwgbWVudGlvbmVkIHRoZXNlIHNvZnQgSVJRIHdh
cm5pbmdzLCBidXQgZGlkbid0DQpwcm92aWRlIGFuIGV4YW1wbGUuIFdoaWNoIHdhcm5pbmdzIGFy
ZSB0aGVzZSBleGFjdGx5LCBhbmQgd2hlcmUgYXJlDQp0aGV5IGNvbWluZyBmcm9tPw0KDQotLSAN
Ci0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1l
cnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
