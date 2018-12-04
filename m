Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63869C04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 19:31:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D117E206B7
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 19:31:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="lrFTk0xO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D117E206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725855AbeLDTbp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 14:31:45 -0500
Received: from mail-eopbgr730124.outbound.protection.outlook.com ([40.107.73.124]:62496
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725831AbeLDTbo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Dec 2018 14:31:44 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/f+LWmWq0S6u3OCuzLQ+2Cvfu52PQNqRMP/RXtH8N38=;
 b=lrFTk0xOs50l5Ljpo7qc3CMmsFowpGjAt5lwAEnyqqEXgF5QUlVa0WlCoqnl2063vr61IUEikwgKLu0v6mvzs0XhnbqymJyW3cSBv1HGEUi+PUKymIKnyVy3PYlnaDLx7Ybv3dIgA1k328UiZqPkr2S7ufyH1k4hocSsIj4vzkc=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2544.namprd13.prod.outlook.com (52.135.96.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1404.8; Tue, 4 Dec 2018 19:31:40 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.016; Tue, 4 Dec 2018
 19:31:40 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "cristian.marussi@arm.com" <cristian.marussi@arm.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix RPC receive hangs
Thread-Topic: [PATCH] SUNRPC: Fix RPC receive hangs
Thread-Index: AQHUjAcrBzSZN4+fvk6NtsSK8c4Yn6Vu9+OA
Date:   Tue, 4 Dec 2018 19:31:39 +0000
Message-ID: <70cd2493391a24e5f92a36622f588cdc463dfe4c.camel@hammerspace.com>
References: <20181204192439.39259-1-trond.myklebust@hammerspace.com>
In-Reply-To: <20181204192439.39259-1-trond.myklebust@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2544;6:BgFqND59vt6SL1MjZTaepqLGFrmqCrNqj3Jyz+hzMaMCj5EKtaTggzK6AR5Je2XM8clETCFEMotojBf2ZSwr42djxF262iGlYqoptEi+BKsGVO5HXDx5GggdWNggPa7s8oc32xTCbam4XsSdDZOuryiCeKUjo0fQfxcDsyvwWeTchgoVrGMVqNhsFxNyGRyoigdC/RXDytmLHwVbHY8iR7sgUZr5nkIILArnCfmiqtj/5EwPpaYbJes+GkaTv9WX6lAe0PLtVDAOohTiWS+GNHGByAkSVpBs1EpBLqJcnpdXDP8IvY7R2XsqnTEMjr/+GwjROI0tJ/yee7GQSKATUQWfpEmtiK8f2DinTWdw/Gnt+PzYkeCFxzF3ffClBSvDeAVjQJAhDxZVeLPjlZyO0RER1kCr1F+2q9LUzz5EvJkWSu8JmSvyI3DUW6fX6qPB21BP6Bgjt10Mwthjf7AyYg==;5:J4wnT0Rs22fV8xRqUTx8S4ZiSzH8s31Y9xCWFusw1MFHnv1Lk/5kF9FEPmR+U0KGhG4JoDiSPA2IQo9Tn2Yw5RBKvfwwFUUbmUDmdnXogPYGkpUuaBOG+dU3Es3KtYroSGH4MjAV1W/7UiZ1tFWh1TdrTlJyfEQVJ9fVj3ZyjQM=;7:yty3ak26seXlfS+jkQYP8I5sE0b+/0EMXjJ2j9tQ82A6U07J8kVbvyAFPuTaAAJEAuMo9EPvyueodbYvRD2xuQc9yXWdSR4FHwFQoxmGFbz9txl4wLZI/a65Ytut5gkXyCGo5EKGubB5cjDRtE5Asg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: d506f465-d066-4765-2e29-08d65a1f1d44
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2544;
x-ms-traffictypediagnostic: SN6PR13MB2544:
x-microsoft-antispam-prvs: <SN6PR13MB2544246B682F33FB36A24594B8AF0@SN6PR13MB2544.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(93006095)(93001095)(3231455)(999002)(944501493)(52105112)(3002001)(10201501046)(148016)(149066)(150057)(6041310)(20161123558120)(20161123562045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2544;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2544;
x-forefront-prvs: 0876988AF0
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(346002)(396003)(39830400003)(366004)(376002)(199004)(189003)(25786009)(229853002)(8936002)(486006)(99286004)(81166006)(8676002)(4326008)(6246003)(6512007)(6306002)(186003)(256004)(105586002)(106356001)(81156014)(966005)(476003)(14454004)(53936002)(71190400001)(71200400001)(2501003)(118296001)(66066001)(68736007)(316002)(6506007)(2616005)(76176011)(446003)(6436002)(305945005)(26005)(3846002)(7736002)(97736004)(478600001)(36756003)(102836004)(110136005)(6116002)(2906002)(2201001)(86362001)(6486002)(5660300001)(11346002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2544;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: Mk/USa/cuRsBp/uz1l7AaSMEmBdFLLPs1EeIE0Fel/grtKT1uVnL8Ur0EMLNlEihx2J43Q78LaCoxf2rnTh5l+1DXtso/kWa+2g/3qEsaLYSefGVHqm9Gq4OYsgt2JNm8YJreyh+T8heJokZQtu9uiDNU5DkP8i9CoTWzzJJ9FeUUJx201oyGq2ICd8OIemwL9s7d5MSklYYK/Ai6CwqD52UPxQKF4c2Graj9rKoV3TrHsxieyJq3/8YG8ukmF25d+AH7GgTAoAIzxMKi1pXwvyCo6MOfqdtCjrNxtMwRmFoT0drTMwMPeNM9tWwGtTXk6FH3JKzmF0/4Rf3NobcljYPRIkTheq6ownYqf3rrpA=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <6E38689A976ED34F9BB5A19E4B6581D9@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: d506f465-d066-4765-2e29-08d65a1f1d44
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Dec 2018 19:31:39.9706
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2544
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE4LTEyLTA0IGF0IDE0OjI0IC0wNTAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IFRoZSBSUEMgY29kZSBpcyBvY2Nhc2lvbmFsbHkgaGFuZ2luZyB3aGVuIHRoZSByZWNlaXZl
IGNvZGUgZmFpbHMgdG8NCj4gZW1wdHkgdGhlIHNvY2tldCBidWZmZXIgZHVlIHRvIGEgcGFydGlh
bCByZWFkIG9mIHRoZSBkYXRhLiBXaGVuIHdlDQo+IGNvbnZlcnQgdGhhdCB0byBhbiBFQUdBSU4s
IGl0IGFwcGVhcnMgd2Ugb2NjYXNpb25hbGx5IGxlYXZlIGRhdGEgaW4NCj4gdGhlDQo+IHNvY2tl
dC4gVGhlIGZpeCBpcyB0byBqdXN0IGtlZXAgcmVhZGluZyB1bnRpbCB0aGUgc29ja2V0IHJldHVy
bnMNCj4gRUFHQUlOL0VXT1VMREJMT0NLLg0KPiANCj4gUmVwb3J0ZWQtYnk6IENhdGFsaW4gTWFy
aW5hcyA8Y2F0YWxpbi5tYXJpbmFzQGFybS5jb20+DQo+IFJlcG9ydGVkLWJ5OiBDcmlzdGlhbiBN
YXJ1c3NpIDxjcmlzdGlhbi5tYXJ1c3NpQGFybS5jb20+DQo+IFJlcG9ydGVkLWJ5OiBDaHVjayBM
ZXZlciA8Y2h1Y2subGV2ZXJAb3JhY2xlLmNvbT4NCj4gU2lnbmVkLW9mZi1ieTogVHJvbmQgTXlr
bGVidXN0IDx0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tPg0KPiAtLS0NCg0KSGkgZ3V5
cywNCg0KSSB0aGluayBJIG1hbmFnZWQgdG8gcmVwcm9kdWNlIHRoZSBoYW5ncyB0aGF0IHlvdSB3
ZXJlIHJlcG9ydGluZyBieQ0Kc2V0dGluZyB0aGUgci93c2l6ZSB0byAxMDI0LCBhbmQgdGhlbiBy
dW5uaW5nIHRoZSB4ZnN0ZXN0cyBnZW5lcmljLzA3NA0KdGVzdC4gVGhpcyBwYXRjaCAod2hpY2gg
c2hvdWxkIGFwcGx5IG9uIHRvcCBvZiB0aGUgbGludXgtbmV4dCBicmFuY2gNCnRoYXQgSSBwb2lu
dGVkIHlvdSB0byBwcmV2aW91c2x5KSBhcHBlYXJzIHRvIGZpeCB0aGUgaGFuZyBmb3IgdGhhdCB0
ZXN0DQpjYXNlLCBzbyBJJ20gaG9waW5nIGl0IHdpbGwgYWxzbyBmaXggdGhlIGlzc3VlcyB5b3Ug
cmVwb3J0ZWQuDQoNClRoaXMgcGF0Y2ggY2FuIGFsc28gYmUgcmV0cmlldmVkIGFzIHBhcnQgb2Yg
dGhlICd0ZXN0aW5nJyBicmFuY2ggKCANCmh0dHBzOi8vZ2l0LmxpbnV4LW5mcy5vcmcvP3A9dHJv
bmRteS9saW51eC1uZnMuZ2l0O2E9c2hvcnRsb2c7aD1yZWZzL2hlYWRzL3Rlc3RpbmcNCikNCg0K
Z2l0IHB1bGwgZ2l0Oi8vZ2l0LmxpbnV4LW5mcy5vcmcvcHJvamVjdHMvdHJvbmRteS9saW51eC1u
ZnMuZ2l0IHRlc3RpbmcNCg0KQ2hlZXJzDQogIFRyb25kDQotLSANClRyb25kIE15a2xlYnVzdA0K
TGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0
QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
