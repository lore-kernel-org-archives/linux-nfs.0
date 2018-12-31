Return-Path: <SRS0=v8AN=PI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C99E7C43387
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Dec 2018 18:09:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6A3172133F
	for <linux-nfs@archiver.kernel.org>; Mon, 31 Dec 2018 18:09:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="nsF7HPrm"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726903AbeLaSJN (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 31 Dec 2018 13:09:13 -0500
Received: from mail-eopbgr760090.outbound.protection.outlook.com ([40.107.76.90]:55296
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726332AbeLaSJN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 31 Dec 2018 13:09:13 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=PDtJcyA/pYfmqGMi7NXi/i16r6yBy/bkxi6xjnWWokY=;
 b=nsF7HPrm72TlxaSlLkOzk9qEoxOuxTRk4C8B3WcQ0e+wAr3G4qrLZEdkUuYHd/yizaOdrbtcFIgtCufqe+E8OZWSe/hmoDbKfBxQVV2zGXfygFsVwM8OURVZRzOh29d2DvQr9gbChosCyGmEmf/dqlA+twS5qir4lDn2SdsRaxw=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2478.namprd13.prod.outlook.com (52.135.95.143) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1495.6; Mon, 31 Dec 2018 18:09:07 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%3]) with mapi id 15.20.1495.005; Mon, 31 Dec 2018
 18:09:07 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Topic: [PATCH v3 26/44] SUNRPC: Improve latency for interactive tasks
Thread-Index: AQHUTob5qK09WaTXZkeMo/gY+CHqD6WTldAAgAAwIgCAAAW4AIAF/x2A
Date:   Mon, 31 Dec 2018 18:09:06 +0000
Message-ID: <4e46f31cc59315533e477cb667f903731598f7f1.camel@hammerspace.com>
References: <20180917130335.112832-1-trond.myklebust@hammerspace.com>
         <20180917130335.112832-2-trond.myklebust@hammerspace.com>
         <20180917130335.112832-3-trond.myklebust@hammerspace.com>
         <20180917130335.112832-4-trond.myklebust@hammerspace.com>
         <20180917130335.112832-5-trond.myklebust@hammerspace.com>
         <20180917130335.112832-6-trond.myklebust@hammerspace.com>
         <20180917130335.112832-7-trond.myklebust@hammerspace.com>
         <20180917130335.112832-8-trond.myklebust@hammerspace.com>
         <20180917130335.112832-9-trond.myklebust@hammerspace.com>
         <20180917130335.112832-10-trond.myklebust@hammerspace.com>
         <20180917130335.112832-11-trond.myklebust@hammerspace.com>
         <20180917130335.112832-12-trond.myklebust@hammerspace.com>
         <20180917130335.112832-13-trond.myklebust@hammerspace.com>
         <20180917130335.112832-14-trond.myklebust@hammerspace.com>
         <20180917130335.112832-15-trond.myklebust@hammerspace.com>
         <20180917130335.112832-16-trond.myklebust@hammerspace.com>
         <20180917130335.112832-17-trond.myklebust@! hammerspace.com>
         <20180917130335.112832-18-trond.myklebust@hammerspace.com>
         <20180917130335.112832-19-trond.myklebust@hammerspace.com>
         <20180917130335.112832-20-trond.myklebust@hammerspace.com>
         <20180917130335.112832-21-trond.myklebust@hammerspace.com>
         <20180917130335.112832-22-trond.myklebust@hammerspace.com>
         <20180917130335.112832-23-trond.myklebust@hammerspace.com>
         <20180917130335.112832-24-trond.myklebust@hammerspace.com>
         <20180917130335.112832-25-trond.myklebust@hammerspace.com>
         <20180917130335.112832-26-trond.myklebust@hammerspace.com>
         <20180917130335.112832-27-trond.myklebust@hammerspace.com>
         <4D3465FB-041C-4BB1-AB75-03511FA5AAF1@oracle.com>
         <BC34B04D-4AD5-46FB-8DC6-310BF3FBEBD3@hammerspace.com>
         <4FB643C8-4790-42B9-AF38-622E10F6A1B2@oracle.com>
