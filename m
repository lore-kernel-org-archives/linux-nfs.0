Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4734BC282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 20:53:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EE0F02229F
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 20:53:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=netapp.onmicrosoft.com header.i=@netapp.onmicrosoft.com header.b="K5JSHtJk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728603AbfBLUxh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 15:53:37 -0500
Received: from mail-eopbgr800045.outbound.protection.outlook.com ([40.107.80.45]:42733
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729617AbfBLUxh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 15:53:37 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=netapp.onmicrosoft.com; s=selector1-netapp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=DQRjIiqjlc/jVOfkFCqm1iP/5Bjw4ixLrhzQbKVilQc=;
 b=K5JSHtJkC/jwyEcDhYEPczYteRTubLWOpwS2P/pzI9eEKX9ao5SliWcmA/7hzU033Xn91/4LJym1JfTUqwvb1GpO7yRglXoak1I+wHei0PfDA29JrfaBoVcDpwDNcPmBb504BhSJoFMrXk0VlxgQSBHdL5rSXpvDZdZpqMrdaF0=
Received: from BN8PR06MB6228.namprd06.prod.outlook.com (20.178.217.156) by
 BN8PR06MB5953.namprd06.prod.outlook.com (20.179.139.219) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.21; Tue, 12 Feb 2019 20:52:53 +0000
Received: from BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::d2f:dbea:270:9aea]) by BN8PR06MB6228.namprd06.prod.outlook.com
 ([fe80::d2f:dbea:270:9aea%3]) with mapi id 15.20.1601.023; Tue, 12 Feb 2019
 20:52:53 +0000
From:   "Schumaker, Anna" <Anna.Schumaker@netapp.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "trond.myklebust@hammerspace.com" <trond.myklebust@hammerspace.com>,
        "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>
