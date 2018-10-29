Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDFD7C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 18:02:37 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6D9E62064C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 18:02:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="gDWDofbE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D9E62064C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728199AbeJ3CwS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:52:18 -0400
Received: from mail-cys01nam02on0138.outbound.protection.outlook.com ([104.47.37.138]:14119
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728104AbeJ3CwR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 Oct 2018 22:52:17 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ZL2SdQK/hsKdaZSn/udiKusH2sOfMhQNPKJFZHpMEDg=;
 b=gDWDofbEsd0q/Jpq0LnlIoxjMti7fIxGPrZSF+DtObfgDVLD+Pzgl9HxE3KhDWOHRQJl9IARrGR/E87NwLpurE/nIbAPd3zMGIMJoxhP3elzY23lRh7yXZdRRm63jL5ZXjXCYxtB/2nj8Qzx1tO/QtjazPWYW0Bj52o7NZ2us5k=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6SPR01MB08.namprd13.prod.outlook.com (52.132.115.30) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.16; Mon, 29 Oct 2018 18:02:30 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1294.018; Mon, 29 Oct 2018
 18:02:30 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "julien.thierry@arm.com" <julien.thierry@arm.com>
CC:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: Fix iter_iov_*vec warnings
Thread-Topic: [PATCH] SUNRPC: Fix iter_iov_*vec warnings
Thread-Index: AQHUb7CJz8h5owhNWEOeLWVlebGhlKU2g7oA
Date:   Mon, 29 Oct 2018 18:02:30 +0000
Message-ID: <13c918d699c45a3116b61e396d7c6eb881098940.camel@hammerspace.com>
References: <1540835701-23176-1-git-send-email-julien.thierry@arm.com>
In-Reply-To: <1540835701-23176-1-git-send-email-julien.thierry@arm.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6SPR01MB08;6:y1nrb9aY/16xhGGrKKh+7ZP6J0AD1/iPoGTUlCTTiK9bFczNq4vMUFNcVSDJtCtScm6CyAvDaC2BkAEkVtUi3fzTk1oIi0EOOl6Wn5perGOw6OcwWD/z+VuUYZzoTMKUcmkcf2jw7rANiirNggIYHOeUqaqhVFO+HHg86qbX31s19TCWd2LjMzeSUXSw4HQGZDsDnYaTUCPM5yIT2ipsdKtmiqYyS1c3JKsh1NzvsX9mk4HoGh2/O/U/GjTm5Q6lQQXhEAW8DMmdA4H3SdqPGE7GHvzWlrM4FBPU/SWlOy2BxxGgPBC/YB3lFYwp0+iEdPJ3JlMep7qEzhG1H6686qC7oHcyLpeHizzPWEOqHnB5JLWz9j/Xum5rUX5MC3fvqGLDoBravNrpTbpEsqwcCGK14TFwIxKYqYbNOv/U8nuviBvefDduCwuLLhFVKNXvadaILhZ1CQSyg5FTPrzuDg==;5:AUbt5HDI7uOoRlDKOBleEPx2ogJ09dJpliezjyV1GAHiTAWEt0VdcGQnlszCquBLzF7FL5cVDeZwjLl6QXlHYYd+NOwrIrneoCUmb09sjL7wGxW41cubI6xoY9hzYzdOqFFMchCkQAH6VcUQoDk9xEzvD2VMErxweMFovMwKlVk=;7:JCr8sVu2xcsTNmSBz5PE1P9mXl21+kshQB7aScLRBZ2oDuCbJ/kY7/B0iIBHDjxaHyTrwiOr+Oa42lUkgml7mh85MaOmX/9W8I270efhZwtlIyPc1wlHe46UqD2NQUW8qLQISB1Nt56k9dng0Vz01Q==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 0ba4f72d-0734-4841-8666-08d63dc8b1c8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6SPR01MB08;
x-ms-traffictypediagnostic: SN6SPR01MB08:
x-microsoft-antispam-prvs: <SN6SPR01MB0899254666361618D73FCAB8F30@SN6SPR01MB08.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:(9452136761055)(180628864354917);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(93006095)(93001095)(10201501046)(3002001)(3231382)(944501410)(52105095)(148016)(149066)(150057)(6041310)(20161123564045)(20161123560045)(20161123562045)(20161123558120)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(201708071742011)(7699051)(76991095);SRVR:SN6SPR01MB08;BCL:0;PCL:0;RULEID:;SRVR:SN6SPR01MB08;
x-forefront-prvs: 084080FC15
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(136003)(39830400003)(396003)(346002)(376002)(366004)(51234002)(189003)(199004)(6246003)(4326008)(25786009)(36756003)(7736002)(256004)(476003)(53936002)(14444005)(99286004)(305945005)(446003)(2906002)(2616005)(68736007)(6116002)(478600001)(3846002)(45080400002)(106356001)(486006)(105586002)(118296001)(66066001)(11346002)(71190400001)(14454004)(2900100001)(4001150100001)(6436002)(6486002)(97736004)(6512007)(71200400001)(2501003)(5250100002)(110136005)(316002)(54906003)(26005)(186003)(86362001)(8676002)(8936002)(2201001)(81156014)(229853002)(102836004)(81166006)(6506007)(76176011)(15974865002)(5660300001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6SPR01MB08;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: GF6BfG1SrLRjd/AqqN15DTlJQNW7iETWl+cQOzansq+8uaK0e8VdQpPZSSUc8TNP8MfNJNbhGJIbNsa5KlllqRZAKAh5Ek044CHAnfkH9PY8yfgIxAsKLQAJktyuFVMDpkn/2JRQS0aHjAd0TrNIo3rqMN1SZQI8PiYl7Ug1DcUpeyoVRlvAygAL9fNyIdfHI+V6ViNCd57tbZSpPguLoM/k3g7NWzVl/mjHtUD+pRTmX9aGcBS7TA1MODxrC5I4jVFr/lIzd8UNimt18nM3ozmtecaB4BaZ9r6iTR9cO9atbgTnCptYeJLA0NGx0Q0bMZRV+PMJ/qPOyOiWLCaMlEKvyjS6O4/m1JBkX+XZVAQ=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <539E608E8CEB8F4DB58C4F682597CA9A@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 0ba4f72d-0734-4841-8666-08d63dc8b1c8
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Oct 2018 18:02:30.3385
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6SPR01MB08
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Q2M6IEFsLCBzaW5jZSB0aGlzIHdhbnRzIHRvIGdvIHRocm91Z2ggaGlzIHB1bGwgcmVxdWVzdCAo
dGhlIFJQQyBjb2RlDQpoYXMgYWxyZWFkeSBiZWVuIG1lcmdlZCkuDQoNCk9uIE1vbiwgMjAxOC0x
MC0yOSBhdCAxNzo1NSArMDAwMCwgSnVsaWVuIFRoaWVycnkgd3JvdGU6DQo+IFdoaWxlIGJvb3Rp
bmcgbGludXgtbmV4dCBvbiBKdW5vIHdpdGggcm9vdGZzIG92ZXIgTkZTLCB0aGUgZm9sbG93aW5n
DQo+IHdhcm5pbmcgaXMgc3BhbW1lZCBvbiBrZXJuZWwgbG9nOg0KPiANCj4gWyAgIDE2Ljk4ODE5
MF0gV0FSTklORzogQ1BVOiAxIFBJRDogNjgwIGF0IGxpYi9pb3ZfaXRlci5jOjEwODINCj4gaW92
X2l0ZXJfa3ZlYysweDIwLzB4NDANCj4gWyAgIDE2Ljk5NTc3Nl0gTW9kdWxlcyBsaW5rZWQgaW46
DQo+IFsgICAxNi45OTg4MDFdIENQVTogMSBQSUQ6IDY4MCBDb21tOiBrd29ya2VyL3UxMzowIE5v
dCB0YWludGVkDQo+IDQuMTkuMC1uZXh0LTIwMTgxMDI5ICMyMjM4DQo+IFsgICAxNy4wMDY2NDBd
IEhhcmR3YXJlIG5hbWU6IEFSTSBKdW5vIGRldmVsb3BtZW50IGJvYXJkIChyMCkgKERUKQ0KPiBb
ICAgMTcuMDEyNTA1XSBXb3JrcXVldWU6IHhwcnRpb2QgeHNfc3RyZWFtX2RhdGFfcmVjZWl2ZV93
b3JrZm4NCj4gWyAgIDE3LjAxODEwOF0gcHN0YXRlOiAwMDAwMDAwNSAobnpjdiBkYWlmIC1QQU4g
LVVBTykNCj4gWyAgIDE3LjAyMjg1MV0gcGMgOiBpb3ZfaXRlcl9rdmVjKzB4MjAvMHg0MA0KPiBb
ICAgMTcuMDI2NzMzXSBsciA6IHhzX3N0cmVhbV9kYXRhX3JlY2VpdmUrMHgxOTQvMHgzNzgNCj4g
WyAgIDE3LjAzMTU1OV0gc3AgOiBmZmZmMDAwMDBiMDMzY2UwDQo+IFsgICAxNy4wMzQ4MzZdIHgy
OTogZmZmZjAwMDAwYjAzM2NlMCB4Mjg6IDAwMDAwMDAwMDAwMDAwMDANCj4gWyAgIDE3LjA0MDA5
NV0geDI3OiBmZmZmODAwOTc2MGI5ODcwIHgyNjogZmZmZjAwMDAwOTE3ZTFjOA0KPiBbICAgMTcu
MDQ1MzUyXSB4MjU6IDAwMDAwMDAwMDAwMDAwMDAgeDI0OiBmZmZmODAwOTc2YTkxNTk4DQo+IFsg
ICAxNy4wNTA2MTBdIHgyMzogZmZmZjAwMDAwOTE2OTAwMCB4MjI6IGZmZmY4MDA5Nzc1ZjAwMDAN
Cj4gWyAgIDE3LjA1NTg2N10geDIxOiAwMDAwMDAwMDAwMDAwMDBjIHgyMDogZmZmZjgwMDk3NmE5
MTU3OA0KPiBbICAgMTcuMDYxMTI0XSB4MTk6IGZmZmY4MDA5NzZhOTEwMDAgeDE4OiAwMDAwMDAw
MDAwMDAwMDAwDQo+IFsgICAxNy4wNjYzODFdIHgxNzogMDAwMDAwMDAwMDAwMDAwMCB4MTY6IDAw
MDAwMDAwMDAwMDAwMDANCj4gWyAgIDE3LjA3MTYzOV0geDE1OiAwMDAwMDAwMDAwMDAwNDAwIHgx
NDogMDAwMDAwMDAwMDAwMDQwMA0KPiBbICAgMTcuMDc2ODk2XSB4MTM6IDAwMDAwMDAwMDAwMDA0
MDAgeDEyOiAwMDAwMDAwMDAwMDAyZjI4DQo+IFsgICAxNy4wODIxNTNdIHgxMTogMDAwMDAwMDAw
MDAwMDAwMCB4MTA6IDAwMDAwMDAwMDAwMDA5NjANCj4gWyAgIDE3LjA4NzQxMF0geDkgOiBmZmZm
MDAwMDBiMDMzZDUwIHg4IDogZmVmZWZlZmVmZWZlZmVmZg0KPiBbICAgMTcuMDkyNjY3XSB4NyA6
IGZmZmY4MDA5N2ZmOWQzODAgeDYgOiAwMDAwMDAwMDAwMDAwMDAwDQo+IFsgICAxNy4wOTc5MjRd
IHg1IDogMDA2NDZmNjk3NDcyNzA3OCB4NCA6IDAwMDAwMDAwMDAwMDAwMGMNCj4gWyAgIDE3LjEw
MzE4MV0geDMgOiAwMDAwMDAwMDAwMDAwMDAxIHgyIDogZmZmZjAwMDAwYjAzM2QzMA0KPiBbICAg
MTcuMTA4NDM4XSB4MSA6IDAwMDAwMDAwMDAwMDAwMDIgeDAgOiBmZmZmMDAwMDBiMDMzZDUwDQo+
IFsgICAxNy4xMTM2OTVdIENhbGwgdHJhY2U6DQo+IFsgICAxNy4xMTYxMTVdICBpb3ZfaXRlcl9r
dmVjKzB4MjAvMHg0MA0KPiBbICAgMTcuMTE5NjUyXSAgeHNfc3RyZWFtX2RhdGFfcmVjZWl2ZV93
b3JrZm4rMHgxMC8weDE4DQo+IFsgICAxNy4xMjQ1NjhdICBwcm9jZXNzX29uZV93b3JrKzB4MWM4
LzB4MzE4DQo+IFsgICAxNy4xMjg1MzVdICB3b3JrZXJfdGhyZWFkKzB4NDgvMHg0MjgNCj4gWyAg
IDE3LjEzMjE1OF0gIGt0aHJlYWQrMHhmOC8weDEyOA0KPiBbICAgMTcuMTM1MjY2XSAgcmV0X2Zy
b21fZm9yaysweDEwLzB4MTgNCj4gWyAgIDE3LjEzODgwMV0gLS0tWyBlbmQgdHJhY2UgNjVjYmNk
MmRkYWVlZjU5ZSBdLS0tDQo+IA0KPiBUaGlzIGlzIGxpa2VseSBhIGNsYXNoIGJldHdlZW4gdGhl
IHJlY2VudCBhZGRpdGlvbiBvZiB2ZWN0b3INCj4gaXRlcmF0b3JzIHRvDQo+IFNVTlJQQyBhbmQg
dGhlIHJlY2VudA0KPiBjb21taXQgYWE1NjNkN2JjYTZlODgyZWMyYmRhZTI0NjAzYzhmMDE2NDAx
YTE0NCAoImlvdl9pdGVyOiBTZXBhcmF0ZQ0KPiB0eXBlIGZyb20gZGlyZWN0aW9uIGFuZCB1c2Ug
YWNjZXNzb3IgZnVuY3Rpb25zIikgd2hpY2ggc2xpZ2h0bHkNCj4gY2hhbmdlcw0KPiB0aGUgdXNh
Z2Ugb2YgdGhvc2UgaXRlcmF0b3JzIGJ5IHNwbGl0dGluZyB0eXBlIGFuZCBkaXJlY3Rpb24uDQo+
IA0KPiBGaXggdGhpcyBieSBub3QgaW5jbHVkaW5nIHR5cGUgaW4gdGhlIGRpcmVjdGlvbiBvZiB0
aGUgb3BlcmF0aW9uLg0KPiANCj4gRml4ZXM6IDI3N2U0YWI3ZDUzMGJmMjg3ZTAyYjY1Y2ZjZDNl
YThmNDg5Nzg0ZjYgKCJTVU5SUEM6IFNpbXBsaWZ5DQo+IFRDUA0KPiByZWNlaXZlIGNvZGUgYnkg
c3dpdGNoaW5nIHRvIHVzaW5nIGl0ZXJhdG9ycyIpDQo+IA0KPiBTaWduZWQtb2ZmLWJ5OiBKdWxp
ZW4gVGhpZXJyeSA8anVsaWVuLnRoaWVycnlAYXJtLmNvbT4NCj4gQ2M6IFRyb25kIE15a2xlYnVz
dCA8dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbT4NCj4gQ2M6IEFubmEgU2NodW1ha2Vy
IDxhbm5hLnNjaHVtYWtlckBuZXRhcHAuY29tPg0KPiBDYzogIkouIEJydWNlIEZpZWxkcyIgPGJm
aWVsZHNAZmllbGRzZXMub3JnPg0KPiBDYzogSmVmZiBMYXl0b24gPGpsYXl0b25Aa2VybmVsLm9y
Zz4NCj4gQ2M6ICJEYXZpZCBTLiBNaWxsZXIiIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KPiBDYzog
bmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KPiBDYzogbGludXgta2VybmVsQHZnZXIua2VybmVsLm9y
Zw0KPiAtLS0NCj4gIG5ldC9zdW5ycGMveHBydHNvY2suYyB8IDQgKystLQ0KPiAgMSBmaWxlIGNo
YW5nZWQsIDIgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkNCj4gDQo+IGRpZmYgLS1naXQg
YS9uZXQvc3VucnBjL3hwcnRzb2NrLmMgYi9uZXQvc3VucnBjL3hwcnRzb2NrLmMNCj4gaW5kZXgg
MWI1MWUwNC4uYWU3N2M3MSAxMDA2NDQNCj4gLS0tIGEvbmV0L3N1bnJwYy94cHJ0c29jay5jDQo+
ICsrKyBiL25ldC9zdW5ycGMveHBydHNvY2suYw0KPiBAQCAtMzYxLDcgKzM2MSw3IEBAIHN0YXRp
YyB2b2lkIHhzX2ZyZWVfcGVlcl9hZGRyZXNzZXMoc3RydWN0DQo+IHJwY194cHJ0ICp4cHJ0KQ0K
PiAgeHNfcmVhZF9rdmVjKHN0cnVjdCBzb2NrZXQgKnNvY2ssIHN0cnVjdCBtc2doZHIgKm1zZywg
aW50IGZsYWdzLA0KPiAgCQlzdHJ1Y3Qga3ZlYyAqa3ZlYywgc2l6ZV90IGNvdW50LCBzaXplX3Qg
c2VlaykNCj4gIHsNCj4gLQlpb3ZfaXRlcl9rdmVjKCZtc2ctPm1zZ19pdGVyLCBSRUFEIHwgSVRF
Ul9LVkVDLCBrdmVjLCAxLA0KPiBjb3VudCk7DQo+ICsJaW92X2l0ZXJfa3ZlYygmbXNnLT5tc2df
aXRlciwgUkVBRCwga3ZlYywgMSwgY291bnQpOw0KPiAgCXJldHVybiB4c19zb2NrX3JlY3Ztc2co
c29jaywgbXNnLCBmbGFncywgc2Vlayk7DQo+ICB9DQo+ICANCj4gQEAgLTM3MCw3ICszNzAsNyBA
QCBzdGF0aWMgdm9pZCB4c19mcmVlX3BlZXJfYWRkcmVzc2VzKHN0cnVjdA0KPiBycGNfeHBydCAq
eHBydCkNCj4gIAkJc3RydWN0IGJpb192ZWMgKmJ2ZWMsIHVuc2lnbmVkIGxvbmcgbnIsIHNpemVf
dCBjb3VudCwNCj4gIAkJc2l6ZV90IHNlZWspDQo+ICB7DQo+IC0JaW92X2l0ZXJfYnZlYygmbXNn
LT5tc2dfaXRlciwgUkVBRCB8IElURVJfQlZFQywgYnZlYywgbnIsDQo+IGNvdW50KTsNCj4gKwlp
b3ZfaXRlcl9idmVjKCZtc2ctPm1zZ19pdGVyLCBSRUFELCBidmVjLCBuciwgY291bnQpOw0KPiAg
CXJldHVybiB4c19zb2NrX3JlY3Ztc2coc29jaywgbXNnLCBmbGFncywgc2Vlayk7DQo+ICB9DQo+
ICANCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpDVE8sIEhhbW1lcnNwYWNlIEluYw0KNDMwMCBFbCBD
YW1pbm8gUmVhbCwgU3VpdGUgMTA1DQpMb3MgQWx0b3MsIENBIDk0MDIyDQp3d3cuaGFtbWVyLnNw
YWNlDQoNCg0K
