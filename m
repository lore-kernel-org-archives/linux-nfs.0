Return-Path: <SRS0=oebN=QK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E0EFC169C4
	for <linux-nfs@archiver.kernel.org>; Sun,  3 Feb 2019 18:58:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CAA15217D6
	for <linux-nfs@archiver.kernel.org>; Sun,  3 Feb 2019 18:58:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="lLQieSXu"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726840AbfBCS6r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 3 Feb 2019 13:58:47 -0500
Received: from mail-eopbgr750124.outbound.protection.outlook.com ([40.107.75.124]:16092
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726762AbfBCS6q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 3 Feb 2019 13:58:46 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=J43amQST4yGnRys3ZLBFivvPrgSB0phc0aIz6hYi7ME=;
 b=lLQieSXuiq++05LNVIxjufnXvsG05ob7Ro+Fuk/SphR2DDxH0akmXKDoX3yGpiIY8NxTcp0j+yZm7wPxvufvkelod1m2oq/0OjCMkElRBTDpE36FhAAtetCiMPgSw0pvcGxslcy5rmx3AovZuhQ5hyZr/L2Poft8gcOEyN2o4UM=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.14; Sun, 3 Feb 2019 18:58:42 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::f4e2:9f89:7255:36f0%3]) with mapi id 15.20.1601.016; Sun, 3 Feb 2019
 18:58:42 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "tom@talpey.com" <tom@talpey.com>,
        "simo@redhat.com" <simo@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
Thread-Topic: [PATCH RFC 04/10] SUNRPC: Add common byte-swapped RPC header
 constants
Thread-Index: AQHUumhq0Vii9L2mgU+TMhVuRlnQtaXLycIAgAFTxgCAARABAIAAHmsAgAAkLYA=
Date:   Sun, 3 Feb 2019 18:58:42 +0000
Message-ID: <6ffbfd6e51b31bc3467824493a77b78d052d4f4d.camel@hammerspace.com>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
         <20190201195747.11389.75164.stgit@manet.1015granger.net>
         <7a88add8-c1a3-72b5-cdcc-e6e7578e2ccc@talpey.com>
         <1EDAC62A-8F55-400B-A473-BF2ED133C2CF@oracle.com>
         <fdcf717bf7ccd45b29bd26162223afc07ba4ed2a.camel@hammerspace.com>
         <B5C94F11-2434-4114-9827-F3731E1A11D0@oracle.com>
