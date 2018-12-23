Return-Path: <SRS0=dMO4=PA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D82AC43387
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 23:56:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A02F220685
	for <linux-nfs@archiver.kernel.org>; Sun, 23 Dec 2018 23:56:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Q2y1oTlh"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726016AbeLWX4s (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 23 Dec 2018 18:56:48 -0500
Received: from mail-eopbgr710116.outbound.protection.outlook.com ([40.107.71.116]:26720
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725911AbeLWX4s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 23 Dec 2018 18:56:48 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NOjxFz/D/ENkoMrQxR4c+T3ghHZAyXH5SUdXZln0+gk=;
 b=Q2y1oTlhPTQfsvMQf8FlCilPTz9sKrt2I7n1zGOT/kA8HapukG6V/W+XDDefpYMiWZ5mBOp4Gc/RrscFuW/14tP910KSOOBW/irYpsalu510j5hBWqPZUlocwlm5ARM1D/6L0ZdvEdnM1gn73piz2kRsk9Bukfq4TVPffYjmoMo=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2382.namprd13.prod.outlook.com (52.135.94.150) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1471.17; Sun, 23 Dec 2018 23:56:44 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1471.018; Sun, 23 Dec 2018
 23:56:44 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "vvs@virtuozzo.com" <vvs@virtuozzo.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "khorenko@virtuozzo.com" <khorenko@virtuozzo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "eshatokhin@virtuozzo.com" <eshatokhin@virtuozzo.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Thread-Topic: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Thread-Index: AQHUliTq8x5/j6ovkEmcMIRcXEAVYaWDeL8AgACVn4CAAGV+AIAAHc0AgAAFZwCAA82tgIACq6GAgAH5nYA=
Date:   Sun, 23 Dec 2018 23:56:44 +0000
Message-ID: <b80a9496d933064c0080ef277e79a07b69ae80b1.camel@hammerspace.com>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
         <20181217215026.GA8564@fieldses.org>
         <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
         <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
         <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
         <068f1741afc54367853a2e4501fd95c2ab12a989.camel@hammerspace.com>
         <20181221010007.GA10196@fieldses.org>
         <9082b04a-8235-4b9d-39ae-1462fe350935@virtuozzo.com>
In-Reply-To: <9082b04a-8235-4b9d-39ae-1462fe350935@virtuozzo.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [84.202.42.9]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2382;6:4iz76a2YwBWwAhEC1Nl6k7NkhYNsEwK+RCRGKlWq9NP11c+AhR6JmOoWDKePRGzTqTlqhn9j1zcS3U6/MuKEx0G2O4XeGMuZWzdlIXrLH45MF9AXc4b8ect3BQ6aLZXiK1cVSUZN7FaRkI0WVbBxV7VZ6xJjzeFe+IoVYXgDPEGq9Qr2/qiq3D6cyZ2J3mmDhgs3gYTUqqpcGg2mSoZW5RJU2lkT6LuIT0VaG4UP49RkcVMacN1DEgHUoQiHifs/6i+MaYE3o0tU0Yiu2qycIEVQzQzrPQQG4my+rP0Lh+3+mSEfDvbXIL/vb6wyCO6VKGxQoV6iMkkIl86e5q2+2086lDQUTggLz11Y8JyOrAgDpWkCKppZ5XjFqoGfYPnhiszIqvoCmZCJbi7BK7hSSZZ+nJf7DM0zVp4/6QSMr8cyLaViwaazeRqtv6vw77hqM0CJoL3Pvdl32pX/e1FVmA==;5:ws+EpEpl5hqw7n4y/IdxJ4/aZV2ua2JOWbzxc6R4H8TccPzv2Hy1iFs/gr/kKWNhgLfIAxsbKLSuuFdMFDyTRMK1F3ndY4ojGGrrKfmz28qozYII7YlxbSQAnrEhs2wZQSCs3oSGHBvooQEuVoetus8kFXo9OSuZj7Nr8X04j9g=;7:WsgwGuxEjjWJNBFD72A/pdKUNErZjs5KFRYzjZrZr6vrFa7cYhcNJH6ZfxOMb6RWSUmmMosx9X08YNzak6dsYcV522fn2e5bdnBGeA6nRBiwKjTknT3RRCKMK/vmYRFD1G7bM27mDY/VLHeP+B0/fg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 294f22ad-0701-4f38-6d85-08d669324b1c
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2382;
x-ms-traffictypediagnostic: SN6PR13MB2382:
x-microsoft-antispam-prvs: <SN6PR13MB23824ECE42722BA100EA9E48B8BA0@SN6PR13MB2382.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(2401047)(8121501046)(10201501046)(3002001)(93006095)(93001095)(3231475)(944501520)(52105112)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123564045)(20161123562045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2382;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2382;
x-forefront-prvs: 0895DF8FFD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(366004)(136003)(396003)(39830400003)(189003)(199004)(2906002)(476003)(54906003)(71200400001)(3846002)(486006)(110136005)(6116002)(71190400001)(99286004)(316002)(93886005)(66066001)(86362001)(186003)(305945005)(106356001)(446003)(6246003)(7736002)(2501003)(36756003)(14454004)(68736007)(5660300001)(118296001)(256004)(8676002)(478600001)(81166006)(81156014)(2616005)(102836004)(4326008)(229853002)(97736004)(26005)(6506007)(53546011)(8936002)(4001150100001)(53936002)(105586002)(6512007)(6436002)(6486002)(25786009)(76176011)(11346002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2382;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: JkYVn9TnJHUD7OJtkKKc4+dOPTMw1s9R9G0DE65qUBZf9UP8Hwvqgl4yHDxLUQpcB3osjpN014Ne9ciAQvidLyk13WZWyDoNa/JG+lYfDlEIzc+XJBFP47ltq5alsrOTCbiqtPEuxoC/IUzND8L6w5Hahcm2DSFWpXCN5XEEW6h9AXgQ9x3kouDjqaX8uJ4ZhSWyi0pFGGi0mnHVuE8X6f++dYx7cGpjFNgKMjHw6HAhEpzndsVVcn8XsPSBkJfpysq9vwB5FF/YoI1x10RS/Lk1ZC80r9eu0N7nslrOf5EfDEng/55y7IzIvhQPb5X1
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <71F028DF8C442143BE9D988B40C105ED@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 294f22ad-0701-4f38-6d85-08d669324b1c
X-MS-Exchange-CrossTenant-originalarrivaltime: 23 Dec 2018 23:56:44.7468
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2382
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gU2F0LCAyMDE4LTEyLTIyIGF0IDIwOjQ2ICswMzAwLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0K
PiBPbiAxMi8yMS8xOCA0OjAwIEFNLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3cm90ZToNCj4gPiBP
biBUdWUsIERlYyAxOCwgMjAxOCBhdCAwMjo1NToxNVBNICswMDAwLCBUcm9uZCBNeWtsZWJ1c3Qg
d3JvdGU6DQo+ID4gPiBOby4gV2UgZG9uJ3QgY2FyZSBhYm91dCB4cHRfZmxhZ3MgZm9yIHRoZSBi
YWNrIGNoYW5uZWwgYmVjYXVzZQ0KPiA+ID4gdGhlcmUgaXMNCj4gPiA+IG5vICJzZXJ2ZXIgdHJh
bnNwb3J0Ii4gVGhlIGFjdHVhbCB0cmFuc3BvcnQgaXMgc3RvcmVkIGluIHRoZQ0KPiA+ID4gJ3N0
cnVjdA0KPiA+ID4gcnBjX3Jxc3QnLCBhbmQgaXMgdGhlIHN0cnVjdCBycGNfeHBydCBjb3JyZXNw
b25kaW5nIHRvIHRoZSBjbGllbnQNCj4gPiA+IHNvY2tldCBvciBSRE1BIGNoYW5uZWwuDQo+ID4g
PiANCj4gPiA+IElPVzogQWxsIHdlIHJlYWxseSBuZWVkIGluIHN2Y19wcm9jZXNzX2NvbW1vbigp
IGlzIHRvIGJlIGFibGUgdG8NCj4gPiA+IHJ1bg0KPiA+ID4gcnFzdHAtPnJxX3hwcnQtPnhwdF9v
cHMtPnhwb19wcmVwX3JlcGx5X2hkcigpLCBhbmQgdGhhdCBjYW4gYmUNCj4gPiA+IHBhc3NlZA0K
PiA+ID4gZWl0aGVyIGFzIGEgcG9pbnRlciB0byB0aGUgc3RydWN0IHN2Y194cHJ0X29wcyBpdHNl
bGYuDQo+ID4gDQo+ID4gRm9yIHdoYXQgaXQncyB3b3J0aCwgSSdkIHJhdGhlciBnZXQgcmlkIG9m
IHRoYXQgb3AtLWl0J3MgYW4gYXdmdWxseQ0KPiA+IHJvdW5kYWJvdXQgd2F5IGp1c3QgdG8gZG8g
InN2Y19wdXRubChyZXN2LCAwKTsiIGluIHRoZSB0Y3AgY2FzZS4NCj4gDQo+IERvIHlvdSBtZWFu
IHRoYXQgc3ZjX2NyZWF0ZV94cHJ0KHNlcnYsICJ0Y3AtYmMiLCAuLi4pIHdhcyB1c2VkIE9OTFkN
Cj4gdG8gY2FsbCANCj4gc3ZjX3RjcF9wcmVwX3JlcGx5X2hkcigpIGluIHN2Y19wcm9jZXNzX2Nv
bW1vbigpID8NCj4gQW5kIGFjY29yZGluZyBjYWxsIGZvciByZG1hLWJjIGRvZXMgbm90aGluZyB1
c2VmdWwgYXQgYWxsPyANCj4gDQo+IEkndmUganVzdCB0cmllZCB0byByZW1vdmUgc3ZjX2NyZWF0
ZV94cHJ0KCkgZnJvbSB4c190Y3BfYmNfdXAoKSBhbmQNCj4ganVzdCANCj4gcHJvdmlkZSBwb2lu
dGVyIHRvIHN2Y190Y3BfcHJlcF9yZXBseV9oZHIoKSBpbiAgc3ZjX3Byb2Nlc3NfY29tbW9uKCkg
DQo+IHZpYSBwZXItbmV0bnMgc3VucnBjX25ldCAtLSBhbmQgc2VlbXMgaXQgd2FzIGVub3VnaCwg
bXkgdGVzdGNhc2UNCj4gd29ya2VkIGNvcnJlY3RseS4NCg0KSSBkb24ndCBzZWUgaG93IHRoYXQg
ZnVuY3Rpb24gaXMgcmVsYXRlZCB0byBuZXQgbmFtZXNwYWNlcy4gQXMgZmFyIGFzIEkNCmNhbiB0
ZWxsLCBpdCBvbmx5IHNpZ25hbHMgd2hldGhlciBvciBub3QgdGhlIHR5cGUgb2YgdHJhbnNwb3J0
IHVzZXMgdGhlDQpUQ1AgcmVjb3JkIG1hcmtpbmcgc2NoZW1lLg0KDQpJT1c6IGl0IGRlcGVuZHMg
b24gd2hldGhlciB0aGUgY2xpZW50IGlzIHVzaW5nIGEgc3RyZWFtIGJhc2VkIHByb3RvY29sDQps
aWtlIFRDUCwgb3IgYSBkYXRhZ3JhbS1saWtlIHByb3RvY29sIGxpa2UgVURQLCBvciBSRE1BLiBX
aGV0aGVyIHRoYXQNCnVzZSBpcyBvY2N1cnJpbmcgaW4gYSBwcml2YXRlIG5ldCBuYW1lc3BhY2Ug
b3IgaW4gdGhlIGluaXQgcHJvY2Vzcw0KbmFtZXNwYWNlIHdvdWxkIGJlIGlycmVsZXZhbnQuDQoN
Cj4gQW0gSSBtaXNzZWQgc29tZXRoaW5nIHByb2JhYmx5Pw0KPiBTaG91bGQgd2UgcmVhbGx5IHJl
bW92ZSBzdmNfY3JlYXRlX3hwcnQoICJ0Y3AvcmRtYS1iYyIuLi4pIHJlbGF0ZWQNCj4gc3R1ZmY/
ID8NCg0KQWdyZWVkLiBUaGUgJ2JjX3VwJyBjYWxsYmFjayBpbiBzdHJ1Y3QgcnBjX3hwcnRfb3Bz
IHNlcnZlcyBubw0KZGlzY2VybmlibGUgcHVycG9zZSwgYW5kIGNhbiBiZSByZW1vdmVkLg0KDQot
LSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJz
cGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