In-Reply-To: <4FB643C8-4790-42B9-AF38-622E10F6A1B2@oracle.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2478;6:ai0NPgK/sWA3mX/mvv10SA0OwsHecfyaq6das0Le5XKw4+7G7a/XLs7hD3HROQNokwN8KGesEiUMab1mrEVv4nbutCPgAOILj1prQpmiEexEX2+fhzywtm0osrsh2wzIFE61R3KYoVnuOu5+dzJU1N3tsZaVv4FJQBYXSBCkDKsYasoiW03WYEMBkffmc0y5rL4mnlSPkruyUBBaXvy4J9ahX4uOMfF/9vMVB8wofE84iTf9zxEo8D6BVuBEYjQ3dzP3k7u/s6bLM9nksQtkTNiLUXp/7QImUAyjYjqM/FhALdHzv8+gNlI/cMwj+vjg0o2xdBssBDShwJ2vCbb/eL2eeOfSN+yCN1He3trhi8yFCcerDBbVseC8uvmllMRgVTQ6WRhiZgDfKVVcWbYSXFTst43EplmACvmgUJ20h7rdqxVIZplPR3WLC2pgoxvqEtwGB3A2r7LXr1zekU/zXQ==;5:j0/48IEI0/7HoQP9TncvpuTCH7sO6NDcwnY/wc5KKJKng5ZGLDXBE2z2+XevOojNWh22kgwDojkWn2YlvIl1vKJYsAjzvTA29r5L0zknAQU3VH7TfrXdmMkwRrGj1Twelzn0I2ilHP97stsxBXzRgZL0izmoZBlMBDHYzpezU0+hdDMaE0IsRbWMXy8KI30R+pNSJFpZuCkz1ZBOKBAEhw==;7:+j9OA+tQTyxu6q1DnkEYphR5y3FZksCq/ftwfPxR19e8R5tB/Ftf1HseLRZpXCWe5xYlb6eHwI8z1hTczDNOYH2WqaszjDpapouoUYpZhfrCqpxIgzdPJ05mTj4vwVxEcMSMCbKZlZsFZJcmviKh5Q==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 47d8b854-a49c-4eef-ada8-08d66f4b0e4e
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600109)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2478;
x-ms-traffictypediagnostic: SN6PR13MB2478:
x-microsoft-antispam-prvs: <SN6PR13MB247843C7E5E2CDE29B3FF8E4B8B20@SN6PR13MB2478.namprd13.prod.outlook.com>
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(908002)(999002)(5005026)(6040522)(2401047)(8121501046)(10201501046)(3231475)(944501520)(52105112)(3002001)(93006095)(93001095)(6041310)(20161123560045)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123562045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2478;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2478;
x-forefront-prvs: 0903DD1D85
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(366004)(376002)(136003)(396003)(39830400003)(199004)(189003)(2501003)(316002)(4326008)(86362001)(14454004)(256004)(118296001)(14444005)(53936002)(105586002)(68736007)(2351001)(486006)(305945005)(7736002)(8936002)(99286004)(81166006)(106356001)(6116002)(3846002)(93886005)(25786009)(478600001)(6246003)(6436002)(8676002)(81156014)(5640700003)(66066001)(5660300001)(6512007)(2906002)(71190400001)(71200400001)(229853002)(6486002)(4001150100001)(102836004)(53546011)(6916009)(6506007)(26005)(11346002)(476003)(2616005)(186003)(76176011)(446003)(97736004)(36756003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2478;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: E/aa1PlIOnemtPm9xwp2l/LXZ2+qpbtbZFOaKv3QtCh0qC9Bjs90izvmDSOhchgLUq2gAmyB/eBxJeChRtIsQf8/oV9u3sK1HRtZWn04dkpse4lxdYD0a4fc7rr8vNZdUbUp1aAbqdpTXsA53cIGipV5FDjdChgvnTSxeEZIwuWV2oCO8MeE4RPgr9NCJSmpkYNzN38MCKWjb9GgCy/NG52he4/HG8cjreax0O2YyGh+oX14/TI9IBSCNLauXvoElCPyBbCVY5kiR4V6LpRywjxu1J0emjJVaMLZi6y5/nV0mmFi1rgq4tX2vensSCp6
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <6BBA98735FF7CD428D1EB9DB43EB064A@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 47d8b854-a49c-4eef-ada8-08d66f4b0e4e
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Dec 2018 18:09:07.1208
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2478
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE4LTEyLTI3IGF0IDE3OjM0IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiBPbiBEZWMgMjcsIDIwMTgsIGF0IDU6MTQgUE0sIFRyb25kIE15a2xlYnVzdCA8DQo+ID4gdHJv
bmRteUBoYW1tZXJzcGFjZS5jb20+IHdyb3RlOg0KPiA+IA0KPiA+IA0KPiA+IA0KPiA+ID4gT24g
RGVjIDI3LCAyMDE4LCBhdCAyMDoyMSwgQ2h1Y2sgTGV2ZXIgPGNodWNrLmxldmVyQG9yYWNsZS5j
b20+DQo+ID4gPiB3cm90ZToNCj4gPiA+IA0KPiA+ID4gSGkgVHJvbmQtDQo+ID4gPiANCj4gPiA+
IEkndmUgY2hhc2VkIGRvd24gYSBjb3VwbGUgb2YgcmVtYWluaW5nIHJlZ3Jlc3Npb25zIHdpdGgg
dGhlIHY0LjIwDQo+ID4gPiBORlMgY2xpZW50LA0KPiA+ID4gYW5kIHRoZXkgc2VlbSB0byBiZSBy
b290ZWQgaW4gdGhpcyBjb21taXQuDQo+ID4gPiANCj4gPiA+IFdoZW4gdXNpbmcgc2VjPWtyYjUs
IGtyYjVpLCBvciBrcmI1cCBJIGZvdW5kIHRoYXQgbXVsdGktdGhyZWFkZWQNCj4gPiA+IHdvcmts
b2Fkcw0KPiA+ID4gdHJpZ2dlciBhIGxvdCBvZiBzZXJ2ZXItc2lkZSBkaXNjb25uZWN0cy4gVGhp
cyBpcyB3aXRoIFRDUCBhbmQNCj4gPiA+IFJETUEgdHJhbnNwb3J0cy4NCj4gPiA+IEFuIGluc3Ry
dW1lbnRlZCBzZXJ2ZXIgc2hvd3MgdGhhdCB0aGUgY2xpZW50IGlzIHVuZGVyLXJ1bm5pbmcgdGhl
DQo+ID4gPiBHU1Mgc2VxdWVuY2UNCj4gPiA+IG51bWJlciB3aW5kb3cuIEkgbW9uaXRvcmVkIHRo
ZSBvcmRlciBpbiB3aGljaCBHU1Mgc2VxdWVuY2UNCj4gPiA+IG51bWJlcnMgYXBwZWFyIG9uDQo+
ID4gPiB0aGUgd2lyZSwgYW5kIGFmdGVyIHRoaXMgY29tbWl0LCB0aGUgc2VxdWVuY2UgbnVtYmVy
cyBhcmUgd2lsZGx5DQo+ID4gPiBtaXNvcmRlcmVkLg0KPiA+ID4gSWYgSSByZXZlcnQgdGhlIGh1
bmsgaW4geHBydF9yZXF1ZXN0X2VucXVldWVfdHJhbnNtaXQsIHRoZQ0KPiA+ID4gcHJvYmxlbSBn
b2VzIGF3YXkuDQo+ID4gPiANCj4gPiA+IEkgYWxzbyBmb3VuZCB0aGF0IHJldmVydGluZyB0aGF0
IGh1bmsgcmVzdWx0cyBpbiBhIDMtNCUNCj4gPiA+IGltcHJvdmVtZW50IGluIGZpbw0KPiA+ID4g
SU9QUyByYXRlcywgYXMgd2VsbCBhcyBpbXByb3ZlbWVudCBpbiBhdmVyYWdlIGFuZCBtYXhpbXVt
IGxhdGVuY3kNCj4gPiA+IGFzIHJlcG9ydGVkDQo+ID4gPiBieSBmaW8uDQo+ID4gPiANCj4gPiAN
Cj4gPiBIbW3igKYgUHJvdmlkZWQgdGhlIHNlcXVlbmNlIG51bWJlcnMgc3RpbGwgbGllIHdpdGhp
biB0aGUgd2luZG93LA0KPiA+IHRoZW4gd2h5IHdvdWxkIHRoZSBvcmRlciBtYXR0ZXI/DQo+IA0K
PiBUaGUgbWlzb3JkZXJpbmcgaXMgc28gYmFkIHRoYXQgb25lIHJlcXVlc3QgaXMgZGVsYXllZCBs
b25nIGVub3VnaCB0bw0KPiBmYWxsIG91dHNpZGUgdGhlIHdpbmRvdy4gVGhlIG5ldyDigJxuZWVk
IHJlLWVuY29kZeKAnSBsb2dpYyBkb2VzIG5vdA0KPiB0cmlnZ2VyLg0KPiANCg0KVGhhdCdzIHdl
aXJkLiBJIGNhbid0IHNlZSBhbnl0aGluZyB3cm9uZyB3aXRoIG5lZWQgcmUtZW5jb2RlIGF0IHRo
aXMNCnBvaW50LiBEbyB0aGUgd2luZG93IHNpemVzIGFncmVlIG9uIHRoZSBjbGllbnQgYW5kIHRo
ZSBzZXJ2ZXI/DQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50
YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