In-Reply-To: <B5C94F11-2434-4114-9827-F3731E1A11D0@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2494;6:IKKfCghWFfU0vNATnx2dHWbSmeCssk32XaHvHUwvBVLDatuXsrjpbit4VT9PFnCIUeWkGKGo3cM7EiYwOePXCCHAhb0AvzRf2I+3Us864CaMp8WjwBlDJMDcntWOZCJmlqDTthCoz8dQocD3+RoAYOewTt9L5yhGXhvD5M2S/TiITlyZpVKnNtIB7Zf5XchQtWNjMxhlfvg3mkw+/66lbiqvkCpW46wvv8ZlR/D4ypRiw1rRrCAIgESqozORkdYCnu+WqMmAoMaWTrD+LEqHyKh1ZNSWwWjfAaVZgYVYStpDwFpAJd4aHjm4I7iy3r69LdGOud72zmIuN+Y52HPeRNVT2SZ+zkd2qEtP6lbkEQYsreOn6tK7dCUZDmo1kpZRkegP8LfEukKjs6oQUjkaM7GdDxevqCE2r6ltfQpMna7br+/kaY62GOlB7VLj/12rQfUMXBPmcDn6IhLTYs3Atg==;5:86g14syidZzpfX/NyqIMTjZIG1nbYxOk2QSY5LTMJ5iBNTzqAP0DsC0DltODPg+hGiH/MPJB/Ug3Y+SH0PvHOseltSjPmL8x3SNWIi9ZjFQVeQyCeJJ9Hk6GjVPvjFFsljcwlHERqDIrfUaEzWDiGEV+Q/xHfMgiYrvK/4KNtXBl4RntiCxiG2P0iaoxxUS3740rvNP05e6lH1Xp77wyjQ==;7:PdXyzZVg4cCPyjBqoUaaM2E72XqlrXMjOY6OEi4wLmZrIIKztYTxX/q5CarnM+C3aaf8JfofvspeJioXkEvK6cYhUg8QuH87mSg8VkfsEdeOsEMmDWgnFG26n6MB4iBtRcMghhEuVYCRK+y8Wwj04A==
x-ms-office365-filtering-correlation-id: 206b0afe-cefe-4fda-2c5d-08d68a099dc9
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(7021145)(8989299)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2494;
x-ms-traffictypediagnostic: SN6PR13MB2494:
x-microsoft-antispam-prvs: <SN6PR13MB24946A997DE2394D6678F403B86C0@SN6PR13MB2494.namprd13.prod.outlook.com>
x-forefront-prvs: 0937FB07C5
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(136003)(396003)(366004)(39830400003)(189003)(199004)(476003)(11346002)(2616005)(446003)(105586002)(486006)(2501003)(106356001)(8936002)(316002)(76176011)(4744005)(86362001)(54906003)(6512007)(229853002)(25786009)(6486002)(99286004)(6916009)(4326008)(6246003)(6436002)(5640700003)(217873002)(66066001)(97736004)(256004)(71200400001)(71190400001)(508600001)(14454004)(118296001)(305945005)(7736002)(2351001)(53936002)(6506007)(81166006)(2906002)(53546011)(102836004)(186003)(36756003)(8676002)(26005)(81156014)(68736007)(93886005)(3846002)(6116002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2494;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: HBkmTcdpHxuChCNIwDKpf2eyNfz8oIXNyZNakDXpXdTmVgML2hY+00NZf0CYqSFWDpaoalSw19BNtuyoeqqf/tsIMqW5DAhNF3p+1x3ytSrfJOs5pON+/6xBXLcbFfcYGlhpw9UjXfj/+iC0VdPyRUEOnFb1bxELa0FjpfT5F6hIAA3FnsfKlbuIalm5I2EG+kBp58FJBWLg3sEvLeGN8leCh+O4HCqmRo/zi+U/2A/jrzP3JIlkA9PAV3+h0ZugcN5TBYf13VymRWTfFcmg5hbrCrCz2dBBYOWgxs0xNSl8vFIDPbfyUlIVAF6x5jnBSR1TtAm0S4PQU/uqMjglGhKnWKzJxALf/P3z8pZ3kBlt/JBggW9Or0pnp0A4BT15Ca4LS4U6xSPAgjtd66Dkpzev5bEMpEIgqzn48wmvV7Q=
Content-Type: text/plain; charset="utf-8"
Content-ID: <4BFC93AB3DDE004D8ACAC13702B91845@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 206b0afe-cefe-4fda-2c5d-08d68a099dc9
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Feb 2019 18:58:42.4988
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2494
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gU3VuLCAyMDE5LTAyLTAzIGF0IDExOjQ5IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBGZWIgMywgMjAxOSwgYXQgMTA6MDAgQU0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IERvZXNuJ3QgZ2NjJ3MgX19i
dWlsdGluX2Jzd2FwMzIoKSBhbHJlYWR5IGNvbXB1dGUgdGhlIHJlc3VsdCBhdA0KPiA+IGNvbXBp
bGUNCj4gPiB0aW1lIHdoZW4geW91IGZlZWQgaXQgYSBjb25zdGFudCB2YWx1ZT8gQUZBSUNTIGl0
IGlzIHN1cHBvc2VkIHRvLA0KPiA+IHdoaWNoDQo+ID4gaXMgd2h5IHdlIHVzZSBpdCBkaXJlY3Rs
eSBpbiBpbmNsdWRlL3VhcGkvbGludXgvc3dhYi5oIGluc3RlYWQgb2YNCj4gPiB1c2luZw0KPiA+
IGEgc3BlY2lhbCBjYXNlZCBfX2J1aWx0aW5fY29uc3RhbnRfcCgpLg0KPiANCj4gVGhlIHJldHVy
biB0eXBlIG9mIF9fYnVpbHRpbl9ic3dhcDMyIGlzIHVpbnQzMl90LCBub3QgX19iZTMyLg0KPiAN
Cj4gSSB3aWxsIHN0aWNrIHdpdGggY3B1X3RvX2JlMzIoKSwgYW5kIHNpbXBseSBhZGQgdGhlIG1p
c3NpbmcNCj4gY29uc3RhbnRzLg0KPiANCg0KY3B1X3RvX2JlMzIoKSBpcyBhIG1hY3JvIHRoYXQg
ZXhwYW5kcyB0byBfX2J1aWx0aW5fYnN3YXAzMigpIHBsdXMgYQ0KY2FzdCBmb3IgbW9zdCBhcmNo
aXRlY3R1cmVzIG9uIGdjYy4NCg0KV2hhdCBJJ20gc2F5aW5nIGlzIHRoYXQgYXMgZmFyIGFzIEkg
a25vdywgdGhlIGV4aXN0aW5nICNkZWZpbmVzIHNob3VsZA0KY29tcGlsZSBpbnRvIGJlMzIgY29u
c3RhbnRzIGJ5IGRlZmF1bHQsIGFzIHNob3VsZCBhbnkgY2FsbCBvZiB0aGUgZm9ybQ0KY3B1X3Rv
X2IzMig8Y29uc3QgZXhwcmVzc2lvbj4pIGFuZCBodG9ubCg8Y29uc3QgZXhwcmVzc2lvbj4pLg0K
DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhh
bW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