CC:     "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dhowells@redhat.com" <dhowells@redhat.com>
Subject: Re: [PATCH] rpc: properly check debugfs dentry before using it
Thread-Topic: [PATCH] rpc: properly check debugfs dentry before using it
Thread-Index: AQHUwwCmJ61uGSi0sEGxtE9OEOsrRqXco9UA
Date:   Tue, 12 Feb 2019 20:52:53 +0000
Message-ID: <2a029733e094460e2f57bb2d3fc28e7e1757b83e.camel@netapp.com>
References: <20190212182734.GA4509@kroah.com>
In-Reply-To: <20190212182734.GA4509@kroah.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
user-agent: Evolution 3.30.5 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Anna.Schumaker@netapp.com; 
x-originating-ip: [73.145.169.100]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: fdeb478c-1174-4f33-cb5f-08d6912c0ebf
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7193020);SRVR:BN8PR06MB5953;
x-ms-traffictypediagnostic: BN8PR06MB5953:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtCTjhQUjA2TUI1OTUzOzIzOnhKKzlaMGZNdGdRMGxoTVllMks5Yk5GbDhZ?=
 =?utf-8?B?d2x6VSsyTUpKd1R0WkM1V1BMSUJmZ2MxdVg0QmZqcktWZGQ2bVhORGpNTVFF?=
 =?utf-8?B?dThCZlFEdFNhbUNpWksvdSt1TWFBOWI4LzFoVHhqWDBZY0xUbE1qN0NRN2ha?=
 =?utf-8?B?ZS9QUHdLck9KNVJjMnhReEcyRUFIY2xtSHM1YytaNmpNMW1qdDFZUkNUZHFY?=
 =?utf-8?B?aWpPdjRXOWdISlFvVjZNR2UxOHVWTm91NXR6Zk12TlJCQVA5anFocVZVeWNP?=
 =?utf-8?B?Ry9VOUJHZnhGaXkvRGtMUzRVanFCVVBzK1BYeERmclE4dUNTVUIxbGpNeW1Y?=
 =?utf-8?B?eGFUM0ZVMllJR1ZsZ1h6QldIKzN4b2dlM0EyeVZqdzhtbDR1MHlLWElzTUEw?=
 =?utf-8?B?NElhOWE4ZzVyTWk5R2ppOVpzSEtma0tpYVpISFhJOE1XRHByUy9nR3FLUFM2?=
 =?utf-8?B?NUNVUzZFM0M3V2dqZkcxTXlQTW93ZG9pM0RIMmlsQjZRQ2ZkbnFEVC8yZ3ZX?=
 =?utf-8?B?QlE4eTBMT1NLa216TWU5MFZ1Nlg5RlVQNEkrSTM5VWo0U1hkcFFoUVdzaEpa?=
 =?utf-8?B?SGZ1WVFKVVlnbnk2dEYxWHlvd1VCSkhPOUJRRzVacCtLZEtQeEo3K3FYM3Nu?=
 =?utf-8?B?SDhNZnF0NGhndzlneVdKLy9JUVVMdHhtQU9KUkRTbm5xb3JoZ1hNcVBlOHYy?=
 =?utf-8?B?aHVjQzFsYjlLL1FIZCtaWUw2UjBFMmJuK0g1R2t2SXpZa0kwSGw5UnNITUxS?=
 =?utf-8?B?TnNDT05pNlZjOWpCY2cvLy9KdjN3bXFxL2I1THBWdDFzdzd3aTZ4SmdUUERU?=
 =?utf-8?B?SlhPMFV2K2pWVk9WNXJ4cHVFY2M2UWI0ZWZraldyYlhlVksweU8wdnVPWElZ?=
 =?utf-8?B?dlVQb1NzQ3dId3hSUnFWdE5FZEsvTUkxNS8wZEg5UUZsQVJyTjZ5SmZNc1Nm?=
 =?utf-8?B?TjI5VmlIeU5lcWpjZi90QzR1ZWQ2VDNTaGFCZEU3UDFRNVdGK3U5R3BsSE5C?=
 =?utf-8?B?c0QzMkZEc3ZmNzV4aWlKTnNNVy81citGNTdyK2NhRS93OG1oOFUxZDA3NGlK?=
 =?utf-8?B?ZVhGcGFqQWwwa3hQaDBWaGNaeTNQM3Z3N3FKWFg0cEdsMXpWUEdMRlhvR1Zi?=
 =?utf-8?B?WUdpT2Q0UU9lSUNWaTdZdXdPU1hVcHNxMWx5cFlmZE1xZUp2T3lUQ1ZmZjF6?=
 =?utf-8?B?RCtkUFJSSnBlV1ZJZ2RGMUlHSlJ3SnlNT2dBZ1pRS21EUTQ5V1hVYUUvNWZz?=
 =?utf-8?B?Mis1ZnYybnRpOThqSkF3d2p5c0dLWjBkWjRyMFE3c0VtNlZadFNwb25zYUIz?=
 =?utf-8?B?dldFQS9ES1FQcTFHWDE5R3RRQjRCbE1BS1lQWE9UWDZzYVhhcjhoYWd5eElh?=
 =?utf-8?B?S2hMSXE3OWo0dWZiTGlHdkp3TmFCZWZ4R29Ga01tTlVPZEVkQVN1UkZkUzVQ?=
 =?utf-8?B?SkdabkloMnVzK1FSaUtGeE8rQjVhaktYaFFmS05vUGpTNXg2bTFLK2wwVW1D?=
 =?utf-8?B?dThyR01GV3BvMmlYRkFFOVBjcFBpTXM3VlJkMmsrQTM3RFdUMVErY1Y3WWxQ?=
 =?utf-8?B?aTN2a0F3N1prdWZZVXE3N0N1eTQyL3ArTWh0RUh0L0tySjNWWi9Dell3aFBy?=
 =?utf-8?B?QnVZdnpBYzNnTGtyWm1QZkIzT2ord0JzYjVoOHRTQ0hSV241d0M1U3pqZGFI?=
 =?utf-8?Q?1KLaVKt4E6yNZp7gQfazoxobY9E7sh6JEK9QAIS?=
