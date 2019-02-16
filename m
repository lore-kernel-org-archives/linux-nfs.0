Return-Path: <SRS0=NyTm=QX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CA68C43381
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Feb 2019 14:46:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1B8D1222E6
	for <linux-nfs@archiver.kernel.org>; Sat, 16 Feb 2019 14:46:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="B6JIc9Av"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728750AbfBPOqw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 16 Feb 2019 09:46:52 -0500
Received: from mail-eopbgr730138.outbound.protection.outlook.com ([40.107.73.138]:46669
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728465AbfBPOqw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 16 Feb 2019 09:46:52 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=q7cQhaGGACx2k/o2UnXW+llsamB72LPP4napadArjTc=;
 b=B6JIc9Avxi7NqEVtiuaQJv3u+LWnStY9tAuOWUR9CwKQm/Pfpb3JzUrtntQc0N9GtBiJDDQw70+ao5gMEcEHgsK4vD20ni5P1faBZ6BkPR7wb4oCevBgyx9dP03EboxLAYVrcEUfTJvyVe9KT/tiCzcsqV5/uDO/0KnqPeHd+jA=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2429.namprd13.prod.outlook.com (52.135.94.161) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.9; Sat, 16 Feb 2019 14:46:45 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.008; Sat, 16 Feb 2019
 14:46:45 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tibbs@math.uh.edu" <tibbs@math.uh.edu>,
        "bcodding@redhat.com" <bcodding@redhat.com>
CC:     "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Chuck.Lever@oracle.com" <Chuck.Lever@oracle.com>
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
Thread-Topic: Need help debugging NFS issues new to 4.20 kernel
Thread-Index: AQHUtBBQLoOJiO8U1kuiVnwIPcpCS6W+1kMAgAGQXx+AES4Tb4ABK8OAgACVO9yAAO6cgIAARnn4gAFZDoCAC4+M14ABMVkA
Date:   Sat, 16 Feb 2019 14:46:45 +0000
Message-ID: <e8887651e91b1d0110cab2330a03e3e3ccef742b.camel@hammerspace.com>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
         <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
         <ufak1isms71.fsf@epithumia.math.uh.edu>
         <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
         <FC712F54-5A7A-436D-B076-936B29C013F4@redhat.com>
         <87imxwab12.fsf@hippogriff.math.uh.edu>
         <662CE7B3-235E-4E2D-9C8C-0F6233F3085F@redhat.com>
         <87d0o3aadg.fsf@hippogriff.math.uh.edu>
         <B730E8AE-AFA3-4CE7-9103-FCCC35C37EDD@redhat.com>
         <ufa4l943i6v.fsf@epithumia.math.uh.edu>
In-Reply-To: <ufa4l943i6v.fsf@epithumia.math.uh.edu>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 28380de0-c3f4-4edd-cf0b-08d6941d92dd
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2429;
x-ms-traffictypediagnostic: SN6PR13MB2429:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNDI5OzIzOnBoanNlM2dOa0g5MWlESnZkb0s5RzZvcEU3?=
 =?utf-8?B?d1JtQ3J3OWlrZUljcDg5OVZiSkp1SzRUcEZkMkN6aWxLaFlwVmJVYnZUWDZQ?=
 =?utf-8?B?ay9Vb1ZuMy82cEhHZUErMHZoWDQzTm15QzhHcm5ZZzJTaXU3MXlJdXFBTzEy?=
 =?utf-8?B?dk1Uc2xwcnE3R0Uxb1hpaUNsUmRieDNXNC9yWWhlK0loRVhybEJhYzJOUFlz?=
 =?utf-8?B?ZHRYb2ZkWE81cVpwYk8zNGk1RkE0bFZnMlJ5cFhYRWVUaHh6enNzSmFHUU9o?=
 =?utf-8?B?M2t0L1FuVncwbDU3MWNMamw4aUNYSVFUcjFsWjMwRU1tWS9UY1lnbzBoKzR4?=
 =?utf-8?B?NVprdjhjK1BDUnVNT2J2a0dVbXFJQjdRRU9vTzRyT0tNSHV6cER6LzFOcG40?=
 =?utf-8?B?Q2FYUmpSK1lPcHVFdWVyZHM5cWdGVlNxQTFYc3Y2dUd4TStIb1ViVHNRVEU3?=
 =?utf-8?B?b1FPcnNjZVowSm52T3hodGpuVno3UC9RcXJUZ1dCYXNPaUlOalVUOXJxWGhO?=
 =?utf-8?B?NWhERkNGcWFnZ3laTTdGZXRpWnlZN2RCMXlXYWtxcXNKS2NPTWtUUVpHem5v?=
 =?utf-8?B?eFRlZTNBVnQyN1RQSkxCNHBybWJ2MXhHdnYrSXpzdkVFTkE1VkU4OXI1RXdj?=
 =?utf-8?B?eWswbnZCUStaRk5lTVErenpETTF5TDNaYUl1cUxucGxIdlFvSHQ3bHJBc2x1?=
 =?utf-8?B?THhBMVNmcVg1UHhtMGNnc0xxS0tHcVpYbGlRWU1JVm1NbU5wY3E3M0FMOW5V?=
 =?utf-8?B?WmtMYWd0YlNpZExMRnpCNHNnWFIwZXgvRzZtcTIvcWxhSWVBNEpZUmZ5SE9y?=
 =?utf-8?B?YkcxaTJuTmhZeUtXaU1qRkJFRk1NSzUyMDF3OVRTWm9kRG9HaFZNRHpIbC9v?=
 =?utf-8?B?eUZzRVdUYmw3M0hhdllmZ3FIOGdVejloeWY4SjFLRW9nRkNpaDdvVksrWUdT?=
 =?utf-8?B?WXJuOVpuYnRLS0RITTN1S3k4QXBQWittSkJOZnFodE81RGxnRUpTRS9xc0JJ?=
 =?utf-8?B?VWVkRUdWUFBQRlZnVmVuNWMvZFB5V24xRzVFYkRld0JUUUhqeUQ0VFAzbFdQ?=
 =?utf-8?B?YXhsc21PLzBMeU9lS0F1QUJXUVJTYzZiZVpBSFZjTjRMb3dHcDQ0MWVnUlNM?=
 =?utf-8?B?czB2d0xucjV1STE4eGs4VnJxK3huU1BOeGkvQVRQeHZFZk94ZmtzTGg5ckJP?=
 =?utf-8?B?Q1F5Z3JvWktxVkZCVnRHSUFoM2JYWjhzTGxvY21LWGtSdGNka2lhU28vVHp3?=
 =?utf-8?B?NXZ1OUVINHI3ZWRxaFJLcW9lc2Q2eGF3bWd1cDlQVTY3QzNuQnI5dzR3NVZE?=
 =?utf-8?B?MmtZTmdZSFJ2aWsxT1FNeFJneDB0WFltRHN6TmJHcnF1bWUvb3NoRlovNDZJ?=
 =?utf-8?B?NEcxTGlQQVhFK3BWWkJFVDNGNE52WUNOREx3dUo5c2tWcmdpMjhUNWlsYVNT?=
 =?utf-8?B?UDJyRVFJcXIwQ2Vpc1VwY0drL0dFU0hqOVdGL3pUNko0T0NjRTRPanFxTDNQ?=
 =?utf-8?B?WGNFdlNGS2dSbWxmV0pBb2pEbGZmMnpNL0hjNHl3akl2dTg2ay96WGtvaU94?=
 =?utf-8?B?b1EzL3ptdlVOM0lmWTk5RnFkZXpBaHUzSGdaRXlJNkExMFRsdkJGSHFDTXR4?=
 =?utf-8?B?NDJxN01CczNTelk3eStIOTRFdXVjUHdXR09abXRJbXRsYTFSN3dCSmZnPT0=?=
x-microsoft-antispam-prvs: <SN6PR13MB2429E31A31AD78DC8B52D00EB8610@SN6PR13MB2429.namprd13.prod.outlook.com>
x-forefront-prvs: 0950706AC1
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(346002)(376002)(136003)(199004)(189003)(5660300002)(86362001)(2616005)(81156014)(2171002)(66066001)(8676002)(508600001)(68736007)(97736004)(25786009)(36756003)(6436002)(4326008)(8936002)(76176011)(53936002)(2906002)(229853002)(2501003)(6246003)(6346003)(446003)(3846002)(256004)(93886005)(81166006)(105586002)(106356001)(7736002)(186003)(118296001)(26005)(6116002)(14444005)(71190400001)(486006)(71200400001)(54906003)(6506007)(6512007)(102836004)(14454004)(99286004)(305945005)(476003)(110136005)(6486002)(11346002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2429;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: +twyshPrIOscTXza2VgTJoH6GdIHM1mXljxY66Ay/k73pPpi6lRY1VViZG4jSVY30+fbuqLJGlZPXSkybLOTYfCZbAAefCYCD8BqQW9dtd1jW0YY/MtAPEBvMbRRw5r8iWVkx0xPh5lqB0syUq9eOEL1+wb+3RnFoI+KAURa0iJ9Cg361XEJ40/KxdySPcvBSpvODA3FV2CU/YbFbk9emU7mT5nmIwSZwjQaSAEgkuzMb/wxEguaDkn1V/hxbn2ohxpoYRXufDv52J5loYDbZWXr6eWg1Et1bxqn7Q8eXIkc6+G/DAYKBILUApZmm+uN46TTw2jpR1LygwxPfZTP8+vywri3D7e9kGvAL0LBRpvyimOK9esZQ9f5D/5ARmIrNV/By5akeSTS4Fu+2/TZKwxrfgdJmIciWY1WxY207xQ=
Content-Type: text/plain; charset="utf-8"
Content-ID: <EFD9A7B1FC6DAF40A76D0A71B06D00BE@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 28380de0-c3f4-4edd-cf0b-08d6941d92dd
X-MS-Exchange-CrossTenant-originalarrivaltime: 16 Feb 2019 14:46:45.6665
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2429
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE5LTAyLTE1IGF0IDE0OjMzIC0wNjAwLCBKYXNvbiBMIFRpYmJpdHRzIElJSSB3
cm90ZToNCj4gPiA+ID4gPiA+ICJCQyIgPT0gQmVuamFtaW4gQ29kZGluZ3RvbiA8YmNvZGRpbmdA
cmVkaGF0LmNvbT4gd3JpdGVzOg0KPiANCj4gQkM+IEhtbS4uIGNvbW1pdCBjNDQzMzA1NTI5ZDFk
M2QzYmVlMGQ2OGZkZDE0YWU4OTgzNWUwOTFmIGNoYW5nZWQNCj4gQkM+IHhzX3JlYWRfc3RyZWFt
X3JlcGx5KCkgdG8gcmV0dXJuIHJlY3YuY29waWVkIGluc3RlYWQgb2YgInJldCIgdG8NCj4gQkM+
IHhwcnRfY29tcGxldGVfcnFzdCgpLi4NCg0KVGhhdCdzIGEgZ29vZCB0aGluZy4geHBydF9jb21w
bGV0ZV9ycXN0KCkgcmVhbGx5IGRpc2xpa2VzIG5lZ2F0aXZlDQplcnJvciB2YWx1ZXMuDQoNCj4g
QkM+IFlvdSBjb3VsZCB0cnkgcmV2ZXJ0aW5nIHRoYXQgY29tbWl0IGFuZCBzZWUgaWYgdGhlIHBy
b2JsZW0gZ29lcw0KPiBCQz4gYXdheS4uDQo+IA0KPiBTbyBwYXRjaGluZyBhIHJldmVydCBvZiB0
aGF0IGludG8gNC4yMC43IHdhcyBiZXlvbmQgbWUsIGJ1dCBJDQo+IHJlY2VpdmVkDQo+IHNvbWUg
aGVscCBmcm9tIEplcmVteSBDbGluZSBvbiBJUkMgKGluICNmZWRvcmEta2VybmVsKSBhbmQgZW5k
ZWQgdXANCj4gd2l0aA0KPiBhIHBhdGNoIEknbGwgaW5jbHVkZSBhdCB0aGUgZW5kLiAgU28gZmFy
IGl0IGRvZXMgc2VlbSB0byBiZSBiZXR0ZXIsDQo+IGJ1dA0KPiBiZWNhdXNlIG9mIHNlY3VyZSBi
b290IGFubm95YW5jZXMgSSBoYXZlbid0IGJlZW4gYWJsZSB0byByb2xsIGl0IG91dA0KPiBtb3Jl
IGdlbmVyYWxseS4gIEhvd2V2ZXIsIGl0IGhhcyBiZWVuIHN0YWJsZSBmb3IgYSB3ZWVrIG9uIGEg
ZmV3DQo+IGhvc3RzDQo+IHdoaWNoIGhhdmUgYmVlbiBwcm9ibGVtYXRpYyB3aXRoIHN0b2NrIDQu
MjAuNi4NCj4gDQo+IEkgd2lsbCBjb250aW51ZSB0byB0ZXN0LCBidXQgaG9wZWZ1bGx5IHRoaXMg
aGVscHMgZm9sa3MgdG8gdW5kZXJzdGFuZA0KPiB3aGF0J3MgaGFwcGVuaW5nLg0KPiANCg0KSG1t
Li4uIERvZXMgdGhlIGZvbGxvd2luZyBwYXRjaCBoZWxwIGF0IGFsbD8NCi0tLQ0KZGlmZiAtLWdp
dCBhL25ldC9zdW5ycGMveHBydHNvY2suYyBiL25ldC9zdW5ycGMveHBydHNvY2suYw0KaW5kZXgg
Nzc1NGFhM2U0MzRmLi5hMWE4OTAzYWU1ZDAgMTAwNjQ0DQotLS0gYS9uZXQvc3VucnBjL3hwcnRz
b2NrLmMNCisrKyBiL25ldC9zdW5ycGMveHBydHNvY2suYw0KQEAgLTQwNCw4ICs0MDQsOCBAQCB4
c19yZWFkX3hkcl9idWYoc3RydWN0IHNvY2tldCAqc29jaywgc3RydWN0IG1zZ2hkcg0KKm1zZywg
aW50IGZsYWdzLA0KIAlzaXplX3Qgd2FudCwgc2Vla19pbml0ID0gc2Vlaywgb2Zmc2V0ID0gMDsN
CiAJc3NpemVfdCByZXQ7DQogDQotCWlmIChzZWVrIDwgYnVmLT5oZWFkWzBdLmlvdl9sZW4pIHsN
Ci0JCXdhbnQgPSBtaW5fdChzaXplX3QsIGNvdW50LCBidWYtPmhlYWRbMF0uaW92X2xlbik7DQor
CXdhbnQgPSBtaW5fdChzaXplX3QsIGNvdW50LCBidWYtPmhlYWRbMF0uaW92X2xlbik7DQorCWlm
IChzZWVrIDwgd2FudCkgew0KIAkJcmV0ID0geHNfcmVhZF9rdmVjKHNvY2ssIG1zZywgZmxhZ3Ms
ICZidWYtPmhlYWRbMF0sDQp3YW50LCBzZWVrKTsNCiAJCWlmIChyZXQgPD0gMCkNCiAJCQlnb3Rv
IHNvY2tfZXJyOw0KQEAgLTQxNiw4ICs0MTYsOCBAQCB4c19yZWFkX3hkcl9idWYoc3RydWN0IHNv
Y2tldCAqc29jaywgc3RydWN0IG1zZ2hkcg0KKm1zZywgaW50IGZsYWdzLA0KIAkJCWdvdG8gb3V0
Ow0KIAkJc2VlayA9IDA7DQogCX0gZWxzZSB7DQotCQlzZWVrIC09IGJ1Zi0+aGVhZFswXS5pb3Zf
bGVuOw0KLQkJb2Zmc2V0ICs9IGJ1Zi0+aGVhZFswXS5pb3ZfbGVuOw0KKwkJc2VlayAtPSB3YW50
Ow0KKwkJb2Zmc2V0ICs9IHdhbnQ7DQogCX0NCiANCiAJd2FudCA9IHhzX2FsbG9jX3NwYXJzZV9w
YWdlcyhidWYsDQpAQCAtNDQyLDggKzQ0Miw4IEBAIHhzX3JlYWRfeGRyX2J1ZihzdHJ1Y3Qgc29j
a2V0ICpzb2NrLCBzdHJ1Y3QgbXNnaGRyDQoqbXNnLCBpbnQgZmxhZ3MsDQogCQlvZmZzZXQgKz0g
d2FudDsNCiAJfQ0KIA0KLQlpZiAoc2VlayA8IGJ1Zi0+dGFpbFswXS5pb3ZfbGVuKSB7DQotCQl3
YW50ID0gbWluX3Qoc2l6ZV90LCBjb3VudCAtIG9mZnNldCwgYnVmLQ0KPnRhaWxbMF0uaW92X2xl
bik7DQorCXdhbnQgPSBtaW5fdChzaXplX3QsIGNvdW50IC0gb2Zmc2V0LCBidWYtPnRhaWxbMF0u
aW92X2xlbik7DQorCWlmIChzZWVrIDwgd2FudCkgew0KIAkJcmV0ID0geHNfcmVhZF9rdmVjKHNv
Y2ssIG1zZywgZmxhZ3MsICZidWYtPnRhaWxbMF0sDQp3YW50LCBzZWVrKTsNCiAJCWlmIChyZXQg
PD0gMCkNCiAJCQlnb3RvIHNvY2tfZXJyOw0KQEAgLTQ1Myw3ICs0NTMsNyBAQCB4c19yZWFkX3hk
cl9idWYoc3RydWN0IHNvY2tldCAqc29jaywgc3RydWN0IG1zZ2hkcg0KKm1zZywgaW50IGZsYWdz
LA0KIAkJaWYgKHJldCAhPSB3YW50KQ0KIAkJCWdvdG8gb3V0Ow0KIAl9IGVsc2UNCi0JCW9mZnNl
dCArPSBidWYtPnRhaWxbMF0uaW92X2xlbjsNCisJCW9mZnNldCA9IHNlZWtfaW5pdDsNCiAJcmV0
ID0gLUVNU0dTSVpFOw0KIG91dDoNCiAJKnJlYWQgPSBvZmZzZXQgLSBzZWVrX2luaXQ7DQpAQCAt
NDk3LDExICs0OTcsOSBAQCB4c19yZWFkX3N0cmVhbV9yZXF1ZXN0KHN0cnVjdCBzb2NrX3hwcnQN
Cip0cmFuc3BvcnQsIHN0cnVjdCBtc2doZHIgKm1zZywNCiAJCQkmcmVhZCk7DQogCXRyYW5zcG9y
dC0+cmVjdi5vZmZzZXQgKz0gcmVhZDsNCiAJdHJhbnNwb3J0LT5yZWN2LmNvcGllZCArPSByZWFk
Ow0KLQlpZiAodHJhbnNwb3J0LT5yZWN2Lm9mZnNldCA9PSB0cmFuc3BvcnQtPnJlY3YubGVuKSB7
DQotCQlpZiAoeHNfcmVhZF9zdHJlYW1fcmVxdWVzdF9kb25lKHRyYW5zcG9ydCkpDQotCQkJbXNn
LT5tc2dfZmxhZ3MgfD0gTVNHX0VPUjsNCi0JCXJldHVybiByZWFkOw0KLQl9DQorCWlmICh0cmFu
c3BvcnQtPnJlY3Yub2Zmc2V0ID09IHRyYW5zcG9ydC0+cmVjdi5sZW4gJiYNCisJICAgIHhzX3Jl
YWRfc3RyZWFtX3JlcXVlc3RfZG9uZSh0cmFuc3BvcnQpKQ0KKwkJbXNnLT5tc2dfZmxhZ3MgfD0g
TVNHX0VPUjsNCiANCiAJc3dpdGNoIChyZXQpIHsNCiAJZGVmYXVsdDoNCkBAIC02NzEsNiArNjY5
LDggQEAgc3RhdGljIHZvaWQgeHNfc3RyZWFtX2RhdGFfcmVjZWl2ZShzdHJ1Y3Qgc29ja194cHJ0
DQoqdHJhbnNwb3J0KQ0KIAkJcmVhZCArPSByZXQ7DQogCQljb25kX3Jlc2NoZWQoKTsNCiAJfQ0K
KwlpZiAocmV0ID09IC1FU0hVVERPV04pDQorCQlrZXJuZWxfc29ja19zaHV0ZG93bih0cmFuc3Bv
cnQtPnNvY2ssIFNIVVRfUkRXUik7DQogb3V0Og0KIAltdXRleF91bmxvY2soJnRyYW5zcG9ydC0+
cmVjdl9tdXRleCk7DQogCXRyYWNlX3hzX3N0cmVhbV9yZWFkX2RhdGEoJnRyYW5zcG9ydC0+eHBy
dCwgcmV0LCByZWFkKTsNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoN
Cg0K
