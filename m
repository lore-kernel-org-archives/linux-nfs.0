Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 26FD1C43612
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 14:52:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DD4932133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 14:52:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="dqmtMSXd"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732948AbeLQOvx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 09:51:53 -0500
Received: from mail-eopbgr760120.outbound.protection.outlook.com ([40.107.76.120]:59931
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727605AbeLQOvw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Dec 2018 09:51:52 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lX8eZvEgGszksL+g8S+qm6gTb14bmsY4VOKPbuEs3xk=;
 b=dqmtMSXdoQMCYhxPSOtLoBr7bhyyrULaD1AHheeQt4QuGjI1I1exmEfoQyvJim/RW0bTkdS7VM6KUCtwD7rOK24NQdXq5vfActMd/39dA3Dli1uIeNd0P9cl/ckjVZkPRpQ6NcfaNvnWuNVDEpUyAMUXP7ruAHJzUTTA6nb6V70=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2239.namprd13.prod.outlook.com (52.135.93.152) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.14; Mon, 17 Dec 2018 14:51:47 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1446.015; Mon, 17 Dec 2018
 14:51:47 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "geert@linux-m68k.org" <geert@linux-m68k.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
        "anemo@mba.ocn.ne.jp" <anemo@mba.ocn.ne.jp>
Subject: Re: NFS/TCP crashes on MIPS/RBTX4927 in v4.20-rcX (bisected)
Thread-Topic: NFS/TCP crashes on MIPS/RBTX4927 in v4.20-rcX (bisected)
Thread-Index: AQHUi9i5PIVFqTXGUkaECw8346+eJ6VwIHQAgAAITgCAAAEhAIAAEWKAgBLPo4CAAA11gA==
Date:   Mon, 17 Dec 2018 14:51:47 +0000
Message-ID: <f322eb9ee0cac75f98d188b46843c2df00485f35.camel@hammerspace.com>
References: <CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com>
         <20181205.221146.969453990167463340.anemo@mba.ocn.ne.jp>
         <CAMuHMdU9zXXSaPHKvfG3A73h3CTsb9H2RT_gWt-Ne=qQ+HKShQ@mail.gmail.com>
         <92ce4b8c2b2d53e27ed5bc0e5af3fee4bc17b4dc.camel@hammerspace.com>
         <CAMuHMdXyfEVOWoBOx0Ywm6vw5oQ6eHNXFhQBKTfRSBOmPYGM6Q@mail.gmail.com>
         <CAMuHMdXT_25_64w88KTnAYDwmLnMACua=s2PgAxDv=1ZaBmB7A@mail.gmail.com>
In-Reply-To: <CAMuHMdXT_25_64w88KTnAYDwmLnMACua=s2PgAxDv=1ZaBmB7A@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2239;6:vRuNN45HQmWgbBa0uqlzwk718GgvZgkCPh8+n1HnSK/+Ra6RCdPuLxmazwQHoTV/cii7sATLkFBx+vtSbYLoca64ACMxJqxwx8ezdGiqxiaHL3KFJPiVCcsqhuvM5pZEKJpQ5U0quHsCmL1fiwZbMB0+6LJ4ZDeb3HzU7/Nj2wl0ASYjSeXNKUF7eaNLAeXF1QDlk1fZDwOCcqpTE48yawioO/kf/Ub/xuTTAhYw0CXTN4Tc+wy8IZdLFVath5QhXahi0nNoaiN/UN+/wu5HN0OSTmpUU8XP1Mbrkr8Sa6Ks7pd4D27wcfzynWo1mPTIv9hBC/SRUjAZ5csC+gWr/QOCkLHU+GPq/rW60GHkDNQKN8KCKqf/K2pP3jOhxdxH3G9j8vCNdN5kmRXfpfA4BRlJd3XgEYG342pwa/EFTvSQ/fUCSFJSaMbaBiLitqDhtvc/xnbV6PB8TpWTZVUHqQ==;5:4K6sCcrT+MYlhxL5VYeKolilewcm5Y7ZVx2o3G+sxsAGSE6pIefbB7YB5Vetfao2dRPIddDK3Peh2BgkJg5t47HbmuNJf5iXfPGzXS1eiGPIn43vgpiFi6lM8HOvUg9az+zk9yUB9n2oBlkfzkg4UwM4y3qi2EmCZpx5nBmPH7o=;7:rVMMmxk2ZlwQINzOg0IJaw75LVe42zPy2EpicN0WgCP10xTjZvNnpookHsp9HefcqV2hUa2gGAQOnccP4O1H/dxjQwELHik2hChHRijDyrd87Ue9gdvlmEyRH2r/uUV7Nhx0OkFW3nOgfiG3a0giTA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 3e9d8c7b-2a76-442b-c46b-08d6642f2b7a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2239;
x-ms-traffictypediagnostic: SN6PR13MB2239:
x-microsoft-antispam-prvs: <SN6PR13MB22396EFFED9CCF8143BB799DB8BC0@SN6PR13MB2239.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(6040522)(2401047)(8121501046)(5005006)(93006095)(93001095)(3231475)(944501520)(52105112)(3002001)(10201501046)(148016)(149066)(150057)(6041310)(20161123562045)(20161123564045)(20161123558120)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2239;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2239;
x-forefront-prvs: 08897B549D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(366004)(376002)(39830400003)(136003)(346002)(199004)(189003)(51914003)(2501003)(26005)(186003)(118296001)(5640700003)(7736002)(305945005)(68736007)(4326008)(81166006)(8936002)(8676002)(81156014)(1730700003)(6246003)(97736004)(6512007)(6306002)(71190400001)(5660300001)(4001150100001)(53936002)(71200400001)(14444005)(256004)(36756003)(2906002)(6486002)(229853002)(3846002)(54906003)(6116002)(66066001)(6436002)(6916009)(25786009)(14454004)(105586002)(76176011)(53546011)(446003)(11346002)(93886005)(476003)(2351001)(99286004)(106356001)(966005)(2616005)(486006)(316002)(102836004)(86362001)(6506007)(478600001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2239;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: iZls+sV0uci+72l8r12nijSZvlsU08Se2cU+pIlugP7hC/1G4Re5P6igtr9t/7DgQKRmoDJmFmC34dW+aijEv+eQWt1H4cDC5coR01Tek5vBd+4DxeFUM7ZqTjFajzUsdf+CXhWNy5/6qm+mw0/xXguhKDhDc5BC/7Dly9ZtKaIZiLqScHLXEqbfbOMAv/hQ2q3hec92e/Z6PYNNqun1RMBTOhfiXgJs3q+KwSbt6Ewu47DZh42Dh1WOWC/Bhu0c4DhtsiAxQdRthYPBnfId7Q3XUkP8xGZLQDm+QxvohCjkA8yPbaknC+LNf1MsfHzP
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <9E816BBD2342394998F717DD2359BAE9@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 3e9d8c7b-2a76-442b-c46b-08d6642f2b7a
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Dec 2018 14:51:47.2308
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2239
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgR2VlcnQsDQoNCk9uIE1vbiwgMjAxOC0xMi0xNyBhdCAxNTowMyArMDEwMCwgR2VlcnQgVXl0
dGVyaG9ldmVuIHdyb3RlOg0KPiBIaSBUcm9uZCwNCj4gDQo+IE9uIFdlZCwgRGVjIDUsIDIwMTgg
YXQgMzo0NyBQTSBHZWVydCBVeXR0ZXJob2V2ZW4gPA0KPiBnZWVydEBsaW51eC1tNjhrLm9yZz4g
d3JvdGU6DQo+ID4gT24gV2VkLCBEZWMgNSwgMjAxOCBhdCAyOjQ1IFBNIFRyb25kIE15a2xlYnVz
dCA8DQo+ID4gdHJvbmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+ID4gT24gV2VkLCAy
MDE4LTEyLTA1IGF0IDE0OjQxICswMTAwLCBHZWVydCBVeXR0ZXJob2V2ZW4gd3JvdGU6DQo+ID4g
PiA+IE9uIFdlZCwgRGVjIDUsIDIwMTggYXQgMjoxMSBQTSBBdHN1c2hpIE5lbW90byA8DQo+ID4g
PiA+IGFuZW1vQG1iYS5vY24ubmUuanA+DQo+ID4gPiA+IHdyb3RlOg0KPiA+ID4gPiA+IE9uIFR1
ZSwgNCBEZWMgMjAxOCAxNDo1MzowNyArMDEwMCwgR2VlcnQgVXl0dGVyaG9ldmVuIDwNCj4gPiA+
ID4gPiBnZWVydEBsaW51eC1tNjhrLm9yZz4gd3JvdGU6DQo+ID4gPiA+ID4gPiBJIGZvdW5kIHNp
bWlsYXIgY3Jhc2hlcyBpbiBhIHJlcG9ydCBmcm9tIDIwMDYsIGJ1dCBvZg0KPiA+ID4gPiA+ID4g
Y291cnNlIHRoZQ0KPiA+ID4gPiA+ID4gY29kZQ0KPiA+ID4gPiA+ID4gaGFzIGNoYW5nZWQgdG9v
IG11Y2ggdG8gYXBwbHkgdGhlIHNvbHV0aW9uIHByb3Bvc2VkIHRoZXJlDQo+ID4gPiA+ID4gPiAo
DQo+ID4gPiA+ID4gPiBodHRwczovL3d3dy5saW51eC1taXBzLm9yZy9hcmNoaXZlcy9saW51eC1t
aXBzLzIwMDYtMDkvbXNnMDAxNjkuaHRtbA0KPiA+ID4gPiA+ID4gKS4NCj4gPiA+ID4gPiA+IA0K
PiA+ID4gPiA+ID4gVXNlcmxhbmQgaXMgRGViaWFuIDggKHRoZSBsYXN0IHJlbGVhc2Ugc3VwcG9y
dGluZyAib2xkIg0KPiA+ID4gPiA+ID4gTUlQUykuDQo+ID4gPiA+ID4gPiBNeSBrZXJuZWwgaXMg
YmFzZWQgb24gdjQuMjAuMC1yYzUsIGJ1dCB0aGUgaXNzdWUgaGFwcGVucw0KPiA+ID4gPiA+ID4g
d2l0aA0KPiA+ID4gPiA+ID4gdjQuMjAtcmMxLA0KPiA+ID4gPiA+ID4gdG9vLg0KPiA+ID4gPiA+
ID4gDQo+ID4gPiA+ID4gPiBIb3dldmVyLCBJIG5vdGljZWQgaXQgd29ya3MgaW4gdjQuMTkhIEhl
bmNlIEkndmUgYmlzZWN0ZWQNCj4gPiA+ID4gPiA+IHRoaXMsDQo+ID4gPiA+ID4gPiB0byBjb21t
aXQNCj4gPiA+ID4gPiA+IDI3N2U0YWI3ZDUzMGJmMjggKCJTVU5SUEM6IFNpbXBsaWZ5IFRDUCBy
ZWNlaXZlIGNvZGUgYnkNCj4gPiA+ID4gPiA+IHN3aXRjaGluZw0KPiA+ID4gPiA+ID4gdG8gdXNp
bmcNCj4gPiA+ID4gPiA+IGl0ZXJhdG9ycyIpLg0KPiA+ID4gPiA+ID4gDQo+ID4gPiA+ID4gPiBE
cm9wcGluZyB0aGUgIix0Y3AiIHBhcnQgZnJvbSB0aGUgbmZzcm9vdCBwYXJhbWV0ZXIgYWxzbw0K
PiA+ID4gPiA+ID4gZml4ZXMNCj4gPiA+ID4gPiA+IHRoZSBpc3N1ZS4NCj4gPiA+ID4gPiA+IA0K
PiA+ID4gPiA+ID4gR2l2ZW4gUkJUWDQ5MjcgaXMgbGl0dGxlIGVuZGlhbiwganVzdCBsaWtlIG15
IGFybS9hcm02NA0KPiA+ID4gPiA+ID4gYm9hcmRzLA0KPiA+ID4gPiA+ID4gaXQncyBwcm9iYWJs
eQ0KPiA+ID4gPiA+ID4gbm90IGFuIGVuZGlhbm5lc3MgaXNzdWUuICBTcGFyc2UgZGlkbid0IHNo
b3cgYW55dGhpbmcNCj4gPiA+ID4gPiA+IHN1c3BpY2lvdXMNCj4gPiA+ID4gPiA+IGJlZm9yZS9h
ZnRlcg0KPiA+ID4gPiA+ID4gdGhlIGd1aWx0eSBjb21taXQuDQo+ID4gPiA+ID4gPiANCj4gPiA+
ID4gPiA+IERvIHlvdSBoYXZlIGEgY2x1ZT8NCj4gPiA+ID4gPiANCj4gPiA+ID4gPiBJZiBpdCB3
YXMgYSBjYWNoZSBpc3N1ZSwgZGlzYWJsaW5nIGktY2FjaGUgb3IgZC1jYWNoZQ0KPiA+ID4gPiA+
IGNvbXBsZXRlbHkNCj4gPiA+ID4gPiBtaWdodA0KPiA+ID4gPiA+IGhlbHAgdW5kZXJzdGFuZGlu
ZyB0aGUgcHJvYmxlbS4gIEkgYWRkZWQgVFh4OSBzcGVjaWZpYw0KPiA+ID4gPiA+ICJpY2Rpc2Fi
bGUiDQo+ID4gPiA+ID4gYW5kDQo+ID4gPiA+ID4gImRjZGlzYWJsZSIga2VybmVsIG9wdGlvbnMg
Zm9yIGRlYnVnZ2luZyBsb25nIGFnby4NCj4gPiA+ID4gPiANCj4gPiA+ID4gPiBJIGhvcGUgdGhl
c2Ugb3B0aW9ucyBzdGlsbCB3b3JrcyBjb3JyZWN0bHkgd2l0aCByZWNlbnQga2VybmVsDQo+ID4g
PiA+ID4gYnV0DQo+ID4gPiA+ID4gbm90DQo+ID4gPiA+ID4gc3VyZS4NCj4gPiA+ID4gPiANCj4g
PiA+ID4gPiBBbHNvLCBkaXNhYmxpbmcgaS1jYWNoZSBtYWtlcyB5b3VyIGJvYXJkIFZFUlkgc2xv
dywgb2YNCj4gPiA+ID4gPiBjb3Vyc2UuDQo+ID4gPiA+IA0KPiA+ID4gPiBUaGFua3MhDQo+ID4g
PiA+IA0KPiA+ID4gPiBXaGVuIHVzaW5nIHRoZXNlIG9wdGlvbnMsIEkgZG8gc2VlIGEgc2xvd2Rv
d24gaW4gZWFybHkgYm9vdCwNCj4gPiA+ID4gYnV0IHRoZQ0KPiA+ID4gPiBpc3N1ZQ0KPiA+ID4g
PiBpcyBzdGlsbCB0aGVyZS4NCj4gPiA+ID4gDQo+ID4gPiA+IE15IG5leHQgZ3Vlc3MgaXMgYW4g
dW5hbGlnbmVkIGFjY2VzcyBub3QgdXNpbmcNCj4gPiA+ID4ge2dldCxwdXR9X3VuYWxpZ25lZCgp
LA0KPiA+ID4gPiB3aGljaA0KPiA+ID4gPiBkb2Vzbid0IHNlZW0gdG8gd29yayBvbiB0eDQ5Mjcs
IGJ1dCBkb2Vzbid0IGNhdXNlIGFuIGV4Y2VwdGlvbg0KPiA+ID4gPiBuZWl0aGVyLg0KPiA+ID4g
DQo+ID4gPiBDYW4geW91IHRyeSBteSBsaW51eC1uZXh0IGJyYW5jaCBvbiBnaXQubGludXgtbmZz
Lm9yZz8gSXQNCj4gPiA+IGNvbnRhaW5zIGENCj4gPiA+IGZpeGVzIGZvciBhIGhhbmcgdGhhdCBy
ZXN1bHRzIGZyb20gdGhlIGFib3ZlIGNvbW1pdC4NCj4gPiA+IA0KPiA+ID4gZ2l0IHB1bGwgZ2l0
Oi8vZ2l0LmxpbnV4LW5mcy5vcmcvcHJvamVjdHMvdHJvbmRteS9saW51eC1uZnMuZ2l0DQo+ID4g
PiBsaW51eC1uZXh0DQo+ID4gDQo+ID4gVGhhbmtzIGZvciB0aGUgc3VnZ2VzdGlvbiwgYnV0IHVu
Zm9ydHVuYXRlbHkgaXQgZG9lc24ndCBoZWxwLg0KPiANCj4gSW4gdGhlIG1lYW4gdGltZSwgSSB0
cmllZCB5b3VyIG5ld2VyIGxpbnV4LW5leHQsIG5vIGNoYW5nZS4NCj4gSSB0cmllZCBzZXZlcmFs
IG90aGVyIHRoaW5nczoNCj4gICAtIHJlbW92ZSB0aGUgcGFja2VkIGF0dHJpYnV0ZSAod2h5IGRp
ZCB5b3UgYWRkIHRoYXQ/KSwNCg0KVGhlIHBhY2tlZCBhdHRyaWJ1dGUgYWxsb3dzIHVzIHRvIGF2
b2lkIGEgc2VyaWVzIG9mIGNvcHkgb3BlcmF0aW9ucw0Kd2hlbiBkZWNvZGluZyB0aGUgZmlyc3Qg
dGhyZWUgZWxlbWVudHMgb2YgYSBSUEMgb3ZlciBUQ1AgaGVhZGVyICh3aGljaA0KaXMgd2h5IHRo
ZXkgYXJlIGFsbCBkZWNsYXJlZCBhcyBiaWcgZW5kaWFuKS4gVGhlIGFsdGVybmF0aXZlIHdvdWxk
IGJlDQp0byBoYXZlIGEgMTIgYnl0ZSBidWZmZXIgdGhlcmUgZm9yIHRlbXBvcmFyeSBzdG9yYWdl
LCBhbmQgdGhlbiBhDQpkdXBsaWNhdGUgc2V0IG9mIDMgMzItYml0IHdvcmRzIGludG8gd2hpY2gg
d2UgY29weSB0aGUgYnVmZmVyIGNvbnRlbnRzDQphZnRlciBleHRyYWN0aW5nIHRoZW0gZnJvbSB0
aGUgKG5vbi1ibG9ja2luZykgc29ja2V0Lg0KDQo+ICAgLSB2ZXJpZnkgKGF0IHJ1bnRpbWUpIHRo
YXQgYWxsIGFjY2Vzc2VzIHRvIGZyYWdoZHIsIHhpZCwgYW5kDQo+IGNhbGxkaXINCj4gYXJlIGFs
aWduZWQsDQo+ICAgLSBlbmFibGUgUlBDX0RFQlVHX0RBVEEsIG5vdGhpbmcgZmlzaHkgc2VlbiBh
dCBmaXJzdCBzaWdodC4NCj4gDQo+IElzIGFueW9uZSBlbHNlIHNlZWluZyB0aGlzIG9uIE1JUFMs
IG9yIGFueSBvdGhlciBwbGF0Zm9ybT8NCj4gRG9lcyBtb3VudGluZyBORlMgd2l0aCAtbyBuZnN2
ZXJzPTMsdGNwIHdvcmsgb24gb3RoZXIgTUlQUyBwbGF0Zm9ybXM/DQoNCkkgaGF2ZSBubyBhY2Nl
c3MgdG8gYW55IE1JUFMgaGFyZHdhcmUgZm9yIHRoZSBwdXJwb3NlcyBvZiB0ZXN0aW5nIHNvDQp0
aGF0IHdvdWxkIGJlIGEgcXVlc3Rpb24gZm9yIHRoZSBjb21tdW5pdHkuDQoNCk9uZSB0aGluZyB0
aGF0IEkgaGF2ZSBub3RpY2VkIGlzIHRoYXQgdW5saWtlIHRoZSBvbGQgY29kZSwgdGhlIGJ2ZWMN
CidnZW5lcmljJyBjb2RlIGRvZXMgYXBwZWFyIHRvIGZhaWwgdG8gY2FsbCBmbHVzaF9kY2FjaGVf
cGFnZSgpLiBDb3VsZA0KdGhhdCBiZSBjYXVzaW5nIHRoZSBwcm9ibGVtIGhlcmU/IElmIHNvLCB3
aHkgd291bGQgdGhhdCBub3QgYmUgYQ0KcHJvYmxlbSBpbiB0aGUgY29udGV4dCBvZiByZWd1bGFy
IGJsb2NrIEkvTz8NCg0KQ2hlZXJzDQogIFRyb25kDQotLSANClRyb25kIE15a2xlYnVzdA0KTGlu
dXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhh
bW1lcnNwYWNlLmNvbQ0KDQoNCg==
