Return-Path: <SRS0=oebN=QK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FCB8C169C4
	for <linux-nfs@archiver.kernel.org>; Sun,  3 Feb 2019 15:00:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CF9512177E
	for <linux-nfs@archiver.kernel.org>; Sun,  3 Feb 2019 15:00:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="hhh4+H+s"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726584AbfBCPA1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 3 Feb 2019 10:00:27 -0500
Received: from mail-eopbgr810118.outbound.protection.outlook.com ([40.107.81.118]:55302
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726560AbfBCPA0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 3 Feb 2019 10:00:26 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=s4x9OaTJhWh35JtJV661FoAKJLen5GCkjRVMJ2RBWV4=;
 b=hhh4+H+syO5iIu7Z3AWqYoot/pVWLzcIF8QlUpcPZMI1j2h7Gy/t0aDJukG4K6S6IrlP9fFQ0Jm1hBncC4Q6tGy6CwdNgXlGGFMWWrfXBvlHjnyaNXF9FB428NezfBsydlyCBAhdfzpayvCHMqfC0xO5kbVn5KTBxB3FdB55LvY=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2254.namprd13.prod.outlook.com (52.135.93.155) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.13; Sun, 3 Feb 2019 15:00:20 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0%3]) with mapi id 15.20.1601.016; Sun, 3 Feb 2019
 15:00:20 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tom@talpey.com" <tom@talpey.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "simo@redhat.com" <simo@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
Thread-Topic: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
Thread-Index: AQHUumhq0Vii9L2mgU+TMhVuRlnQtaXLycIAgAFTxgCAARABAA==
Date:   Sun, 3 Feb 2019 15:00:20 +0000
Message-ID: <fdcf717bf7ccd45b29bd26162223afc07ba4ed2a.camel@hammerspace.com>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
         <20190201195747.11389.75164.stgit@manet.1015granger.net>
         <7a88add8-c1a3-72b5-cdcc-e6e7578e2ccc@talpey.com>
         <1EDAC62A-8F55-400B-A473-BF2ED133C2CF@oracle.com>
