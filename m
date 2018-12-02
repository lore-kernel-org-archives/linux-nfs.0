Return-Path: <SRS0=5YGM=OL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62894C04EB8
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 16:45:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0045520851
	for <linux-nfs@archiver.kernel.org>; Sun,  2 Dec 2018 16:45:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="b8CM+ZQ9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0045520851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725385AbeLBQpf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 2 Dec 2018 11:45:35 -0500
Received: from mail-eopbgr680127.outbound.protection.outlook.com ([40.107.68.127]:46160
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725379AbeLBQpf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 2 Dec 2018 11:45:35 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=vzN1jMgqwXWZeczROk4Y+ZuIYZ4muEY+Nf/EwkZOstY=;
 b=b8CM+ZQ9LkDmiAE+PnhLZyGkENYKZbOajkvBgOhcQL/lCy70WHsMNp1/6E39jjEXDuLnUoDkSxTPrm2qp73fypiMgmR3cLggSQ3O/29Nfb/RReWflW8WPro3J/CFXMG2uEquORr+Rh6+MNluZZyJQSWNDjsk/yyKDyVmJ9oKbg0=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2528.namprd13.prod.outlook.com (52.135.95.158) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1404.13; Sun, 2 Dec 2018 16:44:49 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.011; Sun, 2 Dec 2018
 16:44:49 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "cristian.marussi@arm.com" <cristian.marussi@arm.com>
CC:     "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
Thread-Topic: [PATCH v3 40/44] SUNRPC: Simplify TCP receive code by switching
 to using iterators
Thread-Index: AQHUTocCwahWu1c0eEqSYU1l+AHxY6VHnxwAgB/3VYCAAAefAIABVbYAgAA10ACAAvYHgA==
Date:   Sun, 2 Dec 2018 16:44:49 +0000
Message-ID: <7d58a5dc7f62117245c824fc63bce62ba99e5b44.camel@hammerspace.com>
References: <20180917130335.112832-32-trond.myklebust@hammerspace.com>
         <20180917130335.112832-33-trond.myklebust@hammerspace.com>
         <20180917130335.112832-34-trond.myklebust@hammerspace.com>
         <20180917130335.112832-35-trond.myklebust@hammerspace.com>
         <20180917130335.112832-36-trond.myklebust@hammerspace.com>
         <20180917130335.112832-37-trond.myklebust@hammerspace.com>
         <20180917130335.112832-38-trond.myklebust@hammerspace.com>
         <20180917130335.112832-39-trond.myklebust@hammerspace.com>
         <20180917130335.112832-40-trond.myklebust@hammerspace.com>
         <20180917130335.112832-41-trond.myklebust@hammerspace.com>
         <20181109111930.idve77thgcnsg5u3@localhost>
         <e85fe63f-b142-5075-edb6-da6c9e2609fd@arm.com>
         <356631f8d49b5d0698d769ab9c916c84fadd3be6.camel@hammerspace.com>
         <a23d0c18-1030-82f3-a046-41497dc7725b@arm.com>
         <92a750b72255c6a91fd5606668f26b2d492ec43f.camel@hammerspace.com>
In-Reply-To: <92a750b72255c6a91fd5606668f26b2d492ec43f.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2528;6:JQruOlsPPF3qY1NfW7kEwiJlZgYcxR4jGlr23sX71YxcY7002R7N5rD2ibSE4h0Lpaj5WE06GmhHZBdk/ZxLQknR413OrSZ1XoeckzfTqM2L0y3Qr8FH7EvYosVS1BTkYGBHUBTiKMVgOxeKsYR0fRY155x3G6qVFNcAX5+IpPS+ITRCAhbH4YWrKh2ohUO18vF4Spuk3kmWG4vY3FpQPW3LpSFCDeqluVLnrIFEUFfoxpm/pgP/1JKTP8UNcFtRhUCsLSN4iFEoNIbYxDBv+V+jLBGcwtzezXxM7qmd2MjR1eaVlrJuu2hclBuAEfgYvdubT5urLB8Bamvp9h3vKAi+Ds3Ey+TKJcyLWMPezGRa7cqllO/EN9P5a2FrAeuSwTEMSDalDKPc1TuoyTR3EAP6+ZECVHGVJmb3ANm/dx9332zDUyMeVOkifnmSZvWLrxGL5z1+kvYCwwkjXkNMRA==;5:pLwPyokfEw5a3IBwyOV7ChV+5Xag2AZcpaDmie+GZXTm7bc4hy9eaMzag0PpOJHG5v2gC+mn/nrU/3hTzOkQXgJEWoLFhS/SJElBQ1AfQSfuQs+7HQue2EjX5pbcBhVoCArMeX81U+O/loMnRLELu3mGiCEZomDBYIT0JnU02Sk=;7:br2WOsv+pPeHQVTn8Jt/seZezusyVXgLKmzoSnvqC3D7btau1v8cMaROYVXRqqqpIWq0RtYSM21CTxrLfRP87CbGUs2XxHweUkIuV5CBP6RCn7ZoKFYJpTZLdsZgQDOuFIz4tq4l3PyQ5ZTviLUX7w==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 1d2c48bd-9a88-4b32-3941-08d6587579c3
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2528;
x-ms-traffictypediagnostic: SN6PR13MB2528:
x-microsoft-antispam-prvs: <SN6PR13MB2528AAA9083C03F33AFCF434B8AD0@SN6PR13MB2528.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(10201501046)(3002001)(3231455)(999002)(944501490)(52105112)(93006095)(93001095)(148016)(149066)(150057)(6041310)(20161123558120)(20161123564045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123562045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2528;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2528;
x-forefront-prvs: 087474FBFA
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(346002)(136003)(39830400003)(376002)(366004)(189003)(199004)(305945005)(7736002)(11346002)(476003)(2616005)(36756003)(316002)(2906002)(446003)(5660300001)(54906003)(6116002)(3846002)(86362001)(25786009)(478600001)(4326008)(118296001)(486006)(966005)(14454004)(4001150100001)(97736004)(6246003)(2501003)(99286004)(186003)(102836004)(76176011)(14444005)(256004)(6916009)(26005)(5640700003)(6486002)(53936002)(6436002)(6506007)(8676002)(71200400001)(71190400001)(68736007)(53546011)(105586002)(8936002)(106356001)(81166006)(81156014)(229853002)(93886005)(6512007)(66066001)(2351001)(6306002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2528;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: UsP90I/iSX3M0R5eyUVbur2wqrSYOSIoYKSAzp++/QDyh9EF5VXGxKmCLvJ/ZvWSBaI608+CKjEM+J4sGeBLsv323Aek1UKHHBsSPGacxkb0F4j64tl+/PPYcmXcOS/sknQEWngjWyz3iLjVmOwPcXO3RxYv2KOBgUzo3VY4Z1LweNJbzutUL+dmssrsIsIHkSMhAp2aV4N8c6fXPqRYx4hNElrhg8wYXjPbaGhr6euOY4L3O4giyEint2lMTe8bS8AJtnJp388OaumzpsV4H6FoSxzz8coaEWc6z3mNvJYV9fybvDfBqNj/As99K2xu6IIquwj3r30RkVOnMddrVvh0q2U6/siyBQ8WvKuT+nM=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <A4F5CA768B8A444A9C83EB454E9276C4@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1d2c48bd-9a88-4b32-3941-08d6587579c3
X-MS-Exchange-CrossTenant-originalarrivaltime: 02 Dec 2018 16:44:49.5017
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2528
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gRnJpLCAyMDE4LTExLTMwIGF0IDE0OjMxIC0wNTAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IE9uIEZyaSwgMjAxOC0xMS0zMCBhdCAxNjoxOSArMDAwMCwgQ3Jpc3RpYW4gTWFydXNzaSB3
cm90ZToNCj4gPiBIaQ0KPiA+IA0KPiA+IE9uIDI5LzExLzIwMTggMTk6NTYsIFRyb25kIE15a2xl
YnVzdCB3cm90ZToNCj4gPiA+IE9uIFRodSwgMjAxOC0xMS0yOSBhdCAxOToyOCArMDAwMCwgQ3Jp
c3RpYW4gTWFydXNzaSB3cm90ZToNCj4gPiA+ID4gSGkgVHJvbmQsIENhdGFsaW4NCj4gPiBbc25p
cF0NCj4gPiA+IFF1ZXN0aW9uIHRvIHlvdSBib3RoOiB3aGVuIHRoaXMgaGFwcGVucywgZG9lcyAv
cHJvYy8qL3N0YWNrIHNob3cNCj4gPiA+IGFueSBvZg0KPiA+ID4gdGhlIHByb2Nlc3NlcyBoYW5n
aW5nIGluIHRoZSBzb2NrZXQgb3Igc3VucnBjIGNvZGU/IElmIHNvLCBjYW4NCj4gPiA+IHlvdQ0K
PiA+ID4gcGxlYXNlIHNlbmQgbWUgZXhhbXBsZXMgb2YgdGhvc2Ugc3RhY2sgdHJhY2VzIChpLmUu
IHRoZSBjb250ZW50cw0KPiA+ID4gb2YNCj4gPiA+IC9wcm9jLzxwaWQ+L3N0YWNrIGZvciB0aGUg
cHJvY2Vzc2VzIHRoYXQgYXJlIGhhbmdpbmcpDQo+ID4gDQo+ID4gKHVzaW5nIGEgcmV2ZXJzZSBz
aGVsbCBzaW5jZSBzdGFydGluZyBzc2ggY2F1c2VzIGEgbG90IG9mIHBhaW4gYW5kDQo+ID4gdHJh
ZmZpYykNCj4gPiANCj4gPiBMb29raW5nIGF0IE5GUyB0cmFmZmljIGhvbGVzKDMwLTQwIHNlY3Mp
IHRvIGRldGVjdCBDbGllbnQgc2lkZQ0KPiA+IHZhcmlvdXMgSEFOR1MNCj4gPiAtLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
DQo+ID4gDQoNCkhpIENyaXN0aWFuIGFuZCBDYXRhbGluDQoNCkNodWNrIGFuZCBJIGhhdmUgaWRl
bnRpZmllZCBhIGZldyBpc3N1ZXMgdGhhdCBtaWdodCBoYXZlIGFuIGVmZmVjdCBvbg0KdGhlIGhh
bmdzIHlvdSByZXBvcnQuIENvdWxkIHlvdSBwbGVhc2UgZ2l2ZSB0aGUgbGludXgtbmV4dCBicmFu
Y2ggaW4gbXkNCnJlcG9zaXRvcnkgb24gZ2l0LmxpbnV4LW5mcy5vcmcgKA0KaHR0cHM6Ly9naXQu
bGludXgtbmZzLm9yZy8/cD10cm9uZG15L2xpbnV4LW5mcy5naXQ7YT1zaG9ydGxvZztoPXJlZnMv
aGVhZHMvbGludXgtbmV4dA0KKSBhIHRyeT8NCg0KZ2l0IHB1bGwgZ2l0Oi8vZ2l0LmxpbnV4LW5m
cy5vcmcvcHJvamVjdHMvdHJvbmRteS9saW51eC1uZnMuZ2l0IGxpbnV4LW5leHQNCg0KVGhhbmtz
IQ0KICAgVHJvbmQNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50
YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
