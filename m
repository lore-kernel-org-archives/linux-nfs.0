Return-Path: <SRS0=enTr=PL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3714C43387
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 18:11:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9144D217F5
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jan 2019 18:11:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="vWTImNTp"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727107AbfACSL6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jan 2019 13:11:58 -0500
Received: from mail-eopbgr770118.outbound.protection.outlook.com ([40.107.77.118]:7850
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727932AbfACSL6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jan 2019 13:11:58 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=GnHOBLyw7HeLxbhGkkQN9LLUj85LQi4Gwl6pbUHHdo8=;
 b=vWTImNTpqWQPAm9farCF9Dm+4BlTrdDels5pjemI/amW5Y5EeycjvErIrEY/l1tZsAaUrFaBkeeDeiP0l9M3Sxk/fG9FW3sNoGGRGICS4r8i9K/TMgGmRiLdbEEqr+/qp8M3eV+n46RrRbvpUx+qCz0LnzYDHtsvo5pMXWZnlwI=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2528.namprd13.prod.outlook.com (52.135.95.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1516.4; Thu, 3 Jan 2019 18:09:02 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Thu, 3 Jan 2019
 18:09:02 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request
 transmission
Thread-Topic: [PATCH 1/4] SUNRPC: Ensure rq_bytes_sent is reset before request
 transmission
Thread-Index: AQHUou4ciNJmIo9Omk+8lSTAAKbkzqWdrGSAgAAKCoCAAAoCAIAAGHoA
Date:   Thu, 3 Jan 2019 18:09:02 +0000
Message-ID: <cc4a7358e770668447ed8e4dac5bd41f70df10e9.camel@hammerspace.com>
References: <20190102225313.2097-1-trond.myklebust@hammerspace.com>
         <20190102225313.2097-2-trond.myklebust@hammerspace.com>
         <1B5E1F96-246A-43AB-B9CE-FA41C595ADFF@oracle.com>
         <6e18b8ce25652bf17d6d1fa95c3a6127767cb45b.camel@hammerspace.com>
         <0044B1EA-215B-412C-B1C6-0D1767B3CCEE@oracle.com>
In-Reply-To: <0044B1EA-215B-412C-B1C6-0D1767B3CCEE@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2528;6:ePvp0PxeKuDOMbFL9IKXBbZlkpFYlPvNdb3quhGNstdiXDEHreP+4ZTZu/9xWV5jA/eTVJ2KwJYY+4XGAEgh7bCXdtxPjbzezbQ/s/eSpUocYaXwX9s5AAplt+AnD4ruZSkx+b4GyZkMHn+z5sH2B86scborKWNC0yACMqgUi6oyGS5bLNZ87hWlgoOLEFkSNBV9FwrtQ3HTBKuG03E8qzVBIqKSmu0iAXVZmm/A+fygrtSNjY0j3sU64sV3pPFhw6j5PxELNj+Ub6j0hvNxCrxJmQexxNrI+MXKFnIcVkxs2cfw92cSNhQkinpPUUZB0SBy0VeiubH9DXJ+ZViYMzzPcjwPeytm4NlUlJ3uAJWc0lwMjZt8ATVl5hPs1E8w/PEzVqCc+UWGIKO8trX1pe0V5H3ulZe1CXfmXjmZtWQwfUBuOlKdLFrZq9D4TxKoUjGd6tHrAbHGqCj2FaL7Ow==;5:0ksv6gWckBkoPDYFSBjgsPn1Tz0dPgedxw7lMtFkNqXXfR6SucZwBjNkq0BQInvtc4wxtd3mOwTMcCxp78VZdtn2wpo+xpOb7vPzItPNBHTQdgWO3SR5jTtH7duqyPmb6WmorayIfFyADEPXTW+cwwxp1CwMkeWTwiUmjmmfssh8xt3IdjkNSq+zOLJ3cK635lQm/QlQMNDrf+Bed/bc7w==;7:ZY1KafiHNnyL3YOUJSh01LfjT24XP38qyRNKE9ilufOqWjBynvMeTk7y7oM3uMQ12B3DZmeBjmBaGCtEoV5+t1Y+fDb4PKrhl8g4k8u/jb0WzxDjfEgk2zSxK2fMEJ0wQKDb2YW5pjJgoTXgFv1qgg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 57cbee5d-39b1-4f19-7f55-08d671a68ac4
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2528;
x-ms-traffictypediagnostic: SN6PR13MB2528:
x-microsoft-antispam-prvs: <SN6PR13MB252899D686903DC500815643B88D0@SN6PR13MB2528.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(8220060)(2401047)(8121501046)(3002001)(10201501046)(3231475)(944501520)(52105112)(93006095)(93001095)(6041310)(20161123564045)(20161123558120)(20161123562045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2528;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2528;
x-forefront-prvs: 0906E83A25
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(136003)(346002)(366004)(376002)(39830400003)(199004)(189003)(2906002)(26005)(305945005)(118296001)(6916009)(81156014)(81166006)(316002)(8676002)(478600001)(5660300001)(6116002)(3846002)(76176011)(6506007)(53546011)(186003)(99286004)(102836004)(86362001)(93886005)(66066001)(53936002)(25786009)(229853002)(2351001)(476003)(2616005)(105586002)(11346002)(486006)(106356001)(7736002)(6246003)(36756003)(14444005)(68736007)(6512007)(2501003)(8936002)(14454004)(71190400001)(4326008)(71200400001)(5640700003)(256004)(97736004)(6486002)(446003)(6436002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2528;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Eu+2APhe0eAJGJWsjTR/gpo+gOE4TFWrVgTVkMXDghhaKqJNIpx4LYNZtJKQAxGDFsZWGZPIXe7vyGMQhbD6P7KbSD5vwRpQho143zeNSId9QYavfzo2rGnN6vuDoHAR8hv6s/4Nm6zUXHAc2rKltw0+qI6iuzBSgpjbn8VStyECUh1Y3l3zeaNcV9i0KP2Q3uueU4ir/XLhf1WWMjwrBCoJFz3opcKfwVG10+YYTEKs9ftGDa0GbpBGmdfJ1sRlEjHTgQo885jUvJJ8E1sHveil+o9FScgiEHAEfH6I+7GGw4DqqxODsodnD0BXvND1
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <DB9E7FCF442A3946800F18D7B8F088E4@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 57cbee5d-39b1-4f19-7f55-08d671a68ac4
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jan 2019 18:09:02.5365
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2528
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE5LTAxLTAzIGF0IDExOjQxIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBKYW4gMywgMjAxOSwgYXQgMTE6MDUgQU0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IE9uIFRodSwgMjAxOS0wMS0w
MyBhdCAxMDoyOSAtMDUwMCwgQ2h1Y2sgTGV2ZXIgd3JvdGU6DQo+ID4gPiBIaSBUcm9uZC0NCj4g
PiA+IA0KPiA+ID4gSSB3YXMgY3VyaW91cyBhYm91dCB0aGlzIG9uZSBiZWNhdXNlIHllc3RlcmRh
eSBJIHNhdyBldmlkZW5jZQ0KPiA+ID4gKGZvcg0KPiA+ID4gb3RoZXIgcmVhc29ucykgdGhhdCBy
cV9ieXRlc19zZW50IHdhc24ndCBhbHdheXMgemVyb2VkIHdoZW4gaXQNCj4gPiA+IHNob3VsZA0K
PiA+ID4gYmUuDQo+ID4gPiANCj4gPiA+IA0KPiA+ID4gPiBPbiBKYW4gMiwgMjAxOSwgYXQgNTo1
MyBQTSwgVHJvbmQgTXlrbGVidXN0IDx0cm9uZG15QGdtYWlsLmNvbT4NCj4gPiA+ID4gd3JvdGU6
DQo+ID4gPiA+IA0KPiA+ID4gPiBXaGVuIHdlIHJlc2VuZCBhIHJlcXVlc3QsIGVuc3VyZSB0aGF0
IHRoZSAncnFfYnl0ZXNfc2VudCcgaXMNCj4gPiA+ID4gcmVzZXQNCj4gPiA+ID4gdG8gemVyby4N
Cj4gPiA+ID4gDQo+ID4gPiA+IFNpZ25lZC1vZmYtYnk6IFRyb25kIE15a2xlYnVzdCA8dHJvbmQu
bXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KPiA+ID4gPiA+DQo+ID4gPiA+IC0tLQ0KPiA+ID4g
PiBuZXQvc3VucnBjL2NsbnQuYyB8IDEgLQ0KPiA+ID4gPiBuZXQvc3VucnBjL3hwcnQuYyB8IDEg
Kw0KPiA+ID4gPiAyIGZpbGVzIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0p
DQo+ID4gPiA+IA0KPiA+ID4gPiBkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy9jbG50LmMgYi9uZXQv
c3VucnBjL2NsbnQuYw0KPiA+ID4gPiBpbmRleCAyNGNiZGRjNDRjODguLjIxODlmYmM0YzU3MCAx
MDA2NDQNCj4gPiA+ID4gLS0tIGEvbmV0L3N1bnJwYy9jbG50LmMNCj4gPiA+ID4gKysrIGIvbmV0
L3N1bnJwYy9jbG50LmMNCj4gPiA+ID4gQEAgLTE3MzgsNyArMTczOCw2IEBAIHJwY194ZHJfZW5j
b2RlKHN0cnVjdCBycGNfdGFzayAqdGFzaykNCj4gPiA+ID4gCXhkcl9idWZfaW5pdCgmcmVxLT5y
cV9yY3ZfYnVmLA0KPiA+ID4gPiAJCSAgICAgcmVxLT5ycV9yYnVmZmVyLA0KPiA+ID4gPiAJCSAg
ICAgcmVxLT5ycV9yY3ZzaXplKTsNCj4gPiA+ID4gLQlyZXEtPnJxX2J5dGVzX3NlbnQgPSAwOw0K
PiA+ID4gDQo+ID4gPiBJIGFncmVlIHRoaXMgbGluZSBpcyBub3Qgc3VmZmljaWVudCwgYW5kIGl0
IHNob3VsZCBiZSBtb3ZlZC4NCj4gPiA+IE5vdCBldmVyeSByZXRyYW5zbWlzc2lvbiByZXF1aXJl
cyBhIHJlLWVuY29kZS4gSG93ZXZlciwgdGhlDQo+ID4gPiBwYXRjaCBkZXNjcmlwdGlvbiBzaG91
bGQgZXhwbGFpbiB0aGF0LCBhbmQgaXQgcHJvYmFibHkgbmVlZHMNCj4gPiA+IGEgRml4ZXM6IHRh
Zy4NCj4gPiA+IA0KPiA+ID4gQ2FuIHlvdSBub3cgYWxzbyByZW1vdmUgdGhlIHNhbWUgbGluZSBm
cm9tIHhwcnRfcmVxdWVzdF9pbml0DQo+ID4gPiBhbmQgeHBydF9pbml0X2JjX3JlcXVlc3QgPw0K
PiA+ID4gDQo+ID4gPiBBbHNvLCBJIG5vdGljZSB0aGF0IFVEUCBkb2VzIG5vdCB0b3VjaCBycV9i
eXRlc19zZW50LiBTaW5jZQ0KPiA+ID4gUkRNQSBhbHNvIGRvZXMgbm90IHVzZSBycV9ieXRlc19z
ZW50LCBtYXliZSB0aGUgc2FtZSBsaW5lDQo+ID4gPiBjYW4gYmUgcmVtb3ZlZCBmcm9tIHhwcnRy
ZG1hL3RyYW5zcG9ydC5jIGFuZA0KPiA+ID4geHBydHJkbWEvYmFja2NoYW5uZWwuYyA/DQo+ID4g
DQo+ID4gU3VyZS4NCj4gPiANCj4gPiBTbyBwbGVhc2Ugbm90ZSB0aGF0IHJxX2J5dGVzX3NlbnQg
PT0gMCBubyBsb25nZXIgbWVhbnMgInRoaXMNCj4gPiByZXF1ZXN0DQo+ID4gbmVlZHMgdG8gYmUg
cmV0cmFuc21pdHRlZCIgYW5kIHdlIG5vIGxvbmdlciB0ZXN0IGZvciBpdCBpbg0KPiA+IG5ldC9z
dW5ycGMvY2xudC5jLiBXZSBkbyBzdGlsbCBoYXZlIGEgY291cGxlIG9mIHRlc3RzIG9mDQo+ID4g
cnFfYnl0ZXNfc2VudA0KPiA+IGluIG5ldC9zdW5ycGMveHBydC5jIGFuZCBuZXQvc3VucnBjL3hw
cnRzb2NrLmMsIGJ1dCB0aG9zZSBhcmUgbW9yZQ0KPiA+IGFib3V0IGNoZWNraW5nIGlmIGEgdHJh
bnNtaXNzaW9uIG9mIHRoYXQgcmVxdWVzdCBpcyBjdXJyZW50bHkgaW4NCj4gPiBwcm9ncmVzcywg
aW4gd2hpY2ggY2FzZSB3ZSBkb24ndCB3YW50IHRvIHF1ZXVlIGFueXRoaW5nIGluIGZyb250IG9m
DQo+ID4gaXQNCj4gPiBvbiB0aGUgdHJhbnNtaXNzaW9uIHF1ZXVlLCBhbmQgd2UgZG9uJ3Qgd2Fu
dCB0byBhYm9ydCB0aGUNCj4gPiB0cmFuc21pc3Npb24NCj4gPiB1bmxlc3Mgd2UgYWxzbyBjbG9z
ZSB0aGUgc29ja2V0Lg0KPiA+IA0KPiA+IFRoZSBpbnRlbnRpb24gbm93IGlzIHRoYXQgaWYgd2Ug
a25vdyB0aGUgcmVxdWVzdCBuZWVkcw0KPiA+IHJldHJhbnNtaXNzaW9uDQo+ID4gKGR1ZSB0byBh
IHRyYW5zcG9ydCBjb25uZWN0aW9uIGxvc3Mgb3IgYSB0aW1lb3V0KSwgdGhlbiB3ZSBqdXN0IGFk
ZA0KPiA+IGl0DQo+ID4gdG8gdGhlIHRyYW5zbWlzc2lvbiBxdWV1ZS4NCj4gPiANCj4gPiANCj4g
PiA+ID4gCXAgPSBycGNfZW5jb2RlX2hlYWRlcih0YXNrKTsNCj4gPiA+ID4gCWlmIChwID09IE5V
TEwpIHsNCj4gPiA+ID4gZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBydC5jIGIvbmV0L3N1bnJw
Yy94cHJ0LmMNCj4gPiA+ID4gaW5kZXggNzM1NDdkMTdkM2M2Li45MDc1YWUxNTBhZTUgMTAwNjQ0
DQo+ID4gPiA+IC0tLSBhL25ldC9zdW5ycGMveHBydC5jDQo+ID4gPiA+ICsrKyBiL25ldC9zdW5y
cGMveHBydC5jDQo+ID4gPiA+IEBAIC0xMTUxLDYgKzExNTEsNyBAQCB4cHJ0X3JlcXVlc3RfZW5x
dWV1ZV90cmFuc21pdChzdHJ1Y3QNCj4gPiA+ID4gcnBjX3Rhc2sNCj4gPiA+ID4gKnRhc2spDQo+
ID4gPiA+IAlzdHJ1Y3QgcnBjX3hwcnQgKnhwcnQgPSByZXEtPnJxX3hwcnQ7DQo+ID4gPiA+IA0K
PiA+ID4gPiAJaWYgKHhwcnRfcmVxdWVzdF9uZWVkX2VucXVldWVfdHJhbnNtaXQodGFzaywgcmVx
KSkgew0KPiA+ID4gPiArCQlyZXEtPnJxX2J5dGVzX3NlbnQgPSAwOw0KPiA+ID4gPiAJCXNwaW5f
bG9jaygmeHBydC0+cXVldWVfbG9jayk7DQo+ID4gPiA+IAkJLyoNCj4gPiA+ID4gCQkgKiBSZXF1
ZXN0cyB0aGF0IGNhcnJ5IGNvbmdlc3Rpb24gY29udHJvbA0KPiA+ID4gPiBjcmVkaXRzIGFyZQ0K
PiA+ID4gPiBhZGRlZA0KPiA+ID4gDQo+ID4gPiBTbyBJJ20gbm90IGNvbnZpbmNlZCB0aGlzIGNv
dmVycyBldmVyeSBjYXNlLiBJIG5lZWQgc29tZQ0KPiA+ID4gdGltZSB0byBpbnZlc3RpZ2F0ZS4N
Cj4gPiANCj4gPiBJdCBzaG91bGQgbm9ybWFsbHkgY292ZXIgYWxsIGNhc2VzLiBBcyBJIHNhaWQs
IHRoZSBvbmx5IHJlbWFpbmluZw0KPiA+IHRlc3RzDQo+ID4gYXJlIGluIHhwcnQuYyBhbmQgIHhw
cnRzb2NrLmMNCj4gDQo+IEluIHRoZSBwYXRjaCBJIGhhdmUgdGhhdCByZW1vdmVzIHhwcnQ6OnRz
aF9zaXplLCBJJ20gdXNpbmcNCj4gcnFfYnl0ZXNfc2VudA0KPiB0byBmaWd1cmUgb3V0IHdoZW4g
dG8gaW5zZXJ0IGEgcmVjb3JkIG1hcmtlci4gRXZlcnkgb25jZSBpbiBhIHdoaWxlLA0KPiBpdA0K
PiBzdGlja3MgaW4gYSByZWNvcmQgbWFya2VyIHdoZXJlIGl0IHNob3VsZG4ndC4NCg0KSSdtIG5v
dCBzdXJlIEkgdW5kZXJzdGFuZC4gcmVxLT5ycV9ieXRlc19zZW50IGlzIGV4cGVjdGVkIHRvIGJl
IHplcm8NCndoZW4gd2UgY2FsbCBycGNfZW5jb2RlX2hlYWRlcigpLCB3aGljaCBpcyB3aGVyZSB3
ZSBjYWxsDQp4cHJ0X3NraXBfdHJhbnNwb3J0X2hlYWRlcigpLg0KDQpJZiB5b3Ugd2FudCB0byBy
ZW1vdmUgdHNoX3NpemUsIHRoZW4gSSB3b3VsZCBzdWdnZXN0IHJlcGxhY2luZw0KeHBydF9za2lw
X3RyYW5zcG9ydF9oZWFkZXIoKSB3aXRoIGFuIG9wZXJhdGlvbiBpbiBzdHJ1Y3QgcnBjX3hwcnRf
b3BzDQp0aGF0IHJldHVybnMgYSBwb2ludGVyIHRvIHRoZSBmaXJzdCB3b3JkIGluIHRoZSBzZW5k
IGJ1ZmZlciB0aGF0IGlzIG5vdA0KcmVzZXJ2ZWQgZm9yIHRyYW5zcG9ydCB1c2UuDQoNCi0tIA0K
VHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNl
DQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