In-Reply-To: <1EDAC62A-8F55-400B-A473-BF2ED133C2CF@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2254;6:fOsmkklPtZ/Yn2uad2qplA2rvT8XSErmtHEMVGNSJB5w1bzxkqBMBwilgA/vJpJ0IJdkevIyvvd3U2IbYcc9blYgMz2z4h4PzwA4gZu5stnRSEQWIhcL9Ikl2Rr4TQ9eP0lmV+oS4QMalvjfrxageFaL7iiZaYAWYUncCTtHRaCXA0tR4+ZlL/he1GdnOpnfiS1pbf6xcYnMBPe+GPly4G94USlca8eqrTAyjdM35is4tMj+EA26xELhm6OZNwJN9L+5W9XTaBJKn9k35P/nT5DbS6QfmKxHe5go6v8D7f0N4eZJR6fbugzwFxC7Y1fGNwyFKwOUVJu7l/HCBQ/EL6EbW5WjhYoBYjz6DbbV6kWfLRZYrf2PKNjgHcFXfMd+4PoqdEyDGRb+iRI0G6RthersfnIP9p+l+V20Kynk6DQlNLG/mp4C6kAd9S7GnqqE4PXSZA8pjk1/Od362XNYWQ==;5:jLoMQi99UShEhL5n+6ep6NXsQOTB0Bml/UeeJxsuoZvBGGLGU/CEmt5+Y1Q74W1P8GXfEY/DolBEC/F+R/LxVYkwCfGH5vWyqZBcFRTu3c3RjLaMaw7c4EKITuM7y1DXvw/Rc3L4Ttb6lbyUWfK8VKsYg8Vn7G7NevwEHWnqxesFYIJjepyDjwn94kgztB6Pw7ss1SzfkfB7kKyXnVMpqQ==;7:/7P0l8bEb/HzJi4vxHs24HiSmRZF7DHDhnnEYafbCpceVgK0SIW0YoJCkr4vF5ZMVSp6IWSLpEfggJcUtV+qMHyS/ntxwv/ajhlIUSm5sN0fAQwVje5X6cE+1vmmLqPlXDCkiHuQEASJ5vzCtm3FPQ==
x-ms-office365-filtering-correlation-id: 4b021bd3-202c-4521-cac4-08d689e8514b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(7021145)(8989299)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2254;
x-ms-traffictypediagnostic: SN6PR13MB2254:
x-microsoft-antispam-prvs: <SN6PR13MB225435B0169953EB082CB958B86C0@SN6PR13MB2254.namprd13.prod.outlook.com>
x-forefront-prvs: 0937FB07C5
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(39830400003)(376002)(396003)(136003)(346002)(199004)(189003)(446003)(11346002)(26005)(102836004)(2906002)(71200400001)(71190400001)(7736002)(97736004)(86362001)(186003)(36756003)(8936002)(476003)(8676002)(81156014)(81166006)(2616005)(316002)(54906003)(110136005)(486006)(93886005)(256004)(68736007)(6506007)(53546011)(76176011)(99286004)(217873002)(6486002)(229853002)(6116002)(3846002)(6246003)(6436002)(6512007)(4326008)(66066001)(25786009)(53936002)(2501003)(14454004)(508600001)(305945005)(106356001)(105586002)(118296001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2254;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: A+goHC+0I7VZIORb4JgJAqQutaoUY9V5n8CAnbxYPW+9LvoJeHrj7Lt1CT5cHa0CbOK/X33QmxF5mBV8oCIQaqsxU7UAnFc99X915rhwk3wsFi99CbehJbOtxzdSlttxq4hOpCKcTBwnhcxJTIw5L459JB7xHY6diLhaodXAu6a/83iCmjApMIm0R4Y7RNxqGLXBB3ojxSaKByGAFzAErAQ/lgnfG/CH0rd+LyRuMs4BUS7AaXJmtXKUwCm4o4uKOW6LD9ejnfENdht/h8tA8rdmpabtYh/9Tp+bjam2lpcTUxZcWxsq+bzFtP/5RSRfP9//oTY7DUrW2fNorIjJVCRLi39OMWKfuhKclWPNEREkMF0GHHOERvtlrX71wbPFIWWTDqTYDb0LZxfDKNjNDkid4NKSXh5LPtYDP9XmCh0=
Content-Type: text/plain; charset="utf-8"
Content-ID: <7229A3722E6A4D4A8940B7AE7447959F@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 4b021bd3-202c-4521-cac4-08d689e8514b
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Feb 2019 15:00:20.7382
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2254
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gU2F0LCAyMDE5LTAyLTAyIGF0IDE3OjQ2IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBGZWIgMSwgMjAxOSwgYXQgOTozMCBQTSwgVG9tIFRhbHBleSA8dG9tQHRhbHBleS5jb20+
IHdyb3RlOg0KPiA+IA0KPiA+IE9uIDIvMS8yMDE5IDI6NTcgUE0sIENodWNrIExldmVyIHdyb3Rl
Og0KPiA+ID4gQnl0ZS1zd2FwcGluZyBjYXVzZXMgYSBDUFUgcGlwZWxpbmUgYnViYmxlIG9uIHNv
bWUgcHJvY2Vzc29ycy4NCj4gPiA+IFdoZW4NCj4gPiA+IGEgZGVjb2RlciBpcyBjb21wYXJpbmcg
YW4gb24tdGhlLXdpcmUgdmFsdWUgZm9yIGVxdWFsaXR5LCBieXRlLQ0KPiA+ID4gc3dhcHBpbmcg
Y2FuIGJlIGF2b2lkZWQgYnkgY29tcGFyaW5nIGl0IGRpcmVjdGx5IHRvIGEgcHJlLWJ5dGUtDQo+
ID4gPiBzd2FwcGVkIGNvbnN0YW50IHZhbHVlLg0KPiA+ID4gVGhlIGN1cnJlbnQgc2V0IG9mIHBy
ZS14ZHInZCBjb25zdGFudHMgaXMgbWlzc2luZyBzb21lIGNvbW1vbg0KPiA+ID4gdmFsdWVzDQo+
ID4gPiB1c2VkIGluIHRoZSBSUEMgaGVhZGVyLiBGaWxsIHRob3NlIG91dC4NCj4gPiA+IFNpZ25l
ZC1vZmYtYnk6IENodWNrIExldmVyIDxjaHVjay5sZXZlckBvcmFjbGUuY29tPg0KPiA+ID4gLS0t
DQo+ID4gPiAgaW5jbHVkZS9saW51eC9zdW5ycGMvYXV0aF9nc3MuaCB8ICAgIDUgKystDQo+ID4g
PiAgaW5jbHVkZS9saW51eC9zdW5ycGMveGRyLmggICAgICB8ICAgNjYgKysrKysrKysrKysrKysr
KysrKysrKysrLQ0KPiA+ID4gLS0tLS0tLS0tLS0tLS0NCj4gPiA+ICAyIGZpbGVzIGNoYW5nZWQs
IDQ1IGluc2VydGlvbnMoKyksIDI2IGRlbGV0aW9ucygtKQ0KPiA+ID4gZGlmZiAtLWdpdCBhL2lu
Y2x1ZGUvbGludXgvc3VucnBjL2F1dGhfZ3NzLmgNCj4gPiA+IGIvaW5jbHVkZS9saW51eC9zdW5y
cGMvYXV0aF9nc3MuaA0KPiA+ID4gaW5kZXggMzA0MjdiNy4uYWRjNGJlMiAxMDA2NDQNCj4gPiA+
IC0tLSBhL2luY2x1ZGUvbGludXgvc3VucnBjL2F1dGhfZ3NzLmgNCj4gPiA+ICsrKyBiL2luY2x1
ZGUvbGludXgvc3VucnBjL2F1dGhfZ3NzLmgNCj4gPiA+IEBAIC0xOSw3ICsxOSwxMCBAQA0KPiA+
ID4gICNpbmNsdWRlIDxsaW51eC9zdW5ycGMvc3ZjLmg+DQo+ID4gPiAgI2luY2x1ZGUgPGxpbnV4
L3N1bnJwYy9nc3NfYXBpLmg+DQo+ID4gPiAgLSNkZWZpbmUgUlBDX0dTU19WRVJTSU9OCQkxDQo+
ID4gPiArZW51bSB7DQo+ID4gPiArCVJQQ19HU1NfVkVSU0lPTiA9IDEsDQo+ID4gPiArCXJwY19n
c3NfdmVyc2lvbiA9IGNwdV90b19iZTMyKFJQQ19HU1NfVkVSU0lPTikNCj4gPiA+ICt9Ow0KPiA+
ID4gICAgI2RlZmluZSBNQVhTRVEgMHg4MDAwMDAwMCAvKiBtYXhpbXVtIGxlZ2FsIHNlcXVlbmNl
IG51bWJlciwNCj4gPiA+IGZyb20gcmZjIDIyMDMgKi8NCj4gPiA+ICBkaWZmIC0tZ2l0IGEvaW5j
bHVkZS9saW51eC9zdW5ycGMveGRyLmgNCj4gPiA+IGIvaW5jbHVkZS9saW51eC9zdW5ycGMveGRy
LmgNCj4gPiA+IGluZGV4IDc4NzkzOWQuLjY5MTYxY2IgMTAwNjQ0DQo+ID4gPiAtLS0gYS9pbmNs
dWRlL2xpbnV4L3N1bnJwYy94ZHIuaA0KPiA+ID4gKysrIGIvaW5jbHVkZS9saW51eC9zdW5ycGMv
eGRyLmgNCj4gPiA+IEBAIC0xNyw2ICsxNyw3IEBADQo+ID4gPiAgI2luY2x1ZGUgPGFzbS9ieXRl
b3JkZXIuaD4NCj4gPiA+ICAjaW5jbHVkZSA8YXNtL3VuYWxpZ25lZC5oPg0KPiA+ID4gICNpbmNs
dWRlIDxsaW51eC9zY2F0dGVybGlzdC5oPg0KPiA+ID4gKyNpbmNsdWRlIDxsaW51eC9zdW5ycGMv
bXNnX3Byb3QuaD4NCj4gPiA+ICAgIHN0cnVjdCBiaW9fdmVjOw0KPiA+ID4gIHN0cnVjdCBycGNf
cnFzdDsNCj4gPiA+IEBAIC03OSwzMSArODAsNDYgQEAgc3RydWN0IHhkcl9idWYgew0KPiA+ID4g
IAlidWYtPmJ1ZmxlbiA9IGxlbjsNCj4gPiA+ICB9DQo+ID4gPiAgLS8qDQo+ID4gPiAtICogcHJl
LXhkcidlZCBtYWNyb3MuDQo+ID4gPiAtICovDQo+ID4gPiAtDQo+ID4gPiAtI2RlZmluZQl4ZHJf
emVybwljcHVfdG9fYmUzMigwKQ0KPiA+ID4gLSNkZWZpbmUJeGRyX29uZQkJY3B1X3RvX2JlMzIo
MSkNCj4gPiA+IC0jZGVmaW5lCXhkcl90d28JCWNwdV90b19iZTMyKDIpDQo+ID4gPiAtDQo+ID4g
PiAtI2RlZmluZQlycGNfc3VjY2VzcwkJY3B1X3RvX2JlMzIoUlBDX1NVQ0NFU1MpDQo+ID4gPiAt
I2RlZmluZQlycGNfcHJvZ191bmF2YWlsCWNwdV90b19iZTMyKFJQQ19QUk9HX1VOQVZBSUwpDQo+
ID4gPiAtI2RlZmluZQlycGNfcHJvZ19taXNtYXRjaAljcHVfdG9fYmUzMihSUENfUFJPR19NSVNN
QVRDSCkNCj4gPiA+IC0jZGVmaW5lCXJwY19wcm9jX3VuYXZhaWwJY3B1X3RvX2JlMzIoUlBDX1BS
T0NfVU5BVkFJTCkNCj4gPiA+IC0jZGVmaW5lCXJwY19nYXJiYWdlX2FyZ3MJY3B1X3RvX2JlMzIo
UlBDX0dBUkJBR0VfQVJHUykNCj4gPiA+IC0jZGVmaW5lCXJwY19zeXN0ZW1fZXJyCQljcHVfdG9f
YmUzMihSUENfU1lTVEVNX0VSDQo+ID4gPiBSKQ0KPiA+ID4gLSNkZWZpbmUJcnBjX2Ryb3BfcmVw
bHkJCWNwdV90b19iZTMyKFJQQ19EUk9QX1JFUEwNCj4gPiA+IFkpDQo+ID4gPiAtDQo+ID4gPiAt
I2RlZmluZQlycGNfYXV0aF9vawkJY3B1X3RvX2JlMzIoUlBDX0FVVEhfT0spDQo+ID4gPiAtI2Rl
ZmluZQlycGNfYXV0aGVycl9iYWRjcmVkCWNwdV90b19iZTMyKFJQQ19BVVRIX0JBRENSRUQpDQo+
ID4gPiAtI2RlZmluZQlycGNfYXV0aGVycl9yZWplY3RlZGNyZWQNCj4gPiA+IGNwdV90b19iZTMy
KFJQQ19BVVRIX1JFSkVDVEVEQ1JFRCkNCj4gPiA+IC0jZGVmaW5lCXJwY19hdXRoZXJyX2JhZHZl
cmYJY3B1X3RvX2JlMzIoUlBDX0FVVEhfQkFEVkVSRikNCj4gPiA+IC0jZGVmaW5lCXJwY19hdXRo
ZXJyX3JlamVjdGVkdmVyZg0KPiA+ID4gY3B1X3RvX2JlMzIoUlBDX0FVVEhfUkVKRUNURURWRVJG
KQ0KPiA+ID4gLSNkZWZpbmUJcnBjX2F1dGhlcnJfdG9vd2VhawljcHVfdG9fYmUzMihSUENfQVVU
SF9UT09XRUFLKQ0KPiA+ID4gLSNkZWZpbmUJcnBjc2VjX2dzc2Vycl9jcmVkcHJvYmxlbQljcHVf
dG9fYmUzMihSUENTRUNfR1NTX0NSDQo+ID4gPiBFRFBST0JMRU0pDQo+ID4gPiAtI2RlZmluZQly
cGNzZWNfZ3NzZXJyX2N0eHByb2JsZW0JY3B1X3RvX2JlMzIoUlBDU0VDX0dTU19DVA0KPiA+ID4g
WFBST0JMRU0pDQo+ID4gPiAtI2RlZmluZQlycGNfYXV0aGVycl9vbGRzZXFudW0JY3B1X3RvX2Jl
MzIoMTAxKQ0KPiA+ID4gK2VudW0geGRyX2JlMzJfZXF1aXZhbGVudHMgew0KPiA+ID4gKwl4ZHJf
emVybwkJPSBjcHVfdG9fYmUzMigwKSwNCj4gPiA+ICsJeGRyX29uZQkJCT0gY3B1X3RvX2JlMzIo
MSksDQo+ID4gPiArCXhkcl90d28JCQk9IGNwdV90b19iZTMyKDIpLA0KPiA+IA0KPiA+IEl0IGlz
IGNsZXZlciB0byB1c2UgYW4gZW51bSB0byBwcmUtY29tcHV0ZSB0aGVzZSB2YWx1ZXMsIGJ1dA0K
PiANCj4gUGVyaGFwcyBub3QgY2xldmVyOyBpdCBpcyBhIGN1cnJlbnQgTGludXgga2VybmVsIGNv
ZGluZw0KPiBwcmFjdGljZSB0byB1c2UgYW4gZW51bSBpbiBmYXZvciBvZiBhIEMgbWFjcm8gZm9y
IGNvbnN0YW50cy4NCg0KU3VyZSwgYnV0IHdvbid0IHRoYXQgY29uZnVzZSAnc3BhcnNlJyBzdGF0
aWMgY2hlY2tpbmc/IFRoZXNlIGNvbnN0YW50cw0Kd2lsbCBubyBsb25nZXIgYXBwZWFyIGFzIGJl
aW5nIGJpZyBlbmRpYW4uDQoNCkRvZXNuJ3QgZ2NjJ3MgX19idWlsdGluX2Jzd2FwMzIoKSBhbHJl
YWR5IGNvbXB1dGUgdGhlIHJlc3VsdCBhdCBjb21waWxlDQp0aW1lIHdoZW4geW91IGZlZWQgaXQg
YSBjb25zdGFudCB2YWx1ZT8gQUZBSUNTIGl0IGlzIHN1cHBvc2VkIHRvLCB3aGljaA0KaXMgd2h5
IHdlIHVzZSBpdCBkaXJlY3RseSBpbiBpbmNsdWRlL3VhcGkvbGludXgvc3dhYi5oIGluc3RlYWQg
b2YgdXNpbmcNCmEgc3BlY2lhbCBjYXNlZCBfX2J1aWx0aW5fY29uc3RhbnRfcCgpLg0KDQotLSAN
ClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFj
ZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