x-microsoft-antispam-prvs: <BN8PR06MB5953C2EFA75264B0D53021A7F8650@BN8PR06MB5953.namprd06.prod.outlook.com>
x-forefront-prvs: 0946DC87A1
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(346002)(39860400002)(136003)(376002)(366004)(396003)(199004)(189003)(25786009)(478600001)(3846002)(6436002)(6116002)(106356001)(97736004)(105586002)(229853002)(53936002)(72206003)(68736007)(86362001)(2201001)(2906002)(36756003)(6512007)(2501003)(14454004)(4326008)(8936002)(118296001)(305945005)(8676002)(71190400001)(66066001)(486006)(71200400001)(81166006)(7736002)(81156014)(99286004)(6486002)(316002)(58126008)(476003)(6246003)(76176011)(256004)(14444005)(11346002)(26005)(2616005)(446003)(6506007)(186003)(102836004)(54906003)(110136005);DIR:OUT;SFP:1101;SCL:1;SRVR:BN8PR06MB5953;H:BN8PR06MB6228.namprd06.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: netapp.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: m7yI1JVWO63Z6hePLTycA6/pIxTSQ/RKX8DT+hXvlhUBf1j7Hea1gknF2ERjsjTQ7v+GBLg6ZS2EZtZEtNM4EKUXcYJOKo3//DOSN/cjP0opgdk744aZy/vwmlAGguZKUjOGhjtReU2IuinILL/IIPcEIl2gVdrEIbMrPSqZtE2x4Q3+47IVFEdU9UFitADbR6TQAndECPwsC0dSxH9z68hUZI4KxM5dLytdNhneM6+PKoF14nsU3Qd4OCPdhRNi8cR0XKDPv696d0EcJV6ZteErNRcJF5lrMFfJwqamAnSMCSeaYHw0WOrYxU4+dfkyd62E91FVBuAie5BKj0CuEdgr/DBBHWXe1xMmX3S5sPo8AOKxEsMUbdE9iIZcTi09f8wOvA3vFjYA1IdszV/gO8Njkwlcx5VjoL/BG2UoS/w=
Content-Type: text/plain; charset="utf-8"
Content-ID: <1F83E91CFF559948BD0580E1E2828795@namprd06.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: netapp.com
X-MS-Exchange-CrossTenant-Network-Message-Id: fdeb478c-1174-4f33-cb5f-08d6912c0ebf
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Feb 2019 20:52:53.1032
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 4b0911a0-929b-4715-944b-c03745165b3a
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BN8PR06MB5953
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE5LTAyLTEyIGF0IDE5OjI3ICswMTAwLCBHcmVnIEtyb2FoLUhhcnRtYW4gd3Jv
dGU6DQo+IGRlYnVnZnMgY2FuIG5vdyByZXBvcnQgYW4gZXJyb3IgY29kZSBpZiBzb21ldGhpbmcg
d2VudCB3cm9uZyBpbnN0ZWFkIG9mDQo+IGp1c3QgTlVMTC4gIFNvIGlmIHRoZSByZXR1cm4gdmFs
dWUgaXMgdG8gYmUgdXNlZCBhcyBhICJyZWFsIiBkZW50cnksIGl0DQo+IG5lZWRzIHRvIGJlIGNo
ZWNrZWQgaWYgaXQgaXMgYW4gZXJyb3IgYmVmb3JlIGRlcmVmZXJlbmNpbmcgaXQuDQo+IA0KPiBU
aGlzIGlzIG5vdyBoYXBwZW5pbmcgYmVjYXVzZSBvZiBmZjlmYjcyYmMwNzcgKCJkZWJ1Z2ZzOiBy
ZXR1cm4gZXJyb3INCj4gdmFsdWVzLCBub3QgTlVMTCIpLCBidXQgd2h5IGRlYnVnZnMgZmlsZXMg
YXJlIG5vdCBiZWluZyBjcmVhdGVkIHByb3Blcmx5DQo+IGlzIGFuIG9sZGVyIGlzc3VlLCBwcm9i
YWJseSBvbmUgdGhhdCBoYXMgYWx3YXlzIGJlZW4gdGhlcmUgYW5kIHNob3VsZA0KPiBwcm9iYWJs
eSBiZSBsb29rZWQgYXQuLi4NCj4gDQo+IENjOiAiSi4gQnJ1Y2UgRmllbGRzIiA8YmZpZWxkc0Bm
aWVsZHNlcy5vcmc+DQo+IENjOiBKZWZmIExheXRvbiA8amxheXRvbkBrZXJuZWwub3JnPg0KPiBD
YzogVHJvbmQgTXlrbGVidXN0IDx0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tPg0KPiBD
YzogQW5uYSBTY2h1bWFrZXIgPGFubmEuc2NodW1ha2VyQG5ldGFwcC5jb20+DQo+IENjOiBsaW51
eC1uZnNAdmdlci5rZXJuZWwub3JnDQo+IENjOiBuZXRkZXZAdmdlci5rZXJuZWwub3JnDQo+IFJl
cG9ydGVkLWJ5OiBEYXZpZCBIb3dlbGxzIDxkaG93ZWxsc0ByZWRoYXQuY29tPg0KPiBUZXN0ZWQt
Ynk6IERhdmlkIEhvd2VsbHMgPGRob3dlbGxzQHJlZGhhdC5jb20+DQo+IFNpZ25lZC1vZmYtYnk6
IEdyZWcgS3JvYWgtSGFydG1hbiA8Z3JlZ2toQGxpbnV4Zm91bmRhdGlvbi5vcmc+DQo+IA0KPiAt
LS0NCj4gIG5ldC9zdW5ycGMvZGVidWdmcy5jIHwgMiArLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDEg
aW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pDQo+IA0KPiBJIGNhbiB0YWtlIHRoaXMgdGhyb3Vn
aCBteSB0cmVlIGlmIHBlb3BsZSBkb24ndCBvYmplY3QsIG9yIGl0IGNhbiBnbw0KPiB0aHJvdWdo
IHRoZSBORlMgdHJlZS4gIEl0IGRvZXMgbmVlZCB0byBnZXQgbWVyZ2VkIGJlZm9yZSA1LjAtZmlu
YWwNCj4gdGhvdWdoLg0KDQpJJ20gcGxhbm5pbmcgYW5vdGhlciBidWdmaXhlcyBwdWxsIGZvciA1
LjAsIHNvIEkgY2FuIHRha2UgdGhpcyBwYXRjaCBhbmQgc2VuZCBpdA0Kd2l0aCB0aGUgb3RoZXJz
IHRoaXMgd2Vlay4NCg0KVGhhbmtzIQ0KQW5uYQ0KDQo+IA0KPiBJIGFsc28gaGF2ZSBhICJsYXJn
ZXIiIGRlYnVnZnMgY2xlYW51cCBwYXRjaCBmb3IgdGhpcyBmaWxlLCBidXQgdGhhdCdzDQo+IG5v
dCByZWFsbHkgNS4wLWZpbmFsIG1hdGVyaWFsIGFuZCBJIHdpbGwgc2VuZCBpdCBvdXQgbGF0ZXIu
DQo+IA0KPiB0aGFua3MsDQo+IA0KPiBncmVnIGstaA0KPiANCj4gZGlmZiAtLWdpdCBhL25ldC9z
dW5ycGMvZGVidWdmcy5jIGIvbmV0L3N1bnJwYy9kZWJ1Z2ZzLmMNCj4gaW5kZXggNDVhMDMzMzI5
Y2Q0Li4xOWJiMzU2MjMwZWQgMTAwNjQ0DQo+IC0tLSBhL25ldC9zdW5ycGMvZGVidWdmcy5jDQo+
ICsrKyBiL25ldC9zdW5ycGMvZGVidWdmcy5jDQo+IEBAIC0xNDYsNyArMTQ2LDcgQEAgcnBjX2Ns
bnRfZGVidWdmc19yZWdpc3RlcihzdHJ1Y3QgcnBjX2NsbnQgKmNsbnQpDQo+ICAgICAgICAgcmN1
X3JlYWRfbG9jaygpOw0KPiAgICAgICAgIHhwcnQgPSByY3VfZGVyZWZlcmVuY2UoY2xudC0+Y2xf
eHBydCk7DQo+ICAgICAgICAgLyogbm8gImRlYnVnZnMiIGRlbnRyeT8gRG9uJ3QgYm90aGVyIHdp
dGggdGhlIHN5bWxpbmsuICovDQo+IC0gICAgICAgaWYgKCF4cHJ0LT5kZWJ1Z2ZzKSB7DQo+ICsg
ICAgICAgaWYgKElTX0VSUl9PUl9OVUxMKHhwcnQtPmRlYnVnZnMpKSB7DQo+ICAgICAgICAgICAg
ICAgICByY3VfcmVhZF91bmxvY2soKTsNCj4gICAgICAgICAgICAgICAgIHJldHVybjsNCj4gICAg
ICAgICB9DQo=
