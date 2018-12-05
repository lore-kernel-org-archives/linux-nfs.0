Return-Path: <SRS0=3CSe=OO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD48EC04EBF
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 13:45:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 87BB620851
	for <linux-nfs@archiver.kernel.org>; Wed,  5 Dec 2018 13:45:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="V/Fk81xd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87BB620851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727142AbeLENpv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 5 Dec 2018 08:45:51 -0500
Received: from mail-eopbgr690138.outbound.protection.outlook.com ([40.107.69.138]:16224
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727103AbeLENpv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 5 Dec 2018 08:45:51 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZMZXx2CT+LbizPfH5EwY0fQ8FsnJ1BeICa7sL+TWC9I=;
 b=V/Fk81xd91Q1QwyrU/LlvHgG3Z8oBteSMSpcZQ/b7j+8mXhrl2CKikr8sxOCzIiHUJFQkXp2Su7TZKLfV2uAr6Z+1iK+GaNmknV8EmEtr3qCnZsFXrh/4ouZK9rWbOUq0v/Wc9a/xwJbGynlfml+0WqKsSCKyYsse5Juimi9PDM=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2271.namprd13.prod.outlook.com (52.135.93.160) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1404.9; Wed, 5 Dec 2018 13:45:35 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1404.019; Wed, 5 Dec 2018
 13:45:34 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "geert@linux-m68k.org" <geert@linux-m68k.org>,
        "anemo@mba.ocn.ne.jp" <anemo@mba.ocn.ne.jp>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>
Subject: Re: NFS/TCP crashes on MIPS/RBTX4927 in v4.20-rcX (bisected)
Thread-Topic: NFS/TCP crashes on MIPS/RBTX4927 in v4.20-rcX (bisected)
Thread-Index: AQHUi9i5PIVFqTXGUkaECw8346+eJ6VwIHQAgAAITgCAAAEhAA==
Date:   Wed, 5 Dec 2018 13:45:34 +0000
Message-ID: <92ce4b8c2b2d53e27ed5bc0e5af3fee4bc17b4dc.camel@hammerspace.com>
References: <CAMuHMdVJr0PwvJg3FeTCy7vxuyY1=S1tPLHO7hPsoZX4wZ+-cQ@mail.gmail.com>
         <20181205.221146.969453990167463340.anemo@mba.ocn.ne.jp>
         <CAMuHMdU9zXXSaPHKvfG3A73h3CTsb9H2RT_gWt-Ne=qQ+HKShQ@mail.gmail.com>
In-Reply-To: <CAMuHMdU9zXXSaPHKvfG3A73h3CTsb9H2RT_gWt-Ne=qQ+HKShQ@mail.gmail.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2271;6:4WioMaeSEw5cc/nsBIanoRdta48a1rvahmkV6DD70kEW2c958pAH06MkwZQ5u5bRnt+nAuqcbK764lP89KLccz6vYK5hhjdVtVIUI478cNEKZsl0y+v/5Ilt2iFTlSPvEnhfk5ox3jiruqqw+gfQ5MBMl0dZnMuzvkRoSl7/+0TcjOFo2jGB14Gjqx0zYbY8e+d72uMAtINY1bAtRjeW+QugDs+0llZzypQav9JZ+Fywn7BplCLoAkiItNm8LQCStigbzsjbjwOxh49HVdjO7V0NFyqw59yu+VGMohq/Pa9JTMdgC26hlHMVJ370TOj1EAsUeYX0bmnDhpGLGfNFXxSdRJPWmJk2ndtjYaltBa6sGcNsJBSCf/lSxoydU8BDKsDek9WG+fWuVYB/+qZfQVbFVIFl0himvPzbFY4w2pF8UFLYt5mmLWQWmjkDlWQd+oZo2C5zt08fdwnzUSxg7w==;5:JprEpC0xQX/xqNFjRF69hhlhKq6GlMNPeBJW2tkDCcDIshMW2z83lsXC1crw2m/gWIaxjl8HWs92Q269lWfmLtJPhf+d+GartgX8jrG9XTn/Vsy/qffbK+x6tgeemH4X2sWErop1ypgiOM22NCccxFZ8jaQYWPxszcO46q4b/pA=;7:Jsxg+ftMMTiUYlR/3u2mwVPH+o/eu6TLjgn0zgHLfYbT4NcQpnpjdzgZCrqiZXYhwurOIFNovI5h/wXB89NDl0gvE5Hysg3qKwUuu8UhxX3Jef8wg+WRZCH90B1wqE5807rMTxk49TGP5ChdF2oVjQ==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 7067f467-f631-4b4c-9dde-08d65ab7eeb5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390098)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2271;
x-ms-traffictypediagnostic: SN6PR13MB2271:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB2271E44AECB5CEF2DD3ACA3DB8A80@SN6PR13MB2271.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(3002001)(93006095)(93001095)(3231455)(999002)(944501520)(52105112)(10201501046)(148016)(149066)(150057)(6041310)(20161123562045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123560045)(20161123564045)(20161123558120)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2271;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2271;
x-forefront-prvs: 08770259B4
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(136003)(346002)(376002)(396003)(366004)(199004)(189003)(14454004)(118296001)(4326008)(3846002)(229853002)(106356001)(6116002)(36756003)(2906002)(5660300001)(486006)(105586002)(446003)(97736004)(2501003)(11346002)(68736007)(6306002)(2616005)(6512007)(71190400001)(71200400001)(53936002)(6506007)(966005)(476003)(25786009)(478600001)(14444005)(256004)(305945005)(99286004)(6246003)(6436002)(86362001)(8936002)(316002)(81156014)(76176011)(66066001)(8676002)(81166006)(6486002)(53546011)(110136005)(7736002)(54906003)(186003)(102836004)(26005);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2271;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: Ax7W7BQawiGMO8H6XbQO7nTS881VkBxUt01UUaeWLu+w6vmwPpuOJDdrPNPc/iFu/Mo02LK3BYpDO/UwEqsoVJoJCsJozoYGwTcYBbIgGYL/3mQtDRGhgalbbQkr3ipbsWyzvoeM8NOrPz6lt0scblV6sf/ezL7AbSk7tXrWFkxxIfAYvKMAt+0Zo0DkkbRoqy5w6BAYzAC8lEESstI2DHJyrM0kvc3on9l2vGkbtvMr+BX21o4abtax4aNXqmcfG1Z+IKnykwjAaG9HlTphZxkfp3qiVH+LT7voDUAib2cBsHht6EYDxFHFNVPafpW7Kg1/YdL/kt7/w+YhyiJ5gPtq4V3e9kOnHAKJUxW5YDM=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <4B46B8F44433774B81CD172CC3E85955@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7067f467-f631-4b4c-9dde-08d65ab7eeb5
X-MS-Exchange-CrossTenant-originalarrivaltime: 05 Dec 2018 13:45:34.8357
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2271
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE4LTEyLTA1IGF0IDE0OjQxICswMTAwLCBHZWVydCBVeXR0ZXJob2V2ZW4gd3Jv
dGU6DQo+IEhpIE5lbW90by1zYW4sDQo+IA0KPiBPbiBXZWQsIERlYyA1LCAyMDE4IGF0IDI6MTEg
UE0gQXRzdXNoaSBOZW1vdG8gPGFuZW1vQG1iYS5vY24ubmUuanA+DQo+IHdyb3RlOg0KPiA+IE9u
IFR1ZSwgNCBEZWMgMjAxOCAxNDo1MzowNyArMDEwMCwgR2VlcnQgVXl0dGVyaG9ldmVuIDwNCj4g
PiBnZWVydEBsaW51eC1tNjhrLm9yZz4gd3JvdGU6DQo+ID4gPiBJIGZvdW5kIHNpbWlsYXIgY3Jh
c2hlcyBpbiBhIHJlcG9ydCBmcm9tIDIwMDYsIGJ1dCBvZiBjb3Vyc2UgdGhlDQo+ID4gPiBjb2Rl
DQo+ID4gPiBoYXMgY2hhbmdlZCB0b28gbXVjaCB0byBhcHBseSB0aGUgc29sdXRpb24gcHJvcG9z
ZWQgdGhlcmUNCj4gPiA+ICgNCj4gPiA+IGh0dHBzOi8vd3d3LmxpbnV4LW1pcHMub3JnL2FyY2hp
dmVzL2xpbnV4LW1pcHMvMjAwNi0wOS9tc2cwMDE2OS5odG1sDQo+ID4gPiApLg0KPiA+ID4gDQo+
ID4gPiBVc2VybGFuZCBpcyBEZWJpYW4gOCAodGhlIGxhc3QgcmVsZWFzZSBzdXBwb3J0aW5nICJv
bGQiIE1JUFMpLg0KPiA+ID4gTXkga2VybmVsIGlzIGJhc2VkIG9uIHY0LjIwLjAtcmM1LCBidXQg
dGhlIGlzc3VlIGhhcHBlbnMgd2l0aA0KPiA+ID4gdjQuMjAtcmMxLA0KPiA+ID4gdG9vLg0KPiA+
ID4gDQo+ID4gPiBIb3dldmVyLCBJIG5vdGljZWQgaXQgd29ya3MgaW4gdjQuMTkhIEhlbmNlIEkn
dmUgYmlzZWN0ZWQgdGhpcywNCj4gPiA+IHRvIGNvbW1pdA0KPiA+ID4gMjc3ZTRhYjdkNTMwYmYy
OCAoIlNVTlJQQzogU2ltcGxpZnkgVENQIHJlY2VpdmUgY29kZSBieSBzd2l0Y2hpbmcNCj4gPiA+
IHRvIHVzaW5nDQo+ID4gPiBpdGVyYXRvcnMiKS4NCj4gPiA+IA0KPiA+ID4gRHJvcHBpbmcgdGhl
ICIsdGNwIiBwYXJ0IGZyb20gdGhlIG5mc3Jvb3QgcGFyYW1ldGVyIGFsc28gZml4ZXMNCj4gPiA+
IHRoZSBpc3N1ZS4NCj4gPiA+IA0KPiA+ID4gR2l2ZW4gUkJUWDQ5MjcgaXMgbGl0dGxlIGVuZGlh
biwganVzdCBsaWtlIG15IGFybS9hcm02NCBib2FyZHMsDQo+ID4gPiBpdCdzIHByb2JhYmx5DQo+
ID4gPiBub3QgYW4gZW5kaWFubmVzcyBpc3N1ZS4gIFNwYXJzZSBkaWRuJ3Qgc2hvdyBhbnl0aGlu
ZyBzdXNwaWNpb3VzDQo+ID4gPiBiZWZvcmUvYWZ0ZXINCj4gPiA+IHRoZSBndWlsdHkgY29tbWl0
Lg0KPiA+ID4gDQo+ID4gPiBEbyB5b3UgaGF2ZSBhIGNsdWU/DQo+ID4gDQo+ID4gSWYgaXQgd2Fz
IGEgY2FjaGUgaXNzdWUsIGRpc2FibGluZyBpLWNhY2hlIG9yIGQtY2FjaGUgY29tcGxldGVseQ0K
PiA+IG1pZ2h0DQo+ID4gaGVscCB1bmRlcnN0YW5kaW5nIHRoZSBwcm9ibGVtLiAgSSBhZGRlZCBU
WHg5IHNwZWNpZmljICJpY2Rpc2FibGUiDQo+ID4gYW5kDQo+ID4gImRjZGlzYWJsZSIga2VybmVs
IG9wdGlvbnMgZm9yIGRlYnVnZ2luZyBsb25nIGFnby4NCj4gPiANCj4gPiBJIGhvcGUgdGhlc2Ug
b3B0aW9ucyBzdGlsbCB3b3JrcyBjb3JyZWN0bHkgd2l0aCByZWNlbnQga2VybmVsIGJ1dA0KPiA+
IG5vdA0KPiA+IHN1cmUuDQo+ID4gDQo+ID4gQWxzbywgZGlzYWJsaW5nIGktY2FjaGUgbWFrZXMg
eW91ciBib2FyZCBWRVJZIHNsb3csIG9mIGNvdXJzZS4NCj4gDQo+IFRoYW5rcyENCj4gDQo+IFdo
ZW4gdXNpbmcgdGhlc2Ugb3B0aW9ucywgSSBkbyBzZWUgYSBzbG93ZG93biBpbiBlYXJseSBib290
LCBidXQgdGhlDQo+IGlzc3VlDQo+IGlzIHN0aWxsIHRoZXJlLg0KPiANCj4gTXkgbmV4dCBndWVz
cyBpcyBhbiB1bmFsaWduZWQgYWNjZXNzIG5vdCB1c2luZyB7Z2V0LHB1dH1fdW5hbGlnbmVkKCks
DQo+IHdoaWNoDQo+IGRvZXNuJ3Qgc2VlbSB0byB3b3JrIG9uIHR4NDkyNywgYnV0IGRvZXNuJ3Qg
Y2F1c2UgYW4gZXhjZXB0aW9uDQo+IG5laXRoZXIuDQoNCkNhbiB5b3UgdHJ5IG15IGxpbnV4LW5l
eHQgYnJhbmNoIG9uIGdpdC5saW51eC1uZnMub3JnPyBJdCBjb250YWlucyBhDQpmaXhlcyBmb3Ig
YSBoYW5nIHRoYXQgcmVzdWx0cyBmcm9tIHRoZSBhYm92ZSBjb21taXQuDQoNCmdpdCBwdWxsIGdp
dDovL2dpdC5saW51eC1uZnMub3JnL3Byb2plY3RzL3Ryb25kbXkvbGludXgtbmZzLmdpdCBsaW51
eC1uZXh0DQoNCkNoZWVycw0KICBUcm9uZA0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXgg
TkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1l
cnNwYWNlLmNvbQ0KDQoNCg==
