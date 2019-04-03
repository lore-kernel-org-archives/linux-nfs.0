Return-Path: <SRS0=5sV6=SF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA57FC4360F
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 02:03:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 542C9206B7
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 02:03:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Vgi01k0Q"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726797AbfDCCDA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 22:03:00 -0400
Received: from mail-eopbgr710104.outbound.protection.outlook.com ([40.107.71.104]:6077
        "EHLO NAM05-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726157AbfDCCC7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 2 Apr 2019 22:02:59 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=sqgtOHYHBbFJAzxVWlaAGCQ9DHghqgRpIEttlnDg8hU=;
 b=Vgi01k0QHJcs9cAOIhbM7zQOLF8FfDouQts/KQwQIEVLE1uBRiAraJZFpIrzeTkdH3N6NENPHvQG3e8xXI2P5YlEkgEAchWIU9Dlf5x5Y0dnf21ebLpjlthRZhYGjDklYq+4n0Iki0ML3F5S9bONt1edl5iD0/deij3e7fNUT8A=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2319.namprd13.prod.outlook.com (52.135.94.26) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.10; Wed, 3 Apr 2019 02:02:54 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::30dc:67e2:d25a:f1d3%6]) with mapi id 15.20.1771.007; Wed, 3 Apr 2019
 02:02:54 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bradley.kuszmaul@oracle.com" <bradley.kuszmaul@oracle.com>
Subject: Re: directory delegations
Thread-Topic: directory delegations
Thread-Index: AQHU6KcNiRPQ7r4+DEebmwXdEDXzDKYpDBcAgAAU+ICAACXbAIAAJEkAgAAryACAABpogA==
Date:   Wed, 3 Apr 2019 02:02:54 +0000
Message-ID: <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
         <20190402161116.GA2828@fieldses.org>
         <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
         <20190402194148.GA5269@fieldses.org>
         <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
         <20190403002822.GA7667@fieldses.org>
