Return-Path: <SRS0=lcGf=NX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7D1BC43441
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 17:59:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 529992243E
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 17:59:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="TaE9/Mh8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 529992243E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727530AbeKMDx5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Nov 2018 22:53:57 -0500
Received: from mail-eopbgr790090.outbound.protection.outlook.com ([40.107.79.90]:16544
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727363AbeKMDx4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Nov 2018 22:53:56 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=MFTMQb0eZI1c/VYNWngG+cyw7XSG0Tkn6Ddoh0npqqE=;
 b=TaE9/Mh88bzPvg/tHpxXxKE0AzICYwsEQEd/d1Es7DAMTHnSNJhPu+0XVxw/giATnJYtWWUS2BDzzTpAFIHrhnhf3ktaLDK0a9VFqRBwCJtTt8P/rdGnkZS6Iz9RgdkbY66ponCcQp+h2MXKWtMATrozW4H5amr8ldYGfY4wd4A=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2240.namprd13.prod.outlook.com (52.135.93.153) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1339.15; Mon, 12 Nov 2018 17:59:34 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1339.019; Mon, 12 Nov 2018
 17:59:34 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "chucklever@gmail.com" <chucklever@gmail.com>
CC:     "schumakeranna@gmail.com" <schumakeranna@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NULL dereference in rpcauth_lookup_credcache
Thread-Topic: NULL dereference in rpcauth_lookup_credcache
Thread-Index: AQHUd6xJVdpNrPMTaUWtaTxXqXNyo6VHvSMAgAHSE4CAAuRdgA==
Date:   Mon, 12 Nov 2018 17:59:33 +0000
Message-ID: <c986450a2d19fa796078ed51b9d0fb8a79eda696.camel@hammerspace.com>
References: <20181108214452.GH6090@fieldses.org>
         <04114B00-B5A8-4F8A-B052-A266AED7725D@gmail.com>
         <20181110214939.GA16755@fieldses.org>
In-Reply-To: <20181110214939.GA16755@fieldses.org>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2240;6:E63NS4LbfmpTLnMDOMKd/lTuij2+528RypB/oFe+cY70Hn4ZpFJCUetDNt3obq1buZk5oI9UfijrWgrwEKkTnDUMQ2U3a1EyPLQpANe2+r5O96VJtNHaX0ZvP6Ig8Ta/Y9rWTKR4knXYzOhm8KlZPp2jPDvFVQIwQmiM1Xvlpg0ObgHTtKG2miFCDknFbNFze3ZpFWZj9H/UvkyJTjHpV06BJJJKuTMIPXOvQT3XMnVU3SmhNMmiKHs5QQb56IUA3B5NMzy5b/UDfjq1Aha6eYvOeoWOQak9LMZ4/3PWY1NriirihbCii7sS0JXtkm1O+m07QQpNkV7ZI88canpws0soQjjWqQRTnep4lxAKY9R/2cVeLlW5cG4bCoTdmVY5fF26RvT7L2sw8L9K5yFmOQva7IAkVM2gEhMR8kHmJrpNzX61KpMZglZsFRofRLJn2Ud7oX5m1jb4y032dLt6Yw==;5:R8jEm5tMeoXenWv3vZUzgmmed02yX4fYp4iubDkdbsfSRDJfAjJQ0wbghDYeHj0NyE6hXVjGIFalwGKGMfbzV2DoHfjGUAZlDqip/1ASWw9iDsbzRddsCSJxyumTOY8J3q0PIpMPUb9173/MAO4wZk+1svca3Gk3xl9SmNGngEo=;7:PyQRLTARQvu5YpjUNw9VWs72EsUsNxCbRmiOs7lJQuG+7i5jDlZavyiMJZ/4lJU25u1e8PCfm8LaffjAKkvZ3MzcFKRiCt3vYWFNdC4uR1adZHGQEXok+njF3xIdpMXAcg7CIMRRIU8+VP3yibetGg==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 94dcf641-4e3b-474f-41af-08d648c89a7f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390040)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2240;
x-ms-traffictypediagnostic: SN6PR13MB2240:
x-microsoft-antispam-prvs: <SN6PR13MB224016AED1851C471F5BF3B7B8C10@SN6PR13MB2240.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(3231382)(944501410)(52105112)(3002001)(10201501046)(93006095)(93001095)(148016)(149066)(150057)(6041310)(20161123558120)(20161123562045)(20161123564045)(20161123560045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2240;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2240;
x-forefront-prvs: 0854128AF0
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39830400003)(136003)(396003)(366004)(346002)(376002)(189003)(199004)(51234002)(8936002)(186003)(86362001)(81166006)(8676002)(81156014)(53936002)(6486002)(15974865002)(6436002)(97736004)(6246003)(66066001)(256004)(478600001)(4001150100001)(305945005)(6512007)(36756003)(4326008)(45080400002)(2616005)(39060400002)(11346002)(229853002)(7736002)(68736007)(476003)(99286004)(5660300001)(486006)(71200400001)(71190400001)(25786009)(105586002)(102836004)(54906003)(106356001)(316002)(118296001)(14454004)(2900100001)(110136005)(26005)(53546011)(2906002)(2501003)(6116002)(3846002)(446003)(76176011)(6506007);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2240;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: eYtz6KHwQYW9IKXfz/Ha+c8Ph1w0VXp1NN9xjdIqo223i5g9feUp0459CkiAnuhFGvy5ID7uBNRuiAf6zr7rWqv8rZ2YjyXjwswBaDflQk4StLWteWcl3B9J86Ku0vMvLJNnMgNOERdzxXxiNhYo2Vk3U3KlW/Aer6sbv09iZF1E9YcCIlgA7r1RKLWoabfuwNSgHWlKWJNqbzvVA+ukcXWm7BxIzr6r105nJq9TvBp6z4SsDUiUgXMavztmClX9Rawh4BK9mdO79ZzI2RLqk2Zu9njolMb32ic6AHKs0ddNl79NcpZUYzq8xkMxs6TNNMpNxWAkX3ukHqNDqyPZLvp5yPaImWTcwQSVjaHPjIA=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <76F34FB169A5574AA5DAAA796D44AED4@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 94dcf641-4e3b-474f-41af-08d648c89a7f
X-MS-Exchange-CrossTenant-originalarrivaltime: 12 Nov 2018 17:59:34.0502
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2240
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gU2F0LCAyMDE4LTExLTEwIGF0IDE2OjQ5IC0wNTAwLCBCcnVjZSBGaWVsZHMgd3JvdGU6DQo+
IExvb2tzIGxpa2UgaXQncyB0aGUgZmF1bHQgb2YNCj4gDQo+IDA3ZDAyYTY3YjdmYWFlICJTVU5S
UEM6IFNpbXBsaWZ5IGxvb2t1cCBjb2RlIg0KDQpJJ20gaGF2aW5nIHRyb3VibGUgcmVwcm9kdWNp
bmcgdGhpcyBidWcuIEkndmUgdHJpZWQgYm90aCBjdGhvbiBhbmQNCnhmc3Rlc3RzIGluIGEgbG9v
cCwgc28gZmFyIHdpdGhvdXQgc3VjY2VzcyAoYm90aCBORlN2MyBhbmQgdjQuMSwgYnV0DQpvbmx5
IHNlYz1zeXMpLiBJcyB0aGVyZSBhbnl0aGluZyBlbHNlIHlvdSdyZSBkb2luZyB0aGF0IEkgbWln
aHQgdHJ5Pw0KDQplLmcuIEFyZSB5b3UgcnVubmluZyBtdWx0aXBsZSB3b3JrbG9hZHMgaW4gcGFy
YWxsZWw/IERpZmZlcmVudCB1c2Vycz8uLg0KDQo+IA0KPiAtLWIuDQo+IA0KPiBPbiBGcmksIE5v
diAwOSwgMjAxOCBhdCAwMTowMTozMFBNIC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4gPiAN
Cj4gPiA+IE9uIE5vdiA4LCAyMDE4LCBhdCA0OjQ0IFBNLCBKLiBCcnVjZSBGaWVsZHMgPGJmaWVs
ZHNAZmllbGRzZXMub3JnDQo+ID4gPiA+IHdyb3RlOg0KPiA+ID4gDQo+ID4gPiBTaW5jZSAtcmMx
IG15IHJlZ3Jlc3Npb24gdGVzdHMgY3Jhc2ggbXkgY2xpZW50LiAgSXMgdGhpcyBhIGtub3duDQo+
ID4gPiBwcm9ibGVtPyAgSSdsbCBpbnZlc3RpZ2F0ZSBzb21lIG1vcmUsIEkgaGF2ZW4ndCBldmVu
IGxvb2tlZCBhdA0KPiA+ID4gdGhlIGNvZGUNCj4gPiA+IHlldCBvciBjaGVja2VkIHdoaWNoIHRl
c3QgZXhhY3RseSBpcyBoaXR0aW5nIHRoaXMuDQo+ID4gPiANCj4gPiA+IC0tYi4NCj4gPiA+IA0K
PiA+ID4gWyAgMTY0LjEwOTU3MF0gQlVHOiB1bmFibGUgdG8gaGFuZGxlIGtlcm5lbCBOVUxMIHBv
aW50ZXINCj4gPiA+IGRlcmVmZXJlbmNlIGF0IDAwMDAwMDAwMDAwMDAwMDgNCj4gPiA+IFsgIDE2
NC4xMTEyMDddIFBHRCAwIFA0RCAwIA0KPiA+ID4gWyAgMTY0LjExMTUyOF0gT29wczogMDAwMCBb
IzFdIFBSRUVNUFQgU01QIFBUSQ0KPiA+ID4gWyAgMTY0LjExMjMwM10gQ1BVOiAyIFBJRDogMjk0
NyBDb21tOiBrd29ya2VyL3U4OjUgTm90IHRhaW50ZWQNCj4gPiA+IDQuMjAuMC1yYzEtMTMyMjMt
Z2FmYjZkMWM0NzRlZiAjMTg5OA0KPiA+ID4gWyAgMTY0LjExMzQ4N10gSGFyZHdhcmUgbmFtZTog
UUVNVSBTdGFuZGFyZCBQQyAoaTQ0MEZYICsgUElJWCwNCj4gPiA+IDE5OTYpLCBCSU9TID8tMjAx
ODA1MzFfMTQyMDE3LWJ1aWxkaHctMDgucGh4Mi5mZWRvcmFwcm9qZWN0Lm9yZy0NCj4gPiA+IDEu
ZmMyOCAwNC8wMS8yMDE0DQo+ID4gPiBbICAxNjQuMTE1MzAxXSBXb3JrcXVldWU6IHJwY2lvZCBy
cGNfYXN5bmNfc2NoZWR1bGUgW3N1bnJwY10NCj4gPiA+IFsgIDE2NC4xMTU5MjBdIFJJUDogMDAx
MDpycGNhdXRoX2xvb2t1cF9jcmVkY2FjaGUrMHgzZC8weDQ1MA0KPiA+ID4gW3N1bnJwY10NCj4g
PiA+IFsgIDE2NC4xMTY3MDBdIENvZGU6IDg5IGY1IDQxIDU0IDQxIDg5IGQ0IDUzIDQ4IDgzIGVj
IDM4IDg5IDRkIGIwDQo+ID4gPiA0YyA4YiA3ZiAyMCA2NSA0OCA4YiAwNCAyNSAyOCAwMCAwMCAw
MCA0OCA4OSA0NSBkMCAzMSBjMCA0OCA4ZCA0NQ0KPiA+ID4gYzAgNDggODkgNDUgYzggPDQxPiA4
YiA3NyAwOCA0OCA4OSA0NSBjMCA0OCA4YiA0NyAxMCA0YyA4OSBlZiA0OA0KPiA+ID4gOGIgNDAg
MjggZTggY2IgZDINCj4gPiA+IFsgIDE2NC4xMTkyOTldIFJTUDogMDAxODpmZmZmYzkwMDAxZWUz
Y2YwIEVGTEFHUzogMDAwMTAyNDYNCj4gPiA+IFsgIDE2NC4xMTk4NzJdIFJBWDogZmZmZmM5MDAw
MWVlM2QxMCBSQlg6IGZmZmY4ODAwN2NjMTgxODAgUkNYOg0KPiA+ID4gMDAwMDAwMDAwMDYwMDA0
MA0KPiA+ID4gWyAgMTY0LjEyMDgwMF0gUkRYOiAwMDAwMDAwMDAwMDAwMDAxIFJTSTogZmZmZmM5
MDAwMWVlM2Q2MCBSREk6DQo+ID4gPiBmZmZmODgwMDdjYWZiMTk4DQo+ID4gPiBbICAxNjQuMTIx
NjQzXSBSQlA6IGZmZmZjOTAwMDFlZTNkNTAgUjA4OiAwMDAwMDAwMDAwMDAwMDAwIFIwOToNCj4g
PiA+IDAwMDAwMDAwMDAwMDAwMDANCj4gPiA+IFsgIDE2NC4xMjI0NjRdIFIxMDogMDAwMDAwMDAw
MDAwMDAwMCBSMTE6IDAwMDAwMDAwMDAwMDAwMDAgUjEyOg0KPiA+ID4gMDAwMDAwMDAwMDAwMDAw
MQ0KPiA+ID4gWyAgMTY0LjEyMzM3M10gUjEzOiBmZmZmYzkwMDAxZWUzZDYwIFIxNDogZmZmZjg4
MDA3Y2FmYjE5OCBSMTU6DQo+ID4gPiAwMDAwMDAwMDAwMDAwMDAwDQo+ID4gPiBbICAxNjQuMTI0
Mjk2XSBGUzogIDAwMDAwMDAwMDAwMDAwMDAoMDAwMCkNCj4gPiA+IEdTOmZmZmY4ODAwN2ZkMDAw
MDAoMDAwMCkga25sR1M6MDAwMDAwMDAwMDAwMDAwMA0KPiA+ID4gWyAgMTY0LjEyNTMyMl0gQ1M6
ICAwMDEwIERTOiAwMDAwIEVTOiAwMDAwIENSMDogMDAwMDAwMDA4MDA1MDAzMw0KPiA+ID4gWyAg
MTY0LjEyNjAwNl0gQ1IyOiAwMDAwMDAwMDAwMDAwMDA4IENSMzogMDAwMDAwMDA3ODI5YzAwMyBD
UjQ6DQo+ID4gPiAwMDAwMDAwMDAwMTYwNmUwDQo+ID4gPiBbICAxNjQuMTI2ODYwXSBDYWxsIFRy
YWNlOg0KPiA+ID4gWyAgMTY0LjEyNzA0NV0gID8gY2FsbF9yZXRyeV9yZXNlcnZlKzB4MzAvMHgz
MCBbc3VucnBjXQ0KPiA+ID4gWyAgMTY0LjEyNzYyMl0gIHJwY2F1dGhfbG9va3VwY3JlZCsweGEw
LzB4YzAgW3N1bnJwY10NCj4gPiA+IFsgIDE2NC4xMjgyMDBdICBycGNhdXRoX3JlZnJlc2hjcmVk
KzB4MTVmLzB4MTcwIFtzdW5ycGNdDQo+ID4gPiBbICAxNjQuMTI4ODA3XSAgX19ycGNfZXhlY3V0
ZSsweGE5LzB4NDYwIFtzdW5ycGNdDQo+ID4gPiBbICAxNjQuMTI5MjgxXSAgcHJvY2Vzc19vbmVf
d29yaysweDIyNy8weDYzMA0KPiA+ID4gWyAgMTY0LjEyOTY4NF0gIHdvcmtlcl90aHJlYWQrMHgz
Yy8weDM5MA0KPiA+ID4gWyAgMTY0LjEzMDA2Ml0gID8gcHJvY2Vzc19vbmVfd29yaysweDYzMC8w
eDYzMA0KPiA+ID4gWyAgMTY0LjEzMDYwOV0gIGt0aHJlYWQrMHgxMWQvMHgxNDANCj4gPiA+IFsg
IDE2NC4xMzA5MzZdICA/IGt0aHJlYWRfcGFyaysweDgwLzB4ODANCj4gPiA+IFsgIDE2NC4xMzEz
MzldICByZXRfZnJvbV9mb3JrKzB4M2EvMHg1MA0KPiA+ID4gWyAgMTY0LjEzMTY3Nl0gTW9kdWxl
cyBsaW5rZWQgaW46IHJwY3NlY19nc3Nfa3JiNSBuZnN2NCBuZnMgbG9ja2QNCj4gPiA+IGdyYWNl
IGF1dGhfcnBjZ3NzIHN1bnJwYw0KPiA+ID4gWyAgMTY0LjEzMjcxOV0gQ1IyOiAwMDAwMDAwMDAw
MDAwMDA4DQo+ID4gPiBbICAxNjQuMTMzMDUwXSAtLS1bIGVuZCB0cmFjZSBiNDAyOGE2NzgxYTY5
NmFkIF0tLS0NCj4gPiA+IA0KPiA+IA0KPiA+IEkganVzdCBlbmNvdW50ZXJlZCB0aGlzIHJlcGVh
dGVkbHkgd2l0aCBjdGhvbjA0IGdlbmVyYWwgdGVzdHMuDQo+ID4gDQo+ID4gTU5UT1BUSU9OUz0i
cncscHJvdG89dGNwLHZlcnM9NC4xLHNlYz1zeXMiDQo+ID4gDQo+ID4gDQo+ID4gLS0NCj4gPiBD
aHVjayBMZXZlcg0KPiA+IGNodWNrbGV2ZXJAZ21haWwuY29tDQo+ID4gDQo+ID4gDQotLSANClRy
b25kIE15a2xlYnVzdA0KQ1RPLCBIYW1tZXJzcGFjZSBJbmMNCjQzMDAgRWwgQ2FtaW5vIFJlYWws
IFN1aXRlIDEwNQ0KTG9zIEFsdG9zLCBDQSA5NDAyMg0Kd3d3LmhhbW1lci5zcGFjZQ0KDQoNCg==
