Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21B7CC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 18:40:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A617A20867
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 18:40:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="aa/c4LCd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A617A20867
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725861AbeLAFu2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 00:50:28 -0500
Received: from mail-eopbgr750127.outbound.protection.outlook.com ([40.107.75.127]:39409
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725817AbeLAFu2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Dec 2018 00:50:28 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=Xo1OOpCNxmfu/N9kdZ/JpeFyq1ZAxM8DYvGH81DjPww=;
 b=aa/c4LCdCARaad7NsyVkggV+lru1ipd4rm/EwfVrm3RZCAKv27GKAprEZOKtWLyNdJ66/6axObp4habRoZgXv0RaJwryKIBklU1zICuD/yfnZTfKYIXFJdyRxNJZKrFc2rvab2NQJlUglhzcsglFlir2CS5STd3jwqvKwaTRiqw=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2432.namprd13.prod.outlook.com (52.135.95.24) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1404.8; Fri, 30 Nov 2018 18:40:13 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.011; Fri, 30 Nov 2018
 18:40:13 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: kerberos with v4.20-rc4 heads up
Thread-Topic: kerberos with v4.20-rc4 heads up
Thread-Index: AQHUiM9csmuy30v2y0iVh4XfGDc7/aVopp6A
Date:   Fri, 30 Nov 2018 18:40:12 +0000
Message-ID: <d1f07dd56fff6ee1888ca51b1b263825c3a9fd04.camel@hammerspace.com>
References: <028A9DC5-4136-413C-8A79-F32F997A8AB1@oracle.com>
In-Reply-To: <028A9DC5-4136-413C-8A79-F32F997A8AB1@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2432;6:91OpigarMjZIYNlL0DyYPRasdFs1WLxnwTCZ0qh9Inj/orb/2+kO3cmXmTG8wW6RKJ+oggfSdnCRGPhRW3qg7O2XmfMkoVwR83AzHTXP2HlOGiWTAQFNi2/pfXtPOS3z6YX+GoK+VhDtrmx3+dNQ5XLE0n6EpOtBOPaRswXysKC4i15Ip429rIaS0EwwZHKSIWnrSgzrnG3NA06YlxBH05paziN5RBW02aQTdHUmm8aXyWRLK330oRLnRhSfbhZfnTjK8HeXqdoDAPmIfMFUjQUOg6NU0LMpsqfipamvQpNn8J/E2BRsFf5TmyX64aH5CqQBn5IwV86vNj9mBnYIimeC9BNeA7rw0q3YY/095Dv8+1w1q7ZTIsjYFnP5L7QB/xJkLjsd+FVqqgx8sfeGmQndwjOUnZhzgJzs6x8xgPWm6lB6YbNAHVqC7O5ul29TLMC6a6i+ctMZrIXk8+47rw==;5:RGXNdldkOnG6FQfSCvN/S2884gVW+TeRfib+azw9TsnacaSPjM7U1avSXb0dYMzuQY270pQYWzOpkcgyhd0w8trIb4pBgtHWCpZ4UdFnaZMgj9ihpalslRnwGQnGlr0ovFqe99iem3UpADrUV6KB8cmUnXY4PUr+Cg778H21Kq8=;7:EllpvyQ1offz1WbGLmcDDUWpRWDqGDRfEkNnN2RydU/p4Kz06aTHy5xDLS9oIRv3LUstS+WjM9cRxe+Bp3OSQB0WKn9Jm4NAHKIIoy3FBpBKtSTgd72BvDcHG7mFiTUhgZC1hAhlKXlY1iwLfVgBlg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 5eb16393-3431-4bf2-fba2-08d656f3439b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2432;
x-ms-traffictypediagnostic: SN6PR13MB2432:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB24323B9450823EE8D6C13D86B8D30@SN6PR13MB2432.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(3002001)(10201501046)(93006095)(93001095)(3231453)(999002)(944501466)(52105112)(148016)(149066)(150057)(6041310)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123564045)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2432;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2432;
x-forefront-prvs: 087223B4DA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39830400003)(346002)(366004)(396003)(376002)(189003)(199004)(186003)(6512007)(5640700003)(2906002)(99286004)(6916009)(53936002)(2351001)(478600001)(6246003)(256004)(14444005)(86362001)(71200400001)(14454004)(71190400001)(6506007)(53546011)(102836004)(11346002)(76176011)(446003)(68736007)(476003)(486006)(2616005)(66066001)(118296001)(25786009)(5660300001)(305945005)(7736002)(4001150100001)(97736004)(316002)(36756003)(8936002)(575784001)(3846002)(4326008)(6116002)(106356001)(105586002)(6436002)(6486002)(81156014)(81166006)(2501003)(8676002)(26005)(229853002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2432;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: xYc++ThUk/EuJmC3dn93dLQqN41MwUaIo+Hs6nSGxmmXjw9JPfE93grxBrXQ6Uqos3mAXFGDpoJ9V+uQgswA5dm83Xuz84xY68UcDcoccl2bLyzKsbKzpYDlKchqRris3ToID3ESOGaFIlrT5vRMek1wXQpwCjp7xbznIrihiV2Gx2kMHJFM/F5vx7LZ0Ed5dgQAc9bJsGS6x4EQzV4TM2mmosjApbpIbYHSszQbGk6VPtFCp8XZSn8CrbEcg4aaExvF0Na1klJhphvwP0Tp+s0rgHfLfFPiLaU6msxyOJPhT2MuE4lpStGqGtWCp/lltq86xtn+5GjUHPEnDX+SaHoRStRTDznLOut9ef6apM8=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <EAFF6E5FE8919A4CB19F4F904089CA10@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 5eb16393-3431-4bf2-fba2-08d656f3439b
X-MS-Exchange-CrossTenant-originalarrivaltime: 30 Nov 2018 18:40:13.0000
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2432
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTMwIGF0IDEyOjA4IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
SGktDQo+IA0KPiBJJ20gdGVzdGluZyBrcmI1L2tyYjVpL2tyYjVwIHdpdGggc3RvY2sgdjQuMjAt
cmM0IGFuZCBORlMvVENQLg0KPiBUaGUgd29ya2xvYWQgaXMgc3ludGhldGljOg0KPiANCj4gIC9o
b21lL2NlbC9iaW4vaW96b25lIC1NIC0rdSAtaTAgLWkxIC1zMWcgLXI4ayAtdDE2IC1jDQo+IA0K
PiBUaGUgY2xpZW50IGlzIGEgMTItY29yZSBYZW9uIHN5c3RlbS4NCj4gDQo+IA0KPiBJJ20gc2Vl
aW5nIGFsbCBraW5kcyBvZiBzeW1wdG9tczoNCj4gDQo+ICAtIG1lbW9yeSBsZWFrczogYnZlYyBh
bmQgZW5jX3BhZ2VzIGFyZSBsZWFraW5nDQo+IA0KPiAgLSBFQkFETVNHIGlzIHJlcG9ydGVkIHRv
IHVzZXIgc3BhY2UNCj4gDQo+ICAtIGRhdGEgY29ycnVwdGlvbg0KPiANCj4gIC0gY29ubmVjdCBk
ZWFkbG9ja3MgcmVzdWx0aW5nIGluIGEgbW91bnQgaGFuZw0KPiANCj4gIC0gaW52YWxpZCBzb2Z0
IElSUSByZWNlaXZlIGJ1ZmZlciB3YXJuaW5ncw0KPiANCg0KRG9lcyB0aGUgZm9sbG93aW5nIHBh
dGNoIGhlbHA/DQoNCjg8LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLQ0KRnJvbSA4ZmY0Y2Q5ZjBmNjkxMmUxNGY2NTczNzFiNmI3ZWVjZjZkMjA5MWVlIE1vbiBT
ZXAgMTcgMDA6MDA6MDAgMjAwMQ0KRnJvbTogVHJvbmQgTXlrbGVidXN0IDx0cm9uZC5teWtsZWJ1
c3RAaGFtbWVyc3BhY2UuY29tPg0KRGF0ZTogRnJpLCAzMCBOb3YgMjAxOCAxMjo0ODo0NyAtMDUw
MA0KU3ViamVjdDogW1BBVENIXSBTVU5SUEM6IGNhbGxfY29ubmVjdF9zdGF0dXMoKSBtdXN0IGhh
bmRsZSB0YXNrcyB0aGF0IGdvdA0KIHRyYW5zbWl0dGVkDQoNCklmIGEgdGFzayBmYWlsZWQgdG8g
Z2V0IHRoZSB3cml0ZSBsb2NrIGluIHRoZSBjYWxsIHRvIHhwcnRfY29ubmVjdCgpLCB0aGVuDQpp
dCB3aWxsIGJlIHF1ZXVlZCBvbiB4cHJ0LT5zZW5kaW5nLiBJbiB0aGF0IGNhc2UsIGl0IGlzIHBv
c3NpYmxlIGZvciBpdA0KdG8gZ2V0IHRyYW5zbWl0dGVkIGJlZm9yZSB0aGUgY2FsbCB0byBjYWxs
X2Nvbm5lY3Rfc3RhdHVzKCksIGluIHdoaWNoDQpjYXNlIGl0IG5lZWRzIHRvIGJlIGhhbmRsZWQg
YnkgY2FsbF90cmFuc21pdF9zdGF0dXMoKSBpbnN0ZWFkLg0KDQpTaWduZWQtb2ZmLWJ5OiBUcm9u
ZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBoYW1tZXJzcGFjZS5jb20+DQotLS0NCiBuZXQv
c3VucnBjL2NsbnQuYyB8IDcgKysrKysrKw0KIDEgZmlsZSBjaGFuZ2VkLCA3IGluc2VydGlvbnMo
KykNCg0KZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMvY2xudC5jIGIvbmV0L3N1bnJwYy9jbG50LmMN
CmluZGV4IGFlM2I4MTQ1ZGEzNS4uZTM1ZDY0MjU1OGU3IDEwMDY0NA0KLS0tIGEvbmV0L3N1bnJw
Yy9jbG50LmMNCisrKyBiL25ldC9zdW5ycGMvY2xudC5jDQpAQCAtMTkxNSw2ICsxOTE1LDEzIEBA
IGNhbGxfY29ubmVjdF9zdGF0dXMoc3RydWN0IHJwY190YXNrICp0YXNrKQ0KIAlzdHJ1Y3QgcnBj
X2NsbnQgKmNsbnQgPSB0YXNrLT50a19jbGllbnQ7DQogCWludCBzdGF0dXMgPSB0YXNrLT50a19z
dGF0dXM7DQogDQorCS8qIENoZWNrIGlmIHRoZSB0YXNrIHdhcyBhbHJlYWR5IHRyYW5zbWl0dGVk
ICovDQorCWlmICghdGVzdF9iaXQoUlBDX1RBU0tfTkVFRF9YTUlULCAmdGFzay0+dGtfcnVuc3Rh
dGUpKSB7DQorCQl4cHJ0X2VuZF90cmFuc21pdCh0YXNrKTsNCisJCXRhc2stPnRrX2FjdGlvbiA9
IGNhbGxfdHJhbnNtaXRfc3RhdHVzOw0KKwkJcmV0dXJuOw0KKwl9DQorDQogCWRwcmludF9zdGF0
dXModGFzayk7DQogDQogCXRyYWNlX3JwY19jb25uZWN0X3N0YXR1cyh0YXNrKTsNCi0tIA0KMi4x
OS4yDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIs
IEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