In-Reply-To: <20190403002822.GA7667@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [63.235.104.78]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 1c64b967-ce11-4a25-1e58-08d6b7d87c63
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600139)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:SN6PR13MB2319;
x-ms-traffictypediagnostic: SN6PR13MB2319:
x-ms-exchange-purlcount: 2
x-microsoft-antispam-prvs: <SN6PR13MB2319A373939A06E4BB9C3992B8570@SN6PR13MB2319.namprd13.prod.outlook.com>
x-forefront-prvs: 0996D1900D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(136003)(366004)(39830400003)(396003)(346002)(189003)(199004)(2501003)(2906002)(71200400001)(71190400001)(118296001)(66066001)(256004)(106356001)(81166006)(1730700003)(105586002)(93886005)(99286004)(6916009)(3480700005)(81156014)(316002)(8936002)(8676002)(54906003)(2351001)(25786009)(561944003)(7736002)(221733001)(2616005)(4326008)(6246003)(6486002)(6306002)(5640700003)(5660300002)(6436002)(486006)(6512007)(53936002)(305945005)(7116003)(97736004)(476003)(229853002)(11346002)(446003)(68736007)(36756003)(26005)(14454004)(6506007)(86362001)(102836004)(966005)(6116002)(186003)(478600001)(76176011)(3846002)(111123002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2319;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: hfb5cEc/sdjlija5CRJNPA9Elo+vYWNDe3OWmUfyHfrdlX+jA3f7QQDgawSc9+AlRb7Y6smOVMVLB3ctWZ0sCNVQApTdztT+Z2aBwmZ6neGGrUJg6wC/Nurz8SERn7JmcmKlKzB8TIE0g42pZWANAhmEpkrFZYYJvAgpCHNZTq3PTqik4/ADhRCEfrXp32dDPw4FVpXrGM3j71VnAB08bcx7E1SJq4TYGGwpuZ79iYTJ1qWLtJVYBG54C/QgYsiR5G1d+qCXfKVGEMtgjSRRko+zEH+5iqqNrjnzd3K2Z5QGR8F3g4qdeu8q8qnIUal0JL+E4OPctszdj6ZlyN+S0TftwmsbPCzcG/Ps96MQObiueje80dCE4FhhF0ODZFF71HHmL9aE6E70cNZj7hdDxUka2hNdgVZBkWFOX/T99/I=
Content-Type: text/plain; charset="utf-8"
Content-ID: <54536D16728F824DB7C25653833EDC85@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 1c64b967-ce11-4a25-1e58-08d6b7d87c63
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Apr 2019 02:02:54.5592
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2319
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTA0LTAyIGF0IDIwOjI4IC0wNDAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gVHVlLCBBcHIgMDIsIDIwMTkgYXQgMDk6NTE6NDJQTSArMDAwMCwgVHJvbmQg
TXlrbGVidXN0IHdyb3RlOg0KPiA+IE9uIFR1ZSwgMjAxOS0wNC0wMiBhdCAxNTo0MSAtMDQwMCwg
Si4gQnJ1Y2UgRmllbGRzIHdyb3RlOg0KPiA+ID4gT24gVHVlLCBBcHIgMDIsIDIwMTkgYXQgMDE6
MjY6MTlQTSAtMDQwMCwgQnJhZGxleSBDLiBLdXN6bWF1bA0KPiA+ID4gd3JvdGU6DQo+ID4gPiA+
IE15IHNpbXBsZSBtb2RlbCBvZiBtZXRhZGF0YSBvcGVyYXRpb25zIGlzIHRvIHVudGFyIHNvbWV0
aGluZw0KPiA+ID4gPiBsaWtlDQo+ID4gPiA+IHRoZSBsaW51eCBzb3VyY2VzLg0KPiA+ID4gPiAN
Cj4gPiA+ID4gRWFjaCBmaWxlIGluY3VycyBhIExPT0tVUCwgQ1JFQVRFLCBTRVRBVFRSLCBhbmQg
V1JJVEUsIGVhY2ggb2YNCj4gPiA+ID4gd2hpY2gNCj4gPiA+ID4gaXMgZmFpcmx5IGhpZ2ggbGF0
ZW5jeSAoZXZlbiB0aGUgV1JJVEUgZW5kcyB1cCBiZWluZyBkb25lDQo+ID4gPiA+IGVzc2VudGlh
bGx5IHN5bmNocm9ub3VzbHkgYmVjYXVzZSB0YXIgY2xvc2VzIHRoZSBmaWxlIGFmdGVyIGl0cw0K
PiA+ID4gPiB3cml0ZSgyKSBjYWxsLikNCj4gPiA+IA0KPiA+ID4gQW4gb3JkaW5hcnkgZmlsZSB3
cml0ZSBkZWxlZ2F0aW9uIGNhbiBoZWxwIHdpdGggc29tZSBvZiB0aGF0Lg0KPiA+ID4gDQo+ID4g
PiA+IEkgZ3Vlc3MgZGlyZWN0b3J5IGRlbGVnYXRpb25zIG1pZ2h0IHNhdmUgdGhlIGNvc3Qgb2Yg
TE9PS1VQLg0KPiA+ID4gPiANCj4gPiA+ID4gSXMgdGhlcmUgYW55IGhvcGUgZm9yIGdldHRpbmcg
d3JpdGUgZGVsZWdhdGlvbnM/DQo+ID4gPiA+IA0KPiA+ID4gPiBXaGF0IG90aGVyIHN0ZXBzIG1p
Z2h0IGJlIHBvc3NpYmxlPw0KPiA+ID4gDQo+ID4gPiBUcm9uZCwgd2Fzbid0IHRoZXJlIGEgZHJh
ZnQgZGVzY3JpYmluZyB5b3VyIGlkZWEgdGhhdCBhIHNlcnZlcg0KPiA+ID4gc2hvdWxkDQo+ID4g
PiBiZQ0KPiA+ID4gYWJsZSB0byBncmFudCBhIHdyaXRlIGRlbGVnYXRpb24gb24gY3JlYXRlIGFu
ZCBkZWxheSB0aGUgc3luYz8gIEkNCj4gPiA+IGNhbid0DQo+ID4gPiBmaW5kIGl0IHJpZ2h0IG5v
dy4NCj4gPiANCj4gPiBEbyB5b3UgbWVhbiB0aGlzIG9uZT8gDQo+ID4gaHR0cHM6Ly90b29scy5p
ZXRmLm9yZy9odG1sL2RyYWZ0LWhheW5lcy1uZnN2NC1kZWxzdGlkLTAwDQo+IA0KPiBNYXliZSBp
dCdzIHRvbyBzdWJ0bGUgZm9yIG1lLiAgV2hhdCdzIHRoZSBwYXJ0IHRoYXQgYWxsb3dzIGRlbGF5
aW5nDQo+IHN5bmMNCj4gb24gY3JlYXRlPw0KPiANCg0KVGhlIGNyZWF0ZSBpdHNlbGYgbmVlZHMg
dG8gYmUgc3luYywgYnV0IHRoZSBhdHRyaWJ1dGUgZGVsZWdhdGlvbnMgbWVhbg0KdGhhdCB0aGUg
Y2xpZW50LCBub3QgdGhlIHNlcnZlciwgaXMgYXV0aG9yaXRhdGl2ZSBmb3IgdGhlIHRpbWVzdGFt
cHMuDQpTbyB0aGUgY2xpZW50IG5vdyBvd25zIHRoZSBhdGltZSBhbmQgbXRpbWUsIGFuZCBqdXN0
IHNldHMgdGhlbSBhcyBwYXJ0DQpvZiB0aGUgKGFzeW5jaHJvbm91cykgZGVsZWdyZXR1cm4gc29t
ZSB0aW1lIGFmdGVyIHlvdSBhcmUgZG9uZSB3cml0aW5nLg0KDQpXZXJlIHlvdSBwZXJoYXBzIHRo
aW5raW5nIGFib3V0IHRoaXMgZWFybGllciBwcm9wb3NhbD8gDQpodHRwczovL3Rvb2xzLmlldGYu
b3JnL2h0bWwvZHJhZnQtbXlrbGVidXN0LW5mc3Y0LXVuc3RhYmxlLWZpbGUtY3JlYXRpb24tMDEN
Cg0KQ2hlZXJzDQogIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2Uu
Y29tDQoNCg0K
